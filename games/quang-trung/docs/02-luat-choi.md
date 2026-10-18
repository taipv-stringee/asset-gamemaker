# 02 — Luật chơi

> Đặc tả luật để lập trình. Con số (chỉ số lính, giá, địa hình, thẻ) ở [03-don-vi-dia-hinh.md](03-don-vi-dia-hinh.md);
> dữ liệu từng màn ở [04-chien-dich.md](04-chien-dich.md). Chỗ nào **khác Ancient Empires 2** được đánh dấu **[đổi]**;
> bảng đối chiếu từng con số với AE2 ở [10-doi-chieu-ae2.md](10-doi-chieu-ae2.md).
>
> Quy ước: mọi phép tính là **số nguyên**. "Lượt" là lượt của một phe; "vòng" gồm lượt của mọi phe theo thứ tự.
> "8 ô quanh" = khoảng cách Chebyshev 1. "Khoảng cách" không nói gì thêm = Manhattan.

## 1. Bản đồ và phe

- Lưới ô vuông 32 × 32 px. Đi 4 hướng, không đi chéo.
- Kích thước 9–16 cột × 12–28 hàng. Màn hình thấy được 9–13 cột tùy máy (xem 06); bản đồ rộng hơn thì kéo để cuộn.
- Mỗi ô có **một địa hình**, tối đa **một quân**, và có thể có **một vật thể** (mục 12).
- Một số ô gom thành **khu** do kịch bản đánh dấu: khu đồn (mục 11), vùng thắng, vùng thoát của trinh sát, lối viện binh.
- Phe, theo thứ tự đi trong một vòng:

| Phe | Ai điều khiển | Quan hệ |
|---|---|---|
| **Tây Sơn** | Người chơi | — |
| **Diễn tập** | Máy | Đối thủ của Tây Sơn, chỉ có ở màn 1–2 (trận diễn tập, *Sáng tạo của game*) |
| **Thanh** | Máy | Đối thủ của Tây Sơn; đồng minh của Lê |
| **Lê** | Máy | Đối thủ của Tây Sơn; đồng minh của Thanh |
| Trung lập | — | Chỉ là chủ của làng / đồn chưa ai chiếm |

Đồng minh đi xuyên qua nhau được, không tạo vùng khống chế cho nhau, dùng chung làng / đồn để hồi máu.

## 2. Vòng chơi

1. **Đầu lượt** của mỗi phe, theo thứ tự:
   1. Cộng vàng: mỗi làng của phe +30, mỗi đồn / thành +50 (không cộng cho phe không mua lính trong màn).
   2. Hồi máu: quân đứng trên làng / đồn / thành của phe mình **hoặc đồng minh** hồi 20 máu (tối đa 100).
   3. Hết hạn trạng thái của phe đó (mục 9). Xử lý báo động (mục 10) nếu là lượt Thanh / Lê.
   4. Quân tan hết hạn thì biến mất (mục 8).
2. **Hành động**: chọn từng quân theo thứ tự tùy ý. Mỗi quân: **di chuyển** (một lần, có thể đứng yên) rồi **một hành động**
   — Đánh, Chiếm, Chiêu hàng, Gọi hàng, Đốt, Chờ. Mua lính là thao tác trên ô đồn, không phải hành động của quân (mục 5).
   - Trước khi chọn hành động được **hoàn tác** bước đi, **trừ khi** bước đi đó đã làm lộ thông tin mới (sương mù, địa lôi, quân ẩn),
     giẫm bẫy, hoặc đánh thức địch.
   - Xong hành động, quân xám đến hết lượt.
