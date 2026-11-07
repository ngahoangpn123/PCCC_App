import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/info_section.dart';
import '../models/user_account.dart';

/// Cài đặt chữ ký số dùng để ký PC18, PC01, PC06...
/// TODO: tích hợp nhà cung cấp chữ ký số (USB token / ký số từ xa / VNeID).
class SignatureScreen extends StatefulWidget {
  const SignatureScreen({super.key});

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  late final Future<SignatureSettings> _future = Locator.profile.getSignature();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chữ ký số')),
      body: AsyncBody<SignatureSettings>(
        future: _future,
        builder: (context, s) {
          final linked = s.serial.isNotEmpty;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  leading: Icon(
                    linked ? Icons.verified_user : Icons.gpp_maybe_outlined,
                    color: linked ? AppColors.success : AppColors.warning,
                    size: 32,
                  ),
                  title: Text(linked ? 'Đã liên kết chứng thư số' : 'Chưa liên kết chữ ký số'),
                  subtitle: Text(linked
                      ? '${s.provider} · ${s.serial}'
                      : 'Cần liên kết để ký PC18, PC01, PC06 trên ứng dụng'),
                ),
              ),
              const SizedBox(height: 12),
              InfoSection(
                title: 'Chứng thư số',
                icon: Icons.badge_outlined,
                children: [
                  InfoRow('Nhà cung cấp', s.provider),
                  InfoRow('Số serial', s.serial),
                  InfoRow('Hiệu lực đến', s.validUntil == null ? '' : fmtDate(s.validUntil!)),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: s.pinOnSign,
                    title: const Text('Yêu cầu nhập PIN mỗi lần ký'),
                    onChanged: (v) async {
                      setState(() => s.pinOnSign = v);
                      await Locator.profile.saveSignature(s);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => showComingSoon(context, 'Liên kết chữ ký số'),
                icon: const Icon(Icons.link),
                label: Text(linked ? 'Đổi chứng thư số' : 'Liên kết chữ ký số'),
              ),
            ],
          );
        },
      ),
    );
  }
}
