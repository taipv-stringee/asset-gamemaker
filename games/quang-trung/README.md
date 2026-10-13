# Tây Sơn (tên tạm)

Game chiến thuật theo lượt trên điện thoại (màn hình dọc), lối chơi bám sát **Ancient Empires 2**, về chiến dịch
Quang Trung đại phá quân Thanh, từ núi Bân (22/12/1788) đến Thăng Long trưa hoặc chiều mùng 5 Tết Kỷ Dậu (30/01/1789).
Làm bằng **Godot 4**, phát hành **miễn phí** trên Google Play và App Store (chủ dự án đứng tên cá nhân).
Thư mục vẫn tên `quang-trung` (tên mã dự án).

**Trạng thái: M3 – Nội dung** (đang làm: màn 0–4 chơi được). M1, M2 xong 13/10/2026. Project Godot ở [`godot/`](godot/) — cách build và kiểm thử: [`godot/BUILD.md`](godot/BUILD.md), [`godot/TESTING.md`](godot/TESTING.md). Hình tạm và mockup: [`drafts/quang-trung/`](../../drafts/quang-trung/).

## Tài liệu

| Tài liệu | Nội dung |
|---|---|
| [01 – Tổng quan](docs/01-tong-quan.md) | Ý tưởng, trụ cột thiết kế, người chơi, phạm vi 1.0 |
| [02 – Luật chơi](docs/02-luat-choi.md) | Lượt, di chuyển, công thức đánh, kinh tế, cấp bậc, chiêu hàng, đánh đêm, vây đồn, AI |
| [03 – Đơn vị và địa hình](docs/03-don-vi-dia-hinh.md) | Chỉ số lính hai phe, tướng, khắc chế, địa hình, mở khóa |
| [04 – Chiến dịch](docs/04-chien-dich.md) | 10 màn đánh + màn chuyện + lời kết, từng màn: lịch sử, bản đồ, quân, thắng/thua |
| [05 – Cốt truyện](docs/05-cot-truyen.md) | Bốn nhãn nguồn, nhân vật, quy tắc lời thoại, Sử liệu, thuật ngữ |
| [06 – Giao diện](docs/06-giao-dien.md) | Khung màn hình dọc, thao tác chạm, luồng màn hình, lưu game |
| [07 – Mỹ thuật và âm thanh](docs/07-mi-thuat-am-thanh.md) | Thông số hình, hướng nghệ thuật theo nguồn, danh sách asset, nhạc |
| [08 – Kỹ thuật](docs/08-ky-thuat.md) | Kiến trúc Godot, dữ liệu, bản đồ, kiểm thử, xuất bản |
| [09 – Kế hoạch](docs/09-ke-hoach.md) | Các mốc M0–M5, phân công, đối chiếu nguồn, pháp lý, câu hỏi mở, rủi ro |
| [10 – Đối chiếu AE2](docs/10-doi-chieu-ae2.md) | Từng con số và luật so với Ancient Empires 2: giữ hay đổi, độ chắc của thông tin |
| [Nghiên cứu lịch sử](docs/nghien-cuu/bao-cao-lich-su.md) | Báo cáo tổng hợp + [ghi chú gốc](docs/nghien-cuu/ghi-chu/) |
| [Rà soát 10/2026](docs/ra-soat/) | Báo cáo rà soát lịch sử và thiết kế; các lỗi đã được sửa vào 01–10 |

Người mới đọc theo thứ tự: 01 → 04 → 02 → 03; người vẽ đọc thêm 07; người viết kịch bản đọc 05 trước tiên.

## Quyết định đã chốt

| Vấn đề | Quyết định | Ở đâu |
|---|---|---|
| Engine | Godot 4 (MIT, không phí bản quyền) | 08 |
| Lối chơi | Bám sát AE2; chỗ đổi được đánh dấu **[đổi]** | 02 |
| Tên nhân vật | Tên thật | 05 |
| Chế độ chơi | Chỉ chiến dịch | 01 |
| Màn hình | Dọc, gốc 288 × 512, phóng nguyên số | 06, 08 |
| Hình ảnh | Pixel art 32px, chân dung hội thoại 80 × 80 | 07 |
| Màn đêm bắt buộc | Đêm 30 Tết = vượt sông Gián (màn 4); Hà Hồi là đêm mùng 3 (màn 6) | 04 |
| Mộ / gọi xương của AE2 | Đổi thành quân tan / chiêu hàng; thêm vây đồn / gọi hàng | 02 |
| Tướng chính bị hạ | Thua màn (không mua lại như AE2) | 02 |
| Tên game | **Tây Sơn** (tạm) | 01 |
| Kiếm tiền | Miễn phí hoàn toàn: không quảng cáo, không mua trong app | 01 |
| Phát hành | Đứng tên cá nhân, đưa lên store trước; nếu bị chặn theo NĐ 147 thì xử lý sau (rủi ro ghi ở 09 §4). Tài khoản Google Play có từ lâu (không cần thử nghiệm kín 14 ngày) | 09 §4 |
| Build và chơi thử | Chủ dự án build trên máy mình (session Claude Code local + agent kiểm thử local) | 08, 09 |
| Màn phụ thủy quân, trận diễn tập màn 1–2 | Giữ | 04 |
| Người làm | Claude làm toàn bộ sản xuất; chủ dự án định hướng, duyệt, chơi thử, lo tài khoản store và pháp lý | 09 |
| Nguồn lịch sử | Mọi chi tiết gắn một trong bốn nhãn: Sử liệu / Theo HLNTC / Tương truyền / Sáng tạo của game | 05 |

## Câu hỏi còn mở

Xem [09 mục 5](docs/09-ke-hoach.md#5-đã-chốt-và-còn-mở).
