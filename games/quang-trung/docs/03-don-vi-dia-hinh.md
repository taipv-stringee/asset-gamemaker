# 03 — Đơn vị và địa hình

> Số liệu **khởi điểm**, sẽ cân bằng lại sau khi chơi thử. Khi dựng project, bảng ở đây được chép sang
> `data/units.csv` và `data/terrain.csv` (xem [08-ky-thuat.md](08-ky-thuat.md)); từ lúc đó file CSV là nguồn
> chuẩn và tài liệu này chỉ cập nhật theo.
>
> Cột **Nguồn** cho biết độ bám sử của loại lính (theo [báo cáo nghiên cứu](nghien-cuu/bao-cao-lich-su.md),
> mục *Đội hình mười vai*): **Cao** = sử liệu cả hai phía; **TB** = có nguồn nhưng gián tiếp; **Thấp** = sáng tạo hợp lý.

Ký hiệu: Công = khoảng sát thương gốc; Thủ = thủ gốc; Di = điểm di chuyển; Tầm = cự ly đánh;
Kiểu = kiểu di chuyển (*Bộ*, *Nặng*, *Voi*, *Thủy*). Mọi quân có 100 máu tối đa.

## 1. Quân Tây Sơn

| # | Tên | Vai AE2 | Giá | Công | Thủ | Di | Tầm | Kiểu | Đặc tính | Nguồn |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | **Lính giáo** | Soldier | 150 | 50–55 | 5 | 4 | 1 | Bộ | Chiếm làng. +10 công khi đánh voi | TB–Cao |
| 2 | **Hỏa mai thủ** | Archer | 250 | 50–55 | 5 | 4 | 1–2 | Bộ | — | TB |
| 3 | **Thủy binh** | Lizard | 300 | 50–55 | 10 | 4 | 1 | Thủy | Đi sông 1 điểm. +5 thủ khi đứng dưới nước | Thấp–TB |
| 4 | **Quân sư** | Wizard | 400 | 35–40 | 5 | 4 | 1–2 | Bộ | **Chiêu hàng** quân tan trong 2 ô. Thấy địa lôi ở ô kề. Gọi hàng đồn bị vây | TB (cơ chế) |
| 5 | **Trống trận** | Wisp | 400 | 30–35 | 10 | 4 | 1 | Bộ | **Hào quang**: quân mình trong 8 ô quanh +10 công | Thấp |
| 6 | **Hỏa hổ** | Spider | 500 | 50–55 | 10 | 4 | 1 | Bộ | Đánh trúng gây **Cháy**. +10 công khi đánh voi hoặc quân trong doanh trại. Đốt được ô doanh trại | TB |
| 7 | **Mộc thuẫn** | Golem | 600 | 45–50 | 25 | 3 | 1 | Nặng | +20 thủ khi bị đánh xa. **Không bị Cháy** (rơm tẩm nước). Không chiếm | Cao |
| 8 | **Thần công** | Catapult | 700 | 60–70 | 5 | 3 | 2–4 | Nặng | **Bắn đứng**. +15 công khi đánh quân đứng trên đồn, thành, doanh trại | TB |
| 9 | **Voi chiến** | Wyvern | 1000 | 70–80 | 20 | 4 | 1 | Voi | **Xung phong**: bỏ qua vùng khống chế; đã đi ≥ 3 ô trong lượt thì +10 công. +10 công khi đánh bộ binh thường | **Cao** |
| — | **Hàng binh** | Skeleton | — | 40–45 | 5 | 4 | 1 | Bộ | Sinh ra từ chiêu hàng, bắt đầu 50 máu. Chiếm làng | TB |

