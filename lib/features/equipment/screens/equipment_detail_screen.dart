import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/legal/legal_catalog.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/info_section.dart';
import '../../../core/widgets/status_chip.dart';
import '../models/equipment.dart';
import 'equipment_form_screen.dart';
import 'inspection_screen.dart';

class EquipmentDetailScreen extends StatefulWidget {
  const EquipmentDetailScreen({super.key, required this.equipmentId});

  final String equipmentId;

  @override
  State<EquipmentDetailScreen> createState() => _EquipmentDetailScreenState();
}

class _EquipmentDetailScreenState extends State<EquipmentDetailScreen> {
  late Future<Equipment> _future;

  @override
  void initState() {
    super.initState();
    _future = Locator.equipment.getById(widget.equipmentId);
  }

  void _reload() =>
      setState(() => _future = Locator.equipment.getById(widget.equipmentId));

  Future<void> _confirm(Equipment e, InspectionRecord r) async {
    final ok = await confirmDialog(
      context,
      title: 'Xác nhận kết quả',
      message: 'Xác nhận kết quả ${r.kind.toLowerCase()} ngày ${fmtDate(r.date)} với tư cách người có thẩm quyền?',
      confirmLabel: 'Xác nhận',
    );
    if (!ok) return;
    r.confirmed = true;
    await Locator.equipment.save(e);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBody<Equipment>(
      future: _future,
      builder: (context, e) {
        final records = [...e.records]..sort((a, b) => b.date.compareTo(a.date));
        return Scaffold(
          appBar: AppBar(
            title: const Text('Chi tiết thiết bị'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  await pushScreen(context, EquipmentFormScreen(item: e));
                  _reload();
                },
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: FilledButton.icon(
                onPressed: () async {
                  await pushScreen(context, InspectionScreen(equipmentId: e.id));
                  _reload();
                },
                icon: const Icon(Icons.fact_check_outlined),
                label: const Text('Kiểm tra / bảo dưỡng'),
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.goldLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(equipmentIcon(e.type), color: AppColors.primary, size: 30),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                            Text(e.code, style: const TextStyle(color: AppColors.textSecondary)),
                            const SizedBox(height: 6),
                            StatusChip(label: e.status.label, color: e.status.color),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Mã QR của thiết bị',
                        icon: const Icon(Icons.qr_code_2, size: 32),
                        onPressed: () => showComingSoon(context, 'In mã QR dán tại thiết bị'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              InfoSection(
                title: 'Lịch kiểm tra',
                icon: Icons.event_available,
                children: [
                  InfoRow('Kiểm tra tiếp theo', fmtDate(e.nextCheck)),
                  Padding(
                    padding: const EdgeInsets.only(left: 130),
                    child: Text(dueText(e.nextCheck),
                        style: TextStyle(color: dueColor(e.nextCheck), fontWeight: FontWeight.w600)),
                  ),
                  InfoRow('Người phụ trách', e.keeper),
                ],
              ),
              const SizedBox(height: 12),
              InfoSection(
                title: 'Thông tin thiết bị',
                icon: Icons.info_outline,
                children: [
                  InfoRow('Nhóm hệ thống', htLabel(e.htGroup)),
                  InfoRow('Loại', e.type),
                  if (e.pc24Code.isNotEmpty) InfoRow('Tờ khai PC24', e.pc24Code),
                  InfoRow('Hãng sản xuất', e.maker),
                  InfoRow('Model', e.model),
                  InfoRow('Số serial', e.serial),
                  InfoRow('Số lượng', '${e.quantity} ${e.unit}'),
                  InfoRow('Vị trí', e.location),
                  InfoRow('Đưa vào sử dụng', fmtDate(e.inUseSince)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => showComingSoon(context, 'Sổ theo dõi phương tiện (Mẫu 01 TT 36)'),
                      icon: const Icon(Icons.menu_book_outlined, size: 18),
                      label: const Text('Sổ Mẫu 01', overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => showComingSoon(context, 'Xuất biên bản tự kiểm tra (PC02)'),
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                      label: const Text('Xuất PC02', overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InfoSection(
                title: 'Lịch sử kiểm tra, bảo dưỡng, sửa chữa',
                icon: Icons.history,
                children: [
                  if (records.isEmpty)
                    const Text('Chưa có lần kiểm tra nào', style: TextStyle(color: AppColors.textSecondary)),
                  for (final r in records)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('${r.kind} · ${fmtDate(r.date)}',
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              const Spacer(),
                              StatusChip(label: r.result.label, color: r.result.color),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('Người thực hiện: ${r.by}', style: const TextStyle(fontSize: 13)),
                          if (r.note.isNotEmpty) Text(r.note, style: const TextStyle(fontSize: 13)),
                          if (r.photos.isNotEmpty)
                            Text('${r.photos.length} ảnh minh chứng',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(height: 6),
                          r.confirmed
                              ? const StatusChip(label: 'Đã xác nhận', color: AppColors.success, icon: Icons.verified)
                              : TextButton.icon(
                                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                  onPressed: () => _confirm(e, r),
                                  icon: const Icon(Icons.verified_outlined, size: 18),
                                  label: const Text('Chờ xác nhận – Xác nhận ngay'),
                                ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
