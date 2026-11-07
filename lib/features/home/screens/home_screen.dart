import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/session/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_chip.dart';
import '../../acceptance/models/acceptance.dart';
import '../../acceptance/screens/acceptance_hub_screen.dart';
import '../../acceptance/screens/pc01_declaration_screen.dart';
import '../../calendar/models/calendar_event.dart';
import '../../calendar/screens/calendar_screen.dart';
import '../../equipment/models/equipment.dart';
import '../../equipment/screens/qr_scan_screen.dart';
import '../../facility/screens/dossier_form_screen.dart';
import '../../management/management_modules.dart';
import '../../notifications/models/app_notification.dart';
import '../../notifications/notification_router.dart';
import '../../profile/screens/facility_switch_screen.dart';
import '../../team/screens/shift_form_screen.dart';
import '../../training/screens/training_session_form_screen.dart';

class _HomeData {
  _HomeData({
    required this.userName,
    required this.dossierTodo,
    required this.equipmentDue,
    required this.shiftsToday,
    required this.urgent,
    required this.upcoming,
    required this.acceptance,
    required this.needsAcceptance,
    required this.pc01,
    required this.readiness,
  });

  final String userName;
  final int dossierTodo;
  final int equipmentDue;
  final int shiftsToday;
  final List<AppNotification> urgent;
  final List<CalendarEvent> upcoming;
  final ProjectAcceptance? acceptance;
  final bool needsAcceptance; // cơ sở đang thi công / cải tạo
  final Pc01Declaration pc01;
  final ReadinessSummary readiness;

  int get todoCount => urgent.length + dossierTodo + equipmentDue;

