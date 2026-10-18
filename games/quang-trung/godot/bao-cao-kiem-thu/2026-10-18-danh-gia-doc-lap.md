# Đánh giá độc lập — chơi cả chiến dịch "Tây Sơn" trên Pixel 3

Ngày 18/10/2026. Người đánh giá: một người chơi độc lập, không tham gia làm game. Bản build: nhánh
`claude/awesome-goodall-ayzwv4`, commit `7231e8a`, bản Android debug xuất bình thường (không sửa gì).

## Kết luận ngắn

Tây Sơn là một game chiến thuật theo lượt **có hồn và có trách nhiệm với lịch sử**. Phần chuyện, nhãn nguồn
([Sử liệu], [Theo HLNTC], [Tương truyền], [Sáng tạo của game]) và mục Sử liệu là điểm mạnh nhất: tôi chưa thấy game Việt nào
làm việc này cẩn thận như vậy, và giọng văn tôn trọng cả hai phía (lễ cầu siêu cho tử sĩ hai bên, Sầm Nghi Đống, Hứa Thế Hanh
được kể như con người). Năm màn đầu (0–4) và màn phụ thủy quân dễ hiểu, trôi, vui. Nhưng **từ màn 5 trở đi độ khó tăng vọt và
cách chơi trở nên mờ**: nhiều luật quan trọng (ai được gọi hàng, cần bao nhiêu "lực vây", thần công không bắn sau khi đi, chông
chặn hai lần, Sầm Nghi Đống hồi máu) chỉ hiểu được sau khi thua. Tôi thua màn 6 hai lần, màn 7 hai lần, bỏ dở màn 8, và phải
sửa file tiến trình để đi tiếp. Thêm vào đó là một lỗi thao tác khá khó chịu: bấm "Đứng yên" xong thì không quay lại được.
Tôi **khuyên chơi** cho người thích lịch sử và chiến thuật, nhưng chưa khuyên phát hành rộng khi các màn 6–8 chưa được làm
rõ và làm mềm lại.

## Bảng tổng hợp từng màn

Thời gian là thời gian thực tôi bỏ ra (gồm cả đọc chuyện). Tôi điều khiển qua adb nên chậm hơn người chơi bằng tay một chút.

| Màn | Số lần chơi | Thắng? | Vòng | Sao | Thời gian | Ấn tượng một dòng |
|---|---|---|---|---|---|---|
| 0 · Rút về Tam Điệp | 1 | Thắng | 4 | ★★ | ~11 phút | Màn hướng dẫn gọn, gợi ý đúng lúc, hơi nhiều bảng bật lên. |
| 1 · Núi Bân | 1 | Thắng | 9 / 15 | ★★ | ~18 phút | Dễ chịu; hỏa mai rất mạnh, lính giáo địch phản đòn đau. |
| 2 · Nghệ An | 1 | Thắng | 8 / 20 | ★☆ | ~21 phút | Ý hay (mời Nguyễn Thiếp, diễn tập), nhưng đoàn voi "diễn tập" xuất hiện đột ngột giết quân sư. |
| 3 · Tam Điệp ăn Tết (chuyện) | — | Đã xem | — | — | ~2 phút | Sa bàn đẹp; chữ chú thích nằm dưới nếp gấp, phải kéo mới thấy. |
| 4 · Đêm 30, sông Gián | 1 | Thắng | 9 / 12 | ★☆☆ | ~22 phút | Đêm và sương mù có không khí; bị báo động mà không biết vì sao. |
| P · Thủy quân (phụ) | 1 | Thắng | 5 / 15 | ★☆ | ~13 phút | Ngắn, gọn, vui; hơi dễ. |
| 5 · Thanh Quyết – Nhật Tảo | 1 | Thắng | 16 / 18 | ☆☆ | ~48 phút | Dài và lê thê (bản đồ 24 hàng, hai đồn liên tiếp); trinh sát thoát mà tôi không hề hay. |
| 6 · Vây Hà Hồi | 2 | **Thua cả 2** | thua vòng 14; bỏ ở vòng 6 | — | ~54 phút | Ý tưởng vây đồn – gọi hàng rất hay, nhưng luật mờ; bản "đồn thức" (do màn 5) quá khó. **Sửa tiến trình để qua.** |
| 7 · Khương Thượng | 2 (lần 2 nạp lại bản lưu vòng 10) | **Thua** | thua vòng 10; bỏ ở vòng 11 | — | ~32 phút | Đốt doanh vui; Đô đốc Long chết trong một lượt vì pháo + Sầm; Sầm hồi máu, không dồn nổi. **Sửa tiến trình để qua.** |
| 8 · Ngọc Hồi | 1 (bỏ dở) | **Không** | bỏ ở vòng 8 / 22 | — | ~20 phút | Hai hàng chông bắt dừng hai lần, quân bị bắn tan khi đứng chờ; rất chậm. **Sửa tiến trình để qua.** |
| 9 · Cầu phao – vào Thăng Long | 1 | Thắng | 11 / 14 | ☆☆ | ~29 phút | Mục tiêu rõ, kết rất đẹp; quân Thanh khá thụ động. |
| K · Lời kết | — | Đã xem | — | — | ~2 phút | Cảm động, nguồn ghi rõ; nhưng hết chiến dịch không có màn chúc mừng nào. |

