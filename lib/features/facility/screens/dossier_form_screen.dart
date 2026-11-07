import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/models/history_entry.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/form_fields.dart';
import '../models/dossier.dart';
import '../models/form_template.dart';

/// Tạo mới (dossier == null) hoặc sửa hồ sơ.
class DossierFormScreen extends StatefulWidget {
  const DossierFormScreen({super.key, this.dossier, this.presetFormCode});

  final Dossier? dossier;
  final String? presetFormCode;

  @override
  State<DossierFormScreen> createState() => _DossierFormScreenState();
}

class _DossierFormScreenState extends State<DossierFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.dossier?.title ?? '');
  late final _owner = TextEditingController(text: widget.dossier?.owner ?? '');
  late final _note = TextEditingController(text: widget.dossier?.note ?? '');
  late DateTime? _due = widget.dossier?.dueDate;
  late String? _formCode = widget.dossier?.formCode ?? widget.presetFormCode;
  late String _retention = widget.dossier?.retention ?? '05 năm';
  List<FormTemplate> _templates = [];

  bool get _isEdit => widget.dossier != null;

  String _templateRetention(String code) {
    final r = _templates.where((t) => t.code == code).firstOrNull?.retention ?? '05 năm';
    return retentionOptions.contains(r) ? r : '05 năm';
  }

  @override
  void initState() {
    super.initState();
    Locator.facility.getFormTemplates().then((list) {
      if (!mounted) return;
      setState(() {
        _templates = list;
        _formCode ??= list.first.code;
        if (widget.dossier == null) _retention = _templateRetention(_formCode!);
      });
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _owner.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final code = _formCode;
    if (code == null) return;
    final now = DateTime.now();
    final d = widget.dossier ??
        Dossier(
          id: newId(),
          formCode: code,
          title: '',
          owner: '',
          status: DossierStatus.draft,
          updatedAt: now,
          history: [HistoryEntry(time: now, actor: 'Bạn', action: 'Tạo bản nháp')],
        );
    d
      ..formCode = code
      ..title = _title.text.trim()
      ..owner = _owner.text.trim()
      ..note = _note.text.trim()
      ..dueDate = _due
      ..retention = _retention
      ..updatedAt = now;
    if (_isEdit) {
      d.history.add(HistoryEntry(time: now, actor: 'Bạn', action: 'Cập nhật nội dung'));
    }
    await Locator.facility.saveDossier(d);
    if (!mounted) return;
    showSnack(context, _isEdit ? 'Đã cập nhật hồ sơ' : 'Đã tạo bản nháp hồ sơ');
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Sửa hồ sơ' : 'Tạo hồ sơ')),
      bottomNavigationBar: BottomActionBar(
        label: _isEdit ? 'Lưu thay đổi' : 'Lưu bản nháp',
        onPressed: _templates.isEmpty ? null : _save,
      ),
      body: _templates.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  DropdownField<String>(
                    label: 'Biểu mẫu',
                    value: _formCode ?? _templates.first.code,
                    items: _templates.map((t) => t.code).toList(),
                    labelOf: (c) {
                      final t = _templates.firstWhere((t) => t.code == c);
                      return '$c – ${t.name}';
                    },
                    onChanged: (v) => setState(() {
                      _formCode = v;
                      if (!_isEdit) _retention = _templateRetention(v);
                    }),
                  ),
                  AppTextField(label: 'Tên hồ sơ', controller: _title, required: true),
                  AppTextField(label: 'Người phụ trách', controller: _owner, required: true),
                  DatePickerField(
                    label: 'Ngày đến hạn',
                    value: _due,
                    onChanged: (v) => setState(() => _due = v),
                  ),
                  DropdownField<String>(
                    key: ValueKey(_retention),
                    label: 'Thời hạn lưu trữ',
                    value: _retention,
                    items: retentionOptions,
                    labelOf: (r) => r,
                    onChanged: (v) => setState(() => _retention = v),
                  ),
                  AppTextField(label: 'Ghi chú', controller: _note, maxLines: 3),
                  const Text(
                    'Các trường riêng của từng biểu mẫu sẽ được bổ sung khi có '
                    'nội dung chính thức của mẫu.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
    );
  }
}
