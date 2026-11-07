import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/session/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../facility/models/facility.dart';

/// Chọn cơ sở đang quản lý (khi một tài khoản quản lý nhiều cơ sở).
class FacilitySwitchScreen extends StatelessWidget {
  const FacilitySwitchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = AppSession.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn cơ sở')),
      body: AsyncBody<List<Facility>>(
        future: Locator.facility.getFacilities(),
        builder: (context, list) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Toàn bộ dữ liệu, thông báo và nhiệm vụ sẽ thay đổi theo cơ sở được chọn.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            for (final f in list)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: f.id == session.currentFacilityId ? AppColors.primary : AppColors.border,
                      width: f.id == session.currentFacilityId ? 1.5 : 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: const Icon(Icons.apartment, color: AppColors.primary),
                    title: Text(f.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${f.code}\n${f.address}'),
                    isThreeLine: true,
                    trailing: f.id == session.currentFacilityId
                        ? const Icon(Icons.check_circle, color: AppColors.primary)
                        : null,
                    onTap: () {
                      session.switchFacility(f.id, f.name);
                      showSnack(context, 'Đã chuyển sang ${f.name}');
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
