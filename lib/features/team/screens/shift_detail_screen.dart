import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/info_section.dart';
import '../../../core/widgets/person_avatar.dart';
import '../../../core/widgets/status_chip.dart';
import '../models/member.dart';
import '../models/shift.dart';
import 'member_detail_screen.dart';
import 'shift_form_screen.dart';

class ShiftDetailScreen extends StatefulWidget {
  const ShiftDetailScreen({super.key, required this.shiftId});

  final String shiftId;

  @override
  State<ShiftDetailScreen> createState() => _ShiftDetailScreenState();
}

class _ShiftDetailScreenState extends State<ShiftDetailScreen> {
  late Future<(Shift, List<Member>)> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(Shift, List<Member>)> _load() async {
    final shift = await Locator.team.getShift(widget.shiftId);
    final members = await Locator.team.getMembers();
    return (shift, members);
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _toggleConfirm(Shift s, String memberId) async {
    setState(() {
      if (s.confirmedIds.contains(memberId)) {
        s.confirmedIds.remove(memberId);
      } else {
        s.confirmedIds.add(memberId);
      }
    });
    await Locator.team.saveShift(s);
  }

  Future<void> _changeStatus(Shift s) async {
    final picked = await showModalBottomSheet<ShiftStatus>(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final st in ShiftStatus.values)
              ListTile(
                leading: Icon(Icons.circle, size: 14, color: st.color),
                title: Text(st.label),
                trailing: st == s.status ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(c, st),
              ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    s.status = picked;
    await Locator.team.saveShift(s);
    _reload();
  }

  Future<void> _editNote(Shift s, {required bool handover}) async {
    final controller = TextEditingController(text: handover ? s.handoverNote : s.absentNote);
    final result = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(handover ? 'Ghi chú bàn giao ca' : 'Vắng mặt / người thay thế'),
        content: TextField(controller: controller, maxLines: 4, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(c, controller.text), child: const Text('Lưu')),
        ],
      ),
    );
    if (result == null) return;
    if (handover) {
      s.handoverNote = result.trim();
    } else {
      s.absentNote = result.trim();
    }
    await Locator.team.saveShift(s);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBody<(Shift, List<Member>)>(
      future: _future,
      builder: (context, data) {
        final (s, members) = data;
        Member? byId(String id) => members.where((m) => m.id == id).firstOrNull;
        final leader = byId(s.leaderId);
        final progress = s.requiredCount == 0 ? 1.0 : (s.confirmedIds.length / s.requiredCount).clamp(0.0, 1.0);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Chi tiết ca trực'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  await pushScreen(context, ShiftFormScreen(shift: s));
                  _reload();
                },
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: FilledButton.icon(
                onPressed: () => _changeStatus(s),
                icon: const Icon(Icons.swap_vert),
                label: Text('Trạng thái: ${s.status.label}'),
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              InfoSection(
                title: fmtFullDate(s.date),
                icon: Icons.event,
                trailing: StatusChip(label: s.status.label, color: s.status.color),
                children: [
                  InfoRow('Khung giờ', s.timeRange),
                  InfoRow('Địa điểm', s.location),
                  InfoRow('Người phụ trách', leader?.name ?? '—'),
                ],
              ),
              const SizedBox(height: 12),
              InfoSection(
                title: 'Quân số',
                icon: Icons.groups,
                trailing: s.understaffed
                    ? const StatusChip(label: 'Thiếu người', color: AppColors.danger, icon: Icons.warning)
                    : null,
                children: [
                  Row(
                    children: [
                      _Count(label: 'Cần có', value: s.requiredCount, color: AppColors.textPrimary),
                      _Count(
                        label: 'Phân công',
                        value: s.memberIds.length,
                        color: s.understaffed ? AppColors.danger : AppColors.success,
                      ),
                      _Count(label: 'Đã xác nhận', value: s.confirmedIds.length, color: AppColors.info),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: AppColors.border,
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InfoSection(
                title: 'Thành viên được phân công',
                icon: Icons.person_outline,
                children: [
                  const Text(
                    'Chạm vào tên để mở hồ sơ, chạm biểu tượng bên phải để xác nhận.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  for (final id in s.memberIds)
                    Builder(
                      builder: (context) {
                        final m = byId(id);
                        final confirmed = s.confirmedIds.contains(id);
                        final away = m != null && m.status == MemberStatus.away;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: PersonAvatar(m?.name ?? '?', radius: 18),
                          title: Text(m?.name ?? 'Không rõ'),
                          subtitle: Text(
                            away ? 'Đang tạm vắng!' : (m?.duty ?? ''),
                            style: TextStyle(color: away ? AppColors.danger : null),
                          ),
                          onTap: m == null
                              ? null
                              : () => pushScreen(context, MemberDetailScreen(memberId: m.id)),
                          trailing: IconButton(
                            tooltip: confirmed ? 'Bỏ xác nhận' : 'Xác nhận',
                            icon: Icon(
                              confirmed ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: confirmed ? AppColors.success : AppColors.neutral,
                            ),
                            onPressed: () => _toggleConfirm(s, id),
                          ),
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 12),
              InfoSection(
                title: 'Vắng mặt, người thay thế',
                icon: Icons.person_off_outlined,
                trailing: IconButton(
                  icon: const Icon(Icons.edit_note),
                  onPressed: () => _editNote(s, handover: false),
                ),
                children: [Text(s.absentNote.isEmpty ? 'Không có' : s.absentNote)],
              ),
              const SizedBox(height: 12),
              InfoSection(
                title: 'Ghi chú bàn giao ca, vấn đề phát sinh',
                icon: Icons.sticky_note_2_outlined,
                trailing: IconButton(
                  icon: const Icon(Icons.edit_note),
                  onPressed: () => _editNote(s, handover: true),
                ),
                children: [Text(s.handoverNote.isEmpty ? 'Chưa có ghi chú' : s.handoverNote)],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.label, required this.value, required this.color});

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text('$value', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
