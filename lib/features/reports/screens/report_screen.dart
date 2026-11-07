import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/info_section.dart';
import '../../acceptance/models/acceptance.dart';
import '../../drills/models/drill.dart';
import '../../equipment/models/equipment.dart';
import '../../facility/models/dossier.dart';
import '../../team/models/member.dart';
import '../../training/models/training.dart';

class _ReportData {
  const _ReportData({
    required this.dossiers,
    required this.equipment,
    required this.members,
    required this.sessions,
    required this.drills,
    required this.acceptance,
    required this.readiness,
  });

  final List<Dossier> dossiers;
  final List<Equipment> equipment;
  final List<Member> members;
  final List<TrainingSession> sessions;
  final List<Drill> drills;
  final ProjectAcceptance? acceptance;
  final ReadinessSummary readiness;
}

/// Báo cáo tổng hợp tình hình thực hiện trách nhiệm PCCC & CNCH của cơ sở.
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late final Future<_ReportData> _future = _load();

  Future<_ReportData> _load() async => _ReportData(
    dossiers: await Locator.facility.getDossiers(),
    equipment: await Locator.equipment.getEquipment(),
    members: await Locator.team.getMembers(),
    sessions: await Locator.training.getSessions(),
    drills: await Locator.drills.getDrills(),
    acceptance: await Locator.acceptance.getAcceptance(),
    readiness: await Locator.acceptance.getReadinessSummary(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo tổng hợp'),
        actions: [
          IconButton(
            tooltip: 'Xuất báo cáo',
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => showComingSoon(context, 'Xuất báo cáo PDF / Excel'),
          ),
        ],
      ),
      body: AsyncBody<_ReportData>(
        future: _future,
        builder: (context, d) {
          int count<T>(List<T> list, bool Function(T) test) => list.where(test).length;
          final done = d.sessions.where((s) => s.status == SessionStatus.done).toList();
          final hours = done.fold<int>(0, (a, s) => a + s.durationMinutes) / 60;
          final acc = d.acceptance;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ScoreCard(score: d.readiness.score),
              const SizedBox(height: 12),
              InfoSection(
                title: 'Tự nghiệm thu & hậu kiểm',
                icon: Icons.fact_check_outlined,
                children: [
                  InfoRow('Công trình', acc?.projectName ?? 'Không có'),
                  if (acc != null) ...[
                    InfoRow('Tiến độ', '${acc.doneSteps}/6 bước'),
                    InfoRow('Checklist 21 hạng mục', '${acc.passedChecks} đạt · ${acc.failedChecks} không đạt'),
                    InfoRow('Văn bản PC18', acc.pc18Signed ? 'Đã ký số' : 'Chưa ký'),
                  ],
                  InfoRow('Nhóm trách nhiệm', '${d.readiness.groupsDone}/${d.readiness.groupsTotal}'),
                  InfoRow('Hệ thống HT sẵn sàng', '${d.readiness.htReady}/${d.readiness.htTotal}'),
                ],
              ),
              const SizedBox(height: 12),
              InfoSection(
                title: 'Hồ sơ',
                icon: Icons.description_outlined,
                children: [
                  for (final s in DossierStatus.values)
                    InfoRow(s.label, '${count(d.dossiers, (x) => x.status == s)}'),
                ],
              ),
              const SizedBox(height: 12),
              InfoSection(
                title: 'Phương tiện PCCC',
                icon: Icons.fire_extinguisher,
                children: [
                  for (final s in EquipmentStatus.values)
                    InfoRow(s.label, '${count(d.equipment, (x) => x.status == s)}'),
                ],
              ),
              const SizedBox(height: 12),
              InfoSection(
                title: 'Đội PCCC & huấn luyện',
                icon: Icons.groups_outlined,
                children: [
                  InfoRow('Thành viên đang tham gia',
                      '${count(d.members, (m) => m.status != MemberStatus.left)}'),
                  InfoRow('Buổi đã tổ chức', '${done.length}/${d.sessions.length}'),
                  InfoRow('Tổng giờ đã tổ chức', '${hours.toStringAsFixed(1)} giờ'),
                  InfoRow('Buổi chưa thực hiện',
                      '${count(d.sessions, (s) => s.status == SessionStatus.missed)}'),
                ],
              ),
              const SizedBox(height: 12),
              InfoSection(
                title: 'Phương án & thực tập',
                icon: Icons.local_fire_department_outlined,
                children: [
                  InfoRow('Số đợt thực tập', '${d.drills.length}'),
                  InfoRow('Đã đánh giá / khắc phục',
                      '${count(d.drills, (x) => x.stage.index >= DrillStage.evaluate.index)}'),
                  InfoRow('Nhiệm vụ khắc phục còn mở',
                      '${d.drills.expand((x) => x.fixes).where((f) => !f.done).length}'),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 6,
                    backgroundColor: Colors.white24,
                    color: AppColors.gold,
                  ),
                ),
                Text('$score%',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Điểm sẵn sàng hậu kiểm\n(hồ sơ hoàn công, nhóm trách nhiệm, hệ thống HT)',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
