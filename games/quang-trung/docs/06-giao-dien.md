# 06 — Giao diện và điều khiển

> Màn hình dọc, chơi một tay. Mockup tham khảo: `drafts/quang-trung/assets_v2/mockup_battle.png` và
> `mockup_dialogue_night.png` (bản nháp, nhãn "Đêm 30 Tết · Hà Hồi" trong mockup là sai sử, xem 04).

## 1. Khung màn hình

- Kích thước gốc **288 × 512** điểm ảnh logic, phóng **nguyên số** (08 §4). Vì vậy vùng logic thật thay đổi theo máy: rộng **288–432**
  (9–13 cột), cao 512 trở lên. Giao diện **neo theo cạnh** (anchor), không giả định cố định 9 cột; máy dài hơn thì thấy thêm hàng ô.
- **Màn hình ngang / máy tính bảng / máy gập**: Android 16 (khi app nhắm API 36) bỏ qua khóa màn hình dọc trên màn hình lớn; iPad cũng
  đang bỏ chế độ toàn màn hình bắt buộc. Cách xử lý ở 1.0: giữ nguyên bố cục dọc ở giữa màn hình, hai bên là khung trang trí sơn mài.
  Không thiết kế bố cục ngang riêng.
- Chừa vùng an toàn (tai thỏ, thanh điều hướng): thanh trên và bảng dưới nằm trong vùng an toàn; bản đồ được tràn ra sau.
- Vùng ngón cái (nửa dưới màn hình) chứa mọi nút hay bấm. Thanh trên chỉ hiển thị thông tin.

```
┌────────────────────────────┐
│ Hà Hồi · Lượt 2   ◎ 800  ≡ │  thanh trên: tên màn, lượt, vàng, menu
│ Mục tiêu: chiếm đồn        │
├────────────────────────────┤
│                            │
│        BẢN ĐỒ              │  kéo để cuộn, chụm để thu phóng (2 mức)
│   (9–13 cột × 12+ hàng)    │
│                            │
├────────────────────────────┤
│ [chân dung] Tên quân  Cấp 2│  bảng dưới: quân / ô đang chọn
│  Máu 100  Công 60–70       │
│  [ Chờ ]  [ Đi ]  [ Đánh ] │  nút hành động theo ngữ cảnh
│                [Hết lượt ▶]│
└────────────────────────────┘
```

## 2. Thao tác

| Thao tác | Tác dụng |
|---|---|
| Chạm quân mình | Chọn; hiện ô đi được (xanh) và ô đánh được (đỏ) |
| Chạm ô xanh | Hiện đường đi; chạm lại lần nữa (hoặc nút **Đi**) để đi |
| Sau khi đi | Bảng dưới hiện các hành động hợp lệ: Đánh, Chiếm, Chiêu hàng, Gọi hàng, Mua lính, Chờ, **Hoàn tác** |
| Chạm quân địch trong tầm | Hiện **dự báo**: sát thương gây ra, phản đòn nhận lại, % hạ; chạm lần nữa để đánh |
| Chạm quân địch ngoài tầm | Hiện thông tin và **vùng nguy hiểm** của nó (ô nó có thể đánh tới) |
| Giữ lâu một ô | Thông tin địa hình: chi phí đi, thủ, đặc tính |
| Kéo một ngón | Cuộn bản đồ |
| Chụm hai ngón | Thu / phóng 2 mức: ×1 và ×2 (giữ phóng nguyên số) |
| Nút **Hết lượt** | Hỏi xác nhận nếu còn quân chưa đi |
| Nút **≡** | Tạm dừng: tiếp tục, xem mục tiêu, Sử liệu, cài đặt, bỏ màn |

Vùng chạm của ô là 32 × hệ số phóng (≥ 96 px vật lý trên máy 1080p, khoảng 6 mm — dưới mức khuyến nghị 7–9 mm, chấp nhận được vì
đi và đánh đều cần chạm hai lần để xác nhận; mức phóng ×2 cho người cần ô to hơn). Nút ≥ 44 điểm.

