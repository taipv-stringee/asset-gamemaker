# 08 — Thiết kế kỹ thuật (Godot 4)

## 1. Phiên bản và công cụ

- **Godot 4.x**: bản ổn định mới nhất tại thời điểm dựng project (tối thiểu 4.3 vì cần `TileMapLayer`), sau đó **ghim cứng**
  phiên bản trong `godot/BUILD.md` kèm link tải và checksum; chỉ nâng cấp giữa các mốc. Đã kiểm: môi trường cloud tải được
  bản Godot Linux từ GitHub Releases, nên test headless chạy được ở cả cloud lẫn máy chủ dự án.
- Ngôn ngữ: **GDScript** có khai báo kiểu (bật cảnh báo `untyped_declaration` trong Project Settings).
- Kiểm thử tự động: **GUT** hoặc **gdUnit4** (chọn một khi dựng project).
- Script Python (Pillow, numpy) tiếp tục dùng để sinh hình tạm, nằm trong `tools/`.

## 2. Cấu trúc thư mục

```
games/quang-trung/
├─ docs/                    # tài liệu này
├─ tools/                   # script Python sinh hình tạm, kiểm tra dữ liệu
└─ godot/                   # project Godot (project.godot)
   ├─ data/
   │  ├─ units.csv          # chỉ số lính (nguồn chuẩn, sửa bằng bảng tính)
   │  ├─ terrain.csv        # chi phí đi, thủ theo địa hình
   │  ├─ counters.csv       # bảng khắc chế
   │  ├─ codex/             # mục Sử liệu (.md hoặc .json, có trường "nhan_nguon")
   │  ├─ missions.json      # dữ liệu từng màn: vàng, giới hạn, mua_duoc, tướng chính, tam_nhin, vòng rạng sáng
   │  └─ dialogue/          # kịch bản hội thoại theo màn (.csv)
   ├─ missions/
   │  ├─ m00_rut_ve_tam_diep/
   │  │  ├─ map.tscn        # TileMapLayer địa hình + vật thể + điểm đặt quân
   │  │  └─ mission.gd      # điều kiện thắng thua, sự kiện, lượt rạng sáng...
   │  └─ ...
   ├─ scenes/               # battle, ui, dialogue, campaign_map, codex, menu
   ├─ scripts/
   │  ├─ core/              # luật chơi thuần, KHÔNG phụ thuộc Node (test được)
   │  ├─ ai/
   │  └─ ui/
   ├─ assets/               # png, âm thanh, phông
   ├─ localization/         # vi.csv (khóa → chuỗi), en.csv để sau
   └─ tests/
```

## 3. Kiến trúc

### 3.1. Tách luật chơi khỏi hiển thị

- `scripts/core/` chứa trạng thái trận đấu dưới dạng dữ liệu thuần (`RefCounted`/`Resource`):
  `BattleState` (bản đồ, quân, phe, vàng, lượt, seed RNG), `Unit`, `Tile`.
- Mọi thay đổi trạng thái đi qua **lệnh** (`MoveCommand`, `AttackCommand`, `CaptureCommand`, `RecruitCommand`, `SurrenderCommand`,
  `EndTurnCommand`). Lệnh trả về danh sách **sự kiện** (`UnitMoved`, `DamageDealt`, `UnitDefeated`, `LevelUp`, ...).
- Lớp hiển thị (`scenes/battle`) chỉ nghe sự kiện và chạy hoạt cảnh. Lợi ích: test luật không cần mở cảnh; AI dùng chung lệnh với người chơi;
  hoàn tác bước đi là bỏ lệnh cuối; lưu game là lưu `BattleState`.

### 3.2. Các hệ thống

