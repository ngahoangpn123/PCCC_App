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
import '../models/history_entry.dart';

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
      ),
    ]);

    // ---------------- Kho biểu mẫu ----------------
    // TODO: điền tên và mục đích chính thức của từng mẫu theo Phụ lục Nghị định.
    const codes = [
      'PC01', 'PC11', 'PC12', 'PC13', 'PC14', 'PC15', 'PC16',
      'PC17', 'PC18', 'PC19', 'PC20', 'PC21', 'PC22', 'PC23',
    ];
    formTemplates.addAll(
      codes.map(
        (c) => FormTemplate(
          code: c,
          name: 'Biểu mẫu $c',
          purpose: 'Mục đích sử dụng: cập nhật theo Phụ lục của Nghị định',
          guide: 'Hướng dẫn điền mẫu $c sẽ được bổ sung từ văn bản chính thức. '
              'Kiểm tra đủ các trường bắt buộc, ngày tháng và tệp đính kèm trước khi ký.',
        ),
      ),
    );

    // ---------------- Hồ sơ ----------------
    HistoryEntry h(int dayOffset, String actor, String action) =>
        HistoryEntry(time: day(dayOffset, 9, 30), actor: actor, action: action);

    dossiers.addAll([
      Dossier(
        id: 'd1', formCode: 'PC01', title: 'Hồ sơ thông tin cơ sở năm 2026',
        owner: 'Lê Thu Hà', status: DossierStatus.approved,
        updatedAt: day(-60), dueDate: day(300),
        attachments: ['PC01_2026_da_ky.pdf'],
        history: [
          h(-75, 'Lê Thu Hà', 'Tạo bản nháp'),
          h(-70, 'Trần Minh Đức', 'Ký hồ sơ'),
          h(-68, 'Lê Thu Hà', 'Gửi đến đơn vị tiếp nhận'),
          h(-60, 'Lê Thu Hà', 'Cập nhật: đơn vị đã tiếp nhận'),
        ],
      ),
      Dossier(
        id: 'd2', formCode: 'PC11', title: 'Hồ sơ theo mẫu PC11 – cập nhật quý IV',
        owner: 'Lê Thu Hà', status: DossierStatus.draft,
        updatedAt: day(-2), dueDate: day(10),
        history: [h(-2, 'Lê Thu Hà', 'Tạo bản nháp')],
      ),
      Dossier(
        id: 'd3', formCode: 'PC12', title: 'Hồ sơ theo mẫu PC12 – năm 2026',
        owner: 'Lê Thu Hà', status: DossierStatus.waitingSign,
        updatedAt: day(-1), dueDate: day(4),
        attachments: ['PC12_ban_thao.docx'],
        history: [
          h(-6, 'Lê Thu Hà', 'Tạo bản nháp'),
          h(-1, 'Lê Thu Hà', 'Hoàn thiện, chuyển chờ ký'),
        ],
      ),
      Dossier(
        id: 'd4', formCode: 'PC13', title: 'Hồ sơ theo mẫu PC13',
        owner: 'Nguyễn Văn An', status: DossierStatus.submitted,
        updatedAt: day(-5), dueDate: day(20),
        attachments: ['PC13_da_ky.pdf'],
        history: [h(-5, 'Nguyễn Văn An', 'Gửi đến đơn vị tiếp nhận')],
      ),
      Dossier(
        id: 'd5', formCode: 'PC14', title: 'Hồ sơ theo mẫu PC14',
        owner: 'Lê Thu Hà', status: DossierStatus.needSupplement,
        updatedAt: day(-1), dueDate: day(3),
        note: 'Đơn vị tiếp nhận yêu cầu bổ sung ảnh chụp hiện trạng lối thoát nạn.',
        attachments: ['PC14_da_ky.pdf'],
        history: [
          h(-12, 'Lê Thu Hà', 'Gửi đến đơn vị tiếp nhận'),
          h(-1, 'Hệ thống', 'Nhận yêu cầu bổ sung'),
        ],
      ),
      Dossier(
        id: 'd6', formCode: 'PC15', title: 'Hồ sơ theo mẫu PC15',
        owner: 'Lê Thu Hà', status: DossierStatus.waitingSubmit,
        updatedAt: day(-3), dueDate: day(6),
        attachments: ['PC15_da_ky.pdf'],
      ),
      Dossier(
        id: 'd7', formCode: 'PC16', title: 'Hồ sơ theo mẫu PC16 – năm 2025',
        owner: 'Lê Thu Hà', status: DossierStatus.expired,
        updatedAt: day(-200), dueDate: day(-5),
      ),
      Dossier(
        id: 'd8', formCode: 'PC17', title: 'Hồ sơ theo mẫu PC17',
        owner: 'Lê Thu Hà', status: DossierStatus.notCreated,
        updatedAt: day(-10), dueDate: day(15),
      ),
      Dossier(
        id: 'd9', formCode: 'PC18', title: 'Hồ sơ theo mẫu PC18',
        owner: 'Nguyễn Văn An', status: DossierStatus.draft,
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
      Equipment(id: 'e1', code: 'TB-BC-001', name: 'Bình bột chữa cháy MFZ4', type: 'Bình chữa cháy',
          maker: 'Tomoken', model: 'MFZ4', quantity: 12, unit: 'bình',
          location: 'Tầng 1 – Hành lang chính', inUseSince: day(-500),
          status: EquipmentStatus.ok, nextCheck: day(20), keeper: 'Vũ Thị Giang',
          records: [InspectionRecord(date: day(-70), kind: 'Kiểm tra', by: 'Vũ Thị Giang',
              result: EquipmentStatus.ok, note: 'Áp suất trong vùng xanh', confirmed: true)]),
      Equipment(id: 'e2', code: 'TB-BC-002', name: 'Bình khí CO2 MT3', type: 'Bình chữa cháy',
          maker: 'Yamato', model: 'MT3', quantity: 8, unit: 'bình',
          location: 'Tầng 2 – Phòng kỹ thuật điện', inUseSince: day(-400),
          status: EquipmentStatus.needCheck, nextCheck: day(2), keeper: 'Vũ Thị Giang'),
      Equipment(id: 'e3', code: 'TB-HT-001', name: 'Tủ chữa cháy vách tường', type: 'Hệ thống chữa cháy',
          quantity: 6, unit: 'tủ', location: 'Các tầng 1 – 5, cạnh thang bộ',
          inUseSince: day(-900), status: EquipmentStatus.ok, nextCheck: day(45),
          keeper: 'Lê Văn Cường'),
      Equipment(id: 'e4', code: 'TB-MB-001', name: 'Máy bơm chữa cháy động cơ điện', type: 'Máy bơm',
          maker: 'Pentax', model: 'CM 65-200', serial: 'PX-2024-0091', quantity: 1, unit: 'máy',
          location: 'Tầng hầm B1 – Phòng bơm', inUseSince: day(-900),
          status: EquipmentStatus.needRepair, nextCheck: day(-3), keeper: 'Đặng Văn Hùng',
          records: [InspectionRecord(date: day(-3), kind: 'Kiểm tra', by: 'Đặng Văn Hùng',
              result: EquipmentStatus.needRepair, note: 'Bơm không tự khởi động khi thử áp')]),
      Equipment(id: 'e5', code: 'TB-BK-001', name: 'Đầu báo khói quang điện', type: 'Hệ thống báo cháy',
          quantity: 120, unit: 'đầu', location: 'Toàn bộ tòa nhà', inUseSince: day(-900),
          status: EquipmentStatus.ok, nextCheck: day(60), keeper: 'Vũ Thị Giang'),
      Equipment(id: 'e6', code: 'TB-DS-001', name: 'Đèn chiếu sáng sự cố', type: 'Chiếu sáng & thoát nạn',
          quantity: 40, unit: 'đèn', location: 'Hành lang, cầu thang các tầng',
          inUseSince: day(-700), status: EquipmentStatus.needCheck, nextCheck: day(5),
          keeper: 'Lê Văn Cường'),
      Equipment(id: 'e7', code: 'TB-CN-001', name: 'Mặt nạ phòng độc', type: 'Dụng cụ cứu nạn',
          quantity: 20, unit: 'chiếc', location: 'Kho PCCC – Tầng 1', inUseSince: day(-300),
          status: EquipmentStatus.ok, nextCheck: day(90), keeper: 'Hoàng Văn Em'),
      Equipment(id: 'e8', code: 'TB-CN-002', name: 'Thang dây cứu nạn', type: 'Dụng cụ cứu nạn',
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
      TrainingSession(id: 'ts2', planId: 'tp2', title: 'Kỹ năng sơ cấp cứu ban đầu',
          date: day(4, 14), location: 'Phòng họp tầng 3', instructor: 'Mời giảng viên y tế',
          content: 'Sơ cứu bỏng, cầm máu, hô hấp nhân tạo.', format: 'Lý thuyết + thực hành',
          durationMinutes: 180,
          attendance: ['m1', 'm2', 'm3', 'm5', 'm6'].map((id) => Attendance(memberId: id)).toList()),
      TrainingSession(id: 'ts3', planId: 'tp2', title: 'Hướng dẫn thoát nạn khi có cháy',
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
      Scenario(id: 'sc2', code: 'PA-02', name: 'Phương án cứu nạn người mắc kẹt trong thang máy',
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
      AppNotification(id: 'n1', title: 'Máy bơm chữa cháy cần sửa chữa',
          body: 'Kết quả kiểm tra: bơm không tự khởi động khi thử áp. Thiết bị ảnh hưởng đến khả năng sẵn sàng chữa cháy.',
          category: NotifCategory.urgent, priority: NotifPriority.high,
          createdAt: now.subtract(const Duration(hours: 5)),
          target: NotifTarget.equipment, targetId: 'e4'),
      AppNotification(id: 'n2', title: 'Ca trực đêm nay thiếu người',
          body: 'Ca 19:00 – 07:00 mới phân công 2/3 người, 1 người chưa xác nhận.',
          category: NotifCategory.schedule, priority: NotifPriority.high,
          createdAt: now.subtract(const Duration(hours: 2)),
          target: NotifTarget.shift, targetId: 's2'),
      AppNotification(id: 'n3', title: 'Hồ sơ PC14 cần bổ sung',
          body: 'Đơn vị tiếp nhận yêu cầu bổ sung ảnh chụp hiện trạng lối thoát nạn. Hạn còn 3 ngày.',
          category: NotifCategory.dossier, priority: NotifPriority.high,
          createdAt: now.subtract(const Duration(days: 1)),
          target: NotifTarget.dossier, targetId: 'd5'),
      AppNotification(id: 'n4', title: 'Buổi huấn luyện chưa được thực hiện',
          body: 'Buổi "Vận hành máy bơm chữa cháy" trong kế hoạch năm đã quá ngày dự kiến.',
          category: NotifCategory.urgent, priority: NotifPriority.medium,
          createdAt: now.subtract(const Duration(days: 2)),
          target: NotifTarget.training, targetId: 'ts4'),
      AppNotification(id: 'n5', title: 'Bình khí CO2 đến hạn kiểm tra',
          body: '8 bình CO2 MT3 tại phòng kỹ thuật điện đến hạn kiểm tra sau 2 ngày.',
          category: NotifCategory.upcoming, priority: NotifPriority.medium,
          createdAt: now.subtract(const Duration(days: 1, hours: 3)),
          target: NotifTarget.equipment, targetId: 'e2'),
      AppNotification(id: 'n6', title: 'Sắp diễn ra: Kỹ năng sơ cấp cứu',
          body: 'Buổi huấn luyện diễn ra sau 4 ngày tại phòng họp tầng 3.',
          category: NotifCategory.upcoming, priority: NotifPriority.low,
          createdAt: now.subtract(const Duration(days: 1)),
          target: NotifTarget.training, targetId: 'ts2'),
      AppNotification(id: 'n7', title: 'Hồ sơ PC12 đang chờ ký',
          body: 'Hồ sơ đã hoàn thiện, cần người đứng đầu ký trước khi gửi.',
          category: NotifCategory.dossier, priority: NotifPriority.medium,
          createdAt: now.subtract(const Duration(days: 1)), read: true,
          target: NotifTarget.dossier, targetId: 'd3'),
      AppNotification(id: 'n8', title: 'Thành viên chưa xác nhận lịch trực ngày mai',
          body: 'Phạm Thị Dung chưa xác nhận ca 07:00 – 19:00 ngày mai (đang tạm vắng).',
          category: NotifCategory.schedule, priority: NotifPriority.medium,
          createdAt: now.subtract(const Duration(hours: 8)),
          target: NotifTarget.shift, targetId: 's3'),
      AppNotification(id: 'n9', title: 'Thực tập phương án PA-01 sau 9 ngày',
          body: 'Cần hoàn tất phân công nhiệm vụ và rà soát phương tiện.',
          category: NotifCategory.upcoming, priority: NotifPriority.low,
          createdAt: now.subtract(const Duration(days: 3)), read: true,
          target: NotifTarget.drill, targetId: 'dr2'),
    ]);

    // ---------------- Phân quyền & nhật ký ----------------
    delegates.addAll([
      DelegatedUser(name: 'Lê Thu Hà', role: 'Cán bộ phụ trách PCCC & CNCH',
          scope: 'Hồ sơ, kế hoạch huấn luyện, phương án'),
      DelegatedUser(name: 'Nguyễn Văn An', role: 'Đội trưởng đội PCCC & CNCH',
          scope: 'Thành viên, lịch trực, huấn luyện'),
      DelegatedUser(name: 'Vũ Thị Giang', role: 'Người phụ trách thiết bị',
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
