import 'package:flutter/material.dart';

import '../../../core/legal/legal_catalog.dart';
import '../../../core/theme/app_colors.dart';

/// Trạng thái từng bước trong quy trình 6 bước tự nghiệm thu.
enum StepStatus {
  notStarted('Chưa bắt đầu', AppColors.neutral, Icons.radio_button_unchecked),
  inProgress('Đang thực hiện', AppColors.info, Icons.timelapse),
  failed('Có hạng mục không đạt', AppColors.danger, Icons.error_outline),
  done('Hoàn thành', AppColors.success, Icons.check_circle);

  const StepStatus(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;
}

/// Kết quả từng hạng mục trong checklist 21 hạng mục nghiệm thu.
enum CheckResult {
  pending('Chưa kiểm', AppColors.neutral),
  pass('Đạt', AppColors.success),
  fail('Không đạt', AppColors.danger),
  na('Không áp dụng', AppColors.info);

  const CheckResult(this.label, this.color);
  final String label;
  final Color color;
}

/// Một bước của quy trình (Bước 1 → Bước 6).
class AcceptanceStep {
  AcceptanceStep({
    required this.no,
    required this.title,
    required this.content,
    required this.evidence,
    required this.outputs,
    this.status = StepStatus.notStarted,
    this.note = '',
    this.completedAt,
    List<String>? attachments,
  }) : attachments = attachments ?? [];

  final int no;
  final String title;
  final String content; // nội dung công việc
  final List<String> evidence; // minh chứng cần thu thập
  final List<String> outputs; // kết quả đầu ra / văn bản
  StepStatus status;
  String note;
  DateTime? completedAt;
  final List<String> attachments; // ảnh Geotag, video, biên bản...

  /// Bước 3 – 4 có checklist và đo thông số kỹ thuật.
  bool get hasChecklist => no == 3 || no == 4;

  /// Bước 4 cần đủ chữ ký các bên.
  bool get needsSignatures => no == 4;
}

/// Một lần đo thông số kỹ thuật (tự so với ngưỡng, sai thì báo đỏ).
class Measurement {
  Measurement({required this.spec, this.value});

  final MeasureSpec spec;
  double? value;

  bool? get passed => value == null ? null : spec.passes(value!);
}

/// Chữ ký của một bên tham gia nghiệm thu.
class SignOff {
  SignOff({required this.role, this.name = '', this.signedAt});

  final String role;
  String name;
  DateTime? signedAt;

  bool get signed => signedAt != null;
}

/// Hồ sơ tự nghiệm thu của một công trình (thi công mới / cải tạo).
class ProjectAcceptance {
  ProjectAcceptance({
    required this.id,
    required this.facilityId,
    required this.projectName,
    required this.steps,
    required this.checklist,
    required this.measurements,
    required this.signOffs,
    required this.asBuiltParts,
    this.pc18Signed = false,
    this.pc18SignedAt,
    this.receiptCode = '',
  });

  final String id;
  final String facilityId;
  String projectName;
  final List<AcceptanceStep> steps;
  final Map<String, CheckResult> checklist; // mã 2.1 → 2.21
  final List<Measurement> measurements;
  final List<SignOff> signOffs;

  /// 6 thành phần hồ sơ hoàn công → đã có hay chưa.
  final Map<String, bool> asBuiltParts;

  bool pc18Signed; // đã ký số Văn bản PC18
  DateTime? pc18SignedAt;
  String receiptCode; // mã biên nhận khi khai báo CSDL Quốc gia

  int get doneSteps => steps.where((s) => s.status == StepStatus.done).length;
  int get passedChecks =>
      checklist.values.where((r) => r == CheckResult.pass || r == CheckResult.na).length;
  int get failedChecks => checklist.values.where((r) => r == CheckResult.fail).length;
  int get asBuiltDone => asBuiltParts.values.where((v) => v).length;
  bool get allSigned => signOffs.every((s) => s.signed);
  bool get synced => receiptCode.isNotEmpty;