Tổng: khoảng 4 giờ 40 phút. Không lần nào app bị văng; `logcat` không có dòng `E godot` nào sau mỗi lần mở.

## Ghi chú từng màn

### Màn 0 — Rút về Tam Điệp
- Hướng dẫn "chạm để chọn – chạm ô xanh xem đường – chạm lại để đi" rất dễ hiểu. Có Hoàn tác sau khi đi: tốt.
- Ngay vòng đầu có 2–3 bảng gợi ý bật liền nhau, mỗi bảng phải bấm "Đã hiểu". Chấp nhận được ở màn hướng dẫn.
- Hết lượt khi còn quân chưa đi thì phải bấm hai lần: bảo vệ tốt khỏi bấm nhầm.

### Màn 1 — Núi Bân
- Lần đầu mua lính (bấm vào đồn): bảng mua rõ giá và chỉ số.
- Hỏa mai bắn xa 2 ô là quân chủ lực thật sự. Quang Trung lao vào đánh lính giáo bị phản đòn mất 63 máu: bài học tốt, nhưng
  ô xem trước sát thương có ghi phản đòn, chỉ là chữ nhỏ.
- Màn ngắn, thắng thoải mái, đủ 2 sao.

### Màn 2 — Nghệ An
- Chiếm 6 làng → tự động bắt đầu "diễn tập" với doanh voi. Voi xuất hiện sát quân ta và ngay lượt đó giết quân sư đang đi
  trước. Mục tiêu phụ "chiêu hàng 2 hình nộm (cần quân sư)" thế là hỏng luôn, không có cách gỡ. Tôi cũng không bao giờ thấy
  "hình nộm" trông ra sao.
- Đề nghị: báo trước ("chiếm làng thứ 6 sẽ bắt đầu diễn tập") và cho quân diễn tập xuất hiện cách quân ta vài ô.
- Gặp Nguyễn Thiếp ở làng đồi tây: đoạn hội thoại hay.

### Màn 3 — Tam Điệp ăn Tết (màn chuyện)
- Sa bàn chia đạo quân rất đẹp. Nhưng chạm vào một đạo thì chỉ thấy tô sáng, phần chữ giải thích nằm phía dưới màn hình,
  phải kéo xuống mới thấy. Tôi suýt bỏ qua.
- Có dòng chữ kiểu ghi chú nội bộ "Bản tóm tắt này chưa đối chiếu nguyên văn" hiện cho người chơi. Trung thực, nhưng nên
  viết lại cho người chơi hiểu hoặc đưa vào mục nguồn.

