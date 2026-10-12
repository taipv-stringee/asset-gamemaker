# 09 — Kế hoạch sản xuất và phát hành

## 1. Các mốc

Mỗi mốc có **điều kiện xong** rõ ràng; chưa đạt thì chưa sang mốc sau. Thời lượng phụ thuộc số người trong nhóm nên chưa ghi.

| Mốc | Nội dung | Điều kiện xong |
|---|---|---|
| **M0 – Tài liệu** | Bộ tài liệu này | Chủ dự án duyệt 01–09; chốt các câu hỏi ở mục 5 có ảnh hưởng tới M1 |
| **M1 – Mẫu luật chơi** | Project Godot; `core/` (bản đồ, đi, đánh, phản đòn, chiếm, mua lính, cấp bậc); AI cơ bản; 1 bản đồ thử; hình tạm từ `generate_v2.py`; chạy trên điện thoại thật | Chơi trọn một trận AE2-style trên điện thoại; test `core/` xanh |
| **M2 – Lát cắt dọc** | **Màn 4 (Đêm 30 Tết – sông Gián)** làm hoàn chỉnh: sương mù, địch ngủ, báo động, bến đò, hội thoại có chân dung, Sử liệu, nhạc + âm thanh, giao diện thật, hướng dẫn tối thiểu | 5–10 người chơi thử ngoài nhóm; ghi nhận và sửa; đây là bản dùng để quyết định cách kiếm tiền và gọi vốn / tuyển người |
| **M3 – Nội dung** | Màn 0–9, lời kết, đủ 10 vai lính + quân Thanh/Lê + tướng, ~40 mục Sử liệu, hình thật | Chơi được từ đầu đến cuối; AI vs AI mô phỏng không kẹt |
| **M4 – Hoàn thiện** | Cân bằng, hướng dẫn, âm thanh, hiệu năng, thử trên nhiều máy, **cố vấn sử học đọc kịch bản và Sử liệu**, đối chiếu nguyên văn các nguồn | Không lỗi chặn; danh sách đối chiếu nguồn (mục 3) xong |
| **M5 – Phát hành** | Trang store, ảnh chụp, phân loại tuổi, thủ tục theo Nghị định 147, phát hành thử ở Việt Nam | Có mặt trên Google Play và App Store |

Màn phụ P (thủy quân) và tiếng Anh: sau 1.0.

## 2. Nhân sự cần

| Vai | Việc | Ghi chú |
|---|---|---|
| Thiết kế + lập trình Godot | Luật chơi, AI, màn, giao diện | Có thể là 1–2 người |
| Họa sĩ pixel | ~33 loại lính, ~30 chân dung, địa hình, UI | Hình tạm do script lo đến hết M1 |
| Âm nhạc / âm thanh | 8 bản nhạc, ~40 hiệu ứng | Có thể thuê theo gói |
| Viết kịch bản | Hội thoại, Sử liệu | Theo [05](05-cot-truyen.md) |
| **Cố vấn sử học** | Đọc kịch bản, Sử liệu, trang phục | Cách giảm rủi ro rẻ nhất (báo cáo nghiên cứu) |
| Chơi thử | M2 trở đi | Cộng đồng người chơi AE2, nhóm yêu sử |

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
| Nội dung cấm | Không "xuyên tạc truyền thống lịch sử" → bốn nhãn nguồn + cố vấn sử học là bằng chứng làm đúng |
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
| Nhóm có máy Mac để build iOS không? | Phát hành iOS | Trước M4 |
| Hình thật: thuê họa sĩ hay tự vẽ? | Chi phí, thời gian M3 | Trước M3 |
| Có giữ trận diễn tập ở màn 1–2 không, hay gộp thành một màn hướng dẫn? | Số màn | Sau khi chơi thử M2 |
| Màn phụ thủy quân: làm trong 1.0 hay bỏ? | Phạm vi | Đầu M3 |

## 6. Rủi ro

| Rủi ro | Mức | Cách giảm |
|---|---|---|
| Sai sử bị cộng đồng bắt lỗi (như *Sử Hộ Vương* 2019) | Cao | Bốn nhãn nguồn, Sử liệu có nguồn, cố vấn sử học, đối chiếu nguyên văn (mục 3) |
| Phạm vi quá lớn (10 màn + đánh đêm + AI) | Cao | Lát cắt dọc M2 trước; màn phụ và tiếng Anh để sau 1.0 |
| AI yếu / kẹt trên bản đồ lớn | TB | Chế độ AI theo kịch bản; test mô phỏng AI vs AI |
| Màn hình dọc chật cho bản đồ lớn | TB | Phóng nguyên số + hiện thêm hàng; thu phóng 2 mức; vùng nguy hiểm |
| Đánh đêm khó hiểu với người mới | TB | Màn 4 là lát cắt dọc → chơi thử sớm nhất |
| Phản ứng về cách khắc họa quân Thanh | Thấp – TB | Quy tắc từ ngữ; khắc họa con người; lời kết cầu siêu cho cả hai bên |
| Thủ tục pháp lý thay đổi | Thấp | Xác minh lại ở M4 |
