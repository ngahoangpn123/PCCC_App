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
}

/// Danh sách loại hình cơ sở để chọn trong form.
/// TODO: đối chiếu lại với phụ lục của Nghị định đang áp dụng.
const facilityTypes = [
  'Trung tâm thương mại, chợ, siêu thị',
  'Nhà chung cư, nhà tập thể',
  'Cơ sở giáo dục',
  'Cơ sở y tế',
  'Khách sạn, nhà nghỉ',
  'Văn phòng, trụ sở làm việc',
  'Nhà xưởng, cơ sở sản xuất',
  'Kho hàng hóa, vật tư',
  'Khác',
];