### Màn 4 — Đêm 30 Tết, vượt sông Gián
- Không khí đêm, sương mù, quân Lê ngủ, lính cầm đuốc ("ô quanh sáng, địch thấy từ xa"): rất có chất.
- Tới vòng 3 thì báo động đã lên (tôi đọc được cờ `bao_dong` trong bản lưu), nhưng trên màn hình tôi **không thấy rõ ai báo
  động và vì sao**. Hỏng luôn mục tiêu phụ "không để quân Lê báo động".
- Voi chiến và hỏa hổ có trong quân ta nhưng tôi không tìm thấy việc gì cho chúng làm; "không mất voi" là sao duy nhất tôi lấy
  được, bằng cách để voi đứng sau.
- Thắng vòng 9; chuyện kết có nhãn [Sử liệu], mở 3 mục Sử liệu.

### Màn phụ P — Thủy quân
- Bản đồ nhỏ, sông giữa, thủy binh đi nhanh trên nước: ngắn và vui. Đô đốc Tuyết đi thẳng vào bến đông ở vòng 3 mà gần như
  không bị chặn; bến tây hạ trong 5 vòng. Hơi dễ.
- Banner "Bến tây đã về tay ta: mua thủy binh, hồi máu…" rõ ràng.

### Màn 5 — Thanh Quyết – Nhật Tảo – Phú Xuyên
- Bản đồ 24 hàng phải kéo lên kéo xuống liên tục; hai đồn (Thanh Quyết rồi Nhật Tảo) nối tiếp nhau. Tôi mất 16 vòng và gần
  50 phút: **quá dài** so với mục tiêu "một màn 10–25 phút" trong tài liệu thiết kế.
- 5 trinh sát Thanh chạy về bắc ngay từ vòng 1–3. Ba quân ta đặt sẵn phía bắc không chặn kịp. Tôi **không thấy thông báo
  nào** khi trinh sát thoát (có thể có banner 2 giây mà tôi bỏ lỡ); chỉ tới đoạn kết mới biết "có người lọt lưới", và hệ quả
  là màn 6 khó hơn hẳn. Ý tưởng hệ quả liên màn rất hay, nhưng người chơi cần biết ngay lúc nó xảy ra.
- Thần công: **không bắn được sau khi đi**, phải đứng yên rồi bắn. Bảng chỉ số chỉ ghi "Di 3, Tầm 2–4", không nói điều này.
  Khi bắn được thì cực mạnh (60–70 sát thương một phát).
- Chiêu hàng quân tan thành "hàng binh": hay. Quân sư "Đánh" chỉ gây 5–10 sát thương, gần như vô dụng.

### Màn 6 — Vây Hà Hồi (thua 2 lần, sửa tiến trình để qua)
- Vì màn 5 có trinh sát thoát, tôi gặp bản "đồn thức".
- Lần 1: tôi không hiểu luật vây. Mỗi lần gọi hàng, bảng báo "lực" của ta (304–404) không đủ so với mức cần (378–753), mà không
  nói tăng lực bằng cách nào. Hết vòng 14, thua với màn hình "Trời sáng. Quân Thanh ở Ngọc Hồi đã biết tin." Không có gợi ý
  nào về lý do thua.
- Lần 2: tình cờ chạm vào ô đồn mới thấy "Chưa bị vây: còn N ô hở" và dấu × ở các ô hở. Đây là thông tin quan trọng nhất của
  màn, nên hiện thường trực (hoặc có gợi ý "chạm vào đồn để xem ô hở"). Tôi cũng chỉ phát hiện bằng thử: chỉ Quang Trung, quân
  sư và thủy binh mới có nút "Gọi hàng"; lính giáo, hỏa mai, trống thì không.
- Vòng 5 tôi khép được vây (629, cần 731), rồi lượt địch giết lính giáo ở góc bắc, sĩ quan Thanh đứng vào chỗ hở, Quang Trung
  còn 15 máu. Tôi dừng ở vòng 6.
