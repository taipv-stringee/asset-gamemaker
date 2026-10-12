# Rà soát lịch sử — tài liệu thiết kế game Quang Trung

Phạm vi: README.md, docs/01–09, đối chiếu với docs/nghien-cuu/bao-cao-lich-su.md và ghi-chu/*.md. Chỉ báo cáo, không sửa file.

**Giới hạn của lần rà soát này:** WebFetch không chạy được (DNS lỗi với zh.wikisource.org). WebSearch chạy nhưng kết quả về sử liệu Hán văn rất nghèo. Vì vậy phần lớn kết luận dựa vào (a) phép tính thiên văn tự làm, (b) kiến thức nền của người rà soát và (c) việc đối chiếu nội bộ giữa tài liệu và ghi chú nghiên cứu. Mức tin cậy ghi ở từng mục. "Không chắc" nghĩa là không chắc.

---

## 0. Kiểm tra lịch âm – dương (tự tính)

Cách làm: tính thời điểm sóc (trăng mới) bằng thuật toán Meeus, là thuật toán mà lịch âm Việt Nam của Hồ Ngọc Đức cũng dùng. Script nằm ở `scratchpad/newmoon.py`. Kết quả theo giờ UTC+7:

| Sóc (UTC+7) | Mở đầu tháng |
|---|---|
| 29/10/1788 10:13 | tháng 10 Mậu Thân |
| 28/11/1788 01:02 | tháng 11 (chứa Đông chí 21/12) |
| 27/12/1788 18:33 | tháng Chạp |
| 26/01/1789 13:33 | tháng Giêng Kỷ Dậu |

Hệ quả:
- 25/11 Mậu Thân = **22/12/1788** ✔. Mùng 5 Giêng = **30/01/1789** ✔ (Tết Kỷ Dậu là 26/01/1789, khớp lịch nhà Thanh).
- Tháng 11 Mậu Thân **thiếu** (29 ngày, từ 28/11 đến 26/12). Tháng Chạp **đủ 30 ngày** (từ 27/12/1788 đến 25/01/1789). Vì vậy **năm ấy có ngày 30 tháng Chạp**, và "đêm 30 Tết" tồn tại.
- 30 Chạp = 25/01/1789; mùng 1 = 26/01; mùng 3 = 28/01; mùng 4 = 29/01; mùng 7 = 01/02/1789; 20 Chạp = 15/01/1789; 29/11 = 26/12/1788; 20–21/11 = 17–18/12/1788; 28/10 (ngày quân Thanh ra Trấn Nam Quan) = **25/11/1788**.
- Mọi ngày "(quy đổi)" trong 04 và trong báo cáo nghiên cứu đều **đúng**.
- Độ vững: hai ranh giới của tháng Chạp (sóc 18:33 ngày 27/12 và 13:33 ngày 26/01) cách nửa đêm nhiều giờ. Vì vậy kết luận "có 30 Chạp, Tết = 26/01" gần như không đổi dù lịch Vạn Toàn của Lê (gốc Thụ Thời/Đại Thống) có sai số vài giờ so với thiên văn hiện đại. Điểm sát nhất là sóc 28/11/1788 lúc 01:02, chỉ cách nửa đêm khoảng 1 giờ. Nếu lịch thời ấy đặt sóc trước nửa đêm thì mùng 1 tháng 11 là 27/11 và 25/11 sẽ là 21/12. Tôi **không chắc** lịch Lê/Tây Sơn năm 1788 trùng với tính toán hiện đại ở điểm này. Tuy vậy mốc 22/12/1788 được nhiều nguồn ghi giống nhau, nên vẫn nên dùng.
- Đề xuất: bỏ ghi chú "phải kiểm bảng lịch" ở 04:4–5 (hoặc ghi "đã kiểm bằng tính sóc"), và thêm ngày dương cho màn 7 (29–30/01) và cho mốc 28/10 (25/11/1788).

---

## 1. NGHIÊM TRỌNG

### N1. Chi tiết lấy từ HLNTC bị gắn nhãn *[Sử liệu]* (Hà Hồi, Ngọc Hồi)
- **File**: 04-chien-dich.md:127–129, 135 ("đúng như sử chép"); 04:157–160; 05-cot-truyen.md:99.
- **Tài liệu ghi**: Hà Hồi "bí mật vây đồn… bắc loa gọi hàng; quân Thanh không kịp kháng cự, đều ra hàng" có nhãn *[Sử liệu]*. Ngọc Hồi gồm mộc thuẫn, đê Yên Duyên, Đầm Mực, "hơn 100 voi" có nhãn *[Sử liệu; chi tiết lệch nhau]*.
- **Vấn đề**: Đoạn Hà Hồi gần như trùng từng chữ với HLNTC hồi 14 ("Nửa đêm ngày mồng 3 tháng giêng năm Kỷ Dậu, vua Quang Trung đến làng Hà Hồi, huyện Thượng Phúc, lặng lẽ vây kín làng ấy, rồi bắc loa truyền gọi, quân lính luân phiên dạ ran…"). Các "nguồn" mà báo cáo dẫn (gialai.dcs.vn, Wikipedia, phuongnam) đều là bản tóm tắt HLNTC. Tương tự, mộc thuẫn (ván ghép, 20 bức, 10 người khiêng), đê Yên Duyên, Đầm Mực và làng Quỳnh Đô đều là lời HLNTC. Chỉ có hai chi tiết được nguồn Thanh xác nhận: việc "đội ván" và vua "thúc voi đốc đằng sau". Sự kiện Hà Hồi thất thủ là thật, nhưng chi tiết bắc loa và hàng không đổ máu là **Theo HLNTC**. Bốn nhãn nguồn là điểm bán hàng chính của dự án, nên gán nhầm nhãn ở đúng màn trưng bày là lỗi nặng nhất.
- **Bằng chứng**: Đối chiếu ghi-chu/dien_bien_chien_dich.md:113–118 (mọi URL đều là tóm tắt HLNTC hoặc trang dựa trên nó). Văn bản HLNTC hồi 14 theo trí nhớ của người rà soát (bản SGK Ngữ văn 9). Tin cậy: cao về nguồn gốc HLNTC; trung bình về việc *Cương mục*/*Liệt truyện* có chép lại hay không (chưa đọc được).
- **Sửa**: Màn 6 ghi "*[Sự kiện: Sử liệu; chi tiết vây, loa, hàng: Theo HLNTC]*". Ở 04:135, đổi "đúng như sử chép" thành "đúng như HLNTC kể". Màn 8 tách nhãn: "đội ván, vua cưỡi voi đốc chiến: Sử liệu (sử Thanh)"; "60 ván/20 bức, đê Yên Duyên, Đầm Mực: Theo HLNTC"; "địa lôi giẫm phải: Liệt truyện (qua Wikipedia, chưa kiểm)". Sửa cả bảng "Ba tầng sự thật" của báo cáo (dòng 104).

