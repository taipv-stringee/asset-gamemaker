# -*- coding: utf-8 -*-
"""
linh_ro.py — Hình lính Tây Sơn dễ phân biệt (phản hồi chơi thử M2, 13/10/2026: "hình quân chưa nổi bật, khó phân biệt").

Nguyên tắc (mỗi loại khác nhau ít nhất 3 điểm, nhìn được ở 32 px và trên nền đêm):
  1. Màu áo riêng cho từng loại; màu phe (đỏ Tây Sơn / đỏ sẫm Diễn tập) giữ ở khăn và dải thắt chéo.
  2. Dáng riêng: áo dài chấm chân (quân sư), cởi trần mặc gi-lê (thủy binh), trống to trước ngực (trống trận).
  3. Vật cầm TO, chìa hẳn ra ngoài thân, màu sáng tương phản: mái chèo lá to, loa gọi hàng, nòng súng dài có khói,
     ống phun lửa có lưỡi lửa, dùi trống giơ cao.
  4. Hoạt cảnh 2 frame dùng cho cả nhận dạng: sóng nước dưới chân thủy binh, dùi trống thay phiên, khói / lửa đổi.

Theo 07 §2: lính Tây Sơn chít khăn, không đội nón.
"""

import generate_assets as v1
import generate_v2 as v2
from generate_assets import Pen, outline

v1.C.update({
    "coat_brown_dark": (62, 40, 26), "coat_brown": (104, 70, 44), "coat_brown_light": (146, 104, 66),
    "coat_black_dark": (26, 22, 26), "coat_black": (48, 42, 48), "coat_black_light": (86, 78, 84),
    "coat_ochre_dark": (120, 82, 22), "coat_ochre": (182, 132, 40), "coat_ochre_light": (226, 182, 82),
    "coat_white_dark": (176, 168, 150), "coat_white": (226, 220, 202), "coat_white_light": (250, 246, 232),
    "wave_dark": (60, 120, 180), "wave": (120, 184, 230), "wave_light": (210, 238, 255),
    "smoke_light": (236, 234, 228),
    "coat_slate_dark": (46, 56, 72), "coat_slate": (74, 88, 108), "coat_slate_light": (110, 126, 148),
    "coat_indigo_dark": (24, 28, 50), "coat_indigo": (42, 48, 84), "coat_indigo_light": (70, 80, 124),
    "yak": (196, 30, 34), "yak_dark": (128, 16, 22), "yak_light": (236, 84, 70),
})


def body3(p, y, coat, robe=False, sash=True, bare=False, legs=True):
    """Thân người nhìn sang phải. coat = tiền tố màu áo ('coat_brown' → *_dark/_light). Dải chéo màu phe."""
    main, light, dark = coat, coat + "_light", coat + "_dark"
    if legs and not robe:
        p.rect(13, 23, 15, 28, "pants_dark")
        p.rect(17, 23, 19, 28, "pants")
        p.hline(12, 15, 29, "shoe")
        p.hline(17, 21, 29, "shoe")
    if bare:
        # cởi trần, gi-lê ngắn màu áo, quần xắn
        p.rect(12, 13 + y, 20, 21 + y, "skin")
        p.vline(12, 13 + y, 21 + y, "skin_dark")
        p.rect(12, 13 + y, 14, 20 + y, main)
        p.rect(19, 13 + y, 20, 20 + y, main)
        p.vline(12, 13 + y, 20 + y, dark)
        p.hline(15, 18, 17 + y, "skin_dark")
        p.rect(12, 21 + y, 20, 23, "team")
        p.hline(12, 20, 21 + y, "team_dark")
        return
    bottom = 28 if robe else 23
    p.rect(12, 13 + y, 20, 21 + y, main)
    p.vline(12, 13 + y, 21 + y, dark)
    p.vline(20, 14 + y, 21 + y, dark)
    p.rect(13, 14 + y, 14, 18 + y, light)
    p.rect(11, 21 + y, 21, bottom, main)
    p.hline(11, 21, bottom, dark)
    p.vline(11, 21 + y, bottom, dark)
    if robe:
        p.vline(16, 22 + y, bottom - 1, dark)       # nếp áo dài
        p.hline(12, 15, 29, "shoe")
        p.hline(17, 21, 29, "shoe")
    p.hline(17, 18, 13 + y, "white")               # cổ áo
    p.px(17, 14 + y, "white")
    if sash:
        for i in range(8):                          # dải thắt chéo màu phe
            p.px(13 + i, 13 + i + y, "team")
            p.px(14 + i, 13 + i + y, "team_light" if i % 3 == 0 else "team")
    p.hline(12, 20, 20 + y, "wood_dark")           # thắt lưng