- Tôi đánh giá: cơ chế vây và gọi hàng là thứ độc đáo nhất của game, rất xứng đáng giữ, nhưng hiện là chỗ người chơi dễ bỏ
  game nhất.

### Màn 7 — Khương Thượng (thua 2 lần, sửa tiến trình để qua)
- Đốt doanh bằng hỏa hổ rất đã mắt; gợi ý về đốt, lính tuần và pháo viết rõ.
- Lần 1: tôi đặt Đô đốc Long sát Sầm Nghi Đống ở vòng 9. Lượt địch, Sầm + pháo binh hạ Long (54 máu) ngay. Có gợi ý "đừng để
  Long đứng trong tầm pháo", nhưng không có cách nào **xem tầm bắn của pháo địch** trên bản đồ.
- Lần 2 (nạp lại bản lưu vòng 10): Sầm hồi khoảng 20 máu mỗi vòng và không xuống dưới 1 máu nếu không dồn đủ trong một lượt.
  Còn Long, 1 hỏa mai, 1 trống thì không đủ. Tôi có 1.300 vàng nhưng đồn mua lính ở tận góc nam, quân mới tới nơi thì đã hết
  giờ, và game không nhắc gì về việc mua thêm.

### Màn 8 — Ngọc Hồi (bỏ dở, sửa tiến trình để qua)
- Ý tưởng mộc thuẫn đi trước, chông sắt, địa lôi, viện binh Đô đốc Bảo từ Đại Áng: đúng chất "màn trùm".
- Thực tế: mỗi hàng chông bắt quân dừng lại và mất 15 máu, có hai hàng nên mỗi quân dừng hai lần, đứng yên trong tầm điểu
  thương và pháo. Hỏa mai bị tụt lại phía sau vì không đi qua chông được trong một lượt. Tới vòng 8 tôi đã mất 3 mộc thuẫn,
  4 lính giáo và 2 voi (một của Bảo) mà quân Thanh vẫn rút gọn vào trong đồn. Tôi không thấy địa lôi nào nổ.
- Camera tự dịch sau lượt địch (mỗi lượt lệch một khác), dễ chạm nhầm ô.
- Do giới hạn thời gian, tôi không chơi lần 2. Vì sửa tiến trình, màn 9 không nhận quân "mang từ màn 8" mà dùng đội hình mặc định.

### Màn 9 — Cầu phao sông Nhị
- Mục tiêu rõ: hạ 3 tướng ở đầu cầu, rồi đưa Quang Trung và 2 quân vào thành. Không có tiền: phải dùng quân sư chiêu hàng.
- Quân Thanh khá thụ động, đứng quanh đầu cầu. Tôn Sĩ Nghị chạy qua cầu ngay vòng 2 (đúng sử, có báo trước).
- Đoạn kết tuyệt vời: cầu đứt, ba tướng tử trận [Sử liệu]; ba nguồn khác nhau về lý do cầu đứt được ghi song song; Quang
  Trung ra lệnh "thu nhặt xác tử sĩ, cả quân ta lẫn quân Thanh" [Sáng tạo của game]. Đây là đoạn hay nhất game.
- Mục tiêu phụ "vào thành trước vòng 8" khá chặt với đội hình mặc định.

### Lời kết
- Mười mấy dòng, mỗi dòng có nhãn nguồn: Lê Chiêu Thống, Lê Quýnh không chịu cạo đầu, Tôn Sĩ Nghị bị cách chức, đền thờ
  Sầm Nghi Đống, cành đào gửi Ngọc Hân [Tương truyền]. Cảm động và cân bằng.
- Sau đó chỉ có bảng "Xong màn chuyện" rồi quay về danh sách màn. Đã hoàn thành cả chiến dịch mà **không có lời chúc mừng,
  tổng kết sao hay danh sách người làm**. Hơi hụt.

