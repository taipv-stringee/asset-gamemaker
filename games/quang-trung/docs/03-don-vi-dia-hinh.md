# 03 — Đơn vị và địa hình

> Số liệu **khởi điểm**, sẽ cân bằng sau khi chơi thử. Khi dựng project, bảng ở đây chép sang `data/units.csv`,
> `data/terrain.csv`, `data/counters.csv` (xem [08](08-ky-thuat.md)); từ lúc đó CSV là nguồn chuẩn.
> Giá và vai so với AE2: xem [10-doi-chieu-ae2.md](10-doi-chieu-ae2.md).
>
> Cột **Nguồn** = độ bám sử của loại lính (theo [báo cáo nghiên cứu](nghien-cuu/bao-cao-lich-su.md)):
> **Cao** = sử liệu cả hai phía; **TB** = có nguồn nhưng gián tiếp; **Thấp** = sáng tạo hợp lý.

Ký hiệu: Công = khoảng công gốc; Thủ = thủ gốc; Di = điểm di chuyển; Tầm = cự ly đánh; Kiểu = *Bộ* / *Nặng* / *Voi* / *Thủy*.
Mọi quân có 100 máu tối đa.

## 1. Mã định danh (dùng chung cho CSV, tên file hình, khóa dịch)

| Mã | Tên hiển thị | Mã | Tên hiển thị |
|---|---|---|---|
| `linh_giao` | Lính giáo | `truong_mau` | Trường mâu binh |
| `hoa_mai` | Hỏa mai thủ | `dieu_thuong` | Điểu thương binh |
| `thuy_binh` | Thủy binh | `cung_tien` | Cung tiễn binh |
| `quan_su` | Quân sư | `dang_bai` | Đằng bài binh |
| `trong_tran` | Trống trận | `phao_binh` | Pháo binh |
| `hoa_ho` | Hỏa hổ | `tho_binh` | Thổ binh Điền Châu |
| `moc_thuan` | Mộc thuẫn | `trinh_sat` | Trinh sát |
| `than_cong` | Thần công | `quan_le` | Quân Lê |
| `voi_chien` | Voi chiến | `quan_giu_don` | Quan giữ đồn (Thanh) |
| `hang_binh` | Hàng binh | `quan_giu_don_le` | Quan giữ đồn (Lê) |

Tướng: `quang_trung`, `ngo_van_so`, `ngo_thi_nham`, `phan_van_lan`, `do_doc_long`, `do_doc_bao`, `do_doc_tuyet`, `do_doc_loc`,
`ton_si_nghi`, `hua_the_hanh`, `sam_nghi_dong`, `truong_trieu_long`, `thuong_duy_thang`.
Phe Diễn tập (màn 1–2) dùng lại mã quân Tây Sơn, chỉ khác phe.

## 2. Thẻ

| Thẻ | Nghĩa |
|---|---|
| `bo_binh` | "Bộ binh thường" cho khắc chế của voi |
| `ban_xa` | Đánh xa (khắc chế phòng thủ của mộc thuẫn, đằng bài) |
| `chan` | Tạo vùng khống chế (02 §3) |
| `voi` | Bị giáo / mâu / hỏa hổ khắc chế |
| `xung_phong` | Bỏ qua vùng khống chế; đi ≥ 3 ô **theo đường thẳng** trong lượt thì +10 công |
| `ban_dung` | Không đánh sau khi đi; không phản đòn |
| `chiem_lang` | Chiếm được làng |
| `tuong` | Chiếm được làng, đồn, thành; có kỹ năng riêng |
| `chieu_hang` | Chiêu hàng quân tan (02 §8) |
| `goi_hang` | Gọi hàng khu đồn bị vây (02 §11) |
| `khong_chay` | Không bị Cháy |

## 3. Quân Tây Sơn

