import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/info_section.dart';
import '../../../core/widgets/person_avatar.dart';
import '../models/member.dart';
import 'member_detail_screen.dart';
import 'member_form_screen.dart';

/// Phân công nhiệm vụ trong đội, nhóm theo chức vụ.
class TaskAssignmentTab extends StatefulWidget {
  const TaskAssignmentTab({super.key});

  @override
  State<TaskAssignmentTab> createState() => _TaskAssignmentTabState();
}

class _TaskAssignmentTabState extends State<TaskAssignmentTab> {
  late Future<List<Member>> _future = Locator.team.getMembers();

  void _reload() => setState(() => _future = Locator.team.getMembers());

  @override
  Widget build(BuildContext context) {
    return AsyncBody<List<Member>>(
      future: _future,
      builder: (context, all) {
        final members = all.where((m) => m.status != MemberStatus.left).toList();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            OutlinedButton.icon(
              onPressed: () => showComingSoon(
                context,
                'Xuất Văn bản phân công / Quyết định thành lập Đội',
              ),
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Xuất văn bản phân công / Quyết định thành lập'),
            ),
            const SizedBox(height: 12),
            for (final role in memberRoles)
              if (members.any((m) => m.role == role)) ...[
                InfoSection(
                  title: role,
                  icon: Icons.badge_outlined,
                  children: [
                    for (final m in members.where((m) => m.role == role))
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: PersonAvatar(m.name),
                        title: Text(m.name),
                        subtitle: Text(
                          m.duty.isEmpty ? 'Chưa phân công nhiệm vụ' : m.duty,
                          style: TextStyle(
                            color: m.duty.isEmpty ? AppColors.danger : AppColors.textSecondary,
                          ),
                        ),
                        trailing: IconButton(
                          tooltip: 'Sửa phân công',
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () async {
                            await pushScreen(context, MemberFormScreen(member: m));
                            _reload();
                          },
                        ),
                        onTap: () => pushScreen(context, MemberDetailScreen(memberId: m.id)),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
          ],
        );
      },
    );
  }
}