Ghi chú vai:
- **Voi chiến** không bay như Wyvern. Giữ vai "quân mạnh nhất, đắt nhất" nhưng bỏ tốc độ bay vì sử liệu tả voi mạnh mà chậm.
- **Hỏa mai thủ** thay nỏ thủ của bản nháp: không nguồn nào nhắc nỏ trong chiến dịch; có ghi chép người châu Âu về súng hỏa mai.
- **Quân sư** thay phù thủy gọi xương (xem [02 mục 8](02-luat-choi.md#8-quân-tan-và-chiêu-hàng-đổi-so-với-mộ-của-ae2)).
- **Trống trận** là vai sáng tạo; có trống trận thời Tây Sơn ở bảo tàng nhưng không có ghi chép riêng cho năm 1789.
  Codex phải ghi nhãn *Sáng tạo của game*.
- Biến thể **voi chở pháo** (theo nguồn Thanh thế kỷ 19) để dành, có thể thêm sau 1.0.

## 2. Quân Thanh và quân Lê

Quân Thanh dựng theo quy chế Lục doanh: cứ 1.000 lính có 600 điểu thương, 200 cung tiễn, 100 đằng bài, 100 pháo thủ.
Không có kỵ binh, không có Bát kỳ (không có nguồn).

| # | Tên | Phe | Giá | Công | Thủ | Di | Tầm | Kiểu | Đặc tính |
|---|---|---|---|---|---|---|---|---|---|
| 1 | **Trường mâu binh** | Thanh | 150 | 45–50 | 5 | 4 | 1 | Bộ | Chiếm làng. +15 công khi đánh voi (thương có tua đỏ) |
| 2 | **Điểu thương binh** | Thanh | 250 | 50–55 | 5 | 4 | 1–2 | Bộ | Quân bắn xa chính của phe Thanh |
| 3 | **Cung tiễn binh** | Thanh | 200 | 40–45 | 5 | 4 | 2–3 | Bộ | Không đánh / phản đòn ở cự ly 1 |
| 4 | **Đằng bài binh** | Thanh | 400 | 40–45 | 20 | 4 | 1 | Bộ | +15 thủ khi bị đánh xa (khiên mây) |
| 5 | **Pháo binh** | Thanh | 700 | 60–70 | 5 | 3 | 2–4 | Nặng | Bắn đứng |
| 6 | **Thổ binh Điền Châu** | Thanh | 100 | 40–45 | 5 | 5 | 1 | Bộ | Đi đồi, rừng tre chỉ tốn 1 điểm. Chỉ có ở màn Khương Thượng |
| 7 | **Trinh sát** | Thanh | — | 30–35 | 0 | 6 | 1 | Bộ | Do kịch bản đặt. Chế độ *Chạy*: thoát ra mép bản đồ là báo tin |
| 8 | **Quân Lê** | Lê | 100 | 35–40 | 5 | 4 | 1 | Bộ | Chiếm làng. Giữ đồn tiền tiêu |

## 3. Tướng có tên

Tướng giữ vai "vua" của AE2 khi là tướng chính của màn. Chỉ số tăng theo cấp (02, mục 6).

### Phe Tây Sơn

| Tướng | Màn | Công | Thủ | Di | Kiểu | Kỹ năng riêng | Nguồn |
|---|---|---|---|---|---|---|---|
| **Quang Trung** | 1–9 | 60–70 | 20 | 4 | Voi | **Uy danh**: quân mình trong 8 ô +5 công. Cưỡi voi đốc chiến | Sử Thanh: "tự thúc voi đốc đằng sau" |
| **Ngô Văn Sở** | 0, 3 | 50–60 | 15 | 4 | Bộ | **Thận trọng**: +10 thủ nếu chưa di chuyển trong lượt | Sử liệu |
| **Phan Văn Lân** | 0 | 60–65 | 10 | 5 | Bộ | **Hăng máu**: +10 công khi chủ động đánh, −5 thủ | Sử liệu |
| **Ngô Thì Nhậm** | 0, 3 | 35–40 | 10 | 4 | Bộ | Như quân sư; chiêu hàng tầm 3 | Sử liệu; vai có thể bị HLNTC tô đậm |
| **Đô đốc Long** | 7 | 60–65 | 15 | 5 | Bộ | **Tập kích**: +10 công khi đánh ban đêm | Tên gọi tranh cãi, xem 05 |
| **Đô đốc Bảo** | 8 | 60–70 | 20 | 4 | Voi | **Tượng binh**: voi chiến trong 8 ô +5 thủ | Theo HLNTC |
| **Đô đốc Tuyết**, **Đại đô đốc Lộc** | màn phụ | 50–60 | 15 | 5 | Thủy | **Thủy quân**: thủy binh trong 8 ô +1 di chuyển | Lộ trình theo HLNTC |

### Phe Thanh và Lê

| Tướng | Màn | Công | Thủ | Di | Kỹ năng riêng | Ghi chú |
|---|---|---|---|---|---|---|
| **Tôn Sĩ Nghị** | 9 | 55–65 | 20 | 4 | **Thống soái**: quân Thanh trong 8 ô +5 công | Chỉ ra trận ở màn 9; các màn trước ông ở Thăng Long |
| **Hứa Thế Hanh** | 8, 9 | 60–70 | 20 | 4 | **Chặn hậu**: +10 thủ khi đứng trên cầu, đê, bến | Tướng đáng kính, chết khi chặn hậu (sử Thanh) |
| **Sầm Nghi Đống** | 7 | 50–60 | 15 | 4 | **Tử thủ**: +10 thủ khi đứng trên đồn | Thổ quan người Tráng |
| **Trương Triều Long**, **Thượng Duy Thăng** | 8, 9 | 55–60 | 15 | 4 | — | Tổng binh |
| **Quan giữ đồn** (không tên) | 4, 5, 6 | 50–55 | 15 | 4 | — | Không rõ tên tướng giữ các đồn này; không đặt tên bịa |

## 4. Bảng khắc chế tóm tắt

| Bên đánh → bên bị đánh | Hiệu ứng |
|---|---|
| Lính giáo → Voi | +10 công |
| Trường mâu → Voi | +15 công |
| Hỏa hổ → Voi, quân trong doanh trại | +10 công, gây Cháy |
| Voi → bộ binh thường (lính giáo, trường mâu, thổ binh, quân Lê, hàng binh) | +10 công |
| Thần công / pháo → quân trên đồn, thành, doanh trại | +15 công |
| Đánh xa (hỏa mai, điểu thương, cung, pháo, thần công) → Mộc thuẫn | Mộc thuẫn +20 thủ |
| Đánh xa → Đằng bài | Đằng bài +15 thủ |
| Mọi quân → quân đang ngủ | +15 công, không bị phản đòn |

Vòng khắc chế chính: **voi** thắng bộ binh, **giáo/mâu** chặn voi, **mộc thuẫn** chịu súng, **hỏa hổ** đốt voi và doanh trại,
**thần công** phá quân trong đồn.

## 5. Địa hình

Chi phí di chuyển theo kiểu: Bộ / Nặng / Voi / Thủy. "—" là không vào được.

| Địa hình | Bộ | Nặng | Voi | Thủy | Thủ | Ghi chú |
|---|---|---|---|---|---|---|
| Cỏ, đất trống | 1 | 1 | 1 | 2 | 0 | |
| Đường đất | 1 | 1 | 1 | 2 | 0 | Đường thiên lý chạy dọc các màn 4–9 |
| Đê | 1 | 1 | 1 | 2 | +5 | Đê Yên Duyên (màn 8) |
| Ruộng (ruộng nước mùa đông) | 2 | 3 | 2 | 2 | 0 | Lầy, chậm |
| Vườn, cây đào | 1 | 2 | 2 | 2 | +5 | Cây đào là không khí Tết (sáng tạo) |
| Rừng tre, lũy tre | 2 | 3 | 3 | 3 | +10 | Thổ binh: 1 |
| Đồi, gò | 2 | 3 | 2 | 3 | +10 | Thổ binh: 1. Gò cao ở Hà Hồi, Loa Sơn |
| Núi đá vôi | — | — | — | — | — | Tam Điệp; làm biên bản đồ |
| Sông | — | — | — | 1 | +5 | |
| Sông cạn, bến đò | 3 | — | 3 | 1 | −5 | Vượt sông Gián (màn 4) |
| Cầu | 1 | 1 | 1 | 1 | 0 | |
| Cầu phao | 1 | 2 | 2 | 1 | 0 | Đứt theo kịch bản (màn 9) |
| Đầm lầy | 3 | — | 3 | 1 | −5 | Đầm Mực (màn 8) |
| Làng | 1 | 1 | 1 | 2 | +10 | +30 vàng/lượt, hồi máu |
| Doanh trại (lều trại) | 1 | 1 | 1 | 2 | +5 | Cháy được |
| Lũy đất | 2 | 3 | 3 | — | +10 | Vòng ngoài các đồn |
| Đồn | 1 | 1 | 1 | 2 | +15 | +50 vàng/lượt, hồi máu, mua lính |
| Thành | 1 | 1 | 1 | 2 | +20 | Thăng Long, Phú Xuân |

## 6. Mở khóa lính theo chiến dịch

| Màn | Mở thêm cho người chơi | Ghi chú |
|---|---|---|
| 0 | Lính giáo, hỏa mai thủ (không mua, có sẵn) | Mở đầu, quân Ngô Văn Sở |
| 1 | Mua lính giáo, hỏa mai thủ | Hướng dẫn |
| 2 | Quân sư, trống trận, voi chiến | Tuyển quân ở Nghệ An: "10 vạn quân, hơn 200 voi" |
| 3 | (không có trận) Chọn đạo quân | |
| 4 | Thủy binh, hỏa hổ | Vượt sông Gián, đánh đêm |
| 6 | Thần công | Thu khí giới ở Hà Hồi |
| 8 | Mộc thuẫn | Ván ghép phủ rơm chuẩn bị cho Ngọc Hồi |
