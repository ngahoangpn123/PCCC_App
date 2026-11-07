import '../../features/acceptance/models/acceptance.dart';
import '../../features/drills/models/drill.dart';
import '../../features/equipment/models/equipment.dart';
import '../../features/facility/models/dossier.dart';
import '../../features/facility/models/facility.dart';
import '../../features/facility/models/form_template.dart';
import '../../features/notifications/models/app_notification.dart';
import '../../features/profile/models/user_account.dart';
import '../../features/team/models/member.dart';
import '../../features/team/models/shift.dart';
import '../../features/training/models/training.dart';
import '../legal/legal_catalog.dart';
import '../models/history_entry.dart';
import '../session/app_session.dart';

/// Giả lập Future có độ trễ như khi gọi server.
Future<T> mockDelay<T>(T value) =>
    Future<T>.delayed(const Duration(milliseconds: 250), () => value);

/// "Cơ sở dữ liệu" tạm nằm trong bộ nhớ, chỉ để dựng và thử giao diện.
/// Tắt app là dữ liệu thêm mới sẽ mất. Khi nối Supabase, các repository
/// sẽ đọc/ghi Supabase thay vì lớp này.
class MockDatabase {
  MockDatabase._() {
    _seed();
  }

  static final MockDatabase instance = MockDatabase._();

  final List<Facility> facilities = [];
  final List<FormTemplate> formTemplates = [];
  final List<Dossier> dossiers = [];
  final List<Member> members = [];
  final List<Shift> shifts = [];
  final List<Equipment> equipment = [];
  final List<TrainingPlan> trainingPlans = [];
  final List<TrainingSession> trainingSessions = [];
  final List<Scenario> scenarios = [];
  final List<Drill> drills = [];
  final List<AppNotification> notifications = [];
  final List<DelegatedUser> delegates = [];
  final List<ActivityLog> activityLogs = [];
  late UserAccount account;
  final NotificationSettings settings = NotificationSettings();
  final SignatureSettings signature = SignatureSettings();

  // Tự nghiệm thu & sẵn sàng hậu kiểm
  final List<ProjectAcceptance> acceptances = [];
  final List<ReadinessItem> readinessItems = [];
  late PostInspection postInspection;
  final Map<String, Pc01Declaration> _pc01 = {};

  Facility get currentFacility => facilities.firstWhere(
    (f) => f.id == AppSession.instance.currentFacilityId,
    orElse: () => facilities.first,
  );

  Pc01Declaration pc01For(String facilityId) =>
      _pc01.putIfAbsent(facilityId, () => Pc01Declaration());

  /// Tạo hồ sơ tự nghiệm thu trống với 6 bước, 21 hạng mục, 3 thông số đo, 4 chữ ký.
  static ProjectAcceptance newAcceptance(String id, String facilityId, String name) =>
      ProjectAcceptance(
        id: id,
        facilityId: facilityId,
        projectName: name,
        steps: buildDefaultSteps(),
        checklist: {for (final i in acceptanceItems) i.code: CheckResult.pending},
        measurements: measureSpecs.map((m) => Measurement(spec: m)).toList(),
        signOffs: signOffRoles.map((r) => SignOff(role: r)).toList(),
        asBuiltParts: {for (final n in asBuiltPartNames) n: false},
      );

