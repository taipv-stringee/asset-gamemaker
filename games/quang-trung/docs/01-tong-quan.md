# 01 — Tổng quan game

> Tài liệu "một trang" của dự án. Mọi tài liệu khác chi tiết hóa từ đây. Khi một quyết định ở đây đổi,
> cập nhật bảng quyết định trong [README](../README.md).

## Một câu

Game chiến thuật theo lượt trên điện thoại, chơi màn hình dọc, lối chơi bám sát *Ancient Empires 2*:
người chơi cầm quân Tây Sơn đi từ núi Bân (22/12/1788) tới Thăng Long trưa hoặc chiều mùng 5 Tết Kỷ Dậu (30/01/1789).

## Tên game

Tên tạm: **Tây Sơn** (chủ dự án chốt). Các tên khác đã cân nhắc:

| Tên | Ý |
|---|---|
| Quang Trung: Tết Kỷ Dậu | Rõ nhân vật, rõ mốc thời gian |
| Thần Tốc | Nhấn vào cuộc hành quân, ngắn, dễ nhớ |
| Sáu Ngày Tết | Lấy từ báo cáo nghiên cứu: từ đêm 30 đến trưa mùng 5 |
| Đại Phá | Ngắn, gợi "đại phá quân Thanh" |

## Trụ cột thiết kế

1. **Bám sát AE2.** Lưới ô vuông, mua lính ở đồn, chiếm làng lấy vàng, lên cấp, 10 vai lính, khắc chế rõ ràng.
   Người đã chơi AE2 phải thấy quen trong 1 phút. Chỉ thay đổi khi lịch sử hoặc màn hình dọc buộc phải đổi,
   và ghi rõ chỗ đổi trong [02-luat-choi.md](02-luat-choi.md) và [10-doi-chieu-ae2.md](10-doi-chieu-ae2.md).
2. **Lịch sử có nguồn.** Ngày, địa danh, nhân vật, binh chủng lấy từ [báo cáo nghiên cứu](nghien-cuu/bao-cao-lich-su.md).
   Mọi chi tiết trong game được gắn một trong bốn nhãn: *Sử liệu*, *Theo HLNTC*, *Tương truyền*, *Sáng tạo của game*.
   Chính xác là điểm bán hàng, không phải gánh nặng.
3. **Thần tốc.** Cảm giác chủ đạo là tốc độ và bất ngờ: đánh đêm, vây đồn, kịp vào Thăng Long trước "mùng 7".
   Cơ chế thưởng cho người đánh nhanh (mục tiêu phụ theo số lượt), đánh đêm (địch ngủ, sương mù), và chiêu hàng.
4. **Chơi một tay, từng đoạn ngắn.** Màn hình dọc, chạm là chính, một lượt chơi 1–3 phút, một màn 10–25 phút,
   tự lưu mỗi lượt để tắt app lúc nào cũng được.
5. **Tôn trọng người chết của cả hai phía.** Không có cơ chế gọi xác chết, không dùng từ miệt thị trong giao diện,
   tướng Thanh được khắc họa như con người (Hứa Thế Hanh theo sử Thanh ở lại chặn hậu, Sầm Nghi Đống tự vẫn), có lời kết tưởng niệm
   tử sĩ cả hai bên (lấy cảm hứng từ lễ hội gò Đống Đa ngày nay).

## Người chơi mục tiêu

- Người Việt 16–40 tuổi, từng chơi AE2 / game Java trên điện thoại cũ, hoặc thích chiến thuật theo lượt
  (Fire Emblem, Advance Wars, Into the Breach).
- Người thích lịch sử Việt Nam, muốn một game "đúng sử" chứ không phải anime hóa (bài học từ *Sử Hộ Vương*, 2019).
- Độ tuổi phân loại dự kiến **12+** (có giao chiến bằng vũ khí, theo Nghị định 147/2024).

## Phạm vi phiên bản đầu (1.0)

| Có | Chưa có |
|---|---|
| Chiến dịch 10 màn đánh (gồm màn phụ thủy quân) + 1 màn chuyện + lời kết (xem [04-chien-dich.md](04-chien-dich.md)) | Đánh tự do (skirmish), chơi 2 người |
| 10 vai lính Tây Sơn + hàng binh, 8 loại lính phe Thanh/Lê, 8 tướng Tây Sơn và 5 tướng Thanh có tên | Trình tạo bản đồ |
| Đánh đêm (sương mù, đuốc, địch ngủ), vây đồn gọi hàng, chiêu hàng quân tan, cầu phao đứt | Nhiều người chơi qua mạng |
| Hội thoại có chân dung, mục **Sử liệu** (codex) 3 tầng nguồn | Lồng tiếng |
| Tiếng Việt | Tiếng Anh (để sẵn hạ tầng dịch, làm sau 1.0) |
| Android, iOS | PC/console |

Game **miễn phí hoàn toàn**: không quảng cáo, không mua trong app, không năng lượng, không gacha.

## Nền tảng và công nghệ

- Engine **Godot 4** (giấy phép MIT, không phí bản quyền), ngôn ngữ GDScript. Chi tiết: [08-ky-thuat.md](08-ky-thuat.md).
- Android (Google Play) và iOS (App Store), điện thoại; màn hình dọc. Chủ dự án đã có máy Mac và tài khoản cả hai store.
  Đứng tên cá nhân; chủ dự án chọn đưa lên store trước, nếu bị chặn theo Nghị định 147 thì xử lý sau (09 §4).
- Chơi hoàn toàn offline.

## Tham chiếu

| Game | Lấy gì |
|---|---|
| Ancient Empires 2 (Macrospace, 2005) | Toàn bộ khung luật: vai lính, kinh tế, chiếm làng, lên cấp, màn chiến dịch có hội thoại |
| Advance Wars | Dự báo sát thương, giao diện chạm rõ ràng, sương mù chiến tranh |
| Into the Breach | Màn ngắn, thông tin minh bạch, chơi tốt trên màn hình nhỏ |
| Fire Emblem (GBA) | Chân dung hội thoại, tướng có tên, cảm xúc khi mất quân |
