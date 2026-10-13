#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
art_sample.py — Mẫu hình "bản thật" cho Tây Sơn (Godot 4), để chủ dự án duyệt chất lượng vẽ bằng code.

    python3 art_sample.py      # -> ../godot/assets/sample/

Sinh ra:
    unit_tayson_linh_giao_dung_strip2.png    lính giáo đứng (thở), 2 frame 32x32
    unit_tayson_linh_giao_danh_strip3.png    đánh: lấy đà, đâm, thu giáo
    unit_tayson_linh_giao_trung_strip1.png   bị đánh
    unit_thanh_linh_giao_dung_strip2.png     CHỈ để thử đổi bảng màu phe (lính Thanh sẽ có thiết kế riêng)
    portrait_quang_trung_binh_thuong.png     chân dung 80x80, nền trong
    portrait_quang_trung_binh_thuong_khung.png   chân dung trong khung sơn mài 88x88
    preview_sample.png                       bảng xem trước (x6 / x3)

Quy ước (theo docs/07):
    - Lính nhìn sang phải, chân ở giữa đáy, viền tối 1px, sáng từ trên-trái.
    - Chân dung sáng từ trên-phải, mặt hướng về khung chữ (bên phải).
    - Màu phe nằm trong đúng 3 ô có tên: team_dark / team / team_light.
    - Pixel art thuần: chỉ đặt điểm / hình đặc không khử răng cưa; phóng to bằng nearest-neighbour.
"""

import os

from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
GAME = os.path.normpath(os.path.join(HERE, ".."))
OUT = os.path.join(GAME, "godot", "assets", "sample")
FONT_DIRS = [os.path.join(GAME, "godot", "assets", "fonts"),
             os.path.normpath(os.path.join(GAME, "..", "..", "drafts", "quang-trung", "fonts"))]
DEBUG = os.environ.get("ART_DEBUG")          # thư mục ghi ảnh soi (tuỳ chọn)

# =============================================================================
# 1. BẢNG MÀU
# =============================================================================
PAL = {
    "outline":      (28, 20, 22),
    "ink":          (20, 14, 16),
    # Da lính (rám nắng)
    "skin_light":   (246, 200, 150),
    "skin":         (226, 166, 118),
    "skin_dark":    (182, 118, 84),
    "skin_shadow":  (128, 78, 60),
    # Tóc
    "hair":         (34, 26, 28),
    "hair_light":   (74, 60, 62),
    # Áo nâu (vải nhuộm củ nâu)
    "brown_light":  (160, 112, 76),
    "brown":        (122, 82, 58),
    "brown_dark":   (88, 58, 44),
    "brown_deep":   (60, 40, 34),
    # Quần chàm
    "indigo_light": (86, 96, 140),
    "indigo":       (58, 64, 104),
    "indigo_dark":  (38, 40, 70),
    # Cán giáo
    "wood_light":   (204, 160, 96),
    "wood":         (150, 104, 58),
    "wood_dark":    (96, 62, 36),
    # Mũi giáo
    "steel_light":  (236, 240, 244),
    "steel":        (166, 174, 188),
    "steel_dark":   (98, 104, 120),
    # Tua giáo: đỏ cố định, KHÔNG đổi theo phe
    "tassel_light": (240, 92, 72),
    "tassel":       (190, 34, 34),
    "tassel_dark":  (118, 20, 28),
    # Vàng
    "gold_light":   (255, 232, 140),
    "gold":         (236, 186, 52),
    "gold_dark":    (168, 112, 24),
    # Cỏ (ô địa hình)
    "grass_dark":   (58, 110, 48),
    "grass":        (88, 148, 62),
    "grass_light":  (136, 184, 80),
    "grass_tip":    (184, 214, 110),
    "flower":       (250, 226, 90),
    "white":        (246, 240, 224),
}

# Màu phe: đúng 3 ô có tên -> đổi phe = thay 3 màu này.
TEAMS = {
    "tayson": {"team_dark": (128, 20, 28), "team": (204, 42, 44), "team_light": (246, 104, 84)},
    "thanh":  {"team_dark": (32, 54, 124), "team": (58, 96, 184), "team_light": (116, 156, 226)},
}
TEAM_SLOTS = ("team_dark", "team", "team_light")

# Ký tự trong bản vẽ ASCII -> tên màu
KEY = {
    "O": "outline", "e": "ink",
    "S": "skin_light", "s": "skin", "d": "skin_dark", "D": "skin_shadow",
    "k": "hair", "K": "hair_light",
    "B": "brown_light", "b": "brown", "n": "brown_dark", "N": "brown_deep",
    "I": "indigo_light", "i": "indigo", "j": "indigo_dark",
    "W": "wood_light", "w": "wood", "v": "wood_dark",
    "T": "steel_light", "t": "steel", "u": "steel_dark",
    "X": "tassel_light", "x": "tassel", "y": "tassel_dark",
    "G": "gold_light", "g": "gold", "h": "gold_dark",
    "R": "team_light", "r": "team", "q": "team_dark",
}


def rgba(c, a=255):
    return (c[0], c[1], c[2], a)


def palette(team):
    p = dict(PAL)
    p.update(TEAMS[team])
    return p


def blank(w, h, fill=None):
    return Image.new("RGBA", (w, h), rgba(fill) if fill else (0, 0, 0, 0))


def outline(img, color=PAL["outline"]):
    """Viền tối 1px quanh phần đã vẽ (4 hướng, chỉ viền ngoài)."""
    src = img.copy()
    w, h = img.size
    for y in range(h):
        for x in range(w):
            if src.getpixel((x, y))[3]:
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if 0 <= nx < w and 0 <= ny < h and src.getpixel((nx, ny))[3] == 255:
                    img.putpixel((x, y), rgba(color))
                    break
    return img


def strip(frames):
    w, h = frames[0].size
    out = blank(w * len(frames), h)
    for i, f in enumerate(frames):
        out.alpha_composite(f, (i * w, 0))
    return out


# =============================================================================
# 2. LÍNH GIÁO TÂY SƠN (32x32, nhìn sang phải)
#    Vẽ theo bộ phận (ASCII, mỗi ký tự = 1 pixel, "." = trong suốt), rồi ghép
#    từng frame bằng độ lệch (dx, dy). Giáo vẽ bằng hàm vì đổi góc theo frame.
# =============================================================================
class Part:
    def __init__(self, x0, y0, text):
        rows = [r.strip() for r in text.strip("\n").splitlines()]
        assert len({len(r) for r in rows}) == 1, f"part ({x0},{y0}): hàng không đều"
        self.px = {(x0 + x, y0 + y): ch for y, r in enumerate(rows) for x, ch in enumerate(r) if ch != "."}


# Đầu: khăn đỏ quấn xoắn (màu phe), đuôi khăn rủ sau gáy; mặt nhìn phải.
HEAD = Part(10, 7, """
    .....rRRr...
    ...RRrqRrrq.
    ..RRrqRrrqq.
    ..RrqRRrqrq.
    .rrqRRrqrqq.
    qrkqqqqqqqq.
    qq.kddsssss.
    q..kdSssess.
    q.kkdsssess.
    ...kdsssssss
    ....ddssDd..
    .....dddd...
