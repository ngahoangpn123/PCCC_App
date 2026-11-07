import '../../../core/mock/mock_database.dart';
import '../models/dossier.dart';
import '../models/facility.dart';
import '../models/form_template.dart';

/// "Hợp đồng" giữa giao diện và nguồn dữ liệu.
/// Giao diện chỉ gọi các hàm này, không cần biết dữ liệu nằm ở đâu.
abstract class FacilityRepository {
  Future<List<Facility>> getFacilities();
  Future<Facility> getFacility(String id);
  Future<void> saveFacility(Facility facility);

  Future<List<FormTemplate>> getFormTemplates();

  Future<List<Dossier>> getDossiers();
  Future<Dossier> getDossier(String id);
  Future<void> saveDossier(Dossier dossier);
}

/// Bản dùng dữ liệu mẫu trong bộ nhớ.
class MockFacilityRepository implements FacilityRepository {
  final _db = MockDatabase.instance;

  @override
  Future<List<Facility>> getFacilities() => mockDelay(_db.facilities.toList());

  @override
  Future<Facility> getFacility(String id) =>
      mockDelay(_db.facilities.firstWhere((f) => f.id == id));

  @override
  Future<void> saveFacility(Facility facility) async {
    if (!_db.facilities.contains(facility)) _db.facilities.add(facility);
    await mockDelay(null);
  }

  @override
  Future<List<FormTemplate>> getFormTemplates() =>
      mockDelay(_db.formTemplates.toList());

  @override
  Future<List<Dossier>> getDossiers() => mockDelay(_db.dossiers.toList());

  @override
  Future<Dossier> getDossier(String id) =>
      mockDelay(_db.dossiers.firstWhere((d) => d.id == id));

  @override
  Future<void> saveDossier(Dossier dossier) async {
    if (!_db.dossiers.contains(dossier)) _db.dossiers.add(dossier);
    await mockDelay(null);
  }
}

/// TODO (bước nối database): viết các hàm đọc/ghi bảng Supabase ở đây,
/// rồi đổi trong lib/core/di/locator.dart sang dùng lớp này.
class SupabaseFacilityRepository implements FacilityRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Chưa nối Supabase');
}
