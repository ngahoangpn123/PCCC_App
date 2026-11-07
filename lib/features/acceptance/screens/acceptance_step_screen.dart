import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/legal/legal_catalog.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/attachment_list.dart';
import '../../../core/widgets/info_section.dart';
import '../../../core/widgets/status_chip.dart';
import '../models/acceptance.dart';

/// Chi tiết một bước tự nghiệm thu: nội dung, minh chứng, đầu ra,
/// checklist 21 hạng mục + đo thông số (bước 3–4), chữ ký 4 bên (bước 4),
/// thành phần hồ sơ hoàn công (bước 5), mã biên nhận (bước 6).
class AcceptanceStepScreen extends StatefulWidget {
  const AcceptanceStepScreen({super.key, required this.acceptance, required this.stepNo});

  final ProjectAcceptance acceptance;
  final int stepNo;

  @override
  State<AcceptanceStepScreen> createState() => _AcceptanceStepScreenState();
}

class _AcceptanceStepScreenState extends State<AcceptanceStepScreen> {
  ProjectAcceptance get a => widget.acceptance;
  AcceptanceStep get step => a.steps[widget.stepNo - 1];

  late final _note = TextEditingController(text: step.note);
  late final _receipt = TextEditingController(text: a.receiptCode);
  late final List<TextEditingController> _measureCtrls = [
    for (final m in a.measurements)
      TextEditingController(text: m.value == null ? '' : m.value.toString().replaceAll('.', ',')),
  ];

