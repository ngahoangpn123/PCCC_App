/// Thông tin một cơ sở do người dùng quản lý.
class Facility {
  Facility({
    required this.id,
    required this.code,
    required this.name,
    required this.address,
    required this.type,
    required this.field,
    required this.scale,
    required this.buildingInfo,
    required this.headName,
    required this.headPhone,
    required this.officerName,
    required this.officerPhone,
    required this.email,
    this.staffCount = 0,
    this.lat = 0,
    this.lng = 0,
    this.hazard = '',
    this.managementLevel = 'Cơ quan Công an',
    this.hasConstruction = false,
  });

  final String id;
  String code;
  String name;
  String address;
  String type; // loại hình cơ sở
  String field; // lĩnh vực hoạt động
  String scale; // quy mô
  String buildingInfo; // đặc điểm công trình
  String headName; // người đứng đầu
  String headPhone;
  String officerName; // người phụ trách PCCC & CNCH
  String officerPhone;
  String email;
  int staffCount; // số người thường xuyên làm việc (quyết định mô hình đội)
  double lat; // vĩ độ
  double lng; // kinh độ
  String hazard; // đặc điểm nguy hiểm cháy nổ
  String managementLevel; // phân cấp quản lý: Cơ quan Công an / UBND cấp xã
  bool hasConstruction; // đang thi công mới, cải tạo, thay đổi công năng

  bool get hasCoordinates => lat != 0 && lng != 0;
}

/// Danh sách loại hình cơ sở để chọn trong form.
/// TODO: đối chiếu lại với phụ lục của Nghị định đang áp dụng.
const facilityTypes = [
  'Trung tâm thương mại, chợ, siêu thị',
  'Nhà chung cư, nhà tập thể',
  'Nhà hỗn hợp, văn phòng',
  'Cơ sở giáo dục',
  'Cơ sở y tế',
  'Khách sạn, nhà nghỉ',
  'Nhà xưởng, cơ sở sản xuất',
  'Kho hàng hóa, vật tư',
  'Khác',
];

const managementLevels = ['Cơ quan Công an', 'UBND cấp xã'];
