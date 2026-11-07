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
  late final _staff = TextEditingController(
    text: widget.facility.staffCount == 0 ? '' : '${widget.facility.staffCount}',
  );
  late final _lat = TextEditingController(
    text: widget.facility.lat == 0 ? '' : '${widget.facility.lat}',
  );
  late final _lng = TextEditingController(
    text: widget.facility.lng == 0 ? '' : '${widget.facility.lng}',
  );
  late final _hazard = TextEditingController(text: widget.facility.hazard);
  late String _level = managementLevels.contains(widget.facility.managementLevel)
      ? widget.facility.managementLevel
      : managementLevels.first;
  late bool _construction = widget.facility.hasConstruction;
  late String _type = facilityTypes.contains(widget.facility.type)
      ? widget.facility.type
      : facilityTypes.last;

  @override
  void dispose() {
    for (final c in [
      _name, _code, _address, _field, _scale, _building,
      _headName, _headPhone, _officerName, _officerPhone, _email,
      _staff, _lat, _lng, _hazard,
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
      ..email = _email.text.trim()
      ..staffCount = int.tryParse(_staff.text.trim()) ?? 0
      ..lat = double.tryParse(_lat.text.trim().replaceAll(',', '.')) ?? 0
      ..lng = double.tryParse(_lng.text.trim().replaceAll(',', '.')) ?? 0
      ..hazard = _hazard.text.trim()
      ..managementLevel = _level
      ..hasConstruction = _construction;
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
            AppTextField(
              label: 'Số người thường xuyên làm việc',
              controller: _staff,
              keyboardType: TextInputType.number,
              hint: 'Dưới 20 người: văn bản phân công; từ 20 người: Quyết định thành lập Đội',
            ),
            AppTextField(
              label: 'Đặc điểm nguy hiểm cháy, nổ',
              controller: _hazard,
              maxLines: 3,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _construction,
              title: const Text('Đang thi công mới / cải tạo / thay đổi công năng'),
              subtitle: const Text('Bật để yêu cầu Tự nghiệm thu PC18 trước khi đưa vào sử dụng'),
              onChanged: (v) => setState(() => _construction = v),
            ),
            const FormSectionTitle('Vị trí & phân cấp quản lý'),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Vĩ độ',
                    controller: _lat,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppTextField(
                    label: 'Kinh độ',
                    controller: _lng,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => showComingSoon(context, 'Lấy tọa độ từ GPS / bản đồ GIS'),
                icon: const Icon(Icons.my_location, size: 18),
                label: const Text('Lấy vị trí hiện tại'),
              ),
            ),
            DropdownField<String>(
              label: 'Phân cấp quản lý',
              value: _level,
              items: managementLevels,
              labelOf: (v) => v,
              onChanged: (v) => setState(() => _level = v),
            ),
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
