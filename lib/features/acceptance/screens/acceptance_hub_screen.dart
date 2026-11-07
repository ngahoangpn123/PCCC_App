import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_chip.dart';
import '../models/acceptance.dart';
import 'acceptance_step_screen.dart';
import 'inspection_mode_screen.dart';
import 'pc01_declaration_screen.dart';
import 'readiness_screen.dart';

/// Module trọng tâm: Tự nghiệm thu PCCC (PC18) & Sẵn sàng hậu kiểm.
class AcceptanceHubScreen extends StatefulWidget {
  const AcceptanceHubScreen({super.key});

  @override
  State<AcceptanceHubScreen> createState() => _AcceptanceHubScreenState();
}

class _AcceptanceHubScreenState extends State<AcceptanceHubScreen> {
  late Future<(ProjectAcceptance?, ReadinessSummary, Pc01Declaration)> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(ProjectAcceptance?, ReadinessSummary, Pc01Declaration)> _load() async {
    final repo = Locator.acceptance;
    return (await repo.getAcceptance(), await repo.getReadinessSummary(), await repo.getPc01());
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _start() async {
    final ctrl = TextEditingController(text: 'Cải tạo / thi công mới hạng mục ...');
    final name = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Khởi tạo tự nghiệm thu'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Tên công trình / hạng mục'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Hủy')),
          FilledButton(
            onPressed: () => Navigator.pop(c, ctrl.text.trim()),
            child: const Text('Khởi tạo'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    await Locator.acceptance.startAcceptance(name);
    _reload();
  }

  Future<void> _signPc18(ProjectAcceptance a) async {
    final blockers = a.pc18Blockers;
    if (blockers.isNotEmpty) {
      await showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          icon: const Icon(Icons.block, color: AppColors.danger),
          title: const Text('Chưa đủ điều kiện ký PC18'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [for (final b in blockers) Text('• $b')],
          ),
          actions: [
            FilledButton(onPressed: () => Navigator.pop(c), child: const Text('Đã hiểu')),
          ],
        ),
      );
      return;
    }
    final ok = await confirmDialog(
      context,
      title: 'Ký số Văn bản PC18',
      message: 'Ký số Văn bản nghiệm thu PCCC của chủ đầu tư và đồng bộ lên CSDL Quốc gia?',
      confirmLabel: 'Ký số',
    );
    if (!ok) return;
    // TODO: tích hợp chữ ký số + API CSDL Quốc gia. Hiện giả lập kết quả.
    a.pc18Signed = true;
    a.pc18SignedAt = DateTime.now();
    a.asBuiltParts[asBuiltPartNames.last] = true;
    // Bước 5 xong khi đã ký PC18 VÀ đủ 6 thành phần hồ sơ hoàn công.
    if (a.asBuiltDone == a.asBuiltParts.length) {
      a.steps[4].status = StepStatus.done;
      a.steps[4].completedAt = DateTime.now();
      a.steps[5].status = StepStatus.inProgress;
    } else {
      a.steps[4].status = StepStatus.inProgress;
    }
    await Locator.acceptance.saveAcceptance(a);
    if (!mounted) return;
    showSnack(context, 'Đã ký số PC18 (giả lập). Tiếp tục Bước 6 để khai báo CSDL.');
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tự nghiệm thu & hậu kiểm')),
      body: AsyncBody<(ProjectAcceptance?, ReadinessSummary, Pc01Declaration)>(
        future: _future,
        builder: (context, data) {
          final (acc, summary, pc01) = data;
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                if (acc == null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      child: EmptyState(
                        icon: Icons.fact_check_outlined,
                        message: 'Cơ sở chưa có công trình cần tự nghiệm thu.\n'
                            'Khởi tạo khi thi công mới, cải tạo hoặc thay đổi công năng.',
                        actionLabel: 'Khởi tạo tự nghiệm thu',
                        onAction: _start,
                      ),
                    ),
                  )
                else ...[
                  _ProgressHeader(acc: acc),
                  const SectionHeader('Quy trình 6 bước'),
                  for (final s in acc.steps)
                    _StepTile(
                      step: s,
                      onTap: () async {
                        await pushScreen(context, AcceptanceStepScreen(acceptance: acc, stepNo: s.no));
                        _reload();
                      },
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: acc.pc18Signed ? null : () => _signPc18(acc),
                      icon: const Icon(Icons.draw_outlined),
                      label: Text(acc.pc18Signed
                          ? 'Đã ký PC18 lúc ${fmtDateTime(acc.pc18SignedAt!)}'
                          : 'Ký số lập văn bản PC18 & đồng bộ CSDL'),
                    ),
                  ),
                ],
                SectionHeader(
                  'Sẵn sàng hậu kiểm',
                  actionLabel: 'Chi tiết',
                  onAction: () async {
                    await pushScreen(context, const ReadinessScreen());
                    _reload();
                  },
                ),
                _ReadinessDashboard(summary: summary, onOpen: () async {
                  await pushScreen(context, const ReadinessScreen());
                  _reload();
                }),
                const SectionHeader('Khai báo CSDL Quốc gia'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.cloud_upload_outlined, color: AppColors.primary),
                      title: const Text('Phiếu thông tin cơ sở (PC01)'),
                      subtitle: Text(pc01.lastSyncedAt == null
                          ? 'Chưa đồng bộ'
                          : 'Đồng bộ lần cuối ${fmtDate(pc01.lastSyncedAt!)}'),
                      trailing: StatusChip(label: pc01.status.label, color: pc01.status.color),
                      onTap: () async {
                        await pushScreen(context, const Pc01DeclarationScreen());
                        _reload();
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.info,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: () async {
                      await pushScreen(context, const InspectionModeScreen());
                      _reload();
                    },
                    icon: const Icon(Icons.qr_code_2),
                    label: const Text('Bật chế độ tiếp đoàn hậu kiểm (QR)'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.acc});

  final ProjectAcceptance acc;

  @override
  Widget build(BuildContext context) {
    final ratio = acc.doneSteps / acc.steps.length;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Công trình đang tự nghiệm thu',
              style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Text(acc.projectName,
              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: Colors.white24,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hoàn thành ${acc.doneSteps}/${acc.steps.length} bước · '
            'Checklist ${acc.passedChecks}/${acc.checklist.length} đạt'
            '${acc.failedChecks > 0 ? ' · ${acc.failedChecks} không đạt' : ''}',
            style: const TextStyle(color: Colors.white, fontSize: 12.5),
          ),
          if (acc.synced) ...[
            const SizedBox(height: 6),
            Text('Mã biên nhận CSDL: ${acc.receiptCode}',
                style: const TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.step, required this.onTap});

  final AcceptanceStep step;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: step.status.color.withValues(alpha: 0.15),
          child: step.status == StepStatus.done
              ? Icon(Icons.check, color: step.status.color)
              : Text('${step.no}',
                  style: TextStyle(color: step.status.color, fontWeight: FontWeight.w700)),
        ),
        title: Text(step.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: StatusChip(label: step.status.label, color: step.status.color),
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _ReadinessDashboard extends StatelessWidget {
  const _ReadinessDashboard({required this.summary, required this.onOpen});

  final ReadinessSummary summary;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final insp = summary.inspection;
    Widget tile(IconData icon, String label, String value, Color color) => Expanded(
      child: Card(
        margin: const EdgeInsets.all(4),
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(height: 8),
                Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
                const SizedBox(height: 2),
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      ),
    );
    Color c(int a, int b) => a >= b ? AppColors.success : AppColors.warning;
    final selfCheckLate =
        insp.nextSelfCheck != null && insp.nextSelfCheck!.isBefore(DateTime.now());
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Row(children: [
            tile(Icons.folder_copy_outlined, 'Hồ sơ hoàn công',
                '${summary.asBuiltDone}/${summary.asBuiltTotal}',
                c(summary.asBuiltDone, summary.asBuiltTotal)),
            tile(Icons.rule, 'Nhóm trách nhiệm', '${summary.groupsDone}/${summary.groupsTotal}',
                c(summary.groupsDone, summary.groupsTotal)),
          ]),
          Row(children: [
            tile(Icons.build_circle_outlined, 'Hệ thống HT sẵn sàng',
                '${summary.htReady}/${summary.htTotal}', c(summary.htReady, summary.htTotal)),
            tile(
              Icons.checklist,
              insp.lastSelfCheck == null
                  ? 'Tự kiểm tra PC02'
                  : 'PC02 gần nhất ${fmtDayMonth(insp.lastSelfCheck!)}',
              insp.nextSelfCheck == null ? '—' : 'Hạn ${fmtDayMonth(insp.nextSelfCheck!)}',
              selfCheckLate ? AppColors.danger : AppColors.success,
            ),
          ]),
          Card(
            margin: const EdgeInsets.all(4),
            child: ListTile(
              onTap: onOpen,
              leading: const Icon(Icons.event_available, color: AppColors.info),
              title: Text(insp.nextInspection == null
                  ? 'Chưa có lịch hậu kiểm'
                  : 'Hậu kiểm: ${fmtFullDate(insp.nextInspection!)}'),
              subtitle: Text(insp.agency.isEmpty ? 'Chưa rõ cơ quan kiểm tra' : insp.agency),
              trailing: _ScoreBadge(score: summary.score),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final color = score >= 90
        ? AppColors.success
        : score >= 70
            ? AppColors.warning
            : AppColors.danger;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('$score%', style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 16)),
        const Text('sẵn sàng', style: TextStyle(fontSize: 10.5)),
      ],
    );
  }
}
