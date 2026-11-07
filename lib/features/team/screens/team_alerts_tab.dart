import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/empty_state.dart';
import '../models/member.dart';
import '../models/shift.dart';
import 'member_detail_screen.dart';
import 'shift_detail_screen.dart';

class _Alert {
  _Alert(this.icon, this.color, this.title, this.detail, this.open);

  final IconData icon;
  final Color color;
  final String title;
  final String detail;
  final Widget open; // màn hình mở khi chạm
}

/// Cảnh báo tự động về đội: thiếu người, chưa xác nhận, trùng lịch,
/// người vắng mặt được xếp lịch, chưa đáp ứng huấn luyện.
class TeamAlertsTab extends StatefulWidget {
  const TeamAlertsTab({super.key});

  @override
  State<TeamAlertsTab> createState() => _TeamAlertsTabState();
}

class _TeamAlertsTabState extends State<TeamAlertsTab> {
  late Future<List<_Alert>> _future;

  @override
  void initState() {
    super.initState();
    _future = _build();
  }

  Future<List<_Alert>> _build() async {
    final shifts = await Locator.team.getShifts();
    final members = await Locator.team.getMembers();
    String nameOf(String id) => members.where((m) => m.id == id).map((m) => m.name).firstOrNull ?? id;
    final upcoming = shifts.where((s) => daysFromToday(s.date) >= 0 && s.status != ShiftStatus.done);
    final alerts = <_Alert>[];

    for (final s in upcoming) {
      final when = '${fmtFullDate(s.date)} · ${s.timeRange}';
      if (s.understaffed) {
        alerts.add(_Alert(Icons.group_off, AppColors.danger, 'Ca trực thiếu người',
            '$when: ${s.memberIds.length}/${s.requiredCount} người', ShiftDetailScreen(shiftId: s.id)));
      }
      if (s.unconfirmedIds.isNotEmpty) {
        alerts.add(_Alert(Icons.help_outline, AppColors.warning, 'Thành viên chưa xác nhận lịch trực',
            '$when: ${s.unconfirmedIds.map(nameOf).join(', ')}', ShiftDetailScreen(shiftId: s.id)));
      }
      for (final id in s.memberIds) {
        final m = members.where((x) => x.id == id).firstOrNull;
        if (m != null && m.status == MemberStatus.away) {
          alerts.add(_Alert(Icons.person_off, AppColors.danger, 'Người vắng mặt bị xếp lịch',
              '${m.name} đang tạm vắng nhưng có ca $when', ShiftDetailScreen(shiftId: s.id)));
        }
      }
    }

    // Trùng lịch: một người có từ 2 ca trở lên trong cùng ngày.
    final byDay = <DateTime, List<Shift>>{};
    for (final s in upcoming) {
      byDay.putIfAbsent(dateOnly(s.date), () => []).add(s);
    }
    byDay.forEach((day, list) {
      final counts = <String, int>{};
      for (final s in list) {
        for (final id in s.memberIds) {
          counts[id] = (counts[id] ?? 0) + 1;
        }
      }
      counts.forEach((id, n) {
        if (n > 1) {
          alerts.add(_Alert(Icons.event_busy, AppColors.warning, 'Lịch trực bị trùng',
              '${nameOf(id)} có $n ca trong ${fmtFullDate(day)}', MemberDetailScreen(memberId: id)));
        }
      });
    });

    for (final m in members.where((m) => m.status == MemberStatus.active && !m.trainingOk)) {
      alerts.add(_Alert(Icons.school, AppColors.info, 'Chưa đáp ứng yêu cầu huấn luyện',
          '${m.name}: ${m.trainingNote}', MemberDetailScreen(memberId: m.id)));
    }
    return alerts;
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBody<List<_Alert>>(
      future: _future,
      builder: (context, alerts) {
        if (alerts.isEmpty) {
          return const EmptyState(icon: Icons.verified, message: 'Không có cảnh báo nào');
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: alerts.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final a = alerts[i];
            return Card(
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: a.color.withValues(alpha: 0.12),
                  child: Icon(a.icon, color: a.color),
                ),
                title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(a.detail),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await pushScreen(context, a.open);
                  setState(() => _future = _build());
                },
              ),
            );
          },
        );
      },
    );
  }
}
