import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/form_fields.dart';
import '../../../core/widgets/person_avatar.dart';
import '../models/user_account.dart';

/// Quản lý người được phân quyền theo vai trò.
class DelegationScreen extends StatefulWidget {
  const DelegationScreen({super.key});

  @override
  State<DelegationScreen> createState() => _DelegationScreenState();
}

class _DelegationScreenState extends State<DelegationScreen> {
  late Future<List<DelegatedUser>> _future = Locator.profile.getDelegates();

  // Quyền chính của từng vai trò (theo tài liệu thiết kế).
  static const _rolePermissions = {
    'Cán bộ phụ trách PCCC & CNCH': 'Cập nhật hồ sơ, lập kế hoạch, theo dõi công việc',
    'Đội trưởng đội PCCC & CNCH': 'Quản lý thành viên, lịch trực, huấn luyện',
    'Người phụ trách thiết bị': 'Kiểm tra, cập nhật tình trạng, bảo dưỡng thiết bị',
    'Người được giao nhiệm vụ': 'Xem và cập nhật tiến độ nhiệm vụ được giao',
  };

  void _reload() => setState(() => _future = Locator.profile.getDelegates());

  Future<void> _add() async {
    final name = TextEditingController();
    final scope = TextEditingController();
    String role = delegateRoles.first;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setDialog) => AlertDialog(
          title: const Text('Thêm người được phân quyền'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(label: 'Họ tên hoặc email', controller: name, required: true),
                DropdownField<String>(
                  label: 'Vai trò',
                  value: role,
                  items: delegateRoles,
                  labelOf: (v) => v,
                  onChanged: (v) => setDialog(() => role = v),
                ),
                AppTextField(label: 'Phạm vi được giao', controller: scope, maxLines: 2),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Hủy')),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Thêm')),
          ],
        ),
      ),
    );
    if (ok != true || name.text.trim().isEmpty) return;
    await Locator.profile.addDelegate(
      DelegatedUser(name: name.text.trim(), role: role, scope: scope.text.trim()),
    );
    _reload();
  }

  Future<void> _remove(DelegatedUser u) async {
    final ok = await confirmDialog(
      context,
      title: 'Thu hồi quyền',
      message: 'Thu hồi quyền của ${u.name}?',
      confirmLabel: 'Thu hồi',
    );
    if (!ok) return;
    await Locator.profile.removeDelegate(u);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phân quyền')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Thêm người'),
      ),
      body: AsyncBody<List<DelegatedUser>>(
        future: _future,
        builder: (context, list) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.goldLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Người được giao nhiệm vụ không mặc nhiên có quyền ký, phê duyệt hoặc '
                'thực hiện thủ tục chính thức thay người đứng đầu.',
                style: TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(height: 12),
            for (final u in list)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: ListTile(
                    leading: PersonAvatar(u.name),
                    title: Text(u.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${u.role}\nPhạm vi: ${u.scope.isEmpty ? '—' : u.scope}'),
                    isThreeLine: true,
                    trailing: IconButton(
                      tooltip: 'Thu hồi quyền',
                      icon: const Icon(Icons.remove_circle_outline, color: AppColors.danger),
                      onPressed: () => _remove(u),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            const Text('Quyền theo vai trò', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  for (final e in _rolePermissions.entries)
                    ListTile(
                      dense: true,
                      title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(e.value),
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