  bool get pc18Missing => needsAcceptance && !(acceptance?.pc18Signed ?? false);
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
    final facility = await Locator.facility.getFacility(AppSession.instance.currentFacilityId);
    final acceptance = await Locator.acceptance.getAcceptance();
    final pc01 = await Locator.acceptance.getPc01();
    final readiness = await Locator.acceptance.getReadinessSummary();

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
      acceptance: acceptance,
      needsAcceptance: facility.hasConstruction,
      pc01: pc01,
      readiness: readiness,
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
              _LegalStatusBar(
                data: data,
                onTap: () async {
                  await pushScreen(context, const AcceptanceHubScreen());
                  _reload();
                },
                onPc01: () async {
                  await pushScreen(context, const Pc01DeclarationScreen());
                  _reload();
                },
              ),
              if (data.pc18Missing)
                _Pc18Banner(
                  acceptance: data.acceptance,
                  onTap: () async {
                    await pushScreen(context, const AcceptanceHubScreen());
                    _reload();
                  },
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  onPressed: _openCreateSheet,
                  icon: const Icon(Icons.add),
                  label: const Text('Tạo nhiệm vụ mới / Khởi tạo tự nghiệm thu'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 8, 8),
                child: Row(
                  children: [
                    const Text(
                      'Cần xử lý ngay',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    if (data.todoCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${data.todoCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => widget.onOpenTab(3),
                      child: const Text('Xem tất cả công việc'),
                    ),
                  ],
                ),
              ),
              if (data.urgent.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Không có việc khẩn cấp. Tốt lắm!',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              for (final n in data.urgent.take(4))
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _MiniCount('Hồ sơ cần xử lý', data.dossierTodo, AppColors.info),
                    _MiniCount('Thiết bị cần kiểm tra', data.equipmentDue, AppColors.warning),
                    _MiniCount('Ca trực hôm nay', data.shiftsToday, AppColors.primary),
                  ],
                ),
              ),
              const SectionHeader('Danh mục quản lý'),
              _buildModules(),
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openCreateSheet() async {
    final items = <(IconData, String, Widget Function())>[
      (Icons.fact_check_outlined, 'Khởi tạo tự nghiệm thu (PC18)', () => const AcceptanceHubScreen()),
      (Icons.description_outlined, 'Tạo hồ sơ theo biểu mẫu', () => const DossierFormScreen()),
      (Icons.checklist, 'Lập biên bản tự kiểm tra PC02',
          () => const DossierFormScreen(presetFormCode: 'PC02')),
      (Icons.shield_outlined, 'Phân công ca trực', () => const ShiftFormScreen()),
      (Icons.school_outlined, 'Lên lịch huấn luyện', () => const TrainingSessionFormScreen()),
      (Icons.qr_code_scanner, 'Quét QR kiểm tra thiết bị', () => const QrScanScreen()),
    ];
    final picked = await showModalBottomSheet<Widget Function()>(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text('Tạo mới', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            for (final (icon, label, builder) in items)
              ListTile(
                leading: Icon(icon, color: AppColors.primary),
                title: Text(label),
                onTap: () => Navigator.pop(c, builder),
              ),
          ],
        ),
      ),
    );
    if (picked == null || !mounted) return;
    await pushScreen(context, picked());
    _reload();
  }

  Widget _buildModules() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.95,
        children: [
          for (final m in managementModules)
            Card(
              clipBehavior: Clip.antiAlias,
              color: m.highlight ? AppColors.primary : null,
              child: InkWell(
                onTap: () async {
                  await pushScreen(context, m.builder());
                  _reload();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(m.icon, color: m.highlight ? Colors.white : AppColors.primary, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        m.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: m.highlight ? Colors.white : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => pushScreen(context, const QrScanScreen()),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 28),
                    SizedBox(height: 8),
                    Text(
                      'Quét QR kiểm tra',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => widget.onOpenTab(2),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_month_outlined, color: AppColors.primary, size: 28),
                    SizedBox(height: 8),
                    Text(
                      'Lịch hoạt động',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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

/// Thanh trạng thái pháp lý: PC18 · PC01 · Điểm sẵn sàng hậu kiểm.
class _LegalStatusBar extends StatelessWidget {
  const _LegalStatusBar({required this.data, required this.onTap, required this.onPc01});

  final _HomeData data;
  final VoidCallback onTap;
  final VoidCallback onPc01;

  @override
  Widget build(BuildContext context) {
    final acc = data.acceptance;
    final (pc18Text, pc18Color) = !data.needsAcceptance && acc == null
        ? ('Không áp dụng', AppColors.neutral)
        : acc?.synced == true
            ? ('Đã khai báo', AppColors.success)
            : acc?.pc18Signed == true
                ? ('Đã ký', AppColors.info)
                : ('Bước ${acc?.doneSteps ?? 0}/6', AppColors.danger);
    final score = data.readiness.score;
    final scoreColor = score >= 90
        ? AppColors.success
        : score >= 70
            ? AppColors.warning
            : AppColors.danger;
    Widget cell(String label, String value, Color color, VoidCallback onTap) => Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Column(
            children: [
              Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 13.5),
              ),
            ],
          ),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              cell('Nghiệm thu PC18', pc18Text, pc18Color, onTap),
              const SizedBox(height: 36, child: VerticalDivider()),
              cell('Khai báo PC01', data.pc01.status.label, data.pc01.status.color, onPc01),
              const SizedBox(height: 36, child: VerticalDivider()),
              cell('Sẵn sàng hậu kiểm', '$score%', scoreColor, onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pc18Banner extends StatelessWidget {
  const _Pc18Banner({required this.acceptance, required this.onTap});

  final ProjectAcceptance? acceptance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Material(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.gpp_maybe_outlined, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    acceptance == null
                        ? 'Cơ sở đang thi công / cải tạo nhưng chưa khởi tạo tự nghiệm thu PC18.'
                        : 'Chưa hoàn thành tự nghiệm thu PC18 – chưa được đưa '
                            '"${acceptance!.projectName}" vào sử dụng.',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniCount extends StatelessWidget {
  const _MiniCount(this.label, this.count, this.color);

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) => StatusChip(label: '$label: $count', color: color);
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
