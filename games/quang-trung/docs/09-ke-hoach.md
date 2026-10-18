# 09 — Kế hoạch sản xuất và phát hành

## 1. Các mốc

Mỗi mốc có **điều kiện xong**; chưa đạt thì chưa sang mốc sau. Ước lượng tính bằng **phiên làm việc** của Claude (một phiên ≈ một lượt giao việc
lớn, có commit và push) — chỉ là ước lượng thô, chưa tính thời gian chờ chủ dự án build và chơi thử.

| Mốc | Nội dung | Điều kiện xong | Ước lượng |
|---|---|---|---|
| **M0 – Tài liệu** | Bộ tài liệu 01–10, rà soát lịch sử và thiết kế | Chủ dự án duyệt | **Xong** (13/10/2026) |
| **M1 – Mẫu luật chơi** | Project Godot; `core/` (bản đồ, đi, vùng khống chế, đánh, phản đòn, chiếm, mua lính, cấp, quân tan); AI cơ bản; 1 bản đồ thử; hình tạm; chế độ chạy kịch bản; `BUILD.md`, `TESTING.md`. **Hình mẫu chất lượng thật**: 1 loại lính đủ hoạt cảnh + 1 chân dung, để chủ dự án duyệt mức hình vẽ bằng code | Chơi trọn một trận trên điện thoại; test `core/` xanh; chủ dự án duyệt (hoặc từ chối) hình mẫu | 3–5 phiên |
| **M2 – Lát cắt dọc** | **Màn 4 (Đêm 30 Tết – sông Gián)** hoàn chỉnh: đêm, ngủ, báo động, bến đò, hội thoại có chân dung, Sử liệu, nhạc + âm thanh, giao diện thật, hướng dẫn tối thiểu | Chủ dự án và vài người chơi thử; ghi nhận và sửa | **Xong** (13/10/2026) |
| **M3 – Nội dung** | Màn 0–9, màn phụ P (cuối mốc), lời kết, đủ quân và tướng, ~40 mục Sử liệu, hình thật | Chơi được từ đầu đến cuối; AI Tây Sơn đơn giản không kẹt ở màn nào | 10–15 phiên — **đang làm**: màn 0–9 và lời kết đã làm (màn 8, 9 đang chơi thử); còn màn phụ P |
| **M4 – Hoàn thiện** | Cân bằng, hướng dẫn, âm thanh, hiệu năng, thử trên nhiều máy, rà soát sử, đối chiếu nguyên văn nguồn (§3) | Không lỗi chặn; đối chiếu nguồn xong | 4–6 phiên |
| **M5 – Phát hành** | Trang store, ảnh chụp, phân loại tuổi, giấy tờ theo Nghị định 147 (nếu phát hành ở Việt Nam) | Có mặt trên Google Play và App Store | 1–2 phiên |

Tiếng Anh: sau 1.0.

## 2. Phân công

**Chủ dự án định hướng và duyệt; Claude làm toàn bộ phần sản xuất.**

| Ai | Làm gì |
|---|---|
| **Chủ dự án** | Định hướng, duyệt và góp ý mỗi mốc; chạy session Claude Code local để **build** (Android, iOS trên máy Mac) và chạy **agent kiểm thử** local; chơi thử trên điện thoại thật; các việc cần danh tính / tài khoản: ký và đẩy bản lên store (đã có tài khoản Google Play, Apple Developer), giấy tờ pháp lý |
| **Claude** | Thiết kế, lập trình Godot, AI, dựng màn, hình pixel art và chân dung (vẽ bằng code), nhạc và âm thanh (tổng hợp bằng code), kịch bản và Sử liệu, kiểm thử tự động, tài liệu, chuẩn bị hồ sơ store (mô tả, ảnh chụp, chính sách quyền riêng tư) |

