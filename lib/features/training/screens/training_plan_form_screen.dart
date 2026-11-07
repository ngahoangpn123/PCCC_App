import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/form_fields.dart';
import '../models/training.dart';

class TrainingPlanFormScreen extends StatefulWidget {
  const TrainingPlanFormScreen({super.key, this.plan});

  final TrainingPlan? plan;

  @override
  State<TrainingPlanFormScreen> createState() => _TrainingPlanFormScreenState();
}

class _TrainingPlanFormScreenState extends State<TrainingPlanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.plan?.title ?? '');
  late final _description = TextEditingController(text: widget.plan?.description ?? '');

  static const _periodTypes = ['Tháng', 'Quý', 'Năm'];

  // Tách "Quý IV/2026" thành loại kỳ "Quý" và phần "IV/2026".
  late String _periodType = _periodTypes.firstWhere(
    (t) => (widget.plan?.period ?? '').startsWith('$t '),
    orElse: () => 'Quý',
  );
  late final _period = TextEditingController(
    text: (widget.plan?.period ?? '').startsWith('$_periodType ')
        ? widget.plan!.period.substring(_periodType.length + 1)
        : (widget.plan?.period ?? ''),
  );

  @override
  void dispose() {
    _title.dispose();
    _period.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final p = widget.plan ?? TrainingPlan(id: newId(), title: '', period: '');
    p
      ..title = _title.text.trim()
      ..period = '$_periodType ${_period.text.trim()}'.trim()
      ..description = _description.text.trim();
    await Locator.training.savePlan(p);
    if (!mounted) return;
    showSnack(context, 'Đã lưu kế hoạch');
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.plan == null ? 'Lập kế hoạch huấn luyện' : 'Sửa kế hoạch')),
      bottomNavigationBar: BottomActionBar(label: 'Lưu kế hoạch', onPressed: _save),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppTextField(label: 'Tên kế hoạch', controller: _title, required: true),
            Row(
              children: [
                Expanded(
                  child: DropdownField<String>(
                    label: 'Theo',
                    value: _periodType,
                    items: _periodTypes,
                    labelOf: (v) => v,
                    onChanged: (v) => setState(() => _periodType = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: AppTextField(
                    label: 'Kỳ',
                    controller: _period,
                    required: true,
                    hint: 'VD: IV/2026',
                  ),
                ),
              ],
            ),
            AppTextField(label: 'Mô tả, mục tiêu', controller: _description, maxLines: 4),
            const Text(
              'Sau khi lưu, mở kế hoạch để thêm các buổi huấn luyện.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