3. **Hết lượt**: người chơi bấm "Hết lượt" (hỏi xác nhận nếu còn quân chưa đi).
4. **Vòng và lượt** (quy ước chữ trong game, phản hồi M3): **vòng** = mọi phe đi một lần; **lượt** = phần đi của một phe trong vòng.
   Vòng 1 bắt đầu bằng lượt Tây Sơn đầu tiên. Thanh trên ghi số vòng; số trong mục tiêu, giới hạn, thu nhập đều tính theo vòng.
   - "Thắng **trước vòng N**" = đạt điều kiện trong vòng có số ≤ N − 1 (loại mục tiêu `truoc_vong`).
   - "**Hết vòng N**" (điều kiện thua) = cuối vòng N (sau lượt phe cuối cùng) mà chưa thắng.

## 3. Di chuyển

- Mỗi quân có **Di** (điểm di chuyển) và **kiểu di chuyển**: *Bộ*, *Nặng*, *Voi*, *Thủy*. Chi phí vào ô theo kiểu (bảng 03).
- Ô đi được: Dijkstra từ vị trí quân, tổng chi phí ≤ Di.
- Đi xuyên qua quân **cùng phe / đồng minh**; không dừng trên ô có quân. Không đi xuyên quân địch, không vào ô có quân tan.
- **Vùng khống chế [đổi]**: quân có thẻ `chan` (cận chiến đứng chặn) khống chế 4 ô kề nó. Quân đối phương **bước vào** một ô
  bị khống chế thì phải dừng ở đó. Quân bắt đầu lượt trong vùng vẫn đi được, nhưng ô đầu tiên nó vào mà bị khống chế thì dừng.
  - Quân đang ngủ vẫn khống chế. Quân bị sương che vẫn khống chế; khi đó quân bị dừng lại phát hiện ra nó ("phục kích")
    và không được hoàn tác.
  - Quân có thẻ `xung_phong` (voi chiến) bỏ qua vùng khống chế.
  - Lý do đổi: màn hình nhỏ cần chiến tuyến rõ; chỉ quân cận chiến mới chặn để quân bắn xa không quá mạnh.

## 4. Đánh

### 4.1. Tầm và điều kiện

- Tầm `[tầm_min, tầm_max]` theo Manhattan. Chỉ chọn được mục tiêu **đang thấy** (đêm, mục 10).
- Quân có thẻ `ban_dung` (thần công, pháo binh) không đánh trong lượt đã di chuyển, và **không bao giờ phản đòn**.

### 4.2. Công thức

```
công = random_int_bao_gom_hai_dau(công_min, công_max) + Σ cộng_công
thủ  = thủ_gốc + thủ_địa_hình + Σ cộng_thủ
st   = (max(0, công − thủ) × máu_người_đánh) // 100
st   = max(st, công // 10)            # sàn sát thương: luôn gây ít nhất 10% công
máu_bị_đánh = max(0, máu_bị_đánh − st)
```

- `Σ cộng_công`: cấp bậc, khắc chế (bảng 03), Hào quang + Uy danh (**tổng tối đa +10**), Xung phong, Hăng máu, Bất ngờ, trừ khi bị Cháy.
- `Σ cộng_thủ`: cấp bậc, khắc chế phòng thủ (mộc thuẫn, đằng bài khi bị đánh xa), Thận trọng, Chặn hậu, Tử thủ; trừ khi bị Cháy / Hăng máu.
- "Đánh xa" xác định theo **loại quân** có thẻ `ban_xa`, kể cả khi bắn ở cự ly 1.
- Máu tối đa của mọi quân là 100. Máu 0 thì bị hạ (trừ thẻ `toi_thieu_1`, mục 7).

### 4.3. Phản đòn

- Quân bị đánh **còn sống** và người đánh trong tầm của nó thì phản đòn ngay, tính bằng máu còn lại.
- Không phản đòn: quân `ban_dung`; quân đang ngủ; cung tiễn khi bị đánh ở cự ly 1.
- Phản đòn được hưởng: khắc chế, Hào quang / Uy danh, cấp, thủ địa hình. **Không** được: Xung phong, Hăng máu, Bất ngờ.
- Phản đòn của hỏa hổ cũng gây Cháy.

### 4.4. Dự báo [đổi]

