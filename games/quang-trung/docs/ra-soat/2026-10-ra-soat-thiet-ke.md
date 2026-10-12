# Review bộ tài liệu thiết kế "Tây Sơn" (games/quang-trung) trước khi làm

Phạm vi: README, docs/01–09, drafts/quang-trung. Không sửa file nào. Số dòng theo bản ở commit `1f812c2` (15:59, 12/10/2026). Trong lúc review có hai commit mới (`f298305`, `1f812c2`) sửa README, 01, 02, 04, 05, 07, 08, 09; các số dòng và kết luận dưới đây đã đối chiếu lại với bản mới nhất.

Quy ước: **Chặn** = agent không làm đúng được nếu chưa sửa, hoặc chặn phát hành. **Quan trọng** = agent sẽ phải tự đoán, hoặc lối chơi/cân bằng hỏng. **Nhỏ** = lệch chữ, link, chi tiết.

---

## A. CHẶN

### C1. Pháp lý: cá nhân gần như chắc chắn không phát hành hợp pháp ở Việt Nam được theo NĐ 147; game thuộc nhóm G4 nhưng không phải "chỉ thông báo"
- **File:** 09 dòng 48, 59, 65; README dòng 42; 01 dòng 61.
- **Vấn đề:**
  1. **Nhóm:** Khoản 1 Điều 37 NĐ 147/2024 định nghĩa **G4** là "trò chơi điện tử được tải về qua mạng, không có sự tương tác giữa người chơi với nhau và giữa người chơi với hệ thống máy chủ trò chơi của doanh nghiệp". Game offline, một người chơi, tải từ store thuộc **G4**, tức vẫn nằm trong phạm vi nghị định. Không có nghĩa là "ngoài phạm vi vì offline". *Độ chắc: cao* (nhiều nguồn thứ cấp trích cùng câu chữ; chưa đọc được bản gốc).
  2. **Thủ tục:** G2–G4 cần **hai** giấy: (a) **Giấy chứng nhận đăng ký cung cấp dịch vụ trò chơi điện tử G2, G3, G4** cấp một lần cho doanh nghiệp; (b) **Giấy xác nhận thông báo phát hành** cho từng game. Dòng 48 chỉ nói "thông báo phát hành" là thiếu bước (a). *Độ chắc: cao.*
  3. **Chủ thể:** Mọi nguồn tìm được đều nói chủ thể là **"doanh nghiệp"**. Hồ sơ cần giấy chứng nhận đăng ký doanh nghiệp hoặc giấy chứng nhận đăng ký đầu tư. Tổ chức hay cá nhân nước ngoài cung cấp game cho người dùng Việt Nam, kể cả qua biên giới, cũng phải lập doanh nghiệp ở Việt Nam. Không nguồn nào cho cá nhân hay hộ kinh doanh xin giấy này. Game **miễn phí cũng không được miễn**, vì phân loại theo cách tương tác chứ không theo cách thu tiền. Nghị định còn bắt kho ứng dụng chỉ đưa lên game có giấy tờ hợp lệ và gỡ khi cơ quan yêu cầu. Kết luận: **cá nhân đứng tên thì không đáp ứng được NĐ 147 cho kho ứng dụng Việt Nam**. *Độ chắc: trung bình–cao.* Tôi không đọc được nguyên văn (mọi trang bị chặn, chỉ có trích đoạn tìm kiếm) và không tìm thấy điều khoản nào nhắc đến cá nhân.
  4. **Cơ quan:** sau đợt sắp xếp bộ năm 2025, thủ tục G2–G4 do **Sở Văn hóa, Thể thao và Du lịch** cấp tỉnh làm (thời hạn khoảng 15 ngày). Các bài cũ ghi Sở TT&TT. *Độ chắc: trung bình.*
  5. **Văn bản mới:** NĐ **174/2026/NĐ-CP** (xử phạt, hiệu lực 01/7/2026) có mức phạt riêng cho vi phạm G2–G4 (một nguồn ghi 20–40 triệu đồng). Bộ VHTTDL đưa ra **dự thảo sửa NĐ 147** ngày 13/7/2026; theo báo cáo của CCIA, chế độ cấp phép về cơ bản giữ nguyên. *Độ chắc: trung bình*, phải kiểm lại.
- **Sửa:**
  - Viết lại dòng 48: "G4 (Điều 37 khoản 1). Cần Giấy chứng nhận đăng ký cung cấp dịch vụ G2–G4 (chỉ cấp cho doanh nghiệp) và Giấy xác nhận thông báo phát hành cho từng game, nộp ở Sở VHTTDL nơi đặt trụ sở. Số giấy phải ghi trong mô tả trên store."
  - Thêm vào mục 5 một quyết định cần chốt **trước M1**, không để đến M5, vì nó quyết định có phát hành được ở thị trường chính hay không. Ba phương án:
    - (a) Lập công ty TNHH một thành viên, xin giấy G2–G4, rồi thông báo phát hành.
    - (b) Phát hành qua một nhà phát hành Việt Nam đã có giấy. Khi đó tên trên store là của họ, trái quyết định "cá nhân".
    - (c) Tạm bỏ cửa hàng Việt Nam. Phương án này đi ngược đối tượng người chơi.
  - Ghi rõ: cần luật sư xác nhận lại trên nguyên văn Điều 37, 38, 48–54.
  - Sửa README dòng 42 thành "phát hành cá nhân — **chưa hợp lệ ở VN theo NĐ 147, xem 09 §4**".

