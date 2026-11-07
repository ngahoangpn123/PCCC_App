import '../../../core/mock/mock_database.dart';
import '../models/drill.dart';

abstract class DrillRepository {
  Future<List<Scenario>> getScenarios();
  Future<Scenario> getScenario(String id);
  Future<void> saveScenario(Scenario scenario);

  /// Lấy các đợt diễn tập; truyền [scenarioId] để lọc theo phương án.
  Future<List<Drill>> getDrills({String? scenarioId});
  Future<Drill> getDrill(String id);
  Future<void> saveDrill(Drill drill);
}

class MockDrillRepository implements DrillRepository {
  final _db = MockDatabase.instance;

  @override
  Future<List<Scenario>> getScenarios() => mockDelay(_db.scenarios.toList());

  @override
  Future<Scenario> getScenario(String id) =>
      mockDelay(_db.scenarios.firstWhere((s) => s.id == id));

  @override
  Future<void> saveScenario(Scenario scenario) async {
    if (!_db.scenarios.contains(scenario)) _db.scenarios.add(scenario);
    await mockDelay(null);
  }

  @override
  Future<List<Drill>> getDrills({String? scenarioId}) {
    final list = _db.drills
        .where((d) => scenarioId == null || d.scenarioId == scenarioId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return mockDelay(list);
  }

  @override
  Future<Drill> getDrill(String id) =>
      mockDelay(_db.drills.firstWhere((d) => d.id == id));

  @override
  Future<void> saveDrill(Drill drill) async {
    if (!_db.drills.contains(drill)) _db.drills.add(drill);
    await mockDelay(null);
  }
}

class SupabaseDrillRepository implements DrillRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Chưa nối Supabase');
}
