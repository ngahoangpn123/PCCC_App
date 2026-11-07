import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/form_fields.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _agree = false;
  bool _loading = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_password.text != _confirm.text) {
      showSnack(context, 'Mật khẩu nhập lại không khớp');
      return;
    }
    if (!_agree) {
      showSnack(context, 'Vui lòng đồng ý điều khoản sử dụng');
      return;
    }
    setState(() => _loading = true);
    final error = await Locator.auth.signUp(
      _name.text.trim(),
      _email.text.trim(),
      _phone.text.trim(),
      _password.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      showSnack(context, error);
      return;
    }
    showSnack(context, 'Đăng ký thành công. Vui lòng kiểm tra email xác nhận.');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký tài khoản')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppTextField(label: 'Họ và tên', controller: _name, required: true),
            AppTextField(
              label: 'Email',
              controller: _email,
              required: true,
              keyboardType: TextInputType.emailAddress,
            ),
            AppTextField(
              label: 'Số điện thoại',
              controller: _phone,
              keyboardType: TextInputType.phone,
            ),
            AppTextField(
              label: 'Mật khẩu',
              controller: _password,
              required: true,
              obscure: true,
            ),
            AppTextField(
              label: 'Nhập lại mật khẩu',
              controller: _confirm,
              required: true,
              obscure: true,
            ),
            CheckboxListTile(
              value: _agree,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text(
                'Tôi đồng ý với điều khoản sử dụng và chính sách bảo vệ dữ liệu cá nhân',
              ),
              onChanged: (v) => setState(() => _agree = v ?? false),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: Text(_loading ? 'Đang xử lý...' : 'Đăng ký'),
            ),
          ],
        ),
      ),
    );
  }
}