Chạm quân địch trong tầm → hiện khoảng sát thương gây ra, khoảng phản đòn nhận lại, % hạ. AE2 không có; thêm vì người chơi
điện thoại cần quyết nhanh. Hàm dự báo dùng đúng công thức 4.2 với mọi giá trị công trong khoảng.

### 4.5. Ngẫu nhiên

- Mỗi màn có `seed` sinh lúc bắt đầu, lưu trong file save.
- Số ngẫu nhiên của một đòn lấy từ `hash(seed, số_vòng, id_người_đánh, id_bị_đánh, số_lần_đánh_trong_vòng)` — thứ tự hành động
  khác nhau không làm đổi kết quả, tải lại save không "quay lại" được kết quả khác.

## 5. Kinh tế và mua lính

- Mỗi màn ghi rõ: **vàng khởi đầu**, **giới hạn quân**, **nơi mua lính**, **danh sách lính mua được** (`mua_duoc`). Màn không có nơi mua
  thì không có vàng.
- **Mua lính [giống AE2]**: chọn một **đồn / thành của phe mình đang trống** → chọn loại → quân xuất hiện **ngay trên ô đồn**, xám đến hết lượt.
  Không cần tướng đứng ở đó. Loại không đủ vàng, hoặc giới hạn đã đầy, thì mờ.
- **Giới hạn quân** tính mọi quân phe mình, kể cả tướng và hàng binh, **trừ** quân do kịch bản đưa vào (viện binh).
- **Chiếm** (hành động): quân có thẻ `chiem_lang` chiếm được **làng**; quân có thẻ `tuong` chiếm được **đồn / thành**. Ô phải đang đứng trên,
  không phải của phe mình hoặc đồng minh. Chiếm xong ngay.
- Thần công **không** phá làng **[đổi]** (AE2: Catapult phá được làng) — không cho phá làng dân.

## 6. Cấp bậc

- Kinh nghiệm (KN) = sát thương gây ra (kể cả phản đòn) + 30 nếu hạ được địch. Cộng **sau khi xong cả đòn và phản đòn**.
- Mốc: **100 / 250 / 450 / 700** KN → cấp 1–4 (tối đa).
- Mỗi cấp: **+3 công, +2 thủ**. Lên cấp hồi ngay 10 máu.
- Tướng có tên **giữ cấp và KN qua các màn** của lượt chơi chiến dịch chính. Đầu mỗi màn lưu ảnh chụp cấp tướng; chơi lại màn cũ
  dùng ảnh chụp đó và không ghi đè tiến trình. Lính thường không mang sang màn sau (trừ màn 9, xem 04).
- AE2 cũng có kinh nghiệm và cấp, nhưng con số cụ thể chưa xác minh được (xem 10).

## 7. Tướng

- Thẻ `tuong`: chiếm được đồn / thành, có kỹ năng riêng. Mỗi màn chỉ định **tướng chính** cho phe Tây Sơn.
- Tướng chính về 0 máu → **thua màn [đổi]** (AE2: hồi sinh vua ở castle). Tướng là người thật nên không "hồi sinh".
- Tướng phụ phe Tây Sơn về 0 máu → **rút lui bị thương**: rời bản đồ, không chết trong cốt truyện.
- Tướng địch có tên: kịch bản gán một trong các thẻ:
  - `toi_thieu_1`: máu không xuống dưới 1 trong màn đó (vd. Tôn Sĩ Nghị ở màn 9).
  - `rut_khi_yeu X`: còn sống sau một đòn mà máu < X thì chuyển sang chế độ AI *Rút lui*; đòn đủ hạ thì vẫn bị hạ. Tướng không được
    chết trong màn (vd. ba tướng Thanh ở màn 8, sang màn 9) thì kèm `toi_thieu_1`. Quân rút lui tới khu `khu_rut_lui` của màn thì rời bản đồ.
  - Không thẻ: bị hạ bình thường, hiện câu thoại rồi rời bản đồ.
- Cái chết của tướng có tên chỉ được kể **theo các phiên bản trong nguồn**, trong hội thoại và Sử liệu, không trong hoạt cảnh.