## Các mặt chung

### Vui và nhịp chơi
- **Vui nhất:** màn 1, 4, P, 9 và lần đầu thấy hỏa hổ đốt doanh. Nhịp ngắn, mục tiêu rõ, có quyết định thật (đi trước hay vòng
  sau, ai đỡ phản đòn).
- **Mệt nhất:** màn 5 (dài, kéo bản đồ nhiều), màn 8 (chông làm mọi thứ chậm như bò). Màn 6–7 không dài, nhưng thua mà không
  hiểu vì sao nên rất nản.
- Có quyết định thật không? Có ở các màn tốt. Ở nhiều màn lại có một chiến thuật thắng rõ: dồn hỏa mai bắn từ xa 2 ô, lính
  giáo kết liễu. Voi, hỏa hổ (ngoài màn 7), trống trận ít khi đáng dùng.

### Đường cong độ khó
- Màn 0–4, P: dễ đến vừa, mượt.
- **Bước nhảy lớn ở màn 6** (nhất là bản "đồn thức" do màn 5), màn 7 và 8 cũng khó. Màn 9 lại dễ thở. Người chơi bình thường
  rất có thể kẹt lại ở 6–8.
- Hệ quả liên màn (trinh sát thoát → đồn thức) cộng dồn độ khó vào đúng chỗ đã khó nhất. Nên làm cho bản "thức" chỉ khó hơn
  một chút, hoặc cho chọn chơi lại màn 5.
- Mục tiêu phụ: màn đầu công bằng; từ màn 4 nhiều mục tiêu hỏng mà người chơi không biết lúc nào hỏng (báo động, trinh sát).
  Nên có bảng mục tiêu thu gọn trên màn hình, gạch ngay khi hỏng.

### Độ rõ ràng
- Hiểu tốt: đi/đánh/phản đòn, mua lính, chiếm làng, đêm và sương mù, đuốc, đốt doanh, cầu phao.
- Chưa rõ: báo động (ai, lúc nào); trinh sát thoát; vây đồn (ô hở, lực vây, ai gọi hàng được); thần công phải đứng yên mới bắn;
  chông bắt dừng; Sầm Nghi Đống hồi máu bao nhiêu; quân tan / chiêu hàng (biểu tượng vũ khí rơi chỉ hiểu khi tình cờ chạm vào).
- Gợi ý: viết ngắn gọn, đúng chỗ, đa số hiện đúng lúc. Thiếu loại gợi ý "sau khi thua": màn hình thua nên có một dòng "Lần sau
  thử: …".
- Bảng mua lính chỉ có chỉ số, không mô tả kỹ năng đặc biệt (hỏa hổ đốt, trống tăng công, thủy binh đi nước, mộc thuẫn đỡ đạn).

### Giao diện trên điện thoại
- Chữ to, đọc tốt trên màn 5,5 inch; nút đáy đủ lớn. Hội thoại đẹp, chân dung rõ.
- **Không hủy được sau "Đứng yên"** (xem lỗi 1): lỗi thao tác hay gặp nhất.
- Khi một quân đang mở menu hành động, chạm quân khác chỉ hiện thông tin chứ không chuyển chọn; hơi khó hiểu.
- Camera tự dời sau lượt địch, không về chỗ cũ; bản đồ lớn (màn 5, 8) phải kéo nhiều.
- Muốn đánh sau khi đi phải bấm "Đánh" trước rồi mới chạm mục tiêu; chạm thẳng vào địch không có phản hồi gì.
- Không có cách xem tầm đánh của quân địch (bấm giữ hoặc nút bật/tắt). Ở màn 7, 8 có pháo, thiếu cái này là thiệt thòi lớn.

