import '../../features/acceptance/data/acceptance_repository.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/calendar/data/calendar_repository.dart';
import '../../features/drills/data/drill_repository.dart';
import '../../features/equipment/data/equipment_repository.dart';
import '../../features/facility/data/facility_repository.dart';
import '../../features/notifications/data/notification_repository.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/team/data/team_repository.dart';
import '../../features/training/data/training_repository.dart';

/// Nơi DUY NHẤT chọn nguồn dữ liệu cho toàn app.
///
/// Hiện tại: dữ liệu mẫu (Mock...).
/// Khi nối Supabase: viết xong lớp Supabase... tương ứng rồi đổi từng dòng
/// dưới đây, các màn hình giữ nguyên không phải sửa.
class Locator {
  Locator._();

  static final AuthRepository auth = MockAuthRepository();
  static final FacilityRepository facility = MockFacilityRepository();
  static final TeamRepository team = MockTeamRepository();
  static final EquipmentRepository equipment = MockEquipmentRepository();
  static final TrainingRepository training = MockTrainingRepository();
  static final DrillRepository drills = MockDrillRepository();
  static final NotificationRepository notifications = MockNotificationRepository();
  static final CalendarRepository calendar = MockCalendarRepository();
  static final ProfileRepository profile = MockProfileRepository();
  static final AcceptanceRepository acceptance = MockAcceptanceRepository();
}
