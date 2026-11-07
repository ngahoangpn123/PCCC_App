import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/async_body.dart';
import '../models/user_account.dart';

class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nhật ký hoạt động (Audit Log)')),
      body: AsyncBody<List<ActivityLog>>(
        future: Locator.profile.getActivityLogs(),
        builder: (context, logs) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: logs.length,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (context, i) => ListTile(
            leading: const Icon(Icons.history, color: AppColors.primary),
            title: Text(logs[i].action),
            subtitle: Text(fmtDateTime(logs[i].time)),
          ),
        ),
      ),
    );
  }
}