Giới hạn của Claude, cần chủ dự án bù:
- Không chạy được trên điện thoại thật, không có máy Mac → build và chơi thử do session local của chủ dự án làm, dựa trên `BUILD.md` / `TESTING.md`.
- Không đọc được toàn văn nhiều trang nguồn (công cụ tải trang bị chặn) → đối chiếu nguyên văn (§3) cần người đọc sách, hoặc mở quyền truy cập mạng.
- Không tạo tài khoản, không thanh toán, không đứng tên pháp lý.

## 3. Đối chiếu nguồn trước phát hành

Rà soát lịch sử (tháng 10/2026) đã kiểm lịch âm – dương và sửa các lỗi trong tài liệu, nhưng vẫn chỉ đọc được trích đoạn tìm kiếm. Cần đọc nguyên văn:

1. *Hoàng Lê nhất thống chí* hồi 14 (bản dịch Nguyễn Đức Vân – Kiều Thu Hoạch): mọi câu thoại theo HLNTC, cách chia quân, mộc thuẫn, Hà Hồi, cầu phao.
2. *Thanh sử cảo* quyển 330, 334, 527 và *Thanh Cao Tông thực lục*: quân số, cái chết của Hứa Thế Hanh, phẩm hàm Tôn Sĩ Nghị, chức Thượng Duy Thăng.
3. Bài của GS Phan Huy Lê về Đặng Tiến Đông; các sách của Nguyễn Duy Chính.
4. Sách của Barrow và tranh Alexander (Biodiversity Heritage Library) cho trang phục; *Lê quý dật sử* đoạn tả quân Tây Sơn.
5. *Bắc hành lược ký* (Lê Quýnh): câu trích ở lời kết, kèm tên người dịch.

## 4. Phát hành và pháp lý

### Nghị định 147/2024/NĐ-CP — cần chốt ngay (chặn phát hành ở Việt Nam)

Theo rà soát (chỉ đọc được trích đoạn của các trang luật; độ chắc trung bình – cao, **cần luật sư xác nhận trên nguyên văn**):
- Game tải về chơi offline, không tương tác với máy chủ vẫn là **G4** (Điều 37 khoản 1) — vẫn thuộc phạm vi nghị định, kể cả game miễn phí.
- G2–G4 cần **hai** giấy: *Giấy chứng nhận đăng ký cung cấp dịch vụ trò chơi điện tử G2, G3, G4* (cấp một lần) và *Giấy xác nhận thông báo phát hành*
  cho từng game; nộp ở Sở Văn hóa, Thể thao và Du lịch nơi đặt trụ sở.
- Chủ thể được cấp là **doanh nghiệp**; không thấy điều khoản nào cho cá nhân. Kho ứng dụng phải chỉ đưa lên game có giấy hợp lệ.
- Văn bản liên quan mới: Nghị định 174/2026/NĐ-CP (xử phạt, từ 01/7/2026); dự thảo sửa Nghị định 147 (7/2026).

→ **Đứng tên cá nhân gần như chắc chắn không phát hành hợp lệ được trên store Việt Nam.**

**Quyết định của chủ dự án (13/10/2026): cứ đưa lên store dưới tên cá nhân; nếu bị chặn thì xử lý sau.** Các hướng dự phòng:
- (a) Lập doanh nghiệp (vd. công ty TNHH một thành viên), xin giấy G2–G4, rồi thông báo phát hành.
- (b) Phát hành qua một nhà phát hành Việt Nam đã có giấy (tên trên store là của họ).
- (c) Đứng tên cá nhân, **không mở bán ở Việt Nam**, chỉ phát hành ở các nước khác (trái với người chơi mục tiêu chính).

### Các việc khác

