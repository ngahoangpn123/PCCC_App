import '../../../core/mock/mock_database.dart';
import '../../equipment/models/equipment.dart';
import '../../facility/models/facility.dart';
import '../models/acceptance.dart';

abstract class AcceptanceRepository {
  /// Hồ sơ tự nghiệm thu của cơ sở đang chọn (null nếu chưa khởi tạo).
  Future<ProjectAcceptance?> getAcceptance();
  Future<ProjectAcceptance> startAcceptance(String projectName);
  Future<void> saveAcceptance(ProjectAcceptance a);

  Future<List<ReadinessItem>> getReadinessItems();
  Future<void> saveReadinessItems(List<ReadinessItem> items);
  Future<ReadinessSummary> getReadinessSummary();
  Future<PostInspection> getPostInspection();
  Future<void> savePostInspection(PostInspection p);

  Future<Pc01Declaration> getPc01();
  Future<void> savePc01(Pc01Declaration d);

  /// Kiểm tra tính hợp lệ trước khi nộp PC01. Trả về danh sách lỗi (rỗng = hợp lệ).
  Future<List<String>> validatePc01();

  /// Số liệu tự điền vào PC01: thiết bị theo nhóm HT và quân số đội.
  Future<Pc01AutoData> getPc01AutoData();
}

/// Dữ liệu tự động lấy từ các module khác để điền PC01.
class Pc01AutoData {
  const Pc01AutoData({
    required this.facility,
    required this.equipmentByHt,
    required this.teamCount,
    required this.suggestedLevel,
  });

  final Facility facility;
  final Map<String, int> equipmentByHt; // HT → tổng số lượng
  final int teamCount; // số thành viên đội đang tham gia
  final String suggestedLevel; // phân cấp quản lý gợi ý
}

class MockAcceptanceRepository implements AcceptanceRepository {
  final _db = MockDatabase.instance;

  Facility get _facility => _db.currentFacility;

  @override
  Future<ProjectAcceptance?> getAcceptance() =>
      mockDelay(_db.acceptances.where((a) => a.facilityId == _facility.id).firstOrNull);

  @override
  Future<ProjectAcceptance> startAcceptance(String projectName) async {
    final a = MockDatabase.newAcceptance('acc${_db.acceptances.length + 1}', _facility.id, projectName);
    _db.acceptances.removeWhere((x) => x.facilityId == _facility.id);
    _db.acceptances.add(a);
    _facility.hasConstruction = true;
    return mockDelay(a);
  }

  @override
  Future<void> saveAcceptance(ProjectAcceptance a) async {
    if (!_db.acceptances.contains(a)) _db.acceptances.add(a);
    await mockDelay(null);
  }

  @override
  Future<List<ReadinessItem>> getReadinessItems() => mockDelay(_db.readinessItems.toList());

  @override
  Future<void> saveReadinessItems(List<ReadinessItem> items) => mockDelay(null);

  @override
  Future<ReadinessSummary> getReadinessSummary() async {
    final acc = _db.acceptances.where((a) => a.facilityId == _facility.id).firstOrNull;
    final byHt = <String, List<Equipment>>{};
    for (final e in _db.equipment) {
      byHt.putIfAbsent(e.htGroup, () => []).add(e);
    }
    final htReady = byHt.values
        .where((list) => list.every((e) => e.status == EquipmentStatus.ok))
        .length;
    return mockDelay(ReadinessSummary(
      asBuiltDone: acc?.asBuiltDone ?? 0,
      asBuiltTotal: asBuiltPartNames.length,
      groupsDone: _db.readinessItems.where((i) => i.done).length,
      groupsTotal: _db.readinessItems.length,
      htReady: htReady,
      htTotal: byHt.length,
      inspection: _db.postInspection,
    ));
  }

  @override
  Future<PostInspection> getPostInspection() => mockDelay(_db.postInspection);

  @override
  Future<void> savePostInspection(PostInspection p) => mockDelay(null);

  @override
  Future<Pc01Declaration> getPc01() => mockDelay(_db.pc01For(_facility.id));

  @override
  Future<void> savePc01(Pc01Declaration d) => mockDelay(null);

  @override
  Future<List<String>> validatePc01() async {
    final f = _facility;
    final errors = <String>[];
    if (!f.hasCoordinates) {
      errors.add('Tọa độ (vĩ độ, kinh độ) đang bằng 0 – cần cập nhật vị trí cơ sở.');
    }
    if (f.staffCount <= 0) errors.add('Chưa nhập số người thường xuyên làm việc.');
    if (f.hazard.trim().isEmpty) errors.add('Chưa mô tả đặc điểm nguy hiểm cháy, nổ.');
    if (f.headName.trim().isEmpty) errors.add('Thiếu thông tin người đứng đầu cơ sở.');
    if (f.hasConstruction) {
      final acc = _db.acceptances.where((a) => a.facilityId == f.id).firstOrNull;
      if (acc == null || !acc.pc18Signed) {
        errors.add('Cơ sở có hạng mục thi công nhưng chưa có Văn bản PC18 đã ký số.');
      }
    }
    if (_db.members.isEmpty) errors.add('Chưa có danh sách đội PCCC & CNCH cơ sở.');
    return mockDelay(errors);
  }

  @override
  Future<Pc01AutoData> getPc01AutoData() async {
    final byHt = <String, int>{};
    for (final e in _db.equipment) {
      byHt[e.htGroup] = (byHt[e.htGroup] ?? 0) + e.quantity;
    }
    final sorted = Map.fromEntries(byHt.entries.toList()
      ..sort((a, b) => int.parse(a.key.substring(2)).compareTo(int.parse(b.key.substring(2)))));
    return mockDelay(Pc01AutoData(
      facility: _facility,
      equipmentByHt: sorted,
      teamCount: _db.members.where((m) => m.status.name != 'left').length,
      suggestedLevel: suggestManagementLevel(_facility),
    ));
  }
}

/// Gợi ý phân cấp quản lý.
/// TODO: thay bằng tiêu chí chính thức (phụ lục Nghị định) – hiện dùng ngưỡng tạm.
String suggestManagementLevel(Facility f) {
  const policeTypes = [
    'Trung tâm thương mại, chợ, siêu thị',
    'Nhà chung cư, nhà tập thể',
    'Nhà hỗn hợp, văn phòng',
    'Cơ sở y tế',
    'Khách sạn, nhà nghỉ',
    'Nhà xưởng, cơ sở sản xuất',
    'Kho hàng hóa, vật tư',
  ];
  if (f.staffCount >= 50 || policeTypes.contains(f.type)) return 'Cơ quan Công an';
  return 'UBND cấp xã';
}

class SupabaseAcceptanceRepository implements AcceptanceRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Chưa nối Supabase');
}
