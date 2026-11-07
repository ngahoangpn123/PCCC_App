import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ui_helpers.dart';
import '../management_modules.dart';

/// Tab "Quản lý": 6 module nghiệp vụ (Tự nghiệm thu là trọng tâm) + Báo cáo tổng hợp.
class ManagementScreen extends StatelessWidget {
  const ManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final modules = managementModules;
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: modules.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final m = modules[i];
          final isReport = i == modules.length - 1;
          return Card(
            clipBehavior: Clip.antiAlias,
            shape: m.highlight
                ? RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                  )
                : null,
            child: InkWell(
              onTap: () => pushScreen(context, m.builder()),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: m.highlight ? AppColors.primary : AppColors.goldLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        m.icon,
                        color: m.highlight ? Colors.white : AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  isReport ? m.title : '${i + 1}. ${m.title}',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                ),
                              ),
                              if (m.highlight) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.danger,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'TRỌNG TÂM',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            m.subtitle,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
