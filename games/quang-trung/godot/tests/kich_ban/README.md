# Kịch bản chạm

Chạy: `GODOT --path . -- --kich-ban=res://tests/kich_ban/<file>.txt`

Mỗi dòng một lệnh (dòng bắt đầu bằng `#` là chú thích):

| Lệnh | Ý nghĩa |
|---|---|
| `cham X Y` | Chạm vào ô (X, Y) của bản đồ (đếm từ 0, góc trên trái) |
| `nut <chữ>` | Bấm nút có đúng chữ đó ở bảng dưới (kể cả `Hết lượt`) |
| `cho <giây>` | Chờ |
| `anh <file.png>` | Chụp màn hình; đường dẫn tương đối lưu vào `<thư mục dữ liệu người dùng>/anh/` |
| `kiem vang` / `kiem vong` / `kiem ket_qua` / `kiem quan X Y` | In giá trị ra log (dòng `KIỂM ...`) |
| `thoat` | Thoát |

Sau mỗi lệnh, kịch bản chờ đến khi hết hoạt cảnh rồi mới chạy lệnh tiếp.

## co_ban.txt (màn m_thu) — giá trị mong đợi

| Dòng | Mong đợi |
|---|---|
| `kiem vang` (đầu) | `350` (300 khởi đầu + 50 từ đồn) |
| `kiem quan 5 7` | `tayson voi_chien máu 100` |
| `kiem quan 4 12` | `tayson hoa_mai máu 100 (xong)` |
| `kiem vang` (sau khi mua) | `100` |
| `kiem vong` (cuối) | `2` |
