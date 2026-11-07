import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/choice_filter_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_chip.dart';
import '../models/app_notification.dart';
import 'notification_detail_screen.dart';

enum _StateFilter { pending, resolved, all }

/// Trung tâm thông báo và cảnh báo tự động.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, this.onChanged});

  /// Gọi khi số thông báo chưa đọc thay đổi (để cập nhật huy hiệu ở tab).
  final VoidCallback? onChanged;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<AppNotification>> _future;
  NotifCategory? _category;
  NotifPriority? _priority;
  _StateFilter _state = _StateFilter.pending;
  int _days = 0; // 0 = mọi thời gian

  @override
  void initState() {
    super.initState();
    _future = Locator.notifications.getNotifications();
  }

  void _reload() {
    setState(() => _future = Locator.notifications.getNotifications());
    widget.onChanged?.call();
  }

  Future<void> _markAllRead() async {
    await Locator.notifications.markAllRead();
    if (!mounted) return;
    showSnack(context, 'Đã đánh dấu tất cả là đã đọc (chưa phải đã xử lý)');
    _reload();
  }

  Future<void> _openFilters() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (c) => StatefulBuilder(
        builder: (c, setSheet) {
          void update(VoidCallback fn) {
            setSheet(fn);
            setState(() {});
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mức độ ưu tiên', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final p in <NotifPriority?>[null, ...NotifPriority.values])
                        ChoiceChip(
                          label: Text(p?.label ?? 'Tất cả'),
                          selected: _priority == p,
                          onSelected: (_) => update(() => _priority = p),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Thời gian', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final d in const [0, 1, 7, 30])
                        ChoiceChip(
                          label: Text(d == 0 ? 'Tất cả' : (d == 1 ? 'Hôm nay' : '$d ngày qua')),
                          selected: _days == d,
                          onSelected: (_) => update(() => _days = d),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          IconButton(
            tooltip: 'Bộ lọc',
            icon: Badge(
              isLabelVisible: _priority != null || _days != 0,
              smallSize: 8,
              child: const Icon(Icons.tune),
            ),
            onPressed: _openFilters,
          ),
          IconButton(
            tooltip: 'Đánh dấu tất cả đã đọc',
            icon: const Icon(Icons.done_all),
            onPressed: _markAllRead,
          ),
        ],
      ),
      body: AsyncBody<List<AppNotification>>(
        future: _future,
        builder: (context, all) {
          final now = DateTime.now();
          final list = all.where((n) {
            final okCat = _category == null || n.category == _category;
            final okPri = _priority == null || n.priority == _priority;
            final okState = switch (_state) {
              _StateFilter.pending => !n.resolved,
              _StateFilter.resolved => n.resolved,
              _StateFilter.all => true,
            };
            final okTime = _days == 0 || now.difference(n.createdAt).inDays < _days;
            return okCat && okPri && okState && okTime;
          }).toList()
            // Ưu tiên cao lên trước, rồi đến mới nhất.
            ..sort((a, b) {
              final p = a.priority.index.compareTo(b.priority.index);
              return p != 0 ? p : b.createdAt.compareTo(a.createdAt);
            });

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: SegmentedButton<_StateFilter>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: _StateFilter.pending, label: Text('Chưa xử lý')),
                    ButtonSegment(value: _StateFilter.resolved, label: Text('Đã xử lý')),
                    ButtonSegment(value: _StateFilter.all, label: Text('Tất cả')),
                  ],
                  selected: {_state},
                  onSelectionChanged: (v) => setState(() => _state = v.first),
                ),
              ),
              const SizedBox(height: 4),
              ChoiceFilterBar<NotifCategory?>(
                options: [null, ...NotifCategory.values],
                selected: _category,
                labelOf: (c) => c?.label ?? 'Tất cả loại',
                onSelected: (c) => setState(() => _category = c),
              ),
              Expanded(
                child: list.isEmpty
                    ? const EmptyState(icon: Icons.notifications_off_outlined, message: 'Không có thông báo')
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, i) => _NotificationCard(
                          n: list[i],
                          onTap: () async {
                            await Locator.notifications.markRead(list[i].id);
                            if (!context.mounted) return;
                            await pushScreen(context, NotificationDetailScreen(notificationId: list[i].id));
                            _reload();
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.n, required this.onTap});

  final AppNotification n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = n.category;
    return Card(
      clipBehavior: Clip.antiAlias,
      color: n.read ? Colors.white : AppColors.goldLight.withValues(alpha: 0.5),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: c.color.withValues(alpha: 0.14),
                child: Icon(c.icon, color: c.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n.title,
                            style: TextStyle(fontWeight: n.read ? FontWeight.w500 : FontWeight.w700),
                          ),
                        ),
                        if (!n.read)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      n.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    if (n.objectLabel.isNotEmpty || n.dueDate != null || n.assignee.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _Meta(Icons.inventory_2_outlined, n.objectLabel),
                      if (n.dueDate != null)
                        _Meta(Icons.event_outlined, 'Hạn: ${fmtDate(n.dueDate!)} (${dueText(n.dueDate!)})',
                            color: dueColor(n.dueDate!)),
                      _Meta(Icons.person_outline, n.assignee),
                      if (n.suggestedAction.isNotEmpty && !n.resolved)
                        _Meta(Icons.lightbulb_outline, n.suggestedAction, color: AppColors.primary),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        StatusChip(label: n.priority.label, color: n.priority.color),
                        if (n.resolved)
                          const StatusChip(label: 'Đã xử lý', color: AppColors.success, icon: Icons.check),
                        Text(timeAgo(n.createdAt),
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta(this.icon, this.text, {this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    final c = color ?? AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: c),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12.5, color: c))),
        ],
      ),
    );
  }
}
