import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/models/history_entry.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/form_fields.dart';
import '../models/member.dart';

class MemberFormScreen extends StatefulWidget {
  const MemberFormScreen({super.key, this.member});

  final Member? member;

  @override
  State<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends State<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.member?.name ?? '');
  late final _code = TextEditingController(text: widget.member?.code ?? '');
  late final _phone = TextEditingController(text: widget.member?.phone ?? '');
  late final _duty = TextEditingController(text: widget.member?.duty ?? '');
  late final _trainingNote = TextEditingController(
    text: widget.member?.trainingNote ?? 'Chưa có thông tin huấn luyện',
  );
  late String _role = widget.member?.role ?? 'Đội viên';
  late MemberStatus _status = widget.member?.status ?? MemberStatus.active;
  late bool _trainingOk = widget.member?.trainingOk ?? false;

  bool get _isEdit => widget.member != null;

  @override
  void dispose() {
    for (final c in [_name, _code, _phone, _duty, _trainingNote]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final old = widget.member;
    final m = old ??
        Member(
          id: newId(),
          code: '',
          name: '',
          phone: '',
          role: _role,
          duty: '',
          history: [HistoryEntry(time: now, actor: 'Bạn', action: 'Thêm vào đội')],
        );

    // Ghi lịch sử nếu đổi vai trò / nhiệm vụ / trạng thái.
    if (old != null) {
      if (old.role != _role) {
        m.history.add(HistoryEntry(time: now, actor: 'Bạn', action: 'Đổi chức vụ: ${old.role} → $_role'));
      }
      if (old.duty != _duty.text.trim()) {
        m.history.add(HistoryEntry(time: now, actor: 'Bạn', action: 'Đổi nhiệm vụ: ${_duty.text.trim()}'));
      }
      if (old.status != _status) {
        m.history.add(HistoryEntry(time: now, actor: 'Bạn', action: 'Đổi trạng thái: ${_status.label}'));
      }
    }

    m
      ..name = _name.text.trim()
      ..code = _code.text.trim()
      ..phone = _phone.text.trim()
      ..role = _role
      ..duty = _duty.text.trim()
      ..status = _status
      ..trainingOk = _trainingOk
      ..trainingNote = _trainingNote.text.trim();
    await Locator.team.saveMember(m);
    if (!mounted) return;
    showSnack(context, _isEdit ? 'Đã cập nhật thành viên' : 'Đã thêm thành viên');
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Sửa thành viên' : 'Thêm thành viên')),
      bottomNavigationBar: BottomActionBar(label: 'Lưu', onPressed: _save),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const FormSectionTitle('Thông tin cá nhân'),
            AppTextField(label: 'Họ và tên', controller: _name, required: true),
            AppTextField(label: 'Mã thành viên', controller: _code, required: true),
            AppTextField(label: 'Số điện thoại', controller: _phone, keyboardType: TextInputType.phone),
            const FormSectionTitle('Phân công'),
            DropdownField<String>(
              label: 'Chức vụ trong đội',
              value: _role,
              items: memberRoles,
              labelOf: (v) => v,
              onChanged: (v) => setState(() => _role = v),
            ),
            AppTextField(label: 'Nhiệm vụ được phân công', controller: _duty, maxLines: 2),
            DropdownField<MemberStatus>(
              label: 'Tình trạng',
              value: _status,
              items: MemberStatus.values,
              labelOf: (s) => s.label,
              onChanged: (v) => setState(() => _status = v),
            ),
            const FormSectionTitle('Huấn luyện'),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _trainingOk,
              title: const Text('Đã đáp ứng yêu cầu huấn luyện'),
              onChanged: (v) => setState(() => _trainingOk = v),
            ),
            AppTextField(label: 'Ghi chú huấn luyện, chứng nhận', controller: _trainingNote, maxLines: 2),
          ],
        ),
      ),
    );
  }
}
