# TESTING — kiểm thử Tây Sơn

Dành cho **agent kiểm thử chạy trên máy chủ dự án** và cho chủ dự án khi chơi thử. Gửi lại báo cáo theo mẫu ở cuối.

## 1. Kiểm thử tự động (máy tính)

1. `GODOT --headless --path . -s res://tests/run_tests.gd` → phải `0 lỗi`.
   Bộ test có **lời giải mẫu** cho mọi màn đánh (`tests/loi_giai/<màn>.txt`, màn 0, 1, 2, 4, 5, 6): chạy trên luật thật với 3 seed, phải thắng đủ sao.
   `<màn>__<cờ>.txt` là lời giải cho biến thể có hệ quả từ màn trước (màn 6 khi đồn đã thức).
   Chụp / chạm giữa màn: `--man=<id> --loi-giai=<file lời giải cắt ngắn> --kich-ban=…` chạy trước lời giải rồi mới hiện trận.
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

### 2.1. M3 — màn 0, 1, 2, 3, 5, 6 (mới)

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
| 9 | Màn 2 (Nghệ An) | Chiếm làng → "Tuyển quân!" và một lính giáo mới cạnh làng. Đưa một quân tới làng ở đồi phía tây → hội thoại với Nguyễn Thiếp (chân dung râu tóc bạc) giữa trận. Đủ 6 làng → hội thoại duyệt binh, doanh voi Diễn tập xuất hiện ở bãi phía bắc. Quân sư đứng kề hình nộm (cờ rách) → Chiêu hàng |
| 10 | Màn 2: thắng | Đủ 6 làng và hạ hết doanh voi trước vòng 20; mục tiêu phụ: mời Nguyễn Thiếp, chiêu hàng 2 hình nộm |
| 11 | Màn 3 (màn chuyện) | Giới thiệu màn có nút "Xem"; 3 cảnh hội thoại (Sở, Lân xin tội; ăn Tết sớm; chia quân); sa bàn năm đạo: chạm từng đạo → đạo đó đậm lên, hiện chữ bên dưới; Xong → "Xong màn chuyện", 7 Sử liệu mới; Chiến dịch ghi "Đã xem", Màn 4 mở |
| 12 | Màn 5: trinh sát | Dải đỏ ở mép bắc ("đường về Hà Hồi"; chạm vào ô thì có chữ). Chạm trinh sát → "dò thám: thấy quân ta trong 3 ô sẽ chạy". Đưa quân vào trong 3 ô rồi Hết lượt → dải chữ "Trinh sát thấy quân ta, bỏ chạy về báo tin!", nó chạy về phía bắc. Để một con tới dải đỏ → nó biến mất, dải chữ "Một trinh sát đã thoát…", ≡ → mục tiêu phụ ✗ |
| 13 | Màn 5: thần công, Thanh Quyết | Vòng 3 thần công xuất hiện ở đồn của ta (gợi ý). Thần công đã đi thì không có nút Đánh trong lượt đó. Chiếm đồn Thanh Quyết → hội thoại ngắn, mua lính được ở đó. Quân địch bị hạ trên đồn không để lại cờ rách |
| 14 | Màn 5: thắng | Quang Trung chiếm Nhật Tảo. Không ai thoát → hội thoại "bắt hết toán do thám"; có người thoát → hội thoại khác ("có người lọt lưới"). Quân địch không bị xám trong lượt của ta (chỉ quân ta đã đi mới xám) |
| 15 | Màn 6 (Hà Hồi, đêm): vây | Khu đồn có viền vàng nét đứt; quanh khu có dấu × đỏ ở ô còn hở (mặt tây là ao, không cần vây). Chạm ô trong khu → "Chưa bị vây: còn N ô…". Đặt quân / lính giáo khống chế từng ô → dấu × mất dần; đủ thì "Đã bị vây" |
| 16 | Màn 6: gọi hàng | Quân sư (hoặc Quang Trung) đứng kề khu đã bị vây → nút **Gọi hàng** → bảng dưới hiện "Ta: … máu", "Cần …", "✓ Đủ / ✗ Chưa đủ" với nút Gọi / Thôi. Gọi đủ → dải "Quân trong đồn ra hàng!", quân Thanh trong khu thành hàng binh (50 máu), đồn trống; Quang Trung vào Chiếm là thắng. Gọi thiếu → "Gọi hàng không thành…", quân gọi hết lượt, vòng đó không gọi lại được |
| 17 | Màn 6: kho lương, mục tiêu phụ, đồn thức | Lính giáo đứng lên kho lương (bao thóc dưới mái rạ) → nút "Lấy kho lương". Đánh quân trong khu → mục tiêu "Gọi hàng mà không đánh…" ✗. Đồn thức (khi màn 5 có trinh sát thoát): hội thoại mở màn khác ("Trinh sát lọt lưới hôm trước…"), quân trong khu không có chữ z, bắn quân vào tầm, gọi hàng cần đủ máu |
| 18 | Màn 7 (Khương Thượng, đêm → sáng): đốt | Mở sau màn 6; chân dung Đô đốc Long trong hội thoại. Hỏa hổ đứng kề ô doanh trại (ô lều) → nút **Đốt**: một ô thì đốt ngay, nhiều ô thì các ô viền cam, chạm một ô. Ô thành lửa (động), sáng quanh nó; chạm ô → "Lửa: tắt đầu vòng N…". Ba vòng sau ô thành doanh trại cháy. Đốt ô có thổ binh đang ngủ → nó thức, chữ "Cháy", đầu lượt Thanh có báo động. Quân bước vào ô lửa → "Cháy" |
| 19 | Màn 7: Sầm Nghi Đống, rạng sáng | Vòng 7 trời rạng (sắc ấm dần), vòng 9 hết sương. Sầm Nghi Đống trên ô đồn không xuống dưới 1 máu, hồi máu mỗi vòng. Còn 1 máu → hội thoại Loa Sơn (giọng trang nghiêm, chân dung quan Thanh), ông mờ dần rồi rời bản đồ, dải "Đồn Khương Thượng bỏ trống…"; Đô đốc Long vào **Chiếm** là thắng. Mục tiêu phụ "Đốt ít nhất 4 ô… trước vòng 7" hiện ✓ (đã xong) trong bảng tạm dừng khi đủ 4 ô; 3 mục Sử liệu mới |
| 20 | Màn 8 (Ngọc Hồi, rạng sáng): mở khóa, chông, địa lôi | Màn 7 và màn 8 đều mở sau màn 6 (chơi thứ tự nào cũng được); màn 9 cần thắng cả hai. Hai hàng chông sắt (mũi sắt) ở hàng 11 và 14: bước vào phải dừng, chữ "Chông! -15" (mộc thuẫn, voi -5). Địa lôi ẩn giữa hai hàng: giẫm phải "Địa lôi! -30", màn hình rung; quân sư đứng kề thì hiện hũ sành cắm cờ đỏ, đường đi không xuyên qua nữa. Giẫm bẫy thì không Hoàn tác |
| 21 | Màn 8: viện binh, rút lui, kết | Vòng 3: Đô đốc Bảo + 3 voi hiện ở sườn tây bắc, có hội thoại "Đại Áng". Quân Thanh còn sống mà dưới 50 máu chuyển sang rút lui, chạy về mép bắc qua đê Yên Duyên / Đầm Mực (vùng đỏ); tới mép bắc thì mờ đi, dải "Quân Thanh rút về phía bắc". Ba tướng không bị hạ. Quang Trung chiếm đồn là thắng. Hai địa lôi Thanh trên đê: quân rút lui giẫm phải. Mục tiêu phụ: thắng trước vòng 15; hạ 2 quân trên đường rút phía bắc (vùng đỏ, hàng 1–4); không mất mộc thuẫn trước khi một mộc thuẫn qua hai hàng chông. Ghi lại độ khó cảm nhận |
| 22 | Màn 9 (cầu phao): quân mang theo, cầu | Mở khi đã thắng cả màn 7 và 8. Bấm Vào trận → màn "Chọn quân sang Thăng Long": quân còn sống cuối màn 8, chọn sẵn 10 theo cấp, chạm để bỏ / chọn (tối đa 10). Quân ta trong trận đúng quân đã chọn (cấp như cũ, đầy máu); không có nút mua lính. Tôn Sĩ Nghị chạy từ thành sang bờ đông qua cầu rồi mờ đi. Đầu vòng 4 (hoặc sớm hơn khi ông qua hết cầu): dải "Cầu phao rung lắc!", màn hình rung; vòng sau "Cầu phao đứt!": ô cầu thành sông, quân trên cầu bị hạ. Chạm ô cầu: "Cầu phao: đang rung…" |
| 23 | Màn 9: thắng, lời kết | Hạ ba tướng ở đầu cầu và đưa Quang Trung + 2 quân vào thành (viền vàng) thì thắng; hội thoại kết kể ba phiên bản cầu đứt; 3 mục Sử liệu. Mục tiêu phụ: vào thành trước vòng 8; 3 hàng binh (quân sư Chiêu hàng quân tan). Sau đó "Màn K · Lời kết" mở: chuỗi hội thoại, câu của Lê Quýnh (không chân dung), không có sa bàn, "Xong màn chuyện" với 2 mục Sử liệu |
| 24 | Màn phụ P (thủy quân) | Mở sau màn 4 (không chặn các màn khác). Giới thiệu ghi rõ trận là Sáng tạo của game. Thủy binh, Lộc, Tuyết đi sông 1 điểm, lên bờ 2 điểm; thủy binh kề Lộc / Tuyết +1 Di. Bộ binh lội qua sông ngang ở 5 bãi bồi. Lộc hoặc Tuyết chiếm cả hai bến là thắng; chân dung Lộc, Tuyết trong hội thoại; 3 mục Sử liệu |

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