### N2. "Hà Hồi … bắt hơn 3.400 tù binh": gộp nhầm con số
- **File**: 02-luat-choi.md:108–109 (và báo cáo bao-cao-lich-su.md:160).
- **Tài liệu ghi**: Cơ chế chiêu hàng dựa trên "việc đồn Hà Hồi đầu hàng sau khi bị gọi hàng và quân Tây Sơn bắt hơn 3.400 tù binh".
- **Vấn đề**: Con số "ít nhất 3.400 bị bắt" lấy từ infobox Wikipedia tiếng Anh và là con số cho **toàn trận Ngọc Hồi – Đống Đa**, không phải cho Hà Hồi (bao-cao:51; dien_bien:141). Không nguồn nào trong bộ nghiên cứu cho quân số hay số hàng binh ở Hà Hồi (dien_bien:158).
- **Tin cậy**: cao (lỗi đọc nguồn nội bộ).
- **Sửa**: "dựa trên việc đồn Hà Hồi hàng sau khi bị vây và gọi hàng (theo HLNTC), và việc quân Tây Sơn bắt nhiều tù binh trong chiến dịch (Wikipedia tiếng Anh ghi ít nhất 3.400 cho toàn trận, chưa kiểm nguồn gốc)".

### N3. Sơ đồ năm đạo trộn hai hệ thống, không khớp với nguồn nào
- **File**: 04-chien-dich.md:87–89; 05-cot-truyen.md:96.
- **Tài liệu ghi**: Năm mũi tên gồm đạo Quang Trung; Đô đốc Long đánh Khương Thượng; Đô đốc Bảo qua Đại Áng; "thủy quân Tuyết, Lộc vào Lục Đầu"; và "đạo còn lại".
- **Vấn đề**:
  - Theo HLNTC hồi 14 (ghi-chu/dien_bien:89): tiền quân (Đại tư mã Sở, Nội hầu Lân); hậu quân (Hám Hổ hầu); hữu quân cùng thủy quân (Đại đô đốc Lộc, Đô đốc Tuyết); tả quân cùng tượng mã (Đại đô đốc Bảo, Đô đốc **Mưu**); trung quân do vua.
  - Theo sơ đồ sách giáo khoa hiện đại (ghi-chu/quan_luc_vu_khi:94): đạo chủ lực của vua; đạo Đô đốc Long (Khương Thượng); đạo Đô đốc Bảo (Đại Áng); đạo **thứ tư** Đô đốc Tuyết (Hải Dương); đạo **thứ năm** Đô đốc Lộc (Lạng Giang – Phượng Nhãn – Yên Thế).
  - Tài liệu gộp Tuyết và Lộc thành một đạo rồi bịa thêm "đạo còn lại". Như vậy nó sai với cả hai hệ. Ngoài ra tài liệu không nhắc rằng theo HLNTC, Sở và Lân là **tiên phong**, một chi tiết nên đưa vào màn 4–6.
