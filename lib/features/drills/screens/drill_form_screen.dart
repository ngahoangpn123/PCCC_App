import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/form_fields.dart';
import '../models/drill.dart';

/// Lên kế hoạch một đợt thực tập / diễn tập từ một phương án.
class DrillFormScreen extends StatefulWidget {
  const DrillFormScreen({super.key, this.drill, this.presetScenarioId});

  final Drill? drill;
  final String? presetScenarioId;

  @override
  State<DrillFormScreen> createState() => _DrillFormScreenState();
}

class _DrillFormScreenState extends State<DrillFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.drill?.title ?? '');
  late final _participants = TextEditingController(text: widget.drill?.participants ?? '');
  late DateTime _date = widget.drill?.date ?? DateTime.now().add(const Duration(days: 14));
  late String? _scenarioId = widget.drill?.scenarioId ?? widget.presetScenarioId;
  List<Scenario> _scenarios = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    Locator.drills.getScenarios().then((list) {
      if (!mounted) return;
      setState(() {
        _scenarios = list;
        _scenarioId ??= list.isEmpty ? null : list.first.id;
        _loaded = true;
      });
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _participants.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final scenarioId = _scenarioId;
    if (scenarioId == null) {
      showSnack(context, 'Hãy tạo phương án trước');
      return;
    }
    final d = widget.drill ?? Drill(id: newId(), scenarioId: scenarioId, title: '', date: _date);
    d
      ..scenarioId = scenarioId
      ..title = _title.text.trim()
      ..date = _date
      ..participants = _participants.text.trim();
    await Locator.drills.saveDrill(d);
    if (!mounted) return;
    showSnack(context, 'Đã lưu kế hoạch diễn tập');
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.drill == null ? 'Lên kế hoạch diễn tập' : 'Sửa đợt diễn tập')),
      bottomNavigationBar: BottomActionBar(label: 'Lưu', onPressed: _loaded ? _save : null),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_scenarios.isNotEmpty)
                    DropdownField<String>(
                      label: 'Phương án',
                      value: _scenarioId ?? _scenarios.first.id,
                      items: _scenarios.map((s) => s.id).toList(),
                      labelOf: (id) {
                        final s = _scenarios.firstWhere((x) => x.id == id);
                        return '${s.code} · ${s.name}';
                      },
                      onChanged: (v) => setState(() => _scenarioId = v),
                    ),
                  AppTextField(label: 'Tên đợt thực tập / diễn tập', controller: _title, required: true),
                  DatePickerField(
                    label: 'Thời gian dự kiến',
                    value: _date,
                    required: true,
                    onChanged: (v) => setState(() => _date = v),
                  ),
                  AppTextField(label: 'Thành phần tham gia', controller: _participants, maxLines: 3),
                ],
              ),
            ),
    );
  }
}
