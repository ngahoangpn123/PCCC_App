import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/attachment_list.dart';
import '../../../core/widgets/info_section.dart';
import '../../../core/widgets/status_chip.dart';
import '../../team/models/member.dart';
import '../models/training.dart';
import 'training_session_form_screen.dart';

/// Chi tiết buổi huấn luyện: thông tin, điểm danh + kết quả từng người, đánh giá.
class TrainingSessionDetailScreen extends StatefulWidget {
  const TrainingSessionDetailScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  State<TrainingSessionDetailScreen> createState() => _TrainingSessionDetailScreenState();
}

class _TrainingSessionDetailScreenState extends State<TrainingSessionDetailScreen> {
  late Future<(TrainingSession, List<Member>)> _future;
  final _evaluation = TextEditingController();
  bool _evaluationLoaded = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _evaluation.dispose();
    super.dispose();
  }

  Future<(TrainingSession, List<Member>)> _load() async {
    final s = await Locator.training.getSession(widget.sessionId);
    final members = await Locator.team.getMembers();
    if (!_evaluationLoaded) {
      _evaluation.text = s.evaluation;
      _evaluationLoaded = true;
    }
    return (s, members);
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _save(TrainingSession s, {SessionStatus? newStatus}) async {
    s.evaluation = _evaluation.text.trim();
    if (newStatus != null) s.status = newStatus;
    await Locator.training.saveSession(s);
    if (!mounted) return;
    showSnack(context, 'Đã lưu kết quả buổi huấn luyện');
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBody<(TrainingSession, List<Member>)>(
      future: _future,
      builder: (context, data) {
        final (s, members) = data;
        String nameOf(String id) =>
            members.where((m) => m.id == id).map((m) => m.name).firstOrNull ?? id;
        final passed = s.attendance.where((a) => a.present && a.result == 'Đạt').length;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Buổi huấn luyện'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  await pushScreen(context, TrainingSessionFormScreen(session: s));
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
                    child: OutlinedButton(
                      onPressed: () => _save(s),
                      child: const Text('Lưu'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: s.status == SessionStatus.done
                          ? null
                          : () => _save(s, newStatus: SessionStatus.done),
                      child: const Text('Hoàn thành buổi'),
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
                title: s.title,
                icon: Icons.school_outlined,
                trailing: StatusChip(label: s.status.label, color: s.status.color),
                children: [
                  InfoRow('Thời gian', fmtDateTime(s.date)),
                  InfoRow('Thời lượng', '${s.durationMinutes} phút'),
                  InfoRow('Địa điểm', s.location),
                  InfoRow('Người hướng dẫn', s.instructor),
                  InfoRow('Hình thức', s.format),
                  InfoRow('Nội dung', s.content),
                ],
              ),
              const SizedBox(height: 12),
              InfoSection(
                title: 'Thành phần tham gia',
                icon: Icons.how_to_reg_outlined,
                trailing: Text('Có mặt ${s.presentCount}/${s.attendance.length}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                children: [
                  if (s.attendance.isEmpty)
                    const Text('Chưa chọn thành viên', style: TextStyle(color: AppColors.textSecondary)),
                  for (final a in s.attendance)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Checkbox(
                            value: a.present,
                            onChanged: (v) => setState(() {
                              a.present = v ?? false;
                              if (!a.present) a.result = 'Không đạt';
                            }),
                          ),
                          Expanded(
                            child: Text(
                              nameOf(a.memberId),
                              style: TextStyle(
                                decoration: a.present ? null : TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                          DropdownButton<String>(
                            value: a.result,
                            underline: const SizedBox.shrink(),
                            items: attendanceResults
                                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                                .toList(),
                            onChanged: (v) => setState(() => a.result = v ?? a.result),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              InfoSection(
                title: 'Đánh giá kết quả',
                icon: Icons.assessment_outlined,
                trailing: StatusChip(
                  label: 'Đạt $passed/${s.attendance.length}',
                  color: AppColors.success,
                ),
                children: [
                  TextField(
                    controller: _evaluation,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Nhận xét chung, nội dung cần bổ sung, kế hoạch tiếp theo...',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InfoSection(
                title: 'Minh chứng (ảnh, biên bản, danh sách)',
                icon: Icons.attach_file,
                children: [
                  AttachmentList(
                    files: s.attachments,
                    onAdd: () => showComingSoon(context, 'Đính kèm minh chứng'),
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