| Mã | Vai AE2 | Giá | Công | Thủ | Di | Tầm | Kiểu | Thẻ | Đặc tính | Nguồn |
|---|---|---|---|---|---|---|---|---|---|---|
| `linh_giao` | Soldier | 150 | 50–55 | 5 | 4 | 1 | Bộ | bo_binh, chan, chiem_lang | +10 công khi đánh `voi` | TB–Cao |
| `hoa_mai` | Archer | 250 | 50–55 | 5 | 4 | 1–2 | Bộ | ban_xa | — | TB |
| `thuy_binh` | Elemental | 300 | 50–55 | 10 | 4 | 1 | Thủy | chan | Đi sông 1 điểm (thủ sông +5 đã tính ở địa hình) | Thấp–TB |
| `quan_su` | Sorceress | 400 | 35–40 | 5 | 4 | 1–2 | Bộ | ban_xa, chieu_hang, goi_hang | Thấy địa lôi ở ô kề | TB (cơ chế) |
| `trong_tran` | Wisp | 500 | 30–35 | 10 | 4 | 1 | Bộ | — | **Hào quang** +10 công cho quân mình trong 8 ô | Thấp |
| `hoa_ho` | Dire Wolf | 600 | 50–55 | 10 | 4 | 1 | Bộ | chan | Đánh / phản đòn gây **Cháy**. +10 công khi đánh `voi` hoặc quân trên doanh trại. Hành động **Đốt** | TB |
| `moc_thuan` | Golem | 600 | 45–50 | 25 | 3 | 1 | Nặng | chan, khong_chay | +10 thủ khi bị `ban_xa` đánh | Cao |
| `than_cong` | Catapult | 700 | 60–70 | 5 | 3 | 2–4 | Nặng | ban_xa, ban_dung | +15 công khi đánh quân trên đồn, thành, doanh trại | TB |
| `voi_chien` | Dragon | 1000 | 70–80 | 20 | 4 | 1 | Voi | voi, chan, xung_phong | +10 công khi đánh `bo_binh` | **Cao** |
| `hang_binh` | Skeleton | — | 40–45 | 5 | 4 | 1 | Bộ | bo_binh, chan, chiem_lang | Sinh ra từ chiêu hàng / gọi hàng, bắt đầu 50 máu | TB |

Ghi chú:
- **Voi chiến** không bay như Dragon **[đổi]**: sử liệu tả voi mạnh nhưng chậm.
- **Hỏa mai thủ** thay nỏ: không nguồn nào nhắc nỏ trong chiến dịch; có ghi chép người châu Âu về súng hỏa mai.
- **Trống trận** là vai sáng tạo (có trống trận thời Tây Sơn ở bảo tàng, không có ghi chép riêng năm 1789) → Sử liệu ghi *Sáng tạo của game*.
- **Voi chở pháo** (nguồn Thanh thế kỷ 19) để dành sau 1.0.

## 4. Quân Thanh, quân Lê

Lục doanh có súng điểu thương là vũ khí bắn xa chính. Tỷ lệ cụ thể của Lục doanh Lưỡng Quảng năm 1789 chưa rõ: một quy chế doanh
Vân – Quý ghi 60% điểu thương, 20% cung, 10% đằng bài, 10% pháo; quy định năm 1727 cho tỉnh biên giới khoảng 40% điểu thương.
Thiết kế màn dùng khoảng **40–60% điểu thương**. Lục doanh có mã binh, nhưng không thấy ghi chép kỵ binh Thanh ở Ngọc Hồi → 1.0 không có kỵ binh;
không thấy Bát kỳ tham chiến.

| Mã | Phe | Giá | Công | Thủ | Di | Tầm | Kiểu | Thẻ | Đặc tính |
|---|---|---|---|---|---|---|---|---|---|
| `truong_mau` | Thanh | 150 | 45–50 | 5 | 4 | 1 | Bộ | bo_binh, chan, chiem_lang | +15 công khi đánh `voi` (thương có tua đỏ) |
| `dieu_thuong` | Thanh | 250 | 50–55 | 5 | 4 | 1–2 | Bộ | ban_xa | — |
| `cung_tien` | Thanh | 200 | 40–45 | 5 | 4 | 2–3 | Bộ | ban_xa | Không đánh / phản đòn ở cự ly 1 |
| `dang_bai` | Thanh | 400 | 40–45 | 20 | 4 | 1 | Bộ | chan | +10 thủ khi bị `ban_xa` đánh (khiên mây) |
| `phao_binh` | Thanh | 700 | 60–70 | 5 | 3 | 2–4 | Nặng | ban_xa, ban_dung | +15 công khi đánh quân trên đồn, doanh trại |
| `tho_binh` | Thanh | 100 | 40–45 | 5 | 5 | 1 | Bộ | bo_binh, chan, chiem_lang | Đồi, rừng tre tốn 1 điểm. Chỉ ở màn 7 |
| `trinh_sat` | Thanh | — | 30–35 | 0 | 5 | 1 | Bộ | bo_binh | Do kịch bản đặt. Không tạo vùng khống chế |
| `quan_le` | Lê | 100 | 35–40 | 5 | 4 | 1 | Bộ | bo_binh, chan, chiem_lang | — |

