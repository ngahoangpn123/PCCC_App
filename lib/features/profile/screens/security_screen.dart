import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/form_fields.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _twoFactor = false;

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _changePassword() {
    if (!_formKey.currentState!.validate()) return;
    if (_new.text.length < 6) {
      showSnack(context, 'Mật khẩu mới tối thiểu 6 ký tự');
      return;
    }
    if (_new.text != _confirm.text) {
      showSnack(context, 'Mật khẩu nhập lại không khớp');
      return;
    }
    showComingSoon(context, 'Đổi mật khẩu');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bảo mật & đăng nhập')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const FormSectionTitle('Đổi mật khẩu'),
          Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(label: 'Mật khẩu hiện tại', controller: _current, required: true, obscure: true),
                AppTextField(label: 'Mật khẩu mới', controller: _new, required: true, obscure: true),
                AppTextField(label: 'Nhập lại mật khẩu mới', controller: _confirm, required: true, obscure: true),
              ],
            ),
          ),
          FilledButton(onPressed: _changePassword, child: const Text('Đổi mật khẩu')),
          const SizedBox(height: 20),
          const FormSectionTitle('Xác thực'),
          Card(
            child: SwitchListTile(
              title: const Text('Xác thực hai bước'),
              subtitle: const Text('Nhập thêm mã gửi qua email khi đăng nhập'),
              value: _twoFactor,
              onChanged: (v) => setState(() => _twoFactor = v),
            ),
          ),
          const SizedBox(height: 20),
          const FormSectionTitle('Thiết bị đang đăng nhập'),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.phone_android, color: AppColors.primary),
                  title: Text('Điện thoại Android (thiết bị này)'),
                  subtitle: Text('Đang hoạt động'),
                ),
                const Divider(indent: 56),
                ListTile(
                  leading: const Icon(Icons.laptop, color: AppColors.neutral),
                  title: const Text('Trình duyệt máy tính'),
                  subtitle: const Text('Hoạt động 3 ngày trước'),
                  trailing: TextButton(
                    onPressed: () => showComingSoon(context, 'Đăng xuất thiết bị khác'),
                    child: const Text('Đăng xuất'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
