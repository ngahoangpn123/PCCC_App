import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/session/app_session.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/info_section.dart';
import '../models/facility.dart';
import 'facility_edit_screen.dart';

class FacilityInfoTab extends StatefulWidget {
  const FacilityInfoTab({super.key});

  @override
  State<FacilityInfoTab> createState() => _FacilityInfoTabState();
}

class _FacilityInfoTabState extends State<FacilityInfoTab> {
  late Future<Facility> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = Locator.facility.getFacility(AppSession.instance.currentFacilityId);
  }

  Future<void> _edit(Facility f) async {
    final saved = await pushScreen<bool>(context, FacilityEditScreen(facility: f));
    if (saved == true) setState(_load);
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBody<Facility>(
      future: _future,
      builder: (context, f) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InfoSection(
            title: 'Thông tin chung',
            icon: Icons.apartment,
            children: [
              InfoRow('Tên cơ sở', f.name),
              InfoRow('Mã cơ sở', f.code),
              InfoRow('Địa chỉ', f.address),
            ],
          ),
          const SizedBox(height: 12),
          InfoSection(
            title: 'Loại hình & quy mô',
            icon: Icons.category_outlined,
            children: [
              InfoRow('Loại hình', f.type),
              InfoRow('Lĩnh vực', f.field),
              InfoRow('Quy mô', f.scale),
              InfoRow('Đặc điểm công trình', f.buildingInfo),
            ],
          ),
          const SizedBox(height: 12),
          InfoSection(
            title: 'Người chịu trách nhiệm',
            icon: Icons.badge_outlined,
            children: [
              InfoRow('Người đứng đầu', f.headName),
              InfoRow('Điện thoại', f.headPhone),
              InfoRow('Phụ trách PCCC & CNCH', f.officerName),
              InfoRow('Điện thoại', f.officerPhone),
              InfoRow('Email liên hệ', f.email),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _edit(f),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Chỉnh sửa thông tin'),
          ),
        ],
      ),
    );
  }
}
