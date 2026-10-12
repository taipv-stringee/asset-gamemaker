# 09 — Kế hoạch sản xuất và phát hành

## 1. Các mốc

Mỗi mốc có **điều kiện xong** rõ ràng; chưa đạt thì chưa sang mốc sau. Thời lượng phụ thuộc số người trong nhóm nên chưa ghi.

| Mốc | Nội dung | Điều kiện xong |
|---|---|---|
| **M0 – Tài liệu** | Bộ tài liệu này | Chủ dự án duyệt 01–09; chốt các câu hỏi ở mục 5 có ảnh hưởng tới M1 |
| **M1 – Mẫu luật chơi** | Project Godot; `core/` (bản đồ, đi, đánh, phản đòn, chiếm, mua lính, cấp bậc); AI cơ bản; 1 bản đồ thử; hình tạm từ `generate_v2.py`; `BUILD.md` + `TESTING.md` cho session local | Chơi trọn một trận AE2-style trên điện thoại; test `core/` xanh |
| **M2 – Lát cắt dọc** | **Màn 4 (Đêm 30 Tết – sông Gián)** làm hoàn chỉnh: sương mù, địch ngủ, báo động, bến đò, hội thoại có chân dung, Sử liệu, nhạc + âm thanh, giao diện thật, hướng dẫn tối thiểu | Chủ dự án và vài người chơi thử; ghi nhận và sửa |
| **M3 – Nội dung** | Màn 0–9, lời kết, đủ 10 vai lính + quân Thanh/Lê + tướng, ~40 mục Sử liệu, hình thật | Chơi được từ đầu đến cuối; AI vs AI mô phỏng không kẹt |
| **M4 – Hoàn thiện** | Cân bằng, hướng dẫn, âm thanh, hiệu năng, thử trên nhiều máy, rà soát sử cho kịch bản và Sử liệu, đối chiếu nguyên văn các nguồn | Không lỗi chặn; danh sách đối chiếu nguồn (mục 3) xong |
| **M5 – Phát hành** | Trang store, ảnh chụp, phân loại tuổi, thủ tục theo Nghị định 147, phát hành thử ở Việt Nam | Có mặt trên Google Play và App Store |

Tiếng Anh: sau 1.0. Màn phụ P (thủy quân) có trong 1.0, làm cuối M3.

## 2. Phân công

**Chủ dự án định hướng và duyệt; Claude làm toàn bộ phần sản xuất.**

| Ai | Làm gì |
|---|---|
| **Chủ dự án** | Định hướng, duyệt và góp ý mỗi mốc; chạy session Claude Code local để **build** (Android, iOS trên máy Mac) và chạy **agent kiểm thử** local; chơi thử trên điện thoại thật; các việc cần danh tính / tài khoản: ký và đẩy bản lên store (đã có tài khoản Google Play, Apple Developer), thủ tục theo Nghị định 147 |
| **Claude** | Thiết kế, lập trình Godot, AI, dựng màn, hình pixel art và chân dung (vẽ bằng code), nhạc và âm thanh (tổng hợp bằng code), kịch bản và Sử liệu, kiểm thử tự động, tài liệu, chuẩn bị hồ sơ store (mô tả, ảnh chụp, chính sách quyền riêng tư) |

Giới hạn của Claude, cần chủ dự án bù:
- Không chạy được trên điện thoại thật, không có máy Mac → build và chơi thử do session local của chủ dự án làm, dựa trên `BUILD.md` / `TESTING.md`.
- Không đọc được toàn văn nhiều trang nguồn (công cụ tải trang bị chặn) → đối chiếu nguyên văn ở mục 3 cần người đọc sách,
  hoặc mở được quyền truy cập mạng cho môi trường làm việc.
- Không tạo tài khoản, không thanh toán, không đứng tên pháp lý.

## 3. Đối chiếu nguồn trước phát hành

Thứ tự ưu tiên lấy từ báo cáo nghiên cứu (nhóm nghiên cứu mới đọc được trích đoạn tìm kiếm):

