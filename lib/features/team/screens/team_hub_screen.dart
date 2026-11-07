import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/legal/legal_catalog.dart';
import '../../../core/session/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../facility/models/facility.dart';
import 'member_list_tab.dart';
import 'shift_schedule_tab.dart';
import 'task_assignment_tab.dart';
import 'team_alerts_tab.dart';
import 'training_capacity_tab.dart';

/// Quản lý đội PCCC & CNCH: Thành viên, Lịch trực, Năng lực huấn luyện,
/// Phân công nhiệm vụ (+ Cảnh báo).
class TeamHubScreen extends StatelessWidget {
  const TeamHubScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      initialIndex: initialTab,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Đội PCCC & CNCH'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Thành viên'),
              Tab(text: 'Lịch trực'),
              Tab(text: 'Năng lực huấn luyện'),
              Tab(text: 'Phân công nhiệm vụ'),
              Tab(text: 'Cảnh báo'),
            ],
          ),
        ),
        body: const Column(
          children: [
            _OrgModelBanner(),
            Expanded(
              child: TabBarView(
                children: [
                  MemberListTab(),
                  ShiftScheduleTab(),
                  TrainingCapacityTab(),
                  TaskAssignmentTab(),
                  TeamAlertsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mô hình tổ chức lực lượng tự động theo số người làm việc thường xuyên.
class _OrgModelBanner extends StatelessWidget {
  const _OrgModelBanner();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Facility>(
      future: Locator.facility.getFacility(AppSession.instance.currentFacilityId),
      builder: (context, snap) {
        final f = snap.data;
        if (f == null) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.goldLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.account_tree_outlined, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cơ sở có ${f.staffCount} người. ${teamModelFor(f.staffCount)}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Đội PCCC chuyên ngành',
                icon: const Icon(Icons.info_outline, size: 20),
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('Mô hình tổ chức lực lượng'),
                    content: const Text(
                      '• Dưới 20 người: người đứng đầu ban hành văn bản phân công.\n'
                      '• Từ 20 người trở lên: ban hành Quyết định thành lập Đội PCCC & CNCH cơ sở.\n\n'
                      '$specializedTeamNote',
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(c), child: const Text('Đóng')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
