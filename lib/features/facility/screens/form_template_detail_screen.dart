import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/info_section.dart';
import '../models/form_template.dart';
import 'dossier_form_screen.dart';

class FormTemplateDetailScreen extends StatelessWidget {
  const FormTemplateDetailScreen({super.key, required this.template});

  final FormTemplate template;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mẫu ${template.code}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InfoSection(
            title: template.name,
            icon: Icons.description_outlined,
            children: [
              InfoRow('Mã biểu mẫu', template.code),
              InfoRow('Mục đích', template.purpose),
            ],
          ),
          const SizedBox(height: 12),
          InfoSection(
            title: 'Hướng dẫn',
            icon: Icons.menu_book_outlined,
            children: [Text(template.guide)],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.goldLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Lưu ý: Tải tệp lên app không đồng nghĩa hồ sơ đã được nộp hợp lệ. '
              'Việc ký, gửi và nhận kết quả chính thức phụ thuộc phương thức và '
              'thẩm quyền áp dụng.',
              style: TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => pushScreen(
              context,
              DossierFormScreen(presetFormCode: template.code),
            ),
            icon: const Icon(Icons.note_add_outlined),
            label: const Text('Tạo hồ sơ từ mẫu (điền trên app)'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => showComingSoon(context, 'Tải mẫu về máy'),
            icon: const Icon(Icons.download_outlined),
            label: const Text('Tải mẫu về để điền ngoại tuyến'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => showComingSoon(context, 'Tải bản đã điền lên'),
            icon: const Icon(Icons.upload_file_outlined),
            label: const Text('Tải bản đã điền lên'),
          ),
        ],
      ),
    );
  }
}
