import '../../../core/mock/mock_database.dart';

abstract class AuthRepository {
  /// Trả về null nếu thành công, hoặc câu thông báo lỗi.
  Future<String?> signIn(String email, String password);
  Future<String?> signUp(String name, String email, String phone, String password);
  Future<String?> sendResetPassword(String email);
  Future<void> signOut();
}

/// Bản giả lập: mọi email/mật khẩu hợp lệ về hình thức đều đăng nhập được.
class MockAuthRepository implements AuthRepository {
  @override
  Future<String?> signIn(String email, String password) async {
    await mockDelay(null);
    if (!email.contains('@')) return 'Email không hợp lệ';
    if (password.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
    return null;
  }

  @override
  Future<String?> signUp(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    await mockDelay(null);
    return null;
  }

  @override
  Future<String?> sendResetPassword(String email) async {
    await mockDelay(null);
    return email.contains('@') ? null : 'Email không hợp lệ';
  }

  @override
  Future<void> signOut() => mockDelay(null);
}

/// TODO: dùng Supabase Auth (supabase.auth.signInWithPassword...).
class SupabaseAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Chưa nối Supabase');
}