| Việc | Ghi chú |
|---|---|
| Độ tuổi | Tự phân loại **12+** (có giao chiến bằng vũ khí) |
| Nội dung cấm | Không "xuyên tạc truyền thống lịch sử" → bốn nhãn nguồn + danh sách nguồn trong Sử liệu là bằng chứng làm đúng |
| Apple 1.1.1 | Không miệt thị theo nguồn gốc quốc gia → quy tắc từ ngữ ở 05 §4 |
| Google Play | Khai báo nội dung (bạo lực mức nhẹ, bối cảnh lịch sử), chính sách quyền riêng tư. **Tài khoản cá nhân tạo sau 11/2023** phải chạy thử nghiệm kín ≥ 12 người liên tục 14 ngày trước khi phát hành chính thức |
| Trung Quốc đại lục | Không phát hành |
| Bản đồ | Bản đồ năm 1788–1789, không vẽ biên giới hay vùng biển hiện đại |
| Danh dự dòng họ | Không gán Đô đốc Long cho một họ cụ thể (Sử liệu trình bày thuyết Đặng Tiến Đông đầu tiên); không bịa tên tướng giữ đồn |

## 5. Đã chốt và còn mở

Đã chốt: miễn phí hoàn toàn (không quảng cáo, không mua trong app); tên tạm **Tây Sơn**; đã có máy Mac và tài khoản Google Play / Apple Developer
(tài khoản Google Play có từ trước 11/2023 → không cần thử nghiệm kín 14 ngày); đứng tên cá nhân, pháp lý Việt Nam xử lý khi phát sinh;
build và chơi thử bằng session local của chủ dự án; giữ màn phụ thủy quân và hai trận diễn tập màn 1–2.

| Còn mở | Ảnh hưởng | Khi nào cần chốt |
|---|---|---|
| Tên chính thức (bỏ chữ "tạm"); kiểm tra trùng tên trên store | Logo, trang store | Trước M4 |
| Mức chất lượng hình vẽ bằng code (duyệt hình mẫu ở M1) | Có cần thêm nguồn hình khác | Cuối M1 |

## 6. Rủi ro

| Rủi ro | Mức | Cách giảm |
|---|---|---|
| **Pháp lý Việt Nam** (cá nhân không được cấp giấy G4) | Cao | Chủ dự án chấp nhận rủi ro; dự phòng (a)/(b)/(c) ở §4 |
| **Chất lượng hình và nhạc tạo bằng code** không đạt (khoảng 33 loại lính × 6 frame, ~30 chân dung, 8 bản nhạc) | Cao | Hình mẫu chất lượng thật ở M1 cho chủ dự án duyệt sớm; nếu không đạt: dùng tài nguyên CC0 hoặc thuê vẽ riêng chân dung |
| Sai sử bị cộng đồng bắt lỗi (như *Sử Hộ Vương* 2019) | Cao | Bốn nhãn nguồn, Sử liệu có nguồn, đối chiếu nguyên văn (§3); nếu được, nhờ một người am hiểu sử đọc kịch bản trước M5 |
| Phạm vi lớn (10 màn + đánh đêm + AI) | Cao | Lát cắt dọc M2 trước; màn phụ P làm cuối M3; tiếng Anh để sau 1.0 |
| Vòng phản hồi chậm (phụ thuộc chủ dự án build, cài, chơi) | TB | Chế độ chạy kịch bản + chụp màn hình để agent local tự kiểm; gom nhiều thay đổi cho mỗi lần build |
| AI yếu / kẹt trên bản đồ lớn | TB | Chế độ AI theo kịch bản; AI Tây Sơn đơn giản để phát hiện kẹt |
| Màn hình dọc chật / máy tính bảng bỏ khóa dọc | TB | Phóng nguyên số, giao diện co giãn 288–432; bố cục dọc giữa màn hình trên máy lớn |
| Đánh đêm khó hiểu với người mới | TB | Màn 4 là lát cắt dọc → chơi thử sớm nhất |
| Phản ứng về cách khắc họa quân Thanh | Thấp – TB | Quy tắc từ ngữ; khắc họa con người; lời kết tưởng niệm cả hai bên |
| Văn bản pháp lý thay đổi (dự thảo sửa NĐ 147) | Thấp – TB | Kiểm lại ở M4 |