  /// Có đủ điều kiện ký PC18 chưa: bước 1–4 xong, đủ chữ ký,
  /// không hạng mục nào trượt, không chỉ số đo nào trượt.
  List<String> get pc18Blockers {
    final list = <String>[];
    for (final s in steps.where((s) => s.no <= 4)) {
      if (s.status != StepStatus.done) list.add('Bước ${s.no} chưa hoàn thành');
    }
    if (checklist.values.any((r) => r == CheckResult.pending)) {
      list.add('Còn hạng mục trong checklist 21 hạng mục chưa kiểm');
    }
    if (failedChecks > 0) list.add('Có $failedChecks hạng mục không đạt');
    if (measurements.any((m) => m.passed == false)) {
      list.add('Có thông số kỹ thuật đo không đạt ngưỡng');
    }
    if (!allSigned) list.add('Chưa đủ chữ ký của các bên tại Bước 4');
    return list;
  }
}

/// Thành phần hồ sơ hoàn công (bước 5).
const asBuiltPartNames = [
  'Văn bản thẩm định thiết kế (PC12/PC13) & bản vẽ được duyệt',
  'Bản vẽ hoàn công hệ thống PCCC',
  'Chứng nhận kiểm định phương tiện (tem, CO/CQ)',
  'Biên bản nghiệm thu bộ phận che khuất & thử đơn động',
  'Biên bản thử liên động & nghiệm thu hoàn thành',
  'Văn bản PC18 của chủ đầu tư',
];

/// 4 bên phải ký ở Bước 4.
const signOffRoles = [
  'Chủ đầu tư',
  'Giám sát trưởng',
  'Chỉ huy trưởng thi công',
  'Chủ nhiệm thiết kế',
];

/// Định nghĩa 6 bước (nội dung lấy từ bản đặc tả).
List<AcceptanceStep> buildDefaultSteps() => [
  AcceptanceStep(
    no: 1,
    title: 'Đối chiếu thiết kế & nghiệm thu vật liệu đầu vào',
    content: 'Đối chiếu hồ sơ thiết kế đã thẩm định (PC12/PC13) với vật tư, thiết bị '
        'đưa vào công trình. Quét QR tem kiểm định, kiểm tra CO/CQ.',
    evidence: ['Ảnh quét QR tem kiểm định', 'Bản scan CO/CQ', 'Tờ khai PC24 (nếu có phương tiện lưu thông)'],
    outputs: ['Biên bản nghiệm thu vật liệu, thiết bị đầu vào'],
  ),
  AcceptanceStep(
    no: 2,
    title: 'Nghiệm thu bộ phận che khuất',
    content: 'Nghiệm thu đường ống, dây dẫn trước khi che lấp: thử áp lực đường ống, '
        'đo điện trở tiếp địa.',
    evidence: ['Ảnh có Geotag & Timestamp', 'Kết quả thử áp lực', 'Kết quả đo tiếp địa'],
    outputs: ['Biên bản nghiệm thu bộ phận che khuất'],
  ),
  AcceptanceStep(
    no: 3,
    title: 'Thử đơn động không tải / có tải',
    content: 'Chạy thử từng thiết bị riêng lẻ, nhập thông số đo; hệ thống tự so với ngưỡng '
        'và báo đỏ nếu không đạt.',
    evidence: ['Bảng thông số đo', 'Ảnh / video chạy thử'],
    outputs: ['Biên bản thử đơn động'],
  ),
  AcceptanceStep(
    no: 4,
    title: 'Thử liên động toàn hệ thống & nghiệm thu hoàn thành',
    content: 'Kích hoạt kịch bản cháy giả định, kiểm tra liên động; chấm 21 hạng mục; '
        'các bên ký xác nhận.',
    evidence: ['Video thử liên động', 'Checklist 21 hạng mục', 'Chữ ký 4 bên'],
    outputs: ['Biên bản nghiệm thu hoàn thành'],
  ),
  AcceptanceStep(
    no: 5,
    title: 'Lập Văn bản PC18 & đóng bộ hồ sơ hoàn công',
    content: 'Lập Văn bản nghiệm thu PCCC của chủ đầu tư (Mẫu PC18), ký số; '
        'tập hợp đủ 6 thành phần hồ sơ hoàn công.',
    evidence: ['Văn bản PC18 đã ký số', 'Bộ hồ sơ hoàn công 6 thành phần'],
    outputs: ['Văn bản PC18', 'Hồ sơ hoàn công điện tử'],
  ),
  AcceptanceStep(
    no: 6,
    title: 'Khai báo CSDL Quốc gia & đưa vào vận hành',
    content: 'Khai báo PC01 và PC18 lên Cơ sở dữ liệu quốc gia về PCCC & CNCH, '
        'nhận mã biên nhận; đưa công trình vào hoạt động.',
    evidence: ['Mã biên nhận', 'Ảnh chụp xác nhận đồng bộ'],
    outputs: ['Mã biên nhận CSDL', 'Công trình được đưa vào vận hành'],
  ),
];

// ======================== Sẵn sàng hậu kiểm ========================

/// Một mục trong danh sách kiểm tra sẵn sàng (9 nhóm trách nhiệm).
class ReadinessItem {
  ReadinessItem({required this.code, required this.name, this.done = false, this.note = ''});

