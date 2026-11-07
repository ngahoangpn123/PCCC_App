import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/form_fields.dart';
import '../models/member.dart';
import '../models/shift.dart';

/// Tạo / sửa ca trực. Có cảnh báo khi thiếu người hoặc xếp trùng lịch.
class ShiftFormScreen extends StatefulWidget {
  const ShiftFormScreen({super.key, this.shift, this.initialDate});

  final Shift? shift;
  final DateTime? initialDate;

  @override
  State<ShiftFormScreen> createState() => _ShiftFormScreenState();
}

class _ShiftFormScreenState extends State<ShiftFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _location = TextEditingController(text: widget.shift?.location ?? '');
  late final _required = TextEditingController(text: '${widget.shift?.requiredCount ?? 3}');
  late DateTime _date = widget.shift?.date ?? widget.initialDate ?? dateOnly(DateTime.now());
  late String _start = widget.shift?.start ?? '07:00';
  late String _end = widget.shift?.end ?? '19:00';
  late final Set<String> _memberIds = {...?widget.shift?.memberIds};
  late String? _leaderId = widget.shift?.leaderId;

  List<Member> _members = [];
  List<Shift> _otherShifts = [];

  bool get _isEdit => widget.shift != null;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final members = await Locator.team.getMembers();
    final shifts = await Locator.team.getShifts();
    if (!mounted) return;
    setState(() {
      // Chỉ cho chọn người còn trong đội.
      _members = members.where((m) => m.status != MemberStatus.left).toList();
      _otherShifts = shifts.where((s) => s.id != widget.shift?.id).toList();
    });
  }

  @override
  void dispose() {
    _location.dispose();
    _required.dispose();
    super.dispose();
  }

  /// Những người đã có ca khác trong cùng ngày.
  Set<String> get _conflicts {
    final ids = <String>{};
    for (final s in _otherShifts.where((s) => sameDay(s.date, _date))) {
      ids.addAll(s.memberIds.where(_memberIds.contains));
    }
    return ids;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_memberIds.isEmpty) {
      showSnack(context, 'Hãy chọn ít nhất 1 thành viên');
      return;
    }
    final requiredCount = int.tryParse(_required.text.trim()) ?? 1;
    if (_conflicts.isNotEmpty) {
      final ok = await confirmDialog(
        context,
        title: 'Lịch bị trùng',
        message: 'Có ${_conflicts.length} người đã có ca khác trong ngày này. Vẫn lưu?',
        confirmLabel: 'Vẫn lưu',
      );
      if (!ok) return;
    }
    final leader = _leaderId != null && _memberIds.contains(_leaderId) ? _leaderId! : _memberIds.first;
    final s = widget.shift ??
        Shift(
          id: newId(),
          date: _date,
          start: _start,
          end: _end,
          location: '',
          leaderId: leader,
          memberIds: [],
          requiredCount: requiredCount,
        );
    s
      ..date = _date
      ..start = _start
      ..end = _end
      ..location = _location.text.trim()
      ..leaderId = leader
      ..memberIds = _memberIds.toList()
      ..requiredCount = requiredCount
      ..confirmedIds = s.confirmedIds.where(_memberIds.contains).toList();
    await Locator.team.saveShift(s);
    if (!mounted) return;
    showSnack(context, _isEdit ? 'Đã cập nhật ca trực' : 'Đã tạo ca trực');
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final conflicts = _conflicts;
    final requiredCount = int.tryParse(_required.text) ?? 0;
    final selectedMembers = _members.where((m) => _memberIds.contains(m.id)).toList();

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Sửa ca trực' : 'Tạo lịch trực')),
      bottomNavigationBar: BottomActionBar(label: 'Lưu ca trực', onPressed: _save),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const FormSectionTitle('Thời gian & địa điểm'),
            DatePickerField(label: 'Ngày trực', value: _date, required: true, onChanged: (v) => setState(() => _date = v)),
            Row(
              children: [
                Expanded(child: TimePickerField(label: 'Bắt đầu', value: _start, onChanged: (v) => setState(() => _start = v))),
                const SizedBox(width: 12),
                Expanded(child: TimePickerField(label: 'Kết thúc', value: _end, onChanged: (v) => setState(() => _end = v))),
              ],
            ),
            AppTextField(label: 'Địa điểm trực', controller: _location, required: true),
            const FormSectionTitle('Quân số'),
            AppTextField(
              label: 'Quân số cần có',
              controller: _required,
              required: true,
              keyboardType: TextInputType.number,
              hint: 'Thiết lập theo quy định và đặc điểm cơ sở',
            ),
            Text(
              'Đã chọn ${_memberIds.length}/$requiredCount người',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: _memberIds.length < requiredCount ? AppColors.danger : AppColors.success,
              ),
            ),
            const SizedBox(height: 8),
            if (_members.isEmpty)
              const Center(child: CircularProgressIndicator())
            else
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final m in _members)
                    FilterChip(
                      label: Text(m.status == MemberStatus.away ? '${m.name} (vắng)' : m.name),
                      selected: _memberIds.contains(m.id),
                      avatar: conflicts.contains(m.id)
                          ? const Icon(Icons.warning, size: 16, color: AppColors.danger)
                          : null,
                      onSelected: (v) => setState(() {
                        if (v) {
                          _memberIds.add(m.id);
                        } else {
                          _memberIds.remove(m.id);
                        }
                      }),
                    ),
                ],
              ),
            if (conflicts.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Cảnh báo: ${conflicts.length} người đã có ca khác trong ngày ${fmtDate(_date)}.',
                  style: const TextStyle(color: AppColors.danger),
                ),
              ),
            const SizedBox(height: 16),
            if (selectedMembers.isNotEmpty)
              DropdownField<String>(
                key: ValueKey(selectedMembers.map((m) => m.id).join(',')),
                label: 'Người phụ trách ca',
                value: _memberIds.contains(_leaderId) ? _leaderId! : selectedMembers.first.id,
                items: selectedMembers.map((m) => m.id).toList(),
                labelOf: (id) => selectedMembers.firstWhere((m) => m.id == id).name,
                onChanged: (v) => setState(() => _leaderId = v),
              ),
          ],
        ),
      ),
    );
  }
}
