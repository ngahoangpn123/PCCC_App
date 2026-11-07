import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/legal/legal_catalog.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/person_avatar.dart';
import '../../../core/widgets/status_chip.dart';
import '../../training/models/training.dart';
import '../models/member.dart';
import 'member_detail_screen.dart';

/// Số giờ huấn luyện / bồi dưỡng của từng thành viên, tính từ các buổi
/// đã hoàn thành mà thành viên có mặt (Điều 22 NĐ 347/2026:
/// huấn luyện 24–32 giờ, bồi dưỡng 8–12 giờ).
class TrainingCapacityTab extends StatefulWidget {
  const TrainingCapacityTab({super.key});

  @override
  State<TrainingCapacityTab> createState() => _TrainingCapacityTabState();
}

class _TrainingCapacityTabState extends State<TrainingCapacityTab> {
  late Future<(List<Member>, List<TrainingSession>)> _future = _load();

  Future<(List<Member>, List<TrainingSession>)> _load() async =>
      (await Locator.team.getMembers(), await Locator.training.getSessions());

  @override
  Widget build(BuildContext context) {
    return AsyncBody<(List<Member>, List<TrainingSession>)>(
      future: _future,
      builder: (context, data) {
        final (members, sessions) = data;
        final done = sessions.where((s) => s.status == SessionStatus.done).toList();
        final active = members.where((m) => m.status != MemberStatus.left).toList();
        return RefreshIndicator(
          onRefresh: () async => setState(() => _future = _load()),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Yêu cầu: huấn luyện nghiệp vụ $trainingHoursMin–$trainingHoursMax giờ (lần đầu); '
                'bồi dưỡng nghiệp vụ $refresherHoursMin–$refresherHoursMax giờ (định kỳ).',
                style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              for (final m in active) _MemberHours(member: m, sessions: done),
            ],
          ),
        );
      },
    );
  }
}

class _MemberHours extends StatelessWidget {
  const _MemberHours({required this.member, required this.sessions});

  final Member member;
  final List<TrainingSession> sessions;

  double _hours(String kind) => sessions
      .where((s) => s.kind == kind &&
          s.attendance.any((a) => a.memberId == member.id && a.present))
      .fold<int>(0, (sum, s) => sum + s.durationMinutes) /
      60;

  @override
  Widget build(BuildContext context) {
    final train = _hours(sessionKinds[0]);
    final refresh = _hours(sessionKinds[1]);
    final ok = train >= trainingHoursMin || refresh >= refresherHoursMin;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => pushScreen(context, MemberDetailScreen(memberId: member.id)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PersonAvatar(member.name),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(member.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(member.role,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  StatusChip(
                    label: ok ? 'Đạt giờ' : 'Chưa đủ giờ',
                    color: ok ? AppColors.success : AppColors.danger,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _HoursBar(label: 'Huấn luyện', hours: train, min: trainingHoursMin),
              const SizedBox(height: 6),
              _HoursBar(label: 'Bồi dưỡng', hours: refresh, min: refresherHoursMin),
            ],
          ),
        ),
      ),
    );
  }
}

class _HoursBar extends StatelessWidget {
  const _HoursBar({required this.label, required this.hours, required this.min});

  final String label;
  final double hours;
  final int min;

  @override
  Widget build(BuildContext context) {
    final ratio = (hours / min).clamp(0.0, 1.0);
    final color = hours >= min ? AppColors.success : AppColors.warning;
    return Row(
      children: [
        SizedBox(width: 78, child: Text(label, style: const TextStyle(fontSize: 12))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 7,
              color: color,
              backgroundColor: AppColors.border,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('${hours.toStringAsFixed(1)}/$min giờ', style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
