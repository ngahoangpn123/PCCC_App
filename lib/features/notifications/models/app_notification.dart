import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// 4 nhóm thông báo theo bản đặc tả (mục Thông báo & cảnh báo).
enum NotifCategory {
  urgent('Khẩn cấp / cần xử lý ngay', AppColors.danger, Icons.warning_amber_rounded),
  upcoming('Nhiệm vụ sắp đến hạn / quá hạn', AppColors.warning, Icons.schedule),
  dossier('Hồ sơ & tài liệu', AppColors.info, Icons.description_outlined),
  schedule('Lịch hoạt động', AppColors.gold, Icons.event_note_outlined);

  const NotifCategory(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;
}

enum NotifPriority {
  high('Ưu tiên cao', AppColors.danger),
  medium('Trung bình', AppColors.warning),
  low('Thấp', AppColors.neutral);

  const NotifPriority(this.label, this.color);
  final String label;
  final Color color;
}

/// Thông báo trỏ tới đối tượng nào (để mở đúng màn hình).
enum NotifTarget { none, dossier, equipment, shift, training, drill, member, acceptance }

class AppNotification {
  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.priority,
    required this.createdAt,
    this.target = NotifTarget.none,
    this.targetId = '',
    this.read = false,
    this.resolved = false,
    this.objectLabel = '',
    this.dueDate,
    this.assignee = '',
    this.suggestedAction = '',
    this.resultNote = '',
    List<String>? evidence,
  }) : evidence = evidence ?? [];

  final String id;
  final String title;
  final String body;
  final NotifCategory category;
  final NotifPriority priority;
  final DateTime createdAt;
  final NotifTarget target;
  final String targetId;
  bool read; // đã đọc
  bool resolved; // đã xử lý (khác với đã đọc)

  // Thông tin hiển thị trên thẻ (Hình 7 của bản đặc tả)
  final String objectLabel; // đối tượng liên quan
  final DateTime? dueDate; // thời hạn xử lý
  final String assignee; // người chịu trách nhiệm
  final String suggestedAction; // hành động đề xuất

  // Khi đánh dấu "đã xử lý" phải có kết quả + minh chứng
  String resultNote;
  final List<String> evidence;
}
