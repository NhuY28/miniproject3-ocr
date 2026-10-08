# OCR Expense Tracker

Ứng dụng quản lý chi tiêu cá nhân bằng Flutter, hỗ trợ quét hóa đơn và tự động nhận diện tổng tiền bằng Google ML Kit OCR.

## Công nghệ

- Flutter / Dart
- Google ML Kit Text Recognition
- Camera
- Provider
- GoRouter
- SharedPreferences
- CustomPainter

## Chức năng

- Chụp hóa đơn bằng Camera
- Nhận diện nội dung hóa đơn bằng OCR
- Tự động lấy tổng tiền
- Kiểm tra và chỉnh sửa thông tin hóa đơn
- Lưu và quản lý khoản chi tiêu
- Thống kê chi tiêu bằng biểu đồ

##  Cài đặt

### 1. Clone project

```bash
git clone <GITHUB_REPOSITORY_URL>
cd ocr_expense_tracker
```

### 2. Cài dependencies

```bash
flutter pub get
```

### 3. Kiểm tra môi trường

```bash
flutter doctor
flutter devices
```

### 4. Chạy trên Android Emulator

Mở Android Studio → Device Manager → khởi động emulator.

Sau đó:

```bash
flutter run -d emulator-5554
```

Hoặc chạy trên điện thoại Android thật:

```bash
flutter run
```

## Build APK

```bash
flutter build apk --release
```

APK nằm tại:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Kiểm tra

```bash
flutter analyze
flutter test
```

## Demo

Luồng sử dụng:

```text
Home
→ Scan Receipt
→ Camera
→ OCR
→ Receipt Result
→ Save Expense
→ Expenses
→ Statistics
```

## Links

- **GitHub:** `<GITHUB_REPOSITORY_URL>`
- **APK:** `<APK_DOWNLOAD_LINK>`
- **Demo Video:** `<DEMO_VIDEO_LINK>`

## Author

**Mai Thị Như Ý – 23IT326**