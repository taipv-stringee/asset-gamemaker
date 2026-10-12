# 09 — Kế hoạch sản xuất và phát hành

## 1. Các mốc

Mỗi mốc có **điều kiện xong** rõ ràng; chưa đạt thì chưa sang mốc sau. Thời lượng phụ thuộc số người trong nhóm nên chưa ghi.

| Mốc | Nội dung | Điều kiện xong |
|---|---|---|
| **M0 – Tài liệu** | Bộ tài liệu này | Chủ dự án duyệt 01–09; chốt các câu hỏi ở mục 5 có ảnh hưởng tới M1 |
| **M1 – Mẫu luật chơi** | Project Godot; `core/` (bản đồ, đi, đánh, phản đòn, chiếm, mua lính, cấp bậc); AI cơ bản; 1 bản đồ thử; hình tạm từ `generate_v2.py`; chạy trên điện thoại thật | Chơi trọn một trận AE2-style trên điện thoại; test `core/` xanh |
| **M2 – Lát cắt dọc** | **Màn 4 (Đêm 30 Tết – sông Gián)** làm hoàn chỉnh: sương mù, địch ngủ, báo động, bến đò, hội thoại có chân dung, Sử liệu, nhạc + âm thanh, giao diện thật, hướng dẫn tối thiểu | 5–10 người chơi thử ngoài nhóm; ghi nhận và sửa; đây là bản dùng để quyết định cách kiếm tiền và gọi vốn / tuyển người |
| **M3 – Nội dung** | Màn 0–9, lời kết, đủ 10 vai lính + quân Thanh/Lê + tướng, ~40 mục Sử liệu, hình thật | Chơi được từ đầu đến cuối; AI vs AI mô phỏng không kẹt |
| **M4 – Hoàn thiện** | Cân bằng, hướng dẫn, âm thanh, hiệu năng, thử trên nhiều máy, rà soát sử cho kịch bản và Sử liệu, đối chiếu nguyên văn các nguồn | Không lỗi chặn; danh sách đối chiếu nguồn (mục 3) xong |
| **M5 – Phát hành** | Trang store, ảnh chụp, phân loại tuổi, thủ tục theo Nghị định 147, phát hành thử ở Việt Nam | Có mặt trên Google Play và App Store |

Màn phụ P (thủy quân) và tiếng Anh: sau 1.0.

## 2. Phân công

**Chủ dự án định hướng và duyệt; Claude làm toàn bộ phần sản xuất.**

| Ai | Làm gì |
|---|---|
| **Chủ dự án** | Định hướng, duyệt cuối mỗi mốc, chơi thử bản build trên điện thoại thật, và các việc cần danh tính / tài khoản thật: tài khoản Google Play và Apple Developer, ký và đẩy bản lên store, thủ tục theo Nghị định 147, thanh toán |
| **Claude** | Thiết kế, lập trình Godot, AI, dựng màn, hình pixel art và chân dung (vẽ bằng code), nhạc và âm thanh (tổng hợp bằng code), kịch bản và Sử liệu, kiểm thử tự động, tài liệu, chuẩn bị hồ sơ store (mô tả, ảnh chụp, chính sách quyền riêng tư) |

Giới hạn của Claude, cần chủ dự án bù:
- Không chạy được trên điện thoại thật → chủ dự án cài bản build (APK) để chơi thử và báo lại.
- Không có máy Mac → không tự build iOS.
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

## 5. Câu hỏi còn mở

| Câu hỏi | Ảnh hưởng | Khi nào cần chốt |
|---|---|---|
| **Cách kiếm tiền**: miễn phí, mua một lần, miễn phí + mở khóa toàn bộ, quảng cáo? | Giá, màn hình cửa hàng, có cần SDK quảng cáo / mua trong app | Trước M5; nên quyết sau khi có M2 để thử phản ứng người chơi |
| **Tên game** | Logo, trang store | Trước M4 |
| Chủ dự án có máy Mac để build iOS không? | Phát hành iOS | Trước M4 |
| **Ai đứng tên phát hành** (cá nhân hay công ty) và tài khoản Google Play / Apple Developer | Tên nhà phát hành trên store, thủ tục theo Nghị định 147 | Trước M5 |
| Cách nhận bản build để chơi thử (APK qua GitHub Releases / Actions, hay cách khác) | Chơi thử từ M1 | Trước khi xong M1 |
| Có giữ trận diễn tập ở màn 1–2 không, hay gộp thành một màn hướng dẫn? | Số màn | Sau khi chơi thử M2 |
| Màn phụ thủy quân: làm trong 1.0 hay bỏ? | Phạm vi | Đầu M3 |

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
