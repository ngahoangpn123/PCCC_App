import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/form_fields.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final error = await Locator.auth.sendResetPassword(_email.text.trim());
    if (!mounted) return;
    if (error != null) {
      showSnack(context, error);
      return;
    }
    setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quên mật khẩu')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _sent
            ? Column(
                children: [
                  const SizedBox(height: 40),
                  const Icon(
                    Icons.mark_email_read_outlined,
                    size: 64,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Đã gửi hướng dẫn đặt lại mật khẩu đến ${_email.text}.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Quay lại đăng nhập'),
                  ),
                ],
              )
            : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Nhập email đã đăng ký, chúng tôi sẽ gửi đường dẫn đặt lại mật khẩu.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      label: 'Email',
                      controller: _email,
                      required: true,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    FilledButton(
                      onPressed: _submit,
                      child: const Text('Gửi hướng dẫn'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