## 5. Tướng có tên

Mọi tướng có thẻ `tuong` và `chan`. Tầm 1. Chỉ số tăng theo cấp (02 §6).

### Tây Sơn

| Mã | Màn | Công | Thủ | Di | Kiểu | Thẻ thêm | Kỹ năng | Nguồn |
|---|---|---|---|---|---|---|---|---|
| `quang_trung` | 1, 2, 4, 5, 6, 8, 9 | 60–70 | 20 | 4 | Voi | voi, goi_hang | **Uy danh**: quân mình trong 8 ô +5 công | Sử Thanh: "tự thúc voi đốc đằng sau" |
| `ngo_van_so` | 0 | 50–60 | 15 | 4 | Bộ | goi_hang | **Thận trọng**: không di chuyển trong lượt của mình → +10 thủ đến đầu lượt sau | Sử liệu |
| `ngo_thi_nham` | 0 | 35–40 | 10 | 4 | Bộ | goi_hang | **Mưu sĩ**: quân mình trong 8 ô +5 thủ | Sử liệu; vai có thể được HLNTC tô đậm |
| `phan_van_lan` | 0 | 60–65 | 5 | 5 | Bộ | — | **Hăng máu**: +10 công khi chủ động đánh | Sử liệu |
| `do_doc_long` | 7 | 60–65 | 15 | 5 | Bộ | goi_hang | **Tập kích**: +10 công khi `tam_nhin` ≤ 3 (đêm, rạng sáng) | Tên gọi tranh cãi (05 §3) |
| `do_doc_bao` | 8 | 60–70 | 20 | 4 | Voi | voi | **Tượng binh**: voi chiến trong 8 ô +5 thủ | Theo HLNTC |
| `do_doc_tuyet`, `do_doc_loc` | P | 50–60 | 15 | 5 | Thủy | — | **Thủy quân**: thủy binh trong 8 ô +1 Di (tính đầu lượt) | Theo HLNTC |

### Thanh và Lê

| Mã | Màn | Công | Thủ | Di | Kiểu | Kỹ năng | Ghi chú |
|---|---|---|---|---|---|---|---|
| `ton_si_nghi` | 9 | 55–65 | 20 | 4 | Bộ | **Thống soái**: quân Thanh trong 8 ô +5 công | Chỉ ra trận ở màn 9 |
| `hua_the_hanh` | 8, 9 | 60–70 | 20 | 4 | Bộ | **Chặn hậu**: +10 thủ khi đứng trên cầu, cầu phao, đê, sông cạn | Đề đốc Quảng Tây |
| `sam_nghi_dong` | 7 | 50–60 | 15 | 4 | Bộ | **Tử thủ**: +10 thủ khi đứng trong khu đồn | Thổ quan người Tráng |
| `truong_trieu_long`, `thuong_duy_thang` | 8, 9 | 55–60 | 15 | 4 | Bộ | — | Chức của Thượng Duy Thăng chưa xác minh |
| `quan_giu_don`, `quan_giu_don_le` | 4, 5, 6 | 50–55 | 15 | 4 | Bộ | — | Không rõ tên trong nguồn; không bịa tên |

## 6. Khắc chế (`counters.csv`)

| Bên đánh → bên bị đánh | Hiệu ứng |
|---|---|
| `linh_giao` → `voi` | +10 công |
| `truong_mau` → `voi` | +15 công |
| `hoa_ho` → `voi`, quân trên doanh trại | +10 công; gây Cháy |
| `voi_chien` → `bo_binh` | +10 công |
| `than_cong`, `phao_binh` → quân trên đồn, thành, doanh trại | +15 công |
| `ban_xa` → `moc_thuan` | Mộc thuẫn +10 thủ |
| `ban_xa` → `dang_bai` | Đằng bài +10 thủ |
| Mọi quân → quân đang ngủ | +15 công (Bất ngờ), không bị phản đòn |