""")

# Đầu lúc bị đánh: nhắm mắt, há miệng.
HEAD_HIT = Part(10, 7, """
    .....rRRr...
    ...RRrqRrrq.
    ..RRrqRrrqq.
    ..RrqRRrqrq.
    .rrqRRrqrqq.
    qrkqqqqqqqq.
    qq.kddsssss.
    q..kdSsDsss.
    q.kkdsseess.
    ...kdsssDeDs
    ....ddssdd..
    .....dddd...
""")

# Thân trên: áo nâu rộng, sáng bên trái.
CHEST = Part(11, 18, """
    ..nBBBbnn..
    .nBBbbbbbn.
    NnBbbbbbbn.
    NnBbbbbbbn.
    NnBbbbbbbnn
""")

# Thắt lưng đỏ (màu phe) thắt nút, đuôi rủ; vạt áo dài tới gối.
SKIRT = Part(10, 23, """
    .dqRrrrrrrrq..
    .nBbbbbbbbrqn.
    .nBbbbbbbbrqn.
    NnnnnnnnnnqrnN
""")

# Chân: quần chàm ống rộng xắn lửng, chân đất.
LEGS = Part(9, 27, """
    .jiIij.jIIiij.
    jiIIij.jiIiiij
    .dss...Sss....
    Ddsss..Dsssss.
""")
LEGS_WIDE = Part(6, 27, """
    ...jiIij...jIIiij
    .jjiIij...jiIiiij
    .dss.......Sss...
    Ddsss......Dsssss
""")
LEGS_LUNGE = Part(4, 26, """
    .....jj.............
    ....jiIj.....jIIiij.
    ..jiIIj......jiIiiij
    .jiIj........Sss....
    Ddss.........Dsssss.
""")

# Tay trước (ống tay áo rộng + bàn tay), mỗi tư thế một kiểu.
ARM = Part(18, 18, """
    .bb......
    bBbb.....
    bbbbbbsS.
    nbbbbndss
    .nn......
""")
ARM_WINDUP = Part(15, 19, """
    .bb....
    bBbbb..
    bbbbbsS
    .nnnds.
    .....d.
""")
ARM_THRUST = Part(20, 19, """
    .bbb
    bBbb
    nbbn
    .nn.
""")
ARM_RECOVER = Part(18, 19, """
    .bb...
    bBbbsS
    nbbnds
""")
ARM_HIT = Part(16, 20, """
    bb.....
    bbbbsS.
    nbbbdss
    .nn....
""")
HAND = Part(0, 0, """
    sS
    ds