- **Tin cậy**: cao về sự không khớp. Trung bình về chi tiết HLNTC, vì nhóm nghiên cứu chưa đọc nguyên văn.
- **Sửa**: Chọn một hệ cho sa bàn. Ví dụ dùng sơ đồ hiện đại: QT; Long; Bảo; Tuyết (Hải Dương); Lộc (Lạng Giang). Đặt mục Sử liệu "Năm đạo theo HLNTC" bên cạnh, nêu rõ HLNTC chia theo tiền/hậu/tả/hữu/trung, có Sở – Lân làm tiên phong và Bảo – Mưu cùng tả quân.

---

## 2. TRUNG BÌNH

### T1. Địa lý bản đồ màn 8 sai hướng
- **File**: 04-chien-dich.md:161–162, 165.
- **Tài liệu ghi**: "Tây: Đầm Mực và đê Yên Duyên. Đông nam: lối ra của đạo Đại Áng."
- **Vấn đề**: Đạo Bảo "tiếp ứng mặt tả" (HLNTC; bao-cao:139 cũng ghi "cánh trái"). Với quân tiến lên bắc, cánh trái là **phía tây**. Theo hiểu biết của tôi, xã Đại Áng (Thanh Trì) nằm ở phía tây/tây nam Ngọc Hồi, không phải đông nam. Đầm Mực (làng Quỳnh Đô, nay thuộc Vĩnh Quỳnh) và đê Yên Duyên (Yên Sở, Hoàng Mai) nằm ở **phía bắc** Ngọc Hồi, trên đường tàn quân chạy về Thăng Long. Đó là lý do quân Thanh bỏ chạy thì gặp phục binh ở đó.
- **Tin cậy**: trung bình – cao về hướng Đại Áng (kiến thức nền; WebSearch chỉ ra tin rao bất động sản ghi "Đại Áng giáp Ngọc Hồi", không cho hướng). Trung bình về vị trí Yên Duyên và Quỳnh Đô.
- **Sửa**: Đặt lối ra Đại Áng ở mép **tây/tây nam**. Đặt Đầm Mực và đê Yên Duyên ở **phía bắc, sau đồn**, có thể làm vùng "đường rút của địch". Mục tiêu phụ "dồn quân Thanh vào Đầm Mực" vẫn giữ được. Nên kiểm lại bằng bản đồ hành chính Thanh Trì.

### T2. Vị trí Tôn Sĩ Nghị ở màn 9 mâu thuẫn với chính sự kiện cầu phao
- **File**: 04-chien-dich.md:180–185.
- **Tài liệu ghi**: "bờ bắc là doanh trại Tôn Sĩ Nghị"; Tôn Sĩ Nghị đứng "bờ bắc, chế độ *Chạy*"; nhưng cầu đứt "khi Tôn Sĩ Nghị qua hết cầu".
- **Vấn đề**: Nếu Nghị khởi đầu ở bờ bắc thì ông không có cầu nào để qua. Cả hai phiên bản nguồn đều cho Nghị **từ bờ nam (phía Thăng Long) vượt sang bờ bắc**. Theo sử Thanh, ông "đoạt đường qua sông" trong khi Hứa Thế Hanh giữ bờ nam. Theo HLNTC, ông chạy qua cầu phao. Báo cáo cũng ghi bản doanh nằm ở "bãi cát **hai bờ** sông Nhị" (bao-cao:13).
- **Tin cậy**: cao (mâu thuẫn nội bộ cộng với cả hai nguồn).
- **Sửa**: Cho Tôn Sĩ Nghị bắt đầu ở đầu cầu bờ nam hoặc trên cầu, chế độ *Chạy* sang bờ bắc. Doanh trại có thể vẽ ở cả hai bờ.

### T3. Hứa Thế Hanh "chết khi chặn hậu" được trình bày là sự thật duy nhất
- **File**: 01-tong-quan.md:79; 02-luat-choi.md:103–104 ("đúng như sử liệu (… Hứa Thế Hanh chết khi chặn hậu)"); 05:101 (nhãn "Sử liệu (sử Thanh)" cho cảnh rút về sông).
- **Vấn đề**: 04:169–170 và quy tắc 6 ở 05:81–82 yêu cầu giữ cả hai phiên bản (sử Việt phổ biến nói ông chết ở Ngọc Hồi; sử Thanh nói ông chết ở bờ sông). Nhưng 01 và 02 lại chọn bản sử Thanh và gọi đó là "sử liệu". Ngoài ra, cảnh "Hứa Thế Hanh rút về sông" ở màn 8 là sáng tạo để dung hòa hai bản, không phải sử liệu.
- **Sửa**: 01:79 sửa thành "Hứa Thế Hanh (sử Thanh: ở lại chặn hậu)". 02:104 sửa thành "theo nguồn, và trình bày cả hai bản khi các nguồn khác nhau". 05:101 đổi nhãn thành *Sáng tạo của game (dung hòa hai bản)*.
- **Bổ sung có lợi**: Theo Wikipedia tiếng Anh ("Xu Shiheng"), Hứa Thế Hanh là người **Hồi** (Hui) quê Tân Đô, Thành Đô; Sầm Nghi Đống là thổ ty người Tráng. Như vậy "quân Thanh" không đồng nghĩa với "người Hán" (05:124 định nghĩa Lục doanh là "quân chính quy người Hán"). Nên nêu điều này trong codex. Đây cũng là một lý do nữa để tránh mọi cách gọi theo sắc tộc. Tin cậy: trung bình (Wikipedia).

