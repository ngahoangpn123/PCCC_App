import 'package:flutter/material.dart';

import 'dossier_list_tab.dart';
import 'facility_info_tab.dart';
import 'form_library_tab.dart';

/// Chức năng 1: Quản lý thông tin và hồ sơ cơ sở (3 tab).
class FacilityHubScreen extends StatelessWidget {
  const FacilityHubScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: initialTab,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hồ sơ cơ sở'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Thông tin'),
              Tab(text: 'Kho biểu mẫu'),
              Tab(text: 'Theo dõi hồ sơ'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [FacilityInfoTab(), FormLibraryTab(), DossierListTab()],
        ),
      ),
    );
  }
}
