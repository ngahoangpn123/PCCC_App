import 'package:flutter/material.dart';

import '../acceptance/screens/acceptance_hub_screen.dart';
import '../drills/screens/drill_hub_screen.dart';
import '../equipment/screens/equipment_list_screen.dart';
import '../facility/screens/facility_hub_screen.dart';
import '../reports/screens/report_screen.dart';
import '../team/screens/team_hub_screen.dart';
import '../training/screens/training_hub_screen.dart';

/// Một module trong "Danh mục quản lý".
class ManagementModule {
  const ManagementModule({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.builder,
    this.highlight = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget Function() builder;
  final bool highlight; // module trọng tâm
}

/// 6 module nghiệp vụ + Báo cáo tổng hợp (theo bản đặc tả).
final managementModules = <ManagementModule>[
  ManagementModule(
    icon: Icons.fact_check_outlined,
    title: 'Tự nghiệm thu & hậu kiểm',
    subtitle: 'Quy trình 6 bước PC18, khai báo PC01, sẵn sàng hậu kiểm',
    builder: () => const AcceptanceHubScreen(),
    highlight: true,
  ),
  ManagementModule(
    icon: Icons.business_outlined,
    title: 'Hồ sơ cơ sở',
    subtitle: 'Thông tin cơ sở, kho 18 mẫu PC + Mẫu TT 36, hồ sơ',
    builder: () => const FacilityHubScreen(),
  ),
  ManagementModule(
    icon: Icons.groups_outlined,
    title: 'Đội PCCC & CNCH',
    subtitle: 'Thành viên, lịch trực, năng lực huấn luyện, phân công',
    builder: () => const TeamHubScreen(),
  ),
  ManagementModule(
    icon: Icons.fire_extinguisher,
    title: 'Phương tiện PCCC',
    subtitle: 'Theo nhóm HT1–HT16, kiểm tra, Sổ theo dõi Mẫu 01',
    builder: () => const EquipmentListScreen(),
  ),
  ManagementModule(
    icon: Icons.school_outlined,
    title: 'Huấn luyện, bồi dưỡng',
    subtitle: 'Kế hoạch, buổi học, điểm danh, giờ huấn luyện',
    builder: () => const TrainingHubScreen(),
  ),
  ManagementModule(
    icon: Icons.local_fire_department_outlined,
    title: 'Phương án & thực tập',
    subtitle: 'Phương án PC06/PC07, Mẫu 02, các đợt thực tập',
    builder: () => const DrillHubScreen(),
  ),
  ManagementModule(
    icon: Icons.bar_chart_outlined,
    title: 'Báo cáo tổng hợp',
    subtitle: 'Tổng hợp tình hình thực hiện trách nhiệm PCCC & CNCH',
    builder: () => const ReportScreen(),
  ),
];
