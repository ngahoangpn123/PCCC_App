import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/session/app_session.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/info_section.dart';
import '../../../core/legal/legal_catalog.dart';
import '../../../core/theme/app_colors.dart';
import '../models/facility.dart';
import 'dossier_form_screen.dart';
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
              InfoRow('Số người làm việc', f.staffCount == 0 ? '' : '${f.staffCount} người'),
              InfoRow('Nguy hiểm cháy, nổ', f.hazard),
            ],
          ),
          const SizedBox(height: 12),
          InfoSection(
            title: 'Vị trí & phân cấp quản lý',
            icon: Icons.place_outlined,
            children: [
              InfoRow('Tọa độ', f.hasCoordinates ? '${f.lat}, ${f.lng}' : 'Chưa cập nhật'),
              InfoRow('Phân cấp quản lý', f.managementLevel),
              InfoRow('Mô hình lực lượng', teamModelFor(f.staffCount)),
              InfoRow('Thi công / cải tạo', f.hasConstruction ? 'Có – cần tự nghiệm thu PC18' : 'Không'),
            ],
          ),
          const SizedBox(height: 12),
          InfoSection(
            title: 'Hồ sơ bắt buộc (gợi ý)',
            icon: Icons.task_alt,
            children: [
              for (final (code, name) in requiredDossiersFor(f))
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.description_outlined, color: AppColors.primary),
                  title: Text('$code – $name'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => pushScreen(context, DossierFormScreen(presetFormCode: code)),
                ),
              const Text(
                'Danh sách gợi ý dựa trên thông tin cơ sở; đối chiếu lại với quy định hiện hành.',
                style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
              ),
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

/// Gợi ý các hồ sơ cơ sở cần có. TODO: hoàn thiện theo phụ lục chính thức.
List<(String, String)> requiredDossiersFor(Facility f) => [
  ('PC01', 'Phiếu thông tin về cơ sở'),
  ('PC02', 'Biên bản tự kiểm tra định kỳ hằng tháng'),
  ('PC06', 'Phương án chữa cháy, CNCH của cơ sở'),
  ('TT36-M01', 'Sổ theo dõi phương tiện PCCC, CNCH'),
  if (f.hasConstruction) ('PC12', 'Văn bản thẩm định thiết kế về PCCC'),
  if (f.hasConstruction) ('PC18', 'Văn bản nghiệm thu PCCC của chủ đầu tư'),
];
