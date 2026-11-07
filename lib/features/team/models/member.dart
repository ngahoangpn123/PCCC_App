import 'package:flutter/material.dart';

import '../../../core/models/history_entry.dart';
import '../../../core/theme/app_colors.dart';

enum MemberStatus {
  active('Đang tham gia', AppColors.success),
  away('Tạm vắng', AppColors.warning),
  reassigned('Thay đổi nhiệm vụ', AppColors.info),
  left('Đã thôi tham gia', AppColors.neutral);

  const MemberStatus(this.label, this.color);
  final String label;
  final Color color;
}

const memberRoles = ['Đội trưởng', 'Đội phó', 'Đội viên', 'Lái xe chữa cháy'];

/// Thành viên đội PCCC & CNCH cơ sở.
class Member {
  Member({
    required this.id,
    required this.code,
    required this.name,
    required this.phone,
    required this.role,
    required this.duty,
    this.status = MemberStatus.active,
    this.trainingOk = true,
    this.trainingNote = 'Đạt yêu cầu huấn luyện',
    List<HistoryEntry>? history,
  }) : history = history ?? [];

  final String id;
  String code;
  String name;
  String phone;
  String role; // chức vụ trong đội
  String duty; // nhiệm vụ được phân công
  MemberStatus status;
  bool trainingOk; // đã đáp ứng yêu cầu huấn luyện chưa
  String trainingNote;
  final List<HistoryEntry> history;
}
