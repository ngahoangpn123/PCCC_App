import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_chip.dart';
import '../models/drill.dart';
import 'drill_detail_screen.dart';
import 'drill_form_screen.dart';
import 'scenario_detail_screen.dart';
import 'scenario_form_screen.dart';

/// Chức năng 5: Phương án, thực tập và diễn tập.
class DrillHubScreen extends StatelessWidget {
  const DrillHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Phương án & diễn tập'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Phương án'), Tab(text: 'Đợt thực tập, diễn tập')],
          ),
        ),
        body: const TabBarView(children: [_ScenariosTab(), _DrillsTab()]),
      ),
    );
  }
}

class _ScenariosTab extends StatefulWidget {
  const _ScenariosTab();

  @override
  State<_ScenariosTab> createState() => _ScenariosTabState();
}

class _ScenariosTabState extends State<_ScenariosTab> {
  late Future<(List<Scenario>, List<Drill>)> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(List<Scenario>, List<Drill>)> _load() async {
    final scenarios = await Locator.drills.getScenarios();
    final drills = await Locator.drills.getDrills();
    return (scenarios, drills);
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await pushScreen(context, const ScenarioFormScreen());
          _reload();
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm phương án'),
      ),
      body: AsyncBody<(List<Scenario>, List<Drill>)>(
        future: _future,
        builder: (context, data) {
          final (scenarios, drills) = data;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.goldLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Phương án là tài liệu, kịch bản. Mỗi phương án có thể được tổ chức '
                  'thực tập, diễn tập nhiều lần, mỗi lần có kết quả riêng.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(height: 12),
              if (scenarios.isEmpty)
                const EmptyState(icon: Icons.description_outlined, message: 'Chưa có phương án'),
              for (final sc in scenarios)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      onTap: () async {
                        await pushScreen(context, ScenarioDetailScreen(scenarioId: sc.id));
                        _reload();
                      },
                      leading: CircleAvatar(
                        backgroundColor: AppColors.goldLight,
                        child: Icon(
                          sc.type == 'Chữa cháy' ? Icons.local_fire_department : Icons.health_and_safety,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text('${sc.code} · ${sc.name}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        '${sc.type} · Đã tổ chức ${drills.where((d) => d.scenarioId == sc.id).length} lần',
                      ),
                      trailing: const Icon(Icons.chevron_right),
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

class _DrillsTab extends StatefulWidget {
  const _DrillsTab();

  @override
  State<_DrillsTab> createState() => _DrillsTabState();
}

class _DrillsTabState extends State<_DrillsTab> {
  late Future<(List<Drill>, List<Scenario>)> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(List<Drill>, List<Scenario>)> _load() async {
    final drills = await Locator.drills.getDrills();
    final scenarios = await Locator.drills.getScenarios();
    return (drills, scenarios);
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Lên kế hoạch diễn tập',
        onPressed: () async {
          await pushScreen(context, const DrillFormScreen());
          _reload();
        },
        child: const Icon(Icons.add),
      ),
      body: AsyncBody<(List<Drill>, List<Scenario>)>(
        future: _future,
        builder: (context, data) {
          final (drills, scenarios) = data;
          if (drills.isEmpty) {
            return const EmptyState(icon: Icons.local_fire_department_outlined, message: 'Chưa có đợt diễn tập');
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: drills.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final d = drills[i];
              final sc = scenarios.where((s) => s.id == d.scenarioId).firstOrNull;
              return DrillCard(
                drill: d,
                scenarioCode: sc?.code ?? '',
                onTap: () async {
                  await pushScreen(context, DrillDetailScreen(drillId: d.id));
                  _reload();
                },
              );
            },
          );
        },
      ),
    );
  }
}

class DrillCard extends StatelessWidget {
  const DrillCard({super.key, required this.drill, required this.scenarioCode, required this.onTap});

  final Drill drill;
  final String scenarioCode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final d = drill;
    final stepIndex = d.stage.index + 1;
    final pendingFixes = d.fixes.where((f) => !f.done).length;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(scenarioCode,
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
                  const SizedBox(width: 8),
                  Text(fmtDate(d.date), style: const TextStyle(color: AppColors.textSecondary)),
                  const Spacer(),
                  StatusChip(label: d.stage.label, color: d.stage.color),
                ],
              ),
              const SizedBox(height: 6),
              Text(d.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (var i = 0; i < DrillStage.values.length; i++)
                    Expanded(
                      child: Container(
                        height: 6,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: i < stepIndex ? d.stage.color : AppColors.border,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Bước $stepIndex/${DrillStage.values.length}'
                '${pendingFixes > 0 ? ' · $pendingFixes việc khắc phục chưa xong' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: pendingFixes > 0 ? AppColors.danger : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
