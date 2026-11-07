import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum SessionStatus {
  planned('Sắp diễn ra', AppColors.info),
  done('Đã hoàn thành', AppColors.success),
  missed('Chưa thực hiện', AppColors.danger);

  const SessionStatus(this.label, this.color);
  final String label;
  final Color color;
}

const trainingFormats = ['Lý thuyết', 'Thực hành', 'Lý thuyết + thực hành'];
const attendanceResults = ['Đạt', 'Cần bổ sung', 'Không đạt'];

/// Loại buổi: tính giờ riêng theo Điều 22 NĐ 347/2026.
const sessionKinds = ['Huấn luyện nghiệp vụ', 'Bồi dưỡng nghiệp vụ'];

/// Kế hoạch huấn luyện (theo tháng / quý / năm). Một kế hoạch gồm nhiều buổi.
class TrainingPlan {
  TrainingPlan({
    required this.id,
    required this.title,
    required this.period,
    this.description = '',
  });

  final String id;
  String title;
  String period;
  String description;
}

/// Kết quả của một thành viên trong một buổi huấn luyện.
/// Lưu riêng từng người để truy xuất được lịch sử từng thành viên.
class Attendance {
  Attendance({
    required this.memberId,
    this.present = true,
    this.result = 'Đạt',
    this.note = '',
    this.theory,
    this.practice,
  });

  final String memberId;
  bool present;
  String result;
  String note;
  double? theory; // điểm lý thuyết
  double? practice; // điểm thực hành
}

class TrainingSession {
  TrainingSession({
    required this.id,
    required this.planId,
    required this.title,
    required this.date,
    required this.location,
    required this.instructor,
    required this.content,
    required this.format,
    required this.durationMinutes,
    this.status = SessionStatus.planned,
    this.kind = 'Huấn luyện nghiệp vụ',
    this.evaluation = '',
    List<Attendance>? attendance,
    List<String>? attachments,
  }) : attendance = attendance ?? [],
       attachments = attachments ?? [];

  final String id;
  String planId;
  String title;
  DateTime date; // gồm cả giờ bắt đầu
  String location;
  String instructor;
  String content;
  String format;
  int durationMinutes;
  SessionStatus status;
  String kind; // Huấn luyện / Bồi dưỡng nghiệp vụ
  String evaluation; // đánh giá chung của buổi
  final List<Attendance> attendance;
  final List<String> attachments;

  int get presentCount => attendance.where((a) => a.present).length;
}
