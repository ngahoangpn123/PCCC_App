import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/form_fields.dart';
import '../models/user_account.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  late final Future<UserAccount> _future = Locator.profile.getAccount().then((a) {
    _name.text = a.name;
    _phone.text = a.phone;
    _email.text = a.email;
    return a;
  });

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save(UserAccount a) async {
    if (!_formKey.currentState!.validate()) return;
    a
      ..name = _name.text.trim()
      ..phone = _phone.text.trim();
    await Locator.profile.saveAccount(a);
    if (!mounted) return;
    showSnack(context, 'Đã lưu thông tin tài khoản');
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBody<UserAccount>(
      future: _future,
      builder: (context, a) => Scaffold(
        appBar: AppBar(title: const Text('Thông tin tài khoản')),
        bottomNavigationBar: BottomActionBar(label: 'Lưu', onPressed: () => _save(a)),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppTextField(label: 'Họ và tên', controller: _name, required: true),
              AppTextField(label: 'Số điện thoại', controller: _phone, keyboardType: TextInputType.phone),
              AppTextField(label: 'Email đăng nhập', controller: _email, readOnly: true),
              InputDecorator(
                decoration: const InputDecoration(labelText: 'Vai trò'),
                child: Text(a.role),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
