import 'package:flutter/material.dart';

import 'member_list_tab.dart';
import 'shift_schedule_tab.dart';
import 'team_alerts_tab.dart';

/// Chức năng 2: Quản lý đội PCCC & CNCH.
class TeamHubScreen extends StatelessWidget {
  const TeamHubScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: initialTab,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Đội PCCC & CNCH'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Thành viên'),
              Tab(text: 'Lịch trực'),
              Tab(text: 'Cảnh báo'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [MemberListTab(), ShiftScheduleTab(), TeamAlertsTab()],
        ),
      ),
    );
  }
}
