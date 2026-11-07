import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/choice_filter_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/search_box.dart';
import '../../../core/widgets/status_chip.dart';
import '../models/dossier.dart';
import '../models/form_template.dart';
import 'form_template_detail_screen.dart';

/// Kho biểu mẫu: tìm theo mã, tên, mục đích và lọc theo trạng thái hồ sơ.
class FormLibraryTab extends StatefulWidget {
  const FormLibraryTab({super.key});

  @override
  State<FormLibraryTab> createState() => _FormLibraryTabState();
}

class _FormLibraryTabState extends State<FormLibraryTab> {
  late Future<(List<FormTemplate>, List<Dossier>)> _future;
  String _query = '';
  String _filter = 'Tất cả';

  static const _filters = ['Tất cả', 'Mẫu PC (NĐ 105)', 'Mẫu TT 36', 'Mẫu mới', 'Đã có hồ sơ', 'Chưa có hồ sơ'];

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(List<FormTemplate>, List<Dossier>)> _load() async {
    final templates = await Locator.facility.getFormTemplates();
    final dossiers = await Locator.facility.getDossiers();
    return (templates, dossiers);
  }

  /// Hồ sơ mới nhất làm từ mẫu [code] (nếu có).
  Dossier? _latestFor(String code, List<Dossier> dossiers) {
    final list = dossiers.where((d) => d.formCode == code).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list.isEmpty ? null : list.first;
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBody<(List<FormTemplate>, List<Dossier>)>(
      future: _future,
      builder: (context, data) {
        final (templates, dossiers) = data;
        final q = _query.toLowerCase();
        final visible = templates.where((t) {
          final matches = q.isEmpty ||
              t.code.toLowerCase().contains(q) ||
              t.name.toLowerCase().contains(q) ||
              t.purpose.toLowerCase().contains(q);
          final has = _latestFor(t.code, dossiers) != null;
          final passFilter = _filter == 'Tất cả' ||
              (_filter == 'Đã có hồ sơ' && has) ||
              (_filter == 'Chưa có hồ sơ' && !has) ||
              (_filter == 'Mẫu PC (NĐ 105)' && t.code.startsWith('PC')) ||
              (_filter == 'Mẫu TT 36' && t.code.startsWith('TT36')) ||
              (_filter == 'Mẫu mới' && t.isNew);
          return matches && passFilter;
        }).toList();

        return Column(
          children: [
            SearchBox(
              hint: 'Tìm theo mã (PC01...), tên, mục đích',
              onChanged: (v) => setState(() => _query = v),
            ),
            ChoiceFilterBar<String>(
              options: _filters,
              selected: _filter,
              labelOf: (v) => v,
              onSelected: (v) => setState(() => _filter = v),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.goldLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${templates.length} mẫu đang áp dụng. Đã bãi bỏ: ${abolishedForms.join(', ')}.',
                style: const TextStyle(fontSize: 12.5),
              ),
            ),
            Expanded(
              child: visible.isEmpty
                  ? const EmptyState(
                      icon: Icons.search_off,
                      message: 'Không tìm thấy biểu mẫu phù hợp',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: visible.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final t = visible[i];
                        final latest = _latestFor(t.code, dossiers);
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
                            onTap: () async {
                              await pushScreen(
                                context,
                                FormTemplateDetailScreen(template: t),
                              );
                              setState(() => _future = _load());
                            },
                            leading: _CodeBadge(t.code),
                            title: Text.rich(
                              TextSpan(
                                text: t.name,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                                children: [
                                  if (t.isNew)
                                    const TextSpan(
                                      text: '  MỚI',
                                      style: TextStyle(
                                        color: AppColors.danger,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: latest == null
                                  ? const Text('Chưa có hồ sơ')
                                  : Align(
                                      alignment: Alignment.centerLeft,
                                      child: StatusChip(
                                        label: latest.status.label,
                                        color: latest.status.color,
                                      ),
                                    ),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _CodeBadge extends StatelessWidget {
  const _CodeBadge(this.code);

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.goldLight,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        code.startsWith('TT36-') ? code.substring(5) : code,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }
}
