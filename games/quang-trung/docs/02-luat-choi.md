# 02 — Luật chơi

> Đặc tả luật để lập trình. Mọi con số cụ thể (chỉ số lính, giá, địa hình) nằm ở
> [03-don-vi-dia-hinh.md](03-don-vi-dia-hinh.md); ở đây chỉ có công thức và quy tắc.
> Chỗ nào **khác AE2** được đánh dấu **[đổi]** kèm lý do.

## 1. Bản đồ

- Lưới ô vuông, mỗi ô 32x32 px. Đi 4 hướng (không đi chéo), khoảng cách tính theo Manhattan.
- Kích thước: rộng 9–16 ô, cao 12–28 ô. Màn hình hiện ít nhất 9 cột; bản đồ lớn hơn thì kéo để cuộn.
- Mỗi ô có một loại địa hình và tối đa một quân. Một số ô có thêm **vật thể**: chông sắt, địa lôi (ẩn),
  quân tan (xem mục 8), lửa.
- Ba phe: **Tây Sơn** (người chơi), **Thanh**, **Lê** (đồng minh của Thanh; máy điều khiển, đi sau quân Thanh).
  Ngoài ra có phe **trung lập** cho làng chưa ai chiếm.

## 2. Lượt chơi

1. **Đầu lượt** của một phe, theo thứ tự:
   - Cộng vàng: mỗi làng +30, mỗi đồn/thành +50.
   - Hồi máu: quân đứng trên làng/đồn/thành **của phe mình** hồi 20 máu (không vượt quá 100) và hết trạng thái *Cháy*.
   - Áp trạng thái (*Cháy* trừ máu, v.v.).
   - Quân tan của phe **kia** quá hạn thì biến mất.
2. **Hành động**: người chơi chọn từng quân, theo thứ tự tùy ý. Mỗi quân làm được:
   - **Di chuyển** (một lần, có thể đứng yên), rồi
   - **Một hành động**: Đánh / Chiếm / Chiêu hàng / Mua lính (chỉ tướng) / Chờ.
   - Trước khi chọn hành động, được **hoàn tác** bước di chuyển.
   - Xong hành động, quân chuyển sang màu xám đến hết lượt.
3. **Kết thúc lượt**: người chơi bấm "Hết lượt". Nếu còn quân chưa đi thì hỏi xác nhận.
4. Thứ tự phe: Tây Sơn → Thanh → Lê → (lượt mới). Đếm lượt theo lượt của Tây Sơn.

## 3. Di chuyển

- Mỗi quân có **điểm di chuyển** (Di) và một **kiểu di chuyển**: *Bộ*, *Nặng*, *Voi*, *Thủy*.
  Chi phí vào từng loại ô tính theo kiểu di chuyển (bảng ở 03). Ô có chi phí "—" thì không vào được.
- Tìm ô đi được: Dijkstra từ vị trí quân, tổng chi phí ≤ Di.
- Đi xuyên qua quân **cùng phe** được, nhưng không dừng trên ô đã có quân.
- **Không** đi xuyên qua quân địch.
- **Vùng khống chế [đổi]**: bước vào ô **kề** quân địch thì phải dừng lại. Lý do: màn hình nhỏ cần
  chiến tuyến rõ, và làm mộc thuẫn / đằng bài có ý nghĩa chặn đường. Voi chiến bỏ qua luật này (xem *Xung phong*).
- Quân đã di chuyển hiện mũi tên đường đi; chạm ô đích lần hai để xác nhận.

## 4. Đánh

### 4.1. Tầm đánh

- Mỗi quân có tầm `[tầm_min, tầm_max]`. Cận chiến là `[1,1]`, hỏa mai `[1,2]`, thần công `[2,4]`.
- Quân có cờ **"bắn đứng"** (thần công, pháo binh) không được đánh trong lượt đã di chuyển.

### 4.2. Công thức sát thương

```
công  = random_int(công_min, công_max) + cộng_công
thủ   = thủ_gốc + thủ_địa_hình + cộng_thủ
sát_thương = max(0, công − thủ) × máu_người_đánh / 100      (làm tròn xuống, tối thiểu 1 nếu công > thủ)
```

- `cộng_công`: cấp bậc, hào quang trống trận, khắc chế (bảng ở 03), *Bất ngờ* (đánh quân đang ngủ).
- `cộng_thủ`: cấp bậc, khắc chế phòng thủ (mộc thuẫn chống đánh xa), trừ đi khi bị *Cháy*.
- Máu tối đa của mọi quân là **100**. Máu về 0 thì quân bị hạ.
- Quân không đứng trên đất liền (ví dụ thủy binh dưới sông) chỉ nhận thủ địa hình của ô đó theo bảng.

### 4.3. Phản đòn

- Nếu quân bị đánh **còn sống** và người đánh nằm trong tầm của nó, nó **phản đòn ngay**, tính bằng máu còn lại của nó.
- Quân "bắn đứng" không phản đòn ở cự ly 1. Quân đang **ngủ** không phản đòn.
- Mỗi lần đánh chỉ có một lần phản đòn.

