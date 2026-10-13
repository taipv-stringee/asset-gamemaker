# Kịch bản chạm

Chạy: `GODOT --path . -- --kich-ban=res://tests/kich_ban/<file>.txt`

Mỗi dòng một lệnh (dòng bắt đầu bằng `#` là chú thích):

| Lệnh | Ý nghĩa |
|---|---|
| `cham X Y` | Chạm vào ô (X, Y) của bản đồ (đếm từ 0, góc trên trái) |
| `nut <chữ>` | Bấm nút có đúng chữ đó ở bảng dưới (kể cả `Hết lượt`) |
| `cho <giây>` | Chờ |
| `anh <file.png>` | Chụp màn hình; đường dẫn tương đối lưu vào `<thư mục dữ liệu người dùng>/anh/` |
| `keo DX DY` | Kéo bản đồ (điểm ảnh logic; DY âm = cuộn xuống) |
| `kiem vang` / `kiem vong` / `kiem ket_qua` / `kiem camera` / `kiem quan X Y` / `kiem vat X Y` | In giá trị ra log (dòng `KIỂM ...`) |
| `thoat` | Thoát |

Sau mỗi lệnh, kịch bản chờ đến khi hết hoạt cảnh rồi mới chạy lệnh tiếp.

## co_ban.txt (màn m_thu, `--seed=5`, cửa sổ 576x1024) — giá trị mong đợi

| Dòng | Mong đợi |
|---|---|
| `kiem vang` (đầu) | `450` (400 khởi đầu + 50 từ đồn) |
| `kiem quan 5 7` | `tayson voi_chien máu 100` |
| `kiem quan 4 12` | `tayson hoa_mai máu 100 (xong)` (mua qua bảng mua lính: nút "Hỏa mai thủ · 250") |
| `kiem vang` (sau khi mua) | `200` |
| `kiem vong` | `2` |
| `kiem camera` (trước / sau khi kéo) | `0,-40` rồi `0,20` (kéo lên 60 điểm ảnh; thanh trên 40, bảng dưới 168 từ bản chữ to) |

## quan_tan_choi_lai.txt (màn m_kiem_thu) — giá trị mong đợi

Chạy: `GODOT --path . -- --man=m_kiem_thu --kich-ban=res://tests/kich_ban/quan_tan_choi_lai.txt`

| Dòng | Mong đợi |
|---|---|
| `kiem vat 3 1` | `quan_tan` (ảnh `quan_tan.png` có cờ rách ở ô đó) |
| `kiem quan 3 1` (sau chiêu hàng) | `tayson hang_binh máu 50 (xong)` |
| `kiem ket_qua` | `thang` (ảnh `thang.png` có bảng THẮNG) |
| `kiem vong` (sau Chơi lại) | `1` |
| `kiem quan 3 1` (sau Chơi lại) | `le quan_le máu 10` |

## dem_m04.txt (màn 4, đêm) — giá trị mong đợi

Chạy: `GODOT --path . -- --man=m04_gian_khau --kich-ban=res://tests/kich_ban/dem_m04.txt`

| Dòng | Mong đợi |
|---|---|
| `kiem vong` (đầu) | `1`; ảnh `dem_bat_dau.png`: trời tối xanh, xa thì sương đặc, không thấy quân Lê |
| `kiem quan 3 7` (vòng 2) | `le quan_le máu 100 (xong)` — lính tuần bị thủy binh chặn ở bờ bắc; ảnh `dem_vong2.png` thấy nó, thấy cổng đồn sáng đèn có quan giữ đồn ngủ (chữ z), trống, đèn |
| `kiem quan 3 7` (sau 3 đòn) | `trống` (lính tuần đã bị hạ, để lại quân tan); ảnh `dem_ha_tuan.png` |
| `kiem ket_qua` | `(chưa)`, không có chữ "Báo động!" nào hiện ra |

## tron_m04.txt (đi qua menu, chơi trọn màn 4) — giá trị mong đợi

Chạy: `GODOT --path . -- --menu --moi --mo-het --seed=1 --kich-ban=res://tests/kich_ban/tron_m04.txt`
(`--moi` xóa tiến trình và file lưu trước khi chạy; `--menu` đi qua menu thay vì vào thẳng trận.)

| Dòng | Mong đợi |
|---|---|
| `kiem man_hinh` (đầu) | `MainMenu`; ảnh `menu.png` không có nút "Tiếp tục" |
| ảnh `gioi_thieu.png` | Giới thiệu màn: "Màn 4", ngày âm + dương, bản đồ nhỏ, đoạn lịch sử có nhãn [Sử liệu], mục tiêu, 3 mục tiêu phụ ☆ |
| ảnh `hoi_thoai_qt.png` | Khung hội thoại có chân dung Quang Trung, bảng tên, nút "Bỏ qua" |
| `kiem luu` (sau hội thoại) | `có` (tự lưu đầu lượt) |
| `kiem ket_qua` | `thang`; ảnh `ket_qua.png`: THẮNG, "Sau 6 vòng · mất 0 quân", 3 sao, 3 mục Sử liệu mới |
| `kiem luu` (sau khi thắng) | `không` (xong trận thì xóa file lưu) |
| `kiem sao m04_gian_khau` | `3` |
| `kiem man_hinh` (sau "Tiếp") | `CampaignScreen`; ảnh `chien_dich_sau.png`: màn 4 có ★★★ |
| ảnh `su_lieu_muc.png` | Mục "Sông Gián và đồn Gián Khẩu", nhãn [Sử liệu], 2 nguồn có đường dẫn |
| `kiem man_hinh` (cuối) | `MainMenu` |

Lệnh thêm cho kịch bản này: `tiep` (chạm vào khung hội thoại), `kiem luu`, `kiem sao <màn>`, `kiem man_hinh`.

## cuon_danh_sach.txt (danh sách Chiến dịch cuộn được) — giá trị mong đợi

Chạy: `GODOT --path . -- --menu --moi --kich-ban=res://tests/kich_ban/cuon_danh_sach.txt`

| Dòng | Mong đợi |
|---|---|
| `kiem cuon` (trước) | `0` |
| `kiem cuon` (sau `vuot 140 260 -200`, vuốt bắt đầu trên nút "Màn 2") | > `0` (đã cuộn) |
| `kiem man_hinh` | `CampaignScreen` (vuốt không bị tính là bấm vào màn) |

Lưu ý: trên máy tính chạy xvfb, danh sách cuộn được cả với bản cũ, nên kịch bản này chỉ bắt được lỗi trên **máy cảm ứng thật**
(hoặc máy có màn cảm ứng). Trên Pixel 3: vuốt bằng tay trên các nút màn, danh sách phải cuộn.
Lệnh mới: `vuot X Y DY` (vuốt cảm ứng từ điểm logic X, Y), `kiem cuon` (vị trí cuộn của danh sách đang hiện).