| Hệ thống | Cách làm |
|---|---|
| **Tìm đường** | Dijkstra tự viết trên lưới (chi phí theo kiểu di chuyển + vùng khống chế + quân chặn). `AStarGrid2D` chỉ dùng cho đường đi của AI tới mục tiêu xa |
| **Đánh** | `CombatResolver` thuần, nhận RNG có seed; hàm `forecast()` trả về khoảng sát thương cho giao diện dự báo |
| **Lượt** | Máy trạng thái: `PhaseStart → PlayerInput / AIThinking → PhaseEnd`; thứ tự phe Tây Sơn → Diễn tập → Thanh → Lê (02 §1) |
| **AI** | Chấm điểm (utility) theo [02 mục 14](02-luat-choi.md#14-ai); chạy theo từng quân, có giới hạn thời gian mỗi quân (vd. 30 ms) để không giật |
| **Sương mù** | Mảng boolean tầm nhìn tính lại sau mỗi lệnh; hiển thị bằng một `TileMapLayer` phủ hoặc shader |
| **Bộ lọc đêm** | Shader `CanvasItem` toàn màn: nhân màu xanh tối + cộng ánh sáng từ texture "light map" (vẽ các nguồn sáng); chia bậc sáng để giữ chất pixel. Cùng thuật toán với `night()` trong `generate_v2.py` |
| **Kịch bản màn** | `mission.gd` kế thừa `Mission` (lớp gốc), ghi đè `on_turn_start(turn)`, `on_unit_defeated(u)`, `check_victory()`, ... và gọi API: `spawn()`, `say()`, `set_ai_mode()`, `collapse_bridge()` |
| **Hội thoại** | File CSV: `id, nguoi_noi, bieu_cam, khoa_chu, lenh`. Chữ lấy qua `tr(khoa_chu)` để dịch về sau. Bộ chạy hội thoại tự viết (nhu cầu đơn giản: chân dung, tên, chữ, vài lệnh camera) |
| **Sử liệu** | Mỗi mục một file, có `id`, `nhom`, `nhan_nguon` (`su_lieu` / `hlntc` / `tuong_truyen` / `sang_tao`), `nguon[]`, điều kiện mở |
| **Lưu** | Xem §3.4 |
| **Âm thanh** | Autoload `Audio`, hai bus Nhạc / Hiệu ứng |

### 3.3. Autoload

`Game` (tiến trình chiến dịch, cài đặt), `Save`, `Audio`, `Data` (nạp CSV lúc khởi động, kiểm tra lỗi dữ liệu).

### 3.4. Lưu game

- Hai khe: **chiến dịch** (tiến trình + `BattleState` màn đang chơi + ảnh chụp cấp tướng đầu mỗi màn) và **chơi lại** (màn cũ, không ghi đè chiến dịch).
- Định dạng: `var_to_str` / `FileAccess.store_var` (giữ đúng kiểu `int` 64 bit). **Không** dùng JSON cho trạng thái trận: JSON của Godot đọc mọi số
  thành float, làm hỏng `seed` và kết quả "tải lại không đổi".
- Có trường `save_version` và hàm chuyển đổi khi đổi phiên bản.
- Ghi an toàn: ghi ra `*.tmp` → đổi tên; giữ một bản `.bak`.
- Chỉ lưu ở **ranh giới lệnh**: đầu lượt người chơi, và khi app xuống nền (`NOTIFICATION_APPLICATION_PAUSED`). Nếu app xuống nền giữa lượt máy,
  lưu trạng thái đầu lượt máy đó; mở lại thì chạy lại lượt máy (kết quả không đổi nhờ RNG theo hash, 02 §4.5).

## 4. Độ phân giải và phóng to

- Kích thước gốc **288 × 512**; `stretch_mode = canvas_items`, `aspect = expand`, `scale_mode = integer` (có từ Godot 4.2);
  bật `rendering/2d/snap/snap_2d_transforms_to_pixel`.
  Vùng logic thật đổi theo máy: 1080 × 2400 (×3) → 360 × 800 (11 cột); iPhone 1170 × 2532 (×4) → 292 × 633 (9 cột); máy tính bảng có thể tới
  khoảng 432 rộng. Giao diện co giãn theo chiều rộng 288–432 (06 §1).
- Thu phóng trong trận: camera zoom ×1 / ×2, không dùng hệ số lẻ.
- Texture filter mặc định **Nearest**; tắt mipmap cho pixel art.
- Chữ hội thoại dùng phông vector (Be Vietnam Pro) nên vẫn sắc ở mọi tỉ lệ.
- Vùng an toàn: đọc `DisplayServer.get_display_safe_area()` và đệm thanh trên / bảng dưới.
- Khóa hướng màn hình **dọc** cho điện thoại. Màn hình lớn có thể bị hệ điều hành bỏ qua khóa (06 §1): khi đó giữ bố cục dọc ở giữa.

## 5. Dữ liệu

- `units.csv`: `id, phe, ten_khoa, gia, cong_min, cong_max, thu, di, tam_min, tam_max, kieu_di, the (danh sách thẻ, 03 §2), dac_tinh`.
  Không có cột mở khóa: danh sách lính mua được nằm trong `missions.json` (`mua_duoc` từng màn).
- `terrain.csv`: `id, ten_khoa, chi_phi_bo, chi_phi_nang, chi_phi_voi, chi_phi_thuy, thu, vang, hoi_mau, mua_linh, chay_duoc`.
- `counters.csv`: `ben_danh, ben_bi_danh, cong_them, thu_them`.
- `Data` kiểm tra khi khởi động (bản dev): id trùng, khóa dịch thiếu, tham chiếu lính / địa hình không tồn tại → báo lỗi ngay.
- Số liệu khởi điểm lấy từ [03-don-vi-dia-hinh.md](03-don-vi-dia-hinh.md).

## 6. Bản đồ

- Mỗi màn là một cảnh có các `TileMapLayer`: `dia_hinh`, `vat_the` (chông, địa lôi, kho lương, trống báo động...), `diem_dat` (ô đặt quân ban đầu,
  ô viện binh, vùng thắng, vùng thoát, **khu đồn** `khu_don_<id>`).
- Thông tin địa hình gắn vào **custom data** của TileSet (`terrain_id`), luật chơi đọc `terrain_id` rồi tra `terrain.csv`.
- Quân ban đầu: các Node đánh dấu trong cảnh (`UnitSpawn` với `unit_id`, `phe`, `ai_mode`, `ngu`, `duoc`, thẻ tướng như `toi_thieu_1`), đổi thành dữ liệu khi vào màn.

## 7. Kiểm thử

- Test đơn vị cho `scripts/core/`: công thức sát thương, phản đòn, vùng khống chế, chi phí đi, chiêu hàng, vây đồn, cấp bậc,
  trạng thái Cháy, tầm nhìn đêm.
- **Phát hiện kẹt**: AI Tây Sơn đơn giản (02 §14) chơi mỗi màn với nhiều seed; báo màn nào không thắng được trong số lượt. Cân bằng thật dựa vào
  lượt chơi thử của chủ dự án.
- Test "tải lại không đổi kết quả": lưu, đánh, tải, đánh lại → cùng kết quả.
- **Chế độ chạy theo kịch bản**: file JSON liệt kê lệnh (`MoveCommand`, `AttackCommand`...) chạy headless; lần đầu ghi kết quả, các lần sau so sánh.
  Dùng cho test hồi quy và cho agent kiểm thử local.
- **Chụp màn hình** để agent tự xem giao diện: `xvfb-run godot --rendering-driver opengl3 ...` (Mesa), chạy được cả ở cloud.
- **Build và chơi thử trên máy chủ dự án**: session Claude Code local (Godot, Android SDK, Xcode) build Android / iOS; agent kiểm thử local chạy test,
  chạy kịch bản, chụp màn hình. Repo phải có `godot/BUILD.md` (phiên bản Godot, lệnh tải, export preset, lệnh test headless) và `godot/TESTING.md`
  (checklist chơi thử từng màn) để agent local làm theo không cần hỏi lại. Chủ dự án tự chơi trên điện thoại thật để góp ý cảm giác chơi.

## 8. Xuất bản

| Nền tảng | Yêu cầu |
|---|---|
| Android | Godot export template, JDK, Android SDK; bật **Gradle build** (cài Android build template) để xuất **AAB**; keystore ký (cất ngoài repo); target API theo yêu cầu hiện hành của Google Play (từ 31/8/2025 là API 35; kiểm tra lại lúc phát hành) |
| iOS | Máy **Mac** có Xcode; tài khoản Apple Developer (trả phí hằng năm); Godot xuất project Xcode rồi build / ký trên Mac |

- Không thu thập dữ liệu người dùng ở 1.0 → chính sách quyền riêng tư đơn giản, khai "không thu thập dữ liệu" trên cả hai store.
- Kích thước bản cài mục tiêu < 150 MB.
- Hiệu năng mục tiêu: 60 fps trên máy Android tầm trung đời 2020; lượt máy mỗi quân < 0,5 giây kể cả hoạt cảnh khi tua nhanh.

## 9. Bản địa hóa

- Mọi chuỗi hiển thị qua khóa dịch (`tr()`), không viết chữ cứng trong code / cảnh.
- `localization/vi.csv` là bản chuẩn. Tiếng Anh để sau 1.0; tên riêng (Quang Trung, Tôn Sĩ Nghị) giữ nguyên, có chú thích chữ Hán trong Sử liệu.