### 4.4. Dự báo [đổi]

Chạm vào quân địch trong tầm sẽ hiện **dự báo**: khoảng sát thương gây ra, khoảng phản đòn nhận lại, và xác suất hạ.
AE2 không có tính năng này. Thêm vào vì người chơi điện thoại cần ra quyết định nhanh mà không phải nhớ bảng số.

### 4.5. Ngẫu nhiên

- Dùng một bộ sinh số ngẫu nhiên có seed, lưu trong file save. Tải lại save thì kết quả không đổi
  (chống "load lại cho đến khi trúng").
- Seed của mỗi màn được sinh lúc bắt đầu màn.

## 5. Kinh tế và mua lính

- Mỗi màn có **vàng khởi đầu** và **giới hạn quân** riêng (ghi ở 04).
- **Chiếm**: lính giáo, hàng binh và tướng chiếm được **làng**. Chỉ **tướng** chiếm được **đồn/thành**.
  Chiếm là hành động, xong ngay (giống AE2). Ô chiếm được phải không có quân địch đứng trên.
- **Mua lính**: tướng đang đứng trên **đồn/thành của phe mình** chọn "Mua lính" → chọn loại → đặt quân vào
  một ô trống **kề** đồn/thành đó. Quân mới mua không hành động được trong lượt mua. Tướng mua xong vẫn còn
  đứng nguyên chỗ và kết thúc lượt của mình.
- Danh sách lính mua được **mở dần theo chiến dịch** (ghi ở 04), không phải mọi màn đều có đủ 10 loại.

## 6. Cấp bậc

- Quân nhận **kinh nghiệm (KN)** = sát thương gây ra (cả khi phản đòn) + 30 nếu hạ được địch.
- Mốc lên cấp: **100 / 250 / 450 / 700** KN, tối đa **cấp 4**.
- Mỗi cấp: **+5 công, +4 thủ**. Lên cấp hồi 10 máu (khoảnh khắc thưởng).
- Tướng có tên giữ cấp qua các màn; lính thường không mang sang màn sau.

## 7. Tướng

- **Quang Trung** là "vua" của phe Tây Sơn như Galamar trong AE2. Các màn không có ông thì một tướng khác
  (Ngô Văn Sở, Đô đốc Long, Đô đốc Bảo...) giữ vai này.
- Tướng **không mua được**. Tướng của người chơi về 0 máu thì **thua màn [đổi]**.
  AE2 cho mua lại vua; ở đây tướng là người thật, nên không "hồi sinh". Tướng phụ có tên (không phải tướng chính)
  về 0 máu thì **rút lui bị thương**: rời bản đồ, màn vẫn tiếp tục, không chết trong cốt truyện.
- Tướng địch có tên về 0 máu: hiện câu thoại, rời bản đồ. Cái chết của họ chỉ được thể hiện **đúng như sử liệu**
  (Sầm Nghi Đống tự vẫn, Hứa Thế Hanh chết khi chặn hậu) trong hội thoại, không phải trong hoạt cảnh chiến đấu.

## 8. Quân tan và chiêu hàng [đổi so với "mộ" của AE2]

AE2: quân chết để lại **mộ**, phù thủy gọi **bộ xương** từ mộ. Game này đổi thành chiêu hàng, dựa trên việc đồn
Hà Hồi đầu hàng sau khi bị gọi hàng và quân Tây Sơn bắt hơn 3.400 tù binh.

- Quân thường của Thanh/Lê bị hạ để lại **quân tan** (cờ rách, vũ khí vứt lại) trên ô đó, tồn tại **2 lượt**.
- **Quân sư** đứng cách quân tan ≤ 2 ô dùng **Chiêu hàng** → quân tan thành **hàng binh** (phe Tây Sơn,
  50 máu, đi được từ lượt sau). Hàng binh tính vào giới hạn quân.
- Quân tan làm ô đó **không đi vào được** cho đến khi biến mất hoặc được chiêu hàng (giống mộ trong AE2).
- Quân Tây Sơn bị hạ **không** để lại gì. Không có cơ chế liên quan đến xác người chết.

## 9. Trạng thái

| Trạng thái | Do đâu | Hiệu ứng | Hết khi |
|---|---|---|---|
| **Cháy** | Hỏa hổ đánh trúng; đứng trên ô lửa | −10 máu đầu mỗi lượt của phe đó (không xuống dưới 1), −5 thủ | 2 lượt, hoặc hồi máu ở làng/đồn/thành |
| **Hào quang** | Đứng trong 8 ô quanh trống trận | +10 công | Rời khỏi vùng |
| **Uy danh** | Đứng trong 8 ô quanh Quang Trung | +5 công (không cộng dồn với chính nó) | Rời khỏi vùng |
| **Ngủ** | Quân địch trong màn đêm, lúc bắt đầu màn | Không phản đòn, bị đánh nhận +15 công (*Bất ngờ*). Không di chuyển | Bị đánh (sau đòn đó); có báo động; trời sáng |

