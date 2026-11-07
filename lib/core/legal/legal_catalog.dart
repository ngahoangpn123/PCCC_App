/// Danh mục pháp lý dùng chung, lấy từ "Bản đặc tả tổng hợp tính năng"
/// (căn cứ NĐ 347/2026, CV 3038/C07-P3,P4, NĐ 105/2025, TT 36/2025).
/// Khi văn bản thay đổi chỉ cần sửa file này.
library;

/// Một mục có mã + tên + mô tả ngắn.
class CatalogItem {
  const CatalogItem(this.code, this.name, [this.detail = '']);

  final String code;
  final String name;
  final String detail;
}

// ---------------------------------------------------------------------------
// 16 bảng kiểm tra kỹ thuật hậu kiểm (Phụ lục IV CV 3038/C07)
// ---------------------------------------------------------------------------
const htTables = <CatalogItem>[
  CatalogItem('HT1', 'Hệ thống báo cháy tự động loại thường'),
  CatalogItem('HT2', 'Hệ thống báo cháy tự động loại địa chỉ'),
  CatalogItem('HT3', 'Trạm bơm cấp nước chữa cháy'),
  CatalogItem('HT4', 'Hệ thống cấp nước chữa cháy ngoài nhà'),
  CatalogItem('HT5', 'Hệ thống họng nước chữa cháy trong nhà'),
  CatalogItem('HT6', 'Hệ thống chữa cháy tự động bằng nước, bọt'),
  CatalogItem('HT7', 'Hệ thống chữa cháy bằng bọt cố định'),
  CatalogItem('HT8', 'Hệ thống chữa cháy bằng khí hóa lỏng'),
  CatalogItem('HT9', 'Hệ thống chữa cháy bằng khí nén'),
  CatalogItem('HT10', 'Hệ thống chữa cháy tự động bằng khí CO2'),
  CatalogItem('HT11', 'Hệ thống chữa cháy bằng Sol-khí'),
  CatalogItem('HT12', 'Bình chữa cháy xách tay; dụng cụ phá dỡ thô sơ; mặt nạ lọc độc/cách ly'),
  CatalogItem('HT13', 'Chiếu sáng sự cố, chỉ dẫn thoát nạn & loa thoát nạn'),
  CatalogItem('HT14', 'Hệ thống điện phục vụ phòng cháy và chữa cháy'),
  CatalogItem('HT15', 'Chữa cháy tự động bằng nước cho nhà kho có giá kệ hàng'),
  CatalogItem('HT16', 'Hệ thống chữa cháy bằng bột'),
];

String htName(String code) =>
    htTables.where((e) => e.code == code).map((e) => e.name).firstOrNull ?? code;

/// Tên nhóm HT kèm mã, dùng chung ở nhiều màn hình.
String htLabel(String code) => '$code – ${htName(code)}';

