import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';

/// Lưới lịch tháng tự vẽ (không cần thư viện ngoài).
/// [markers]: ngày nào có sự kiện thì hiện chấm màu bên dưới số ngày.
class MonthGrid extends StatelessWidget {
  const MonthGrid({
    super.key,
    required this.month,
    required this.selected,
    required this.onSelect,
    required this.onMonthChanged,
    this.markers = const {},
  });

  final DateTime month; // bất kỳ ngày nào trong tháng cần hiển thị
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;
  final ValueChanged<DateTime> onMonthChanged;
  final Map<DateTime, List<Color>> markers; // key là dateOnly

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = first.weekday - 1; // tuần bắt đầu từ thứ 2
    final rows = ((leading + daysInMonth + 6) ~/ 7);
    final today = DateTime.now();

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () =>
                  onMonthChanged(DateTime(month.year, month.month - 1, 1)),
            ),
            Expanded(
              child: Text(
                'Tháng ${month.month}/${month.year}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () =>
                  onMonthChanged(DateTime(month.year, month.month + 1, 1)),
            ),
          ],
        ),
        Row(
          children: [
            for (final w in weekdayShort)
              Expanded(
                child: Center(
                  child: Text(
                    w,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        for (var r = 0; r < rows; r++)
          Row(
            children: List.generate(7, (c) {
              final dayNum = r * 7 + c - leading + 1;
              if (dayNum < 1 || dayNum > daysInMonth) {
                return const Expanded(child: SizedBox(height: 46));
              }
              final date = DateTime(month.year, month.month, dayNum);
              final isSelected = sameDay(date, selected);
              final isToday = sameDay(date, today);
              final dots = markers[date] ?? const <Color>[];
              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => onSelect(date),
                  child: SizedBox(
                    height: 46,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : null,
                            shape: BoxShape.circle,
                            border: isToday && !isSelected
                                ? Border.all(color: AppColors.primary)
                                : null,
                          ),
                          child: Text(
                            '$dayNum',
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (final color in dots.take(3))
                              Container(
                                width: 5,
                                height: 5,
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
      ],
    );
  }
}
