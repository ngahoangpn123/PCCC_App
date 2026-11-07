// Chỗ dành cho phần kết nối database (để trống trong giai đoạn làm UI).
//
// Bước tiếp theo sẽ:
// 1. Tạo bảng trên Supabase (facilities, dossiers, members, shifts, equipment,
//    inspection_records, training_plans, training_sessions, attendance,
//    scenarios, drills, fix_tasks, notifications, profiles...).
// 2. Viết RLS cho từng bảng.
// 3. Viết các lớp Supabase...Repository trong thư mục data/ của từng chức năng.
// 4. Đổi lib/core/di/locator.dart sang dùng các lớp đó.
//
// Khi cần dùng client:
//   import 'package:supabase_flutter/supabase_flutter.dart';
//   final supabase = Supabase.instance.client;
