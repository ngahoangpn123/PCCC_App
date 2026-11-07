import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/session/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/person_avatar.dart';
import '../../auth/screens/login_screen.dart';
import '../models/user_account.dart';
import 'account_info_screen.dart';
import 'activity_log_screen.dart';
import 'delegation_screen.dart';
import 'facility_switch_screen.dart';
import 'help_screen.dart';
import 'notification_settings_screen.dart';
import 'security_screen.dart';
import 'signature_screen.dart';

/// Tab "Cá nhân".
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserAccount> _future = Locator.profile.getAccount();

  Future<void> _open(Widget screen) async {
    await pushScreen(context, screen);
    setState(() => _future = Locator.profile.getAccount());
  }

  Future<void> _logout() async {
    final ok = await confirmDialog(
      context,
      title: 'Đăng xuất',
      message: 'Bạn có chắc muốn đăng xuất?',
      confirmLabel: 'Đăng xuất',
    );
    if (!ok) return;
    await Locator.auth.signOut();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cá nhân')),
      body: AsyncBody<UserAccount>(
        future: _future,
        builder: (context, a) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    PersonAvatar(a.name, radius: 30),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          Text(a.role, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600)),
                          Text(a.email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ListenableBuilder(
              listenable: AppSession.instance,
              builder: (context, _) => Card(
                child: ListTile(
                  leading: const Icon(Icons.apartment, color: AppColors.primary),
                  title: const Text('Cơ sở đang quản lý'),
                  subtitle: Text(AppSession.instance.currentFacilityName),
                  trailing: const Text('Đổi', style: TextStyle(color: AppColors.primary)),
                  onTap: () => _open(const FacilitySwitchScreen()),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  _MenuTile(Icons.person_outline, 'Thông tin tài khoản', () => _open(const AccountInfoScreen())),
                  _MenuTile(Icons.admin_panel_settings_outlined, 'Quản lý người được phân quyền',
                      () => _open(const DelegationScreen())),
                  _MenuTile(Icons.notifications_active_outlined, 'Cài đặt thông báo',
                      () => _open(const NotificationSettingsScreen())),
                  _MenuTile(Icons.draw_outlined, 'Chữ ký số', () => _open(const SignatureScreen())),
                  _MenuTile(Icons.lock_outline, 'Bảo mật & đăng nhập', () => _open(const SecurityScreen())),
                  _MenuTile(Icons.history, 'Nhật ký hoạt động (Audit Log)', () => _open(const ActivityLogScreen())),
                  _MenuTile(Icons.help_outline, 'Hướng dẫn, hỗ trợ & phản hồi', () => _open(const HelpScreen()),
                      showDivider: false),
                ],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
              ),
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Đăng xuất'),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text('Phiên bản 0.1.0 (giao diện)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile(this.icon, this.title, this.onTap, {this.showDivider = true});

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
        if (showDivider) const Divider(indent: 56),
      ],
    );
  }
}
