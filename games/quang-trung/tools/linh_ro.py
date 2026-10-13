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


DRAW = {
    "hoa_mai": hoa_mai,
    "thuy_binh": thuy_binh,
    "quan_su": quan_su,
    "trong_tran": trong_tran,
    "hoa_ho": hoa_ho,
}
