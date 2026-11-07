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
import '../models/equipment.dart';
import 'equipment_detail_screen.dart';
import 'equipment_form_screen.dart';
import 'qr_scan_screen.dart';

/// Chức năng 3: Danh sách phương tiện, thiết bị PCCC & CNCH.
class EquipmentListScreen extends StatefulWidget {
  const EquipmentListScreen({super.key});

  @override
  State<EquipmentListScreen> createState() => _EquipmentListScreenState();
}

class _EquipmentListScreenState extends State<EquipmentListScreen> {
  late Future<List<Equipment>> _future;
  EquipmentStatus? _status;
  bool _onlyDue = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = Locator.equipment.getEquipment();
  }

  void _reload() => setState(() => _future = Locator.equipment.getEquipment());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phương tiện & thiết bị'),
        actions: [
          IconButton(
            tooltip: 'Quét mã QR để kiểm tra',
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () async {
              await pushScreen(context, const QrScanScreen());
              _reload();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Thêm thiết bị',
        onPressed: () async {
          await pushScreen(context, const EquipmentFormScreen());
          _reload();
        },
        child: const Icon(Icons.add),
      ),
      body: AsyncBody<List<Equipment>>(
        future: _future,
        builder: (context, all) {
          final q = _query.toLowerCase();
          final list = all.where((e) {
            final okStatus = _status == null || e.status == _status;
            final okDue = !_onlyDue || daysFromToday(e.nextCheck) <= 7;
            final okQuery = q.isEmpty ||
                e.name.toLowerCase().contains(q) ||
                e.code.toLowerCase().contains(q) ||
                e.location.toLowerCase().contains(q);
            return okStatus && okDue && okQuery;
          }).toList();
          final dueCount = all.where((e) => daysFromToday(e.nextCheck) <= 7).length;

          return Column(
            children: [
              _Summary(all: all),
              SearchBox(
                hint: 'Tìm theo tên, mã, vị trí',
                onChanged: (v) => setState(() => _query = v),
              ),
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  children: [
                    FilterChip(
                      label: Text('Đến hạn trong 7 ngày ($dueCount)'),
                      selected: _onlyDue,
                      avatar: const Icon(Icons.alarm, size: 16),
                      onSelected: (v) => setState(() => _onlyDue = v),
                    ),
                  ],
                ),
              ),
              ChoiceFilterBar<EquipmentStatus?>(
                options: [null, ...EquipmentStatus.values],
                selected: _status,
                labelOf: (s) => s?.label ?? 'Tất cả',
                onSelected: (s) => setState(() => _status = s),
              ),
              Expanded(
                child: list.isEmpty
                    ? const EmptyState(icon: Icons.inventory_2_outlined, message: 'Không có thiết bị phù hợp')
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, i) => EquipmentCard(
                          item: list[i],
                          onTap: () async {
                            await pushScreen(context, EquipmentDetailScreen(equipmentId: list[i].id));
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

class _Summary extends StatelessWidget {
  const _Summary({required this.all});

  final List<Equipment> all;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          for (final s in EquipmentStatus.values)
            Expanded(
              child: Column(
                children: [
                  Text(
                    '${all.where((e) => e.status == s).length}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: s.color),
                  ),
                  Text(
                    s.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class EquipmentCard extends StatelessWidget {
  const EquipmentCard({super.key, required this.item, required this.onTap});

  final Equipment item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: item.status.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(equipmentIcon(item.type), color: item.status.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      '${item.code} · ${item.quantity} ${item.unit}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    Text(
                      item.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        StatusChip(label: item.status.label, color: item.status.color),
                        const SizedBox(width: 8),
                        Icon(Icons.event, size: 14, color: dueColor(item.nextCheck)),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            'Kiểm tra: ${dueText(item.nextCheck)}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: dueColor(item.nextCheck)),
                          ),
                        ),
                      ],
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
  }
}
