# TESTING — kiểm thử Tây Sơn

Dành cho **agent kiểm thử chạy trên máy chủ dự án** và cho chủ dự án khi chơi thử. Gửi lại báo cáo theo mẫu ở cuối.

## 1. Kiểm thử tự động (máy tính)

1. `GODOT --headless --path . -s res://tests/run_tests.gd` → phải `0 lỗi`.
   Bộ test có cả **lời giải mẫu màn 4** (`tests/loi_giai/m04_gian_khau.txt`): chạy trên luật thật, phải thắng 3 sao.
2. Chạy từng kịch bản chạm trong `tests/kich_ban/` (lệnh chạy và giá trị mong đợi của từng file: `tests/kich_ban/README.md`):
   - `co_ban.txt`, `quan_tan_choi_lai.txt`, `dem_m04.txt`: vào thẳng trận.
   - `tron_m04.txt`: `GODOT --path . -- --menu --moi --seed=1 --kich-ban=res://tests/kich_ban/tron_m04.txt` — đi từ menu,
     chơi trọn màn 4 qua giao diện chạm, kiểm tra lưu, sao, Sử liệu. (`--moi` xóa tiến trình trên máy trước khi chạy.)
   - So các dòng `KIỂM` với bảng mong đợi; mở ảnh chụp (dòng `Đã chụp:`) và mô tả bất thường: chữ bị cắt, nút chồng nhau,
     quân hiển thị sai chỗ, quân địch hiện ra trong sương.
   - Trên macOS, nếu cửa sổ game bị cửa sổ khác che kín thì Godot ngừng vẽ và ảnh chụp đứng hình (trông như chạm
     không ăn): thêm `--always-on-top` trước `--`, ví dụ `GODOT --path . --always-on-top -- --kich-ban=...`.
3. Máy tự chơi có hình: `GODOT --path . -- --tu-dong --vong=10 --anh=<file>` → không treo, không lỗi `SCRIPT ERROR` trong log.
4. Mô phỏng nhanh (không hình): `GODOT --headless --path . -s res://tools/mo_phong.gd -- --man=m_thu --lan=10`
   → in kết quả từng trận. Dùng để phát hiện kẹt / lỗi, **không** dùng để kết luận cân bằng (AI phe ta đơn giản hơn người chơi).
5. Xem lời giải màn 4 chạy từng vòng (in bản đồ chữ): `GODOT --headless --path . -s res://tools/thu_nuoc.gd -- --seed=1`.

Lỗi đã biết, bỏ qua: lúc thoát có dòng `ERROR: 1 resources still in use at exit` (một file nhạc còn trong bộ phát âm thanh khi
tắt; không ảnh hưởng gì).

## 2. Chơi thử trên điện thoại (mốc M2 — lát cắt dọc màn 4)

Mở game **không có tham số** (như người chơi). Bật tiếng. Lần đầu nên xóa dữ liệu app để bắt đầu từ đầu.

| # | Việc | Mong đợi |
|---|---|---|
| 1 | Mở game | Menu: biểu tượng, chữ TÂY SƠN, lời lưu truyền có nhãn [Tương truyền], nút Chiến dịch / Sử liệu. Nhạc chủ đề (trống, kèn, đàn) |
| 2 | Chiến dịch | Danh sách màn 0–9 + màn phụ; chỉ màn 4 và "Trận thử luật" bấm được |
| 3 | Màn 4 | Giới thiệu màn: ngày âm và dương lịch, bản đồ nhỏ, đoạn lịch sử có nhãn, mục tiêu, 3 mục tiêu phụ |
| 4 | Vào trận | Trời tối, nhạc đêm (dế, gió, trống xa, sáo). Hội thoại có chân dung Quang Trung; chạm để tiếp; Bỏ qua được |
| 5 | Nhìn bản đồ | Xa quân ta thì sương đặc, không thấy quân Lê; cổng đồn có đèn sáng, thấy quan giữ đồn đang ngủ (chữ z), trống, đèn ở làng |
| 6 | Đi quân về phía sông | Thấy lính tuần khi tới gần (có dấu "!"); khi đi vào chỗ có quân ẩn → "Phục kích!", quân dừng, không Hoàn tác được |
| 7 | Mua lính ở đồn của ta (bến đò) | Bảng mua lính hiện đủ các loại kèm hình, giá, chỉ số; loại không đủ vàng thì mờ |
| 8 | Đánh lính tuần mà không hạ được, rồi hết lượt | Đầu lượt quân Lê: "Báo động!" (tiếng tù và), quân quanh đó thức |
| 9 | Để quân Lê đứng cạnh trống lúc báo động | "Trống báo động! Cả đồn đã thức.", màn hình rung, tiếng trống dồn |
| 10 | Nút ≡ | Tạm dừng: mục tiêu, Tiếp tục, Lưu và về menu |
| 11 | Lưu và về menu, rồi tắt hẳn app, mở lại | Menu có "Tiếp tục"; bấm vào thì về đúng lượt đang chơi |
| 12 | Chơi đến thắng | Hội thoại sau trận; bảng THẮNG có số vòng, quân mất, sao mục tiêu phụ, Sử liệu mới; nhạc thắng |
| 13 | Tiếp → Chiến dịch | Màn 4 có sao; Sử liệu mở được 3 mục, có nhãn nguồn, bấm nguồn thì mở trình duyệt |
| 14 | Thử thắng không báo động trước vòng 7 | Gợi ý cách làm: tests/loi_giai/m04_gian_khau.txt (đừng xem nếu muốn tự tìm) |
| 15 | Nút Back của Android | Từ Sử liệu / giới thiệu màn → lùi một màn hình; trong trận → mở bảng tạm dừng |

Ghi thêm cảm nhận: **nhạc và tiếng** (hay / chói / quá to / quá nhỏ, nghe có "chất Việt" không), đêm có quá tối không,
màn 4 khó hay dễ, chữ có dễ đọc không, lượt máy nhanh hay chậm.

Mục cũ của M1 (trận thử ban ngày) vẫn chơi được: Chiến dịch → Trận thử luật.

## 3. Mẫu báo cáo

```
Commit: <hash>   Godot: 4.7.2   Máy: <tên máy, Android/iOS, độ phân giải>
Test tự động: <N test, 0 lỗi | dán dòng FAIL>
Kịch bản: <tên file → đạt / không đạt, kèm dòng KIỂM sai>
Chơi thử: <bước nào không như mong đợi, kèm ảnh chụp nếu có>
Cảm nhận: <...>
```

Các báo cáo đã làm lưu trong [bao-cao-kiem-thu/](bao-cao-kiem-thu/) (mỗi lần một file `YYYY-MM-DD-<mốc>.md`).