def khan(p, y, color="team", tall=False):
    """Khăn chít; tall=True: khăn xếp cao (quân sư)."""
    light = color + "_light" if color in ("team", "coat_black") else color
    rows = ((3, 13, 20), (4, 12, 21), (5, 12, 21), (6, 13, 20))
    if tall:
        rows = ((0, 14, 19), (1, 13, 20), (2, 13, 20)) + rows
    for ry, x0, x1 in rows:
        for x in range(x0, x1 + 1):
            p.px(x, ry + y, light if (x + ry) % 3 == 0 else color)
    p.hline(14, 19, 2 + y if not tall else y - 1, color)
    p.px(11, 5 + y, color)                         # đuôi khăn
    p.px(10, 6 + y, color)
    p.px(10, 7 + y, color)


def finish(img):
    return v2.shadow_under(outline(img))


# ---------------------------------------------------------------- từng loại

def hoa_mai(team, f):
    """Hỏa mai thủ: áo nâu, súng dài chĩa chếch lên, khói ở nòng (frame 1), sừng đựng thuốc ở hông."""
    img = v2.canvas()
    p = Pen(img, team)
    body3(p, f, "coat_brown")
    v2.head2(p, f)
    khan(p, f)
    y = f
    p.line(14, 19 + y, 30, 9 + y, "steel_dark")      # nòng dài chếch lên
    p.line(15, 18 + y, 30, 8 + y, "steel_light")
    p.rect(10, 19 + y, 15, 21 + y, "wood")           # báng
    p.hline(10, 14, 19 + y, "wood_light")
    p.px(19, 15 + y, "fire")                          # mồi dây cháy
    p.px(19, 14 + y, "fire_light")
    v2.arm(p, y, 21, 15)
    p.ellipse(11, 23, 2, 1, "white_dark")             # sừng thuốc
    if f:
        for cx, cy, r in ((29, 5, 2), (26, 3, 1)):
            p.ellipse(cx, cy, r, r, "smoke_light")
    return finish(img)