### C2. Kinh tế không chạy: vàng khởi đầu có nhưng gần như không màn nào có đồn của ta để mua lính
- **File:** 02 dòng 84–86 (mua lính cần tướng đứng trên đồn/thành **của phe mình**). 04 dòng 73 (màn 2: 200 vàng, không có đồn), 102 (màn 4: 400), 117 (màn 5: 500), 132 (màn 6: 400), 148 (màn 7: 500), 164 (màn 8: 800). Màn 9 không ghi vàng.
- **Vấn đề:** Ở màn 4, 5, 6, 7, 8, đồn duy nhất được nhắc là **đồn mục tiêu**, mà chiếm nó là **thắng màn ngay**. Màn 2 chỉ có làng. Vậy vàng không tiêu được, và trụ cột "mua lính ở thành, chiếm làng lấy vàng" (01 dòng 24) chỉ còn ở màn 1. Màn 8: có sẵn 16 quân, thêm 4 viện binh ở lượt 4 là đủ **20/20**, nên 800 vàng chắc chắn vô dụng, và chiêu hàng cũng bị chặn vì giới hạn đã đầy.
- **Sửa:** Mỗi màn thêm một mục **"Nơi mua lính"**: ô đồn hoặc doanh của ta có sẵn, hoặc một đồn phụ chiếm được mà không kết thúc màn, kèm danh sách lính mua được. Màn nào không có thì ghi "Không mua lính" và bỏ vàng. Màn 8 thì tăng giới hạn lên khoảng 24, hoặc cho viện binh không tính vào giới hạn.

### C3. "Đồn" là một ô, nhưng luật vây đồn và gọi hàng lại cần một khu nhiều ô; công thức gọi hàng gần như không đạt được
- **File:** 03 dòng 116 (đồn là một loại ô). 02 dòng 143–148. 04 dòng 130–136. 06 dòng 36 (Gọi hàng là hành động của một quân sau khi đi). 03 dòng 20 (kỹ năng của quân sư).
- **Vấn đề:**
  1. "Quân trong đồn" thì một ô chỉ chứa được một quân. Trong khi đó 04 tả đồn Hà Hồi có vòng lũy và 11 quân "trong và quanh đồn".
  2. "Mọi ô đi được kề đồn" là 4 ô hay cả vòng ngoài?
  3. Gọi hàng diễn ra lúc "đầu lượt Tây Sơn" (02) hay là hành động của một quân (06, 03)?
  4. Ví dụ tính: địch có 1 quan + 4 + 2 + 2 + 2 = **11 quân, tổng 1.100 máu**. Quân ta ở màn 6 cũng là **11 quân, tổng 1.100 máu**. Mục tiêu "không đánh trận nào" mà không được giảm máu địch, nên điều kiện chỉ đạt khi **toàn bộ** quân ta, gồm cả Quang Trung và 2 quân sư, đứng vây với máu đầy.
  5. Chưa nói quan giữ đồn có hàng không. Chưa nói 11 quân tan sinh ra một lúc chỉ tồn tại 2 lượt, mà 2 quân sư chỉ chiêu hàng được tối đa 4.
- **Sửa (đề xuất luật):**
  - **Khu đồn** = tập ô đánh dấu trên lớp `diem_dat` (`khu_don_<id>`), gồm ô đồn và các ô lũy hay doanh bên trong.
  - **Bị vây** khi mọi ô đi được nằm kề ngoài khu đồn đều có quân Tây Sơn, hoặc không vào được, hoặc nằm trong vùng khống chế của quân Tây Sơn.
  - **Gọi hàng** là hành động của quân sư hoặc tướng đứng kề khu đồn, mỗi lượt một lần, xong thì quân đó hết lượt.
  - **Điều kiện:** Σ máu quân Tây Sơn trong vòng 2 ô quanh khu đồn ≥ Σ máu quân địch trong khu đồn × k. k = 0,5 nếu quá nửa quân trong đồn đang ngủ, k = 1 nếu không.
  - **Kết quả:** mọi quân địch trong khu đồn, kể cả quan giữ đồn, rời bản đồ. Ta nhận số hàng binh bằng min(số quân hàng, chỗ trống trong giới hạn); số còn lại thành "tù binh" chỉ để ghi điểm mục tiêu phụ. Đồn chuyển sang trung lập.
  - Đổi nhãn "Mục tiêu phụ (chính của màn)" ở 04 dòng 135 cho rõ: đây là mục tiêu phụ hay điều kiện thắng?

### C4. Đánh đêm: một đòn không hạ nổi quân đang ngủ, nên báo động vang ngay đòn đầu; thiếu tầm nhìn của địch, đuốc, chế độ tuần tra
- **File:** 02 dòng 126 (Ngủ), 132–138 (tầm nhìn, báo động, rạng sáng), 170–178 (AI). 04 dòng 100–106 (màn 4), 131 (màn 6), 147 (màn 7), 163 (màn 8).
- **Vấn đề:**
  1. Báo động nổ khi "một quân địch còn sống sau khi bị đánh". Ví dụ tính với lính giáo (50–55) + Bất ngờ (+15) đánh quân Lê ngủ trên doanh trại (thủ 5 + 5): sát thương = 65–70 − 10 = **55–60**, không hạ được. Hỏa hổ (+10 khi đánh quân trong doanh trại) gây 65–70, cũng không hạ được. Voi đánh trên cỏ chỉ hạ được ở lần tung cao nhất; voi có Xung phong thì khoảng 55%. Vì vậy **gần như đòn đầu nào cũng gây báo động bán kính 5**. Mục tiêu phụ "không để trống báo động vang" và cảm giác đánh úp mất hết.
  2. Chưa định nghĩa: "quân cầm đuốc" là quân nào; địch (Thanh **và Lê**) nhìn xa bao nhiêu; quân đang ngủ có "thấy" được không; quân bị Cháy có tỉnh dậy không.
  3. Màn 4 có "2 điểu thương đi tuần", nhưng 02 §14 chỉ có 3 chế độ AI: Giữ đồn, Tấn công, Chạy. Thức dậy rồi chuyển sang chế độ nào cũng chưa có.
  4. Màn 8 dùng "tầm nhìn 4" nhưng 02 không có tham số này. Rạng sáng thì chỉ ghi "giảm dần".
