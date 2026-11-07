import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/legal/legal_catalog.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/info_section.dart';
import '../../../core/widgets/status_chip.dart';
import '../../facility/screens/facility_edit_screen.dart';
import '../data/acceptance_repository.dart';
import '../models/acceptance.dart';

/// Khai báo Phiếu thông tin cơ sở PC01 lên CSDL Quốc gia.
/// Tự điền từ hồ sơ cơ sở, thiết bị (theo nhóm HT), đội PCCC;
/// kiểm tra hợp lệ trước khi nộp; đếm ngược hạn cập nhật 72 giờ.
class Pc01DeclarationScreen extends StatefulWidget {
  const Pc01DeclarationScreen({super.key});

  @override
  State<Pc01DeclarationScreen> createState() => _Pc01DeclarationScreenState();
}

class _Pc01DeclarationScreenState extends State<Pc01DeclarationScreen> {
  late Future<(Pc01Declaration, Pc01AutoData, List<String>)> _future = _load();
  Timer? _ticker;

  Future<(Pc01Declaration, Pc01AutoData, List<String>)> _load() async => (
    await Locator.acceptance.getPc01(),
    await Locator.acceptance.getPc01AutoData(),
    await Locator.acceptance.validatePc01(),
  );

  void _reload() => setState(() => _future = _load());

  @override
  void initState() {
    super.initState();
    // Cập nhật đồng hồ đếm ngược mỗi phút.
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _submit(Pc01Declaration d, List<String> errors) async {
    if (errors.isNotEmpty) {
      showSnack(context, 'Còn ${errors.length} lỗi cần sửa trước khi nộp');
      return;
    }
    final ok = await confirmDialog(
      context,
      title: 'Ký số & đồng bộ PC01',
      message: 'Ký số Phiếu thông tin cơ sở và gửi lên CSDL Quốc gia?',
      confirmLabel: 'Ký số & gửi',
    );
    if (!ok) return;
    // TODO: chữ ký số + API CSDL Quốc gia. Hiện giả lập.
    d
      ..status = DeclarationStatus.synced
      ..lastSyncedAt = DateTime.now()
      ..changedAt = null
      ..receiptCode = d.receiptCode.isEmpty
          ? 'CSDL-${DateTime.now().millisecondsSinceEpoch % 1000000}'
          : d.receiptCode;
    d.changes.clear();
    await Locator.acceptance.savePc01(d);
    if (!mounted) return;
    showSnack(context, 'Đã đồng bộ PC01 (giả lập)');
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Khai báo PC01')),
      body: AsyncBody<(Pc01Declaration, Pc01AutoData, List<String>)>(
        future: _future,
        builder: (context, data) {
          final (d, auto, errors) = data;
          final f = auto.facility;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  StatusChip(label: d.status.label, color: d.status.color),
                  const Spacer(),
                  if (d.receiptCode.isNotEmpty)
                    Text('Mã: ${d.receiptCode}',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              if (d.updateDeadline != null) ...[
                const SizedBox(height: 12),
                _DeadlineBanner(deadline: d.updateDeadline!, changes: d.changes),
              ],
              const SizedBox(height: 12),
              _ValidationCard(errors: errors),
              const SizedBox(height: 12),
              InfoSection(
                title: 'Thông tin cơ sở (tự điền)',
                icon: Icons.apartment,
                trailing: TextButton(
                  onPressed: () async {
                    await pushScreen(context, FacilityEditScreen(facility: f));
                    _reload();
                  },
                  child: const Text('Sửa'),
                ),
                children: [
                  InfoRow('Tên cơ sở', f.name),
                  InfoRow('Mã cơ sở', f.code),
                  InfoRow('Địa chỉ', f.address),
                  InfoRow('Tọa độ', f.hasCoordinates ? '${f.lat}, ${f.lng}' : 'Chưa có (0, 0)'),
                  InfoRow('Loại hình', f.type),
                  InfoRow('Người đứng đầu', '${f.headName} · ${f.headPhone}'),
                  InfoRow('Số người làm việc', '${f.staffCount}'),
                  InfoRow('Nguy hiểm cháy nổ', f.hazard),
                ],
              ),
              const SizedBox(height: 12),
              InfoSection(
                title: 'Phân cấp quản lý',
                icon: Icons.account_balance_outlined,
                children: [
                  InfoRow('Đang khai', f.managementLevel),
                  InfoRow('Hệ thống gợi ý', auto.suggestedLevel),
                  if (auto.suggestedLevel != f.managementLevel)
                    const Text('Phân cấp đang khai khác với gợi ý – kiểm tra lại tiêu chí.',
                        style: TextStyle(color: AppColors.warning, fontSize: 12.5)),
                  const Text('TODO: tiêu chí phân loại chính thức theo phụ lục Nghị định.',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 12),
              InfoSection(
                title: 'Lực lượng tại chỗ',
                icon: Icons.groups_outlined,
                children: [
                  InfoRow('Số đội viên', '${auto.teamCount}'),
                  InfoRow('Mô hình tổ chức', teamModelFor(f.staffCount)),
                ],
              ),
              const SizedBox(height: 12),
              InfoSection(
                title: 'Phương tiện PCCC theo nhóm HT',
                icon: Icons.fire_extinguisher,
                children: [
                  for (final e in auto.equipmentByHt.entries)
                    InfoRow(htLabel(e.key), '${e.value}'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => showComingSoon(context, 'Smart Auto-fill từ CCCD / GIS'),
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Auto-fill'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => showComingSoon(context, 'Xuất PC01 (PDF/Word)'),
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('Xuất mẫu'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                onPressed: errors.isEmpty ? () => _submit(d, errors) : null,
                icon: const Icon(Icons.cloud_upload_outlined),
                label: const Text('Ký số & đồng bộ CSDL Quốc gia'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ValidationCard extends StatelessWidget {
  const _ValidationCard({required this.errors});

  final List<String> errors;

  @override
  Widget build(BuildContext context) {
    final ok = errors.isEmpty;
    final color = ok ? AppColors.success : AppColors.danger;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(ok ? Icons.verified : Icons.error_outline, color: color),
              const SizedBox(width: 8),
              Text(
                ok ? 'Hợp lệ – sẵn sàng nộp' : 'Kiểm tra trước khi nộp: ${errors.length} lỗi',
                style: TextStyle(fontWeight: FontWeight.w700, color: color),
              ),
            ],
          ),
          for (final e in errors)
            Padding(padding: const EdgeInsets.only(top: 6), child: Text('• $e')),
        ],
      ),
    );
  }
}

class _DeadlineBanner extends StatelessWidget {
  const _DeadlineBanner({required this.deadline, required this.changes});

  final DateTime deadline;
  final List<String> changes;

  @override
  Widget build(BuildContext context) {
    final left = deadline.difference(DateTime.now());
    final overdue = left.isNegative;
    final color = overdue || left.inHours < 24 ? AppColors.danger : AppColors.warning;
    final text = overdue
        ? 'Đã quá hạn cập nhật 72 giờ'
        : 'Còn ${left.inHours} giờ ${left.inMinutes % 60} phút để cập nhật thay đổi';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timer_outlined, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(text, style: TextStyle(fontWeight: FontWeight.w700, color: color)),
              ),
            ],
          ),
          Text('Hạn: ${fmtDateTime(deadline)}', style: const TextStyle(fontSize: 12.5)),
          for (final c in changes) Text('• $c', style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