## 10. Đêm và sương mù

Dùng cho các màn đêm 30 Tết (Gián Khẩu), đêm mùng 3 (Hà Hồi), đêm mùng 4 rạng mùng 5 (Khương Thượng).

- **Tầm nhìn**: mỗi quân Tây Sơn thấy 2 ô quanh nó (Manhattan); quân cầm đuốc 3 ô. Ô có nguồn sáng
  (đuốc ở đồn, đèn trong làng, lửa) và các ô kề nó luôn thấy được.
- Ô ngoài tầm nhìn bị phủ tối: thấy địa hình nhưng không thấy quân địch.
- **Báo động**: khi một quân địch còn sống sau khi bị đánh, hoặc thấy quân Tây Sơn đứng kề trong vùng sáng,
  mọi quân địch trong bán kính 5 ô thức dậy. Một số màn có **trống báo động** (vật thể) làm cả đồn thức dậy.
- **Trời sáng**: màn có nhiều lượt ban đêm thì có lượt "rạng sáng" (ghi ở 04): sương mù giảm dần rồi tắt,
  mọi quân thức dậy.
- AE2 không có đánh đêm. Đây là phần mở rộng lớn nhất **[đổi]**, bắt buộc theo yêu cầu "màn đánh đêm Tết".

## 11. Vây đồn

Cơ chế riêng cho màn Hà Hồi, dùng lại được ở màn khác.

- Một **đồn bị vây** khi mọi ô đi được kề đồn đều có quân Tây Sơn hoặc bị chặn.
- Đầu lượt của Tây Sơn, nếu đồn bị vây và có **quân sư hoặc tướng** kề đồn, thì có thể chọn **Gọi hàng**:
  quân trong đồn đầu hàng nếu tổng máu quân địch trong đồn ≤ tổng máu quân Tây Sơn đang vây.
  Quân đầu hàng biến thành quân tan (chiêu hàng được), đồn đổi sang trung lập để tướng chiếm.

## 12. Bẫy và vật thể

| Vật thể | Hiệu ứng |
|---|---|
| **Chông sắt** | Hiện rõ. Bước vào: dừng lại, −15 máu. Mộc thuẫn và voi bị −5 máu |
| **Địa lôi** | Ẩn cho đến khi giẫm phải hoặc quân sư đứng kề. Giẫm: −30 máu, mất 1 lần. Quân Thanh cũng bị (theo *Liệt truyện*, quân Thanh tháo chạy giẫm phải địa lôi của mình) |
| **Lửa** | Ô đang cháy: vào thì bị *Cháy*. Lửa lan sang ô *doanh trại* kề 1 lần mỗi lượt, tắt sau 3 lượt |
| **Quân tan** | Mục 8 |
| **Cầu phao** | Đi như cầu. Màn 9 có sự kiện: cầu đứt ở lượt định sẵn, quân đứng trên cầu rơi xuống sông và bị hạ |

## 13. Thắng thua

Mỗi màn có:
- **Điều kiện thắng** chính, ví dụ: chiếm đồn X, hạ tướng Y, giữ quân sống đến lượt N, đưa tướng tới ô Z.
- **Điều kiện thua**: tướng chính bị hạ, hết số lượt tối đa (nếu có), hoặc điều kiện riêng.
- **Mục tiêu phụ** (0–3, không bắt buộc): ví dụ thắng trước lượt N ("kịp mùng 7"), không mất quân, chiêu hàng ≥ N quân.
  Mục tiêu phụ mở mục Sử liệu, không cho sức mạnh (để không phá cân bằng).

## 14. Trí tuệ máy (AI)

- Mỗi quân máy lần lượt chấm điểm mọi cặp *(ô đứng, hành động)* trong tầm và chọn điểm cao nhất:
  - Đánh: sát thương dự kiến gây ra × hệ số giá trị mục tiêu − sát thương phản đòn dự kiến; thưởng lớn nếu hạ được.
  - Chiếm: giá trị làng/đồn; ưu tiên chiếm lại của mình.
  - Đứng: thủ địa hình, khoảng cách tới mục tiêu chiến lược của màn, nguy hiểm (tổng sát thương địch có thể gây ở lượt sau).
- Mỗi quân có **chế độ** do kịch bản màn đặt: *Giữ đồn* (không rời bán kính R), *Tấn công* (tiến về mục tiêu),
  *Chạy* (tránh giao chiến, về ô Z; dùng cho trinh sát, tàn quân).
- Quân đang ngủ không làm gì.
- Máy mua lính nếu màn cho phép, theo danh sách và ngân sách của màn.
- Mục tiêu: máy không gian lận (không thấy qua sương mù trong màn đêm cho phe Thanh trừ khi đã báo động).