### Lịch sử và giọng văn
- Nhãn nguồn dùng đều, nhất quán, có cả màu riêng. Đoạn cầu phao đặt ba nguồn cạnh nhau là cách làm rất đáng khen.
- Tôn trọng hai phía: không miệt thị, lễ cầu siêu cả hai bên, đền thờ Sầm Nghi Đống, Lê Quýnh. Rất tốt.
- Mục Sử liệu hay, có ngày âm – dương quy đổi và nguồn. Một điểm trừ: mục "Tết năm ấy có ngày 30" dẫn nguồn "Trích Hoàng Lê
  nhất thống chí hồi 14 (hoc24)" là trang học tập, không phải bản in. Nên dẫn bản in hoặc thư viện số.
- Ghi chú nội bộ ở màn 3 ("chưa đối chiếu nguyên văn") nên viết lại.
- Tôi không thấy câu nào sai hay một chiều đáng lo.

## Danh sách lỗi

1. **Không hủy được "Đứng yên".** Chọn một quân → bấm "Đứng yên" → nếu không có địch trong tầm thì chỉ còn nút "Chờ"; nếu có
   "Gọi hàng" mà bấm vào rồi "Thôi" thì vẫn chỉ còn "Gọi hàng" / "Chờ". Không có Hoàn tác, chạm chỗ khác không bỏ chọn. Kết
   quả: mất lượt của quân đó. Gặp ở màn 5 (Quang Trung) và màn 6 vòng 5 (Quang Trung, ô cổng đồn).
2. **Không báo khi trinh sát thoát (màn 5).** Để trinh sát chạy qua sông ở vòng 3–6: tôi không thấy thông báo nào (hoặc nó quá
   ngắn), chỉ đoạn kết mới nói. Hệ quả: màn 6 thành bản "đồn thức".
3. **Không rõ nguồn báo động (màn 4).** Vòng 1–2 đi qua sông bằng quân không cầm đuốc; đầu vòng 3 cờ báo động đã lên mà không
   có banner chỉ ra quân nào kêu.
4. **Diễn tập màn 2 bật đột ngột.** Chiếm làng thứ 6 khi quân sư đang đi đầu: voi diễn tập xuất hiện sát và hạ quân sư trong
   cùng lượt, mục tiêu phụ "chiêu hàng hình nộm" không còn cách đạt.
5. **Thần công không bắn sau khi di chuyển, không giải thích.** Màn 5: đi thần công 1 ô → không có nút Đánh, không có thông báo.
6. **Chạm thẳng vào địch sau khi đi không có phản hồi.** Đi quân tới cạnh địch, chạm vào địch: không gì xảy ra; phải bấm "Đánh"
   trước. Nên cho chạm thẳng hoặc hiện chữ hướng dẫn.
7. **Chữ ghi chú nội bộ lộ ra (màn 3).** Dòng "Bản tóm tắt này chưa đối chiếu nguyên văn" trong sa bàn.
8. **Hết chiến dịch không có màn kết thúc.** Sau Lời kết → "Xong màn chuyện" → quay về danh sách, không chúc mừng, không tổng kết.
9. **(Cân bằng, không phải lỗi)** Quân sư "Đánh" chỉ gây 5–10 máu; quân Thanh ở màn 9 thụ động, phần lớn đứng chờ ở đầu cầu.

## 5 thay đổi nên làm trước, theo thứ tự ưu tiên

1. **Sửa luồng thao tác:** cho Hoàn tác / Thôi sau "Đứng yên" và trong mọi menu hành động; chạm thẳng vào địch là đánh; chạm
   quân khác thì chuyển chọn. Đây là thứ người chơi đụng phải mỗi màn.
2. **Làm mềm và làm rõ màn 6–8:** hiện thường trực số ô hở và lực vây ở màn 6, nói rõ ai gọi hàng được; giảm độ khó bản "đồn
   thức"; ở màn 7 cho xem tầm pháo và nói Sầm hồi bao nhiêu; ở màn 8 cân nhắc chỉ một hàng chông hoặc chông không bắt dừng
   mộc thuẫn. Thêm một dòng gợi ý trên màn hình thua.
