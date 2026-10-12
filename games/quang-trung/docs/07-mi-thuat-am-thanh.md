# 07 — Mỹ thuật và âm thanh

> Phong cách đã duyệt: bản chi tiết `drafts/quang-trung/assets_v2/` (ô 32px, chân dung 80 × 80).
> Bản nháp có một số chi tiết sai sử; mục 2 liệt kê cách sửa theo [báo cáo nghiên cứu](nghien-cuu/bao-cao-lich-su.md#sửa-art-direction).

## 1. Thông số chung

| Hạng mục | Quy định |
|---|---|
| Ô lưới | 32 × 32 px |
| Lính | Khung 32 × 32 px, vẽ **nhìn sang phải**, phe địch lật ngang. Gốc ở giữa đáy (chân) |
| Chân dung hội thoại | 80 × 80 px trong khung 88 × 88 (viền sơn mài vàng) |
| Màn hình gốc | 288 × 512 px logic |
| Viền | Viền tối 1px quanh lính và vật thể; ô địa hình không viền |
| Ánh sáng | Từ trên – trái cho lính và ô; từ trên – phải cho chân dung (mặt hướng về khung chữ) |
| Bảng màu | Một bảng màu chung (khoảng 64 màu), mỗi phe 3 sắc độ màu phe (Tây Sơn, Diễn tập, Thanh, Lê, trung lập) |
| Phông chữ | Be Vietnam Pro (OFL) cho giao diện và hội thoại; một phông pixel có dấu tiếng Việt cho số trên bản đồ |
| Không anti-alias | Mọi hình pixel art phóng bằng nearest-neighbor |

## 2. Hướng nghệ thuật theo nguồn

| Đối tượng | Làm | Không làm | Nguồn |
|---|---|---|---|
| **Lính Tây Sơn** | Mặc định: chít khăn (turban), đi chân đất, áo rộng dài tay, quần ống rộng; vải nâu, chàm. Một số quân tinh nhuệ / tướng có thể đội mũ đính lông đỏ (*Lê quý dật sử*: "chỏm mũ đính lông chiên đỏ") | Nón chóp, nón dấu (không thấy bằng chứng thế kỷ 18; cho rằng nón dấu là của thời Nguyễn là suy luận, chưa có nguồn); quân phục đồng phục; giáp | Tranh William Alexander, 1793; *Lê quý dật sử* |
| **Màu đỏ** | Khăn đỏ cho quân voi và làm màu phe; áo đỏ tía cho một số quân | Gọi "áo vải cờ đào" như sử liệu (đó là biệt danh hiện đại) | Sử Thanh (qua trích dẫn, chưa kiểm nguyên văn); *Lê quý dật sử* |
| **Cờ Tây Sơn** | Cờ đỏ trơn hoặc có chữ, ghi là *Sáng tạo* | Khẳng định màu cờ lịch sử | Không có nguồn về màu cờ |
| **Quang Trung** | Cách điệu: áo bào đỏ, cưỡi voi, "mắt sáng" là dấu hiệu nhận diện | Chép mặt từ tranh *Đông Thanh* 1932 / tượng đài (có thể bắt nguồn từ tranh Càn Long) | Nguyễn Duy Chính, Lê Nguyễn Lưu |
| **Lính Thanh** | Đuôi sam, mũ có tua đỏ, trường thương tua đỏ (lông bò yak); màu phe xanh lam để dễ đọc | Chữ 勇 trên ngực áo (dấu hiệu thế kỷ 19); áo xanh lục (màu lục chỉ cho cờ) | Hoàng triều lễ khí đồ thức (1766) |
| **Tôn Sĩ Nghị** | Từ khi chiếm Thăng Long (tháng 11 Mậu Thân, được phong Nhất đẳng Mưu dũng công): đỉnh mũ **hồng ngọc** đỏ trong, **lông công hai mắt**, bổ tử, triều châu. Cảnh trước đó (vượt Trấn Nam Quan): đỉnh san hô. Bản **bị thu mũ** chỉ dùng ở lời kết (lệnh thu mũ đến vài tuần sau trận) | Dùng bản bị thu mũ ngay trong màn 9 | Thanh sử cảo, quyển 330 |
| **Quan Lê** | Áo giao lĩnh, mũ chữ đinh | | Báo Pháp Luật (cổ phục Lê trung hưng) |
| **Mộc thuẫn** | Tấm ván ghép, phủ rơm ướt, nhiều người khiêng | | Theo HLNTC (ván ghép phủ rơm); sử Thanh chỉ ghi "đội ván"; *Cương mục* ghi bó rơm lăn |
| **Voi chiến** | Mỗi voi 3–4 lính chít khăn đỏ, có thể ném hỏa cầu | | Sử Thanh (qua trích dẫn, chưa kiểm nguyên văn) |
| **Thăng Long** | Thành, cổng ô cách điệu | Vẽ đúng Ô Quan Chưởng hiện nay (bản xây lại 1804/1817) | |
| **Tết** | Cây đào, đèn trong làng, cây nêu — coi là **không khí** (sáng tạo) | Gán là chi tiết sử | Chưa có nguồn thế kỷ 18 |
| **Khung UI** | Sơn mài đỏ – đen – vàng; motif đồng tiền **Quang Trung thông bảo** (光中通寶) | | Numista, Penn Museum |

Tham khảo hình ảnh (xem [ghi chú trang phục](nghien-cuu/ghi-chu/hinh_anh_trang_phuc.md)): "Cochin-chinese Soldier"
(William Alexander 1793, British Library); bộ *Bình định An Nam chiến đồ* (Cố Cung, lưu ý là tranh tuyên truyền, bỏ trận thua);
tranh "An Nam quốc vương" 1790.

## 3. Danh sách asset bản 1.0

### Lính (32 × 32)

Mỗi loại: **đứng** 2 frame, **đánh** 3 frame, **bị đánh** 1 frame. Di chuyển là trượt mượt giữa các ô (như AE2), không cần frame đi.
Tướng có tên dùng chung thân với một loại lính + đầu/mũ riêng.

| Phe | Loại | Số |
|---|---|---|
| Tây Sơn | Lính giáo, hỏa mai thủ, thủy binh, quân sư, trống trận, hỏa hổ, mộc thuẫn, thần công, voi chiến, hàng binh | 10 |
| Tây Sơn – tướng | Quang Trung (cưỡi voi), Ngô Văn Sở, Ngô Thì Nhậm, Phan Văn Lân, Đô đốc Long, Đô đốc Bảo (voi), Tuyết, Lộc | 8 |
| Thanh | Trường mâu, điểu thương, cung tiễn, đằng bài, pháo binh, thổ binh Điền Châu, trinh sát | 7 |
| Thanh – tướng | Tôn Sĩ Nghị, Hứa Thế Hanh, Sầm Nghi Đống, Trương Triều Long, Thượng Duy Thăng, quan giữ đồn | 6 |
| Lê | Quân Lê, quan giữ đồn phe Lê | 2 |
| **Tổng** | | **33 loại × 6 frame ≈ 200 frame** |

### Chân dung (80 × 80)

| Nhân vật | Biểu cảm |
|---|---|
| Quang Trung | bình thường, quyết, giận, cười |
| Ngô Văn Sở, Ngô Thì Nhậm, Phan Văn Lân | bình thường, lo/giận |
| Nguyễn Thiếp, Tuyết, Lộc, Đô đốc Long, Đô đốc Bảo | bình thường |
| Tôn Sĩ Nghị | bình thường, khinh, hoảng; bản **bị thu mũ** |
| Hứa Thế Hanh | bình thường, quyết |
| Sầm Nghi Đống | bình thường, buồn |
| Lê Chiêu Thống, Lê Quýnh | bình thường |
| Lính Tây Sơn, lính Thanh, quan giữ đồn (chung) | bình thường |
| **Tổng** | khoảng 30 chân dung |

### Địa hình (32 × 32)

Cỏ (4 biến thể), đường (nối 16 kiểu), đê, ruộng, vườn/cây đào, rừng tre, đồi, núi đá vôi, sông (viền bờ tự nối — autotile 47),
sông cạn/bến đò, cầu, cầu phao (+ bản đứt), đầm lầy, làng (3 màu chủ + trung lập), doanh trại (+ bản cháy), lũy đất, đồn
(5 màu chủ), thành, chông sắt, địa lôi (hiện), quân tan, lửa (4 frame), kho lương, trống báo động.
Bản đêm **không vẽ riêng**: dùng bộ lọc đêm và nguồn sáng.

### Hiệu ứng

Chém, đâm, khói súng hỏa mai, nổ thần công, lửa hỏa hổ, nổ hỏa cầu, mũi tên bay, bụi voi xung phong, lên cấp, cờ chiếm làng,
cờ trắng gọi hàng, quân tan tan biến, cầu phao gãy, nước bắn, sương mù trôi.

### Giao diện

Khung sơn mài (9-slice), nút (3 trạng thái), biểu tượng (vàng, lượt, công, thủ, di, tầm, sao cấp, các trạng thái, các hành động),
con trỏ chọn ô, ô xanh / đỏ / vùng nguy hiểm, bản đồ chiến dịch (giấy dó, mực, dấu son), khung Sử liệu.

## 4. Quy trình asset

1. **Hình tạm**: tiếp tục dùng script Python (`generate_v2.py`) để sinh hình tạm cho mọi loại lính / ô mới, đủ để chơi thử.
2. **Hình thật**: Claude vẽ lại bằng code ở mức chi tiết cao hơn, giữ đúng kích thước, bảng màu và tên file của hình tạm → thay file là xong, không sửa code. Chủ dự án duyệt từng nhóm hình.
3. Tên file dùng **mã định danh** ở 03 §1 (ASCII, không dấu): `unit_<phe>_<ma>_<hanhdong>_strip<N>.png` (vd. `unit_tayson_hoa_mai_danh_strip3.png`),
   `tile_<ma_dia_hinh>.png`, `portrait_<ma_nhan_vat>_<bieucam>.png`. Hình nháp cũ (`noithu`, `daibac`, không có phần hành động) phải đổi tên khi chuyển vào project.
4. Mỗi hình tướng / chân dung qua **kiểm tra sử** theo bảng mục 2 trước khi duyệt.

## 5. Âm thanh

### Nhạc

| Bản | Dùng ở | Tinh thần |
|---|---|---|
| Chủ đề | Tiêu đề, bản đồ chiến dịch | Hào hùng, chậm, trống và kèn |
| Hành quân | Màn ngày (0, 1, 2, 5) | Nhịp đi đều |
| Đêm | Màn đêm (4, 6, 7 lúc đêm) | Thưa, căng, tiếng côn trùng, trống xa |
| Đánh đồn | Màn 8, 9 | Dồn dập |
| Tết | Màn 3, khúc giao thừa màn 4 | Ấm, vui nhưng có nỗi lo |
| Thắng / Thua | Kết quả màn | Ngắn |
| Lời kết | Cầu siêu, kết thúc | Trầm, tưởng niệm |

Nhạc cụ: trống chiến, chiêng, kèn, tù và, sáo, đàn nguyệt. Cảnh trong doanh trại Thanh dùng cùng bảng nhạc cụ nhưng
đổi giai điệu và nhịp; tránh các khuôn sáo "nhạc Trung Hoa" (gõ chũm chọe, ngũ cung kiểu phim) để không rập khuôn.

### Hiệu ứng âm thanh

Chọn quân, đi bộ, voi bước / rống, chém, đâm, súng hỏa mai, thần công, hỏa hổ phun lửa, hỏa cầu nổ, mũi tên, bị đánh, quân bị hạ,
lên cấp, chiếm làng, mua lính, vàng, gọi hàng (tiếng loa), trống báo động, cầu phao gãy, nước, gió đêm, lửa cháy,
giao diện (chạm, mở menu, lật trang Sử liệu).

Claude tổng hợp nhạc và âm thanh bằng code (như `games/diet-rong/generate_sounds.py`). Nếu chất lượng chưa đạt, có thể bổ sung âm thanh từ thư viện giấy phép CC0 (ghi nguồn trong `CREDITS`).
