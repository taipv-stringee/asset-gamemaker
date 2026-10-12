# Cá chép vượt Vũ Môn — bản nháp

> **Trạng thái: nháp.** Game làm thử để dò cách dựng project GameMaker bằng code;
> chưa cân bằng độ khó, chưa có âm thanh. Không dùng làm nền cho game thật.

## Asset pixel art

Toàn bộ hình ảnh được vẽ bằng code trong `generate_assets.py` (Python + Pillow),
không dùng file ảnh có sẵn.

```bash
pip install pillow
python generate_assets.py     # tạo lại thư mục assets/ và assets/preview_sheet.png
```

Script in ra danh sách file kèm kích thước, đồng thời tự kiểm tra từng sprite
(số màu, hình chạm mép khung, phần có thể bị cắt khi xoay) và in cảnh báo `!` nếu có.

## Import vào GameMaker

- File `*_stripN.png`: GameMaker tự cắt thành N frame khi import (frame chia đều theo chiều ngang).
- Đặt **Origin = Middle Centre** cho mọi sprite.
- Cá chép, rồng và kẻ địch đều vẽ **đầu hướng lên** → `image_angle = direction - 90;`
- `tile_water`, `tile_bank_left/right` dùng làm Tile Set 32x32 (nước lặp được theo cả hai chiều; bờ sông ghép dọc được).
- Thanh năng lượng: vẽ `spr_bar_energy_bg`, rồi vẽ `spr_bar_energy_fill` bằng
  `draw_sprite_part(spr_bar_energy_fill, 0, 0, 0, 3 + 90 * energy, 12, x, y)` (`energy` từ 0 đến 1).

## Sửa asset

- Bảng màu `PALETTE` ở đầu script dùng chung cho mọi sprite: đổi một màu là đổi cả game.
- Mỗi nhóm asset là một hàm riêng: `make_carp()`, `make_dragon()`, `make_enemies()`,
  `make_obstacles()`, `make_items()`, `make_environment()`, `make_effects()`, `make_ui()`.

## Project GameMaker: `CaChepVuMon/`

Mở `CaChepVuMon/CaChepVuMon.yyp` bằng GameMaker LTS 2026 rồi nhấn **F5** để chạy.

- Điều khiển: Mũi tên / WASD để bơi, **SPACE** để lướt nhanh (tốn năng lượng, bất tử trong lúc lướt).
- Bơi ngược dòng, né đá, khúc gỗ, cá dữ, rắn nước, rái cá và xoáy nước; nhặt ngọc, giọt năng lượng, khiên, tim.
- Tới Vũ Môn thì phải **lướt** mới vượt được thác; lọt qua cổng là cá hóa rồng.
- Code chính: `scripts/scr_game` (hằng số, hàm dùng chung), `scripts/scr_spawn` (sinh chướng ngại), `objects/obj_game` (luật chơi, HUD), `objects/obj_carp` (người chơi).
- Chỉnh độ khó: `GOAL_DIST` trong `scr_game`, trọng số trong `spawn_wave()` ở `scr_spawn`.
- Font chữ tiếng Việt: VT323 (SIL Open Font License) trong Included Files.
