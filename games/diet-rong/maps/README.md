# Bản đồ các màn

Mỗi file là một màn chơi, mỗi ký tự là một ô 32x32. Sửa bằng trình soạn thảo chữ bất kỳ
rồi chạy lại `python build_project.py`.

| Ký tự | Ý nghĩa | Ký tự | Ý nghĩa |
|---|---|---|---|
| `#` | tường (cây / tường đá / vách hang tùy màn) | `.` | nền đi được |
| `~` | nước (chặn đường) | `o` | tảng đá (chặn đường) |
| `P` | người chơi xuất phát | `E` | cổng dịch chuyển sang màn sau |
| `S` | slime | `G` | yêu tinh |
| `K` | xương cung thủ | `B` | dơi |
| `O` | orc | `X` | orc giữ chìa khóa |
| `D` | Hỏa Long (trùm) | `\|` | cửa khóa (cần chìa) |
| `C` | rương gỗ | `W` | rương tím (vũ khí mới) |
| `k` | chìa khóa | `h` / `m` | bình máu / bình năng lượng |
| `$` | đồng vàng | `H` | trái tim (+1 máu tối đa) |
| `T` | bàn dịch chuyển (đặt đúng 2 cái) | `^` | bẫy chông |
| `L` | dung nham | `i` | biển chỉ dẫn |

Nội dung biển chỉ dẫn nằm ở cuối file, mỗi dòng `i: ...` ứng với một biển theo thứ tự đọc
(từ trên xuống dưới, từ trái sang phải).
