# 08 — Thiết kế kỹ thuật (Godot 4)

## 1. Phiên bản và công cụ

- **Godot 4.x**: bản ổn định mới nhất tại thời điểm dựng project (tối thiểu 4.3 vì cần `TileMapLayer`), sau đó **ghim cứng**
  phiên bản trong `godot/BUILD.md` kèm link tải và checksum; chỉ nâng cấp giữa các mốc. Đã kiểm: môi trường cloud tải được
  bản Godot Linux từ GitHub Releases, nên test headless chạy được ở cả cloud lẫn máy chủ dự án.
- Ngôn ngữ: **GDScript** có khai báo kiểu (bật cảnh báo `untyped_declaration` trong Project Settings).
- Kiểm thử tự động: bộ chạy test tự viết, không phụ thuộc thư viện ngoài (`godot/tests/run_tests.gd`, xem `godot/BUILD.md`).
- **Đã ghim: Godot 4.7.2-stable** (13/10/2026).
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
| **Âm thanh** | Autoload `AmThanh` (`scripts/core/am_thanh.gd`), hai bus `Nhac` / `HieuUng`; gọi qua lớp tĩnh `Sfx` để test headless không cần autoload |

### 3.3. Autoload

`Game` (tiến trình chiến dịch, cài đặt), `Save`, `Audio`, `Data` (nạp CSV lúc khởi động, kiểm tra lỗi dữ liệu).

**Đã làm (M2)**: chỉ một autoload `AmThanh`. Dữ liệu (`GameData`), tiến trình và file lưu (`Progress`), dữ liệu truyện (`Story`)
là lớp tĩnh nạp lười — dùng được trong test headless (`-s`) mà không cần cây cảnh. Luồng màn hình (menu → chiến dịch → giới thiệu
màn → trận → kết quả) do `scripts/main.gd` điều khiển; các màn hình ở `scripts/ui/`.

### 3.4. Lưu game

- Hai khe: **chiến dịch** (tiến trình + `BattleState` màn đang chơi + ảnh chụp cấp tướng đầu mỗi màn) và **chơi lại** (màn cũ, không ghi đè chiến dịch).
- Định dạng: `var_to_str` / `FileAccess.store_var` (giữ đúng kiểu `int` 64 bit). **Không** dùng JSON cho trạng thái trận: JSON của Godot đọc mọi số
  thành float, làm hỏng `seed` và kết quả "tải lại không đổi".
- Có trường `save_version` và hàm chuyển đổi khi đổi phiên bản.
- Ghi an toàn: ghi ra `*.tmp` → đổi tên; giữ một bản `.bak`.
- Chỉ lưu ở **ranh giới lệnh**: đầu lượt người chơi, và khi app xuống nền (`NOTIFICATION_APPLICATION_PAUSED`). Nếu app xuống nền giữa lượt máy,
  lưu trạng thái đầu lượt máy đó; mở lại thì chạy lại lượt máy (kết quả không đổi nhờ RNG theo hash, 02 §4.5).
- **Đã làm (M2)**: một khe chiến dịch (`user://luu_tran.txt`, `var_to_str`) + tiến trình (`user://tien_trinh.json`: màn đã thắng,
  mục tiêu phụ tốt nhất, Sử liệu đã mở — chỉ chứa chuỗi/bool/số nhỏ nên JSON được). Ghi qua `.tmp` + `.bak`. Khi app xuống nền giữa
  lượt máy hiện đang lưu trạng thái lúc đó (không phải đầu lượt máy); mở lại thì máy đi tiếp các quân còn lại — hợp lệ nhưng chưa
  đúng ý "chạy lại cả lượt". Khe "chơi lại" chưa làm: chơi lại màn đã thắng hiện dùng chung khe chiến dịch.

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

- `units.csv`: `id, phe, ten, gia, cong_min, cong_max, thu, di, tam_min, tam_max, kieu_di, the` — `the` là danh sách thẻ (03 §2) và kỹ năng
  (`hao_quang`, `uy_danh`, `gay_chay`, `than_trong`...), cách nhau bằng dấu cách. Tên hiển thị tạm để tiếng Việt; chuyển sang khóa dịch khi làm bản địa hóa.
  Không có cột mở khóa: danh sách lính mua được nằm trong `missions.json` (`mua_duoc` từng màn).
