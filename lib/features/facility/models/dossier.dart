import 'package:flutter/material.dart';

import '../../../core/models/history_entry.dart';
import '../../../core/theme/app_colors.dart';

/// 6 trạng thái hồ sơ theo bản đặc tả (áp dụng từ 15/9/2026).
enum DossierStatus {
  notCreated('Chưa lập', AppColors.neutral),
  draft('Bản nháp', AppColors.info),
  signed('Đã ký nội bộ', AppColors.warning),
  submitted('Đã nộp, chờ phản hồi', AppColors.info),
  completed('Đã hoàn thành & khai báo CSDL', AppColors.success),
  needUpdate('Yêu cầu bổ sung / Cần cập nhật', AppColors.danger);

  const DossierStatus(this.label, this.color);
  final String label;
  final Color color;

  /// Hồ sơ còn việc phải làm (dùng để đếm trên trang chủ).
  bool get needsAction => this != submitted && this != completed;
}

/// Thời hạn lưu trữ (khoản 2 Điều 11 NĐ 347/2026).
const retentionOptions = ['05 năm', '10 năm', 'Vĩnh viễn'];

class Dossier {
  Dossier({
    required this.id,
    required this.formCode,
    required this.title,
    required this.owner,
    required this.status,
    required this.updatedAt,
    this.dueDate,
    this.note = '',
    this.retention = '05 năm',
    List<String>? attachments,
    List<HistoryEntry>? history,
  }) : attachments = attachments ?? [],
       history = history ?? [];

  final String id;
  String formCode;
  String title;
  String owner; // người phụ trách
  DossierStatus status;
  DateTime updatedAt;
  DateTime? dueDate;
  String note;
  String retention; // thời hạn lưu trữ tối thiểu
  final List<String> attachments;
  final List<HistoryEntry> history;
}
