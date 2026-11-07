import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// 5 bước trong vòng đời một đợt diễn tập.
enum DrillStage {
  plan('Lập kế hoạch', 'Xác định mục tiêu, thời gian, địa điểm, lực lượng và phương tiện.'),
  prepare('Chuẩn bị', 'Phân công nhiệm vụ, xác nhận nhân sự, rà soát phương tiện và tài liệu.'),
  execute('Tổ chức thực hiện', 'Ghi nhận thời gian thực tế, thành phần tham gia và diễn biến.'),
  evaluate('Đánh giá', 'Ghi nhận kết quả, nhận xét, vấn đề phát hiện và minh chứng.'),
  remediate('Khắc phục & theo dõi', 'Giao nhiệm vụ khắc phục, đặt thời hạn và xác nhận hoàn thành.');

  const DrillStage(this.label, this.description);
  final String label;
  final String description;

  Color get color => switch (this) {
    DrillStage.plan => AppColors.neutral,
    DrillStage.prepare => AppColors.info,
    DrillStage.execute => AppColors.warning,
    DrillStage.evaluate => AppColors.gold,
    DrillStage.remediate => AppColors.success,
  };
}

const scenarioTypes = ['Chữa cháy', 'Cứu nạn, cứu hộ', 'Thoát nạn', 'Tổng hợp'];

/// Phương án: tài liệu / kịch bản. Có thể tổ chức diễn tập nhiều lần.
class Scenario {
  Scenario({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    required this.objective,
    required this.scope,
    required this.location,
    required this.commander,
    List<String>? forces,
    List<String>? equipment,
    List<String>? steps,
  }) : forces = forces ?? [],
       equipment = equipment ?? [],
       steps = steps ?? [];

  final String id;
  String code;
  String name;
  String type;
  String objective;
  String scope;
  String location;
  String commander;
  List<String> forces; // lực lượng tham gia và vai trò
  List<String> equipment; // phương tiện huy động
  List<String> steps; // các bước thực hiện
}

/// Nhiệm vụ khắc phục sau diễn tập.
class FixTask {
  FixTask({
    required this.title,
    required this.assignee,
    required this.due,
    this.done = false,
  });

  String title;
  String assignee;
  DateTime due;
  bool done;
}

/// Một lần tổ chức thực tập / diễn tập cụ thể của một phương án.
class Drill {
  Drill({
    required this.id,
    required this.scenarioId,
    required this.title,
    required this.date,
    this.stage = DrillStage.plan,
    this.participants = '',
    this.result = '',
    this.issues = '',
    List<FixTask>? fixes,
    List<String>? attachments,
  }) : fixes = fixes ?? [],
       attachments = attachments ?? [];

  final String id;
  String scenarioId;
  String title;
  DateTime date;
  DrillStage stage;
  String participants;
  String result; // kết quả, nhận xét
  String issues; // vấn đề phát hiện
  final List<FixTask> fixes;
  final List<String> attachments;
}