// ---------------------------------------------------------------------------
// 21 hạng mục tự nghiệm thu (Mục 2 Phụ lục II CV 3038/C07)
// ---------------------------------------------------------------------------
const acceptanceItems = <CatalogItem>[
  CatalogItem('2.1', 'Đường giao thông, bãi đỗ xe chữa cháy, chiều cao PCCC',
      'Chiều rộng, chiều cao thông thủy, độ dốc, tải trọng mặt đường; biển báo bãi đỗ; lối vào trên cao; mốc chiều cao PCCC.'),
  CatalogItem('2.2', 'Khoảng cách an toàn PCCC đến công trình lân cận',
      'Khoảng cách thông thủy; tường ngăn cháy REI 150 / REI 45; lỗ mở ≤ 25% diện tích tường; mái đua vật liệu cháy > 1 m.'),
  CatalogItem('2.3', 'Bậc chịu lửa của nhà, công trình, khoang cháy',
      'Đối chiếu cấu kiện với Phụ lục F QCVN 06:2022/BXD; độ dày lớp bọc/sơn chống cháy kết cấu thép.'),
  CatalogItem('2.4', 'Bố trí công năng các tầng, gian phòng',
      'Công năng từng phòng, tầng; cảnh báo tự ý đổi công năng, tăng số tầng, giá kệ vượt chiều cao thiết kế.'),
  CatalogItem('2.5', 'Giải pháp ngăn cháy theo chiều ngang và chiều đứng',
      'Cửa/màn ngăn cháy, diện tích khoang cháy, ngăn cháy hành lang dài, chèn bịt trục kỹ thuật.'),
  CatalogItem('2.6', 'Giải pháp thoát nạn (buồng thang, đường & lối thoát nạn)',
      'Số lượng, chiều rộng thang; lỗ lấy sáng ≥ 1,2 m²; chiều mở cửa; sơ đồ chỉ dẫn theo TCVN 13456:2022.'),
  CatalogItem('2.7', 'Gian lánh nạn (nhà cao tầng có yêu cầu)',
      'Không bố trí căn hộ/kho; diện tích ≥ 0,3 m²/người; ô thông gió; khoang đệm ngăn cháy.'),
  CatalogItem('2.8', 'Thang máy chữa cháy',
      'Cửa tự cứu nóc cabin, điện thoại liên lạc, 02 nguồn điện, áp suất buồng đệm 20–50 Pa, chế độ về tầng 1.'),
  CatalogItem('2.9', 'Hệ thống tăng áp chống khói',
      'Khoảng cách miệng lấy gió – thải khói ≥ 5 m; bọc ống gió; áp suất buồng đệm/buồng thang 20–50 Pa.'),
  CatalogItem('2.10', 'Hệ thống hút khói hành lang và gian phòng',
      'Quạt chịu nhiệt, van ngăn cháy, thử liên động, 02 nguồn điện.'),
  CatalogItem('2.11', 'Hệ thống báo cháy tự động',
      'Tủ trung tâm, cáp chống cháy riêng, vị trí đầu báo, nút ấn cao 1,4 ± 0,2 m cách nhau ≤ 45 m.'),
  CatalogItem('2.12', 'Chiếu sáng sự cố và chỉ dẫn thoát nạn',
      'Độ rọi, biển chỉ dẫn cao ≤ 2,7 m, pin dự phòng ≥ 2 giờ (≥ 3 giờ với một số loại nhà).'),
  CatalogItem('2.13', 'Trạm bơm nước chữa cháy và bể nước dự trữ',
      'Lưu lượng/cột áp bơm chính, dự phòng, bù áp; thể tích bể; thử chạy bơm bằng tay và tự động.'),
  CatalogItem('2.14', 'Chữa cháy bằng nước (trụ ngoài nhà, vách tường, Sprinkler, Drencher)',
      'Áp lực đầu lăng ≤ 0,4 MPa tại vị trí bất lợi nhất; hệ số K, súc rửa ống, Alarm/Deluge valve.'),
  CatalogItem('2.15', 'Chữa cháy tự động bằng bọt (Foam)',
      'Bồn bọt, bộ trộn tỷ lệ, đầu phun; kích hoạt bởi 02 đầu báo thuộc 02 kênh.'),
  CatalogItem('2.16', 'Chữa cháy bằng khí (FM-200, Nitơ, CO2, Sol-khí...)',
      'Cân bằng tuyến ống lệch ≤ 10%; chuông/đèn xả khí; nút xả cưỡng bức & trì hoãn; độ kín phòng.'),
  CatalogItem('2.17', 'Phương tiện chữa cháy ban đầu, cứu người, phá dỡ, mặt nạ',
      'Số lượng, chủng loại, vị trí bình xách tay, dụng cụ phá dỡ, mặt nạ theo định mức.'),
  CatalogItem('2.18', 'Nguồn điện ưu tiên cấp cho hệ thống PCCC',
      'Cáp chống cháy lộ riêng, máy phát dự phòng; cảnh báo Aptomat tự ngắt quá tải trên mạch PCCC.'),
  CatalogItem('2.19', 'Phòng trực điều khiển chống cháy',
      'Diện tích tối thiểu 6 m², tủ điều khiển, nút khởi động cưỡng bức quạt, liên lạc.'),
  CatalogItem('2.20', 'Hệ thống cấp khí đốt LPG trung tâm (nếu có)',
      'Khoảng cách an toàn, thử kín ống, đầu dò rò rỉ, van ngắt khẩn cấp.'),
  CatalogItem('2.21', 'Hệ thống loa thông báo và hướng dẫn thoát nạn',
      'Cáp chống cháy, vị trí loa, nguồn dự phòng; phát thông báo theo vùng.'),
];

