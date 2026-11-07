import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/info_section.dart';
import '../models/training.dart';
import 'training_hub_screen.dart';
import 'training_plan_form_screen.dart';
import 'training_session_detail_screen.dart';
import 'training_session_form_screen.dart';

class TrainingPlanDetailScreen extends StatefulWidget {
  const TrainingPlanDetailScreen({super.key, required this.planId});

  final String planId;

  @override
  State<TrainingPlanDetailScreen> createState() => _TrainingPlanDetailScreenState();
}

class _TrainingPlanDetailScreenState extends State<TrainingPlanDetailScreen> {
  late Future<(TrainingPlan, List<TrainingSession>)> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(TrainingPlan, List<TrainingSession>)> _load() async {
    final plan = await Locator.training.getPlan(widget.planId);
    final sessions = await Locator.training.getSessions(planId: widget.planId);
    return (plan, sessions);
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return AsyncBody<(TrainingPlan, List<TrainingSession>)>(
      future: _future,
      builder: (context, data) {
        final (plan, sessions) = data;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Kế hoạch huấn luyện'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  await pushScreen(context, TrainingPlanFormScreen(plan: plan));
                  _reload();
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              await pushScreen(context, TrainingSessionFormScreen(presetPlanId: plan.id));
              _reload();
            },
            icon: const Icon(Icons.add),
            label: const Text('Thêm buổi'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            children: [
              InfoSection(
                title: plan.title,
                icon: Icons.event_note,
                children: [
                  InfoRow('Kỳ', plan.period),
                  InfoRow('Số buổi', '${sessions.length}'),
                  if (plan.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(plan.description),
                  ],
                ],
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(4, 20, 4, 8),
                child: Text('Các buổi trong kế hoạch',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
              if (sessions.isEmpty)
                const Text('Chưa có buổi nào', style: TextStyle(color: AppColors.textSecondary)),
              for (final s in sessions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SessionCard(
                    session: s,
                    onTap: () async {
                      await pushScreen(context, TrainingSessionDetailScreen(sessionId: s.id));
                      _reload();
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
