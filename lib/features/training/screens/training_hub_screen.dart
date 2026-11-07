import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/choice_filter_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_chip.dart';
import '../models/training.dart';
import 'training_plan_detail_screen.dart';
import 'training_plan_form_screen.dart';
import 'training_session_detail_screen.dart';
import 'training_session_form_screen.dart';

/// Chức năng 4: Huấn luyện, bồi dưỡng nghiệp vụ.
class TrainingHubScreen extends StatelessWidget {
  const TrainingHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Huấn luyện, bồi dưỡng'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Kế hoạch'), Tab(text: 'Buổi huấn luyện')],
          ),
        ),
        body: const TabBarView(children: [_PlansTab(), _SessionsTab()]),
      ),
    );
  }
}

class _PlansTab extends StatefulWidget {
  const _PlansTab();

  @override
  State<_PlansTab> createState() => _PlansTabState();
}

class _PlansTabState extends State<_PlansTab> {
  late Future<(List<TrainingPlan>, List<TrainingSession>)> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(List<TrainingPlan>, List<TrainingSession>)> _load() async {
    final plans = await Locator.training.getPlans();
    final sessions = await Locator.training.getSessions();
    return (plans, sessions);
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await pushScreen(context, const TrainingPlanFormScreen());
          _reload();
        },
        icon: const Icon(Icons.add),
        label: const Text('Lập kế hoạch'),
      ),
      body: AsyncBody<(List<TrainingPlan>, List<TrainingSession>)>(
        future: _future,
        builder: (context, data) {
          final (plans, sessions) = data;
          if (plans.isEmpty) {
            return const EmptyState(icon: Icons.event_note, message: 'Chưa có kế hoạch huấn luyện');
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: plans.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final p = plans[i];
              final ofPlan = sessions.where((s) => s.planId == p.id).toList();
              final done = ofPlan.where((s) => s.status == SessionStatus.done).length;
              final missed = ofPlan.where((s) => s.status == SessionStatus.missed).length;
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () async {
                    await pushScreen(context, TrainingPlanDetailScreen(planId: p.id));
                    _reload();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            StatusChip(label: p.period, color: AppColors.gold),
                            const Spacer(),
                            if (missed > 0)
                              StatusChip(label: '$missed buổi chưa thực hiện', color: AppColors.danger),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(p.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: ofPlan.isEmpty ? 0 : done / ofPlan.length,
                            minHeight: 7,
                            backgroundColor: AppColors.border,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('Hoàn thành $done/${ofPlan.length} buổi',
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SessionsTab extends StatefulWidget {
  const _SessionsTab();

  @override
  State<_SessionsTab> createState() => _SessionsTabState();
}

class _SessionsTabState extends State<_SessionsTab> {
  late Future<List<TrainingSession>> _future;
  SessionStatus? _status;

  @override
  void initState() {
    super.initState();
    _future = Locator.training.getSessions();
  }

  void _reload() => setState(() => _future = Locator.training.getSessions());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Tạo buổi huấn luyện',
        onPressed: () async {
          await pushScreen(context, const TrainingSessionFormScreen());
          _reload();
        },
        child: const Icon(Icons.add),
      ),
      body: AsyncBody<List<TrainingSession>>(
        future: _future,
        builder: (context, all) {
          final list = all.where((s) => _status == null || s.status == _status).toList();
          return Column(
            children: [
              const SizedBox(height: 8),
              ChoiceFilterBar<SessionStatus?>(
                options: [null, ...SessionStatus.values],
                selected: _status,
                labelOf: (s) => s?.label ?? 'Tất cả',
                onSelected: (s) => setState(() => _status = s),
              ),
              Expanded(
                child: list.isEmpty
                    ? const EmptyState(icon: Icons.school_outlined, message: 'Không có buổi huấn luyện')
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, i) => SessionCard(
                          session: list[i],
                          onTap: () async {
                            await pushScreen(context, TrainingSessionDetailScreen(sessionId: list[i].id));
                            _reload();
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class SessionCard extends StatelessWidget {
  const SessionCard({super.key, required this.session, required this.onTap});

  final TrainingSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = session;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 52,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.goldLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text('${s.date.day}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    Text('Th${s.date.month}', style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('${fmtTime(s.date)} · ${s.location}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        StatusChip(label: s.status.label, color: s.status.color),
                        const SizedBox(width: 8),
                        Text(
                          s.status == SessionStatus.done
                              ? 'Có mặt ${s.presentCount}/${s.attendance.length}'
                              : '${s.attendance.length} người tham gia',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
