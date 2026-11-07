import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/attachment_list.dart';
import '../../../core/widgets/form_fields.dart';
import '../../../core/widgets/info_section.dart';
import '../models/drill.dart';
import 'drill_form_screen.dart';

/// Chi tiết một đợt diễn tập theo vòng đời 5 bước.
class DrillDetailScreen extends StatefulWidget {
  const DrillDetailScreen({super.key, required this.drillId});

  final String drillId;

  @override
  State<DrillDetailScreen> createState() => _DrillDetailScreenState();
}

class _DrillDetailScreenState extends State<DrillDetailScreen> {
  late Future<(Drill, Scenario?)> _future;
  final _result = TextEditingController();
  final _issues = TextEditingController();
  bool _textLoaded = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _result.dispose();
    _issues.dispose();
    super.dispose();
  }

  Future<(Drill, Scenario?)> _load() async {
    final d = await Locator.drills.getDrill(widget.drillId);
    final scenarios = await Locator.drills.getScenarios();
    if (!_textLoaded) {
      _result.text = d.result;
      _issues.text = d.issues;
      _textLoaded = true;
    }
    return (d, scenarios.where((s) => s.id == d.scenarioId).firstOrNull);
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _save(Drill d, {DrillStage? stage}) async {
    d
      ..result = _result.text.trim()
      ..issues = _issues.text.trim();
    if (stage != null) d.stage = stage;
    await Locator.drills.saveDrill(d);
    if (!mounted) return;
    showSnack(context, stage == null ? 'Đã lưu' : 'Đã chuyển sang bước: ${stage.label}');
    _reload();
  }

  Future<void> _addFix(Drill d) async {
    final title = TextEditingController();
    final assignee = TextEditingController();
    DateTime due = DateTime.now().add(const Duration(days: 14));
    final added = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setDialog) => AlertDialog(
          title: const Text('Giao nhiệm vụ khắc phục'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(label: 'Nội dung', controller: title, required: true),
                AppTextField(label: 'Người thực hiện', controller: assignee),
                DatePickerField(
                  label: 'Thời hạn',
                  value: due,
                  onChanged: (v) => setDialog(() => due = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Hủy')),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Giao việc')),
          ],
        ),
      ),
    );
    if (added != true || title.text.trim().isEmpty) return;
    d.fixes.add(FixTask(title: title.text.trim(), assignee: assignee.text.trim(), due: due));
    await _save(d);
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBody<(Drill, Scenario?)>(
      future: _future,
      builder: (context, data) {
        final (d, sc) = data;
        final current = d.stage.index;
        final isLast = current == DrillStage.values.length - 1;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Đợt diễn tập'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  await pushScreen(context, DrillFormScreen(drill: d));
                  _reload();
                },
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(onPressed: () => _save(d), child: const Text('Lưu')),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: isLast ? null : () => _save(d, stage: DrillStage.values[current + 1]),
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(isLast ? 'Bước cuối' : 'Sang bước tiếp'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              InfoSection(
                title: d.title,
                icon: Icons.local_fire_department_outlined,
                children: [
                  InfoRow('Phương án', sc == null ? '' : '${sc.code} · ${sc.name}'),
                  InfoRow('Thời gian', fmtFullDate(d.date)),
                  InfoRow('Thành phần', d.participants),
                ],
              ),
              const SizedBox(height: 12),
              InfoSection(
                title: 'Vòng đời đợt diễn tập',
                icon: Icons.timeline,
                children: [
                  for (final st in DrillStage.values)
                    _StageTile(stage: st, state: st.index.compareTo(current)),
                ],
              ),
              const SizedBox(height: 12),
              InfoSection(
                title: 'Kết quả, nhận xét',
                icon: Icons.assessment_outlined,
                children: [
                  TextField(
                    controller: _result,
                    maxLines: 3,
                    decoration: const InputDecoration(hintText: 'Thời gian thực tế, diễn biến, nhận xét...'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InfoSection(
                title: 'Vấn đề phát hiện',
                icon: Icons.report_problem_outlined,
                children: [
                  TextField(
                    controller: _issues,
                    maxLines: 3,
                    decoration: const InputDecoration(hintText: 'Những điểm chưa đạt, cần khắc phục...'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InfoSection(
                title: 'Nhiệm vụ khắc phục',
                icon: Icons.task_alt,
                trailing: IconButton(
                  tooltip: 'Giao nhiệm vụ',
                  icon: const Icon(Icons.add_task),
                  onPressed: () => _addFix(d),
                ),
                children: [
                  if (d.fixes.isEmpty)
                    const Text('Chưa có nhiệm vụ', style: TextStyle(color: AppColors.textSecondary)),
                  for (final f in d.fixes)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: f.done,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        f.title,
                        style: TextStyle(decoration: f.done ? TextDecoration.lineThrough : null),
                      ),
                      subtitle: Text(
                        '${f.assignee.isEmpty ? 'Chưa giao' : f.assignee} · Hạn ${fmtDate(f.due)}'
                        '${f.done ? '' : ' (${dueText(f.due)})'}',
                        style: TextStyle(color: f.done ? null : dueColor(f.due)),
                      ),
                      onChanged: (v) async {
                        setState(() => f.done = v ?? false);
                        await Locator.drills.saveDrill(d);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 12),
              InfoSection(
                title: 'Biên bản, ảnh minh chứng',
                icon: Icons.attach_file,
                children: [
                  AttachmentList(
                    files: d.attachments,
                    onAdd: () => showComingSoon(context, 'Đính kèm biên bản'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StageTile extends StatelessWidget {
  const _StageTile({required this.stage, required this.state});

  final DrillStage stage;
  final int state; // <0 đã xong, 0 đang làm, >0 chưa tới

  @override
  Widget build(BuildContext context) {
    final done = state < 0;
    final current = state == 0;
    final color = done ? AppColors.success : (current ? AppColors.primary : AppColors.neutral);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: done || current ? color : AppColors.border,
            child: done
                ? const Icon(Icons.check, size: 15, color: Colors.white)
                : Text(
                    '${stage.index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      color: current ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stage.label,
                  style: TextStyle(
                    fontWeight: current ? FontWeight.w700 : FontWeight.w500,
                    color: state > 0 ? AppColors.textSecondary : AppColors.textPrimary,
                  ),
                ),
                if (current)
                  Text(stage.description,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
