import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/info_section.dart';
import '../../../core/widgets/status_chip.dart';
import '../models/app_notification.dart';
import '../notification_router.dart';

class NotificationDetailScreen extends StatefulWidget {
  const NotificationDetailScreen({super.key, required this.notificationId});

  final String notificationId;

  @override
  State<NotificationDetailScreen> createState() => _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  late Future<AppNotification> _future;

  @override
  void initState() {
    super.initState();
    _future = Locator.notifications.getNotification(widget.notificationId);
  }

  void _reload() => setState(
        () => _future = Locator.notifications.getNotification(widget.notificationId),
      );

  /// Đóng thông báo: bắt buộc nhập kết quả xử lý và đính kèm minh chứng.
  Future<void> _resolve(AppNotification n) async {
    final result = await showModalBottomSheet<(String, List<String>)>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (c) => const _ResolveSheet(),
    );
    if (result == null) return;
    final (note, files) = result;
    await Locator.notifications.markResolved(n.id, resultNote: note, evidence: files);
    if (!mounted) return;
    showSnack(context, 'Đã xác nhận xử lý');
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBody<AppNotification>(
      future: _future,
      builder: (context, n) => Scaffold(
        appBar: AppBar(title: const Text('Chi tiết thông báo')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(n.category.icon, color: n.category.color),
                        const SizedBox(width: 8),
                        StatusChip(label: n.category.label, color: n.category.color),
                        const SizedBox(width: 6),
                        StatusChip(label: n.priority.label, color: n.priority.color),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(n.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(n.body),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            InfoSection(
              title: 'Trạng thái',
              icon: Icons.flag_outlined,
              children: [
                InfoRow('Phát sinh lúc', fmtDateTime(n.createdAt)),
                InfoRow('Đối tượng', n.objectLabel),
                InfoRow('Thời hạn', n.dueDate == null ? '' : '${fmtDateTime(n.dueDate!)} (${dueText(n.dueDate!)})'),
                InfoRow('Người chịu trách nhiệm', n.assignee),
                InfoRow('Hành động đề xuất', n.suggestedAction),
                InfoRow('Đã đọc', n.read ? 'Rồi' : 'Chưa'),
                InfoRow('Xử lý', n.resolved ? 'Đã xử lý' : 'Chưa xử lý'),
                if (n.resolved) InfoRow('Kết quả', n.resultNote),
                if (n.evidence.isNotEmpty) InfoRow('Minh chứng', n.evidence.join(', ')),
                const SizedBox(height: 6),
                const Text(
                  'Đã đọc không đồng nghĩa đã xử lý. Thông báo chỉ đóng khi điều kiện hoàn thành được đáp ứng.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (n.target != NotifTarget.none)
              FilledButton.icon(
                onPressed: () async {
                  await openNotificationTarget(context, n.target, n.targetId);
                  _reload();
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Mở nội dung liên quan'),
              ),
            const SizedBox(height: 10),
            if (!n.resolved)
              OutlinedButton.icon(
                onPressed: () => _resolve(n),
                icon: const Icon(Icons.task_alt),
                label: const Text('Xác nhận đã xử lý'),
              ),
          ],
        ),
      ),
    );
  }
}

class _ResolveSheet extends StatefulWidget {
  const _ResolveSheet();

  @override
  State<_ResolveSheet> createState() => _ResolveSheetState();
}

class _ResolveSheetState extends State<_ResolveSheet> {
  final _note = TextEditingController();
  final _files = <String>[];

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  bool get _valid => _note.text.trim().isNotEmpty && _files.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Xác nhận đã xử lý', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text(
            'Bắt buộc ghi kết quả và đính kèm ít nhất 1 minh chứng.',
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            maxLines: 3,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(labelText: 'Kết quả xử lý *'),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final f in _files)
                InputChip(label: Text(f), onDeleted: () => setState(() => _files.remove(f))),
              ActionChip(
                avatar: const Icon(Icons.add_a_photo_outlined, size: 18),
                label: const Text('Thêm minh chứng *'),
                // TODO: chọn ảnh / tệp thật.
                onPressed: () => setState(
                  () => _files.add('minh_chung_${DateTime.now().millisecondsSinceEpoch % 100000}.jpg'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _valid ? () => Navigator.pop(context, (_note.text.trim(), _files.toList())) : null,
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }
}
