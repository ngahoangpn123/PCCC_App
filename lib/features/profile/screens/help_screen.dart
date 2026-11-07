import 'package:flutter/material.dart';

import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/form_fields.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _feedback = TextEditingController();

  static const _faqs = [
    (
      'Làm sao tạo hồ sơ từ biểu mẫu?',
      'Vào Quản lý > Hồ sơ cơ sở > Kho biểu mẫu, chọn mẫu rồi bấm "Tạo hồ sơ từ mẫu".',
    ),
    (
      'Tải tệp lên app có phải là đã nộp hồ sơ?',
      'Không. App quản lý hồ sơ nội bộ. Việc nộp và nhận kết quả chính thức phụ thuộc '
          'phương thức và thẩm quyền áp dụng.',
    ),
    (
      'Vì sao thông báo đã đọc vẫn còn trong mục "Chưa xử lý"?',
      'Đã đọc không đồng nghĩa đã xử lý. Thông báo đóng khi vấn đề đã được giải quyết.',
    ),
    (
      'Làm sao kiểm tra thiết bị nhanh tại chỗ?',
      'Dùng nút "Quét QR kiểm tra" ở trang chủ hoặc biểu tượng QR trong danh sách thiết bị.',
    ),
  ];

  @override
  void dispose() {
    _feedback.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hướng dẫn & hỗ trợ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const FormSectionTitle('Câu hỏi thường gặp'),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final f in _faqs)
                  ExpansionTile(
                    title: Text(f.$1, style: const TextStyle(fontWeight: FontWeight.w600)),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    children: [Align(alignment: Alignment.centerLeft, child: Text(f.$2))],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const FormSectionTitle('Gửi phản hồi'),
          AppTextField(
            label: 'Nội dung góp ý, lỗi gặp phải',
            controller: _feedback,
            maxLines: 4,
          ),
          FilledButton.icon(
            onPressed: () {
              if (_feedback.text.trim().isEmpty) return;
              _feedback.clear();
              showSnack(context, 'Cảm ơn bạn đã góp ý!');
            },
            icon: const Icon(Icons.send),
            label: const Text('Gửi phản hồi'),
          ),
        ],
      ),
    );
  }
}
