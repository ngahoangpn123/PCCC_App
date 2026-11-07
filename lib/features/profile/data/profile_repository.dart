import '../../../core/mock/mock_database.dart';
import '../models/user_account.dart';

abstract class ProfileRepository {
  Future<UserAccount> getAccount();
  Future<void> saveAccount(UserAccount account);
  Future<List<DelegatedUser>> getDelegates();
  Future<void> addDelegate(DelegatedUser user);
  Future<void> removeDelegate(DelegatedUser user);
  Future<List<ActivityLog>> getActivityLogs();
  Future<NotificationSettings> getSettings();
  Future<void> saveSettings(NotificationSettings settings);
  Future<SignatureSettings> getSignature();
  Future<void> saveSignature(SignatureSettings s);
}

class MockProfileRepository implements ProfileRepository {
  final _db = MockDatabase.instance;

  @override
  Future<UserAccount> getAccount() => mockDelay(_db.account);

  @override
  Future<void> saveAccount(UserAccount account) async {
    _db.account = account;
    await mockDelay(null);
  }

  @override
  Future<List<DelegatedUser>> getDelegates() => mockDelay(_db.delegates.toList());

  @override
  Future<void> addDelegate(DelegatedUser user) async {
    _db.delegates.add(user);
    await mockDelay(null);
  }

  @override
  Future<void> removeDelegate(DelegatedUser user) async {
    _db.delegates.remove(user);
    await mockDelay(null);
  }

  @override
  Future<List<ActivityLog>> getActivityLogs() =>
      mockDelay(_db.activityLogs.toList());

  @override
  Future<NotificationSettings> getSettings() => mockDelay(_db.settings);

  @override
  Future<void> saveSettings(NotificationSettings settings) => mockDelay(null);

  @override
  Future<SignatureSettings> getSignature() => mockDelay(_db.signature);

  @override
  Future<void> saveSignature(SignatureSettings s) => mockDelay(null);
}

class SupabaseProfileRepository implements ProfileRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Chưa nối Supabase');
}
