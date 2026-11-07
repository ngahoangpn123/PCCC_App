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

const delegateRoles = [
  'Cán bộ phụ trách PCCC & CNCH',
  'Đội trưởng đội PCCC & CNCH',
  'Người phụ trách thiết bị',
  'Người được giao nhiệm vụ',
];

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
