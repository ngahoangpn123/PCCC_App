import 'package:flutter/material.dart';

import '../../../core/models/history_entry.dart';
import '../../../core/theme/app_colors.dart';

/// Các trạng thái của một hồ sơ (theo tài liệu thiết kế).
enum DossierStatus {
  notCreated('Chưa lập', AppColors.neutral),
  draft('Bản nháp', AppColors.info),
  waitingSign('Chờ ký', AppColors.warning),
  waitingSubmit('Chờ nộp', AppColors.warning),
  submitted('Đã nộp', AppColors.info),
  needSupplement('Yêu cầu bổ sung', AppColors.danger),
  approved('Đã tiếp nhận', AppColors.success),
  expired('Cần cập nhật', AppColors.danger);

  const DossierStatus(this.label, this.color);
  final String label;
  final Color color;

  /// Hồ sơ còn việc phải làm (dùng để đếm trên trang chủ).
  bool get needsAction => this != submitted && this != approved;
}

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
  final List<String> attachments;
  final List<HistoryEntry> history;
}