### T4. Nhãn ngoài bộ bốn nhãn
- **File**: 04:206 "*[Sử liệu về lễ hội hiện đại]*"; 04:211 "**[Hư cấu đời sau: vở kịch của Trúc Đường, 1964]**"; 05:43 "có nhãn hư cấu"; 05:97 "Sáng tạo dựa trên sử liệu"; 05:102 "Hai phiên bản".
- **Vấn đề**: README:40, 05:8 và 08:62 (enum `nhan_nguon` chỉ có 4 giá trị) quy định mỗi chi tiết gắn **đúng một** trong bốn nhãn. Các nhãn trên sẽ không biểu diễn được trong dữ liệu.
- **Sửa**: Cành đào gắn *Tương truyền*, với ghi chú "một số nhà nghiên cứu (Tôn Thất Thọ, Tạp chí Đáng Nhớ) truy về vở kịch của Trúc Đường năm 1964; GS Trần Quốc Vượng cho là không có thật". Lễ hội gò Đống Đa gắn *Sử liệu*, với ghi chú "hiện tại". Cảnh bản doanh gắn *Sáng tạo của game*. Cảnh cầu phao: lời thoại gắn *Sáng tạo*, hai mục Sử liệu gắn *Sử liệu (Thanh)* và *Theo HLNTC*. Một cách khác là thêm nhãn thứ năm, nhưng khi đó phải sửa README, 05 và 08 cùng lúc.

### T5. "Lễ cầu siêu cho tử sĩ cả hai bên" ngầm đặt vào năm 1789
- **File**: 04:206; 01:79–80.
- **Vấn đề**: Câu "Lễ cầu siêu cho tử sĩ cả hai bên, nối tới lễ hội gò Đống Đa ngày nay" khiến người đọc hiểu là năm 1789 có lễ cầu siêu cho cả hai phía. Bộ nghiên cứu không có nguồn cho một nghi lễ như vậy năm 1789. Nguồn duy nhất về nghi thức cầu siêu cho lính Thanh là một bài blog của FPT Shop, nói về lễ hội **hiện nay** (nguon_su_lieu:160). Có một ý kiến (Zhihu, độ tin thấp) rằng nhà Thanh **đòi** lập đền thờ tướng sĩ Thanh trong điều kiện giảng hòa. Nếu đúng thì đó là yêu cầu ngoại giao, không phải lễ cầu siêu tự nguyện.
- **Tin cậy**: cao về việc thiếu nguồn.
- **Sửa**: Tách thành hai cảnh. (a) Lễ hội gò Đống Đa mùng 5 Tết ngày nay có nghi thức cầu siêu (Sử liệu, ghi nguồn tốt hơn FPT Shop, ví dụ Sở VHTT Hà Nội). (b) Nếu muốn có cảnh năm 1789 thì gắn *Sáng tạo của game*. Nên tìm thêm văn tế tử sĩ do Ngô Thì Nhậm hoặc Phan Huy Ích soạn (tôi không chắc văn bản này có tồn tại).

### T6. Tỷ lệ Lục doanh 60% điểu thương được nêu như quy chế chung
- **File**: 03-don-vi-dia-hinh.md:38; 04:166–167.
- **Tài liệu ghi**: "Quân Thanh dựng theo quy chế Lục doanh: cứ 1.000 lính có 600 điểu thương, 200 cung tiễn, 100 đằng bài, 100 pháo thủ."
- **Vấn đề**: Tỷ lệ này lấy từ **một bài Zhihu** về các doanh **Vân – Quý**. Cùng ghi chú đó (quan_luc_vu_khi:114) dẫn quy định năm Ung Chính 5 (1727): tỉnh nội địa 300 khẩu điểu thương trên 1.000 lính, tỉnh biên giới hoặc ven biển 400. Như vậy hai con số mâu thuẫn nhau. Đạo chính binh ở Ngọc Hồi là Lục doanh **Lưỡng Quảng**, không phải Vân – Quý.
- **Sửa**: Ghi "tỷ lệ theo một nguồn về doanh Vân – Quý (Zhihu, chưa kiểm); quy định năm 1727 cho tỉnh biên giới là khoảng 40% điểu thương. Game dùng tỷ lệ cách điệu". Trong codex gắn *Sáng tạo của game (dựa trên quy chế)*.

