import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/form_fields.dart';
import '../models/equipment.dart';

/// Quy trình kiểm tra thiết bị: checklist → kết quả → ảnh minh chứng → lưu.
class InspectionScreen extends StatefulWidget {
  const InspectionScreen({super.key, required this.equipmentId});

  final String equipmentId;

  @override
  State<InspectionScreen> createState() => _InspectionScreenState();
}

class _InspectionScreenState extends State<InspectionScreen> {
  late final Future<Equipment> _future = Locator.equipment.getById(widget.equipmentId);
  final _note = TextEditingController();
  final _by = TextEditingController(text: 'Vũ Thị Giang');
  final Map<String, bool> _checks = {};
  final List<String> _photos = [];
  String _kind = 'Kiểm tra';
  EquipmentStatus _result = EquipmentStatus.ok;
  DateTime _nextCheck = DateTime.now().add(const Duration(days: 90));

  static const _kinds = ['Kiểm tra', 'Bảo dưỡng', 'Sửa chữa'];

  /// Checklist mẫu theo loại thiết bị.
  /// TODO: thay bằng checklist chuẩn theo quy định cho từng loại.
  List<String> _checklistFor(String type) {
    if (type == 'Bình chữa cháy') {
      return [
        'Vỏ bình không móp, gỉ, nứt',
        'Đồng hồ áp suất ở vùng xanh',
        'Chốt hãm, niêm phong còn nguyên',
        'Vòi, loa phun không tắc, không nứt',
        'Nhãn, hướng dẫn sử dụng rõ ràng',
        'Đặt đúng vị trí, dễ thấy, dễ lấy',
      ];
    }
    if (type == 'Máy bơm') {
      return [
        'Khởi động được ở chế độ tay',
        'Tự khởi động khi giảm áp',
        'Áp lực đầu đẩy đạt yêu cầu',
        'Không rò rỉ nước, dầu',
        'Nguồn điện ưu tiên hoạt động',
      ];
    }
    return [
      'Thiết bị đủ số lượng',
      'Không hư hỏng bên ngoài',
      'Hoạt động bình thường khi thử',
      'Vị trí đặt đúng quy định',
    ];
  }

  @override
  void dispose() {
    _note.dispose();
    _by.dispose();
    super.dispose();
  }

  Future<void> _save(Equipment e) async {
    final failed = _checks.entries.where((x) => !x.value).map((x) => x.key).toList();
    final record = InspectionRecord(
      date: DateTime.now(),
      kind: _kind,
      by: _by.text.trim(),
      result: _result,
      note: [
        if (failed.isNotEmpty) 'Chưa đạt: ${failed.join('; ')}',
        if (_note.text.trim().isNotEmpty) _note.text.trim(),
      ].join('\n'),
      photos: _photos,
    );
    await Locator.equipment.addInspection(e, record, _nextCheck);
    if (!mounted) return;
    showSnack(context, 'Đã lưu kết quả. Chờ người có thẩm quyền xác nhận.');
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBody<Equipment>(
      future: _future,
      builder: (context, e) {
        final items = _checklistFor(e.type);
        for (final item in items) {
          _checks.putIfAbsent(item, () => false);
        }
        final passed = _checks.values.where((v) => v).length;

        return Scaffold(
          appBar: AppBar(title: Text('Kiểm tra: ${e.code}')),
          bottomNavigationBar: BottomActionBar(
            label: 'Lưu kết quả',
            icon: Icons.save_outlined,
            onPressed: () => _save(e),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(e.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              Text(e.location, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              DropdownField<String>(
                label: 'Hình thức',
                value: _kind,
                items: _kinds,
                labelOf: (v) => v,
                onChanged: (v) => setState(() => _kind = v),
              ),
              Row(
                children: [
                  const Expanded(child: FormSectionTitle('Checklist kiểm tra')),
                  Text('$passed/${items.length} đạt',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              Card(
                child: Column(
                  children: [
                    for (final item in items)
                      CheckboxListTile(
                        value: _checks[item],
                        title: Text(item),
                        onChanged: (v) => setState(() => _checks[item] = v ?? false),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const FormSectionTitle('Kết quả'),
              DropdownField<EquipmentStatus>(
                label: 'Tình trạng sau kiểm tra',
                value: _result,
                items: EquipmentStatus.values,
                labelOf: (s) => s.label,
                onChanged: (v) => setState(() => _result = v),
              ),
              AppTextField(label: 'Người thực hiện', controller: _by, required: true),
              AppTextField(label: 'Ghi chú, đề xuất xử lý', controller: _note, maxLines: 3),
              DatePickerField(
                label: 'Ngày kiểm tra tiếp theo',
                value: _nextCheck,
                onChanged: (v) => setState(() => _nextCheck = v),
              ),
              const FormSectionTitle('Ảnh minh chứng'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final p in _photos)
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.goldLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.image, color: AppColors.primary),
                          Text(p, style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    // TODO: dùng image_picker để chụp ảnh thật.
                    onTap: () => setState(() => _photos.add('anh_${_photos.length + 1}.jpg')),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined, color: AppColors.primary),
                          Text('Chụp ảnh', style: TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
