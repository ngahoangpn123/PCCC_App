import '../../../core/mock/mock_database.dart';
import '../../acceptance/models/acceptance.dart';
import '../../facility/models/dossier.dart';
import '../../training/models/training.dart';
import '../models/calendar_event.dart';

abstract class CalendarRepository {
  /// Tổng hợp mọi sự kiện có ngày: ca trực, huấn luyện, diễn tập,
  /// lịch kiểm tra thiết bị và hạn hồ sơ.
  Future<List<CalendarEvent>> getEvents();
}

class MockCalendarRepository implements CalendarRepository {
  final _db = MockDatabase.instance;

  @override
  Future<List<CalendarEvent>> getEvents() {
    final now = DateTime.now();
    final events = <CalendarEvent>[
      for (final s in _db.shifts)
        CalendarEvent(
          date: s.date,
          title: 'Ca trực ${s.timeRange}',
          subtitle: '${s.location} · ${s.memberIds.length}/${s.requiredCount} người',
          kind: EventKind.shift,
          refId: s.id,
        ),
      for (final t in _db.trainingSessions)
        if (t.status != SessionStatus.missed)
          CalendarEvent(
            date: t.date,
            title: t.title,
            subtitle: t.location,
            kind: EventKind.training,
            refId: t.id,
          ),
      for (final d in _db.drills)
        CalendarEvent(
          date: d.date,
          title: d.title,
          subtitle: d.stage.label,
          kind: EventKind.drill,
          refId: d.id,
        ),
      for (final e in _db.equipment)
        CalendarEvent(
          date: e.nextCheck,
          title: 'Kiểm tra: ${e.name}',
          subtitle: e.location,
          kind: EventKind.maintenance,
          refId: e.id,
        ),
      for (final d in _db.dossiers)
        if (d.dueDate != null && d.status != DossierStatus.completed)
          CalendarEvent(
            date: d.dueDate!,
            title: 'Hạn hồ sơ ${d.formCode}',
            subtitle: d.title,
            kind: EventKind.deadline,
            refId: d.id,
          ),
      // Tự nghiệm thu: bước đang thực hiện của công trình
      for (final a in _db.acceptances)
        for (final st in a.steps)
          if (st.status == StepStatus.inProgress)
            CalendarEvent(
              date: DateTime(now.year, now.month, now.day + 3, 8),
              title: 'Bước ${st.no}: ${st.title}',
              subtitle: a.projectName,
              kind: EventKind.acceptance,
              refId: a.id,
            ),
      if (_db.postInspection.nextSelfCheck != null)
        CalendarEvent(
          date: _db.postInspection.nextSelfCheck!,
          title: 'Tự kiểm tra định kỳ (PC02)',
          subtitle: 'Lập biên bản tự kiểm tra hằng tháng',
          kind: EventKind.selfCheck,
          refId: 'readiness',
        ),
      if (_db.postInspection.nextInspection != null)
        CalendarEvent(
          date: _db.postInspection.nextInspection!,
          title: 'Tiếp đoàn hậu kiểm',
          subtitle: _db.postInspection.agency,
          kind: EventKind.postInspection,
          refId: 'readiness',
        ),
    ]..sort((a, b) => a.date.compareTo(b.date));
    return mockDelay(events);
  }
}

class SupabaseCalendarRepository implements CalendarRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Chưa nối Supabase');
}