## 3. Lượt của máy

- Camera đi theo từng quân máy **đang được thấy** (ở màn đêm không bám theo quân trong sương mù).
- Nút **Tua nhanh** (×2) và **Bỏ hoạt cảnh** (chỉ hiện kết quả). Lưu lựa chọn trong cài đặt.
- Hiện số sát thương nổi lên trên quân bị đánh.

## 4. Luồng màn hình

```
Khởi động → Màn hình tiêu đề ("Đánh cho để dài tóc…" — nhãn Tương truyền)
  → Menu chính: Tiếp tục | Chiến dịch | Sử liệu | Cài đặt
      Chiến dịch → Bản đồ chiến dịch → Giới thiệu màn → [Hội thoại] → Trận đánh → [Hội thoại] → Kết quả màn
      Sử liệu → Danh mục (Sự kiện, Nhân vật, Binh chủng, Địa danh, Tranh cãi, Về các nguồn) → Mục
```

| Màn hình | Nội dung |
|---|---|
| **Giới thiệu màn** | Ngày âm + dương lịch, địa danh, bản đồ nhỏ, mục tiêu chính, mục tiêu phụ, một đoạn lịch sử 2–3 câu có nhãn nguồn |
| **Hội thoại** | Chân dung 88 × 88 (khung sơn mài) bên trái phía trên khung chữ, bảng tên, chữ hiện dần; chạm để tiếp, nút **Bỏ qua** |
| **Kết quả màn** | Số lượt, quân mất, mục tiêu phụ đạt được, mục Sử liệu mới mở |
| **Mua lính** | Danh sách lính mở khóa: hình, giá, công/thủ/di/tầm, một dòng đặc tính; lính không đủ vàng thì mờ |

## 5. Hiển thị trên bản đồ

- Máu: số ở góc dưới phải của quân khi < 100 (như AE2).
- Cấp: sao nhỏ góc trên trái (1–4).
- Trạng thái: biểu tượng nhỏ (lửa = Cháy, nốt nhạc/trống = Hào quang, "z" = Ngủ).
- Quân đã hành động: xám đi.
- Màu phe: **Tây Sơn đỏ**, **Diễn tập đỏ sẫm** (màn 1–2), **Thanh xanh lam**, **Lê vàng đất**, trung lập xám. Thêm khác biệt hình dáng (khăn vs mũ có tua,
  cờ đuôi nheo vs cờ vuông) để người mù màu vẫn phân biệt được.
- Đêm: ô ngoài tầm nhìn phủ màu xanh đen 60%; nguồn sáng có quầng ấm (bộ lọc `night()` trong bản nháp).

## 6. Cài đặt

Âm lượng nhạc / hiệu ứng; tốc độ lượt máy; bỏ hoạt cảnh đánh; cỡ chữ (2 mức); rung; ngôn ngữ (để sẵn, 1.0 chỉ tiếng Việt);
thuận tay trái (đảo vị trí nút **Hết lượt**).

## 7. Lưu game

- Tự lưu đầu mỗi lượt của người chơi và khi app bị đưa xuống nền. Mở lại app → **Tiếp tục** vào đúng lượt đó.
- Hai khe: chiến dịch, và chơi lại màn đã qua (không ảnh hưởng tiến trình). Chi tiết kỹ thuật ở 08 §3.4.
- Không có lưu/tải tùy ý giữa lượt (đúng tinh thần AE2, và seed ngẫu nhiên nằm trong file lưu).

## 8. Hướng dẫn trong game

Theo màn 0–2 (xem 04). Hướng dẫn là các khung gợi ý trỏ vào nút / ô, chỉ hiện lần đầu, xem lại được trong menu.
Không chặn người chơi quá 3 bước liên tiếp.
