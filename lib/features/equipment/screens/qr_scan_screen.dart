import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/async_body.dart';
import '../models/equipment.dart';
import 'inspection_screen.dart';

/// Màn hình quét QR tại vị trí thiết bị.
/// Hiện là khung giả lập; sẽ dùng thư viện mobile_scanner để mở camera thật.
class QrScanScreen extends StatelessWidget {
  const QrScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quét mã QR thiết bị')),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            height: 220,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gold, width: 3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Khung camera\n(sẽ nối mobile_scanner)',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Hoặc chọn thiết bị đến hạn:',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          Expanded(
            child: AsyncBody<List<Equipment>>(
              future: Locator.equipment.getEquipment(),
              builder: (context, list) => ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final e in list)
                    ListTile(
                      leading: Icon(equipmentIcon(e.type), color: e.status.color),
                      title: Text(e.name),
                      subtitle: Text('${e.code} · ${dueText(e.nextCheck)}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => InspectionScreen(equipmentId: e.id)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: () => showComingSoon(context, 'Bật camera quét QR'),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Bật camera'),
            ),
          ),
        ],
      ),
    );
  }
}
