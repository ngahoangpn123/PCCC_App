import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/info_section.dart';
import '../models/drill.dart';
import 'drill_detail_screen.dart';
import 'drill_form_screen.dart';
import 'drill_hub_screen.dart';
import 'scenario_form_screen.dart';

class ScenarioDetailScreen extends StatefulWidget {
  const ScenarioDetailScreen({super.key, required this.scenarioId});

  final String scenarioId;

  @override
  State<ScenarioDetailScreen> createState() => _ScenarioDetailScreenState();
}

class _ScenarioDetailScreenState extends State<ScenarioDetailScreen> {
  late Future<(Scenario, List<Drill>)> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(Scenario, List<Drill>)> _load() async {
    final sc = await Locator.drills.getScenario(widget.scenarioId);
    final drills = await Locator.drills.getDrills(scenarioId: widget.scenarioId);
    return (sc, drills);
  }

  void _reload() => setState(() => _future = _load());

  Widget _bullets(List<String> items, {bool numbered = false}) {
    if (items.isEmpty) {
      return const Text('Chưa có', style: TextStyle(color: AppColors.textSecondary));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  child: Text(numbered ? '${i + 1}.' : '•',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                ),
                Expanded(child: Text(items[i])),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBody<(Scenario, List<Drill>)>(
      future: _future,
      builder: (context, data) {
        final (sc, drills) = data;
        return Scaffold(
          appBar: AppBar(
            title: Text('Phương án ${sc.code}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  await pushScreen(context, ScenarioFormScreen(scenario: sc));
                  _reload();
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              await pushScreen(context, DrillFormScreen(presetScenarioId: sc.id));
              _reload();
            },
            icon: const Icon(Icons.event_available),
            label: const Text('Lên kế hoạch diễn tập'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            children: [
              InfoSection(
                title: sc.name,
                icon: Icons.description_outlined,
                children: [
                  InfoRow('Biểu mẫu', sc.formType),
                  InfoRow('Loại hình', sc.type),
                  InfoRow('Địa điểm', sc.location),
                  InfoRow('Phạm vi', sc.scope),
                  InfoRow('Người chỉ huy', sc.commander),
                  InfoRow('Mục tiêu', sc.objective),
                ],
              ),
              const SizedBox(height: 12),
              InfoSection(
                title: 'Lực lượng tham gia',
                icon: Icons.groups_outlined,
                children: [_bullets(sc.forces)],
              ),
              const SizedBox(height: 12),
              InfoSection(
                title: 'Phương tiện, thiết bị huy động',
                icon: Icons.fire_truck_outlined,
                children: [_bullets(sc.equipment)],
              ),
              const SizedBox(height: 12),
              InfoSection(
                title: 'Các bước thực hiện',
                icon: Icons.format_list_numbered,
                children: [_bullets(sc.steps, numbered: true)],
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(4, 20, 4, 8),
                child: Text('Các lần thực tập, diễn tập',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
              if (drills.isEmpty)
                const Text('Chưa tổ chức lần nào', style: TextStyle(color: AppColors.textSecondary)),
              for (final d in drills)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: DrillCard(
                    drill: d,
                    scenarioCode: sc.code,
                    onTap: () async {
                      await pushScreen(context, DrillDetailScreen(drillId: d.id));
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
