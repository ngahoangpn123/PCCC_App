/// Một biểu mẫu trong kho (PC01, PC11...).
class FormTemplate {
  const FormTemplate({
    required this.code,
    required this.name,
    required this.purpose,
    required this.guide,
  });

  final String code;
  final String name;
  final String purpose;
  final String guide;
}
