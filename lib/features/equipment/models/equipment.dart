import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum EquipmentStatus {
  ok('Hoạt động', AppColors.success),
  needCheck('Cần kiểm tra', AppColors.warning),
  needRepair('Cần sửa chữa', AppColors.danger),
  outOfService('Ngừng sử dụng', AppColors.neutral);

  const EquipmentStatus(this.label, this.color);
  final String label;
  final Color color;
}

const equipmentTypes = [
  'Bình chữa cháy',
  'Hệ thống chữa cháy',
  'Máy bơm',
  'Hệ thống báo cháy',
  'Chiếu sáng & thoát nạn',
  'Dụng cụ cứu nạn',
  'Khác',
];

IconData equipmentIcon(String type) {
  switch (type) {
    case 'Bình chữa cháy':
      return Icons.fire_extinguisher;
    case 'Hệ thống chữa cháy':
      return Icons.water_drop_outlined;
    case 'Máy bơm':
      return Icons.settings_outlined;
    case 'Hệ thống báo cháy':
      return Icons.sensors;
    case 'Chiếu sáng & thoát nạn':
      return Icons.emergency_outlined;
    case 'Dụng cụ cứu nạn':
      return Icons.medical_services_outlined;
    default:
      return Icons.inventory_2_outlined;
  }
}

/// Một lần kiểm tra / bảo dưỡng / sửa chữa.
class InspectionRecord {
  InspectionRecord({
    required this.date,
    required this.kind,
    required this.by,
    required this.result,
    this.note = '',
    this.confirmed = false,
    List<String>? photos,
  }) : photos = photos ?? [];

  final DateTime date;
  final String kind; // Kiểm tra / Bảo dưỡng / Sửa chữa
  final String by; // người thực hiện
  final EquipmentStatus result;
  final String note;
  bool confirmed; // người có thẩm quyền đã xác nhận chưa
  final List<String> photos;
}

class Equipment {
  Equipment({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    this.maker = '',
    this.model = '',
    this.serial = '',
    required this.quantity,
    required this.unit,
    required this.location,
    required this.inUseSince,
    required this.status,
    required this.nextCheck,
    required this.keeper,
    List<InspectionRecord>? records,
  }) : records = records ?? [];

  final String id;
  String code; // mã định danh / mã tài sản
  String name;
  String type;
  String maker;
  String model;
  String serial;
  int quantity;
  String unit;
  String location; // tòa nhà, tầng, phòng, khu vực
  DateTime inUseSince;
  EquipmentStatus status;
  DateTime nextCheck;
  String keeper; // người phụ trách
  final List<InspectionRecord> records;
}
