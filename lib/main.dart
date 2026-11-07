import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

// Đọc cấu hình truyền vào lúc chạy: flutter run --dart-define-from-file=env/dev.json
const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Giai đoạn làm UI: chưa có file env thì bỏ qua Supabase, app chạy bằng dữ liệu mẫu.
  if (supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty) {
    await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseKey);
  }

  runApp(const PcccApp());
}
