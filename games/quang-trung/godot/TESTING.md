# TESTING — kiểm thử Tây Sơn

Dành cho **agent kiểm thử chạy trên máy chủ dự án** và cho chủ dự án khi chơi thử. Gửi lại báo cáo theo mẫu ở cuối.

## 1. Kiểm thử tự động (máy tính)

1. `GODOT --headless --path . -s res://tests/run_tests.gd` → phải `0 lỗi`.
   Bộ test có cả **lời giải mẫu màn 4** (`tests/loi_giai/m04_gian_khau.txt`): chạy trên luật thật, phải thắng 3 sao.
2. Chạy từng kịch bản chạm trong `tests/kich_ban/` (lệnh chạy và giá trị mong đợi của từng file: `tests/kich_ban/README.md`):
   - `co_ban.txt`, `quan_tan_choi_lai.txt`, `dem_m04.txt`: vào thẳng trận. `cuon_danh_sach.txt`: cuộn danh sách Chiến dịch.
   - `tron_m04.txt`: `GODOT --path . -- --menu --moi --mo-het --seed=1 --kich-ban=res://tests/kich_ban/tron_m04.txt` — đi từ menu,
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

## 2. Chơi thử trên điện thoại

### 2.1. M3 — màn 0 và màn 1 (mới)

Xóa dữ liệu app (hoặc `--moi`) để thấy thứ tự mở màn và gợi ý hướng dẫn từ đầu.

| # | Việc | Mong đợi |
|---|---|---|
| 1 | Chiến dịch | Chỉ Màn 0 mở; Màn 1, Màn 4 mờ, dòng "Thắng màn trước để mở" (màn đã thắng trước đây vẫn mở) |
| 2 | Màn 0: giới thiệu, hội thoại | Chân dung Phan Văn Lân (khăn đỏ, giáp), Ngô Thì Nhậm (mũ cánh chuồn), Ngô Văn Sở (khăn đen, giáp) |
| 3 | Gợi ý hướng dẫn | Khung xanh đậm dưới thanh trên, nút "Đã hiểu"; hiện lần lượt khi chọn quân, sau khi đi, xem dự báo, vòng 2, vòng 3; không chặn bản đồ; ≡ → mục "Gợi ý" xem lại được. Chơi lại màn: gợi ý đã xem không hiện nữa |
| 4 | Màn 0: viện binh | Vòng 2 quân Thanh + quân Lê xuất hiện ở bờ bắc (dải chữ "Viện binh…" nếu thấy), vòng 3 quân Lê từ sườn tây, vòng 5 sườn đông |
| 5 | Màn 0: thắng | Ngô Văn Sở + 4 quân vào 2 hàng cuối (cửa núi) là thắng ngay; mục tiêu phụ: Lân về tới nơi, không mất quân |
| 6 | Màn 1 mở sau màn 0 | Hội thoại lên ngôi ở núi Bân; quân phe Diễn tập màu đỏ sẫm; quân về 0 máu thì biến mất, không để quân tan |
| 7 | Màn 1: mua lính, lên cấp | Bảng mua lính có lính giáo, hỏa mai; gợi ý Uy danh (vòng 2), lên cấp (khi có quân lên cấp) |
| 8 | Màn 1: thắng | Quang Trung vào đồn bắc và Chiếm; mục tiêu phụ: một quân lên cấp, thắng trước vòng 10 |

### 2.2. M2 — lát cắt dọc màn 4

Mở game **không có tham số** (như người chơi). Bật tiếng. Lần đầu nên xóa dữ liệu app để bắt đầu từ đầu.

| # | Việc | Mong đợi |
|---|---|---|
| 1 | Mở game | Màn khởi động là huy hiệu + chữ TÂY SƠN (không còn logo Godot). Menu: biểu tượng, chữ TÂY SƠN, lời lưu truyền có nhãn [Tương truyền], nút Chiến dịch / Sử liệu. Nhạc chủ đề (trống, kèn, đàn) |
| 2 | Chiến dịch | Danh sách màn 0–9 + màn phụ; chỉ màn 4 và "Trận thử luật" bấm được; tên dài xuống dòng; **vuốt trên các nút vẫn cuộn**, vuốt không mở màn |
| 3 | Màn 4 | Giới thiệu màn: ngày âm và dương lịch, bản đồ nhỏ, đoạn lịch sử có nhãn, mục tiêu, 3 mục tiêu phụ |
| 4 | Vào trận | Trời tối, nhạc đêm (dế, gió, trống xa, sáo). Hội thoại có chân dung Quang Trung; chạm để tiếp; Bỏ qua được |
| 5a | Mua đủ các loại lính, xem trên bản đồ (ngày: Trận thử luật; đêm: màn 4) | Phân biệt được từng loại không cần chạm: lính giáo (giáo dài), hỏa mai (áo nâu, súng chếch, khói), thủy binh (cởi trần, mái chèo, sóng nước), quân sư (áo dài đen, loa), trống trận (trống to trước ngực), hỏa hổ (áo đen, lửa). Quân Thanh (Trận thử luật): trường mâu (tua đỏ), điểu thương (súng ngang, khói), cung tiễn (cung lớn), đằng bài (khiên mây tròn); quân Lê (màn 4): áo vàng đất, khăn đen |
| 5 | Nhìn bản đồ | Xa quân ta thì sương đặc, không thấy quân Lê; cổng đồn có đèn sáng, thấy quan giữ đồn đang ngủ (chữ z), trống, đèn ở làng |
| 6 | Đi quân về phía sông | Thấy lính tuần khi tới gần (có dấu "!"); khi đi vào chỗ có quân ẩn → "Phục kích!", quân dừng, không Hoàn tác được |
| 7 | Mua lính ở đồn của ta (bến đò) | Bảng mua lính hiện đủ các loại kèm hình, giá, chỉ số; loại không đủ vàng thì mờ |
| 8 | Đánh lính tuần mà không hạ được, rồi hết lượt | Đầu lượt quân Lê: "Báo động!" (tiếng tù và), quân quanh đó thức |
| 9 | Để quân Lê đứng cạnh trống lúc báo động | "Trống báo động! Cả đồn đã thức.", màn hình rung, tiếng trống dồn |
| 10 | Nút ≡ | Tạm dừng: mục tiêu, mục tiêu phụ (☆ còn mở, ✗ đã hỏng — vd. sau khi bị báo động), Tiếp tục, "Lưu, về menu" |
| 11 | "Lưu, về menu", rồi tắt hẳn app, mở lại | Menu có "Tiếp tục"; bấm vào thì về đúng lượt đang chơi |
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
