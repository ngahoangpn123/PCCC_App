import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// 4 nhóm thông báo theo tài liệu thiết kế.
enum NotifCategory {
  urgent('Khẩn cấp', AppColors.danger, Icons.warning_amber_rounded),
  upcoming('Sắp đến hạn', AppColors.warning, Icons.schedule),
  dossier('Hồ sơ & thủ tục', AppColors.info, Icons.description_outlined),
  schedule('Lịch & phân công', AppColors.gold, Icons.event_note_outlined);

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
enum NotifTarget { none, dossier, equipment, shift, training, drill, member }

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
  });

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
}
