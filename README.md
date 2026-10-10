# Cá chép vượt Vũ Môn — asset pixel art

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
