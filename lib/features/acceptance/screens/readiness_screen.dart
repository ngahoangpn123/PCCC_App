import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/legal/legal_catalog.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/info_section.dart';
import '../../../core/widgets/status_chip.dart';
import '../../equipment/models/equipment.dart';
import '../models/acceptance.dart';

/// Danh mục sẵn sàng hậu kiểm: 9 nhóm trách nhiệm + 16 bảng HT + lịch PC02.
class ReadinessScreen extends StatefulWidget {
  const ReadinessScreen({super.key});

  @override
  State<ReadinessScreen> createState() => _ReadinessScreenState();
}

class _ReadinessScreenState extends State<ReadinessScreen> {
  late Future<(List<ReadinessItem>, List<Equipment>, PostInspection)> _future = _load();

  Future<(List<ReadinessItem>, List<Equipment>, PostInspection)> _load() async => (
    await Locator.acceptance.getReadinessItems(),
    await Locator.equipment.getEquipment(),
    await Locator.acceptance.getPostInspection(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sẵn sàng hậu kiểm')),
      body: AsyncBody<(List<ReadinessItem>, List<Equipment>, PostInspection)>(
        future: _future,
        builder: (context, data) {
          final (items, equipment, insp) = data;
          final byHt = <String, List<Equipment>>{};
          for (final e in equipment) {
            byHt.putIfAbsent(e.htGroup, () => []).add(e);
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              InfoSection(
                title: 'Tự kiểm tra định kỳ (PC02)',
                icon: Icons.checklist,
                children: [
                  InfoRow('Lần gần nhất', insp.lastSelfCheck == null ? '' : fmtDate(insp.lastSelfCheck!)),
                  InfoRow(
                    'Hạn kế tiếp',
                    insp.nextSelfCheck == null
                        ? ''
                        : '${fmtDate(insp.nextSelfCheck!)} (${dueText(insp.nextSelfCheck!)})',
                  ),
                  InfoRow(
                    'Lịch hậu kiểm',
                    insp.nextInspection == null ? 'Chưa có' : fmtFullDate(insp.nextInspection!),
                  ),
                  InfoRow('Cơ quan kiểm tra', insp.agency),
                  const SizedBox(height: 6),
                  OutlinedButton.icon(
                    onPressed: () => showComingSoon(context, 'Xuất biên bản tự kiểm tra PC02'),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('Lập / xuất biên bản PC02'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InfoSection(
                title: '9 nhóm trách nhiệm',
                icon: Icons.rule,
                trailing: Text('${items.where((i) => i.done).length}/${items.length}',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                children: [
                  for (final i in items)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: i.done,
                      title: Text('${i.code}. ${i.name}'),
                      subtitle: i.note.isEmpty
                          ? null
                          : Text(i.note, style: const TextStyle(color: AppColors.warning)),
                      onChanged: (v) async {
                        setState(() => i.done = v ?? false);
                        await Locator.acceptance.saveReadinessItems(items);
                      },
                    ),
                  const Text(
                    'TODO: tên chính thức của nhóm 1–8 sẽ cập nhật theo Phụ lục III.',
                    style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InfoSection(
                title: '16 bảng kiểm tra kỹ thuật (HT1 – HT16)',
                icon: Icons.build_circle_outlined,
                children: [
                  for (final ht in htTables) _HtRow(ht: ht, list: byHt[ht.code]),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HtRow extends StatelessWidget {
  const _HtRow({required this.ht, required this.list});

  final CatalogItem ht;
  final List<Equipment>? list;

  @override
  Widget build(BuildContext context) {
    final items = list;
    final (label, color) = items == null
        ? ('Không có', AppColors.neutral)
        : items.every((e) => e.status == EquipmentStatus.ok)
            ? ('Sẵn sàng', AppColors.success)
            : ('Cần xử lý', AppColors.danger);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(ht.code, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ht.name, style: const TextStyle(fontSize: 13)),
                if (items != null)
                  Text('${items.length} thiết bị',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
              ],
            ),
          ),
          StatusChip(label: label, color: color),
        ],
      ),
    );
  }
}
