import '../../../core/mock/mock_database.dart';
import '../models/app_notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> getNotifications();
  Future<AppNotification> getNotification(String id);
  Future<int> unreadCount();
  Future<void> markRead(String id);
  Future<void> markAllRead();

  /// Đánh dấu đã xử lý. Khi có backend, việc này nên do hệ thống tự làm
  /// khi điều kiện hoàn thành được đáp ứng (vd: thiết bị đã sửa xong).
  /// [resultNote] kết quả xử lý, [evidence] minh chứng (bắt buộc ở giao diện).
  Future<void> markResolved(String id, {String resultNote = '', List<String> evidence = const []});
}

class MockNotificationRepository implements NotificationRepository {
  final _db = MockDatabase.instance;

  @override
  Future<List<AppNotification>> getNotifications() {
    final list = _db.notifications.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return mockDelay(list);
  }

  @override
  Future<AppNotification> getNotification(String id) =>
      mockDelay(_db.notifications.firstWhere((n) => n.id == id));

  @override
  Future<int> unreadCount() =>
      mockDelay(_db.notifications.where((n) => !n.read).length);

  @override
  Future<void> markRead(String id) async {
    _db.notifications.firstWhere((n) => n.id == id).read = true;
    await mockDelay(null);
  }

  @override
  Future<void> markAllRead() async {
    for (final n in _db.notifications) {
      n.read = true;
    }
    await mockDelay(null);
  }

  @override
  Future<void> markResolved(String id, {String resultNote = '', List<String> evidence = const []}) async {
    final n = _db.notifications.firstWhere((n) => n.id == id);
    n.resolved = true;
    n.resultNote = resultNote;
    n.evidence.addAll(evidence);
    n.read = true;
    await mockDelay(null);
  }
}

class SupabaseNotificationRepository implements NotificationRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Chưa nối Supabase');
}