## 8. Quân tan và chiêu hàng [thay "mộ" và "gọi xương" của AE2]

AE2: quân chết để lại mộ khoảng 1 lượt, Sorceress đứng kề mộ gọi Skeleton. Game này giữ nhịp đó nhưng đổi hình thức để không
động tới người chết, lấy cảm hứng từ cảnh đồn Hà Hồi ra hàng (*Theo HLNTC*).

- Quân thường của Thanh / Lê bị hạ để lại **quân tan** (cờ rách, vũ khí vứt) trên ô đó. Tướng, quân phe Diễn tập, quân Tây Sơn không để lại gì.
  Không sinh quân tan trên cầu, cầu phao, sông, đầm lầy (quân bị hạ ở đó coi như chạy mất), và trên đồn, thành (quân giữ đồn tan chạy khỏi đồn, để ô mục tiêu luôn chiếm được ngay).
- Quân tan sinh ra trong vòng N **biến mất đầu lượt Tây Sơn của vòng N + 2** (tức còn đến hết lượt Tây Sơn kế tiếp).
- Quân tan chặn di chuyển của mọi phe, chặn chiếm làng, chặn mua lính trên ô đó; không chặn đường bắn.
- **Chiêu hàng** (hành động của quân có thẻ `chieu_hang`: quân sư): đứng **kề** quân tan → quân tan thành
  **hàng binh** của Tây Sơn ngay trên ô đó (máu 50/100, cấp 0, xám đến hết lượt). Giới hạn quân đầy thì không chiêu hàng được.

## 9. Trạng thái

| Trạng thái | Do đâu | Hiệu ứng | Hết khi |
|---|---|---|---|
| **Cháy** [giống độc của AE2] | Hỏa hổ đánh hoặc phản đòn trúng; đứng trên ô lửa | **Từ lúc bị Cháy đến hết lượt kế tiếp** của phe quân đó: −1 Di, −10 công, −10 thủ. Không mất máu theo lượt | Cuối lượt kế tiếp của phe quân đó. Bị Cháy lại thì đặt lại thời hạn, không cộng dồn. Mộc thuẫn không bị Cháy |
| **Hào quang** | Đứng trong 8 ô quanh trống trận (không tính chính trống) | +10 công | Tính lúc ra đòn. Nhiều trống không cộng dồn |
| **Uy danh** | Đứng trong 8 ô quanh Quang Trung (không tính chính ông) | +5 công | Như trên. Hào quang + Uy danh ≤ +10 |
| **Ngủ** | Kịch bản đặt cho quân địch ở màn đêm | Không di chuyển, không thấy, không phản đòn; bị đánh nhận **Bất ngờ** +15 công | Bị đánh (sau đòn đó); báo động; trời sáng |
| **Kêu** | Quân địch bị đánh mà còn sống, ở màn đêm | Đánh dấu để gây báo động đầu lượt phe nó | Bị hạ trước khi tới lượt phe nó; hoặc đã gây báo động |

Ghi chú: AE2 Dire Wolf gây độc làm quân "chậm và yếu ở lượt kế". Cháy giữ đúng cơ chế đó, chỉ đổi hình thức thành lửa.

## 10. Đêm, sương mù, báo động [đổi — AE2 không có đánh đêm]

Tham số của màn: `tam_nhin` (đêm 2, rạng sáng 3 → 5, ngày = không giới hạn).

- **Tầm nhìn Tây Sơn**: mỗi quân thấy các ô trong `tam_nhin` (Manhattan). Quân có cờ `duoc` (cầm đuốc, do kịch bản đặt) thấy thêm 1 ô
  nhưng chính nó là **nguồn sáng**.