- **Sửa:**
  - **Báo động trễ:** quân bị đánh mà còn sống thì bị đánh dấu "kêu". Báo động (bán kính Manhattan 5) chỉ xảy ra **đầu lượt địch kế tiếp**. Nếu quân "kêu" bị hạ trước đó thì không có báo động. Cách này cho phép hai quân phối hợp hạ một mục tiêu trong im lặng. Hoặc đơn giản hơn: Bất ngờ = +30.
  - Thêm cờ `duoc` (cầm đuốc) vào units.csv: tầm nhìn 3, và quân cầm đuốc tự là nguồn sáng (đổi lại dễ bị phát hiện). Tầm nhìn mặc định là tham số của màn: đêm 2, rạng sáng 4, ngày ∞.
  - Quân địch **thức** thấy quân ta trong bán kính 2, hoặc bất kỳ quân ta nào đứng trên ô sáng trong bán kính 5. Thấy quân ta thì báo động. Quân ngủ không thấy gì. Bị Cháy thì tỉnh.
  - Thêm các chế độ AI: *Tuần tra* (đi theo danh sách điểm), *Ngủ*, *Rút lui* (về ô Z khi máu < X), *Chặn hậu* (= Giữ đồn quanh một ô). Khi báo động: *Ngủ* và *Tuần tra* chuyển thành *Giữ đồn* với R = 4 quanh đồn gần nhất.
  - Rạng sáng: lượt R tầm nhìn 3, lượt R+1 tầm nhìn 5, sau đó tắt sương mù. Mọi quân thức dậy ở đầu lượt R.

---

## B. QUAN TRỌNG

### Q1. Đối chiếu với Ancient Empires 2: tài liệu nói "bám sát AE2" nhưng dùng bộ vai của AE1, và có nhiều chỗ đổi không đánh dấu [đổi]
- **File:** 03 dòng 15–26 (cột "Vai AE2"). 02 dòng 84–86, 109–117, 123. 01 dòng 24, 68.
- **Chắc chắn (có nguồn):**
  - Bộ quân AE2 gồm **Soldier, Archer, Elemental, Sorceress, Wisp, Dire Wolf, Golem, Catapult, Dragon**, Commander (Galamar/Valadorn), Skeleton, Crystal. Các tên **Lizard, Wizard, Spider, Wyvern** mà 03 ghi là "Vai AE2" thực ra là của **AE1** (fandom wiki).
  - Máu tối đa 100 ở AE2 (AE1 là 10). Khớp với tài liệu.
  - Sorceress gọi Skeleton từ mộ. Commander chết thì hồi sinh được ở castle. Catapult **phá được làng** địch.
  - **Dire Wolf gây độc: quân bị độc "chậm và yếu ở lượt kế"**, không phải mất máu theo lượt.
  - Ở AE2, **vua không cần đứng trong castle mới mua được lính** (Wikipedia: AE2 đã bỏ điều kiện này).
- **Khá chắc (diễn đàn 2008, hoặc trí nhớ):** giá Soldier 150, Archer 250, Elemental 300, Sorceress 400, **Wisp 500**, **Dire Wolf 600**, Golem 600, Catapult 700, Dragon 1000. Mộ chỉ tồn tại khoảng **1 lượt** và Sorceress phải **đứng kề** mộ (một bài diễn đàn).
- **Không chắc:** thu nhập mỗi làng/castle, lượng máu hồi (tôi nhớ là 20), cộng chỉ số mỗi cấp và các mốc kinh nghiệm, giới hạn quân, Catapult có phản đòn không, AE2 có vùng khống chế hay không, bán kính hào quang của Wisp.
- **Chỗ đổi chưa đánh dấu [đổi]:**
  - Trống trận (vai Wisp) giá 400 so với 500 của AE2 (03 dòng 21).
  - Hỏa hổ (vai Dire Wolf) giá 500 so với 600 (03 dòng 22).
  - *Cháy* trừ máu và trừ thủ, so với độc của AE2 làm giảm di chuyển và công (02 dòng 123).
  - Mua lính cần tướng đứng trên đồn và đặt quân ra ô kề: đây là luật AE1, không phải AE2 (02 dòng 84–86).
  - Quân tan tồn tại 2 lượt, chiêu hàng tầm 2 (02 dòng 113–115).
  - Thần công không phá được làng.
  - Voi không bay (có giải thích ở 03 dòng 29 nhưng thiếu nhãn [đổi]).
  - Bảng kinh nghiệm và cấp ở 02 §6 không ghi nguồn.
- **Sửa:**
  - Đổi cột "Vai AE2" sang tên AE2 (Elemental, Sorceress, Dire Wolf, Dragon, Skeleton).
  - Thêm phụ lục **"Bảng đối chiếu AE2"**: mỗi con số kèm giá trị AE2, nguồn, độ chắc, và giữ hay [đổi]. Nếu không có bảng này, agent sẽ tự "nhớ" AE2 và áp sai.
  - Đánh dấu [đổi] cho mọi chỗ kể trên, hoặc sửa về đúng AE2. Đề xuất giữ cách mua lính của AE1 vì hợp lịch sử (tướng chỉ huy), nhưng phải ghi rõ.

### Q2. Thiếu luật, agent sẽ phải tự đoán (mục 2). Mỗi dòng kèm luật đề xuất

