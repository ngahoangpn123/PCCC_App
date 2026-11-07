import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/form_fields.dart';
import '../models/user_account.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  late final Future<NotificationSettings> _future = Locator.profile.getSettings();

  static const _remindOptions = [1, 3, 7, 14, 30];

  Future<void> _save(NotificationSettings s) async {
    await Locator.profile.saveSettings(s);
    if (!mounted) return;
    showSnack(context, 'Đã lưu cài đặt thông báo');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBody<NotificationSettings>(
      future: _future,
      builder: (context, s) => Scaffold(
        appBar: AppBar(title: const Text('Cài đặt thông báo')),
        bottomNavigationBar: BottomActionBar(label: 'Lưu cài đặt', onPressed: () => _save(s)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const FormSectionTitle('Kênh nhận'),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Thông báo đẩy trên điện thoại'),
                    value: s.push,
                    onChanged: (v) => setState(() => s.push = v),
                  ),
                  SwitchListTile(
                    title: const Text('Thông báo trong ứng dụng'),
                    value: s.inApp,
                    onChanged: (v) => setState(() => s.inApp = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const FormSectionTitle('Nhắc hạn'),
            DropdownField<int>(
              label: 'Nhắc trước hạn',
              value: s.remindDaysBefore,
              items: _remindOptions,
              labelOf: (d) => '$d ngày',
              onChanged: (v) => setState(() => s.remindDaysBefore = v),
            ),
            Card(
              child: SwitchListTile(
                title: const Text('Nhắc lại khi quá hạn'),
                value: s.remindOverdue,
                onChanged: (v) => setState(() => s.remindOverdue = v),
              ),
            ),
            const SizedBox(height: 12),
            const FormSectionTitle('Loại thông báo'),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Khẩn cấp'),
                    subtitle: const Text('Luôn nên bật'),
                    value: s.urgent,
                    onChanged: (v) => setState(() => s.urgent = v),
                  ),
                  SwitchListTile(
                    title: const Text('Sắp đến hạn'),
                    value: s.upcoming,
                    onChanged: (v) => setState(() => s.upcoming = v),
                  ),
                  SwitchListTile(
                    title: const Text('Hồ sơ & thủ tục'),
                    value: s.dossier,
                    onChanged: (v) => setState(() => s.dossier = v),
                  ),
                  SwitchListTile(
                    title: const Text('Lịch & phân công'),
                    value: s.schedule,
                    onChanged: (v) => setState(() => s.schedule = v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
