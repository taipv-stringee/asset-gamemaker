# Kịch bản chạm

Chạy: `GODOT --path . -- --kich-ban=res://tests/kich_ban/<file>.txt`

Mỗi dòng một lệnh (dòng bắt đầu bằng `#` là chú thích):

| Lệnh | Ý nghĩa |
|---|---|
| `cham X Y` | Chạm vào ô (X, Y) của bản đồ (đếm từ 0, góc trên trái) |
| `nut <chữ>` | Bấm nút có đúng chữ đó ở bảng dưới (kể cả `Hết lượt`) |
| `cho <giây>` | Chờ |
| `anh <file.png>` | Chụp màn hình; đường dẫn tương đối lưu vào `<thư mục dữ liệu người dùng>/anh/` |
| `keo DX DY` | Kéo bản đồ (điểm ảnh logic; DY âm = cuộn xuống) |
| `kiem vang` / `kiem vong` / `kiem ket_qua` / `kiem camera` / `kiem quan X Y` / `kiem vat X Y` | In giá trị ra log (dòng `KIỂM ...`) |
| `thoat` | Thoát |

Sau mỗi lệnh, kịch bản chờ đến khi hết hoạt cảnh rồi mới chạy lệnh tiếp.

## co_ban.txt (màn m_thu, `--seed=5`, cửa sổ 576x1024) — giá trị mong đợi

| Dòng | Mong đợi |
|---|---|
| `kiem vang` (đầu) | `450` (400 khởi đầu + 50 từ đồn) |
| `kiem quan 5 7` | `tayson voi_chien máu 100` |
| `kiem quan 4 12` | `tayson hoa_mai máu 100 (xong)` |
| `kiem vang` (sau khi mua) | `200` |
| `kiem vong` | `2` |
| `kiem camera` (trước / sau khi kéo) | `0,-32` rồi `0,8` (đã cuộn hết xuống dưới) |

## quan_tan_choi_lai.txt (màn m_kiem_thu) — giá trị mong đợi

Chạy: `GODOT --path . -- --man=m_kiem_thu --kich-ban=res://tests/kich_ban/quan_tan_choi_lai.txt`

| Dòng | Mong đợi |
|---|---|
| `kiem vat 3 1` | `quan_tan` (ảnh `quan_tan.png` có cờ rách ở ô đó) |
| `kiem quan 3 1` (sau chiêu hàng) | `tayson hang_binh máu 50 (xong)` |
| `kiem ket_qua` | `thang` (ảnh `thang.png` có bảng THẮNG) |
| `kiem vong` (sau Chơi lại) | `1` |
| `kiem quan 3 1` (sau Chơi lại) | `le quan_le máu 10` |

## dem_m04.txt (màn 4, đêm) — giá trị mong đợi

Chạy: `GODOT --path . -- --man=m04_gian_khau --kich-ban=res://tests/kich_ban/dem_m04.txt`

| Dòng | Mong đợi |
|---|---|
| `kiem vong` (đầu) | `1`; ảnh `dem_bat_dau.png`: trời tối xanh, xa thì sương đặc, không thấy quân Lê |
| `kiem quan 3 7` (vòng 2) | `le quan_le máu 100 (xong)` — lính tuần bị thủy binh chặn ở bờ bắc; ảnh `dem_vong2.png` thấy nó, thấy cổng đồn sáng đèn có quan giữ đồn ngủ (chữ z), trống, đèn |
| `kiem quan 3 7` (sau 3 đòn) | `trống` (lính tuần đã bị hạ, để lại quân tan); ảnh `dem_ha_tuan.png` |
| `kiem ket_qua` | `(chưa)`, không có chữ "Báo động!" nào hiện ra |
