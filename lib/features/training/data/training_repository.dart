import '../../../core/mock/mock_database.dart';
import '../models/training.dart';

abstract class TrainingRepository {
  Future<List<TrainingPlan>> getPlans();
  Future<TrainingPlan> getPlan(String id);
  Future<void> savePlan(TrainingPlan plan);

  /// Lấy các buổi huấn luyện; truyền [planId] để lọc theo kế hoạch.
  Future<List<TrainingSession>> getSessions({String? planId});
  Future<TrainingSession> getSession(String id);
  Future<void> saveSession(TrainingSession session);
}

class MockTrainingRepository implements TrainingRepository {
  final _db = MockDatabase.instance;

  @override
  Future<List<TrainingPlan>> getPlans() => mockDelay(_db.trainingPlans.toList());

  @override
  Future<TrainingPlan> getPlan(String id) =>
      mockDelay(_db.trainingPlans.firstWhere((p) => p.id == id));

  @override
  Future<void> savePlan(TrainingPlan plan) async {
    if (!_db.trainingPlans.contains(plan)) _db.trainingPlans.add(plan);
    await mockDelay(null);
  }

  @override
  Future<List<TrainingSession>> getSessions({String? planId}) {
    final list = _db.trainingSessions
        .where((s) => planId == null || s.planId == planId)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return mockDelay(list);
  }

  @override
  Future<TrainingSession> getSession(String id) =>
      mockDelay(_db.trainingSessions.firstWhere((s) => s.id == id));

  @override
  Future<void> saveSession(TrainingSession session) async {
    if (!_db.trainingSessions.contains(session)) {
      _db.trainingSessions.add(session);
    }
    await mockDelay(null);
  }
}

class SupabaseTrainingRepository implements TrainingRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Chưa nối Supabase');
}
