import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum ShiftStatus {
  planned('Dự kiến', AppColors.neutral),
  confirmed('Đã xác nhận', AppColors.info),
  onDuty('Đang trực', AppColors.warning),
  done('Đã hoàn thành', AppColors.success);

  const ShiftStatus(this.label, this.color);
  final String label;
  final Color color;
}

/// Một ca trực.
class Shift {
  Shift({
    required this.id,
    required this.date,
    required this.start,
    required this.end,
    required this.location,
    required this.leaderId,
    required this.memberIds,
    required this.requiredCount,
    List<String>? confirmedIds,
    this.status = ShiftStatus.planned,
    this.absentNote = '',
    this.handoverNote = '',
  }) : confirmedIds = confirmedIds ?? [];

  final String id;
  DateTime date;
  String start; // "07:00"
  String end; // "19:00"
  String location;
  String leaderId; // người phụ trách ca
  List<String> memberIds; // thành viên được phân công
  int requiredCount; // quân số cần có (cấu hình theo cơ sở)
  List<String> confirmedIds; // thành viên đã xác nhận
  ShiftStatus status;
  String absentNote; // vắng mặt, người thay thế
  String handoverNote; // ghi chú bàn giao ca

  String get timeRange => '$start – $end';
  bool get understaffed => memberIds.length < requiredCount;
  List<String> get unconfirmedIds =>
      memberIds.where((id) => !confirmedIds.contains(id)).toList();
}
