import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/choice_filter_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/search_box.dart';
import '../../../core/widgets/status_chip.dart';
import '../models/dossier.dart';
import 'dossier_detail_screen.dart';
import 'dossier_form_screen.dart';

/// Theo dõi hồ sơ: thiếu, sắp đến hạn, đã nộp, cần bổ sung...
class DossierListTab extends StatefulWidget {
  const DossierListTab({super.key});

  @override
  State<DossierListTab> createState() => _DossierListTabState();
}

class _DossierListTabState extends State<DossierListTab> {
  late Future<List<Dossier>> _future;
  DossierStatus? _status;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = Locator.facility.getDossiers();
  }

  void _reload() => setState(() => _future = Locator.facility.getDossiers());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await pushScreen(context, const DossierFormScreen());
          _reload();
        },
        icon: const Icon(Icons.add),
        label: const Text('Tạo hồ sơ'),
      ),
      body: AsyncBody<List<Dossier>>(
        future: _future,
        builder: (context, all) {
          final q = _query.toLowerCase();
          final list = all.where((d) {
            final okStatus = _status == null || d.status == _status;
            final okQuery = q.isEmpty ||
                d.title.toLowerCase().contains(q) ||
                d.formCode.toLowerCase().contains(q);
            return okStatus && okQuery;
          }).toList()
            ..sort((a, b) {
              final ad = a.dueDate ?? DateTime(2100);
              final bd = b.dueDate ?? DateTime(2100);
              return ad.compareTo(bd);
            });

          return Column(
            children: [
              SearchBox(
                hint: 'Tìm hồ sơ theo tên hoặc mã mẫu',
                onChanged: (v) => setState(() => _query = v),
              ),
              ChoiceFilterBar<DossierStatus?>(
                options: [null, ...DossierStatus.values],
                selected: _status,
                labelOf: (s) {
                  final count = all.where((d) => s == null || d.status == s).length;
                  return '${s?.label ?? 'Tất cả'} ($count)';
                },
                onSelected: (s) => setState(() => _status = s),
              ),
              Expanded(
                child: list.isEmpty
                    ? const EmptyState(
                        icon: Icons.folder_open,
                        message: 'Không có hồ sơ nào',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, i) => DossierCard(
                          dossier: list[i],
                          onTap: () async {
                            await pushScreen(
                              context,
                              DossierDetailScreen(dossierId: list[i].id),
                            );
                            _reload();
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class DossierCard extends StatelessWidget {
  const DossierCard({super.key, required this.dossier, required this.onTap});

  final Dossier dossier;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final due = dossier.dueDate;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    dossier.formCode,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  StatusChip(label: dossier.status.label, color: dossier.status.color),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                dossier.title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      dossier.owner,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ),
                  if (due != null) ...[
                    Icon(Icons.event, size: 16, color: dueColor(due)),
                    const SizedBox(width: 4),
                    Text(
                      '${fmtDate(due)} · ${dueText(due)}',
                      style: TextStyle(fontSize: 12, color: dueColor(due)),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
