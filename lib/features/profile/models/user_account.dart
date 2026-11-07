import '../../../core/legal/legal_catalog.dart';

class UserAccount {
  UserAccount({
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });

  String name;
  String email;
  String phone;
  String role;
}

/// Người được giao quyền (cán bộ phụ trách, đội trưởng...).
class DelegatedUser {
  DelegatedUser({required this.name, required this.role, required this.scope});

  String name;
  String role;
  String scope; // phạm vi được giao
}

/// 6 vai trò có thể giao (vai trò 1 là chính người đứng đầu) – xem userRoles.
final delegateRoles = userRoles.skip(1).map((r) => r.name).toList();

class ActivityLog {
  const ActivityLog({required this.time, required this.action});

  final DateTime time;
  final String action;
}

class NotificationSettings {
  NotificationSettings({
    this.push = true,
    this.inApp = true,
    this.remindDaysBefore = 7,
    this.remindOverdue = true,
    this.urgent = true,
    this.upcoming = true,
    this.dossier = true,
    this.schedule = true,
  });

  bool push;
  bool inApp;
  int remindDaysBefore;
  bool remindOverdue;
  bool urgent;
  bool upcoming;
  bool dossier;
  bool schedule;
}

/// Cài đặt chữ ký số / chữ ký điện tử.
class SignatureSettings {
  SignatureSettings({this.provider = '', this.serial = '', this.validUntil, this.pinOnSign = true});

  String provider; // nhà cung cấp chữ ký số
  String serial; // số serial chứng thư
  DateTime? validUntil;
  bool pinOnSign; // yêu cầu nhập PIN mỗi lần ký
}
