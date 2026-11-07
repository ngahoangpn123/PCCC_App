import '../../../core/mock/mock_database.dart';
import '../models/member.dart';
import '../models/shift.dart';

abstract class TeamRepository {
  Future<List<Member>> getMembers();
  Future<Member> getMember(String id);
  Future<void> saveMember(Member member);

  Future<List<Shift>> getShifts();
  Future<Shift> getShift(String id);
  Future<void> saveShift(Shift shift);
}

class MockTeamRepository implements TeamRepository {
  final _db = MockDatabase.instance;

  @override
  Future<List<Member>> getMembers() => mockDelay(_db.members.toList());

  @override
  Future<Member> getMember(String id) =>
      mockDelay(_db.members.firstWhere((m) => m.id == id));

  @override
  Future<void> saveMember(Member member) async {
    if (!_db.members.contains(member)) _db.members.add(member);
    await mockDelay(null);
  }

  @override
  Future<List<Shift>> getShifts() {
    final list = _db.shifts.toList()
      ..sort((a, b) {
        final byDate = a.date.compareTo(b.date);
        return byDate != 0 ? byDate : a.start.compareTo(b.start);
      });
    return mockDelay(list);
  }

  @override
  Future<Shift> getShift(String id) =>
      mockDelay(_db.shifts.firstWhere((s) => s.id == id));

  @override
  Future<void> saveShift(Shift shift) async {
    if (!_db.shifts.contains(shift)) _db.shifts.add(shift);
    await mockDelay(null);
  }
}

class SupabaseTeamRepository implements TeamRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Chưa nối Supabase');
}