| # | Chỗ (file:dòng) | Chưa rõ | Luật đề xuất |
|---|---|---|---|
| 1 | 02:51–55 | `random_int` có tính hai đầu không; thứ tự làm tròn | Tung đều trong [min, max], tính cả hai đầu. `st = (max(0, công − thủ) * hp_người_đánh) // 100`; nếu công > thủ và st = 0 thì st = 1. Mọi cộng trừ là số nguyên, cộng hết rồi mới trừ thủ |
| 2 | 02:64–66 | Quân bắn đứng có phản đòn ở cự ly 2–4 không. Phản đòn dùng những cộng thêm nào | Quân bắn đứng **không bao giờ phản đòn** (như Catapult). Phản đòn có khắc chế, hào quang, uy danh, cấp. **Không** có Xung phong, Hăng máu, Bất ngờ. Phản đòn có gây Cháy |
| 3 | 02:38–39 | Vùng khống chế: quân bắt đầu lượt trong vùng; quân địch đang ngủ hay đang bị che trong sương; quân đồng minh Thanh–Lê; quân bắn xa | Bắt đầu lượt trong vùng vẫn đi được, nhưng ô đầu tiên vào mà kề địch thì dừng. Quân ngủ **vẫn** tạo vùng khống chế. Quân bị sương che vẫn tạo vùng, và khi dừng thì lộ ra ("phục kích"), không hoàn tác được. Thanh và Lê là đồng minh: đi xuyên qua nhau được, không tạo vùng khống chế cho nhau. Đề xuất chỉ quân cận chiến tạo vùng khống chế (xem Q4) |
| 4 | 02:113–117, 22 | "Phe kia", "2 lượt" tính thế nào. Quân tan nằm trên cầu, làng, đồn | Quân tan sinh ra ở vòng N thì biến mất đầu lượt Tây Sơn của vòng N+2. Không sinh quân tan trên cầu, cầu phao, sông (quân rơi xuống sông thì mất luôn). Quân tan chặn mọi phe, chặn chiếm làng, chặn đặt quân mới. Đánh xa qua được |
| 5 | 02:114–115 | Hàng binh: khi đã đủ giới hạn; máu tối đa; cấp; có chiếm đồn được không | Đầy giới hạn thì nút Chiêu hàng mờ. Máu tối đa 100, bắt đầu 50, cấp 0, chỉ chiếm được làng. Ra đời ở ô quân tan. Hết lượt đó |
| 6 | 02:84–86 | Không còn ô trống kề đồn; ô kề là nước; quân mới sinh trong sương | Không có ô hợp lệ (đi vào được theo kiểu di chuyển của loại quân đó, không có quân tan) thì loại quân đó mờ trong danh sách. Ô đặt quân do người chơi chọn trong các ô hợp lệ |
| 7 | 02:19–20 | Thời điểm hồi máu; làng của đồng minh; quân vừa mua | Hồi máu đầu lượt của phe đó, kể cả quân vừa mua. Làng của **đồng minh** (Thanh ↔ Lê) cũng hồi máu. Hồi máu xong mới trừ Cháy |
| 8 | 02:123 | Cháy bị đánh lại thì cộng dồn hay tính lại; đếm 2 lượt theo phe nào | Không cộng dồn. Bị đánh lại thì đặt lại về 2. Đếm theo lượt của **phe bị Cháy**. Máu không xuống dưới 1 |
| 9 | 02:124–125 | "8 ô quanh" là Chebyshev hay Manhattan; nhiều trống trận có cộng dồn không; trống trận có tự hưởng không | Chebyshev 1 (8 ô quanh). Không cộng dồn giữa nhiều trống. Không tự hưởng. Uy danh và hào quang cộng được với nhau. Tính lúc ra đòn |
| 10 | 03:85 | "Bộ binh thường" | Dùng thẻ `bo_binh` trong units.csv: lính giáo, trường mâu, thổ binh, quân Lê, hàng binh, **trinh sát**. Không gồm điểu thương, cung, đằng bài |
| 11 | 03:17, 43, 82–84 | Quang Trung và Đô đốc Bảo cưỡi voi: có bị tính là "voi" khi bị giáo/mâu đánh không | Thẻ `voi` cho voi chiến, Quang Trung, Đô đốc Bảo. Ghi rõ (trường mâu đánh Quang Trung: 60–65 − 20 = 40–45) |
| 12 | 03:23, 87 | "Đánh xa" xác định bằng loại quân hay cự ly | Theo **loại quân** có thẻ `ban_xa`, kể cả khi hỏa mai bắn ở cự ly 1 |
| 13 | 03:22; 02:25 | "Đốt ô doanh trại" không có trong danh sách hành động | Thêm hành động **Đốt** (hỏa hổ, tầm 1, ô doanh trại). Ô thành lửa 3 vòng, sau đó thành "doanh trại cháy" (thủ 0, đi như cỏ). Quân đứng trên ô bị Cháy, trừ mộc thuẫn |
| 14 | 02:152–158; 04:130, 135 | Thiếu kho lương, trống báo động trong bảng vật thể | Kho lương: tướng hoặc lính giáo đứng lên rồi chọn Chiếm. Trống báo động: là vật thể gắn với một đồn; báo động nổ khi quân "kêu" đứng kề nó (luật C4) |
| 15 | 02:30; 04 (mọi màn) | "Trước lượt N", "hết lượt N" | "Thắng trước lượt N" = đạt điều kiện trong lượt Tây Sơn có số ≤ N−1. "Hết lượt N" = thua ở cuối vòng N (sau lượt Lê) nếu chưa thắng |
| 16 | 02:94 | Tướng có tên giữ cấp: giữ KN không; chơi lại màn cũ thì sao | Giữ cả cấp và KN, nhưng **chỉ ở lượt chơi chiến dịch chính**. Chơi lại màn (06:87) dùng cấp của lúc đầu màn đó và không ghi đè. Lưu ảnh chụp cấp tướng ở đầu mỗi màn |
| 17 | 04:182 | Màn 9 mang quân từ màn 8 | Chọn tối đa 10 quân **còn sống cuối màn 8**: người chơi tự chọn, hoặc tự động theo cấp giảm dần. Giữ cấp và KN, hồi đầy máu, hết trạng thái. Đô đốc Bảo không mang sang. Nếu chơi 8 trước 7 thì vẫn mang từ ảnh chụp cuối màn 8 |
| 18 | 02:98–105 | "Tướng" gồm ai (Nhậm, Lân có chiếm đồn, mua lính được không); tướng địch | Thẻ `tuong` (chiếm đồn, mua lính), `tuong_chinh` (bị hạ thì thua). Quan giữ đồn cũng là `tuong`. Ghi điều kiện thua của phía địch nếu có |
| 19 | 01:24; 02:83; 04 | Giới hạn quân có tính tướng, viện binh do kịch bản đưa vào không | Tính mọi quân phe ta trừ quân do kịch bản sinh. Viện binh được phép vượt giới hạn |
| 20 | 02:132; 03:24 | Đánh được quân trong sương không | Chỉ chọn được mục tiêu đang thấy. Thần công tầm 4 cần quân khác soi đường |
| 21 | 08:48; 02:26 | Hoàn tác sau khi bước đi làm lộ sương, địa lôi, vùng khống chế ẩn | Không cho hoàn tác nếu bước đi làm lộ thông tin mới, giẫm bẫy, hoặc đánh thức địch |
| 22 | 04:171 | "Dồn ≥ 3 quân Thanh vào Đầm Mực": không có luật đẩy lùi | Đổi thành "hạ ≥ 3 quân Thanh khi chúng đứng trên ô Đầm Mực". Cho AI *Rút lui* có đường chạy qua đầm |
| 23 | 02:155 | AI có biết địa lôi của mình không | Biết, và tránh. Riêng chế độ *Chạy*/*Rút lui* thì bỏ qua (đúng *Liệt truyện*) |
| 24 | 03:61, 62, 66 | Thời điểm áp Thận trọng, Hăng máu, Thủy quân | Thận trọng: Sở không di chuyển ở lượt gần nhất của mình thì được +10 thủ đến lượt sau. Hăng máu: luôn −5 thủ. Thủy quân: tính +1 di chuyển đầu lượt |
| 25 | 02:91–93 | Lên cấp giữa trận đánh | Cộng KN và tăng cấp **sau khi xong cả đòn và phản đòn**. +10 máu ngay lúc đó |

### Q3. Mộc thuẫn quá mạnh: hỏa khí và cung gần như không làm gì được (tính theo công thức ở 02)
- **File:** 03 dòng 23, 87. 04 dòng 164 (màn 8 có 4 mộc thuẫn).
- **Ví dụ tính** (`st = max(0, công − thủ)`, máu đầy):
  - Điểu thương (50–55) đánh mộc thuẫn (25 + 20 = 45) trên cỏ: **5–10**, tức 10–20 phát mới hạ.
  - Cùng cặp đó khi mộc thuẫn đứng trên làng, đồi, rừng tre, lũy đất (+10): **0**.
  - Cung tiễn (40–45) đánh mộc thuẫn trên cỏ: **0**.
  - Pháo binh (60–70): 15–25.
  - Trường mâu cận chiến (45–50): 20–25, tức 4–5 đòn.
  - Phe Thanh có 60% là điểu thương và 20% là cung (03 dòng 38), nên 4 mộc thuẫn ở màn 8 gần như bất tử. Chông sắt cũng chỉ trừ 5.
- **Sửa:** chống đánh xa giảm còn +10, hoặc giữ +20 nhưng địa hình chỉ cộng một nửa thủ cho mộc thuẫn. Thêm sàn sát thương: đòn trúng tối thiểu = 10% công. Với +10: điểu thương đánh mộc thuẫn trên cỏ được 15–20, trên đồi 5–10. Vẫn là "chịu súng" nhưng không bất tử.

### Q4. Voi, hào quang và cấp tướng cộng dồn thành quá mạnh; vùng khống chế làm quân bắn xa mạnh lên
- **File:** 03 dòng 25, 60. 02 dòng 38–39, 91–94.
- **Ví dụ tính:**
  - Voi (70–80) có +10 khi đánh bộ binh, +10 Xung phong, +5 Uy danh, +10 hào quang. Đánh trường mâu trên cỏ: **100–110, chắc chắn hạ một đòn**. Không có hào quang thì 85–95.
  - Trường mâu đánh voi: 40–45, phải 3 đòn.
  - Quang Trung giữ cấp qua 8 màn. Lên cấp 4 cần khoảng 700 KN, tức chừng 10 lần hạ địch, nên có thể đạt ngay từ màn 5–6. Khi đó: công 80–90, thủ 36; đứng trên đồn thì thủ 51. Điểu thương đánh Quang Trung chỉ được **0–4**, nên điều kiện thua "tướng chính bị hạ" không còn tác dụng.
  - Vùng khống chế: mỗi quân cận chiến khóa 3 cột, nên 3 quân là chặn kín một bản đồ rộng 9. Quân bắn xa (tầm 2, không bị cận chiến phản đòn) đứng sau tuyến đó bắn tự do. Đây là thế mạnh của phe Thanh (80% bắn xa). Mộc thuẫn và voi bỏ qua vùng khống chế là hai thứ duy nhất phá được thế này, nên thêm lý do không làm mộc thuẫn bất tử.
- **Sửa:**
  - Cấp: +3 công / +2 thủ mỗi cấp, hoặc giữ con số hiện tại nhưng **tướng mang sang màn sau tối đa cấp 2**.
  - Hào quang và uy danh cộng lại không quá +10.
  - Xung phong chỉ có khi đi ≥ 3 ô **theo đường thẳng**.
  - Vùng khống chế chỉ do quân có thẻ `chan` tạo ra (cận chiến: giáo, mâu, đằng bài, mộc thuẫn, voi, tướng). Hỏa mai, cung, thần công, quân sư, trống không tạo vùng khống chế.
- Đã kiểm thêm (để tham khảo): lính giáo đánh trường mâu trên cỏ 45–50, bị phản đòn 20–24, hạ sau 2–3 đòn. Thần công đánh đằng bài trong đồn: 75–85 − (20 + 15 + 15) = 25–35; đánh điểu thương trong đồn: 55–65. Hai cặp này hợp lý.

### Q5. Tướng Thanh có tên: bị hạ ở màn 8 nhưng phải chết ở màn 9; luật "rút khi máu < 30" bị một đòn vượt qua; chưa có cách khiến Tôn Sĩ Nghị không thể bị hạ
- **File:** 02 dòng 103–105. 04 dòng 166–170, 184–187.
- **Vấn đề:**
  - Trương Triều Long và Thượng Duy Thăng ở màn 8 không có luật rút, nên có thể bị hạ, rồi lại "chặn hậu" ở màn 9.
  - Hứa Thế Hanh có thủ 20, đứng trên đồn (+15) là 35, nhưng voi có Xung phong đánh được 45–55 nên có thể bị hạ từ 35+ máu xuống 0 trong một đòn.
  - Tôn Sĩ Nghị (chế độ Chạy) chưa có cơ chế bảo vệ trước lượt 4.
- **Sửa:** thêm thẻ `bat_tu_den_man` (máu tối thiểu 1). Hứa Thế Hanh và hai tổng binh ở màn 8: sau đòn nào khiến máu < 30 thì rút về sông, không bị hạ. Tôn Sĩ Nghị ở màn 9: máu tối thiểu 1; bị đánh thì lập tức chạy và qua cầu.

### Q6. Màn 1–2 cần một phe thứ tư ("doanh hữu", "doanh voi") mà luật không có; chiêu hàng "quân thua diễn tập" trái với 02 §8
- **File:** 02 dòng 13 (3 phe), 113 (chỉ quân Thanh/Lê để lại quân tan). 04 dòng 60–63, 76–78. 07 dòng 75 (đồn 4 màu). 06 dòng 75.
- **Sửa:**
  - Thêm phe `dien_tap` (AI, màu đỏ sẫm, không để lại quân tan; về 0 máu thì "bị loại" chứ không chết), đi sau Tây Sơn.
  - Màn 2: thay "chiêu hàng 2 quân" bằng một mục tiêu hướng dẫn riêng, ví dụ quân sư "chiêu hàng" hình nộm quân tan do kịch bản đặt sẵn. Ghi rõ đây là ngoại lệ.
  - Thêm màu phe cho làng, đồn và lính (07 dòng 73–75).
  - Ghi rõ quân sư, trống, voi **mở từ đầu màn 2 hay chỉ trong phần duyệt binh**.

### Q7. Mở khóa lính và danh sách quân lệch nhau
- **File:**
  - 04 dòng 26 ("màn phụ P mở sau màn 3, chơi lúc nào cũng được") và 04 dòng 198 (P có thủy binh) mâu thuẫn với 03 dòng 127 (thủy binh mở ở màn 4).
  - 04 dòng 43 và 03 dòng 63 (màn 0 có Ngô Thì Nhậm biết chiêu hàng, trong khi quân sư và hàng binh mở ở màn 2).
  - 03 dòng 128–129 với 04 dòng 26 (màn 7 và 8 chọn thứ tự, nên mộc thuẫn có thể mua được ở màn 7).
  - 08 dòng 81 (`mo_tu_man` là mốc toàn cục).
- **Sửa:**
  - P mở sau màn 4. Hoặc thủy binh có sẵn trong P như một ngoại lệ ghi rõ.
  - Màn 0: tắt chiêu hàng của Nhậm (đánh dấu là kỹ năng chỉ mở từ màn 2).
  - Bỏ `mo_tu_man`. Thay bằng `mua_duoc: [id...]` trong dữ liệu từng màn. Danh sách quân ban đầu cũng nằm ở dữ liệu màn.
  - P còn thiếu toàn bộ số liệu: vàng, giới hạn, số lượt, địch, số lượng từng loại quân.
- **Đã kiểm và khớp:** quân ban đầu ở các màn 0, 1, 2, 4, 5, 6, 7, 8 đều chỉ dùng lính đã mở. Giới hạn quân: màn 1 6/10; màn 2 4 + 6 lính giáo tặng = 10/14; màn 4 11/14; màn 5 8/16; màn 6 11/16 (+4 hàng binh = 15); màn 7 10/16; màn 8 **20/20**; màn 9 ≤ 11/16.

### Q8. Màn 5: trinh sát có Di 6, quân ta có Di 4, nên không đuổi kịp nếu không quy định vị trí xuất phát
- **File:** 04 dòng 116–122. 03 dòng 49.
- **Sửa:** ghi vị trí xuất phát (ở phía nam hoặc ngang hàng quân ta), thời điểm chúng bắt đầu chạy (khi thấy quân ta), và đường chạy. Ghi rõ là vùng khống chế dừng được chúng (thủ 0, lính giáo hạ trong 2 đòn). Thêm điều kiện thua theo số lượt, hoặc ghi "không giới hạn" cho rõ.

### Q9. Giao diện màn hình dọc trong Godot: số cột không khớp, thu phóng ×1.5 phá phóng nguyên số, máy lớn không còn bị khóa màn hình dọc
- **File:** 06 dòng 8 và ASCII dòng 13–27 (9 cột, "hiện thêm hàng"). 08 dòng 72–73 (360 × 800, hơn 11 cột). 06 dòng 41 (×1.5). 08 dòng 77 (khóa dọc).
- **Vấn đề:**
  - Với `scale_mode = integer` và `aspect = expand`, chiều rộng logic thay đổi theo máy: máy 1080 px rộng được 360 (11,25 cột); iPhone 1170 × 2532 được 292; iPad 1620 × 2160 (×4) được 405 × 540. Giao diện phải co giãn theo chiều rộng 288–405, không cố định 9 cột.
  - Thu phóng ×1.5 thì pixel không đều. Nên dùng mức ×1 và ×2.
  - Android 16 (API 36): với app nhắm API 36, hệ thống **bỏ qua khóa hướng màn hình** trên màn hình ≥ 600dp (tablet, máy gập). Google Play sẽ bắt nhắm API mới. *Độ chắc: trung bình–cao.*
  - iPad: Apple đang bỏ dần `UIRequiresFullScreen`. *Độ chắc: trung bình.*
- **Sửa:**
  - 06: thiết kế cho chiều rộng 288–432 logic; thanh trên và bảng dưới neo theo anchor.
  - Thu phóng 2 mức ×1 và ×2.
  - Thêm mục "màn hình ngang / tablet": bản đồ ở giữa, bảng bên phải. Hoặc chỉ phát hành iPhone và điện thoại Android, ghi rõ.
  - Vùng chạm 96 px vật lý chỉ khoảng 6 mm, dưới mức khuyến nghị 7–9 mm. Chấp nhận được vì có chạm hai lần để xác nhận, nhưng nên ghi rõ.

### Q10. Hệ thống lưu game (08 dòng 63; 06 dòng 86–88)
- **Vấn đề:**
  - Trạng thái `RandomNumberGenerator.state` là **số nguyên 64 bit**. JSON của Godot đọc mọi số thành float, nên **mất độ chính xác ở số > 2^53**, và tọa độ, máu cũng thành float. Hậu quả: test "tải lại không đổi kết quả" ở 08 dòng 99 sẽ hỏng.
  - Lưu khi app bị đưa xuống nền có thể rơi vào lúc máy đang chạy hoạt cảnh.
  - Chưa nói việc ghi file an toàn (ghi dở thì hỏng save), số phiên bản save, và khe riêng cho chơi lại màn cũ.
- **Sửa:**
  - Lưu `seed` và `state` dưới dạng chuỗi. Ép kiểu int khi đọc; hoặc dùng `FileAccess.store_var` hay `var_to_str`.
  - Có trường `save_version` và hàm chuyển đổi giữa các phiên bản.
  - Ghi ra `*.tmp` rồi đổi tên; giữ một bản `.bak`.
  - Chỉ lưu ở **ranh giới lệnh**: nếu đang ở lượt máy thì lưu trạng thái đầu lượt máy rồi chạy lại khi mở app.
  - Khe chơi lại màn cũ tách khỏi khe chiến dịch.
  - Ghi chú: muốn chống "tải lại cho đến khi trúng" hiệu quả hơn, lấy số ngẫu nhiên theo `hash(seed, lượt, id_người_đánh, id_bị_đánh, số_lần_đánh)`, để thứ tự hành động không làm thay đổi kết quả.

### Q11. Kiểm thử và cách agent tự kiểm tra
- **File:** 08 dòng 96–103.
- **Vấn đề:**
  - "AI vs AI" cần AI cho phe Tây Sơn biết theo mục tiêu màn (chiếm, gọi hàng, chiêu hàng). Hiện chỉ có AI cho phe địch.
  - Godot `--headless` không vẽ hình, nên không chụp được màn hình để agent tự xem giao diện.
  - "Agent kiểm thử local chơi thử theo kịch bản" trên điện thoại thật bằng chạm là không thực tế.
- **Đã kiểm:** tải bản Godot từ GitHub Releases **được** trong môi trường cloud này (`Godot_v4.5-stable_linux.x86_64.zip`, 200 OK, khoảng 69 MB). Như vậy test headless chạy được ở cloud. Trang tài liệu và wiki thì bị chặn.
- **Sửa:**
  - Ghim phiên bản Godot (ví dụ 4.5.x). `BUILD.md` có lệnh tải và kiểm tra checksum.
  - Thêm **chế độ chạy theo kịch bản** (file lệnh JSON chạy qua `Command`) cho cả test lẫn agent local. Lần đầu chạy ghi lại kết quả, các lần sau so sánh.
  - Chụp màn hình bằng `xvfb-run` + `--rendering-driver opengl3` (Mesa), kiểm thử khả thi ngay ở M1.
  - Đổi mục tiêu "AI vs AI để cân bằng" thành "AI Tây Sơn đơn giản để phát hiện kẹt". Cân bằng dựa vào lượt chơi thử của chủ dự án.

### Q12. Kế hoạch sản xuất (09) với một agent AI làm toàn bộ
- **File:** 09 dòng 5, 9–16, 24–31, 72.
- **Vấn đề:**
  - Không có ước lượng thời gian. Dòng 5 vẫn viết "phụ thuộc số người trong nhóm", không còn đúng.
  - Rủi ro lớn nhất chưa có trong bảng rủi ro: **chất lượng hình vẽ bằng code**. Phải làm 33 loại × 6 frame và khoảng 30 chân dung 80 × 80 có nhiều biểu cảm. Nhạc tổng hợp bằng code cũng vậy.
  - Vòng phản hồi phụ thuộc chủ dự án build, cài và chơi.
  - Đối chiếu nguồn cần người đọc sách, vì agent không tải được trang (đã kiểm lại: fandom, luatvietnam, công báo đều bị chặn).
  - Thủ tục NĐ 147 đặt ở M5 là quá muộn (xem C1).
  - **Google Play với tài khoản cá nhân mới** (tạo sau 11/2023): phải chạy **thử nghiệm kín với ít nhất 12 người, liên tục 14 ngày** trước khi được lên bản chính thức. 09 chưa nhắc. *Độ chắc: cao*, nhưng nếu tài khoản tạo trước 11/2023 thì có thể không áp dụng.
- **Sửa:**
  - Thêm ước lượng theo số phiên làm việc của agent cho từng mốc.
  - M1 làm thêm "hình mẫu chất lượng thật" cho 1 lính và 1 chân dung để chủ dự án duyệt sớm. Nếu không đạt, chuyển sang tài sản CC0 hoặc thuê vẽ chân dung.
  - Đưa quyết định pháp lý lên M0.
  - Ở M4, tuyển ít nhất 12 người thử nghiệm kín.
  - Dòng 72: bỏ "màn phụ để sau 1.0" (mâu thuẫn với dòng 16).
  - Dòng 12: thêm "màn P".

### Q13. Bảng tướng ở 03 thiếu cột
- **File:** 03 dòng 58–76.
- **Vấn đề:** thiếu Tầm (Ngô Thì Nhậm "như quân sư" thì tầm 1–2?), thiếu Kiểu di chuyển của tướng Thanh, thiếu các thẻ `tuong`/`tuong_chinh`/`bo_binh`/`voi`.
- **Sửa:** thêm các cột này và ghi đủ cho mọi tướng.

---

## C. NHỎ

1. **README dòng 50:** link `09-ke-hoach.md#5-câu-hỏi-còn-mở` đã hỏng, vì tiêu đề đổi thành "5. Đã chốt và còn mở". Đổi thành `#5-đã-chốt-và-còn-mở`. Các link khác đều đã kiểm và đúng: 03→02 §8, 04→02 §11, 08→02 §14, 06→08 §4, 05→04 Lời kết, 07→báo cáo "Sửa art direction".
2. **01 dòng 49:** viết "1 màn chuẩn bị", trong khi README dòng 17 và 04 gọi là "màn chuyện". Thống nhất một tên. Số màn đã kiểm: 0, 1, 2, 4, 5, 6, 7, 8, 9, P = 10 màn đánh, khớp vì P đã vào 1.0.
3. **01 dòng 50:** "6 tướng có tên" không khớp với 03 và 07 (8 tướng Tây Sơn, 5 tướng Thanh có tên). Ghi lại số đúng.
4. **01 dòng 51:** "vây đồn chiêu hàng" nên là "vây đồn **gọi hàng**" (05 dòng 127–128 phân biệt hai từ này). **01 dòng 24:** "mua lính ở thành" nên là "ở đồn" theo bảng thuật ngữ 05 dòng 123–124.
5. **03 dòng 60, 05 dòng 31:** "Quang Trung màn 1–9", nhưng màn 3 không có trận và màn 7 do Đô đốc Long cầm quân. Ghi "1, 2, 4, 5, 6, 8, 9".
6. **03 dòng 117:** dòng Thành thiếu "+50 vàng, hồi máu, mua lính?", trong khi 02 dòng 19 cho thành +50. Ghi rõ thành có mua lính được không.
7. **03 dòng 19 và 108:** thủy binh được +5 thủ "khi đứng dưới nước", và ô sông cũng cho +5. Không rõ có cộng cả hai không. Ghi rõ: cộng cả hai (tổng 20), hoặc bỏ một.
8. **08 dòng 72:** `scale_mode = integer` có **từ Godot 4.2**, không phải 4.3 (tài liệu Godot). `TileMapLayer` thì đúng là cần 4.3+. Nên thêm `rendering/2d/snap/snap_2d_transforms_to_pixel = true`.
9. **08 dòng 109:** xuất AAB phải bật **Gradle build** (cài Android build template). Target API: Google Play đòi API 35 từ 31/8/2025; năm 2026 có thể là 36, cần kiểm tra lúc làm.
10. **07 dòng 92 và drafts:** hình tạm đặt tên `unit_tayson_noithu_strip2.png`, `..._daibac_...` (nỏ thủ, đại bác, không có phần hành động). Trong khi đó quy ước mới là `unit_<phe>_<loai>_<hanhdong>_strip<N>`, và lính đã đổi thành hỏa mai, thần công. Cần **một bảng id ASCII chuẩn** (`linh_giao`, `hoa_mai`, `than_cong`, ...) dùng chung cho units.csv, tên file và khóa dịch.
11. **06 dòng 49:** camera bám theo quân máy thì sẽ làm lộ quân trong sương. Chỉ bám khi quân đó đang được thấy.
12. **04 dòng 180, 186:** màn 9 đặt "cổng ô" ở phía nam, gần chỗ quân ta xuất phát, nên "tới cổng thành" quá dễ. Vẽ lại bố cục hoặc đổi mục tiêu thành "tới ô thành Thăng Long sau khi qua đầu cầu".
13. **02 dòng 82:** danh sách quân chiếm làng ghi bằng tên (thiếu trường mâu, quân Lê, đang có ở 03 dòng 43, 50). Dùng thẻ `chiem_lang`.
14. **02 dòng 158:** cầu phao đứt thì quân trên cầu bị hạ, nhưng thủy binh lẽ ra phải sống. Thêm ngoại lệ, và báo trước một lượt (cầu rung) để người chơi không mất Quang Trung oan.
15. **06 dòng 24 (ASCII):** "Công 55–65" không khớp với loại quân nào. Không quan trọng nhưng dễ làm agent hiểu nhầm.
16. **09 dòng 5:** câu "Thời lượng phụ thuộc số người trong nhóm" đã lỗi thời, xem Q12.
17. **04 dòng 206 và 211** vẫn dùng nhãn "[Sử liệu về lễ hội hiện đại]" và "[Hư cấu đời sau: vở kịch của Trúc Đường, 1964]". Điều này trái với luật mới ở 05 dòng 83 (chỉ có bốn nhãn), và 05 dòng 43 đã đổi cảnh cành đào thành *Tương truyền*. Sửa 04 theo 05.
18. **04 dòng 49–50** ghi người báo tin là "Nguyễn Văn Tuyết, *Sử liệu*", trong khi 05 (bảng nhân vật và dàn ý cảnh, sau commit `1f812c2`) đã đổi thành *Theo HLNTC*, và việc đồng nhất người báo tin với Nguyễn Văn Tuyết chỉ là suy luận. Sửa 04 theo 05.

---

## Nguồn
- AE2: [Ancient Empires 2 – fandom](https://ancient-empires.fandom.com/wiki/Ancient_Empires_2), [Module:Unit data](https://ancient-empires.fandom.com/wiki/Module:Unit_data), [Ancient Empires (series) – Wikipedia](https://en.wikipedia.org/wiki/Ancient_Empires_(series)), [TL.net 2008](https://tl.net/forum/games/68295-ancient-empires-ii), [aeii.boards.net](https://aeii.boards.net/thread/343/strategy-walkthrough-tips-useful-information)
- Godot: [Multiple resolutions (4.2+)](https://docs.godotengine.org/en/4.2/tutorials/rendering/multiple_resolutions.html)
- NĐ 147/2024: [Công báo (bản gốc, chưa tải được)](https://congbaocdn.chinhphu.vn/CongBaoCP/VanBan/2024/11/43155/52696-1-20241263-1264147-2024-nd-cp.pdf), [Thư viện Pháp luật – G1–G4](https://thuvienphapluat.vn/phap-luat/ho-tro-phap-luat/game-g1-g2-g3-g4-la-gi-tu-172026-loai-game-nao-phai-xac-thuc-tai-khoan-nguoi-choi-276245.html), [LuatVietnam – điều kiện G2–G4](https://luatvietnam.vn/doanh-nghiep/dieu-kien-thu-tuc-de-cung-cap-dich-vu-tro-choi-dien-tu-g2-g3-g4-561-101208-article.html), [DAZPRO – mục lục NĐ 147](https://dazpro.com/vi/nd-147-2024-ve-internet-thong-tin-mang/), [Luật Phong Đằng](https://luatphongdang.vn/dich-vu-xin-giay-phep-game-g2-g3-g4/), [Gamota 2026](https://gamota.com/gamota-lab/game-publishing-regulations-in-vietnam-what-foreign-studios-need-to-know-in-2026/), [CCIA 30/7/2026](https://ccianet.org/wp-content/uploads/securepdfs/2026/07/2026-07-30-Vietnams-Online-Services-Reforms-Leave-Gaming-Barriers-Unresolved.pdf), [Digital Policy Alert – Sở VHTTDL](https://digitalpolicyalert.org/event/28920-departments-of-culture-sports-and-tourism-published-procedure-for-amending-licence-to-provide-g2-g3-g4-online-game-services-under-decree-1472024nd-cp), [Thanh Niên – NĐ 174/2026](https://thanhnien.vn/tu-17-khong-xac-thuc-tai-khoan-game-co-the-bi-phat-60-trieu-dong-185260526224244509.htm), [PocketGamer.biz](https://www.pocketgamer.biz/vietnam-issues-decree-1472024-to-regulate-online-games-and-internet-services)