- `terrain.csv`: `id, ten_khoa, chi_phi_bo, chi_phi_nang, chi_phi_voi, chi_phi_thuy, thu, vang, hoi_mau, mua_linh, chay_duoc`.
- `counters.csv`: `ben_danh, ben_bi_danh, cong_them, thu_them`.
- `Data` kiểm tra khi khởi động (bản dev): id trùng, khóa dịch thiếu, tham chiếu lính / địa hình không tồn tại → báo lỗi ngay.
- Số liệu khởi điểm lấy từ [03-don-vi-dia-hinh.md](03-don-vi-dia-hinh.md).

## 6. Bản đồ

- **Quyết định ở M1**: mỗi màn là một file JSON `data/missions/<id>.json` với bản đồ **chữ ASCII** (mỗi ký tự là một địa hình, cột `ky_tu`
  trong `terrain.csv`), chủ ô, quân ban đầu (mã lính, phe, ô, chế độ AI, cờ `ngu` / `duoc` / `toi_thieu_1`...), vàng, giới hạn, `mua_duoc`,
  điều kiện thắng thua. Lý do: dễ đọc, dễ sửa và dễ so sánh trong git, Claude sinh và kiểm tra được mà không cần mở trình biên tập.
  Lúc chạy, game dựng `TileMapLayer` từ JSON (atlas `assets/tiles/tiles.png` + `tiles.json`).
- Các trường đã dùng (M2–M3), đều là dữ liệu, chưa cần script riêng cho màn nào:
  - `khu` {tên: [ô]}: khu đồn (trống báo động), vùng thắng `vao_vung`, vùng thoát của trinh sát. `hien_khu` [{khu, mau: vang|do, ghi}]:
    khu vẽ lên bản đồ cho người chơi thấy, `ghi` hiện khi chạm vào ô.
  - `vat_the`, `tam_nhin`, `rang_sang` (đêm); `vien_binh` (theo vòng); `su_kien` (khi `vao_o` / `so_lang` / `chiem_o` / `mau_duoi` → cờ, hội thoại, quân, dải chữ, `roi_ban_do`);
    `thuong_chiem_lang`, `vang_lang`; `goi_y`.
  - `thang` (`chiem_o`, `ha_het`, `vao_vung`, `so_lang`, `co`, `tat_ca`), `thua_het_luot`, `muc_tieu_phu` (02 §13).
  - Quân: `ai` (`tan_cong`, `giu_don` + `tam` / `ban_kinh`, `tuan_tra` + `diem`, `ngu`, `dung_yen`, `do_tham` + `khu` / `thay` / `diem`).
  - Hệ quả sang màn sau: `co_khi_thoat` (cờ bật khi có trinh sát thoát), `luu_co` (cờ ghi vào tiến trình khi thắng, `Progress.campaign_flag`),
    `he_qua` [{co, thuc_khu}] (màn sau: cờ bật thì quân trong khu thức sẵn; `Rules.apply_carry`, chỉ trong chiến dịch),
    `truoc_theo_co` / `sau_thang_theo_co` {cờ: phần hội thoại} (hội thoại mở / kết khác đi theo cờ).
  - Vây đồn (màn 6): `khu_don` [tên khu], vật thể `kho_luong` {co}.
  - Màn 8: vật thể `chong`, `dia_loi` {phe, lo}; `khu_rut_lui`; `khong_thu_nhap` [phe]; `luu_quan` (ghi quân sang màn 9);
    viện binh có `hoi_thoai`; mục tiêu phụ `ha_tren_khu` {khu, n}, `khong_mat_truoc_co` {quan, co}; chiến dịch: `mo_sau` [màn].
  - Màn 9: `cau_phao` {o, rung, khi_qua}; `quan_mang_theo` {toi_da, o} (Rules.apply_army, quân từ màn 8); điều kiện thắng `ha_loai` {quan};
    sự kiện có `truoc_vong`. Màn chuyện không có `sa_ban` (lời kết) thì bỏ qua sa bàn.
  - Đốt (màn 7): ô địa hình `chay_duoc` (doanh trại); vật thể `lua` {het: vòng tắt} do lệnh Đốt tạo; mục tiêu phụ `dot_doanh` {n, truoc_vong}.
  - `goi_y` có thể kèm `neu_co` / `khong_co` (cờ trận) để gợi ý chỉ hiện ở một biến thể màn (màn 6 đồn thức).
- Sự kiện quá riêng để làm bằng dữ liệu (cầu phao đứt ở màn 9...): khi cần mới thêm script `missions/<id>.gd`.

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