""")


def spear_v(x, top, bottom):
    """Giáo dựng đứng: mũi ở (x, top), chân ở (x, bottom)."""
    px = {(x, y): "w" for y in range(top + 10, bottom + 1)}
    for dx, dy, c in ((0, 0, "T"), (-1, 1, "T"), (0, 1, "T"), (1, 1, "u"), (-1, 2, "T"), (0, 2, "t"),
                      (1, 2, "u"), (-1, 3, "T"), (0, 3, "t"), (1, 3, "u"), (0, 4, "u"), (0, 5, "h"),
                      # tua đỏ
                      (-1, 6, "x"), (0, 6, "X"), (1, 6, "x"), (-1, 7, "x"), (0, 7, "X"), (1, 7, "x"),
                      (2, 7, "y"), (-1, 8, "x"), (0, 8, "x"), (1, 8, "x"), (2, 8, "y"), (-1, 9, "y"),
                      (1, 9, "y")):
        px[(x + dx, top + dy)] = c
    return px


def spear_t(x, top, bottom, step=5, d=1):
    """Giáo nghiêng: cứ `step` hàng lệch 1 cột (d=1: đầu ngả phải)."""
    base = spear_v(0, 0, bottom - top)
    return {(x + dx + d * ((bottom - top - dy) // step), top + dy): c for (dx, dy), c in base.items()}


def spear_h(tx, y, butt, tassel="hang"):
    """Giáo nằm ngang, mũi chỉ sang phải ở (tx, y)."""
    px = {(x, y): "w" for x in range(butt, tx - 5)}
    for dx, dy, c in ((0, 0, "T"), (-1, 0, "T"), (-2, 0, "t"), (-3, 0, "t"), (-4, 0, "u"),
                      (-1, -1, "T"), (-2, -1, "T"), (-3, -1, "T"), (-2, 1, "u"), (-3, 1, "u"), (-5, 0, "h")):
        px[(tx + dx, y + dy)] = c
    if tassel == "hang":       # tua rủ xuống
        pts = ((-6, -1, "x"), (-6, 0, "X"), (-6, 1, "x"), (-7, 0, "x"), (-7, 1, "X"), (-7, 2, "x"),
               (-6, 2, "y"), (-8, 1, "y"), (-8, 2, "x"), (-7, 3, "y"), (-9, 3, "y"))
    else:                      # tua bay ngược khi đâm
        pts = ((-6, 1, "x"), (-7, 1, "X"), (-8, 1, "x"), (-9, 1, "y"), (-7, 2, "x"), (-8, 2, "X"),
               (-9, 2, "x"), (-10, 2, "y"), (-9, 3, "y"), (-11, 3, "y"))
    for dx, dy, c in pts:
        px[(tx + dx, y + dy)] = c
    return px


def spear_d(tx, ty, length):
    """Giáo chéo 45°, mũi chỉ lên-phải ở (tx, ty)."""
    px = {(tx - i, ty + i): "w" for i in range(6, length)}
    for dx, dy, c in ((0, 0, "T"), (-1, 0, "T"), (0, 1, "t"), (-1, 1, "T"), (-2, 1, "T"), (-1, 2, "t"),
                      (0, 2, "u"), (-2, 2, "t"), (-1, 3, "u"), (-3, 3, "u"), (-2, 3, "t"), (-3, 4, "h"),
                      (-4, 5, "x"), (-5, 5, "X"), (-4, 6, "x"), (-5, 6, "x"), (-3, 6, "y"), (-4, 7, "y"),
                      (-6, 6, "y")):
        px[(tx + dx, ty + dy)] = c
    return px


def L(src, dx=0, dy=0, inner=None):
    """Một lớp: (pixel, độ lệch, màu viền trong). inner = ký tự màu vẽ quanh lớp này
    nơi nó đè lên lớp dưới (tách tay khỏi thân)."""
    px = src.px if isinstance(src, Part) else src
    return ({(x + dx, y + dy): c for (x, y), c in px.items()}, inner)


# Mỗi frame = danh sách lớp, vẽ từ sau ra trước.
FRAMES = {
    "dung": [
        [L(LEGS), L(SKIRT), L(CHEST), L(HEAD), L(spear_v(24, 1, 30)), L(ARM, inner="N")],
        # thở ra: đầu, vai, tay hạ 1px (thắt lưng và chân giữ nguyên)
        [L(LEGS), L(CHEST, 0, 1), L(SKIRT), L(HEAD, 0, 1), L(spear_v(24, 2, 30)), L(ARM, 0, 1, "N")],
    ],
    "danh": [
        # 1. lấy đà: ngả ra sau, hạ giáo ngang, kéo về
        [L(LEGS_WIDE), L(SKIRT, -1), L(CHEST, -2, 1), L(HEAD, -3, 1), L(spear_h(24, 22, 1)),
         L(ARM_WINDUP, inner="N"), L(HAND, 9, 22)],
        # 2. đâm: lao người, chân sau duỗi, mũi giáo chạm mép khung
        [L(LEGS_LUNGE, 2), L(SKIRT, 2), L(CHEST, 3, 1), L(HEAD, 4, 1), L(ARM_THRUST, inner="N"),
         L(spear_h(31, 22, 8, "stream")), L(HAND, 24, 21), L(HAND, 16, 21)],
        # 3. thu giáo: đứng lên, giáo chéo trở về
        [L(LEGS), L(SKIRT), L(CHEST, 1), L(HEAD, 1), L(spear_d(31, 10, 27)), L(ARM_RECOVER, inner="N")],
    ],
    "trung": [
        # bật ngửa ra sau, nhắm mắt, giáo chao
        [L(LEGS, -1), L(SKIRT, -1), L(CHEST, -2, 1), L(HEAD_HIT, -3, 2), L(spear_t(20, 3, 30)),
         L(ARM_HIT, inner="N")],
    ],
}

# Hiệu ứng vẽ SAU viền (không có viền): vệt gió khi đâm.
FX = {("danh", 1): [((x, 19), 150) for x in range(22, 27)] + [((x, 25), 110) for x in range(26, 30)]}


def compose(layers):
    """Ghép các lớp thành dict pixel; lớp có `inner` được viền trong chỗ đè lên lớp dưới."""
    out = {}
    for px, inner in layers:
        if inner:
            for (x, y) in px:
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    n = (x + dx, y + dy)
                    if n not in px and n in out:
                        out[n] = inner
        out.update(px)
    return out


def ground_shadow(img, cx=16, cy=30, rx=8):
    """Bóng bầu dục mờ dưới chân (vẽ sau viền, nằm dưới lính)."""
    base = blank(*img.size)
    for y in range(cy - 2, cy + 3):
        for x in range(cx - rx - 1, cx + rx + 2):
            dx, dy = (x - cx) / (rx + 0.5), (y - cy) / 2.2
            if dx * dx + dy * dy <= 1 and 0 <= x < img.width and 0 <= y < img.height:
                base.putpixel((x, y), (0, 0, 0, 70))
    base.alpha_composite(img)
    return base


def render_frame(layers, team, fx=()):
    pal = palette(team)
    img = blank(32, 32)
    for (x, y), ch in compose(layers).items():
        if 0 <= x < 32 and 0 <= y < 32:
            img.putpixel((x, y), rgba(pal[KEY[ch]]))
    img = outline(img)
    for (x, y), a in fx:
        if img.getpixel((x, y))[3] == 0:
            img.putpixel((x, y), (255, 255, 255, a))
    return ground_shadow(img)


def unit_strips(team="tayson"):
    return {act: strip([render_frame(fr, team, FX.get((act, i), ())) for i, fr in enumerate(frames)])
            for act, frames in FRAMES.items()}


def swap_team(img, src="tayson", dst="thanh"):
    """Đổi bảng màu phe trên ảnh đã vẽ: chỉ thay đúng 3 màu team_*."""
    m = {TEAMS[src][k]: TEAMS[dst][k] for k in TEAM_SLOTS}
    out = img.copy()
    px = out.load()
    for y in range(out.height):
        for x in range(out.width):
            r, g, b, a = px[x, y]
            if a == 255 and (r, g, b) in m:
                px[x, y] = rgba(m[(r, g, b)])
    return out


# =============================================================================
# 3. CHÂN DUNG QUANG TRUNG 80x80 (sáng từ trên-phải, mặt hơi quay sang phải)
# =============================================================================
PP = {
    "line":      (36, 18, 20),     # viền ngoài / nét đậm
    # Da
    "sk_hi":     (255, 226, 190),
    "sk_lt":     (246, 196, 150),
    "sk":        (222, 158, 114),
    "sk_sh":     (178, 110, 80),
    "sk_dp":     (120, 66, 54),
    # Tóc, râu
    "hr":        (26, 20, 24),
    "hr_md":     (56, 44, 48),
    "hr_lt":     (96, 80, 80),
    # Mắt, môi
    "eye_w":     (250, 246, 236),
    "iris":      (70, 40, 28),
    "iris_lt":   (176, 108, 48),
    "lip":       (168, 86, 72),
    # Khăn vàng
    "gd_hi":     (255, 244, 176),
    "gd_lt":     (248, 210, 92),
    "gd":        (220, 162, 44),
    "gd_sh":     (164, 104, 28),
    "gd_dp":     (100, 58, 24),
    # Áo bào đỏ
    "rd_lt":     (240, 92, 70),
    "rd":        (200, 40, 44),
    "rd_sh":     (142, 22, 36),
    "rd_dp":     (84, 14, 28),
    # Cổ áo trong
    "wt":        (246, 238, 220),
    "wt_sh":     (196, 182, 164),
}


class Brush:
    """Vẽ hình đặc không khử răng cưa bằng tên màu trong PP."""

    def __init__(self, img):
        self.img = img
        self.d = ImageDraw.Draw(img)

    def c(self, name):
        return rgba(PP[name])

    def poly(self, pts, name):
        self.d.polygon(pts, fill=self.c(name))

    def ell(self, box, name):
        self.d.ellipse(box, fill=self.c(name))

    def rect(self, box, name):
        self.d.rectangle(box, fill=self.c(name))

    def line(self, pts, name, w=1):
        self.d.line(pts, fill=self.c(name), width=w)

    def px(self, pts, name):
        for p in pts:
            self.img.putpixel(p, self.c(name))

    def run(self, x0, x1, y, name):
        self.d.line((x0, y, x1, y), fill=self.c(name))


def despeckle(img, keep=()):
    """Dọn pixel lẻ do ghép hình: pixel có <=1 láng giềng cùng màu (4 hướng) lấy màu đa số xung quanh."""
    src = img.copy()
    s, d = src.load(), img.load()
    keep = {rgba(PP[k]) for k in keep}
    for y in range(1, img.height - 1):
        for x in range(1, img.width - 1):
            c = s[x, y]
            if c[3] == 0 or c in keep:
                continue
            nb = [s[x + 1, y], s[x - 1, y], s[x, y + 1], s[x, y - 1]]
            if sum(n == c for n in nb) <= 1:
                best = max(set(nb), key=nb.count)
                if nb.count(best) >= 2 and best[3]:
                    d[x, y] = best
    return img


def arc_pts(x0, x1, y_side, y_mid, cx=None, n=12):
    """Điểm trên cung võng (vòng khăn nhìn từ trên-trước): hai đầu ở y_side, giữa ở y_mid."""
    cx = (x0 + x1) / 2 if cx is None else cx
    pts = []
    for i in range(n + 1):
        x = x0 + (x1 - x0) * i / n
        t = (x - cx) / max(cx - x0, x1 - cx)
        pts.append((round(x), round(y_mid + (y_side - y_mid) * t * t)))
    return pts


def portrait_qt():
    img = blank(80, 80)
    b = Brush(img)

    # --- Áo bào đỏ ------------------------------------------------------------
    b.poly([(0, 79), (0, 72), (6, 67), (18, 63), (30, 61), (58, 61), (68, 63), (75, 66), (79, 71), (79, 79)], "rd")
    b.poly([(0, 79), (0, 72), (6, 67), (18, 63), (27, 62), (21, 68), (17, 79)], "rd_sh")    # vai trái khuất
    b.poly([(62, 62), (69, 63), (75, 66), (79, 71), (79, 74), (72, 68), (64, 65)], "rd_lt")  # vai phải bắt sáng
    b.line([(27, 69), (25, 79)], "rd_sh")                                                     # nếp áo
    b.line([(66, 70), (68, 79)], "rd_sh")
    b.line([(9, 73), (7, 79)], "rd_dp")
    b.px([(70, 66), (71, 67)], "rd_lt")
    # thêu mây vàng trên vai (gợi ý hoa văn áo bào)
    for x, y in ((8, 72), (66, 73)):
        b.px([(x, y), (x + 1, y - 1), (x + 2, y - 1), (x + 3, y), (x + 3, y + 1), (x + 2, y + 1),
              (x + 4, y + 2), (x + 5, y + 2), (x + 6, y + 1)], "gd_sh" if x < 40 else "gd")
    # mây cuộn chìm (đỏ sẫm) trên áo bào
    cloud = ((1, 0), (2, 0), (0, 1), (3, 1), (5, 1), (6, 1), (0, 2), (2, 2), (4, 2), (1, 3))
    for ox, oy in ((11, 69), (20, 74), (56, 72), (69, 75), (3, 76)):
        b.px([(ox + x, oy + y) for x, y in cloud], "rd_sh")
    # cổ áo sau gáy (sau cổ)
    b.poly([(34, 60), (58, 59), (60, 63), (33, 64)], "gd_sh")
    # --- Cổ ------------------------------------------------------------------
    b.poly([(38, 55), (54, 56), (55, 68), (46, 72), (38, 66)], "sk_sh")
    b.poly([(47, 60), (54, 58), (55, 67), (49, 70)], "sk")
    b.poly([(38, 55), (54, 56), (53, 59), (40, 60)], "sk_dp")                              # bóng hàm đổ xuống cổ
    # cổ áo trong trắng bắt chéo + viền vàng cổ tròn phía trước
    b.poly([(33, 63), (40, 64), (47, 72), (40, 72)], "wt_sh")
    b.poly([(60, 62), (54, 64), (47, 72), (53, 72)], "wt")
    b.line([(31, 64), (35, 69), (41, 73), (47, 75), (53, 73), (59, 69), (62, 63)], "gd", 3)
    b.line([(33, 63), (37, 68), (42, 71), (47, 72), (52, 71), (58, 67), (61, 62)], "gd_lt")
    b.line([(31, 66), (35, 71), (41, 75), (47, 77), (53, 75), (59, 71), (63, 65)], "gd_sh")

    # --- Tai -------------------------------------------------------------------
    b.ell((21, 36, 29, 50), "sk_sh")
    b.ell((22, 37, 28, 48), "sk")
    b.px([(24, 40), (24, 41), (24, 42), (25, 43), (25, 44), (26, 45)], "sk_dp")
    b.px([(23, 39), (23, 40)], "sk_lt")

    # --- Mặt: khối gốc ---------------------------------------------------------
    face = [(27, 30), (26, 38), (27, 46), (29, 52), (33, 57), (38, 61), (43, 64), (48, 64), (52, 61), (55, 56),
            (57, 50), (58, 46), (59, 41), (58, 36), (57, 30)]
    b.poly(face, "sk")
    # bóng má trái (phía khuất sáng): hẹp ở thái dương, ôm theo hàm
    b.poly([(27, 30), (31, 30), (31, 38), (31, 45), (33, 51), (37, 56), (42, 60), (43, 64), (38, 61), (33, 57),
            (29, 52), (27, 46), (26, 38)], "sk_sh")
    b.poly([(27, 30), (57, 30), (57, 34), (46, 35), (36, 35), (29, 36)], "sk_sh")          # bóng khăn đổ xuống trán
    # sáng: trán phải, gò má phải
    b.poly([(47, 36), (56, 35), (57, 39), (52, 40), (48, 39)], "sk_lt")
    b.poly([(53, 46), (57, 45), (56, 51), (53, 50)], "sk_lt")
    # hốc mắt
    b.poly([(33, 40), (42, 40), (43, 42), (33, 42)], "sk_sh")
    b.poly([(49, 40), (56, 40), (56, 42), (49, 42)], "sk_sh")
    # mũi: sống sáng, cánh trái tối, đổ bóng dưới
    b.poly([(46, 42), (48, 42), (51, 50), (50, 52), (47, 52)], "sk_lt")
    b.poly([(44, 43), (46, 43), (46, 52), (44, 52)], "sk_sh")
    b.poly([(43, 52), (51, 52), (51, 54), (44, 55)], "sk_sh")
    # bóng dưới môi
    b.poly([(44, 59), (51, 59), (50, 60), (45, 60)], "sk_sh")
    despeckle(img)

    # --- Chi tiết vẽ tay -------------------------------------------------------
    b.px([(48, 45), (49, 47), (50, 49)], "sk_hi")                                          # sống mũi
    b.px([(46, 53), (49, 53)], "sk_dp")                                                     # lỗ mũi
    b.px([(51, 51)], "sk")
    b.px([(54, 47), (55, 47)], "sk_hi")                                                     # gò má
    # mắt gần (trái): mí trên đậm, tròng trắng, con ngươi nâu hổ phách + chấm sáng -> "mắt sáng"
    b.run(33, 41, 41, "line")
    b.px([(32, 42), (42, 42)], "line")
    b.run(33, 41, 42, "eye_w")
    b.run(33, 41, 43, "eye_w")
    b.run(34, 40, 44, "eye_w")
    b.rect((38, 42, 40, 44), "iris")
    b.px([(39, 44), (40, 43)], "iris_lt")
    b.px([(39, 42), (39, 43)], "line")
    b.px([(38, 42)], "eye_w")
    b.run(34, 40, 45, "sk_sh")
    b.px([(33, 44), (41, 44)], "sk_sh")
    # mắt xa (phải, hẹp hơn vì mặt quay)
    b.run(49, 55, 41, "line")
    b.px([(56, 42)], "line")
    b.run(49, 55, 42, "eye_w")
    b.run(49, 55, 43, "eye_w")
    b.run(50, 54, 44, "eye_w")
    b.rect((52, 42, 54, 44), "iris")
    b.px([(53, 44), (54, 43)], "iris_lt")
    b.px([(53, 42), (53, 43)], "line")
    b.px([(52, 42)], "eye_w")
    b.run(50, 54, 45, "sk_sh")
    b.px([(49, 44), (55, 44)], "sk_sh")
    # lông mày rậm, chau xuống ở đầu trong -> quyết đoán
    b.poly([(29, 37), (35, 36), (42, 38), (43, 40), (36, 39), (30, 39)], "hr")
    b.poly([(48, 40), (49, 38), (55, 36), (59, 37), (58, 39), (52, 39)], "hr")
    b.px([(33, 37), (52, 38)], "hr_md")
    b.px([(44, 39), (45, 40)], "sk_dp")                                                    # nếp chau giữa mày
    # miệng mím
    b.run(43, 52, 57, "line")
    b.run(45, 50, 58, "lip")
    b.px([(43, 58), (52, 58)], "sk_sh")
    # ria mép rủ hai đầu
    b.poly([(41, 56), (44, 54), (48, 55), (52, 54), (55, 56), (55, 58), (52, 56), (48, 56), (44, 56), (41, 59)], "hr")
    b.px([(46, 55), (50, 55), (53, 55)], "hr_md")
    # râu cằm ngắn, vuốt nhọn
    b.poly([(45, 61), (51, 61), (51, 63), (49, 66), (47, 66), (45, 63)], "hr")
    b.px([(48, 62), (49, 63), (50, 62)], "hr_md")
    b.px([(49, 62)], "hr_lt")
    # tóc mai trước tai
    b.poly([(27, 31), (31, 31), (31, 39), (30, 42), (28, 40), (27, 36)], "hr")
    b.px([(30, 33), (29, 36)], "hr_md")

    # --- Khăn vấn vàng: rộng, thấp, các vòng quấn võng ra trước, dải chéo chữ nhân ---
    cx = 44
    outer = [(18, 32), (17, 25), (20, 19), (26, 14), (35, 11), (41, 10), (50, 10), (55, 12), (61, 16), (64, 23), (63, 30), (60, 34)]
    outer += list(reversed(arc_pts(19, 60, 34, 33, cx)))
    b.poly(outer, "gd")
    b.poly([(26, 14), (35, 11), (46, 10), (55, 12), (60, 15), (50, 16), (40, 16), (30, 17)], "gd_lt")   # đỉnh khăn
    b.poly([(44, 11), (52, 12), (56, 14), (48, 14)], "gd_hi")
    for ys, ym in ((17, 21), (23, 27)):                    # mép dưới mỗi vòng quấn
        pts = arc_pts(22, 62, ys, ym, cx)
        b.line(pts, "gd_sh")
        b.line([(x, y + 1) for x, y in pts if x > 22], "gd_dp")
        b.line([(x, y + 2) for x, y in arc_pts(34, 62, ys, ym, cx)], "gd_lt")   # mép trên vòng kế bắt sáng
    # dải chéo chữ nhân phía trước trán
    b.poly([(41, 34), (47, 17), (52, 17), (46, 34)], "gd_lt")
    b.poly([(47, 17), (51, 17), (58, 32), (53, 34)], "gd")
    b.line([(46, 34), (51, 19)], "gd_sh")
    b.line([(51, 18), (57, 32)], "gd_sh")
    b.line([(48, 18), (43, 32)], "gd_hi")
    # mép trái khuất sáng
    b.poly([(18, 32), (17, 25), (20, 19), (25, 15), (23, 24), (24, 34)], "gd_sh")
    b.line(arc_pts(19, 60, 34, 33, cx), "gd_dp")

    return outline(img, PP["line"])


def portrait_frame(port):
    """Khung sơn mài 88x88: nền đỏ-đen chia bậc, viền vàng nổi 3 lớp, góc đồng Quang Trung thông bảo."""
    LQ = {"dk": (30, 10, 12), "l0": (46, 16, 16), "l1": (56, 20, 18), "l2": (68, 24, 20), "red": (128, 30, 28)}
    fr = blank(88, 88, LQ["dk"])
    d = ImageDraw.Draw(fr)
    # nền sơn mài: tối ở trên, ấm dần xuống dưới (3 bậc, không chuyển mượt)
    d.rectangle((4, 4, 83, 83), fill=rgba(LQ["l0"]))
    d.rectangle((4, 34, 83, 83), fill=rgba(LQ["l1"]))
    d.rectangle((4, 60, 83, 83), fill=rgba(LQ["l2"]))
    for x in range(5, 83, 2):                          # răng cưa nhỏ giữa các bậc cho mềm
        fr.putpixel((x, 34), rgba(LQ["l0"]))
        fr.putpixel((x + 1, 60), rgba(LQ["l1"]))
    fr.alpha_composite(port, (4, 4))
    g = {k: rgba(PAL[k]) for k in ("gold_light", "gold", "gold_dark")}
    # viền vàng: sáng trên-trái, tối dưới-phải; trong cùng một nét son đỏ
    d.rectangle((0, 0, 87, 87), outline=rgba(LQ["dk"]))
    d.line((1, 1, 86, 1), fill=g["gold_light"])
    d.line((1, 1, 1, 86), fill=g["gold_light"])
    d.rectangle((2, 2, 85, 85), outline=g["gold"])
    d.line((1, 86, 86, 86), fill=g["gold_dark"])
    d.line((86, 1, 86, 86), fill=g["gold_dark"])
    d.rectangle((3, 3, 84, 84), outline=rgba(LQ["red"]))
    for cx, cy in ((4, 4), (83, 4), (4, 83), (83, 83)):    # đồng tiền: tròn vàng, lỗ vuông
        d.ellipse((cx - 4, cy - 4, cx + 4, cy + 4), fill=g["gold_dark"])
        d.ellipse((cx - 4, cy - 4, cx + 3, cy + 3), fill=g["gold"])
        fr.putpixel((cx - 2, cy - 3), g["gold_light"])
        fr.putpixel((cx - 3, cy - 2), g["gold_light"])
        d.rectangle((cx - 1, cy - 1, cx + 1, cy + 1), fill=rgba(LQ["dk"]))
    return fr


# =============================================================================
# 4. Ô CỎ 32x32 (cho bản xem trước)
# =============================================================================
def tile_grass():
    img = blank(32, 32, PAL["grass"])
    p = img.load()
    g = lambda n: rgba(PAL[n])
    for cx, cy, rx, ry in ((7, 8, 4, 2), (23, 5, 3, 1), (26, 20, 4, 2), (9, 25, 3, 2)):   # mảng cỏ tối
        for y in range(cy - ry, cy + ry + 1):
            for x in range(cx - rx, cx + rx + 1):
                if ((x - cx) / (rx + .5)) ** 2 + ((y - cy) / (ry + .5)) ** 2 <= 1:
                    p[x % 32, y % 32] = g("grass_dark")
    for x, y in ((4, 14), (14, 9), (19, 27), (28, 12), (13, 20), (24, 29), (2, 30), (17, 3)):  # khóm lá
        p[x, y] = g("grass_light")
        p[x, y - 1] = g("grass_tip")
        p[(x + 1) % 32, y] = g("grass_light")
        p[(x - 1) % 32, y] = g("grass_dark")
    p[30, 26] = g("flower")
    p[6, 3] = g("white")
    return img


# =============================================================================
# 5. XEM TRƯỚC
# =============================================================================
def font(size, bold=False):
    name = "BeVietnamPro-Bold.ttf" if bold else "BeVietnamPro-Medium.ttf"
    for d in FONT_DIRS:
        if os.path.exists(os.path.join(d, name)):
            return ImageFont.truetype(os.path.join(d, name), size)
    return ImageFont.load_default()


def big(img, s):
    return img.resize((img.width * s, img.height * s), Image.NEAREST)


def preview(strips, thanh_idle, port, framed):
    BG, CELL, LABEL = (58, 56, 64), (72, 70, 80), (236, 230, 214)
    W = 1300
    sheet = blank(W, 1500, BG)
    d = ImageDraw.Draw(sheet)
    gold = rgba(PAL["gold_light"])
    f_t, f_l = font(30, True), font(20)
    y = 18
    d.text((24, y), "Lính giáo Tây Sơn — 32×32, phóng ×6", font=f_t, fill=gold)
    y += 50
    items = [("đứng 1", strips["dung"], 0), ("đứng 2", strips["dung"], 1), ("đánh 1: lấy đà", strips["danh"], 0),
             ("đánh 2: đâm", strips["danh"], 1), ("đánh 3: thu", strips["danh"], 2), ("bị đánh", strips["trung"], 0)]
    for i, (lab, st, k) in enumerate(items):
        x = 24 + i * 208
        cell = blank(32, 32, CELL)
        cell.alpha_composite(st.crop((k * 32, 0, k * 32 + 32, 32)))
        sheet.alpha_composite(big(cell, 6), (x, y))
        d.text((x, y + 198), lab, font=f_l, fill=LABEL)
    y += 250
    d.text((24, y), "Thử đổi màu phe (palette swap) · ô cỏ ×6", font=f_t, fill=gold)
    y += 50
    for k in range(2):
        cell = blank(32, 32, CELL)
        cell.alpha_composite(thanh_idle.crop((k * 32, 0, k * 32 + 32, 32)))
        sheet.alpha_composite(big(cell, 6), (24 + k * 208, y))
        d.text((24 + k * 208, y + 198), f"đổi màu Thanh {k + 1}", font=f_l, fill=LABEL)
    grass = tile_grass()
    t1 = grass.copy()
    t1.alpha_composite(strips["dung"].crop((0, 0, 32, 32)))
    sheet.alpha_composite(big(t1, 6), (24 + 2 * 208 + 40, y))
    d.text((24 + 2 * 208 + 40, y + 198), "trên ô cỏ", font=f_l, fill=LABEL)
    # Đối mặt: Tây Sơn (trái) - Thanh lật ngang (phải), ×3
    duo = blank(96, 32)
    for i in range(3):
        duo.alpha_composite(grass, (i * 32, 0))
    duo.alpha_composite(strips["danh"].crop((32, 0, 64, 32)), (16, 0))
    duo.alpha_composite(thanh_idle.crop((0, 0, 32, 32)).transpose(Image.FLIP_LEFT_RIGHT), (56, 0))
    sheet.alpha_composite(big(duo, 4), (24 + 3 * 208 + 60, y + 32))
    d.text((24 + 3 * 208 + 60, y + 198), "trên bản đồ (×4, phe địch lật ngang)", font=f_l, fill=LABEL)
    y += 260
    d.text((24, y), "Chân dung Quang Trung — 80×80 và khung 88×88, phóng ×3", font=f_t, fill=gold)
    y += 50
    cell = blank(80, 80, CELL)
    cell.alpha_composite(port)
    sheet.alpha_composite(big(cell, 3), (24, y))
    sheet.alpha_composite(big(framed, 3), (24 + 270, y - 12))  # khung lớn hơn 8px -> lệch 12px để thẳng mặt
    sheet.alpha_composite(port, (24 + 570, y))
    sheet.alpha_composite(framed, (24 + 570, y + 100))
    d.text((24 + 570, y + 200), "×1", font=f_l, fill=LABEL)
    y += 290
    # Bảng màu phe
    d.text((24, y), "3 ô màu phe: team_dark · team · team_light", font=f_l, fill=LABEL)
    for r, team in enumerate(("tayson", "thanh")):
        for k, slot in enumerate(TEAM_SLOTS):
            d.rectangle((24 + k * 40, y + 34 + r * 40, 24 + k * 40 + 32, y + 66 + r * 40), fill=rgba(TEAMS[team][slot]))
        d.text((24 + 130, y + 38 + r * 40), team, font=f_l, fill=LABEL)
    y += 130
    return sheet.crop((0, 0, W, y))


# =============================================================================
# 6. MAIN
# =============================================================================
def main():
    os.makedirs(OUT, exist_ok=True)

    def save(img, name):
        img.save(os.path.join(OUT, name))
        print(f"  {name:48s} {img.width}x{img.height}")

    strips = unit_strips("tayson")
    save(strips["dung"], "unit_tayson_linh_giao_dung_strip2.png")
    save(strips["danh"], "unit_tayson_linh_giao_danh_strip3.png")
    save(strips["trung"], "unit_tayson_linh_giao_trung_strip1.png")
    thanh = swap_team(strips["dung"])
    save(thanh, "unit_thanh_linh_giao_dung_strip2.png")

    port = portrait_qt()
    framed = portrait_frame(port)
    save(port, "portrait_quang_trung_binh_thuong.png")
    save(framed, "portrait_quang_trung_binh_thuong_khung.png")
    save(preview(strips, thanh, port, framed), "preview_sample.png")

    if DEBUG:
        os.makedirs(DEBUG, exist_ok=True)
        big(port, 6).save(os.path.join(DEBUG, "dbg_portrait.png"))
        big(strip([strips["dung"], strips["danh"], strips["trung"]]), 8).save(os.path.join(DEBUG, "dbg_units.png"))


if __name__ == "__main__":
    main()