def thuy_binh(team, f):
    """Thủy binh: cởi trần, gi-lê trắng sọc màu phe, mái chèo lá to chéo qua người, sóng nước dưới chân."""
    img = v2.canvas()
    p = Pen(img, team)
    # sóng nước (vẽ trước để chân đè lên)
    for i, x0 in enumerate((4, 18) if f == 0 else (7, 21)):
        p.hline(x0, x0 + 7, 30, "wave")
        p.hline(x0 + 2, x0 + 4, 29, "wave_light")
    p.hline(1, 30, 31, "wave_dark")
    body3(p, f, "coat_white", bare=True)
    for yy in (14, 16, 18):                            # sọc gi-lê
        p.hline(12, 14, yy + f, "team")
        p.hline(19, 20, yy + f, "team")
    v2.head2(p, f)
    khan(p, f)
    y = f
    # mái chèo: cán từ trên trái xuống dưới phải, lá chèo to sáng
    p.line(7, 3 + y, 24, 22, "wood_dark")
    p.line(8, 3 + y, 25, 22, "wood_light")
    for i in range(6):
        p.hline(23 + i // 2, 29, 22 + i, "straw_light" if i < 2 else "straw")
    p.vline(30, 23, 27, "straw_dark")
    v2.arm(p, y, 17, 14)
    return finish(img)


def quan_su(team, f):
    """Quân sư: áo dài đen chấm chân, khăn xếp cao màu phe, loa gọi hàng to màu tre sáng chìa trước mặt."""
    img = v2.canvas()
    p = Pen(img, team)
    body3(p, f, "coat_black", robe=True, sash=False)
    p.rect(17, 13 + f, 18, 21 + f, "white")          # vạt trong trắng
    p.hline(12, 20, 20 + f, "team")                  # đai màu phe
    v2.head2(p, f, "long")
    khan(p, f, tall=True)
    y = f
    # loa: miệng hẹp ở môi, loe ra phía phải
    for i in range(9):
        half = 1 + i // 2
        for dy in range(-half, half + 1):
            edge = abs(dy) == half
            p.px(21 + i, 10 + y + dy, "bamboo_dark" if edge else ("straw_light" if dy < 0 else "straw"))
    p.vline(30, 10 + y - 5, 10 + y + 5, "straw_dark")
    p.hline(22, 28, 10 + y, "straw_light")
    v2.arm(p, y, 21, 12)
    if f:                                            # sóng tiếng
        p.px(31, 6 + y, "white")
        p.px(31, 14 + y, "white")
    return finish(img)


def trong_tran(team, f):
    """Trống trận: áo vàng đất, trống to đeo trước ngực (mặt da sáng, thân đỏ, đinh vàng), hai dùi giơ thay phiên."""
    img = v2.canvas()
    p = Pen(img, team)
    body3(p, f, "coat_ochre")
    v2.head2(p, f)
    khan(p, f)
    y = f
    # dùi trống: frame 0 dùi phải giơ cao, frame 1 dùi trái
    up, down = ((26, 2), (24, 14)) if f == 0 else ((24, 14), (26, 2))
    p.line(19, 13 + y, up[0], up[1] + y, "wood_light")
    p.line(19, 14 + y, up[0], up[1] + y + 1, "wood_dark")
    p.ellipse(up[0], up[1] + y, 1, 1, "team")
    p.line(19, 15 + y, down[0], down[1] + y, "wood_dark")
    # trống: thân đỏ nhìn chếch, mặt da bên phải
    p.ellipse(18, 21, 6, 6, "tassel_dark")
    p.ellipse(18, 21, 5, 5, "tassel")
    for dx, dy in ((-4, -3), (-4, 3), (0, -5), (0, 5)):
        p.px(18 + dx, 21 + dy, "gold")
    p.ellipse(22, 21, 3, 5, "white_dark")
    p.ellipse(22, 21, 2, 4, "white")
    p.px(22, 21, "skin_dark")
    p.hline(12, 24, 15, "wood_dark")                 # dây đeo
    return finish(img)


def hoa_ho(team, f):
    """Hỏa hổ: áo đen, ống phun bằng tre vàng ôm bên hông, lưỡi lửa lớn phụt ra phía trước (đổi hình theo frame)."""
    img = v2.canvas()
    p = Pen(img, team)
    body3(p, f, "coat_black")
    v2.head2(p, f)
    khan(p, f)
    y = f
    p.rect(13, 16 + y, 22, 18 + y, "straw_dark")     # ống tre vàng sẫm, có đốt
    p.hline(13, 22, 16 + y, "straw_light")
    for x in (16, 19):
        p.vline(x, 16 + y, 18 + y, "wood_dark")
    p.rect(22, 15 + y, 23, 19 + y, "steel_dark")      # miệng ống bọc sắt
    # lưỡi lửa: tam giác loe từ miệng ống tới mép phải, hai frame khác nhau
    reach = 31 if f == 0 else 30
    for i, x in enumerate(range(24, reach + 1)):
        half = 1 + i // 2 if f == 0 else 1 + (i + 1) // 2
        half = min(half, 4)
        for dy in range(-half, half + 1):
            c = "fire_dark" if abs(dy) == half else ("fire_light" if abs(dy) <= half // 2 and x < 28 else "fire")
            p.px(x, 17 + y + dy, c)
    for cx, cy in (((29, 11), (27, 23)) if f == 0 else ((30, 12), (26, 22))):
        p.px(cx, cy + y, "fire")                     # tàn lửa bay
    v2.arm(p, y, 18, 16)
    return finish(img)


# ---------------------------------------------------------------- quân Thanh, quân Lê
# Lính Lục doanh (07 §2; ghi chú trang phục §3): đuôi sam, mũ có tua đỏ, trường thương tua đỏ lông bò yak. Màu xanh lam
# là màu phe để dễ đọc (không phải màu áo thật). Không vẽ chữ 勇 / hình tròn trên ngực (dấu hiệu thế kỷ 19, chưa có nguồn).

def mu_tua(p, y):
    """Mũ lính Thanh: chỏm tròn, vành lật, tua đỏ phủ đỉnh (kiểu "mu" của bản nháp)."""
    v2.hat2(p, "mu", y)


def duoi_sam(p, y):
    """Đuôi sam buông sau gáy."""
    p.vline(12, 9 + y, 17 + y, "hair")
    p.vline(11, 11 + y, 18 + y, "hair")
    p.px(11, 19 + y, "yak_dark")


def truong_mau(team, f):
    """Trường mâu binh: áo màu phe, mũ tua đỏ, đuôi sam, trường thương có chùm tua đỏ to dưới mũi."""
    img = v2.canvas()
    p = Pen(img, team)
    body3(p, f, "team", sash=False)
    v2.head2(p, f)
    mu_tua(p, f)
    duoi_sam(p, f)
    y = f
    p.vline(24, 1 + y, 30, "wood")
    p.vline(25, 3 + y, 30, "wood_dark")
    p.rect(24, -1 + y, 24, 1 + y, "steel_light")
    p.px(25, 1 + y, "steel")
    sway = f
    for dy in range(4):                              # chùm tua lông yak
        p.hline(22 + sway, 27, 3 + dy + y, "yak" if dy % 2 == 0 else "yak_light")
    p.hline(23, 26, 7 + y, "yak_dark")
    v2.arm(p, y, 22, 16)
    return finish(img)


def dieu_thuong(team, f):
    """Điểu thương binh: áo xám chàm, mũ tua đỏ, súng điểu thương dài nằm ngang trước ngực, mồi dây và khói."""
    img = v2.canvas()
    p = Pen(img, team)
    body3(p, f, "coat_slate")
    v2.head2(p, f)
    mu_tua(p, f)
    duoi_sam(p, f)
    y = f
    p.hline(16, 31, 15 + y, "steel_dark")
    p.hline(18, 31, 14 + y, "steel_light")
    p.rect(11, 15 + y, 17, 17 + y, "wood")
    p.hline(11, 16, 15 + y, "wood_light")
    p.px(20, 13 + y, "fire")
    p.px(20, 12 + y, "fire_light")
    p.rect(10, 21, 12, 23, "straw_dark")             # túi thuốc
    v2.arm(p, y, 20, 15)
    if f:
        for cx, cy, r in ((30, 11, 1), (28, 9, 2)):
            p.ellipse(cx, cy + y, r, r, "smoke_light")
    return finish(img)


def cung_tien(team, f):
    """Cung tiễn binh: áo màu phe, mũ tua đỏ, cung lớn cao gần bằng người, ống tên sau lưng lòi chuôi tên."""
    img = v2.canvas()
    p = Pen(img, team)
    p.rect(8, 9, 11, 22, "wood_dark")                # ống tên sau lưng
    p.rect(9, 10, 10, 21, "wood")
    for x, c in ((8, "white"), (9, "yak"), (10, "white"), (11, "yak")):
        p.vline(x, 5, 8, c)
    body3(p, f, "team", sash=False)
    v2.head2(p, f)
    mu_tua(p, f)
    y = f
    for yy in range(3, 28):                          # cánh cung
        t = (yy - 15) / 12.0
        x = 24 + round(4 * (1 - t * t))
        p.px(x, yy + y, "wood_light")
        p.px(x + 1, yy + y, "wood_dark")
    p.vline(24, 3 + y, 27 + y, "white_dark")         # dây cung
    if f:                                            # lắp tên
        p.hline(19, 31, 15 + y, "wood_light")
        p.px(31, 15 + y, "steel_light")
        p.px(19, 14 + y, "white")
    v2.arm(p, y, 27, 15)
    return finish(img)


def dang_bai(team, f):
    """Đằng bài binh: áo xám chàm, mũ tua đỏ, khiên mây tròn to che trước người, đao giơ cao."""
    img = v2.canvas()
    p = Pen(img, team)
    body3(p, f, "coat_slate")
    v2.head2(p, f)
    mu_tua(p, f)
    duoi_sam(p, f)
    y = f
    p.line(18, 12 + y, 23 - f, 3 + y, "steel_light")  # đao
    p.line(19, 12 + y, 24 - f, 3 + y, "steel")
    p.hline(17, 20, 13 + y, "gold_dark")
    p.ellipse(22, 20, 8, 8, "straw_dark")            # khiên mây
    p.ellipse(22, 20, 7, 7, "straw")
    for r in (5, 3):
        p.ellipse(22, 20, r, r, "straw_dark")
        p.ellipse(22, 20, r - 1, r - 1, "straw_light" if r == 5 else "straw")
    p.ellipse(22, 20, 1, 1, "team")
    return finish(img)


def tho_binh(team, f):
    """Thổ binh Điền Châu: khăn đen, áo chàm sẫm, chân đất, giáo trơn không tua, khiên gỗ nhỏ."""
    img = v2.canvas()
    p = Pen(img, team)
    body3(p, f, "coat_indigo", sash=False)
    p.hline(12, 15, 29, "skin_dark")                 # chân đất
    p.hline(17, 21, 29, "skin")
    p.hline(12, 20, 20 + f, "team")                  # đai màu phe
    v2.head2(p, f)
    khan(p, f, color="coat_black")
    y = f
    p.vline(23, 3 + y, 30, "bamboo_dark")
    p.rect(23, 0 + y, 23, 2 + y, "steel_light")
    p.ellipse(13, 19, 3, 4, "wood")                   # khiên gỗ nhỏ bên trái
    p.ellipse(13, 19, 1, 2, "wood_light")
    v2.arm(p, y, 21, 15)
    return finish(img)


def trinh_sat(team, f):
    """Trinh sát: áo nâu gọn, mũ tua đỏ, cờ hiệu tam giác màu phe cắm sau lưng, đao ngắn; dáng chạy."""
    img = v2.canvas()
    p = Pen(img, team)
    p.vline(9, 1, 20, "wood_dark")                   # cán cờ sau lưng
    for i in range(6):                               # cờ đuôi nheo bay
        p.hline(10, 16 - i - f, 1 + i, "team" if i % 2 == 0 else "team_light")
    body3(p, f, "coat_brown", legs=False)
    if f == 0:                                       # chân chạy
        p.rect(12, 23, 14, 28, "pants_dark")
        p.rect(18, 23, 20, 27, "pants")
        p.hline(11, 14, 29, "shoe")
        p.hline(19, 22, 28, "shoe")
    else:
        p.rect(14, 23, 16, 28, "pants_dark")
        p.rect(16, 23, 18, 28, "pants")
        p.hline(13, 16, 29, "shoe")
        p.hline(16, 19, 29, "shoe")
    v2.head2(p, f)
    mu_tua(p, f)
    duoi_sam(p, f)
    y = f
    p.line(22, 15 + y, 27, 9 + y, "steel_light")
    p.hline(21, 23, 16 + y, "gold_dark")
    v2.arm(p, y, 21, 15)
    return finish(img)


def quan_le(team, f):
    """Quân Lê: khăn đen, áo màu phe (vàng đất), giáo có cờ nhỏ màu phe."""
    img = v2.canvas()
    p = Pen(img, team)
    body3(p, f, "team", sash=False)
    v2.head2(p, f)
    khan(p, f, color="coat_black")
    y = f
    p.vline(23, 2 + y, 30, "wood")
    p.vline(24, 4 + y, 30, "wood_dark")
    p.rect(23, 0 + y, 23, 1 + y, "steel_light")
    for i in range(4):                               # cờ nhỏ trên cán giáo
        p.hline(25, 29 - i + f, 3 + i + y, "team_dark" if i == 3 else "team_light")
    v2.arm(p, y, 21, 16)
    return finish(img)


DRAW = {
    "truong_mau": truong_mau,
    "dieu_thuong": dieu_thuong,
    "cung_tien": cung_tien,
    "dang_bai": dang_bai,
    "tho_binh": tho_binh,
    "trinh_sat": trinh_sat,
    "quan_le": quan_le,
    "hoa_mai": hoa_mai,
    "thuy_binh": thuy_binh,
    "quan_su": quan_su,
    "trong_tran": trong_tran,
    "hoa_ho": hoa_ho,
}
