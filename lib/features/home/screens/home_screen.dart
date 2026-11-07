import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/session/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../calendar/models/calendar_event.dart';
import '../../calendar/screens/calendar_screen.dart';
import '../../drills/screens/drill_hub_screen.dart';
import '../../equipment/models/equipment.dart';
import '../../equipment/screens/equipment_list_screen.dart';
import '../../equipment/screens/qr_scan_screen.dart';
import '../../facility/models/dossier.dart';
import '../../facility/screens/facility_hub_screen.dart';
import '../../notifications/models/app_notification.dart';
import '../../notifications/notification_router.dart';
import '../../profile/screens/facility_switch_screen.dart';
import '../../team/screens/team_hub_screen.dart';
import '../../training/screens/training_hub_screen.dart';

class _HomeData {
  _HomeData({
    required this.userName,
    required this.dossierTodo,
    required this.equipmentDue,
    required this.shiftsToday,
    required this.urgent,
    required this.upcoming,
  });

  final String userName;
  final int dossierTodo;
  final int equipmentDue;
  final int shiftsToday;
  final List<AppNotification> urgent;
  final List<CalendarEvent> upcoming;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onOpenTab});

  /// Chuyển sang tab khác của thanh điều hướng (0..4).
  final ValueChanged<int> onOpenTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<_HomeData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_HomeData> _load() async {
    final account = await Locator.profile.getAccount();
    final dossiers = await Locator.facility.getDossiers();
    final equipment = await Locator.equipment.getEquipment();
    final shifts = await Locator.team.getShifts();
    final notifications = await Locator.notifications.getNotifications();
    final events = await Locator.calendar.getEvents();

    final today = DateTime.now();
    return _HomeData(
      userName: account.name,
      dossierTodo: dossiers.where((d) => d.status.needsAction).length,
      equipmentDue: equipment
          .where(
            (e) =>
                e.status == EquipmentStatus.needRepair ||
                e.status == EquipmentStatus.needCheck ||
                daysFromToday(e.nextCheck) <= 7,
          )
          .length,
      shiftsToday: shifts.where((s) => sameDay(s.date, today)).length,
      urgent: notifications
          .where((n) => !n.resolved && n.priority == NotifPriority.high)
          .toList(),
      upcoming: events.where((e) {
        final d = daysFromToday(e.date);
        return d >= 0 && d <= 7;
      }).toList(),
    );
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AsyncBody<_HomeData>(
        future: _future,
        builder: (context, data) => RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _Header(userName: data.userName, onBell: () => widget.onOpenTab(3)),
              _buildStats(data),
              SectionHeader(
                'Cần xử lý ngay',
                actionLabel: 'Tất cả',
                onAction: () => widget.onOpenTab(3),
              ),
              if (data.urgent.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Không có việc khẩn cấp. Tốt lắm!',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              for (final n in data.urgent.take(3))
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: _UrgentTile(
                    notification: n,
                    onTap: () async {
                      await openNotificationTarget(context, n.target, n.targetId);
                      _reload();
                    },
                  ),
                ),
              SectionHeader(
                'Sắp diễn ra (7 ngày tới)',
                actionLabel: 'Mở lịch',
                onAction: () => widget.onOpenTab(2),
              ),
              if (data.upcoming.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Chưa có lịch trong 7 ngày tới',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              for (final e in data.upcoming.take(5))
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: EventTile(
                    event: e,
                    showDate: true,
                    onTap: () async {
                      await openEventTarget(context, e);
                      _reload();
                    },
                  ),
                ),
              const SectionHeader('Truy cập nhanh'),
              _buildQuickActions(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats(_HomeData data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.45,
        children: [
          StatCard(
            icon: Icons.description_outlined,
            label: 'Hồ sơ cần xử lý',
            value: '${data.dossierTodo}',
            color: AppColors.info,
            onTap: () => pushScreen(context, const FacilityHubScreen(initialTab: 2)),
          ),
          StatCard(
            icon: Icons.fire_extinguisher,
            label: 'Thiết bị cần kiểm tra / sửa',
            value: '${data.equipmentDue}',
            color: AppColors.warning,
            onTap: () => pushScreen(context, const EquipmentListScreen()),
          ),
          StatCard(
            icon: Icons.shield_outlined,
            label: 'Ca trực hôm nay',
            value: '${data.shiftsToday}',
            color: AppColors.primary,
            onTap: () => pushScreen(context, const TeamHubScreen(initialTab: 1)),
          ),
          StatCard(
            icon: Icons.warning_amber_rounded,
            label: 'Cảnh báo ưu tiên cao',
            value: '${data.urgent.length}',
            color: AppColors.danger,
            onTap: () => widget.onOpenTab(3),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = <(IconData, String, Widget)>[
      (Icons.business_outlined, 'Hồ sơ cơ sở', const FacilityHubScreen()),
      (Icons.groups_outlined, 'Đội PCCC', const TeamHubScreen()),
      (Icons.fire_extinguisher, 'Thiết bị', const EquipmentListScreen()),
      (Icons.school_outlined, 'Huấn luyện', const TrainingHubScreen()),
      (Icons.local_fire_department_outlined, 'Diễn tập', const DrillHubScreen()),
      (Icons.qr_code_scanner, 'Quét QR kiểm tra', const QrScanScreen()),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.05,
        children: [
          for (final a in actions)
            Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () async {
                  await pushScreen(context, a.$3);
                  _reload();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(a.$1, color: AppColors.primary, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        a.$2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.userName, required this.onBell});

  final String userName;
  final VoidCallback onBell;

  @override
  Widget build(BuildContext context) {
    final session = AppSession.instance;
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 12,
        8,
        20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fmtFullDate(DateTime.now()),
                      style: const TextStyle(color: AppColors.goldLight, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Xin chào, $userName',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onBell,
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Thẻ cơ sở đang quản lý, bấm để chuyển cơ sở
          ListenableBuilder(
            listenable: session,
            builder: (context, _) => Material(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => pushScreen(context, const FacilitySwitchScreen()),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.apartment, color: AppColors.gold),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cơ sở đang quản lý',
                              style: TextStyle(color: AppColors.goldLight, fontSize: 12),
                            ),
                            Text(
                              session.currentFacilityName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.swap_horiz, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UrgentTile extends StatelessWidget {
  const _UrgentTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = notification.category;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: c.color, width: 4)),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(c.icon, color: c.color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        StatusChip(label: c.label, color: c.color),
                        const SizedBox(width: 8),
                        Text(
                          timeAgo(notification.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
