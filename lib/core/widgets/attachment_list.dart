import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/ui_helpers.dart';

/// Danh sách tệp đính kèm / ảnh minh chứng.
/// Hiện chỉ lưu tên tệp; khi nối Supabase Storage sẽ thay bằng chọn tệp thật.
class AttachmentList extends StatelessWidget {
  const AttachmentList({
    super.key,
    required this.files,
    required this.onAdd,
  });

  final List<String> files;
  final VoidCallback onAdd;

  IconData _iconFor(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.pdf')) return Icons.picture_as_pdf_outlined;
    if (lower.endsWith('.jpg') || lower.endsWith('.png')) {
      return Icons.image_outlined;
    }
    return Icons.insert_drive_file_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (files.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Text(
              'Chưa có tệp nào',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        for (final f in files)
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: Icon(_iconFor(f), color: AppColors.primary),
            title: Text(f),
            trailing: IconButton(
              icon: const Icon(Icons.download_outlined),
              onPressed: () => showComingSoon(context, 'Tải tệp'),
            ),
          ),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.attach_file),
          label: const Text('Thêm tệp / ảnh'),
        ),
      ],
    );
  }
}
