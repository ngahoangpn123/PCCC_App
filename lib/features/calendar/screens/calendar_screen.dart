import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../acceptance/screens/acceptance_hub_screen.dart';
import '../../acceptance/screens/readiness_screen.dart';
import '../../drills/screens/drill_detail_screen.dart';
import '../../equipment/screens/equipment_detail_screen.dart';
import '../../facility/screens/dossier_detail_screen.dart';
import '../../team/screens/shift_detail_screen.dart';
import '../../training/screens/training_session_detail_screen.dart';
import '../models/calendar_event.dart';
import '../widgets/month_grid.dart';

/// Mở màn hình chi tiết tương ứng với một mục lịch.
Future<void> openEventTarget(BuildContext context, CalendarEvent e) {
  final Widget screen = switch (e.kind) {
    EventKind.shift => ShiftDetailScreen(shiftId: e.refId),
    EventKind.training => TrainingSessionDetailScreen(sessionId: e.refId),
    EventKind.drill => DrillDetailScreen(drillId: e.refId),
    EventKind.maintenance => EquipmentDetailScreen(equipmentId: e.refId),
    EventKind.deadline => DossierDetailScreen(dossierId: e.refId),
    EventKind.acceptance => const AcceptanceHubScreen(),
    EventKind.selfCheck || EventKind.postInspection => const ReadinessScreen(),
  };
  return pushScreen(context, screen);
}

enum _ViewMode { day, week, month }

/// Tab "Lịch": lịch sự kiện và lịch trực tách riêng, xem theo ngày/tuần/tháng.
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lịch'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Lịch sự kiện'), Tab(text: 'Lịch trực')],
          ),
        ),
        body: const TabBarView(
          children: [
            _CalendarView(
              kinds: [
                EventKind.acceptance,
                EventKind.selfCheck,
                EventKind.postInspection,
                EventKind.training,
                EventKind.drill,
                EventKind.maintenance,
                EventKind.deadline,
              ],
            ),
            _CalendarView(kinds: [EventKind.shift]),
          ],
        ),
      ),
    );
  }
}

class _CalendarView extends StatefulWidget {
  const _CalendarView({required this.kinds});

  final List<EventKind> kinds;

  @override
  State<_CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<_CalendarView> {
  late Future<List<CalendarEvent>> _future;
  _ViewMode _mode = _ViewMode.month;
  DateTime _selected = dateOnly(DateTime.now());
  DateTime _month = DateTime.now();
  late Set<EventKind> _visibleKinds = widget.kinds.toSet();

  @override
  void initState() {
    super.initState();
    _future = Locator.calendar.getEvents();
  }

  void _reload() => setState(() => _future = Locator.calendar.getEvents());

  void _shift(int days) {
    setState(() {
      _selected = DateTime(_selected.year, _selected.month, _selected.day + days);
      _month = _selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBody<List<CalendarEvent>>(
      future: _future,
      builder: (context, all) {
        final events = all.where((e) => _visibleKinds.contains(e.kind)).toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
          children: [
            SegmentedButton<_ViewMode>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: _ViewMode.day, label: Text('Ngày')),
                ButtonSegment(value: _ViewMode.week, label: Text('Tuần')),
                ButtonSegment(value: _ViewMode.month, label: Text('Tháng')),
              ],
              selected: {_mode},
              onSelectionChanged: (v) => setState(() => _mode = v.first),
            ),
            if (widget.kinds.length > 1) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (final k in widget.kinds)
                    FilterChip(
                      avatar: Icon(k.icon, size: 16, color: k.color),
                      label: Text(k.label),
                      selected: _visibleKinds.contains(k),
                      onSelected: (v) => setState(() {
                        if (v) {
                          _visibleKinds.add(k);
                        } else {
                          _visibleKinds.remove(k);
                        }
                      }),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            ...switch (_mode) {
              _ViewMode.month => _monthView(events),
              _ViewMode.week => _weekView(events),
              _ViewMode.day => _dayView(events),
            },
          ],
        );
      },
    );
  }

  List<CalendarEvent> _on(List<CalendarEvent> events, DateTime day) =>
      events.where((e) => sameDay(e.date, day)).toList();

  List<Widget> _eventList(List<CalendarEvent> list) {
    if (list.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.all(8),
          child: Text('Không có lịch', style: TextStyle(color: AppColors.textSecondary)),
        ),
      ];
    }
    return [
      for (final e in list)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: EventTile(
            event: e,
            onTap: () async {
              await openEventTarget(context, e);
              _reload();
            },
          ),
        ),
    ];
  }

  List<Widget> _monthView(List<CalendarEvent> events) {
    final markers = <DateTime, List<Color>>{};
    for (final e in events) {
      markers.putIfAbsent(dateOnly(e.date), () => []).add(e.kind.color);
    }
    return [
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
      _DayHeader(date: _selected),
      ..._eventList(_on(events, _selected)),
    ];
  }

  List<Widget> _weekView(List<CalendarEvent> events) {
    final monday = DateTime(_selected.year, _selected.month, _selected.day - (_selected.weekday - 1));
    final days = List.generate(7, (i) => DateTime(monday.year, monday.month, monday.day + i));
    return [
      Row(
        children: [
          IconButton(onPressed: () => _shift(-7), icon: const Icon(Icons.chevron_left)),
          Expanded(
            child: Text(
              '${fmtDayMonth(days.first)} – ${fmtDate(days.last)}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(onPressed: () => _shift(7), icon: const Icon(Icons.chevron_right)),
        ],
      ),
      for (final d in days) ...[
        _DayHeader(date: d),
        ..._eventList(_on(events, d)),
      ],
    ];
  }

  List<Widget> _dayView(List<CalendarEvent> events) {
    return [
      Row(
        children: [
          IconButton(onPressed: () => _shift(-1), icon: const Icon(Icons.chevron_left)),
          Expanded(
            child: TextButton(
              onPressed: () => setState(() => _selected = dateOnly(DateTime.now())),
              child: Text(
                fmtFullDate(_selected),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
          IconButton(onPressed: () => _shift(1), icon: const Icon(Icons.chevron_right)),
        ],
      ),
      ..._eventList(_on(events, _selected)),
    ];
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final isToday = sameDay(date, DateTime.now());
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 6),
      child: Text(
        isToday ? 'Hôm nay · ${fmtFullDate(date)}' : fmtFullDate(date),
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: isToday ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// Một dòng sự kiện có thanh màu theo loại. Dùng ở Lịch và Trang chủ.
class EventTile extends StatelessWidget {
  const EventTile({super.key, required this.event, required this.onTap, this.showDate = false});

  final CalendarEvent event;
  final VoidCallback onTap;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final k = event.kind;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(border: Border(left: BorderSide(color: k.color, width: 4))),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(k.icon, color: k.color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (showDate) '${weekdayLabel(event.date)} ${fmtDayMonth(event.date)}',
                        k.label,
                        if (event.subtitle.isNotEmpty) event.subtitle,
                      ].join(' · '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.neutral),
            ],
          ),
        ),
      ),
    );
  }
}
