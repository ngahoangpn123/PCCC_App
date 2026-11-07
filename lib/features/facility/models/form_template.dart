/// Một biểu mẫu trong kho (PC01, PC02... và Mẫu 01, 02 của TT 36/2025).
class FormTemplate {
  const FormTemplate({
    required this.code,
    required this.name,
    required this.purpose,
    required this.guide,
    this.source = 'Phụ lục VIII NĐ 105/2025 (sửa đổi bởi NĐ 347/2026)',
    this.retention = '05 năm',
    this.isNew = false,
  });

  final String code;
  final String name;
  final String purpose;
  final String guide;
  final String source; // văn bản quy định mẫu
  final String retention; // thời hạn lưu trữ tối thiểu
  final bool isNew; // mẫu mới thay thế / bổ sung từ 15/9/2026
}

/// Các mẫu đã bị bãi bỏ theo Điều 30 NĐ 347/2026 (không còn trong kho).
const abolishedForms = ['PC15', 'PC16', 'PC17', 'PC19', 'PC20', 'PC21'];
