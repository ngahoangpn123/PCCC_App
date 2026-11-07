import '../../../core/mock/mock_database.dart';
import '../models/equipment.dart';

abstract class EquipmentRepository {
  Future<List<Equipment>> getEquipment();
  Future<Equipment> getById(String id);
  Future<void> save(Equipment item);

  /// Ghi nhận một lần kiểm tra: thêm vào lịch sử, cập nhật tình trạng và hạn kế tiếp.
  Future<void> addInspection(
    Equipment item,
    InspectionRecord record,
    DateTime nextCheck,
  );
}

class MockEquipmentRepository implements EquipmentRepository {
  final _db = MockDatabase.instance;

  @override
  Future<List<Equipment>> getEquipment() {
    final list = _db.equipment.toList()
      ..sort((a, b) => a.nextCheck.compareTo(b.nextCheck));
    return mockDelay(list);
  }

  @override
  Future<Equipment> getById(String id) =>
      mockDelay(_db.equipment.firstWhere((e) => e.id == id));

  @override
  Future<void> save(Equipment item) async {
    if (!_db.equipment.contains(item)) _db.equipment.add(item);
    await mockDelay(null);
  }

  @override
  Future<void> addInspection(
    Equipment item,
    InspectionRecord record,
    DateTime nextCheck,
  ) async {
    item.records.add(record);
    item.status = record.result;
    item.nextCheck = nextCheck;
    await mockDelay(null);
  }
}

class SupabaseEquipmentRepository implements EquipmentRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Chưa nối Supabase');
}
