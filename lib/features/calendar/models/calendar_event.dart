import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum EventKind {
  shift('Ca trực', AppColors.primary, Icons.shield_outlined),
  training('Huấn luyện', AppColors.info, Icons.school_outlined),
  drill('Diễn tập', AppColors.gold, Icons.local_fire_department_outlined),
  maintenance('Kiểm tra, bảo dưỡng', AppColors.success, Icons.build_outlined),
  deadline('Hạn hồ sơ', AppColors.danger, Icons.assignment_late_outlined),
  acceptance('Chạy thử, tự nghiệm thu', Color(0xFF6A3FA0), Icons.fact_check_outlined),
  selfCheck('Tự kiểm tra định kỳ PC02', Color(0xFF00897B), Icons.checklist),
  postInspection('Tiếp đoàn hậu kiểm', Color(0xFF2F6DB5), Icons.verified_user_outlined);

  const EventKind(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;
}

/// Một mục hiển thị trên lịch. Được tổng hợp từ ca trực, huấn luyện,
/// diễn tập, lịch kiểm tra thiết bị và hạn hồ sơ.
class CalendarEvent {
  const CalendarEvent({
    required this.date,
    required this.title,
    required this.kind,
    this.subtitle = '',
    this.refId = '',
  });

  final DateTime date;
  final String title;
  final EventKind kind;
  final String subtitle;
  final String refId; // id của ca trực / buổi huấn luyện... để mở chi tiết
}
