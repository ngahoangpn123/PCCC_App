import 'package:flutter/material.dart';

import '../models/history_entry.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

/// Danh sách lịch sử dạng dòng thời gian (mới nhất ở trên).
class HistoryTimeline extends StatelessWidget {
  const HistoryTimeline({super.key, required this.entries});

  final List<HistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Chưa có lịch sử',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    final sorted = [...entries]..sort((a, b) => b.time.compareTo(a.time));
    return Column(
      children: [
        for (var i = 0; i < sorted.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 20,
                  child: Column(
                    children: [
                      const SizedBox(height: 6),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: i == 0 ? AppColors.primary : AppColors.gold,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (i != sorted.length - 1)
                        Expanded(
                          child: Container(width: 2, color: AppColors.border),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sorted[i].action,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${sorted[i].actor} · ${fmtDateTime(sorted[i].time)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