### T7. Quy tắc trang phục "không nón" tuyệt đối hơn bằng chứng cho phép
- **File**: 07-mi-thuat-am-thanh.md:24–25, 32.
- **Tài liệu ghi**: Phần "Không làm" có "Nón chóp, nón dấu…; quân phục đồng phục; giáp". Phần "Màu đỏ" dùng *Lê quý dật sử* cho "áo đỏ tía". Voi chiến: "3–4 lính chít khăn đỏ, ném hỏa cầu — Sử Thanh".
- **Vấn đề**:
  1. Chính câu *Lê quý dật sử* mà tài liệu dẫn ghi quân Tây Sơn "mặc áo đỏ tía, **chỏm mũ đính lông chiên đỏ**" (hinh_anh_trang_phuc:25). Như vậy có ít nhất một nguồn nói tới một loại **mũ** có chỏm lông đỏ. Tài liệu lấy màu áo của câu này nhưng bỏ phần mũ.
  2. Kết luận "nón dấu là của lính lệ thời Nguyễn" được chính báo cáo ghi là **suy luận** (bao-cao:167). Vậy mà 07 đưa nó vào cột "Không làm" như sự thật.
  3. Chi tiết "khăn đỏ" của quân voi chỉ có qua Wikipedia tiếng Việt dẫn lại sử Thanh. Ghi chú nghiên cứu nói rõ "chưa xác minh được nguyên văn" (hinh_anh_trang_phuc:53).
  4. Tranh của Alexander vẽ lính Đàng Trong năm 1793 (vùng Tourane), không phải đạo quân Bắc tiến năm 1789.
- **Tin cậy**: cao (đọc từ chính ghi chú nghiên cứu).
- **Sửa**: Đổi cột "Không làm" thành "Tránh (chưa có bằng chứng thế kỷ 18)". Thêm phương án "mũ có chỏm lông đỏ (*Lê quý dật sử*)" cho một số lính, ví dụ quân Nghệ An. Ghi chú nguồn "khăn đỏ: Wikipedia dẫn sử Thanh, chưa kiểm nguyên văn".

### T8. Nguyễn Văn Tuyết: nhãn và việc đồng nhất hai người
- **File**: 04:49–50; 05:36, 93.
- **Tài liệu ghi**: Người báo tin là "(Nguyễn Văn Tuyết, *Sử liệu*)". Bảng nhân vật ghi "Nguyễn Văn Tuyết (Đô đốc Tuyết) … Sử liệu (báo tin); thủy quân theo HLNTC".
- **Vấn đề**: Ghi chú nhan_vat:50 và 187 gắn chi tiết "Văn Tuyết phi ngựa vào Phú Xuân" nhãn **[HLNTC]**. Nguồn còn lại chỉ là Wikipedia tiếng Anh. Việc coi người đưa tin "Văn Tuyết" và vị "Đô đốc Tuyết" chỉ huy thủy quân là một người là **suy luận** của nhóm làm game. Chưa nguồn nào trong bộ nghiên cứu khẳng định điều này. Chi tiết "phi ngựa" cũng chưa có nguồn.
- **Sửa**: Gắn nhãn *Theo HLNTC*. Ghi "có thể là cùng người với Đô đốc Tuyết (chưa xác nhận)". Bỏ chữ "phi ngựa" hoặc gắn *Sáng tạo*.

### T9. Quân số "chênh 25 lần" là phép tính sai
- **File**: 05:112; báo cáo bao-cao:3, 45.
- **Vấn đề**: Báo cáo đặt hai đầu là "khoảng 18.000" và "29 vạn". 290.000 / 18.000 ≈ **16 lần**. Chỉ khi lấy 500.000 / 20.000 mới ra 25 lần, mà con số 500.000 bị Wikipedia gắn cờ "failed verification".
- **Tin cậy**: cao (số học).
- **Sửa**: Viết "chênh khoảng 16 lần (18.000 so với 29 vạn); nếu tính cả con số 500.000 chưa kiểm chứng thì còn chênh hơn".

### T10. Gián Khẩu: "diệt đồn" cùng quân Thanh đi tuần là chi tiết chưa có nguồn
- **File**: 04:96–97, 103.
- **Vấn đề**: Nguồn chỉ nói đây là đồn tiền tiêu của quân Lê. Theo trí nhớ của tôi về HLNTC, quân Lê ở sông Gián thấy quân Tây Sơn thì "tan vỡ chạy trước", tức là không có trận đánh lớn. Tôi **không chắc** về câu chữ chính xác. Việc đặt "2 điểu thương binh Thanh đi tuần" ở Gián Khẩu không có nguồn nào.
- **Sửa**: Gắn *Sáng tạo của game* cho đội tuần Thanh và cho cơ chế trống báo động. Trong Sử liệu ghi "quân Lê ở đồn tan chạy (theo HLNTC)" sau khi đối chiếu bản dịch.

