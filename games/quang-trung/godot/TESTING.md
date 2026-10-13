# TESTING — kiểm thử Tây Sơn

Dành cho **agent kiểm thử chạy trên máy chủ dự án** và cho chủ dự án khi chơi thử. Gửi lại báo cáo theo mẫu ở cuối.

## 1. Kiểm thử tự động (máy tính)

1. `GODOT --headless --path . -s res://tests/run_tests.gd` → phải `0 lỗi`.
2. Chạy từng kịch bản chạm trong `tests/kich_ban/` (xem `tests/kich_ban/README.md`):
   `GODOT --path . -- --kich-ban=res://tests/kich_ban/<file>.txt`
   - So các dòng `KIỂM` với giá trị ghi trong chú thích của kịch bản.
   - Mở các ảnh chụp (đường dẫn in ở dòng `Đã chụp:`) và mô tả bất thường: chữ bị cắt, nút chồng nhau, quân hiển thị sai chỗ.
3. Máy tự chơi: `GODOT --path . -- --tu-dong --vong=10 --anh=<file>` → không treo, không lỗi `SCRIPT ERROR` trong log.

## 2. Chơi thử trên điện thoại (mốc M1)

Màn **Trận thử** (`m_thu`): mục tiêu là Quang Trung chiếm đồn quân Thanh ở phía bắc.

| # | Việc | Mong đợi |
|---|---|---|
| 1 | Mở game | Màn hình dọc, thanh trên có "Trận thử · Vòng 1", bảng dưới có nút "Hết lượt" |
| 2 | Kéo bản đồ lên xuống | Cuộn mượt, không lệch ra ngoài bản đồ |
| 3 | Chạm một quân Tây Sơn | Ô xanh (đi được), ô đỏ (đánh được nếu có), bảng dưới hiện chỉ số |
| 4 | Chạm một ô xanh, chạm lại | Quân đi theo đường; hiện các nút Đánh / Chiếm / Chờ / Hoàn tác |
| 5 | Hoàn tác | Quân về chỗ cũ, chọn lại được |
| 6 | Đánh: chạm quân địch ô đỏ | Hiện dự báo "Gây X–Y (hạ: Z%)", phản đòn; chạm lần nữa thì đánh |
| 7 | Chạm đồn của ta (phía nam) khi đồn trống | Danh sách mua lính, trừ vàng, quân mới xám đến hết lượt |
| 8 | Hết lượt khi còn quân chưa đi | Hỏi lại; bấm lần nữa thì máy đi |
| 9 | Lượt máy | Camera theo quân máy, có số sát thương, không treo |
| 10 | Quân Thanh bị hạ | Để lại cờ rách (quân tan) 1 lượt |
| 11 | Chơi đến thắng hoặc thua | Hiện bảng THẮNG / THUA, nút "Chơi lại" |

Ghi thêm cảm nhận: chữ có dễ đọc không, ô có dễ chạm không, lượt máy nhanh hay chậm.

## 3. Mẫu báo cáo

```
Commit: <hash>   Godot: 4.7.2   Máy: <tên máy, Android/iOS, độ phân giải>
Test tự động: <N test, 0 lỗi | dán dòng FAIL>
Kịch bản: <tên file → đạt / không đạt, kèm dòng KIỂM sai>
Chơi thử: <bước nào không như mong đợi, kèm ảnh chụp nếu có>
Cảm nhận: <...>
```

Các báo cáo đã làm lưu trong [bao-cao-kiem-thu/](bao-cao-kiem-thu/) (mỗi lần một file `YYYY-MM-DD-<mốc>.md`).
