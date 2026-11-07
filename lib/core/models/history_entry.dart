/// Một dòng lịch sử: ai làm gì, lúc nào. Dùng chung cho hồ sơ, thành viên, thiết bị...
class HistoryEntry {
  const HistoryEntry({
    required this.time,
    required this.actor,
    required this.action,
  });

  final DateTime time;
  final String actor;
  final String action;
}