---

## 3. NHỎ

1. **"Trưa mùng 5" được nêu như chắc chắn** — README.md:4; 01-tong-quan.md:53; 04:205 ("*[Sử liệu]*"). Nguồn ghi "trưa" hoặc "chiều" (bao-cao:32; nhan_vat:22 dẫn QĐND ghi "chiều"). 04:178 thì đã viết đúng "trưa hoặc chiều". Sửa thành "mùng 5"; nếu giữ chữ "trưa" thì gắn *Theo HLNTC*.
2. **Thượng Duy Thăng có phải "Tổng binh" không** — 03:75; 05:54. Ghi chú nhan_vat:118 nói chức của ông chưa rõ (phó tướng 副將 hay tổng binh). Bài Znews dẫn *Đại Nam liệt truyện* chỉ gắn chữ "Tổng binh" rõ ràng với Trương Triều Long. Tôi **không chắc**; trí nhớ của tôi nghiêng về phó tướng. Sửa: ghi "võ quan Thanh (Tổng binh hoặc Phó tướng, cần tra *Thanh sử cảo* quyển 334)".
3. **Mũ Tôn Sĩ Nghị** — 07:29; 05:51; 04:209. Đỉnh hồng ngọc của ông là **ân thưởng đặc biệt**, ban kèm tước **Nhất đẳng Mưu dũng công** (一等謀勇公, Wikipedia "Sun Shiyi") sau khi chiếm Lê thành vào tháng 11–12/1788. Vì vậy:
   - Ở cảnh "quân Thanh vượt Trấn Nam Quan" (05:91, tháng 11/1788), đỉnh san hô của phẩm 2 có thể **đúng hơn**. Bản nháp dùng san hô không hẳn sai. Tôi không chắc phẩm của ông khi đó.
   - Việc bị lột mũ là theo chiếu chỉ ban sau, vài tuần sau ngày mùng 5, không phải ngay sau màn 9.
   - Nên thêm tước "Mưu dũng công" vào 05:51.
   - Lời kết nên nói thêm rằng về sau ông được khởi phục (theo kiến thức nền: ông làm quan lớn trở lại và mất năm 1796), để công bằng với nhân vật.