3. **Cho xem tầm đánh của địch** (bấm giữ quân địch hoặc nút bật/tắt vùng nguy hiểm). Hầu hết các lần mất quân oan của tôi là
   vì không biết quân địch đánh tới đâu.
4. **Hiện nhân quả ngay lúc xảy ra:** bảng mục tiêu (chính + phụ) thu gọn trên màn hình, gạch đỏ ngay khi hỏng; banner rõ khi
   báo động (ai kêu, vì sao) và khi trinh sát thoát; mô tả kỹ năng trong bảng mua lính.
5. **Nhịp chơi:** rút ngắn màn 5 (bớt một đồn hoặc bớt chiều dài bản đồ), giảm phải kéo bản đồ, camera không tự dời sau lượt
   địch; thêm màn hình kết thúc chiến dịch (tổng sao, lời cảm ơn).

## Cách tôi đánh giá

- Build: `git pull` (không có gì mới), chạy test headless (68 test, 912 kiểm tra, 0 lỗi), xuất APK debug bình thường, cài lên
  Pixel 3 (`89NX0C3U2`). Sau mỗi lần mở app đều kiểm `logcat`: không có lỗi script.
- Trước khi chơi: sao lưu `files/tien_trinh.json` và `.bak` (máy không có `luu_tran.txt`), rồi xóa dữ liệu app (`pm clear`)
  để bắt đầu như người mới. Sau khi chơi: đẩy lại đúng hai file đã sao lưu (đã so byte, giống hệt), xóa `luu_tran.txt*`.
  Lưu ý: bản APK đang cài trên máy giờ là bản build bình thường từ commit `7231e8a`, không còn bản build tạm trước đây.
- Chơi bằng lệnh `adb` (chạm, kéo, chụp màn hình). Để biết tọa độ ô, tôi đọc bản tự lưu `luu_tran.txt` lấy vị trí quân và dùng
  một đoạn mã so ảnh để tìm ô xanh đi được. **Nói thẳng:** đọc bản lưu cũng cho tôi biết vị trí quân địch bị sương che, nên ở
  các màn đêm tôi biết nhiều hơn người chơi thường. Nếu có ảnh hưởng thì là làm các màn đêm *dễ hơn*, nên nhận xét "khó" ở
  trên càng đúng.
- Không đọc báo cáo kiểm thử cũ, lịch sử chat hay lời giải mẫu trong khi chơi. Chỉ đọc tài liệu thiết kế (`docs/01`, `docs/04`)
  **sau khi** chơi xong, để đối chiếu: tài liệu nhắm "một màn 10–25 phút"; màn 5 của tôi mất gần 50 phút. Tài liệu cũng ghi
  lời giải màn 8 được tìm bằng máy và "cần người chơi thật xác nhận độ khó". Trải nghiệm của tôi cho thấy màn này hiện quá khó
  với người chơi lần đầu.
- **Sửa file tiến trình (để mở màn sau, đã nói rõ ở trên):**
  - 18:56: đánh dấu màn 6 xong, 0 sao, sau 2 lần thua.
  - Khoảng 19:42: đánh dấu màn 7 xong, 0 sao, sau 2 lần thua; lần 2 là nạp lại bản tự lưu đầu vòng 10.
  - 20:02: đánh dấu màn 8 xong, 0 sao, sau 1 lần bỏ dở ở vòng 8.
  - Ngoài ra tôi chỉ nạp lại bản tự lưu một lần, ở màn 7.
- Ảnh chụp màn hình và ghi chú nằm ngoài repo, trong thư mục scratchpad
  `/private/tmp/claude-501/-Users-november-Project-games-asset-gamemaker/6492e91d-4303-4d37-87c0-153ba0b35e58/scratchpad/reviewer/`
  (`p3/` là ảnh, `hints/` là ảnh các bảng gợi ý, `notes.md` là ghi chú thô).