- **Nguồn sáng**: đuốc ở đồn, đèn trong làng, ô lửa, quân cầm đuốc. Ô nguồn sáng và các ô kề nó luôn được thấy (cả hai phe).
- Ô ngoài tầm nhìn: thấy địa hình, không thấy quân địch. Camera trong lượt máy chỉ đi theo quân đang được thấy.
- **Tầm nhìn địch**: quân **thức** thấy quân Tây Sơn trong 2 ô, hoặc quân Tây Sơn đứng trên / kề ô sáng trong 5 ô. Quân ngủ không thấy gì.
- **Báo động**: đầu lượt Thanh / Lê, nếu có quân của phe đó đang *Kêu*, hoặc có quân thức đang thấy quân Tây Sơn, thì mọi quân phe đó
  trong 5 ô quanh nó thức dậy; quân *Ngủ* / *Tuần tra* chuyển sang *Giữ đồn* (R = 4) quanh đồn gần nhất.
  **Trống báo động** (vật thể gắn với một đồn): nếu quân *Kêu* hoặc quân thức đứng kề trống lúc báo động, **cả khu đồn** thức.
  → Hai quân phối hợp hạ gọn một mục tiêu trong cùng lượt thì không gây báo động.
- **Rạng sáng** (màn có lượt R ghi trong 04): đầu vòng R mọi quân thức, `tam_nhin` = 3; vòng R + 1 = 5; từ vòng R + 2 tắt sương mù.

## 11. Khu đồn, vây đồn, gọi hàng

- **Khu đồn**: tập ô kịch bản đánh dấu (`khu_don_<id>`), gồm ô đồn và các ô lũy / doanh bên trong.
- **Bị vây** khi mọi ô đi được **kề ngoài** khu đồn đều: có quân Tây Sơn, hoặc không vào được (sông, ao, ô có quân tan), hoặc nằm trong
  vùng khống chế của quân Tây Sơn. Trong trận, ô kề ngoài còn hở có dấu × đỏ; chạm ô trong khu thì thấy "đã bị vây / còn N ô hở".
- **Gọi hàng** (hành động của quân có thẻ `goi_hang`: quân sư, tướng) đứng kề khu đồn đang bị vây, mỗi khu một lần mỗi lượt:
  - Thành công nếu `Σ máu quân Tây Sơn trong 2 ô quanh khu ≥ Σ máu quân địch trong khu × k`, với k = 1/2 nếu **quá nửa** quân trong khu
    đang ngủ, k = 1 nếu không. Kết quả tất định nên bấm **Gọi hàng** thì hiện con số trước (ta / cần), rồi mới **Gọi** hay **Thôi**.
    Gọi được ngay sau khi đi (khép vây và gọi trong cùng một lượt).
  - Thành công: mọi quân địch trong khu (kể cả quan giữ đồn) rời bản đồ; Tây Sơn nhận hàng binh trên các ô đó, số lượng
    = min(số quân hàng, chỗ trống trong giới hạn); phần còn lại tính là **tù binh** (chỉ để tính mục tiêu phụ). Đồn chuyển trung lập để tướng chiếm.
    Hàng binh không đứng lên ô đồn: hàng binh của quân trên ô đồn đứng ô trống khác trong khu, không có thì ô kề ngoài khu. Hàng binh 50 máu, xong lượt.
  - Thất bại: không có gì xảy ra, quân gọi hàng hết lượt; nếu quân trong khu đang ngủ thì vẫn ngủ.

## 12. Vật thể và hành động đặc biệt