  @override
  void dispose() {
    _note.dispose();
    _receipt.dispose();
    for (final c in _measureCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  /// Bước trước chưa xong thì không được hoàn thành bước này.
  bool get _previousDone =>
      a.steps.where((s) => s.no < step.no).every((s) => s.status == StepStatus.done);

  List<String> _stepBlockers() {
    final list = <String>[];
    if (!_previousDone) list.add('Các bước trước chưa hoàn thành');
    if (step.attachments.isEmpty && step.no != 6) list.add('Chưa đính kèm minh chứng');
    if (step.no == 3 && a.measurements.any((m) => m.passed != true)) {
      list.add('Thông số đo chưa nhập đủ hoặc không đạt ngưỡng');
    }
    if (step.no == 4) {
      if (a.checklist.values.any((r) => r == CheckResult.pending)) {
        list.add('Còn hạng mục chưa kiểm trong checklist 21 hạng mục');
      }
      if (a.failedChecks > 0) list.add('Còn ${a.failedChecks} hạng mục không đạt');
      if (!a.allSigned) list.add('Chưa đủ chữ ký 4 bên');
    }
    if (step.no == 5) {
      if (!a.pc18Signed) list.add('Chưa ký số Văn bản PC18');
      if (a.asBuiltDone < a.asBuiltParts.length) list.add('Hồ sơ hoàn công chưa đủ 6 thành phần');
    }
    if (step.no == 6 && _receipt.text.trim().isEmpty) list.add('Chưa có mã biên nhận CSDL');
    return list;
  }

  Future<void> _save({bool complete = false}) async {
    step.note = _note.text.trim();
    for (var i = 0; i < a.measurements.length; i++) {
      final t = _measureCtrls[i].text.trim().replaceAll(',', '.');
      a.measurements[i].value = t.isEmpty ? null : double.tryParse(t);
    }
    if (step.no == 6) a.receiptCode = _receipt.text.trim();
    if (complete) {
      final blockers = _stepBlockers();
      if (blockers.isNotEmpty) {
        await showDialog<void>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Chưa thể hoàn thành bước'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [for (final b in blockers) Text('• $b')],
            ),
            actions: [FilledButton(onPressed: () => Navigator.pop(c), child: const Text('Đã hiểu'))],
          ),
        );
        setState(() {});
        return;
      }
      step.status = StepStatus.done;
      step.completedAt = DateTime.now();
      if (step.no < 6 && a.steps[step.no].status == StepStatus.notStarted) {
        a.steps[step.no].status = StepStatus.inProgress;
      }
    } else if (step.status == StepStatus.notStarted) {
      step.status = StepStatus.inProgress;
    }
    if (step.hasChecklist && step.status != StepStatus.done) {
      final anyFail = a.failedChecks > 0 || a.measurements.any((m) => m.passed == false);
      step.status = anyFail ? StepStatus.failed : StepStatus.inProgress;
    }
    await Locator.acceptance.saveAcceptance(a);
    if (!mounted) return;
    showSnack(context, complete ? 'Đã hoàn thành Bước ${step.no}' : 'Đã lưu');
    if (complete) Navigator.pop(context);
    setState(() {});
  }

  Future<void> _sign(SignOff s) async {
    final ctrl = TextEditingController(text: s.name);
    final name = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Ký xác nhận – ${s.role}'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Họ tên người ký'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(c, ctrl.text.trim()), child: const Text('Ký')),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    // TODO: thay bằng ký số / ký điện tử thật.
    setState(() {
      s.name = name;
      s.signedAt = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bước ${step.no}/6')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(onPressed: () => _save(), child: const Text('Lưu tạm')),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: step.status == StepStatus.done ? null : () => _save(complete: true),
                  child: const Text('Hoàn thành bước'),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StatusChip(label: step.status.label, color: step.status.color, icon: step.status.icon),
          const SizedBox(height: 8),
          Text(step.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          if (step.completedAt != null)
            Text('Hoàn thành ${fmtDateTime(step.completedAt!)}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
          const SizedBox(height: 12),
          InfoSection(
            title: 'Nội dung công việc',
            icon: Icons.assignment_outlined,
            children: [Text(step.content)],
          ),
          const SizedBox(height: 12),
          InfoSection(
            title: 'Minh chứng cần có',
            icon: Icons.verified_outlined,
            children: [
              for (final e in step.evidence) _Bullet(e),
              const Divider(height: 20),
              AttachmentList(
                files: step.attachments,
                onAdd: () => _addEvidence(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InfoSection(
            title: 'Kết quả đầu ra',
            icon: Icons.output,
            children: [for (final o in step.outputs) _Bullet(o)],
          ),
          if (step.no == 3) ...[const SizedBox(height: 12), _measurements()],
          if (step.no == 4) ...[
            const SizedBox(height: 12),
            _checklist(),
            const SizedBox(height: 12),
            _signatures(),
          ],
          if (step.no == 5) ...[const SizedBox(height: 12), _asBuilt()],
          if (step.no == 6) ...[const SizedBox(height: 12), _receiptBox()],
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Ghi chú'),
          ),
        ],
      ),
    );
  }

  Future<void> _addEvidence() async {
    final kind = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Chụp ảnh (kèm Geotag & Timestamp)'),
              onTap: () => Navigator.pop(c, 'anh_geotag'),
            ),
            ListTile(
              leading: const Icon(Icons.videocam_outlined),
              title: const Text('Quay video'),
              onTap: () => Navigator.pop(c, 'video'),
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Quét QR tem kiểm định'),
              onTap: () => Navigator.pop(c, 'qr_tem'),
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Tải tệp (CO/CQ, biên bản...)'),
              onTap: () => Navigator.pop(c, 'tep'),
            ),
          ],
        ),
      ),
    );
    if (kind == null) return;
    // TODO: camera + định vị thật. Hiện thêm tên tệp giả lập có tọa độ & thời gian.
    final now = DateTime.now();
    setState(() => step.attachments.add(
          '${kind}_${now.millisecondsSinceEpoch % 100000}'
          '${kind == 'anh_geotag' ? '_20.9931N_105.8106E' : ''}.${kind == 'video' ? 'mp4' : kind == 'tep' ? 'pdf' : 'jpg'}',
        ));
  }

  Widget _measurements() {
    return InfoSection(
      title: 'Thông số đo (tự so với ngưỡng)',
      icon: Icons.speed,
      children: [
        for (var i = 0; i < a.measurements.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _MeasureField(
              m: a.measurements[i],
              controller: _measureCtrls[i],
              onChanged: (v) => setState(() {
                a.measurements[i].value = double.tryParse(v.trim().replaceAll(',', '.'));
              }),
            ),
          ),
        const Text('TODO: bổ sung đủ các thông số theo QCVN/TCVN áp dụng.',
            style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _checklist() {
    return InfoSection(
      title: 'Checklist 21 hạng mục nghiệm thu',
      icon: Icons.checklist,
      trailing: Text('${a.passedChecks}/${a.checklist.length}',
          style: const TextStyle(fontWeight: FontWeight.w700)),
      children: [
        for (final item in acceptanceItems)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item.code}. ${item.name}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: a.checklist[item.code] == CheckResult.fail
                          ? AppColors.danger
                          : AppColors.textPrimary,
                    )),
                if (item.detail.isNotEmpty)
                  Text(item.detail,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: [
                    for (final r in [CheckResult.pass, CheckResult.fail, CheckResult.na])
                      ChoiceChip(
                        label: Text(r.label),
                        selected: a.checklist[item.code] == r,
                        selectedColor: r.color.withValues(alpha: 0.18),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: a.checklist[item.code] == r ? r.color : AppColors.textPrimary,
                        ),
                        onSelected: (_) => setState(() => a.checklist[item.code] = r),
                      ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _signatures() {
    return InfoSection(
      title: 'Chữ ký các bên',
      icon: Icons.draw_outlined,
      children: [
        for (final s in a.signOffs)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              s.signed ? Icons.verified : Icons.pending_outlined,
              color: s.signed ? AppColors.success : AppColors.neutral,
            ),
            title: Text(s.role),
            subtitle: Text(s.signed ? '${s.name} · ${fmtDateTime(s.signedAt!)}' : 'Chưa ký'),
            trailing: s.signed
                ? null
                : TextButton(onPressed: () => _sign(s), child: const Text('Ký')),
          ),
      ],
    );
  }

  Widget _asBuilt() {
    return InfoSection(
      title: 'Hồ sơ hoàn công (6 thành phần)',
      icon: Icons.folder_copy_outlined,
      trailing: Text('${a.asBuiltDone}/${a.asBuiltParts.length}',
          style: const TextStyle(fontWeight: FontWeight.w700)),
      children: [
        for (final name in asBuiltPartNames)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            value: a.asBuiltParts[name] ?? false,
            title: Text(name, style: const TextStyle(fontSize: 13.5)),
            onChanged: name == asBuiltPartNames.last
                ? null // PC18 chỉ tích khi đã ký số ở màn hình chính
                : (v) => setState(() => a.asBuiltParts[name] = v ?? false),
          ),
        if (!a.pc18Signed)
          const Text('Văn bản PC18 được tích tự động sau khi ký số ở màn hình Tự nghiệm thu.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _receiptBox() {
    return InfoSection(
      title: 'Khai báo CSDL Quốc gia',
      icon: Icons.cloud_done_outlined,
      children: [
        const Text('Khai báo PC01 và PC18 lên CSDL Quốc gia về PCCC & CNCH. '
            'Khi có tích hợp API, mã biên nhận sẽ tự điền.'),
        const SizedBox(height: 10),
        TextField(
          controller: _receipt,
          decoration: const InputDecoration(labelText: 'Mã biên nhận'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => showComingSoon(context, 'Đồng bộ CSDL Quốc gia (API)'),
          icon: const Icon(Icons.sync),
          label: const Text('Đồng bộ CSDL'),
        ),
      ],
    );
  }
}

class _MeasureField extends StatelessWidget {
  const _MeasureField({required this.m, required this.controller, required this.onChanged});

  final Measurement m;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final passed = m.passed;
    final color = passed == null
        ? AppColors.neutral
        : passed
            ? AppColors.success
            : AppColors.danger;
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: '${m.spec.name} (${m.spec.unit})',
        helperText: 'Chuẩn: ${m.spec.rule}',
        errorText: passed == false ? 'KHÔNG ĐẠT – ngoài ngưỡng ${m.spec.rule}' : null,
        suffixIcon: Icon(
          passed == null ? Icons.remove : passed ? Icons.check_circle : Icons.error,
          color: color,
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('•  '),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
