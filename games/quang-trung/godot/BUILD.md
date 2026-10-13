# BUILD — Tây Sơn (Godot)

Hướng dẫn cho **session Claude Code chạy trên máy chủ dự án** (và cho người). Làm theo đúng thứ tự, không cần hỏi lại.

## 1. Phiên bản Godot (ghim cứng)

**Godot 4.7.2-stable** (bản thường, không phải .NET).

| Máy | File | Nguồn |
|---|---|---|
| macOS | `Godot_v4.7.2-stable_macos.universal.zip` | https://github.com/godotengine/godot/releases/tag/4.7.2-stable |
| Linux | `Godot_v4.7.2-stable_linux.x86_64.zip` (SHA-512 `9aa00f7a…3e925850368e150c59ed54c65`, xem `SHA512-SUMS.txt` trong release) | như trên |
| Export templates | `Godot_v4.7.2-stable_export_templates.tpz` | như trên |

Kiểm tra: `godot --version` phải in `4.7.2.stable.official.ed1daf0bf`.

Trong các lệnh dưới, `GODOT` là đường dẫn tới file chạy Godot (trên macOS: `/Applications/Godot.app/Contents/MacOS/Godot`).
Mọi lệnh chạy trong thư mục `games/quang-trung/godot/`.

## 2. Lần đầu: nhập tài nguyên

```bash
GODOT --headless --path . --import
```

## 3. Chạy test (bắt buộc trước mỗi lần build)

```bash
GODOT --headless --path . -s res://tests/run_tests.gd
```
Dòng cuối phải là `N test, M kiểm tra, 0 lỗi`; mã thoát 0. Có lỗi thì **không build**, báo lại nguyên văn các dòng `FAIL`.

## 4. Chạy game trên máy tính

```bash
GODOT --path .                                   # cửa sổ 576x1024 (dọc)
GODOT --path . -- --man=m_thu --seed=5           # chọn màn, seed
GODOT --path . -- --tu-dong                      # máy chơi cả hai phe
GODOT --path . -- --anh=/tmp/a.png --cho=2       # chụp màn hình rồi thoát
GODOT --path . -- --kich-ban=res://tests/kich_ban/co_ban.txt   # chạy kịch bản chạm
```
Linux không có màn hình: thêm `xvfb-run -a -s "-screen 0 1280x1280x24"` trước lệnh và `--rendering-driver opengl3`.

## 5. Android

Chuẩn bị một lần:
1. Cài export templates 4.7.2 (Editor → Editor → Manage Export Templates → Install from file, chọn file `.tpz`).
2. Cài **JDK 17** và **Android SDK** (Android Studio, có Platform-Tools, Build-Tools, platform đúng target API Google Play đang yêu cầu).
3. Editor → Editor Settings → Export → Android: điền `Java SDK Path`, `Android SDK Path`. Godot tự tạo debug keystore.
4. `export_presets.cfg` đã có preset **"Android"**. Đổi `package/unique_name` từ `com.example.tayson` sang mã ứng dụng thật trước khi phát hành.

Bản thử (APK debug) và cài lên máy qua cáp USB (bật Gỡ lỗi USB):
```bash
mkdir -p export/android
GODOT --headless --path . --export-debug "Android" export/android/tay_son.apk
adb install -r export/android/tay_son.apk
```
Bản phát hành Google Play (AAB): bật `gradle_build/use_gradle_build=true` (cài Android build template: Project → Install Android Build Template),
khai báo keystore phát hành (không commit keystore vào repo), rồi `--export-release "Android" export/android/tay_son.aab`.

## 6. iOS (máy Mac)

1. Cài Xcode, đăng nhập tài khoản Apple Developer trong Xcode.
2. Trong preset **"iOS"**: điền `application/app_store_team_id`, đổi `application/bundle_identifier`.
3. Xuất project Xcode:
   ```bash
   mkdir -p export/ios
   GODOT --headless --path . --export-debug "iOS" export/ios/TaySon.ipa
   ```
   Nếu export trực tiếp lỗi ký, mở project Xcode Godot tạo ra trong `export/ios/`, chọn team, cắm iPhone, bấm Run.
4. **Không dùng iOS Simulator** với template chính thức 4.7.2: phần simulator trong template chỉ có x86_64, simulator iOS 27 không chạy được
   (báo cáo 13/10/2026). Thử trên **iPhone thật**. Nếu bắt buộc cần simulator: tự build template
   `scons platform=ios target=template_debug arch=arm64 simulator=yes`.
5. Biểu tượng: `assets/icon/icon_1024.png` (sinh bằng `tools/gen_icon.py`) đã gán cho project và preset iOS.

## 7. Tạo lại hình và âm thanh (không bắt buộc)

Hình, nhạc, tiếng trong `assets/` đều sinh bằng code và đã commit sẵn; chỉ chạy lại khi sửa công cụ. Cần Python 3 + Pillow + numpy,
và ffmpeg có libvorbis (cho nhạc .ogg). Chạy ở thư mục `games/quang-trung/`:

```bash
python3 tools/gen_placeholders.py   # hình quân, ô bản đồ, giao diện tạm
python3 tools/gen_objects.py        # trống báo động, đèn
python3 tools/gen_icon.py           # biểu tượng app
python3 tools/gen_audio.py          # nhạc (chủ đề, đêm, thắng, thua) + 19 tiếng hiệu ứng, khoảng 15 giây
```

Sau đó mở lại Godot (hoặc `GODOT --headless --path . --import`) để nhập lại.

## 8. Sau khi build

- Ghi lại: phiên bản Godot, commit (`git rev-parse --short HEAD`), máy thử, kết quả test.
- Làm theo [TESTING.md](TESTING.md) và gửi kết quả cho chủ dự án / Claude.
- Thư mục `export/` và `.godot/` đã được bỏ qua trong git.
