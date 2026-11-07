import 'package:flutter/material.dart';

import '../../core/utils/ui_helpers.dart';
import '../acceptance/screens/acceptance_hub_screen.dart';
import '../acceptance/screens/pc01_declaration_screen.dart';
import '../acceptance/screens/readiness_screen.dart';
import '../drills/screens/drill_detail_screen.dart';
import '../equipment/screens/equipment_detail_screen.dart';
import '../facility/screens/dossier_detail_screen.dart';
import '../team/screens/member_detail_screen.dart';
import '../team/screens/shift_detail_screen.dart';
import '../training/screens/training_session_detail_screen.dart';
import 'models/app_notification.dart';

/// Mở đúng màn hình của đối tượng mà thông báo nhắc tới.
Future<void> openNotificationTarget(
  BuildContext context,
  NotifTarget target,
  String id,
) async {
  final Widget? screen = switch (target) {
    NotifTarget.dossier => DossierDetailScreen(dossierId: id),
    NotifTarget.equipment => EquipmentDetailScreen(equipmentId: id),
    NotifTarget.shift => ShiftDetailScreen(shiftId: id),
    NotifTarget.training => TrainingSessionDetailScreen(sessionId: id),
    NotifTarget.drill => DrillDetailScreen(drillId: id),
    NotifTarget.member => MemberDetailScreen(memberId: id),
    NotifTarget.acceptance => switch (id) {
      'pc01' => const Pc01DeclarationScreen(),
      'readiness' => const ReadinessScreen(),
      _ => const AcceptanceHubScreen(),
    },
    NotifTarget.none => null,
  };
  if (screen != null) await pushScreen(context, screen);
}
