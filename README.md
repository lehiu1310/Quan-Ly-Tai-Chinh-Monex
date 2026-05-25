# 💰 Monex - Ứng dụng quản lý tài chính cá nhân

Monex là ứng dụng quản lý tài chính cá nhân chạy trên Android, được xây dựng bằng Flutter.

Ứng dụng hỗ trợ người dùng theo dõi thu nhập, chi phí, tiết kiệm, hóa đơn, biểu đồ phân tích và các cảnh báo tài chính thông minh dựa trên dữ liệu thật.

---

## 🧱 Công nghệ sử dụng

- Mobile Framework: Flutter
- Programming Language: Dart
- State Management: ChangeNotifier
- Local Storage: SharedPreferences
- Chart: fl_chart
- Local Notification: flutter_local_notifications
- Home Widget: home_widget
- PDF Export: pdf + printing
- Excel Export: syncfusion_flutter_xlsio
- File Sharing: share_plus
- Animation: Lottie
- IDE: Android Studio

---

## ✨ Chức năng chính

- Đăng ký, đăng nhập và lưu tài khoản cục bộ.
- Mỗi tài khoản có dữ liệu thu chi riêng, không bị lẫn với tài khoản khác.
- Thêm thu nhập, chi phí và danh mục giao dịch.
- Tìm kiếm, lọc giao dịch theo tên, loại và thời gian.
- Quản lý mục tiêu tiết kiệm theo kiểu bỏ lợn đất: nạp tiền từng lần và rút tiền khi cần.
- Tạo hóa đơn, lời nhắc và thông báo cục bộ.
- Trợ lý tài chính/nhắc nhở chi tiêu dựa trên dữ liệu thật.
- Biểu đồ phân tích thu chi và xu hướng theo tháng.
- Xuất báo cáo PDF/Excel và chia sẻ file.
- Hỗ trợ onboarding, dark mode, skeleton loading và home widget.

---

## 📁 Cấu trúc thư mục

```text
monex/
├── android/                 # Cấu hình chạy Android
├── lib/
│   ├── data/                # AppState, model dữ liệu, preferences
│   ├── screens/             # Các màn hình giao diện
│   │   ├── auths/           # Đăng nhập, đăng ký, quên mật khẩu
│   │   ├── onboarding/      # Màn hình giới thiệu lần đầu
│   │   ├── pages/           # Tổng quan, thu chi, tiết kiệm, hóa đơn, phân tích
│   │   └── widgets/         # Widget dùng lại trong app
│   ├── services/            # Thông báo, báo cáo, trợ lý tài chính, home widget
│   └── theme/               # Theme sáng/tối và nền ứng dụng
├── reports/                 # Báo cáo PDF của ứng dụng
├── tools/                   # Script hỗ trợ chạy, format, phân tích code
├── pubspec.yaml             # Khai báo package Flutter
└── README.md
```

---

## ▶️ 1. Mở project bằng Android Studio

Mở Android Studio, chọn:

```text
File -> Open
```

Sau đó chọn đúng thư mục:

```text
D:\HOC_TAP\quan_ly_tai_chinh\monex
```

Không chọn thư mục cha `quan_ly_tai_chinh` vì trong đó có thể có các thư mục phụ không phải project Flutter chính.

---

## ▶️ 2. Cài dependencies

Tại thư mục gốc project, chạy:

```bash
flutter pub get
```

Hoặc trong Android Studio bấm nút:

```text
Pub get
```

---

## ▶️ 3. Chạy ứng dụng trên Android Studio

Chọn Android Emulator hoặc thiết bị Android thật.

Sau đó bấm nút Run trong Android Studio, hoặc chạy:

```bash
flutter run
```

Nếu dùng script đã chuẩn bị trong project:

```bash
tools\run_android_d.bat
```

---

## ▶️ 4. Đăng nhập hệ thống

Tài khoản demo có sẵn:

```text
Username: minh
Email: minh@monex.vn
Password: 123456
```

Ngoài ra, người dùng có thể tự tạo tài khoản mới trong màn hình đăng ký.

Dữ liệu của mỗi tài khoản được lưu riêng, ví dụ tài khoản A sẽ không nhìn thấy thu chi của tài khoản B.

---

## ▶️ 5. Kiểm tra các chức năng chính

Sau khi đăng nhập, có thể kiểm tra các chức năng:

- Thêm thu nhập
- Thêm chi phí
- Thêm danh mục giao dịch
- Tìm kiếm và lọc giao dịch
- Tạo mục tiêu tiết kiệm
- Nạp/rút tiền tiết kiệm
- Tạo hóa đơn/lời nhắc
- Xem thông báo thông minh
- Xem biểu đồ phân tích
- Xuất báo cáo PDF/Excel

---

## ▶️ 6. Báo cáo PDF

File báo cáo của ứng dụng nằm tại:

```text
reports/Bao_cao_Monex.pdf
```

Báo cáo trình bày tổng quan ứng dụng, yêu cầu hệ thống, công nghệ sử dụng, kiến trúc, thiết kế dữ liệu, kiểm thử, đánh giá và hướng phát triển.

---

## ▶️ 7. Kiểm tra code

Chạy phân tích Dart/Flutter:

```bash
flutter analyze
```

Hoặc dùng script:

```bash
tools\analyze_d.bat
```

---

## 📝 Ghi chú

- Project được cấu hình để chạy bằng Android Studio.
- Dữ liệu hiện được lưu cục bộ bằng SharedPreferences.
- Ứng dụng chưa dùng backend/cloud, phù hợp cho phạm vi demo học phần.
- Các thư mục build/cache như `build`, `.dart_tool`, `.runtime` không được đưa lên GitHub.