  void _seed() {
    final now = DateTime.now();
    final t = DateTime(now.year, now.month, now.day);
    DateTime day(int offset, [int hour = 0, int minute = 0]) =>
        DateTime(t.year, t.month, t.day + offset, hour, minute);

    account = UserAccount(
      name: 'Trần Minh Đức',
      email: 'giamdoc@hoabinh-tm.vn',
      phone: '0912 345 678',
      role: 'Người đứng đầu cơ sở',
    );

    // ---------------- Cơ sở ----------------
    facilities.addAll([
      Facility(
        id: 'f1',
        code: 'CS-HN-0125',
        name: 'Trung tâm Thương mại Hòa Bình',
        address: 'Số 25 Nguyễn Trãi, Thanh Xuân, Hà Nội',
        type: 'Trung tâm thương mại, chợ, siêu thị',
        field: 'Kinh doanh bán lẻ, dịch vụ ăn uống',
        scale: '5 tầng nổi, 1 tầng hầm; khoảng 12.000 m² sàn',
        buildingInfo: 'Kết cấu bê tông cốt thép, tầng hầm để xe, có hệ thống chữa cháy tự động',
        headName: 'Trần Minh Đức',
        headPhone: '0912 345 678',
        officerName: 'Lê Thu Hà',
        officerPhone: '0987 654 321',
        email: 'pccc@hoabinh-tm.vn',
        staffCount: 45,
        lat: 20.9931,
        lng: 105.8106,
        hazard: 'Hàng hóa dễ cháy (vải, nhựa, giấy), khu ẩm thực dùng gas, tầng hầm để xe máy.',
        hasConstruction: true,
      ),
      Facility(
        id: 'f2',
        code: 'CS-HN-0377',
        name: 'Kho vận Hòa Bình – Long Biên',
        address: 'Lô C2, KCN Sài Đồng, Long Biên, Hà Nội',
        type: 'Kho hàng hóa, vật tư',
        field: 'Lưu kho, phân phối hàng hóa',
        scale: '2 nhà kho, tổng 6.500 m²',
        buildingInfo: 'Nhà khung thép, mái tôn',
        headName: 'Trần Minh Đức',
        headPhone: '0912 345 678',
        officerName: 'Phạm Quốc Toàn',
        officerPhone: '0903 112 233',
        email: 'kho.lb@hoabinh-tm.vn',
        staffCount: 14,
        hazard: 'Kho hàng hóa đóng gói giấy, nhựa; xe nâng chạy điện.',
      ),
    ]);

    // ---------------- Kho biểu mẫu ----------------
    // 18 mẫu PC theo Phụ lục VIII NĐ 105/2025 (sửa đổi bởi NĐ 347/2026)
    // + 2 mẫu theo Thông tư 36/2025. Mẫu PC15, 16, 17, 19, 20, 21 đã bãi bỏ.
    // TODO: tên các mẫu ghi "Biểu mẫu PCxx" cần điền theo văn bản chính thức.
    FormTemplate pc(String code, String name, String purpose, {bool isNew = false, String? retention}) =>
        FormTemplate(
          code: code,
          name: name,
          purpose: purpose,
          isNew: isNew,
          retention: retention ?? '05 năm',
          guide: 'Hướng dẫn điền mẫu $code sẽ được bổ sung từ văn bản chính thức. '
              'Kiểm tra đủ các trường bắt buộc, ngày tháng và tệp đính kèm trước khi ký số.',
        );
    formTemplates.addAll([
      pc('PC01', 'Phiếu thông tin về cơ sở', 'Khai báo thông tin cơ sở lên CSDL Quốc gia về PCCC & CNCH (mẫu mới, thay thế mẫu cũ).', isNew: true, retention: 'Vĩnh viễn'),
      pc('PC02', 'Biên bản tự kiểm tra định kỳ', 'Cơ sở tự kiểm tra an toàn PCCC hằng tháng.'),
      pc('PC03', 'Biên bản kiểm tra (hậu kiểm)', 'Do cơ quan có thẩm quyền lập khi kiểm tra; cơ sở dùng để theo dõi khắc phục.'),
      pc('PC04', 'Biểu mẫu PC04', 'Mục đích sử dụng: cập nhật theo Phụ lục VIII.'),
      pc('PC05', 'Biểu mẫu PC05', 'Mục đích sử dụng: cập nhật theo Phụ lục VIII.'),
      pc('PC06', 'Phương án chữa cháy, CNCH của cơ sở', 'Phương án do cơ sở xây dựng, phê duyệt và tổ chức thực tập.', retention: '10 năm'),
      pc('PC07', 'Phương án chữa cháy, CNCH của phương tiện giao thông', 'Áp dụng cho phương tiện giao thông thuộc diện quản lý.'),
      pc('PC08', 'Biểu mẫu PC08', 'Mục đích sử dụng: cập nhật theo Phụ lục VIII.'),
      pc('PC09', 'Biểu mẫu PC09', 'Mục đích sử dụng: cập nhật theo Phụ lục VIII.'),
      pc('PC10', 'Biểu mẫu PC10', 'Mục đích sử dụng: cập nhật theo Phụ lục VIII.'),
      pc('PC11', 'Biểu mẫu PC11', 'Mục đích sử dụng: cập nhật theo Phụ lục VIII (mẫu đã được thay thế).', isNew: true),
      pc('PC12', 'Văn bản thẩm định thiết kế về PCCC', 'Kết quả thẩm định thiết kế – đầu vào bắt buộc của Bước 1 tự nghiệm thu (mẫu đã được thay thế).', isNew: true, retention: 'Vĩnh viễn'),
      pc('PC13', 'Văn bản thẩm định thiết kế về PCCC (điều chỉnh)', 'Kết quả thẩm định thiết kế điều chỉnh – dùng đối chiếu ở Bước 1.', retention: 'Vĩnh viễn'),
      pc('PC14', 'Biểu mẫu PC14', 'Mục đích sử dụng: cập nhật theo Phụ lục VIII.'),
      pc('PC18', 'Văn bản nghiệm thu về PCCC của chủ đầu tư', 'Chủ đầu tư tự nghiệm thu, ký số và khai báo CSDL trước khi đưa công trình vào sử dụng.', retention: 'Vĩnh viễn'),
      pc('PC22', 'Biểu mẫu PC22', 'Mục đích sử dụng: cập nhật theo Phụ lục VIII.'),
      pc('PC23', 'Biểu mẫu PC23', 'Mục đích sử dụng: cập nhật theo Phụ lục VIII.'),
      pc('PC24', 'Tờ khai thông tin phương tiện PCCC lưu thông trên thị trường', 'Mẫu mới: khai báo thông tin phương tiện PCCC (dùng đối chiếu tại Bước 1).', isNew: true),
      FormTemplate(
        code: 'TT36-M01', name: 'Sổ theo dõi phương tiện PCCC, CNCH (Mẫu 01)',
        purpose: 'Theo dõi số lượng, chất lượng, kiểm tra, bảo dưỡng phương tiện.',
        source: 'Thông tư 36/2025/TT-BCA', guide: 'Ghi theo từng phương tiện; cập nhật sau mỗi lần kiểm tra, bảo dưỡng.',
      ),
      FormTemplate(
        code: 'TT36-M02', name: 'Phiếu chiến thuật chữa cháy, CNCH (Mẫu 02)',
        purpose: 'Phiếu chiến thuật dùng kèm phương án chữa cháy, CNCH.',
        source: 'Thông tư 36/2025/TT-BCA', guide: 'Lập cho từng tình huống trong phương án.',
      ),
    ]);

    // ---------------- Hồ sơ ----------------
    HistoryEntry h(int dayOffset, String actor, String action) =>
        HistoryEntry(time: day(dayOffset, 9, 30), actor: actor, action: action);

    dossiers.addAll([
      Dossier(
        id: 'd1', formCode: 'PC01', title: 'Hồ sơ thông tin cơ sở năm 2026',
        owner: 'Lê Thu Hà', status: DossierStatus.completed, retention: 'Vĩnh viễn',
        updatedAt: day(-60), dueDate: day(300),
        attachments: ['PC01_2026_da_ky.pdf'],
        history: [
          h(-75, 'Lê Thu Hà', 'Tạo bản nháp'),
          h(-70, 'Trần Minh Đức', 'Ký hồ sơ'),
          h(-68, 'Lê Thu Hà', 'Ký số & đồng bộ CSDL Quốc gia'),
          h(-60, 'Hệ thống', 'Đã khai báo CSDL – mã biên nhận CSDL-0125-2026'),
        ],
      ),
      Dossier(
        id: 'd2', formCode: 'PC02', title: 'Biên bản tự kiểm tra định kỳ tháng này',
        owner: 'Lê Thu Hà', status: DossierStatus.draft,
        updatedAt: day(-2), dueDate: day(10),
        history: [h(-2, 'Lê Thu Hà', 'Tạo bản nháp')],
      ),
      Dossier(
        id: 'd3', formCode: 'PC06', title: 'Phương án chữa cháy, CNCH của cơ sở – năm 2026',
        owner: 'Lê Thu Hà', status: DossierStatus.signed, retention: '10 năm',
        updatedAt: day(-1), dueDate: day(4),
        attachments: ['PC06_ban_thao.docx'],
        history: [
          h(-6, 'Lê Thu Hà', 'Tạo bản nháp'),
          h(-1, 'Trần Minh Đức', 'Ký nội bộ'),
        ],
      ),
      Dossier(
        id: 'd4', formCode: 'PC12', title: 'Văn bản thẩm định thiết kế PCCC – cải tạo tầng 5',
        owner: 'Nguyễn Văn An', status: DossierStatus.submitted,
        updatedAt: day(-5), dueDate: day(20),
        attachments: ['PC12_tham_dinh.pdf'],
        history: [h(-5, 'Nguyễn Văn An', 'Gửi đến đơn vị tiếp nhận')],
      ),
      Dossier(
        id: 'd5', formCode: 'PC14', title: 'Hồ sơ theo mẫu PC14',
        owner: 'Lê Thu Hà', status: DossierStatus.needUpdate,
        updatedAt: day(-1), dueDate: day(3),
        note: 'Đơn vị tiếp nhận yêu cầu bổ sung ảnh chụp hiện trạng lối thoát nạn.',
        attachments: ['PC14_da_ky.pdf'],
        history: [
          h(-12, 'Lê Thu Hà', 'Gửi đến đơn vị tiếp nhận'),
          h(-1, 'Hệ thống', 'Nhận yêu cầu bổ sung'),
        ],
      ),
      Dossier(
        id: 'd6', formCode: 'PC24', title: 'Tờ khai phương tiện PCCC lưu thông – lô bình mới',
        owner: 'Lê Thu Hà', status: DossierStatus.draft,
        updatedAt: day(-3), dueDate: day(6),
        attachments: ['CO_CQ_binh_MFZ4.pdf'],
      ),
      Dossier(
        id: 'd7', formCode: 'PC02', title: 'Biên bản tự kiểm tra định kỳ tháng trước',
        owner: 'Lê Thu Hà', status: DossierStatus.notCreated,
        updatedAt: day(-35), dueDate: day(-5),
      ),
      Dossier(
        id: 'd8', formCode: 'TT36-M01', title: 'Sổ theo dõi phương tiện PCCC, CNCH năm 2026',
        owner: 'Vũ Thị Giang', status: DossierStatus.draft,
        updatedAt: day(-10), dueDate: day(15),
      ),
      Dossier(
        id: 'd9', formCode: 'PC18', title: 'Văn bản nghiệm thu PCCC – cải tạo tầng 5',
        owner: 'Nguyễn Văn An', status: DossierStatus.notCreated, retention: 'Vĩnh viễn',
        updatedAt: day(-4), dueDate: day(30),
      ),
    ]);

    // ---------------- Thành viên đội ----------------
    members.addAll([
      Member(id: 'm1', code: 'DV-001', name: 'Nguyễn Văn An', phone: '0901 111 001',
          role: 'Đội trưởng', duty: 'Chỉ huy chung, phân công nhiệm vụ',
          history: [h(-300, 'Trần Minh Đức', 'Bổ nhiệm Đội trưởng')]),
      Member(id: 'm2', code: 'DV-002', name: 'Trần Thị Bình', phone: '0901 111 002',
          role: 'Đội phó', duty: 'Thông tin liên lạc, báo cháy'),
      Member(id: 'm3', code: 'DV-003', name: 'Lê Văn Cường', phone: '0901 111 003',
          role: 'Đội viên', duty: 'Sử dụng bình, vòi chữa cháy'),
      Member(id: 'm4', code: 'DV-004', name: 'Phạm Thị Dung', phone: '0901 111 004',
          role: 'Đội viên', duty: 'Hướng dẫn thoát nạn', status: MemberStatus.away,
          history: [h(-3, 'Nguyễn Văn An', 'Chuyển trạng thái: Tạm vắng (nghỉ phép)')]),
      Member(id: 'm5', code: 'DV-005', name: 'Hoàng Văn Em', phone: '0901 111 005',
          role: 'Đội viên', duty: 'Cứu nạn, sơ cấp cứu', trainingOk: false,
          trainingNote: 'Chưa tham gia buổi huấn luyện định kỳ gần nhất'),
      Member(id: 'm6', code: 'DV-006', name: 'Vũ Thị Giang', phone: '0901 111 006',
          role: 'Đội viên', duty: 'Kiểm tra phương tiện, thiết bị'),
      Member(id: 'm7', code: 'DV-007', name: 'Đặng Văn Hùng', phone: '0901 111 007',
          role: 'Đội viên', duty: 'Ngắt điện, đóng van khí', status: MemberStatus.reassigned,
          history: [h(-15, 'Nguyễn Văn An', 'Đổi nhiệm vụ: từ Hướng dẫn thoát nạn sang Ngắt điện')]),
      Member(id: 'm8', code: 'DV-008', name: 'Bùi Văn Khoa', phone: '0901 111 008',
          role: 'Đội viên', duty: '—', status: MemberStatus.left),
    ]);

    // ---------------- Ca trực ----------------
    shifts.addAll([
      Shift(id: 's1', date: day(0), start: '07:00', end: '19:00', location: 'Sảnh chính – Tầng 1',
          leaderId: 'm1', memberIds: ['m1', 'm3', 'm6'], requiredCount: 3,
          confirmedIds: ['m1', 'm3', 'm6'], status: ShiftStatus.onDuty),
      Shift(id: 's2', date: day(0), start: '19:00', end: '07:00', location: 'Phòng bảo vệ',
          leaderId: 'm2', memberIds: ['m2', 'm5'], requiredCount: 3, confirmedIds: ['m2']),
      Shift(id: 's3', date: day(1), start: '07:00', end: '19:00', location: 'Sảnh chính – Tầng 1',
          leaderId: 'm1', memberIds: ['m1', 'm4', 'm6'], requiredCount: 3,
          confirmedIds: ['m1', 'm6']),
      Shift(id: 's4', date: day(1), start: '19:00', end: '07:00', location: 'Phòng bảo vệ',
          leaderId: 'm3', memberIds: ['m3', 'm6'], requiredCount: 2),
      Shift(id: 's5', date: day(2), start: '07:00', end: '19:00', location: 'Sảnh chính – Tầng 1',
          leaderId: 'm2', memberIds: ['m2', 'm3', 'm5'], requiredCount: 3,
          confirmedIds: ['m2', 'm3', 'm5'], status: ShiftStatus.confirmed),
      Shift(id: 's6', date: day(3), start: '19:00', end: '07:00', location: 'Phòng bảo vệ',
          leaderId: 'm1', memberIds: ['m1', 'm3'], requiredCount: 2),
      Shift(id: 's7', date: day(5), start: '07:00', end: '19:00', location: 'Sảnh chính – Tầng 1',
          leaderId: 'm6', memberIds: ['m3', 'm6'], requiredCount: 3),
      Shift(id: 's8', date: day(-1), start: '07:00', end: '19:00', location: 'Sảnh chính – Tầng 1',
          leaderId: 'm1', memberIds: ['m1', 'm3', 'm6'], requiredCount: 3,
          confirmedIds: ['m1', 'm3', 'm6'], status: ShiftStatus.done,
          handoverNote: 'Ca trực bình thường. Đã kiểm tra tủ chữa cháy tầng 3.'),
      Shift(id: 's9', date: day(-2), start: '19:00', end: '07:00', location: 'Phòng bảo vệ',
          leaderId: 'm2', memberIds: ['m2', 'm5', 'm6'], requiredCount: 3,
          confirmedIds: ['m2', 'm5', 'm6'], status: ShiftStatus.done,
          absentNote: 'Lê Văn Cường vắng, Vũ Thị Giang trực thay.'),
    ]);

    // ---------------- Thiết bị ----------------
    equipment.addAll([
      Equipment(id: 'e1', htGroup: 'HT12', pc24Code: 'PC24-2026-00871', code: 'TB-BC-001', name: 'Bình bột chữa cháy MFZ4', type: 'Bình chữa cháy',
          maker: 'Tomoken', model: 'MFZ4', quantity: 12, unit: 'bình',
          location: 'Tầng 1 – Hành lang chính', inUseSince: day(-500),
          status: EquipmentStatus.ok, nextCheck: day(20), keeper: 'Vũ Thị Giang',
          records: [InspectionRecord(date: day(-70), kind: 'Kiểm tra', by: 'Vũ Thị Giang',
              result: EquipmentStatus.ok, note: 'Áp suất trong vùng xanh', confirmed: true)]),
      Equipment(id: 'e2', htGroup: 'HT12', code: 'TB-BC-002', name: 'Bình khí CO2 MT3', type: 'Bình chữa cháy',
          maker: 'Yamato', model: 'MT3', quantity: 8, unit: 'bình',
          location: 'Tầng 2 – Phòng kỹ thuật điện', inUseSince: day(-400),
          status: EquipmentStatus.needCheck, nextCheck: day(2), keeper: 'Vũ Thị Giang'),
      Equipment(id: 'e3', htGroup: 'HT5', code: 'TB-HT-001', name: 'Tủ chữa cháy vách tường', type: 'Hệ thống chữa cháy',
          quantity: 6, unit: 'tủ', location: 'Các tầng 1 – 5, cạnh thang bộ',
          inUseSince: day(-900), status: EquipmentStatus.ok, nextCheck: day(45),
          keeper: 'Lê Văn Cường'),
      Equipment(id: 'e4', htGroup: 'HT3', code: 'TB-MB-001', name: 'Máy bơm chữa cháy động cơ điện', type: 'Máy bơm',
          maker: 'Pentax', model: 'CM 65-200', serial: 'PX-2024-0091', quantity: 1, unit: 'máy',
          location: 'Tầng hầm B1 – Phòng bơm', inUseSince: day(-900),
          status: EquipmentStatus.needRepair, nextCheck: day(-3), keeper: 'Đặng Văn Hùng',
          records: [InspectionRecord(date: day(-3), kind: 'Kiểm tra', by: 'Đặng Văn Hùng',
              result: EquipmentStatus.needRepair, note: 'Bơm không tự khởi động khi thử áp')]),
      Equipment(id: 'e5', htGroup: 'HT1', code: 'TB-BK-001', name: 'Đầu báo khói quang điện', type: 'Hệ thống báo cháy',
          quantity: 120, unit: 'đầu', location: 'Toàn bộ tòa nhà', inUseSince: day(-900),
          status: EquipmentStatus.ok, nextCheck: day(60), keeper: 'Vũ Thị Giang'),
      Equipment(id: 'e6', htGroup: 'HT13', code: 'TB-DS-001', name: 'Đèn chiếu sáng sự cố', type: 'Chiếu sáng & thoát nạn',
          quantity: 40, unit: 'đèn', location: 'Hành lang, cầu thang các tầng',
          inUseSince: day(-700), status: EquipmentStatus.needCheck, nextCheck: day(5),
          keeper: 'Lê Văn Cường'),
      Equipment(id: 'e7', htGroup: 'HT12', code: 'TB-CN-001', name: 'Mặt nạ phòng độc', type: 'Dụng cụ cứu nạn',
          quantity: 20, unit: 'chiếc', location: 'Kho PCCC – Tầng 1', inUseSince: day(-300),
          status: EquipmentStatus.ok, nextCheck: day(90), keeper: 'Hoàng Văn Em'),
      Equipment(id: 'e8', htGroup: 'HT12', code: 'TB-CN-002', name: 'Thang dây cứu nạn', type: 'Dụng cụ cứu nạn',
          quantity: 2, unit: 'bộ', location: 'Tầng 5 – Phòng kỹ thuật', inUseSince: day(-1200),
          status: EquipmentStatus.outOfService, nextCheck: day(0), keeper: 'Hoàng Văn Em'),
    ]);

    // ---------------- Huấn luyện ----------------
    trainingPlans.addAll([
      TrainingPlan(id: 'tp1', title: 'Kế hoạch huấn luyện năm 2026', period: 'Năm 2026',
          description: 'Huấn luyện định kỳ cho toàn bộ đội PCCC & CNCH cơ sở.'),
      TrainingPlan(id: 'tp2', title: 'Bồi dưỡng nghiệp vụ Quý IV/2026', period: 'Quý IV/2026',
          description: 'Tập trung kỹ năng sơ cấp cứu và hướng dẫn thoát nạn.'),
    ]);
    trainingSessions.addAll([
      TrainingSession(id: 'ts1', planId: 'tp1', title: 'Sử dụng bình chữa cháy xách tay',
          date: day(-20, 8), location: 'Sân sau tòa nhà', instructor: 'Nguyễn Văn An',
          content: 'Phân loại bình, cách sử dụng, thực hành dập đám cháy khay xăng.',
          format: 'Lý thuyết + thực hành', durationMinutes: 120, status: SessionStatus.done,
          evaluation: 'Đa số đạt yêu cầu. 1 thành viên cần thực hành bổ sung.',
          attachments: ['bien_ban_ts1.pdf', 'anh_thuc_hanh.jpg'],
          attendance: [
            Attendance(memberId: 'm1'),
            Attendance(memberId: 'm2'),
            Attendance(memberId: 'm3'),
            Attendance(memberId: 'm4', result: 'Cần bổ sung'),
            Attendance(memberId: 'm5', present: false, result: 'Không đạt', note: 'Vắng không lý do'),
            Attendance(memberId: 'm6'),
          ]),
      TrainingSession(id: 'ts2', kind: 'Bồi dưỡng nghiệp vụ', planId: 'tp2', title: 'Kỹ năng sơ cấp cứu ban đầu',
          date: day(4, 14), location: 'Phòng họp tầng 3', instructor: 'Mời giảng viên y tế',
          content: 'Sơ cứu bỏng, cầm máu, hô hấp nhân tạo.', format: 'Lý thuyết + thực hành',
          durationMinutes: 180,
          attendance: ['m1', 'm2', 'm3', 'm5', 'm6'].map((id) => Attendance(memberId: id)).toList()),
      TrainingSession(id: 'ts3', kind: 'Bồi dưỡng nghiệp vụ', planId: 'tp2', title: 'Hướng dẫn thoát nạn khi có cháy',
          date: day(12, 8), location: 'Toàn bộ tòa nhà', instructor: 'Trần Thị Bình',
          content: 'Lối thoát nạn, điểm tập kết, cách hướng dẫn khách hàng.', format: 'Thực hành',
          durationMinutes: 90,
          attendance: ['m1', 'm2', 'm3', 'm4', 'm6', 'm7'].map((id) => Attendance(memberId: id)).toList()),
      TrainingSession(id: 'ts4', planId: 'tp1', title: 'Vận hành máy bơm chữa cháy',
          date: day(-8, 9), location: 'Tầng hầm B1', instructor: 'Đặng Văn Hùng',
          content: 'Khởi động, kiểm tra áp lực, xử lý sự cố thường gặp.', format: 'Thực hành',
          durationMinutes: 60, status: SessionStatus.missed),
    ]);

    // ---------------- Phương án & diễn tập ----------------
    scenarios.addAll([
      Scenario(id: 'sc1', code: 'PA-01', name: 'Phương án chữa cháy khu vực kho hàng tầng hầm',
          type: 'Chữa cháy', objective: 'Phát hiện sớm, dập tắt đám cháy ban đầu, sơ tán người an toàn.',
          scope: 'Tầng hầm B1 và khu vực kho', location: 'Tầng hầm B1',
          commander: 'Nguyễn Văn An',
          forces: ['Tổ chữa cháy: Lê Văn Cường, Vũ Thị Giang',
                   'Tổ thông tin liên lạc: Trần Thị Bình',
                   'Tổ thoát nạn: Phạm Thị Dung, Đặng Văn Hùng'],
          equipment: ['Bình bột MFZ4 × 6', 'Tủ chữa cháy vách tường', 'Máy bơm chữa cháy'],
          steps: ['Phát hiện cháy, báo động toàn tòa nhà',
                  'Ngắt điện khu vực cháy',
                  'Dùng bình chữa cháy dập đám cháy ban đầu',
                  'Triển khai lăng vòi từ tủ chữa cháy',
                  'Hướng dẫn sơ tán, kiểm đếm tại điểm tập kết',
                  'Gọi 114 và đón lực lượng chữa cháy chuyên nghiệp']),
      Scenario(id: 'sc2', formType: scenarioForms[2], code: 'PA-02', name: 'Phương án cứu nạn người mắc kẹt trong thang máy',
          type: 'Cứu nạn, cứu hộ', objective: 'Giải cứu người mắc kẹt an toàn, nhanh chóng.',
          scope: '4 thang máy khách hàng', location: 'Khu thang máy trung tâm',
          commander: 'Trần Thị Bình',
          forces: ['Tổ cứu nạn: Hoàng Văn Em, Lê Văn Cường', 'Kỹ thuật thang máy (thuê ngoài)'],
          equipment: ['Bộ dụng cụ mở cửa thang máy', 'Mặt nạ phòng độc × 2'],
          steps: ['Trấn an người bị nạn qua hệ thống liên lạc',
                  'Ngắt nguồn thang máy',
                  'Xác định vị trí cabin, mở cửa tầng',
                  'Đưa người ra, sơ cứu nếu cần']),
    ]);
    drills.addAll([
      Drill(id: 'dr1', scenarioId: 'sc1', title: 'Diễn tập chữa cháy kho hàng – Quý III',
          date: day(-40, 8), stage: DrillStage.remediate,
          participants: '18 người (đội PCCC cơ sở + nhân viên trực)',
          result: 'Hoàn thành trong 12 phút. Phối hợp các tổ tốt.',
          issues: 'Máy bơm khởi động chậm; một lối thoát nạn bị hàng hóa che chắn.',
          attachments: ['bien_ban_dien_tap_q3.pdf'],
          fixes: [
            FixTask(title: 'Dọn thông thoáng lối thoát nạn kho B1', assignee: 'Đặng Văn Hùng',
                due: day(-30), done: true),
            FixTask(title: 'Sửa chữa bộ khởi động máy bơm', assignee: 'Đặng Văn Hùng', due: day(7)),
          ]),
      Drill(id: 'dr2', scenarioId: 'sc1', title: 'Thực tập phương án PA-01 – Quý IV',
          date: day(9, 8), stage: DrillStage.prepare, participants: 'Đội PCCC cơ sở'),
      Drill(id: 'dr3', scenarioId: 'sc2', title: 'Diễn tập cứu nạn thang máy',
          date: day(25, 14), stage: DrillStage.plan),
    ]);

    // ---------------- Thông báo ----------------
    notifications.addAll([
      AppNotification(id: 'n1', objectLabel: 'Máy bơm chữa cháy (TB-MB-001)', dueDate: day(2), assignee: 'Đặng Văn Hùng',
          suggestedAction: 'Liên hệ đơn vị bảo trì, sửa bộ khởi động và chạy thử lại', title: 'Máy bơm chữa cháy cần sửa chữa',
          body: 'Kết quả kiểm tra: bơm không tự khởi động khi thử áp. Thiết bị ảnh hưởng đến khả năng sẵn sàng chữa cháy.',
          category: NotifCategory.urgent, priority: NotifPriority.high,
          createdAt: now.subtract(const Duration(hours: 5)),
          target: NotifTarget.equipment, targetId: 'e4'),
      AppNotification(id: 'n2', objectLabel: 'Ca trực 19:00 – 07:00', dueDate: day(0, 18), assignee: 'Nguyễn Văn An',
          suggestedAction: 'Phân công thêm 1 người và nhắc xác nhận', title: 'Ca trực đêm nay thiếu người',
          body: 'Ca 19:00 – 07:00 mới phân công 2/3 người, 1 người chưa xác nhận.',
          category: NotifCategory.schedule, priority: NotifPriority.high,
          createdAt: now.subtract(const Duration(hours: 2)),
          target: NotifTarget.shift, targetId: 's2'),
      AppNotification(id: 'n3', objectLabel: 'Hồ sơ PC14', dueDate: day(3), assignee: 'Lê Thu Hà',
          suggestedAction: 'Chụp ảnh lối thoát nạn và bổ sung vào hồ sơ', title: 'Hồ sơ PC14 cần bổ sung',
          body: 'Đơn vị tiếp nhận yêu cầu bổ sung ảnh chụp hiện trạng lối thoát nạn. Hạn còn 3 ngày.',
          category: NotifCategory.dossier, priority: NotifPriority.high,
          createdAt: now.subtract(const Duration(days: 1)),
          target: NotifTarget.dossier, targetId: 'd5'),
      AppNotification(id: 'n4', objectLabel: 'Buổi huấn luyện vận hành máy bơm', dueDate: day(7), assignee: 'Nguyễn Văn An',
          suggestedAction: 'Lên lịch lại buổi huấn luyện', title: 'Buổi huấn luyện chưa được thực hiện',
          body: 'Buổi "Vận hành máy bơm chữa cháy" trong kế hoạch năm đã quá ngày dự kiến.',
          category: NotifCategory.urgent, priority: NotifPriority.medium,
          createdAt: now.subtract(const Duration(days: 2)),
          target: NotifTarget.training, targetId: 'ts4'),
      AppNotification(id: 'n5', objectLabel: '8 bình CO2 MT3', dueDate: day(2), assignee: 'Vũ Thị Giang',
          suggestedAction: 'Kiểm tra áp suất, khối lượng và ghi kết quả', title: 'Bình khí CO2 đến hạn kiểm tra',
          body: '8 bình CO2 MT3 tại phòng kỹ thuật điện đến hạn kiểm tra sau 2 ngày.',
          category: NotifCategory.upcoming, priority: NotifPriority.medium,
          createdAt: now.subtract(const Duration(days: 1, hours: 3)),
          target: NotifTarget.equipment, targetId: 'e2'),
      AppNotification(id: 'n6', objectLabel: 'Buổi Kỹ năng sơ cấp cứu', dueDate: day(4, 14), assignee: 'Trần Thị Bình',
          suggestedAction: 'Xác nhận danh sách tham gia', title: 'Sắp diễn ra: Kỹ năng sơ cấp cứu',
          body: 'Buổi huấn luyện diễn ra sau 4 ngày tại phòng họp tầng 3.',
          category: NotifCategory.upcoming, priority: NotifPriority.low,
          createdAt: now.subtract(const Duration(days: 1)),
          target: NotifTarget.training, targetId: 'ts2'),
      AppNotification(id: 'n7', objectLabel: 'Phương án PC06 năm 2026', dueDate: day(4), assignee: 'Trần Minh Đức',
          suggestedAction: 'Ký số và gửi / đồng bộ', title: 'Hồ sơ PC12 đang chờ ký',
          body: 'Hồ sơ đã hoàn thiện, cần người đứng đầu ký trước khi gửi.',
          category: NotifCategory.dossier, priority: NotifPriority.medium,
          createdAt: now.subtract(const Duration(days: 1)), read: true,
          target: NotifTarget.dossier, targetId: 'd3'),
      AppNotification(id: 'n8', objectLabel: 'Ca 07:00 – 19:00 ngày mai', dueDate: day(1, 7), assignee: 'Phạm Thị Dung',
          suggestedAction: 'Liên hệ xác nhận hoặc phân công người thay', title: 'Thành viên chưa xác nhận lịch trực ngày mai',
          body: 'Phạm Thị Dung chưa xác nhận ca 07:00 – 19:00 ngày mai (đang tạm vắng).',
          category: NotifCategory.schedule, priority: NotifPriority.medium,
          createdAt: now.subtract(const Duration(hours: 8)),
          target: NotifTarget.shift, targetId: 's3'),
      AppNotification(id: 'n9', objectLabel: 'Phương án PA-01', dueDate: day(9, 8), assignee: 'Nguyễn Văn An',
          suggestedAction: 'Hoàn tất phân công và rà soát phương tiện', title: 'Thực tập phương án PA-01 sau 9 ngày',
          body: 'Cần hoàn tất phân công nhiệm vụ và rà soát phương tiện.',
          category: NotifCategory.upcoming, priority: NotifPriority.low,
          createdAt: now.subtract(const Duration(days: 3)), read: true,
          target: NotifTarget.drill, targetId: 'dr2'),
      AppNotification(id: 'n10', title: 'Chưa hoàn thành tự nghiệm thu PC18',
          body: 'Hạng mục cải tạo tầng 5 đang ở Bước 3/6. Chưa được đưa công trình vào sử dụng '
              'khi chưa có Văn bản PC18 và khai báo CSDL.',
          category: NotifCategory.urgent, priority: NotifPriority.high,
          createdAt: now.subtract(const Duration(hours: 1)),
          objectLabel: 'Công trình cải tạo tầng 5', dueDate: day(14), assignee: 'Trần Minh Đức',
          suggestedAction: 'Hoàn tất thử đơn động và lên lịch thử liên động',
          target: NotifTarget.acceptance),
      AppNotification(id: 'n11', title: 'Quá hạn tự kiểm tra định kỳ PC02',
          body: 'Biên bản tự kiểm tra tháng trước chưa được lập.',
          category: NotifCategory.upcoming, priority: NotifPriority.high,
          createdAt: now.subtract(const Duration(days: 4)),
          objectLabel: 'Biên bản PC02 tháng trước', dueDate: day(-5), assignee: 'Lê Thu Hà',
          suggestedAction: 'Tổ chức tự kiểm tra và lập biên bản PC02',
          target: NotifTarget.dossier, targetId: 'd7'),
      AppNotification(id: 'n12', title: 'Thông tin cơ sở thay đổi – cập nhật PC01 trong 72 giờ',
          body: 'Số người làm việc thường xuyên đã thay đổi. Cần cập nhật Phiếu PC01 lên CSDL Quốc gia.',
          category: NotifCategory.dossier, priority: NotifPriority.high,
          createdAt: now.subtract(const Duration(hours: 20)),
          objectLabel: 'Phiếu thông tin cơ sở PC01', dueDate: now.add(const Duration(hours: 52)),
          assignee: 'Lê Thu Hà', suggestedAction: 'Mở Khai báo PC01, kiểm tra và đồng bộ',
          target: NotifTarget.acceptance, targetId: 'pc01'),
      AppNotification(id: 'n13', title: 'Lịch tiếp đoàn hậu kiểm',
          body: 'Đoàn kiểm tra của Phòng Cảnh sát PCCC & CNCH dự kiến làm việc tại cơ sở.',
          category: NotifCategory.schedule, priority: NotifPriority.medium,
          createdAt: now.subtract(const Duration(days: 2)),
          objectLabel: 'Hậu kiểm định kỳ', dueDate: day(21, 9), assignee: 'Trần Minh Đức',
          suggestedAction: 'Rà soát danh mục sẵn sàng hậu kiểm',
          target: NotifTarget.acceptance, targetId: 'readiness'),
    ]);

    // ---------------- Tự nghiệm thu & hậu kiểm ----------------
    final acc = newAcceptance('acc1', 'f1', 'Cải tạo, chuyển đổi công năng tầng 5');
    for (final st in acc.steps.take(2)) {
      st.status = StepStatus.done;
      st.completedAt = day(-20 + st.no * 5);
    }
    acc.steps[0].attachments.addAll(['qr_tem_kiem_dinh.jpg', 'CO_CQ_dau_bao.pdf']);
    acc.steps[1].attachments.addAll(['ong_ngam_geotag_01.jpg', 'thu_ap_luc.pdf']);
    acc.steps[2].status = StepStatus.inProgress;
    acc.measurements[0].value = 32;
    acc.measurements[1].value = 0.45; // vượt ngưỡng → báo đỏ
    for (final i in acceptanceItems.take(8)) {
      acc.checklist[i.code] = CheckResult.pass;
    }
    acc.checklist['2.9'] = CheckResult.fail;
    acc.asBuiltParts[asBuiltPartNames[0]] = true;
    acc.asBuiltParts[asBuiltPartNames[1]] = true;
    acc.asBuiltParts[asBuiltPartNames[2]] = true;
    acceptances.add(acc);

    readinessItems.addAll(responsibilityGroups.map(
      (g) => ReadinessItem(code: g.code, name: g.name, done: g.code != 'N4' && g.code != 'N9'),
    ));
    readinessItems.last.note = 'Hợp đồng bảo hiểm hết hạn sau 10 ngày';

    postInspection = PostInspection(
      lastSelfCheck: day(-38),
      nextSelfCheck: day(-5),
      nextInspection: day(21, 9),
      agency: 'Phòng Cảnh sát PCCC & CNCH – Công an TP. Hà Nội',
      remediations: [
        RemediationItem(title: 'Bổ sung biển chỉ dẫn thoát nạn tầng hầm', assignee: 'Lê Văn Cường',
            due: day(5)),
        RemediationItem(title: 'Thay ắc quy đèn sự cố tầng 3', assignee: 'Lê Văn Cường',
            due: day(-2), done: true, evidence: ['den_su_co_t3.jpg']),
      ],
    );

    _pc01['f1'] = Pc01Declaration(
      status: DeclarationStatus.needUpdate,
      lastSyncedAt: day(-60),
      changedAt: now.subtract(const Duration(hours: 20)),
      receiptCode: 'CSDL-0125-2026',
      changes: ['Số người thường xuyên làm việc: 38 → 45', 'Hạng mục cải tạo tầng 5'],
    );
    _pc01['f2'] = Pc01Declaration(status: DeclarationStatus.draft);

    // ---------------- Phân quyền & nhật ký ----------------
    delegates.addAll([
      DelegatedUser(name: 'Lê Thu Hà', role: userRoles[1].name,
          scope: 'Hồ sơ, kế hoạch huấn luyện, phương án'),
      DelegatedUser(name: 'Nguyễn Văn An', role: userRoles[2].name,
          scope: 'Thành viên, lịch trực, huấn luyện'),
      DelegatedUser(name: 'Vũ Thị Giang', role: userRoles[3].name,
          scope: 'Kiểm tra, bảo dưỡng phương tiện'),
    ]);
    activityLogs.addAll([
      ActivityLog(time: now.subtract(const Duration(minutes: 30)), action: 'Đăng nhập trên Android'),
      ActivityLog(time: now.subtract(const Duration(days: 1)), action: 'Xem hồ sơ PC14'),
      ActivityLog(time: now.subtract(const Duration(days: 2)), action: 'Phân quyền cho Vũ Thị Giang'),
      ActivityLog(time: now.subtract(const Duration(days: 5)), action: 'Ký hồ sơ PC13'),
    ]);
  }
}