1. *Hoàng Lê nhất thống chí* hồi 14 (bản dịch Nguyễn Đức Vân – Kiều Thu Hoạch): mọi câu thoại theo HLNTC, phân công năm đạo, mộc thuẫn, cầu phao.
2. Bảng đối chiếu âm – dương lịch cho các ngày quy đổi (30 Chạp, mùng 1–4, mùng 7).
3. *Thanh sử cảo* quyển 330, 334, 527 và *Thanh Cao Tông thực lục*: quân số, cái chết của Hứa Thế Hanh, phẩm hàm Tôn Sĩ Nghị.
4. Bài của GS Phan Huy Lê về Đặng Tiến Đông; các sách của Nguyễn Duy Chính.
5. Sách của Barrow và tranh Alexander (Biodiversity Heritage Library) cho trang phục.
6. Nguyên văn Nghị định 147/2024/NĐ-CP, Điều 37–38, và cơ quan có thẩm quyền sau đợt sắp xếp bộ năm 2025.

## 4. Phát hành và pháp lý

| Việc | Ghi chú |
|---|---|
| Phân loại game theo **Nghị định 147/2024** | Game tải về chơi offline, không có máy chủ: dự kiến thuộc nhóm chỉ cần **thông báo phát hành** (không phải xin phê duyệt kịch bản như G1) — **phải xác minh** Điều 37 |
| Độ tuổi | Tự phân loại **12+** (có giao chiến bằng vũ khí) |
| Nội dung cấm | Không "xuyên tạc truyền thống lịch sử" → bốn nhãn nguồn + danh sách nguồn trong Sử liệu là bằng chứng làm đúng |
| Apple 1.1.1 | Không miệt thị theo nguồn gốc quốc gia → quy tắc từ ngữ ở 05 mục 4 |
| Google Play | Khai báo nội dung (bạo lực mức nhẹ, bối cảnh lịch sử), chính sách quyền riêng tư |
| Trung Quốc đại lục | **Không phát hành** |
| Bản đồ | Bản đồ năm 1788–1789, không vẽ biên giới hay vùng biển hiện đại |
| Danh dự dòng họ | Không gán Đô đốc Long cho một họ cụ thể; không bịa tên tướng giữ đồn |

## 5. Đã chốt và còn mở

Đã chốt: miễn phí hoàn toàn; tên tạm **Tây Sơn**; phát hành cá nhân, đã có máy Mac và tài khoản Google Play / Apple Developer;
build và chơi thử bằng session local của chủ dự án; giữ màn phụ thủy quân và hai trận diễn tập màn 1–2.

| Còn mở | Ảnh hưởng | Khi nào cần chốt |
|---|---|---|
| Tên chính thức (bỏ chữ "tạm"); kiểm tra trùng tên trên store | Logo, trang store | Trước M4 |
| Cá nhân có được phát hành game ở Việt Nam theo Nghị định 147 không, thuộc nhóm nào (G1–G4) | Có phát hành được ở Việt Nam dưới tên cá nhân hay không | Trước M5 — đang nhờ review xác minh |

## 6. Rủi ro

| Rủi ro | Mức | Cách giảm |
|---|---|---|
| Sai sử bị cộng đồng bắt lỗi (như *Sử Hộ Vương* 2019) | Cao | Bốn nhãn nguồn, Sử liệu có nguồn, đối chiếu nguyên văn (mục 3); nếu được, nhờ một người am hiểu sử đọc kịch bản trước M5 |
| Phạm vi quá lớn (10 màn + đánh đêm + AI) | Cao | Lát cắt dọc M2 trước; màn phụ và tiếng Anh để sau 1.0 |
| AI yếu / kẹt trên bản đồ lớn | TB | Chế độ AI theo kịch bản; test mô phỏng AI vs AI |
| Màn hình dọc chật cho bản đồ lớn | TB | Phóng nguyên số + hiện thêm hàng; thu phóng 2 mức; vùng nguy hiểm |
| Đánh đêm khó hiểu với người mới | TB | Màn 4 là lát cắt dọc → chơi thử sớm nhất |
| Phản ứng về cách khắc họa quân Thanh | Thấp – TB | Quy tắc từ ngữ; khắc họa con người; lời kết cầu siêu cho cả hai bên |
| Thủ tục pháp lý thay đổi | Thấp | Xác minh lại ở M4 |
