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

  Future<void> _resolve(AppNotification n) async {
    final ok = await confirmDialog(
      context,
      title: 'Xác nhận đã xử lý',
      message: 'Chỉ xác nhận khi vấn đề đã thực sự được giải quyết '
          '(vd: thiết bị đã sửa xong, hồ sơ đã bổ sung).',
      confirmLabel: 'Đã xử lý',
    );
    if (!ok) return;
    await Locator.notifications.markResolved(n.id);
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
                InfoRow('Đã đọc', n.read ? 'Rồi' : 'Chưa'),
                InfoRow('Xử lý', n.resolved ? 'Đã xử lý' : 'Chưa xử lý'),
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
