import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/form_fields.dart';
import '../models/drill.dart';

class ScenarioFormScreen extends StatefulWidget {
  const ScenarioFormScreen({super.key, this.scenario});

  final Scenario? scenario;

  @override
  State<ScenarioFormScreen> createState() => _ScenarioFormScreenState();
}

class _ScenarioFormScreenState extends State<ScenarioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _code = TextEditingController(text: widget.scenario?.code ?? '');
  late final _name = TextEditingController(text: widget.scenario?.name ?? '');
  late final _objective = TextEditingController(text: widget.scenario?.objective ?? '');
  late final _scope = TextEditingController(text: widget.scenario?.scope ?? '');
  late final _location = TextEditingController(text: widget.scenario?.location ?? '');
  late final _commander = TextEditingController(text: widget.scenario?.commander ?? '');
  late final _forces = TextEditingController(text: widget.scenario?.forces.join('\n') ?? '');
  late final _equipment = TextEditingController(text: widget.scenario?.equipment.join('\n') ?? '');
  late final _steps = TextEditingController(text: widget.scenario?.steps.join('\n') ?? '');
  late String _type = widget.scenario?.type ?? scenarioTypes.first;
  late String _formType = widget.scenario?.formType ?? scenarioForms.first;

  @override
  void dispose() {
    for (final c in [_code, _name, _objective, _scope, _location, _commander, _forces, _equipment, _steps]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Mỗi dòng là một mục.
  List<String> _lines(TextEditingController c) =>
      c.text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final sc = widget.scenario ??
        Scenario(
          id: newId(),
          code: '',
          name: '',
          type: _type,
          objective: '',
          scope: '',
          location: '',
          commander: '',
        );
    sc
      ..code = _code.text.trim()
      ..name = _name.text.trim()
      ..type = _type
      ..formType = _formType
      ..objective = _objective.text.trim()
      ..scope = _scope.text.trim()
      ..location = _location.text.trim()
      ..commander = _commander.text.trim()
      ..forces = _lines(_forces)
      ..equipment = _lines(_equipment)
      ..steps = _lines(_steps);
    await Locator.drills.saveScenario(sc);
    if (!mounted) return;
    showSnack(context, 'Đã lưu phương án');
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.scenario == null ? 'Thêm phương án' : 'Sửa phương án')),
      bottomNavigationBar: BottomActionBar(label: 'Lưu phương án', onPressed: _save),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const FormSectionTitle('Thông tin chung'),
            AppTextField(label: 'Mã phương án', controller: _code, required: true),
            AppTextField(label: 'Tên phương án', controller: _name, required: true),
            DropdownField<String>(
              label: 'Biểu mẫu phương án',
              value: _formType,
              items: scenarioForms,
              labelOf: (v) => v,
              onChanged: (v) => setState(() => _formType = v),
            ),
            DropdownField<String>(
              label: 'Loại hình',
              value: _type,
              items: scenarioTypes,
              labelOf: (v) => v,
              onChanged: (v) => setState(() => _type = v),
            ),
            AppTextField(label: 'Mục tiêu', controller: _objective, maxLines: 2),
            AppTextField(label: 'Phạm vi', controller: _scope),
            AppTextField(label: 'Địa điểm', controller: _location),
            AppTextField(label: 'Người chỉ huy / phụ trách', controller: _commander),
            const FormSectionTitle('Nội dung (mỗi dòng một mục)'),
            AppTextField(label: 'Lực lượng tham gia và vai trò', controller: _forces, maxLines: 4),
            AppTextField(label: 'Phương tiện, thiết bị huy động', controller: _equipment, maxLines: 4),
            AppTextField(label: 'Các bước thực hiện', controller: _steps, maxLines: 6),
          ],
        ),
      ),
    );
  }
}
