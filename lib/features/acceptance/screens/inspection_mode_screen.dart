import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/session/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/info_section.dart';
import '../../../core/widgets/status_chip.dart';
import '../models/acceptance.dart';

/// Chế độ tiếp đoàn hậu kiểm: hiện mã QR để đoàn kiểm tra quét xem hồ sơ
/// điện tử (chỉ đọc), và theo dõi khắc phục theo Biên bản kiểm tra PC03.
class InspectionModeScreen extends StatefulWidget {
  const InspectionModeScreen({super.key});

  @override
  State<InspectionModeScreen> createState() => _InspectionModeScreenState();
}

class _InspectionModeScreenState extends State<InspectionModeScreen> {
  late Future<PostInspection> _future = Locator.acceptance.getPostInspection();

  void _reload() => setState(() => _future = Locator.acceptance.getPostInspection());

  Future<void> _resolve(PostInspection p, RemediationItem r) async {
    if (r.evidence.isEmpty) {
      // Bắt buộc có minh chứng trước khi xác nhận đã khắc phục.
      final ok = await confirmDialog(
        context,
        title: 'Cần minh chứng',
        message: 'Đính kèm ảnh / tệp minh chứng đã khắc phục trước khi xác nhận. Thêm minh chứng ngay?',
        confirmLabel: 'Thêm minh chứng',
      );
      if (!ok) return;
      r.evidence.add('khac_phuc_${DateTime.now().millisecondsSinceEpoch % 100000}.jpg');
    }
    r.done = true;
    await Locator.acceptance.savePostInspection(p);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tiếp đoàn hậu kiểm')),
      body: AsyncBody<PostInspection>(
        future: _future,
        builder: (context, p) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: p.receptionMode,
                      title: const Text('Chế độ tiếp đoàn',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: const Text('Cho phép đoàn kiểm tra quét QR xem hồ sơ (chỉ đọc)'),
                      onChanged: (v) async {
                        p.receptionMode = v;
                        await Locator.acceptance.savePostInspection(p);
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 8),
                    AnimatedOpacity(
                      opacity: p.receptionMode ? 1 : 0.25,
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.textPrimary, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        // TODO: sinh QR thật (gói qr_flutter) chứa link hồ sơ có thời hạn.
                        child: const Icon(Icons.qr_code_2, size: 170),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p.receptionMode
                          ? 'Mã hồ sơ: ${AppSession.instance.currentFacilityId.toUpperCase()}-'
                              '${DateTime.now().millisecondsSinceEpoch % 1000000}'
                          : 'Bật chế độ tiếp đoàn để hiện mã QR',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const InfoSection(
              title: 'Đoàn kiểm tra xem được',
              icon: Icons.visibility_outlined,
              children: [
                Text('• Phiếu thông tin cơ sở PC01 & Văn bản PC18'),
                Text('• Hồ sơ hoàn công, biên bản tự kiểm tra PC02'),
                Text('• Danh sách đội PCCC, kết quả huấn luyện'),
                Text('• Sổ theo dõi phương tiện (Mẫu 01), kết quả HT1 – HT16'),
                Text('• Phương án PC06 và kết quả thực tập'),
              ],
            ),
            const SizedBox(height: 12),
            InfoSection(
              title: 'Khắc phục theo Biên bản PC03',
              icon: Icons.build_outlined,
              trailing: TextButton.icon(
                onPressed: () => showComingSoon(context, 'Nhận Biên bản PC03 từ đoàn kiểm tra'),
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Nhận PC03'),
              ),
              children: [
                if (p.remediations.isEmpty) const Text('Chưa có yêu cầu khắc phục.'),
                for (final r in p.remediations)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      r.done ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: r.done ? AppColors.success : dueColor(r.due),
                    ),
                    title: Text(r.title),
                    subtitle: Text('${r.assignee} · hạn ${fmtDate(r.due)}'
                        '${r.evidence.isEmpty ? '' : ' · ${r.evidence.length} minh chứng'}'),
                    trailing: r.done
                        ? const StatusChip(label: 'Đã khắc phục', color: AppColors.success)
                        : TextButton(onPressed: () => _resolve(p, r), child: const Text('Xác nhận')),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