  final String code;
  final String name;
  bool done;
  String note;
}

/// Lỗi cần khắc phục theo Biên bản kiểm tra PC03 của đoàn hậu kiểm.
class RemediationItem {
  RemediationItem({
    required this.title,
    required this.assignee,
    required this.due,
    this.done = false,
    List<String>? evidence,
  }) : evidence = evidence ?? [];

  String title;
  String assignee;
  DateTime due;
  bool done;
  final List<String> evidence;
}

/// Thông tin hậu kiểm của cơ sở.
class PostInspection {
  PostInspection({
    this.lastSelfCheck,
    this.nextSelfCheck,
    this.nextInspection,
    this.agency = '',
    this.receptionMode = false,
    List<RemediationItem>? remediations,
  }) : remediations = remediations ?? [];

  DateTime? lastSelfCheck; // lần tự kiểm tra PC02 gần nhất
  DateTime? nextSelfCheck; // hạn tự kiểm tra kế tiếp
  DateTime? nextInspection; // lịch hậu kiểm dự kiến
  String agency; // cơ quan hậu kiểm
  bool receptionMode; // đang bật chế độ tiếp đoàn (QR)
  final List<RemediationItem> remediations;
}

/// Tổng hợp số liệu cho bảng "Sẵn sàng hậu kiểm".
class ReadinessSummary {
  const ReadinessSummary({
    required this.asBuiltDone,
    required this.asBuiltTotal,
    required this.groupsDone,
    required this.groupsTotal,
    required this.htReady,
    required this.htTotal,
    required this.inspection,
  });

  final int asBuiltDone;
  final int asBuiltTotal;
  final int groupsDone;
  final int groupsTotal;
  final int htReady; // số nhóm HT có thiết bị và tất cả đều hoạt động tốt
  final int htTotal; // số nhóm HT cơ sở đang có
  final PostInspection inspection;

  /// Điểm sẵn sàng 0–100 (trọng số bằng nhau cho 3 phần).
  int get score {
    double r(int a, int b) => b == 0 ? 1 : a / b;
    final v = (r(asBuiltDone, asBuiltTotal) + r(groupsDone, groupsTotal) + r(htReady, htTotal)) / 3;
    return (v * 100).round();
  }
}

// ======================== Khai báo PC01 ========================

enum DeclarationStatus {
  notDeclared('Chưa khai báo', AppColors.danger),
  draft('Đang soạn', AppColors.info),
  synced('Đã đồng bộ CSDL', AppColors.success),
  needUpdate('Có thay đổi – cần cập nhật', AppColors.warning);

  const DeclarationStatus(this.label, this.color);
  final String label;
  final Color color;
}

/// Phiếu thông tin cơ sở PC01 (khai báo lên CSDL Quốc gia).
class Pc01Declaration {
  Pc01Declaration({
    this.status = DeclarationStatus.notDeclared,
    this.lastSyncedAt,
    this.changedAt,
    this.receiptCode = '',
    List<String>? changes,
  }) : changes = changes ?? [];

  DeclarationStatus status;
  DateTime? lastSyncedAt;
  DateTime? changedAt; // thời điểm phát sinh thay đổi → hạn cập nhật 72 giờ
  String receiptCode;
  final List<String> changes; // các trường đã thay đổi so với lần khai báo trước

  /// Hạn cập nhật thay đổi (72 giờ kể từ khi có thay đổi).
  DateTime? get updateDeadline => changedAt?.add(const Duration(hours: 72));
}
