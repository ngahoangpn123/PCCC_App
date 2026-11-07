import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/session/app_session.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/form_fields.dart';
import '../models/facility.dart';

class FacilityEditScreen extends StatefulWidget {
  const FacilityEditScreen({super.key, required this.facility});

  final Facility facility;

  @override
  State<FacilityEditScreen> createState() => _FacilityEditScreenState();
}

class _FacilityEditScreenState extends State<FacilityEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.facility.name);
  late final _code = TextEditingController(text: widget.facility.code);
  late final _address = TextEditingController(text: widget.facility.address);
  late final _field = TextEditingController(text: widget.facility.field);
  late final _scale = TextEditingController(text: widget.facility.scale);
  late final _building = TextEditingController(text: widget.facility.buildingInfo);
  late final _headName = TextEditingController(text: widget.facility.headName);
  late final _headPhone = TextEditingController(text: widget.facility.headPhone);
  late final _officerName = TextEditingController(text: widget.facility.officerName);
  late final _officerPhone = TextEditingController(text: widget.facility.officerPhone);
  late final _email = TextEditingController(text: widget.facility.email);
  late String _type = facilityTypes.contains(widget.facility.type)
      ? widget.facility.type
      : facilityTypes.last;

  @override
  void dispose() {
    for (final c in [
      _name, _code, _address, _field, _scale, _building,
      _headName, _headPhone, _officerName, _officerPhone, _email,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final f = widget.facility
      ..name = _name.text.trim()
      ..code = _code.text.trim()
      ..address = _address.text.trim()
      ..type = _type
      ..field = _field.text.trim()
      ..scale = _scale.text.trim()
      ..buildingInfo = _building.text.trim()
      ..headName = _headName.text.trim()
      ..headPhone = _headPhone.text.trim()
      ..officerName = _officerName.text.trim()
      ..officerPhone = _officerPhone.text.trim()
      ..email = _email.text.trim();
    await Locator.facility.saveFacility(f);
    if (f.id == AppSession.instance.currentFacilityId) {
      AppSession.instance.switchFacility(f.id, f.name);
    }
    if (!mounted) return;
    showSnack(context, 'Đã lưu thông tin cơ sở');
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa thông tin cơ sở')),
      bottomNavigationBar: BottomActionBar(label: 'Lưu thông tin', onPressed: _save),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const FormSectionTitle('Thông tin chung'),
            AppTextField(label: 'Tên cơ sở', controller: _name, required: true),
            AppTextField(label: 'Mã cơ sở', controller: _code, required: true),
            AppTextField(label: 'Địa chỉ', controller: _address, required: true, maxLines: 2),
            const FormSectionTitle('Loại hình & quy mô'),
            DropdownField<String>(
              label: 'Loại hình',
              value: _type,
              items: facilityTypes,
              labelOf: (v) => v,
              onChanged: (v) => setState(() => _type = v),
            ),
            AppTextField(label: 'Lĩnh vực hoạt động', controller: _field),
            AppTextField(label: 'Quy mô', controller: _scale),
            AppTextField(label: 'Đặc điểm công trình', controller: _building, maxLines: 3),
            const FormSectionTitle('Người chịu trách nhiệm'),
            AppTextField(label: 'Người đứng đầu', controller: _headName, required: true),
            AppTextField(
              label: 'Điện thoại người đứng đầu',
              controller: _headPhone,
              keyboardType: TextInputType.phone,
            ),
            AppTextField(label: 'Người phụ trách PCCC & CNCH', controller: _officerName),
            AppTextField(
              label: 'Điện thoại người phụ trách',
              controller: _officerPhone,
              keyboardType: TextInputType.phone,
            ),
            AppTextField(
              label: 'Email liên hệ',
              controller: _email,
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
    );
  }
}