| Vật thể | Luật |
|---|---|
| **Chông sắt** | Hiện rõ. Bước vào: dừng lại, −15 máu (mộc thuẫn, voi: −5), không Hoàn tác được. Không mất đi. Bị hạ được |
| **Địa lôi** | Ẩn với Tây Sơn cho đến khi giẫm phải hoặc có quân sư đứng kề. Giẫm: −30 máu, dừng lại, mất địa lôi. AI biết và tránh địa lôi của phe mình, **trừ** chế độ *Chạy* / *Rút lui* (theo *Liệt truyện*, quân Thanh tháo chạy giẫm phải địa lôi của mình) |
| **Lửa** | Ô đang cháy (3 vòng). Quân đứng trên / bước vào: Cháy (trừ mộc thuẫn). Hết lửa: ô doanh trại thành "doanh trại cháy" (thủ 0, đi như cỏ) |
| **Kho lương** | Quân `tuong` hoặc `chiem_lang` (lính giáo, hàng binh) của người chơi đứng lên rồi chọn **Lấy kho lương** → cờ mục tiêu phụ, kho mất. Đi qua được |
| **Trống báo động** | Mục 10 |
| **Quân tan** | Mục 8 |
| **Cầu phao** | Đi như cầu. Kịch bản có thể làm **rung** (cảnh báo) rồi **đứt** ở vòng sau: quân trên cầu rơi xuống sông và bị hạ, trừ thủy binh (chuyển sang ô sông gần nhất) |

**Đốt** (hành động của hỏa hổ, thẻ `dot`): chọn một ô doanh trại kề bên (tầm 1, đi rồi vẫn đốt được) không có vật thể (quân tan thì bị lửa
đuổi đi) và không có quân mình → ô đó thành Lửa, quân đốt hết lượt. Lửa cháy 3 vòng (tắt đầu vòng thứ 4, ô thành "doanh trại cháy") và là
nguồn sáng. Quân địch đứng trên ô bị đốt: bị Cháy, thức dậy, và ban đêm thì **kêu** (báo động đầu lượt phe nó). Quân đứng trên ô lửa đầu
lượt phe mình, hoặc đi qua / dừng trên ô lửa: bị Cháy. Máy tránh đứng trên ô lửa.

## 13. Thắng thua

- Mỗi màn có điều kiện thắng, điều kiện thua (luôn gồm "tướng chính bị hạ"), và 0–3 **mục tiêu phụ**.
- Mục tiêu phụ mở mục Sử liệu, không cho sức mạnh.

## 14. AI

- Mỗi quân máy chấm điểm mọi cặp *(ô đứng, hành động)* hợp lệ và chọn điểm cao nhất:
  - Đánh: sát thương dự kiến × giá trị mục tiêu − phản đòn dự kiến; thưởng lớn nếu hạ được.
  - Chiếm: giá trị làng / đồn; ưu tiên chiếm lại của mình.
  - Đứng: thủ địa hình, khoảng cách tới mục tiêu của chế độ, nguy hiểm ở lượt sau.
- **Chế độ** (kịch bản đặt cho từng quân, đổi được giữa màn):

| Chế độ | Hành vi |
|---|---|
| *Ngủ* | Không làm gì (mục 9, 10) |
| *Giữ đồn (R)* | Không rời bán kính R quanh một ô; đánh địch vào tầm |
| *Tuần tra (điểm…)* | Đi vòng qua danh sách điểm; thấy địch → báo động |
| *Tấn công (mục tiêu)* | Tiến về mục tiêu, đánh trên đường |
| *Chặn hậu (ô)* | Như Giữ đồn quanh một ô cầu / đê / bến |
| *Dò thám (vùng, R)* | Đứng / tuần tra, không đánh. Đầu lượt phe nó, thấy quân đối phương trong R ô (mặc định 3; ban đêm phải thấy được) thì đổi sang *Chạy (vùng)* |
| *Chạy (vùng)* | Tránh giao chiến, đi tới vùng; tới nơi thì rời bản đồ (trinh sát: "báo tin"; màn 5: hệ quả sang màn 6) |
| *Rút lui (vùng, X)* | Như Chạy, kích hoạt khi máu < X |

- Máy không nhìn qua sương mù: phe Thanh / Lê chỉ biết quân Tây Sơn mà quân mình đang thấy (mục 10), trừ khi kịch bản cho phép.
- Máy mua lính nếu màn cho phép, theo `mua_duoc` và ngân sách của màn.
- **AI Tây Sơn đơn giản** (chỉ dùng cho kiểm thử): tiến về mục tiêu màn, chiếm đồn mục tiêu, để phát hiện màn bị kẹt.
