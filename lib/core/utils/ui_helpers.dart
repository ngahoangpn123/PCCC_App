import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'formatters.dart';

/// Mở một màn hình mới.
Future<T?> pushScreen<T>(BuildContext context, Widget screen) {
  return Navigator.of(context).push<T>(
    MaterialPageRoute(builder: (_) => screen),
  );
}

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
}

/// Báo cho người dùng biết chức năng sẽ nối với backend sau.
void showComingSoon(BuildContext context, String feature) {
  showSnack(context, '$feature: sẽ nối với Supabase ở bước sau');
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Đồng ý',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c, false),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(c, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Tạo id tạm cho dữ liệu mẫu (Supabase sẽ tự sinh id thật).
String newId() => DateTime.now().microsecondsSinceEpoch.toString();

/// Màu cho chữ hạn chót: quá hạn đỏ, gần hạn cam, còn xa xám.
Color dueColor(DateTime due) {
  final days = daysFromToday(due);
  if (days < 0) return AppColors.danger;
  if (days <= 7) return AppColors.warning;
  return AppColors.textSecondary;
}
