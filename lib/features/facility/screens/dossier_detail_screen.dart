import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/models/history_entry.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/attachment_list.dart';
import '../../../core/widgets/history_timeline.dart';
import '../../../core/widgets/info_section.dart';
import '../../../core/widgets/status_chip.dart';
import '../models/dossier.dart';
import 'dossier_form_screen.dart';

class DossierDetailScreen extends StatefulWidget {
  const DossierDetailScreen({super.key, required this.dossierId});

  final String dossierId;

  @override
  State<DossierDetailScreen> createState() => _DossierDetailScreenState();
}

class _DossierDetailScreenState extends State<DossierDetailScreen> {
  late Future<Dossier> _future;

  // Các bước của quy trình thao tác hồ sơ.
  static const _steps = [
    'Chọn biểu mẫu',
    'Tạo hồ sơ',
    'Kiểm tra thông tin',
    'Ký và gửi',
    'Theo dõi kết quả',
  ];

  @override
  void initState() {
    super.initState();
    _future = Locator.facility.getDossier(widget.dossierId);
  }

  void _reload() =>
      setState(() => _future = Locator.facility.getDossier(widget.dossierId));

  /// Bước hiện tại trong quy trình, suy ra từ trạng thái.
  int _stepOf(DossierStatus s) => switch (s) {
    DossierStatus.notCreated => 0,
    DossierStatus.draft => 2,
    DossierStatus.waitingSign || DossierStatus.waitingSubmit => 3,
    _ => 4,
  };

  Future<void> _changeStatus(Dossier d) async {
    final picked = await showModalBottomSheet<DossierStatus>(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'Chuyển trạng thái hồ sơ',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
            for (final s in DossierStatus.values)
              ListTile(
                leading: Icon(Icons.circle, size: 14, color: s.color),
                title: Text(s.label),
                subtitle: s == DossierStatus.approved
                    ? const Text('Chỉ chọn khi có xác nhận từ đơn vị có thẩm quyền')
                    : null,
                trailing: s == d.status ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(c, s),
              ),
          ],
        ),
      ),
    );
    if (picked == null || picked == d.status) return;
    d.history.add(
      HistoryEntry(
        time: DateTime.now(),
        actor: 'Bạn',
        action: 'Chuyển trạng thái: ${d.status.label} → ${picked.label}',
      ),
    );
    d.status = picked;
    d.updatedAt = DateTime.now();
    await Locator.facility.saveDossier(d);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBody<Dossier>(
      future: _future,
      builder: (context, d) => Scaffold(
        appBar: AppBar(
          title: Text('Hồ sơ ${d.formCode}'),
          actions: [
            IconButton(
              tooltip: 'Chỉnh sửa',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                await pushScreen(context, DossierFormScreen(dossier: d));
                _reload();
              },
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton.icon(
              onPressed: () => _changeStatus(d),
              icon: const Icon(Icons.swap_vert),
              label: const Text('Chuyển trạng thái'),
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatusChip(label: d.status.label, color: d.status.color),
                    const SizedBox(height: 8),
                    Text(
                      d.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    if (d.note.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: d.status.color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(d.note),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            InfoSection(
              title: 'Thông tin hồ sơ',
              icon: Icons.info_outline,
              children: [
                InfoRow('Mã biểu mẫu', d.formCode),
                InfoRow('Người phụ trách', d.owner),
                InfoRow('Cập nhật lần cuối', fmtDate(d.updatedAt)),
                InfoRow(
                  'Ngày đến hạn',
                  d.dueDate == null ? '' : '${fmtDate(d.dueDate!)} (${dueText(d.dueDate!)})',
                ),
              ],
            ),
            const SizedBox(height: 12),
            InfoSection(
              title: 'Quy trình xử lý',
              icon: Icons.route_outlined,
              children: [
                for (var i = 0; i < _steps.length; i++)
                  _StepRow(
                    index: i,
                    label: _steps[i],
                    state: i < _stepOf(d.status)
                        ? _StepState.done
                        : i == _stepOf(d.status)
                            ? _StepState.current
                            : _StepState.todo,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            InfoSection(
              title: 'Tệp đính kèm',
              icon: Icons.attach_file,
              children: [
                AttachmentList(
                  files: d.attachments,
                  onAdd: () => showComingSoon(context, 'Đính kèm tệp'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            InfoSection(
              title: 'Lịch sử xử lý',
              icon: Icons.history,
              children: [HistoryTimeline(entries: d.history)],
            ),
          ],
        ),
      ),
    );
  }
}

enum _StepState { done, current, todo }

class _StepRow extends StatelessWidget {
  const _StepRow({required this.index, required this.label, required this.state});

  final int index;
  final String label;
  final _StepState state;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _StepState.done => AppColors.success,
      _StepState.current => AppColors.primary,
      _StepState.todo => AppColors.neutral,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: state == _StepState.todo
                ? AppColors.border
                : color,
            child: state == _StepState.done
                ? const Icon(Icons.check, size: 15, color: Colors.white)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      color: state == _StepState.todo ? AppColors.textSecondary : Colors.white,
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontWeight: state == _StepState.current ? FontWeight.w700 : FontWeight.w400,
              color: state == _StepState.todo ? AppColors.textSecondary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
