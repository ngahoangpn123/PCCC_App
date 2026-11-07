import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/status_chip.dart';
import '../../calendar/widgets/month_grid.dart';
import '../models/member.dart';
import '../models/shift.dart';
import 'shift_detail_screen.dart';
import 'shift_form_screen.dart';

/// Lịch trực với 2 chế độ: lịch tháng và danh sách ca trực.
class ShiftScheduleTab extends StatefulWidget {
  const ShiftScheduleTab({super.key});

  @override
  State<ShiftScheduleTab> createState() => _ShiftScheduleTabState();
}

class _ShiftScheduleTabState extends State<ShiftScheduleTab> {
  late Future<(List<Shift>, List<Member>)> _future;
  bool _calendarMode = true;
  DateTime _month = DateTime.now();
  DateTime _selected = dateOnly(DateTime.now());

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(List<Shift>, List<Member>)> _load() async {
    final shifts = await Locator.team.getShifts();
    final members = await Locator.team.getMembers();
    return (shifts, members);
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _open(Shift s) async {
    await pushScreen(context, ShiftDetailScreen(shiftId: s.id));
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await pushScreen(context, ShiftFormScreen(initialDate: _selected));
          _reload();
        },
        icon: const Icon(Icons.add),
        label: const Text('Tạo lịch trực'),
      ),
      body: AsyncBody<(List<Shift>, List<Member>)>(
        future: _future,
        builder: (context, data) {
          final (shifts, members) = data;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, icon: Icon(Icons.calendar_month), label: Text('Lịch tháng')),
                    ButtonSegment(value: false, icon: Icon(Icons.view_list), label: Text('Danh sách')),
                  ],
                  selected: {_calendarMode},
                  onSelectionChanged: (v) => setState(() => _calendarMode = v.first),
                ),
              ),
              Expanded(
                child: _calendarMode
                    ? _buildCalendar(shifts, members)
                    : _buildList(shifts, members),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCalendar(List<Shift> shifts, List<Member> members) {
    final markers = <DateTime, List<Color>>{};
    for (final s in shifts) {
      final key = dateOnly(s.date);
      markers.putIfAbsent(key, () => []).add(
        s.understaffed ? AppColors.danger : AppColors.primary,
      );
    }
    final ofDay = shifts.where((s) => sameDay(s.date, _selected)).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 90),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: MonthGrid(
              month: _month,
              selected: _selected,
              markers: markers,
              onSelect: (d) => setState(() => _selected = d),
              onMonthChanged: (m) => setState(() => _month = m),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
          child: Text(
            fmtFullDate(_selected),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
        if (ofDay.isEmpty)
          const Padding(
            padding: EdgeInsets.all(4),
            child: Text('Không có ca trực trong ngày', style: TextStyle(color: AppColors.textSecondary)),
          ),
        for (final s in ofDay)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ShiftCard(shift: s, members: members, onTap: () => _open(s)),
          ),
      ],
    );
  }

  Widget _buildList(List<Shift> shifts, List<Member> members) {
    final upcoming = shifts.where((s) => daysFromToday(s.date) >= 0).toList();
    final past = shifts.where((s) => daysFromToday(s.date) < 0).toList().reversed.toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
      children: [
        const Text('SẮP TỚI', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.gold, fontSize: 12)),
        const SizedBox(height: 8),
        for (final s in upcoming)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ShiftCard(shift: s, members: members, showDate: true, onTap: () => _open(s)),
          ),
        const SizedBox(height: 8),
        const Text('ĐÃ QUA', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.gold, fontSize: 12)),
        const SizedBox(height: 8),
        for (final s in past)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ShiftCard(shift: s, members: members, showDate: true, onTap: () => _open(s)),
          ),
      ],
    );
  }
}

/// Thẻ tóm tắt một ca trực: giờ, địa điểm, quân số dự kiến / đã xác nhận.
class ShiftCard extends StatelessWidget {
  const ShiftCard({
    super.key,
    required this.shift,
    required this.members,
    required this.onTap,
    this.showDate = false,
  });

  final Shift shift;
  final List<Member> members;
  final VoidCallback onTap;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final s = shift;
    final leader = members.where((m) => m.id == s.leaderId).map((m) => m.name).firstOrNull ?? '—';
    final staffColor = s.understaffed ? AppColors.danger : AppColors.success;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.schedule, size: 18, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      showDate ? '${fmtFullDate(s.date)} · ${s.timeRange}' : s.timeRange,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  StatusChip(label: s.status.label, color: s.status.color),
                ],
              ),
              const SizedBox(height: 6),
              Text('${s.location} · Phụ trách: $leader',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.groups, size: 18, color: staffColor),
                  const SizedBox(width: 6),
                  Text(
                    'Phân công ${s.memberIds.length}/${s.requiredCount}',
                    style: TextStyle(color: staffColor, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.how_to_reg, size: 18, color: AppColors.info),
                  const SizedBox(width: 6),
                  Text('Đã xác nhận ${s.confirmedIds.length}'),
                  const Spacer(),
                  if (s.understaffed)
                    const StatusChip(label: 'Thiếu người', color: AppColors.danger, icon: Icons.warning),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