4. **"Áo bào đỏ… sạm đen khói súng"** — 05:31; 07:27. Mọi nguồn tìm được đều là văn mẫu. Tôi **không chắc** chi tiết này nằm trong nguyên văn HLNTC hay là lời diễn của sách giáo khoa. Cần đưa vào danh sách đối chiếu ở 09 mục 3.
5. **Nguyễn Thiếp** — 04:75. Theo HLNTC, Quang Trung *vời* Nguyễn Thiếp **vào doanh**, không phải nhà vua tới làng của ông. Cơ chế "Quang Trung đứng vào làng" cần gắn *Sáng tạo*.
6. **"10 vạn quân, hơn 200 voi"** — 03:125; 04:69–70. Câu này đặt trong ngoặc kép như trích nguồn, nhưng thực ra lấy từ báo và trang tem. *Liệt truyện* chỉ ghi "hơn mười vạn". Sửa: "theo nhiều bài hiện đại; *Liệt truyện* ghi 'hơn mười vạn'".
7. **Bùi Thị Xuân** — 05:41. Viết "không có nguồn nào cho thấy bà ở Đống Đa" là quá mạnh, vì báo phổ thông vẫn khẳng định điều đó. Nên viết "không có sử liệu gốc; Bảo tàng Lịch sử Quốc gia không xác nhận".
8. **Chi tiết ngoại hình bịa nhưng gắn nhãn nguồn** — 05:34 (Phan Văn Lân "võ tướng trẻ"), 05:38 (Đô đốc Bảo "cưỡi voi"), 05:35 ("áo nâu"). Các chi tiết này nằm trong hàng có nhãn "Sử liệu" hoặc "Theo HLNTC". Nên ghi riêng nhãn *Sáng tạo* cho ngoại hình.
9. **Đường hành quân trên bản đồ chiến dịch** — 04:30–31. Khương Thượng không nằm trên trục của đạo chủ lực. Đạo Long/Mưu đi Chương Đức (Chương Mỹ) → Nhân Mục. Nên vẽ một mũi tên riêng.
10. **Tên "Đống Đa" năm 1789** — 04:20, 143. Nhiều người giải thích tên "Đống Đa" ra đời sau trận đánh (các đống xác). Tôi **không chắc** cách giải thích này đúng. Nếu đúng thì nhãn màn năm 1789 nên dùng "Khương Thượng", còn chữ "Đống Đa" để dành giải thích trong codex.
11. **Kỵ binh Thanh** — 03:39 ghi "không có kỵ binh (không có nguồn)". Lục doanh có mã binh (ghi chú hinh_anh:105). Viết đúng là "không thấy ghi chép về kỵ binh Thanh ở Ngọc Hồi". Quyết định thiết kế không đổi.
12. **Đô đốc Long trong codex** — 05:61–67. Câu "trình bày cả 4 thuyết, không kết luận" có thể gây hiểu nhầm về sức nặng học thuật. Thuyết Đặng Tiến Đông là của GS Phan Huy Lê và đã được Hà Nội công nhận qua tên phố từ năm 1986. Ý kiến phản bác là của một nhà báo. Nên trình bày theo mức độ ủng hộ. Không gán họ cho Đô đốc Long là có thể làm dòng họ Đặng (Lương Xá, Chương Mỹ) phật lòng; ngược lại, gán họ thì làm các dòng họ khác phật lòng. Rủi ro có ở cả hai phía, nên cần một câu giải thích lịch sự.
13. **"Giả vương" năm 1790** được viết như sự thật — 04:213. Đây là điểm còn tranh cãi; Nguyễn Duy Chính có thể cho rằng người sang là vua thật. Nên viết "chuyến sứ bộ Nhiệt Hà năm 1790 (tranh cãi thật/giả)".
14. **Phan Văn Lân hay Nguyễn Văn Lân** — 05:34. Ghi chú quan_luc_vu_khi:93 có chỗ ghi "Nội hầu cho Nguyễn Văn Lân". Tôi không chắc tên nào đúng; nên ghi chú cả hai cách gọi.
15. **Âm nhạc** — 07:109–110. Ghi "tránh tạo cảm giác 'nhạc Trung Hoa' cho phe Tây Sơn" nhưng lại dùng "chũm chọe" để ám chỉ phe Thanh. Cách này có nguy cơ rập khuôn, và chũm chọe vốn cũng có trong nhạc lễ Việt. Nên mô tả bằng chất liệu cụ thể, ví dụ kèn và trống đồng hành quân của Lục doanh, thay cho "không khí Trung Hoa".
16. **Lê Chiêu Thống "bi kịch"** — 05:55. Cách khắc họa này hợp với nghiên cứu mới, nhưng đi ngược cách nhìn phổ biến ở Việt Nam ("cõng rắn cắn gà nhà"). Nên có mục codex giải thích vì sao chọn cách này, để tránh phản ứng.
17. **Ngày quân Thanh ra Trấn Nam Quan** — 04:39. Nên thêm ngày dương 25/11/1788 (tính ở mục 0).
18. **Câu Lê Quýnh** — 04:207. Đây là bản dịch tiếng Việt, qua damau.org (khảo cứu của Nguyễn Duy Chính), của văn bản chữ Hán. Sự việc xảy ra ở Trung Quốc sau năm 1790, ngoài khung "1789–1790". Nên ghi "bản dịch của …", ghi năm, và đối chiếu nguyên văn *Bắc hành lược ký*.

---

## 4. Lỗi trong chính báo cáo nghiên cứu và ghi chú (đã hoặc có thể lan sang tài liệu)