// ---------------------------------------------------------------------------
// 9 nhóm trách nhiệm của người đứng đầu (Phụ lục III CV 3038/C07)
// TODO: điền tên chính thức từng nhóm theo Phụ lục III (bản đặc tả chưa liệt kê).
// ---------------------------------------------------------------------------
const responsibilityGroups = <CatalogItem>[
  CatalogItem('N1', 'Nhóm trách nhiệm 1'),
  CatalogItem('N2', 'Nhóm trách nhiệm 2'),
  CatalogItem('N3', 'Nhóm trách nhiệm 3'),
  CatalogItem('N4', 'Nhóm trách nhiệm 4'),
  CatalogItem('N5', 'Nhóm trách nhiệm 5'),
  CatalogItem('N6', 'Nhóm trách nhiệm 6'),
  CatalogItem('N7', 'Nhóm trách nhiệm 7'),
  CatalogItem('N8', 'Nhóm trách nhiệm 8'),
  CatalogItem('N9', 'Bảo hiểm cháy, nổ bắt buộc'),
];

// ---------------------------------------------------------------------------
// Đo thông số ở Bước 3 – App tự so sánh với chuẩn và báo đỏ nếu không đạt.
// ---------------------------------------------------------------------------
class MeasureSpec {
  const MeasureSpec(this.name, this.unit, {this.min, this.max});

  final String name;
  final String unit;
  final double? min;
  final double? max;

  String get rule {
    if (min != null && max != null) return '${_n(min!)}–${_n(max!)} $unit';
    if (min != null) return '≥ ${_n(min!)} $unit';
    return '≤ ${_n(max!)} $unit';
  }

  bool passes(double v) =>
      (min == null || v >= min!) && (max == null || v <= max!);

  static String _n(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString().replaceAll('.', ',');
}

const measureSpecs = <MeasureSpec>[
  MeasureSpec('Áp suất buồng đệm / buồng thang', 'Pa', min: 20, max: 50),
  MeasureSpec('Áp lực đầu lăng họng nước trong nhà', 'MPa', max: 0.4),
  MeasureSpec('Thời gian pin đèn chiếu sáng sự cố', 'giờ', min: 2),
];

// ---------------------------------------------------------------------------
// Quy định về huấn luyện (Điều 22 NĐ 347/2026)
// ---------------------------------------------------------------------------
const trainingHoursMin = 24;
const trainingHoursMax = 32;
const refresherHoursMin = 8;
const refresherHoursMax = 12;

// ---------------------------------------------------------------------------
// Mô hình tổ chức lực lượng PCCC tại cơ sở (Điều 20 NĐ 105/2025, NĐ 347/2026)
// ---------------------------------------------------------------------------
String teamModelFor(int staffCount) => staffCount < 20
    ? 'Dưới 20 người thường xuyên làm việc → lập Văn bản phân công người thực hiện nhiệm vụ PCCC'
    : 'Từ 20 người trở lên → lập Quyết định thành lập Đội PCCC cơ sở';

const specializedTeamNote =
    'Đội PCCC chuyên ngành: kiêm nhiệm (KCN ≥ 75 ha, kho dầu 100.000–500.000 m³, '
    'nhiệt điện 600–1.200 MW, thủy điện ≥ 1.000 MW, sân bay < 10 triệu khách/năm) '
    'hoặc chuyên trách (kho dầu ≥ 500.000 m³, nhiệt điện ≥ 1.200 MW, sân bay ≥ 10 triệu khách/năm).';

/// 7 vai trò người dùng (RBAC).
const userRoles = <CatalogItem>[
  CatalogItem('R1', 'Người đứng đầu cơ sở / Chủ đầu tư', 'Toàn quyền quản lý, phân công, ký số Mẫu PC18, PC01, PC06'),
  CatalogItem('R2', 'Người phụ trách PCCC & CNCH', 'Quản lý hồ sơ, lập kế hoạch, tổng hợp báo cáo'),
  CatalogItem('R3', 'Đội trưởng Đội PCCC', 'Quản lý đội viên, lịch trực, điểm danh huấn luyện'),
  CatalogItem('R4', 'Người phụ trách thiết bị', 'Quét QR kiểm tra HT1–HT16, cập nhật bảo dưỡng & Mẫu 01'),
  CatalogItem('R5', 'Nhân viên / Đội viên được giao nhiệm vụ', 'Cập nhật tiến độ công việc được giao'),
  CatalogItem('R6', 'Đơn vị thi công & tư vấn giám sát', 'Tài khoản có thời hạn: tải CO/CQ, bản vẽ hoàn công, ký biên bản Bước 1–4'),
  CatalogItem('R7', 'Đoàn kiểm tra hậu kiểm', 'Quét QR xem hồ sơ điện tử, gửi Biên bản kiểm tra Mẫu PC03'),
];
