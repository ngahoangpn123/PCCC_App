import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../drills/screens/drill_hub_screen.dart';
import '../../equipment/screens/equipment_list_screen.dart';
import '../../facility/screens/facility_hub_screen.dart';
import '../../team/screens/team_hub_screen.dart';
import '../../training/screens/training_hub_screen.dart';

/// Tab "Quản lý": cửa vào 5 nhóm chức năng nghiệp vụ.
class ManagementScreen extends StatelessWidget {
  const ManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final modules = <_Module>[
      _Module(
        number: 1,
        icon: Icons.business_outlined,
        title: 'Thông tin & hồ sơ cơ sở',
        description: 'Thông tin cơ sở, kho biểu mẫu PC, theo dõi trạng thái hồ sơ',
        screen: const FacilityHubScreen(),
      ),
      _Module(
        number: 2,
        icon: Icons.groups_outlined,
        title: 'Đội PCCC & CNCH',
        description: 'Thành viên, lịch trực, cảnh báo thiếu người / trùng lịch',
        screen: const TeamHubScreen(),
      ),
      _Module(
        number: 3,
        icon: Icons.fire_extinguisher,
        title: 'Phương tiện & thiết bị',
        description: 'Danh sách thiết bị, lịch kiểm tra, bảo dưỡng, minh chứng',
        screen: const EquipmentListScreen(),
      ),
      _Module(
        number: 4,
        icon: Icons.school_outlined,
        title: 'Huấn luyện, bồi dưỡng',
        description: 'Kế hoạch, buổi huấn luyện, điểm danh, kết quả từng thành viên',
        screen: const TrainingHubScreen(),
      ),
      _Module(
        number: 5,
        icon: Icons.local_fire_department_outlined,
        title: 'Phương án, thực tập, diễn tập',
        description: 'Phương án, các đợt diễn tập, đánh giá và nhiệm vụ khắc phục',
        screen: const DrillHubScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: modules.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final m = modules[i];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => pushScreen(context, m.screen),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.goldLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(m.icon, color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${m.number}. ${m.title}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            m.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.neutral),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Module {
  const _Module({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
    required this.screen,
  });

  final int number;
  final IconData icon;
  final String title;
  final String description;
  final Widget screen;
}