1. **Gán nhãn "Sự kiện (đa số nguồn)" cho chi tiết của HLNTC** — bao-cao:27, 104, 106. "Đa số nguồn" về Hà Hồi đều là bản tóm tắt HLNTC, không phải các nguồn độc lập. Lỗi này lan sang N1.
2. **"3.400 tù binh" gắn với Hà Hồi** — bao-cao:160. Con số là của toàn trận. Lỗi này lan sang N2.
3. **Phép tính "chênh 25 lần"** — bao-cao:3, 45. Đúng ra khoảng 16 lần. Lỗi này lan sang T9.
4. **Bỏ quy định Ung Chính 5 (30–40% điểu thương)** — bao-cao:55. Báo cáo chỉ giữ tỷ lệ 60% của Vân – Quý và trình bày nó như khung chung. Lỗi này lan sang T6.
5. **"Không có bằng chứng nào cho thấy lính Tây Sơn đội nón"** — bao-cao:3, 77–81. Kết luận này đúng với nón dấu, nhưng báo cáo bỏ qua chi tiết "chỏm mũ đính lông chiên đỏ" của *Lê quý dật sử*, mà chính báo cáo có trích ở dòng 81. Chi tiết "khăn đỏ" của sử Thanh cũng chưa được kiểm nguyên văn. Lỗi này lan sang T7.
6. **Mâu thuẫn về ai cắt cầu phao theo HLNTC** — ghi-chu/dien_bien_chien_dich.md:135 viết "theo HLNTC: Tôn Sĩ Nghị sai chặt cầu phao". Báo cáo (bao-cao:41) và nhan_vat:181 lại viết HLNTC cho rằng cầu gãy do quân chen nhau. Theo trí nhớ của tôi về HLNTC hồi 14 ("tranh nhau qua cầu… lát sau cầu lại bị đứt… nước sông Nhị Hà vì thế mà tắc nghẽn"), **báo cáo đúng, dien_bien:135 sai**. Tin cậy: trung bình – cao.
7. **Đô đốc Bảo thuộc "hữu quân"** — nhan_vat:45. Dòng này mâu thuẫn với dien_bien:89 và bao-cao:71, vì theo HLNTC Bảo và Mưu cùng **tả quân**. Tài liệu game dùng đúng bản "cánh trái".
8. **"Đại đô đốc Tuyết"** — dien_bien:89. Báo cáo ghi "Đô đốc Tuyết", và tôi nhớ HLNTC cũng ghi như vậy. Đây là lỗi chép nhỏ.
9. **"出白馬關"** — quan_luc_vu_khi:12. Có lẽ đúng là **馬白關** (Mã Bạch quan, vùng Mã Quan, Văn Sơn, Vân Nam), cửa ải cánh quân Ô Đại Kinh đi ra để vào Tuyên Quang. Tin cậy: trung bình, không kiểm được qua web. Tài liệu game không dùng chi tiết này.
10. **Quy đổi 28/10** — dien_bien:14 ghi "≈ 25–26/11". Đúng ra là **25/11/1788**, vì tháng 10 bắt đầu ngày 29/10/1788.
11. **Phẩm hàm Tôn Sĩ Nghị** — hinh_anh_trang_phuc:118 viết "chưa xác minh được ông có tước công hay không". Wikipedia tiếng Anh ("Sun Shiyi") ghi ông được phong **一等謀勇公**. Báo cáo cũng không giải thích rằng đỉnh hồng ngọc là ân thưởng kèm tước này.
12. **"Càn Long truy tặng Hứa Thế Hanh tước bá"** — nguon_su_lieu_tranh_cai:24. Tôi **không chắc**; trí nhớ của tôi là tước tử (子爵). Cần tra *Thanh sử cảo* quyển 334. Tài liệu game không dùng chi tiết này.
13. **Nguồn gốc chuyện cành đào** — bao-cao:117. Báo cáo viết "bắt nguồn từ vở kịch của Trúc Đường (1964)" như kết luận chắc chắn. Thực ra đây là ý kiến của Tôn Thất Thọ và Tạp chí Đáng Nhớ; Hội Di sản Văn hóa Việt Nam nói giai thoại "có thể thật và không thật" (nhan_vat:184). Nên viết "theo một số nhà nghiên cứu". Lỗi này lan sang 04:211.
14. **Lễ cầu siêu cho lính Thanh** — bao-cao:189. Nguồn là một bài của FPT Shop, rất yếu. Lỗi này lan sang T5.

---

## 5. Những điểm đã kiểm và thấy ổn

- Gián Khẩu đêm 30 Chạp, Hà Hồi nửa đêm mùng 3, Ngọc Hồi mờ sáng mùng 5. Thứ tự các trận và ngày dương lịch quy đổi đều đúng (xem mục 0).
- Hứa Thế Hanh là **Đề đốc Quảng Tây** (廣西提督). Wikipedia tiếng Anh "Xu Shiheng" ghi "Provincial military commander of Guangxi, 1788–1789".
- Sầm Nghi Đống là thổ ty người Tráng ở Điền Châu, mang hàm tri phủ Điền Châu. Ông tự vẫn ngày 30/01/1789 (Wikipedia tiếng Anh "Cen Yidong").
- Tôn Sĩ Nghị là Tổng đốc Lưỡng Quảng. Ông bị lột đỉnh hồng ngọc và lông công hai mắt, cách chức; Phúc Khang An lên thay (*Thanh sử cảo* quyển 330, theo ghi chú).
- Câu "Đánh cho để dài tóc…" xử lý đúng: gắn *Tương truyền*, không đặt vào màn 4, chép đúng "chích luân bất phản, phiến giáp bất hoàn". Tôi đồng ý câu này không có trong HLNTC hồi 14 (tin cậy cao, theo kiến thức nền; web không truy được văn bản đầu tiên).
- Quy tắc từ ngữ: không dùng "giặc", không dùng "Tàu" trong giao diện. Quyết định không đặt tên bịa cho tướng giữ đồn cũng tốt.

## Nguồn web đã dùng trong lần rà soát này

- https://en.wikipedia.org/wiki/Xu_Shiheng (qua đoạn trích tìm kiếm)
- https://en.wikipedia.org/wiki/Sun_Shiyi (qua đoạn trích tìm kiếm)
- https://en.wikipedia.org/wiki/Cen_Yidong (qua đoạn trích tìm kiếm)
- https://en.wikipedia.org/wiki/Battle_of_Ng%E1%BB%8Dc_H%E1%BB%93i-%C4%90%E1%BB%91ng_%C4%90a (qua đoạn trích tìm kiếm)
- https://znews.vn/tran-ngoc-hoi-dong-da-230-nam-truoc-trong-su-sach-viet-trung-post914995.html (qua đoạn trích tìm kiếm)
- Tính sóc: scratchpad/newmoon.py (thuật toán Meeus)
