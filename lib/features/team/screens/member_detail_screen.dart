import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/history_timeline.dart';
import '../../../core/widgets/info_section.dart';
import '../../../core/widgets/person_avatar.dart';
import '../../../core/widgets/status_chip.dart';
import '../models/member.dart';
import '../models/shift.dart';
import 'member_form_screen.dart';
import 'shift_detail_screen.dart';

class MemberDetailScreen extends StatefulWidget {
  const MemberDetailScreen({super.key, required this.memberId});

  final String memberId;

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  late Future<(Member, List<Shift>)> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(Member, List<Shift>)> _load() async {
    final member = await Locator.team.getMember(widget.memberId);
    final shifts = await Locator.team.getShifts();
    final upcoming = shifts
        .where((s) => s.memberIds.contains(member.id) && daysFromToday(s.date) >= 0)
        .toList();
    return (member, upcoming);
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBody<(Member, List<Shift>)>(
      future: _future,
      builder: (context, data) {
        final (m, shifts) = data;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Hồ sơ thành viên'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  await pushScreen(context, MemberFormScreen(member: m));
                  setState(() => _future = _load());
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      PersonAvatar(m.name, radius: 30),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                            Text('${m.code} · ${m.role}', style: const TextStyle(color: AppColors.textSecondary)),
                            const SizedBox(height: 6),
                            StatusChip(label: m.status.label, color: m.status.color),
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
                        tooltip: 'Gọi điện',
                        onPressed: () => showSnack(context, 'Gọi ${m.phone} (cần thư viện url_launcher)'),
                        icon: const Icon(Icons.call),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              InfoSection(
                title: 'Phân công',
                icon: Icons.assignment_ind_outlined,
                children: [
                  InfoRow('Chức vụ', m.role),
                  InfoRow('Nhiệm vụ', m.duty),
                  InfoRow('Điện thoại', m.phone),
                ],
              ),
              const SizedBox(height: 12),
              InfoSection(
                title: 'Huấn luyện',
                icon: Icons.school_outlined,
                trailing: StatusChip(
                  label: m.trainingOk ? 'Đạt yêu cầu' : 'Chưa đáp ứng',
                  color: m.trainingOk ? AppColors.success : AppColors.danger,
                ),
                children: [Text(m.trainingNote)],
              ),
              const SizedBox(height: 12),
              InfoSection(
                title: 'Ca trực sắp tới',
                icon: Icons.shield_outlined,
                children: [
                  if (shifts.isEmpty)
                    const Text('Chưa có ca trực', style: TextStyle(color: AppColors.textSecondary)),
                  for (final s in shifts)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: const Icon(Icons.event, color: AppColors.primary),
                      title: Text('${fmtFullDate(s.date)} · ${s.timeRange}'),
                      subtitle: Text(s.location),
                      trailing: Icon(
                        s.confirmedIds.contains(m.id) ? Icons.check_circle : Icons.help_outline,
                        color: s.confirmedIds.contains(m.id) ? AppColors.success : AppColors.warning,
                      ),
                      onTap: () => pushScreen(context, ShiftDetailScreen(shiftId: s.id)),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              InfoSection(
                title: 'Lịch sử thay đổi vai trò, phân công',
                icon: Icons.history,
                children: [HistoryTimeline(entries: m.history)],
              ),
            ],
          ),
        );
      },
    );
  }
}
