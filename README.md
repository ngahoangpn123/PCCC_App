# App PCCC & CNCH (Flutter)

App hỗ trợ người đứng đầu cơ sở thực hiện trách nhiệm PCCC và CNCH.
Giai đoạn hiện tại: **giao diện hoàn chỉnh, dữ liệu mẫu trong bộ nhớ**, chưa nối Supabase.

## Chạy lần đầu

1. Giải nén thư mục `pccc_app` vào nơi bạn muốn (đường dẫn không dấu, không dấu cách).
2. Mở terminal trong thư mục đó, sinh các thư mục nền tảng (android, ios) còn thiếu:

   ```bash
   flutter create --org vn.edu.hust --platforms android,ios .
   ```

   Lệnh này chỉ tạo file còn thiếu, không ghi đè `lib/`, `pubspec.yaml`, `test/`.
3. Tải thư viện: `flutter pub get`
4. Chạy: `flutter run` (hoặc nút Run trong Android Studio).
5. Màn đăng nhập đã điền sẵn tài khoản mẫu, bấm **Đăng nhập** là vào.

Chưa cần file `env/dev.json`. Khi nối Supabase: copy `env/dev.example.json` thành
`env/dev.json`, điền URL và publishable key, rồi chạy
`flutter run --dart-define-from-file=env/dev.json`.

## Cấu trúc thư mục

```
lib/
├── main.dart                 Điểm khởi động (khởi tạo Supabase nếu có env)
├── app.dart                  MaterialApp, theme, tiếng Việt
├── core/                     Phần dùng chung
│   ├── di/locator.dart       NƠI DUY NHẤT chọn nguồn dữ liệu (Mock ↔ Supabase)
│   ├── mock/                 Dữ liệu mẫu trong bộ nhớ
│   ├── models/               Model dùng chung (lịch sử thay đổi)
│   ├── session/              Cơ sở đang được chọn
│   ├── supabase/             (để trống) chỗ cho phần kết nối database
│   ├── theme/                Màu đỏ đô – trắng – vàng đồng
│   ├── utils/                Định dạng ngày, hàm tiện ích
│   └── widgets/              Widget dùng chung (thẻ, chip, ô nhập, lịch sử...)
└── features/                 Mỗi chức năng một thư mục
    ├── auth/                 Màn chờ, đăng nhập, đăng ký, quên mật khẩu
    ├── shell/                Thanh điều hướng 5 tab
    ├── home/                 Tab Trang chủ
    ├── management/           Tab Quản lý (cửa vào 5 chức năng)
    ├── facility/             1. Thông tin & hồ sơ cơ sở
    ├── team/                 2. Đội PCCC & CNCH, lịch trực
    ├── equipment/            3. Phương tiện & thiết bị
    ├── training/             4. Huấn luyện, bồi dưỡng
    ├── drills/               5. Phương án, thực tập, diễn tập
    ├── calendar/             Tab Lịch
    ├── notifications/        Tab Thông báo
    └── profile/              Tab Cá nhân

Mỗi chức năng gồm:
    models/    Lớp dữ liệu (Facility, Dossier, Member, Shift, Equipment...)
    data/      Repository: lớp trừu tượng + bản Mock + bản Supabase (để trống)
    screens/   Các màn hình
```

## Danh sách màn hình

| Khu vực | Màn hình |
|---|---|
| Đăng nhập | Màn chờ, Đăng nhập, Đăng ký, Quên mật khẩu |
| Trang chủ | Thẻ cơ sở (đổi cơ sở), 4 ô thống kê, việc cần xử lý ngay, lịch 7 ngày tới, truy cập nhanh |
| 1. Hồ sơ cơ sở | Thông tin cơ sở, sửa thông tin, kho biểu mẫu (tìm/lọc), chi tiết mẫu, theo dõi hồ sơ (lọc theo 8 trạng thái), chi tiết hồ sơ (quy trình 5 bước, tệp, lịch sử, chuyển trạng thái), tạo/sửa hồ sơ |
| 2. Đội PCCC | Danh sách thành viên, hồ sơ thành viên, thêm/sửa; lịch trực (lịch tháng / danh sách), chi tiết ca (quân số, xác nhận, vắng mặt, bàn giao), tạo ca (cảnh báo trùng lịch, thiếu người); tab cảnh báo tự động |
| 3. Thiết bị | Danh sách (thống kê, lọc đến hạn / tình trạng), chi tiết + lịch sử + xác nhận kết quả, thêm/sửa, kiểm tra theo checklist + ảnh, quét QR |
| 4. Huấn luyện | Kế hoạch (tiến độ), chi tiết kế hoạch, buổi huấn luyện, chi tiết buổi (điểm danh, kết quả từng người, đánh giá, minh chứng), tạo/sửa buổi và kế hoạch |
| 5. Diễn tập | Phương án, chi tiết phương án, đợt diễn tập, chi tiết đợt (vòng đời 5 bước, kết quả, vấn đề, nhiệm vụ khắc phục), tạo/sửa |
| Lịch | Lịch sự kiện và lịch trực tách riêng; xem theo ngày / tuần / tháng; lọc theo loại |
| Thông báo | Lọc theo trạng thái xử lý, loại, ưu tiên, thời gian; chi tiết, mở đối tượng liên quan, xác nhận đã xử lý |
| Cá nhân | Tài khoản, đổi cơ sở, phân quyền, cài đặt thông báo, bảo mật, nhật ký, hướng dẫn & phản hồi, đăng xuất |

## Việc còn để lại (đánh dấu TODO trong code)

- Nối Supabase: viết các lớp `Supabase...Repository`, đổi trong `core/di/locator.dart`.
- Tên, mục đích chính thức của các mẫu PC01, PC11–PC23 (đang để tên tạm).
- Checklist kiểm tra chuẩn cho từng loại thiết bị.
- Thư viện cần thêm sau: `mobile_scanner` (quét QR), `image_picker` (chụp ảnh),
  `file_picker` (đính kèm tệp), `url_launcher` (gọi điện).
- Nếu `Supabase.initialize(publishableKey: ...)` báo lỗi với bản thư viện của bạn,
  đổi `publishableKey` thành `anonKey`.
