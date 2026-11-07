/// Các hàm định dạng ngày giờ kiểu Việt Nam (không cần thư viện ngoài).
library;

String _two(int n) => n.toString().padLeft(2, '0');

String fmtDate(DateTime d) => '${_two(d.day)}/${_two(d.month)}/${d.year}';

String fmtDayMonth(DateTime d) => '${_two(d.day)}/${_two(d.month)}';

String fmtTime(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';

String fmtDateTime(DateTime d) => '${fmtTime(d)} · ${fmtDate(d)}';

const _weekdays = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];
const weekdayShort = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

String weekdayLabel(DateTime d) => _weekdays[d.weekday - 1];

String fmtFullDate(DateTime d) => '${weekdayLabel(d)}, ${fmtDate(d)}';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Số ngày từ hôm nay đến [d] (âm nếu đã qua).
int daysFromToday(DateTime d) =>
    dateOnly(d).difference(dateOnly(DateTime.now())).inDays;

/// "Hôm nay", "Còn 3 ngày", "Quá hạn 2 ngày".
String dueText(DateTime due) {
  final days = daysFromToday(due);
  if (days < 0) return 'Quá hạn ${-days} ngày';
  if (days == 0) return 'Hôm nay';
  if (days == 1) return 'Ngày mai';
  return 'Còn $days ngày';
}

/// "5 phút trước", "2 giờ trước", "3 ngày trước".
String timeAgo(DateTime t) {
  final diff = DateTime.now().difference(t);
  if (diff.inMinutes < 1) return 'Vừa xong';
  if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
  if (diff.inHours < 24) return '${diff.inHours} giờ trước';
  if (diff.inDays < 30) return '${diff.inDays} ngày trước';
  return fmtDate(t);
}
