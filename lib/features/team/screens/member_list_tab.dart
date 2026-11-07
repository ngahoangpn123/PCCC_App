import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/choice_filter_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/person_avatar.dart';
import '../../../core/widgets/search_box.dart';
import '../../../core/widgets/status_chip.dart';
import '../models/member.dart';
import 'member_detail_screen.dart';
import 'member_form_screen.dart';

class MemberListTab extends StatefulWidget {
  const MemberListTab({super.key});

  @override
  State<MemberListTab> createState() => _MemberListTabState();
}

class _MemberListTabState extends State<MemberListTab> {
  late Future<List<Member>> _future;
  MemberStatus? _status;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = Locator.team.getMembers();
  }

  void _reload() => setState(() => _future = Locator.team.getMembers());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Thêm thành viên',
        onPressed: () async {
          await pushScreen(context, const MemberFormScreen());
          _reload();
        },
        child: const Icon(Icons.person_add_alt_1),
      ),
      body: AsyncBody<List<Member>>(
        future: _future,
        builder: (context, all) {
          final q = _query.toLowerCase();
          final list = all.where((m) {
            return (_status == null || m.status == _status) &&
                (q.isEmpty ||
                    m.name.toLowerCase().contains(q) ||
                    m.code.toLowerCase().contains(q));
          }).toList();
          final activeCount = all.where((m) => m.status == MemberStatus.active).length;

          return Column(
            children: [
              SearchBox(
                hint: 'Tìm theo tên hoặc mã thành viên',
                onChanged: (v) => setState(() => _query = v),
              ),
              ChoiceFilterBar<MemberStatus?>(
                options: [null, ...MemberStatus.values],
                selected: _status,
                labelOf: (s) => s?.label ?? 'Tất cả (${all.length})',
                onSelected: (s) => setState(() => _status = s),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: Row(
                  children: [
                    const Icon(Icons.groups, size: 18, color: AppColors.success),
                    const SizedBox(width: 6),
                    Text('Đang tham gia: $activeCount / ${all.length} thành viên'),
                  ],
                ),
              ),
              Expanded(
                child: list.isEmpty
                    ? const EmptyState(icon: Icons.person_off, message: 'Không có thành viên')
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final m = list[i];
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: ListTile(
                              onTap: () async {
                                await pushScreen(context, MemberDetailScreen(memberId: m.id));
                                _reload();
                              },
                              leading: PersonAvatar(m.name),
                              title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text('${m.role} · ${m.duty}', maxLines: 1, overflow: TextOverflow.ellipsis),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  StatusChip(label: m.status.label, color: m.status.color),
                                  if (!m.trainingOk)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Icon(Icons.school, size: 16, color: AppColors.danger),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
