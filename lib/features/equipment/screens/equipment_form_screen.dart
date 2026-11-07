import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/form_fields.dart';
import '../../../core/legal/legal_catalog.dart';
import '../models/equipment.dart';

class EquipmentFormScreen extends StatefulWidget {
  const EquipmentFormScreen({super.key, this.item});

  final Equipment? item;

  @override
  State<EquipmentFormScreen> createState() => _EquipmentFormScreenState();
}

class _EquipmentFormScreenState extends State<EquipmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _code = TextEditingController(text: widget.item?.code ?? '');
  late final _name = TextEditingController(text: widget.item?.name ?? '');
  late final _maker = TextEditingController(text: widget.item?.maker ?? '');
  late final _model = TextEditingController(text: widget.item?.model ?? '');
  late final _serial = TextEditingController(text: widget.item?.serial ?? '');
  late final _quantity = TextEditingController(text: '${widget.item?.quantity ?? 1}');
  late final _unit = TextEditingController(text: widget.item?.unit ?? 'cái');
  late final _location = TextEditingController(text: widget.item?.location ?? '');
  late final _keeper = TextEditingController(text: widget.item?.keeper ?? '');
  late String _type = widget.item?.type ?? equipmentTypes.first;
  late String _ht = widget.item?.htGroup ?? 'HT12';
  late final _pc24 = TextEditingController(text: widget.item?.pc24Code ?? '');
  late EquipmentStatus _status = widget.item?.status ?? EquipmentStatus.ok;
  late DateTime _inUseSince = widget.item?.inUseSince ?? DateTime.now();
  late DateTime _nextCheck =
      widget.item?.nextCheck ?? DateTime.now().add(const Duration(days: 90));

  bool get _isEdit => widget.item != null;

  @override
  void dispose() {
    for (final c in [_code, _name, _maker, _model, _serial, _quantity, _unit, _location, _keeper, _pc24]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final e = widget.item ??
        Equipment(
          id: newId(),
          code: '',
          name: '',
          type: _type,
          quantity: 1,
          unit: '',
          location: '',
          inUseSince: _inUseSince,
          status: _status,
          nextCheck: _nextCheck,
          keeper: '',
        );
    e
      ..code = _code.text.trim()
      ..name = _name.text.trim()
      ..type = _type
      ..maker = _maker.text.trim()
      ..model = _model.text.trim()
      ..serial = _serial.text.trim()
      ..quantity = int.tryParse(_quantity.text.trim()) ?? 1
      ..unit = _unit.text.trim()
      ..location = _location.text.trim()
      ..keeper = _keeper.text.trim()
      ..htGroup = _ht
      ..pc24Code = _pc24.text.trim()
      ..status = _status
      ..inUseSince = _inUseSince
      ..nextCheck = _nextCheck;
    await Locator.equipment.save(e);
    if (!mounted) return;
    showSnack(context, _isEdit ? 'Đã cập nhật thiết bị' : 'Đã thêm thiết bị');
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Sửa thiết bị' : 'Thêm thiết bị')),
      bottomNavigationBar: BottomActionBar(label: 'Lưu thiết bị', onPressed: _save),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const FormSectionTitle('Định danh'),
            AppTextField(label: 'Mã định danh / mã tài sản', controller: _code, required: true),
            AppTextField(label: 'Tên thiết bị', controller: _name, required: true),
            DropdownField<String>(
              label: 'Loại',
              value: _type,
              items: equipmentTypes,
              labelOf: (v) => v,
              onChanged: (v) => setState(() => _type = v),
            ),
            DropdownField<String>(
              label: 'Nhóm hệ thống (bảng kiểm tra HT)',
              value: _ht,
              items: htTables.map((h) => h.code).toList(),
              labelOf: htLabel,
              onChanged: (v) => setState(() => _ht = v),
            ),
            AppTextField(
              label: 'Mã tờ khai PC24 (nếu có)',
              controller: _pc24,
              hint: 'Tờ khai thông tin phương tiện PCCC lưu thông trên thị trường',
            ),
            AppTextField(label: 'Hãng sản xuất', controller: _maker),
            AppTextField(label: 'Model', controller: _model),
            AppTextField(label: 'Số serial', controller: _serial),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Số lượng',
                    controller: _quantity,
                    required: true,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: AppTextField(label: 'Đơn vị tính', controller: _unit)),
              ],
            ),
            const FormSectionTitle('Vị trí & sử dụng'),
            AppTextField(
              label: 'Vị trí',
              controller: _location,
              required: true,
              hint: 'Tòa nhà, tầng, phòng, khu vực',
            ),
            DatePickerField(
              label: 'Ngày đưa vào sử dụng',
              value: _inUseSince,
              onChanged: (v) => setState(() => _inUseSince = v),
            ),
            AppTextField(label: 'Người phụ trách', controller: _keeper),
            const FormSectionTitle('Tình trạng & lịch kiểm tra'),
            DropdownField<EquipmentStatus>(
              label: 'Tình trạng',
              value: _status,
              items: EquipmentStatus.values,
              labelOf: (s) => s.label,
              onChanged: (v) => setState(() => _status = v),
            ),
            DatePickerField(
              label: 'Ngày kiểm tra tiếp theo',
              value: _nextCheck,
              onChanged: (v) => setState(() => _nextCheck = v),
            ),
          ],
        ),
      ),
    );
  }
}