Vòng khắc chế: **voi** thắng bộ binh, **giáo / mâu** chặn voi, **mộc thuẫn** chịu súng, **hỏa hổ** đốt voi và doanh trại, **thần công** phá quân trong đồn.

Một vài phép tính kiểm tra (máu đầy, không cấp, trên cỏ):
- Điểu thương → mộc thuẫn: 50–55 − 35 = **15–20** (5–7 phát). Trên đồi: 5–10.
- Trường mâu → voi chiến: 60–65 − 20 = **40–45**. Voi → trường mâu: 80–90 − 5 = **75–85**; thêm Xung phong 85–95.
- Lính giáo + Bất ngờ → quân Lê ngủ trên doanh trại: 65–70 − 10 = **55–60** → hai đòn trong cùng lượt hạ gọn, không báo động.
- Điểu thương → Quang Trung cấp 4 trên đồn: 50–55 − (28 + 15) = **7–12** (sàn 5).

## 7. Địa hình (`terrain.csv`)

Chi phí di chuyển: Bộ / Nặng / Voi / Thủy. "—" = không vào được.

| Mã | Địa hình | Bộ | Nặng | Voi | Thủy | Thủ | Khác |
|---|---|---|---|---|---|---|---|
| `co` | Cỏ, đất trống | 1 | 1 | 1 | 2 | 0 | |
| `duong` | Đường đất | 1 | 1 | 1 | 2 | 0 | Đường thiên lý (màn 4–9) |
| `de` | Đê | 1 | 1 | 1 | 2 | +5 | Đê Yên Duyên (màn 8) |
| `ruong` | Ruộng nước mùa đông | 2 | 3 | 2 | 2 | 0 | |
| `vuon` | Vườn, cây đào | 1 | 2 | 2 | 2 | +5 | Cây đào là không khí Tết (sáng tạo) |
| `rung_tre` | Rừng tre, lũy tre | 2 | 3 | 3 | 3 | +10 | Thổ binh: 1 |
| `doi` | Đồi, gò | 2 | 3 | 2 | 3 | +10 | Thổ binh: 1 |
| `nui` | Núi đá vôi | — | — | — | — | — | Biên bản đồ |
| `song` | Sông | — | — | — | 1 | +5 | Chỉ thủy binh |
| `song_can` | Sông cạn, bến đò | 3 | — | 3 | 1 | −5 | |
| `cau` | Cầu | 1 | 1 | 1 | 1 | 0 | |
| `cau_phao` | Cầu phao | 1 | 2 | 2 | 1 | 0 | Rung / đứt theo kịch bản |
| `dam` | Đầm lầy | 3 | — | 3 | 1 | −5 | Đầm Mực (màn 8) |
| `lang` | Làng | 1 | 1 | 1 | 2 | +10 | +30 vàng, hồi máu |
| `doanh` | Doanh trại | 1 | 1 | 1 | 2 | +5 | Đốt được |
| `doanh_chay` | Doanh trại cháy | 1 | 1 | 1 | 2 | 0 | |
| `luy` | Lũy đất | 2 | 3 | 3 | — | +10 | |
| `don` | Đồn | 1 | 1 | 1 | 2 | +15 | +50 vàng, hồi máu, mua lính |
| `thanh` | Thành | 1 | 1 | 1 | 2 | +20 | +50 vàng, hồi máu, mua lính |
| `lua` | (vật thể Lửa trên ô) | | | | | | 02 §12 |

## 8. Lính mua được

Không còn mốc mở khóa toàn cục. Mỗi màn ghi danh sách `mua_duoc` riêng ở [04](04-chien-dich.md) (lần đầu mỗi loại xuất hiện:
lính giáo, hỏa mai — màn 1; quân sư, trống trận, voi chiến — màn 2; thủy binh, hỏa hổ — màn 4; thần công — màn 5; mộc thuẫn — màn 8).
