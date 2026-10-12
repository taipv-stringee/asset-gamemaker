#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
generate_v2.py — Bản thử phong cách CHI TIẾT HƠN (so với generate_assets.py).

    - Ô lưới 32x32, lính 32x32 (2 frame đứng thở), đổ bóng nhiều tầng hơn.
    - Chân dung hội thoại 80x80: Quang Trung, Tôn Sĩ Nghị.
    - Màn đêm: lọc tối toàn bản đồ, giữ sáng quanh đuốc / đèn lồng (đêm 30 Tết ở Hà Hồi).
    - Màn hình gốc 288x512 (9 x 12 ô + thanh trên + bảng dưới), mockup phóng x3 = 864x1536.

Chạy:
    pip install pillow numpy
    python generate_v2.py     # -> assets_v2/

Dùng lại bảng màu và bút vẽ của generate_assets.py; chỉ thêm màu mới vào C.
"""

import math
import os
import random

import numpy as np
from PIL import Image, ImageDraw, ImageFont

from generate_assets import C, Pen, TEAMS, outline, rgba

HERE = os.path.dirname(os.path.abspath(__file__))
OUT_DIR = os.path.join(HERE, "assets_v2")
FONT_BOLD = os.path.join(HERE, "fonts", "BeVietnamPro-Bold.ttf")
FONT_MED = os.path.join(HERE, "fonts", "BeVietnamPro-Medium.ttf")
T = 32

C.update({
    "skin_light":   (252, 214, 176),
    "lip":          (150, 72, 60),
    "hair_light":   (74, 60, 62),
    "white_dark":   (196, 188, 172),
    "tassel":       (196, 36, 36),
    "tassel_dark":  (132, 20, 26),
    "coral":        (232, 92, 64),
    "feather":      (34, 116, 84),
    "feather_blue": (48, 92, 196),
    "lantern":      (232, 52, 36),
    "earth_dark":   (96, 70, 46),
    "earth":        (138, 104, 66),
    "earth_light":  (176, 140, 92),
    "flower":       (250, 226, 90),
    "deep_water":   (28, 66, 120),
    "ink":          (20, 14, 16),
})


def canvas(w=T, h=T, fill=None):
    return Image.new("RGBA", (w, h), rgba(fill) if fill else (0, 0, 0, 0))


def shadow_under(sprite, cx=16, cy=29, rx=9):
    base = canvas(sprite.width, sprite.height)
    Pen(base).ellipse(cx, cy, rx, 2, (0, 0, 0, 80))
    base.alpha_composite(sprite)
    return base


def strip(frames, size=T):
    out = canvas(size * len(frames), size)
    for i, f in enumerate(frames):
        out.alpha_composite(f, (i * size, 0))
    return out


# =============================================================================
# 1. LÍNH 32x32 (nhìn sang phải)
# =============================================================================
def head2(p, y, beard=None):
    p.rect(13, 5 + y, 20, 12 + y, "skin")
    for cx, cy in ((13, 5), (20, 5), (13, 12)):
        p.px(cx, cy + y, (0, 0, 0, 0))
    p.rect(13, 5 + y, 15, 10 + y, "hair")
    p.px(16, 9 + y, "skin_dark")                   # tai
    p.hline(16, 19, 12 + y, "skin_dark")
    p.px(21, 9 + y, "skin")                        # mũi
    p.vline(19, 8 + y, 9 + y, "ink")               # mắt
    p.hline(18, 20, 7 + y, "hair")                 # lông mày
    p.px(20, 11 + y, "lip")
    if beard == "short":
        p.hline(19, 21, 10 + y, "hair")
        p.hline(17, 20, 12 + y, "hair")
        p.px(19, 13 + y, "hair")
    elif beard == "long":
        p.hline(20, 21, 10 + y, "hair")
        p.vline(21, 11 + y, 14 + y, "hair")
        p.vline(19, 12 + y, 15 + y, "hair")


def hat2(p, kind, y):
    if kind == "non":
        rows = ((0, 17, 17), (1, 16, 17), (2, 15, 18), (3, 14, 19), (4, 12, 21), (5, 10, 23))
        for ry, x0, x1 in rows:
            for x in range(x0, x1 + 1):
                p.px(x, ry + y, "straw_light" if x < 16 else "straw")
        p.hline(10, 23, 5 + y, "straw_dark")
        p.px(15, 3 + y, "straw_dark")
        p.px(19, 4 + y, "straw_dark")
        p.hline(13, 20, 6 + y, "team")             # khăn đỏ dưới nón
    elif kind == "khan":
        for ry, x0, x1 in ((2, 14, 19), (3, 13, 20), (4, 12, 21), (5, 12, 21), (6, 12, 21)):
            for x in range(x0, x1 + 1):
                band = (x + ry) % 4
                p.px(x, ry + y, "gold_dark" if band == 0 else "gold_light" if band == 1 else "gold")
        p.hline(13, 20, 7 + y, "team")             # viền khăn đỏ
        p.rect(17, 3 + y, 18, 4 + y, "team_light")  # ngọc
        for i, (tx, ty) in enumerate(((11, 5), (10, 6), (10, 7), (9, 8), (9, 9), (8, 10))):
            p.px(tx, ty + y, "gold_dark" if i % 2 else "gold")
    elif kind in ("mu", "mu_quan"):
        for ry, x0, x1 in ((2, 16, 18), (3, 15, 19), (4, 13, 21)):
            for x in range(x0, x1 + 1):
                p.px(x, ry + y, "tassel" if x % 2 else "tassel_dark")
        p.hline(11, 22, 5 + y, "pants_dark")
        p.hline(12, 21, 6 + y, "outline")
        if kind == "mu":
            p.px(17, 1 + y, "tassel")
            p.vline(12, 9 + y, 17 + y, "hair")     # bím tóc
            p.px(11, 18 + y, "hair")
        else:
            p.rect(16, 0 + y, 18, 1 + y, "coral")  # chỏm mũ quan
            for i, (fx, fy) in enumerate(((13, 3), (12, 4), (11, 4), (10, 5), (9, 5), (8, 6), (7, 6))):
                p.px(fx, fy + y, "feather" if i < 5 else "feather_blue")
            p.px(6, 6 + y, "flower")
            p.vline(12, 9 + y, 17 + y, "hair")


def body2(p, y, cape=False, armor=False, badge=False, wraps=True, robe=False):
    if cape:
        p.rect(8, 13 + y, 11, 27, "team_dark")
        p.vline(10, 14 + y, 25, "team")
        p.px(7, 27, "team_dark")
    p.rect(13, 23, 15, 28, "pants_dark")
    p.rect(17, 23, 19, 28, "pants")
    if wraps:
        for yy in (25, 27):
            p.hline(13, 15, yy, "white_dark")
            p.hline(17, 19, yy, "white")
    p.hline(12, 15, 29, "shoe")
    p.hline(17, 21, 29, "shoe")
    p.rect(12, 13 + y, 20, 21 + y, "team")
    p.vline(12, 13 + y, 21 + y, "team_dark")
    p.vline(20, 14 + y, 21 + y, "team_dark")
    p.rect(13, 14 + y, 14, 18 + y, "team_light")
    skirt = 25 if robe else 23
    p.rect(11, 21 + y, 21, skirt, "team")
    p.hline(11, 21, skirt, "team_dark")
    p.vline(11, 21 + y, skirt, "team_dark")
    p.hline(17, 18, 13 + y, "white")               # cổ áo
    p.px(17, 14 + y, "white")
    p.hline(12, 20, 20 + y, "wood_dark")           # thắt lưng
    p.px(18, 20 + y, "gold")
    if armor:
        for yy in range(14, 20):
            for x in range(14, 20):
                p.px(x, yy + y, "gold_light" if (x + yy) % 3 == 0 else "gold" if yy % 2 else "gold_dark")
        p.rect(17, 13 + y, 21, 15 + y, "gold")
        p.hline(17, 21, 13 + y, "gold_light")
    if badge:
        p.ellipse(16, 16 + y, 2, 2, "white")
        p.px(16, 16 + y, "team_dark")


def arm(p, y, hx, hy):
    """Tay trước: tay áo từ vai tới bàn tay (hx, hy)."""
    p.line(19, 14 + y, hx - 1, hy + y, "team_dark")
    p.line(20, 14 + y, hx - 1, hy + y - 1, "team_dark")
    p.rect(hx, hy + y, hx + 1, hy + y + 1, "skin")


def u_spear(team, hat, bob, beard=None):
    img = canvas()
    p = Pen(img, team)
    body2(p, bob, wraps=(hat == "non"), badge=(hat == "mu"))
    head2(p, bob, beard)
    hat2(p, hat, bob)
    y = bob
    p.vline(23, 4 + y, 30, "wood")
    p.vline(24, 6 + y, 30, "wood_dark")
    p.px(23, 0 + y, "steel_light")
    p.rect(23, 1 + y, 23, 3 + y, "steel")
    p.vline(24, 2 + y, 3 + y, "steel_dark")
    p.px(22, 3 + y, "steel_dark")
    p.hline(22, 25, 4 + y, "team" if hat == "non" else "tassel")
    p.hline(22, 24, 5 + y, "team_dark" if hat == "non" else "tassel_dark")
    arm(p, y, 21, 16)
    return shadow_under(outline(img))


def u_ranged(team, hat, bob):
    img = canvas()
    p = Pen(img, team)
    body2(p, bob, wraps=(hat == "non"), badge=(hat == "mu"))
    head2(p, bob)
    hat2(p, hat, bob)
    y = bob
    if hat == "non":                                # nỏ
        p.hline(17, 27, 16 + y, "wood")
        p.hline(18, 27, 17 + y, "wood_dark")
        p.vline(26, 12 + y, 20 + y, "wood_dark")
        p.px(27, 11 + y, "wood_dark")
        p.px(27, 21 + y, "wood_dark")
        p.line(27, 12 + y, 24, 16 + y, "white_dark")
        p.line(27, 20 + y, 24, 16 + y, "white_dark")
        p.hline(27, 30, 15 + y, "steel_light")
        arm(p, y, 20, 16)
    else:                                           # cung
        for i in range(17):
            bx = 23 + round(2.4 * math.sin(math.pi * i / 16))
            p.px(bx, 8 + y + i, "wood_dark")
        p.vline(23, 8 + y, 24 + y, "white_dark")
        p.rect(8, 13 + y, 10, 21 + y, "wood")
        p.vline(8, 13 + y, 21 + y, "wood_dark")
        for ax in (8, 10):
            p.vline(ax, 10 + y, 12 + y, "white")
            p.px(ax, 10 + y, "tassel")
        arm(p, y, 22, 15)
    return shadow_under(outline(img))


def u_shield(team, bob):
    """Mộc thuẫn: tấm ván ghép bện rơm tẩm nước."""
    img = canvas()
    p = Pen(img, team)
    body2(p, bob)
    head2(p, bob)
    hat2(p, "non", bob)
    y = bob
    rnd = random.Random(21)
    for x in range(19, 29):
        shade = ("straw_light", "straw", "straw", "straw_dark")[(x - 19) % 4]
        p.vline(x, 9 + y, 29, shade)
    for _ in range(9):
        p.px(rnd.randrange(20, 28), rnd.randrange(11 + y, 28), (128, 104, 56))   # vệt ướt
    for by in (12 + y, 19 + y, 26):
        p.hline(19, 28, by, "wood_dark")
    p.vline(19, 9 + y, 29, "straw_dark")
    for cx, cy in ((19, 9 + y), (28, 9 + y), (28, 29)):
        p.px(cx, cy, (0, 0, 0, 0))
    p.vline(21, 2 + y, 8 + y, "steel")             # đao giơ sau khiên
    p.vline(22, 3 + y, 8 + y, "steel_light")
    p.px(21, 1 + y, "steel_light")
    p.hline(20, 23, 9 + y, "gold")
    return shadow_under(outline(img), rx=11)


def u_commander(team, bob, who):
    img = canvas()
    p = Pen(img, team)
    y = bob
    if who == "qt":
        body2(p, y, cape=True, armor=True, wraps=False)
        head2(p, y, "short")
        hat2(p, "khan", y)
        p.line(23, 14 + y, 29, 2 + y, "steel_light")
        p.line(24, 14 + y, 30, 2 + y, "steel")
        p.px(30, 1 + y, "steel_light")
        p.hline(21, 24, 15 + y, "gold")
        arm(p, y, 21, 14)
    else:
        body2(p, y, cape=True, robe=True, wraps=False)
        p.rect(14, 15 + y, 18, 19 + y, "gold")      # bổ tử
        p.rect(15, 16 + y, 17, 18 + y, "white")
        p.px(16, 17 + y, "team_dark")
        for i, (bx, by) in enumerate(((13, 14), (14, 16), (15, 18), (16, 19), (17, 18), (18, 16), (19, 14))):
            p.px(bx, by + y, "coral" if i % 2 else "flower")   # chuỗi triều châu
        head2(p, y, "long")
        hat2(p, "mu_quan", y)
        p.rect(22, 11 + y, 26, 14 + y, "white")     # quạt
        p.hline(22, 26, 11 + y, "white_dark")
        p.line(22, 14 + y, 26, 11 + y, "white_dark")
        arm(p, y, 21, 14)
    return shadow_under(outline(img))


def u_elephant(team, bob):
    img = canvas()
    p = Pen(img, team)
    for x0 in (6, 11):
        p.rect(x0, 23, x0 + 3, 30, "ele_dark")
    p.ellipse(14, 19, 10, 7, "ele")
    p.ellipse(12, 23, 8, 3, "ele_dark")
    p.ellipse(14, 19, 9, 5, "ele")
    for x0 in (16, 21):
        p.rect(x0, 23, x0 + 3, 30, "ele")
        p.vline(x0 + 3, 23, 30, "ele_dark")
        p.px(x0 + 1, 30, "white")
        p.px(x0 + 3, 30, "white_dark")
    p.ellipse(25, 15, 5, 5, "ele")
    p.ellipse(26, 13, 3, 2, "ele_light")
    sway = bob
    for i, (tx, ty) in enumerate(((29, 17), (29, 18), (30, 19), (30, 20), (30, 21), (30, 22), (30, 23), (29, 24))):
        p.px(tx, ty, "ele")
        p.px(tx - 1, ty, "ele_dark" if i > 2 else "ele")
    p.px(28 + sway, 25, "ele_dark")
    p.px(27 + sway, 25 - sway, "ele_dark")
    p.line(26, 20, 29, 21, "white")
    p.px(30, 20, "white")
    # Vải phủ lưng
    p.rect(7, 13, 19, 21, "team")
    p.vline(7, 13, 21, "team_dark")
    p.hline(8, 18, 14, "team_light")
    p.hline(7, 19, 21, "gold")
    for x in range(8, 20, 2):
        p.px(x, 22, "gold_dark")
    # Tai (đè lên vải)
    p.ellipse(21, 16, 3, 5, "ele_dark")
    p.ellipse(21, 16, 2, 4, "ele")
    p.vline(20, 13, 19, "ele_light")
    p.px(27, 14, "ink")
    p.px(26, 13, "ele_dark")
    # Bành + quản tượng + cờ
    p.rect(9, 8, 18, 12, "wood")
    p.hline(9, 18, 8, "wood_light")
    p.hline(9, 18, 12, "wood_dark")
    p.vline(9, 3, 8, "wood_dark")
    p.vline(18, 3, 8, "wood_dark")
    p.rect(12, 4, 15, 7, "skin")
    p.px(15, 5, "ink")
    p.hline(12, 15, 4, "team")
    p.rect(8, 1, 19, 3, "team")
    p.hline(9, 18, 1, "team_light")
    for x in range(8, 20, 2):
        p.px(x, 3, "team_dark")
    p.vline(6, 0, 12, "wood_dark")
    p.rect(2, 0, 5, 3, "team")
    p.px(1, 1, "team_dark")
    p.px(1, 2, "team_dark")
    return shadow_under(outline(img), cx=15, cy=30, rx=13)


def u_cannon(team, bob):
    img = canvas()
    p = Pen(img, team)
    p.line(2, 27, 12, 21, "wood_dark")
    p.line(2, 28, 12, 22, "wood")
    p.rect(8, 19, 20, 22, "wood")
    p.hline(8, 20, 19, "wood_light")
    for x in range(6, 27):
        r = 3 if x < 18 else 2
        for yy in range(16 - r, 16 + r + 1):
            shade = "bronze_light" if yy == 16 - r else "bronze_dark" if yy >= 16 + r - 0 else "bronze"
            p.px(x, yy, shade)
    for rx in (10, 18):
        p.vline(rx, 12, 20, "bronze_dark")
        p.px(rx, 12, "bronze_light")
    p.rect(26, 12, 28, 20, "bronze")
    p.vline(28, 12, 20, "bronze_dark")
    p.hline(26, 28, 12, "bronze_light")
    p.vline(5, 14, 18, "bronze_dark")
    p.rect(3, 15, 4, 17, "bronze")
    p.ellipse(14, 24, 6, 6, "wood_dark")
    p.ellipse(14, 24, 5, 5, "wood")
    for a in range(0, 360, 45):
        p.line(14, 24, 14 + round(5 * math.cos(math.radians(a))), 24 + round(5 * math.sin(math.radians(a))), "wood_dark")
    p.ellipse(14, 24, 1, 1, "gold")
    p.vline(4, 2, 13, "wood_dark")
    p.rect(5, 2, 10, 6, "team")
    p.hline(5, 10, 2, "team_light")
    p.px(10, 7, "team_dark")
    img = outline(img)
    if bob:
        q = Pen(img)
        for sx, sy in ((30, 11), (31, 10), (30, 9)):
            q.px(sx, sy, "smoke")
    return shadow_under(img, cx=15, cy=30, rx=12)


UNITS = {
    "tayson_quangtrung": lambda b: u_commander("tayson", b, "qt"),
    "tayson_linhgiao":   lambda b: u_spear("tayson", "non", b),
    "tayson_noithu":     lambda b: u_ranged("tayson", "non", b),
    "tayson_mocthuan":   lambda b: u_shield("tayson", b),
    "tayson_voichien":   lambda b: u_elephant("tayson", b),
    "tayson_daibac":     lambda b: u_cannon("tayson", b),
    "thanh_tonsinghi":   lambda b: u_commander("thanh", b, "tsn"),
    "thanh_linhgiao":    lambda b: u_spear("thanh", "mu", b),
    "thanh_cungthu":     lambda b: u_ranged("thanh", "mu", b),
    "thanh_daibac":      lambda b: u_cannon("thanh", b),
}


# =============================================================================
# 2. ĐỊA HÌNH 32x32
# =============================================================================
def t_grass(seed=1, flowers=True):
    img = canvas(fill=C["grass"])
    p = Pen(img)
    rnd = random.Random(seed)
    for _ in range(5):
        cx, cy = rnd.randrange(32), rnd.randrange(32)
        p.ellipse(cx, cy, rnd.randrange(2, 5), rnd.randrange(1, 3), "grass_dark")
    for _ in range(14):
        x, y = rnd.randrange(1, 31), rnd.randrange(2, 31)
        p.px(x, y, "grass_light")
        p.px(x, y - 1, "grass_light")
        p.px(x + 1, y, "grass_dark")
    if flowers:
        for _ in range(2):
            p.px(rnd.randrange(32), rnd.randrange(32), "flower" if rnd.random() < 0.5 else "white")
    return img


def t_road():
    img = t_grass(2, False)
    p = Pen(img)
    rnd = random.Random(3)
    for y in range(32):
        l = 9 + rnd.choice((0, 0, 1))
        r = 22 - rnd.choice((0, 0, 1))
        p.hline(l, r, y, "dirt")
        p.px(l, y, "dirt_dark")
        p.px(r, y, "dirt_dark")
    for y in range(32):                            # vệt bánh xe
        if y % 5:
            p.px(13, y, "dirt_dark")
            p.px(18, y, "dirt_dark")
    for _ in range(8):
        p.px(rnd.randrange(11, 21), rnd.randrange(32), "dirt_light")
    return img


def t_paddy():
    img = canvas(fill=C["paddy_water"])
    p = Pen(img)
    for y in range(0, 28, 7):
        p.hline(0, 31, y + 5, (126, 176, 168))     # ánh nước
    for row, cy in enumerate((5, 12, 19, 26)):
        for cx in range(2 + (row % 2) * 2, 30, 5):
            p.px(cx, cy, "rice_dark")
            p.px(cx, cy - 1, "rice")
            p.px(cx - 1, cy - 2, "rice")
            p.px(cx + 1, cy - 2, "rice")
            p.px(cx, cy - 3, "rice_light")
            p.px(cx - 2, cy - 3, "rice_light")
            p.px(cx + 2, cy - 3, "rice_light")
    p.rect(0, 29, 31, 31, "earth")                 # bờ ruộng
    p.hline(0, 31, 29, "grass")
    p.hline(0, 31, 31, "earth_dark")
    return img


def t_bamboo():
    img = t_grass(4, False)
    p = Pen(img)
    rnd = random.Random(5)
    for bx, base, h in ((3, 30, 24), (17, 26, 20), (11, 31, 14), (25, 31, 17)):
        for i in range(3):
            x = bx + i * 2
            top = base - h + (i % 2) * 3
            p.vline(x, top, base, "bamboo")
            p.vline(x + 1, top, base, "bamboo_dark")
            for ny in range(top + 3, base, 5):
                p.hline(x, x + 1, ny, "bamboo_light")
        for _ in range(7):                          # lá
            lx, ly = bx + rnd.randrange(-3, 7), base - h + rnd.randrange(-2, 6)
            d = rnd.choice((-1, 1))
            p.px(lx, ly, "bamboo_light")
            p.px(lx + d, ly + 1, "bamboo")
            p.px(lx + 2 * d, ly + 1, "bamboo_dark")
    return img


def t_peach():
    img = t_grass(6, False)
    p = Pen(img)
    p.rect(15, 18, 17, 29, "wood_dark")
    p.px(14, 29, "wood_dark")
    p.px(18, 29, "wood_dark")
    p.line(16, 19, 23, 13, "wood_dark")
    p.line(16, 21, 8, 14, "wood_dark")
    rnd = random.Random(7)
    for cx, cy, rx, ry in ((16, 10, 9, 6), (8, 13, 5, 4), (24, 12, 5, 4), (16, 5, 6, 3)):
        p.ellipse(cx, cy, rx, ry, "blossom")
    for _ in range(26):
        p.px(rnd.randrange(4, 29), rnd.randrange(3, 18), "blossom_light")
    for _ in range(18):
        p.px(rnd.randrange(4, 29), rnd.randrange(6, 19), "blossom_dark")
    for fx, fy in ((6, 24), (24, 27), (21, 22)):
        p.px(fx, fy, "blossom_light")
    return img


def t_karst():
    img = t_grass(8, False)
    p = Pen(img)
    for cx, top, w in ((10, 1, 8), (23, 7, 7)):
        p.rect(cx - w, top + 4, cx + w, 31, "rock")
        p.ellipse(cx, top + 4, w, 4, "rock")
        p.vline(cx - w, top + 5, 31, "rock_dark")
        p.rect(cx + w - 2, top + 6, cx + w, 31, "rock_light")
        for gx in (cx - 3, cx + 2):
            p.vline(gx, top + 8, 28, "rock_dark")
        p.ellipse(cx, top + 2, 4, 2, "grass_dark")
        p.ellipse(cx - 4, top + 12, 2, 1, "grass_dark")
        p.px(cx, top + 1, "grass_light")
    return img


def t_hill():
    img = t_grass(9, False)
    p = Pen(img)
    p.ellipse(16, 21, 15, 9, "grass_dark")
    p.ellipse(16, 20, 14, 8, "grass")
    p.ellipse(13, 17, 8, 4, "grass_light")
    p.rect(0, 30, 31, 31, "grass")
    return img


def t_water(frame):
    img = canvas(fill=C["water"])
    p = Pen(img)
    for y in (8, 20):
        p.hline(0, 31, y, "deep_water")
    for wx, wy in ((3, 4), (18, 11), (8, 17), (22, 25), (1, 28)):
        x = (wx + frame * 3) % 32
        p.hline(x, x + 4, wy, "water_light")
        p.hline(x + 1, x + 3, wy - 1, "water_light")
    return img


def t_bridge():
    img = t_water(0)
    p = Pen(img)
    p.rect(7, 0, 24, 31, "wood")
    for y in range(0, 32, 4):
        p.hline(7, 24, y, "wood_dark")
        p.hline(8, 23, y + 1, "wood_light")
    p.vline(6, 0, 31, "wood_dark")
    p.vline(25, 0, 31, "wood_dark")
    for y in (2, 18):
        p.rect(5, y, 6, y + 3, "wood_dark")
        p.rect(25, y, 26, y + 3, "wood_dark")
    return img


def t_village(owner):
    img = t_grass(10, False)
    p = Pen(img, owner)
    p.rect(26, 22, 30, 29, "straw")                # đống rơm
    p.ellipse(28, 21, 3, 2, "straw_light")
    p.vline(30, 22, 29, "straw_dark")
    p.rect(4, 17, 23, 29, "earth_light")           # tường đất
    p.vline(4, 17, 29, "earth")
    p.hline(4, 23, 29, "earth_dark")
    p.rect(11, 21, 15, 29, "wood_dark")
    p.vline(13, 21, 29, "wood")
    p.rect(18, 20, 21, 23, "wood_dark")
    p.vline(19, 20, 23, "earth")
    for i in range(10):                            # mái rạ nhiều lớp
        x0, x1 = 6 - i // 2, 21 + i // 2
        for x in range(x0, x1 + 1):
            p.px(x, 7 + i, ("straw_light", "straw", "straw", "straw_dark")[(x + i * 2) % 4] if i < 9 else "straw_dark")
    p.hline(10, 17, 6, "straw_dark")
    p.px(3, 16, "straw_dark")
    p.px(24, 16, "straw_dark")
    p.vline(7, 17, 18, "wood_dark")                # đèn lồng Tết
    p.rect(6, 19, 8, 21, "lantern")
    p.px(7, 22, "flower")
    p.vline(28, 2, 20, "wood_dark")                # cờ
    p.rect(29, 2, 31, 7, "team")
    p.vline(29, 2, 7, "team_light")
    return img


def t_castle(owner):
    """Thành (mua lính)."""
    img = t_grass(11, False)
    p = Pen(img, owner)
    p.rect(1, 15, 30, 30, "wall")
    p.hline(1, 30, 15, "wall_light")
    p.hline(1, 30, 30, "wall_dark")
    for x in range(1, 31, 5):
        p.rect(x, 13, x + 2, 14, "wall")
        p.hline(x, x + 2, 13, "wall_light")
    for y in (19, 23, 27):
        for x in range(2 + (y // 4 % 2) * 3, 30, 6):
            p.hline(x, x + 3, y, "wall_dark")
    p.ellipse(15, 25, 4, 4, "ink")
    p.rect(11, 25, 19, 30, "ink")
    p.rect(6, 8, 25, 13, "roof")                   # lầu, hai mái cong
    p.hline(3, 28, 8, "roof_dark")
    p.px(2, 7, "roof_dark")
    p.px(29, 7, "roof_dark")
    p.hline(6, 25, 9, "roof_light")
    p.rect(9, 11, 22, 13, "wood")
    for wx in (11, 15, 19):
        p.rect(wx, 11, wx + 1, 12, "ink")
    p.rect(10, 4, 21, 7, "roof")
    p.hline(8, 23, 4, "roof_dark")
    p.px(7, 3, "roof_dark")
    p.px(24, 3, "roof_dark")
    p.vline(15, 0, 3, "wood_dark")
    p.rect(16, 0, 21, 2, "team")
    p.hline(16, 21, 0, "team_light")
    return img


def t_fort(owner):
    """Đồn (lũy đất + hàng rào cọc + chòi canh) — đồn Hà Hồi, Ngọc Hồi."""
    img = t_grass(12, False)
    p = Pen(img, owner)
    p.rect(0, 22, 31, 31, "earth")                 # lũy đất
    p.hline(0, 31, 22, "earth_light")
    p.hline(0, 31, 31, "earth_dark")
    for x in range(0, 32, 3):                      # cọc nhọn
        p.vline(x, 14, 22, "wood")
        p.vline(x + 1, 15, 22, "wood_dark")
        p.px(x, 13, "wood_light")
    p.hline(0, 31, 18, "wood_dark")
    p.rect(12, 18, 19, 26, "ink")                  # cổng
    p.vline(15, 18, 26, "wood_dark")
    p.rect(21, 5, 28, 12, "wood")                  # chòi canh
    p.vline(21, 5, 21, "wood_dark")
    p.vline(28, 5, 21, "wood_dark")
    p.line(21, 13, 28, 20, "wood_dark")
    p.hline(19, 30, 4, "straw_dark")
    p.hline(20, 29, 3, "straw")
    p.hline(22, 27, 2, "straw_light")
    for tx in (3, 9):                              # đuốc
        p.vline(tx, 9, 13, "wood_dark")
        p.rect(tx - 1, 7, tx + 1, 8, "fire")
        p.px(tx, 6, "fire_light")
    p.vline(5, 0, 12, "wood_dark")
    p.rect(6, 0, 11, 3, "team")
    p.hline(6, 11, 0, "team_light")
    return img


TILES = {
    "grass": t_grass, "road": t_road, "paddy": t_paddy, "bamboo": t_bamboo, "peach": t_peach,
    "karst": t_karst, "hill": t_hill, "bridge": t_bridge, "water": lambda: t_water(0),
    "village_neutral": lambda: t_village("neutral"), "village_tayson": lambda: t_village("tayson"),
    "village_thanh": lambda: t_village("thanh"), "castle_tayson": lambda: t_castle("tayson"),
    "castle_thanh": lambda: t_castle("thanh"), "fort_thanh": lambda: t_fort("thanh"),
}


# =============================================================================
# 3. CHÂN DUNG 80x80
# =============================================================================
def face(img, p, d, who):
    """Mặt nhìn hơi sang phải, ánh sáng từ trên-phải."""
    d.ellipse((23, 31, 28, 44), fill=rgba(C["skin_dark"]))           # tai
    d.ellipse((24, 33, 27, 42), fill=rgba(C["skin"]))
    d.rectangle((33, 48, 46, 64), fill=rgba(C["skin_dark"]))         # cổ
    d.rectangle((40, 50, 46, 64), fill=rgba(C["skin"]))
    d.ellipse((26, 16, 54, 52), fill=rgba(C["skin_dark"]))
    d.ellipse((28, 15, 55, 50), fill=rgba(C["skin"]))
    d.polygon([(29, 40), (54, 40), (47, 54), (35, 54)], fill=rgba(C["skin"]))
    d.polygon([(29, 40), (31, 40), (36, 54), (35, 54)], fill=rgba(C["skin_dark"]))
    d.ellipse((42, 20, 51, 28), fill=rgba(C["skin_light"]))          # trán sáng
    p.rect(30, 41, 32, 43, "skin_dark")                               # gò má
    # Mắt
    for ex, iris in ((30, 33), (43, 46)):
        lid = 35 if who == "tsn" else 34
        p.hline(ex, ex + 5, lid, "ink")
        p.hline(ex, ex + 5, lid + 1, "white")
        p.rect(iris, lid + 1, iris + 1, 36, "ink")
        p.hline(ex + 1, ex + 4, 37, "skin_dark")
    # Lông mày
    if who == "qt":
        d.line((28, 30, 35, 32), fill=rgba(C["hair"]), width=2)
        d.line((43, 32, 50, 29), fill=rgba(C["hair"]), width=2)
    else:
        d.line((29, 31, 35, 31), fill=rgba(C["hair"]), width=1)
        d.line((43, 31, 49, 30), fill=rgba(C["hair"]), width=1)
    # Mũi, miệng
    p.vline(39, 36, 43, "skin_dark")
    p.hline(38, 42, 44, "skin_dark")
    p.vline(41, 39, 42, "skin_light")
    p.hline(36, 44, 49, "lip")
    p.hline(37, 43, 50, "skin_dark")
    if who == "qt":
        d.line((33, 48, 40, 46), fill=rgba(C["hair"]), width=2)       # ria
        d.line((40, 46, 47, 48), fill=rgba(C["hair"]), width=2)
        d.polygon([(36, 52), (44, 52), (41, 59), (39, 59)], fill=rgba(C["hair"]))   # chòm râu
        d.rectangle((26, 23, 28, 37), fill=rgba(C["hair"]))           # tóc mai
        d.rectangle((52, 23, 53, 33), fill=rgba(C["hair"]))
    else:
        d.line((40, 46, 33, 48), fill=rgba(C["hair"]))                # ria rủ dài
        d.line((33, 48, 31, 58), fill=rgba(C["hair"]))
        d.line((40, 46, 47, 48), fill=rgba(C["hair"]))
        d.line((47, 48, 49, 58), fill=rgba(C["hair"]))
        d.line((40, 52, 40, 63), fill=rgba(C["hair"]), width=2)


def portrait(who):
    img = canvas(80, 80)
    team = "tayson" if who == "qt" else "thanh"
    p = Pen(img, team)
    d = ImageDraw.Draw(img)
    pal = p.pal

    def f(name):
        return rgba(pal[name])

    # Vai + áo
    if who == "qt":
        d.polygon([(2, 79), (8, 64), (24, 58), (56, 58), (72, 64), (78, 79)], fill=f("team_dark"))   # áo choàng
        d.polygon([(10, 79), (16, 64), (30, 58), (50, 58), (64, 64), (70, 79)], fill=f("team"))
        d.polygon([(30, 58), (40, 72), (50, 58)], fill=f("white"))
        d.line((30, 58, 40, 72), fill=f("gold"), width=3)
        d.line((50, 58, 40, 72), fill=f("gold"), width=3)
        for cx in (17, 63):                                            # giáp vai vảy cá
            d.ellipse((cx - 12, 60, cx + 12, 78), fill=f("gold_dark"))
            d.ellipse((cx - 11, 60, cx + 11, 76), fill=f("gold"))
            for ry in (64, 69, 74):
                for rx in range(cx - 10, cx + 10, 4):
                    p.hline(rx, rx + 2, ry, "gold_dark")
                    p.px(rx + 1, ry - 1, "gold_light")
        d.rectangle((34, 72, 46, 79), fill=f("gold"))                 # hộ tâm kính
        d.ellipse((37, 73, 43, 79), fill=f("gold_light"))
    else:
        d.polygon([(4, 79), (10, 63), (26, 57), (54, 57), (70, 63), (76, 79)], fill=f("team_dark"))
        d.polygon([(30, 57), (40, 68), (50, 57)], fill=f("team"))
        d.rectangle((28, 66, 52, 79), fill=f("gold"))                # bổ tử
        d.rectangle((30, 68, 50, 79), fill=f("team_light"))
        d.ellipse((35, 70, 45, 78), fill=f("white"))                  # chim hạc
        d.line((40, 70, 46, 67), fill=f("white"), width=2)
        p.px(46, 67, "tassel")
        for i in range(17):                                            # chuỗi triều châu
            t = i / 16
            bx = round(22 + 36 * t)
            by = round(60 + 16 * math.sin(math.pi * t))
            d.ellipse((bx - 1, by - 1, bx + 1, by + 1), fill=f("coral" if i % 3 else "flower"))

    face(img, p, d, who)

    # Mũ / khăn
    if who == "qt":
        for y in range(5, 31):
            for x in range(21, 60):
                dx, dy = (x - 40) / 19.5, (y - 18) / 12.5
                if dx * dx + dy * dy <= 1:
                    band = (x + y * 0.6) % 7
                    name = "gold_dark" if band < 1.2 else "gold_light" if band < 2.2 else "gold"
                    if x < 27 and name == "gold":
                        name = "gold_dark"
                    p.px(x, y, name)
        d.rectangle((27, 26, 53, 29), fill=f("team"))                 # viền khăn đỏ
        d.line((27, 26, 53, 26), fill=f("team_light"))
        d.ellipse((36, 12, 44, 20), fill=f("gold_dark"))              # ngọc
        d.ellipse((37, 13, 43, 19), fill=f("team"))
        p.rect(39, 14, 40, 15, "team_light")
        d.polygon([(22, 18), (12, 26), (10, 36), (18, 28)], fill=f("gold_dark"))  # đuôi khăn
    else:
        for y in range(6, 28):                                         # mũ lương mạo, tua đỏ
            half = 4 + (y - 6) * 1.15
            for x in range(round(40 - half), round(40 + half) + 1):
                ang = (x - 40) / max(1, y - 3)
                p.px(x, y, "tassel" if int(ang * 6 + 20) % 2 else "tassel_dark")
        d.rectangle((14, 26, 66, 29), fill=f("pants_dark"))
        d.line((14, 26, 66, 26), fill=rgba(C["hair_light"]))
        d.rectangle((36, 6, 44, 8), fill=f("gold"))
        d.ellipse((36, 0, 44, 7), fill=f("coral"))
        p.rect(38, 1, 39, 2, "white")
        d.polygon([(30, 12), (16, 24), (6, 42), (10, 44), (22, 28)], fill=f("feather"))   # lông công
        d.ellipse((4, 38, 12, 46), fill=f("feather_blue"))
        d.ellipse((6, 40, 10, 44), fill=f("flower"))
        p.px(8, 42, "ink")

    return outline(img)


def portrait_frame(port, team):
    fr = canvas(88, 88, C["lacquer_dark"])
    p = Pen(fr, team)
    for i in range(88):                             # nền chuyển màu nhẹ
        p.hline(2, 85, i, (40 + i // 6, 14 + i // 10, 14 + i // 10))
    fr.alpha_composite(port, (4, 6))
    p.rect(0, 0, 87, 1, "gold")
    p.rect(0, 86, 87, 87, "gold_dark")
    p.rect(0, 0, 1, 87, "gold")
    p.rect(86, 0, 87, 87, "gold_dark")
    for cx, cy in ((0, 0), (84, 0), (0, 84), (84, 84)):
        p.rect(cx, cy, cx + 3, cy + 3, "gold_light")
    return fr


# =============================================================================
# 4. BẢN ĐỒ HÀ HỒI + HIỆU ỨNG ĐÊM
# =============================================================================
MAP = [
    "kkbgFgbkk",
    "kbgprpgbk",
    "bgXgrgXgb",
    "pppgrgppp",
    "dggprpggd",
    "wwwwBwwww",
    "ppgVrgvpp",
    "hgggrgggh",
    "bgdgrgdgb",
    "pppgrgppp",
    "kbggrggbk",
    "kkbgcgbkk",
]
MAP_TILES = {"g": "grass", "r": "road", "p": "paddy", "b": "bamboo", "d": "peach", "k": "karst",
             "h": "hill", "w": "water", "B": "bridge", "v": "village_neutral", "V": "village_tayson",
             "X": "village_thanh", "c": "castle_tayson", "F": "fort_thanh"}
MAP_UNITS = {
    (4, 0): ("thanh_tonsinghi", 100), (3, 1): ("thanh_linhgiao", 100), (5, 1): ("thanh_linhgiao", 90),
    (2, 2): ("thanh_cungthu", 100), (6, 2): ("thanh_daibac", 100), (4, 3): ("thanh_linhgiao", 60),
    (4, 6): ("tayson_mocthuan", 100), (5, 6): ("tayson_mocthuan", 80), (3, 7): ("tayson_linhgiao", 100),
    (4, 8): ("tayson_quangtrung", 100), (6, 8): ("tayson_voichien", 100), (2, 9): ("tayson_noithu", 100),
    (4, 10): ("tayson_daibac", 100),
}
DIGITS = {
    "0": ["111", "101", "101", "101", "111"], "1": ["010", "110", "010", "010", "111"],
    "2": ["111", "001", "111", "100", "111"], "3": ["111", "001", "011", "001", "111"],
    "4": ["101", "101", "111", "001", "001"], "5": ["111", "100", "111", "001", "111"],
    "6": ["111", "100", "111", "101", "111"], "7": ["111", "001", "010", "010", "010"],
    "8": ["111", "101", "111", "101", "111"], "9": ["111", "101", "111", "001", "111"],
}


def hp_badge(v):
    s = str(v)
    img = canvas(len(s) * 4 + 3, 9)
    p = Pen(img)
    p.rect(0, 0, img.width - 1, 8, "ink")
    for i, ch in enumerate(s):
        for ry, row in enumerate(DIGITS[ch]):
            for rx, bit in enumerate(row):
                if bit == "1":
                    p.px(2 + i * 4 + rx, 2 + ry, "white")
    return img


def draw_map(tiles, units, top, highlights=True):
    W = 9 * T
    img = canvas(W, top + len(MAP) * T, C["ink"])
    for r, row in enumerate(MAP):
        for c, ch in enumerate(row):
            img.alpha_composite(tiles[MAP_TILES[ch]], (c * T, top + r * T))
    if highlights:
        sel, move = (4, 8), 3
        reach = {}
        frontier = [sel]
        reach[sel] = 0
        while frontier:
            nxt = []
            for (x, y) in frontier:
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    n = (x + dx, y + dy)
                    if n in reach or not (0 <= n[0] < 9 and 0 <= n[1] < len(MAP)):
                        continue
                    if MAP[n[1]][n[0]] in "wk" or (n in MAP_UNITS and MAP_UNITS[n][0].startswith("thanh")):
                        continue
                    if reach[(x, y)] < move:
                        reach[n] = reach[(x, y)] + 1
                        nxt.append(n)
            frontier = nxt
        hl = canvas(T, T)
        Pen(hl).rect(0, 0, T - 1, T - 1, (90, 160, 255, 80))
        Pen(hl).rect(1, 1, T - 2, T - 2, (90, 160, 255, 60))
        for (c, r) in reach:
            if (c, r) not in MAP_UNITS:
                img.alpha_composite(hl, (c * T, top + r * T))
    for (c, r), (name, hp) in sorted(MAP_UNITS.items(), key=lambda kv: kv[0][1]):
        fr = units[name].crop((0, 0, T, T))
        if name.startswith("thanh"):
            fr = fr.transpose(Image.FLIP_LEFT_RIGHT)
        img.alpha_composite(fr, (c * T, top + r * T))
        if hp < 100:
            b = hp_badge(hp)
            img.alpha_composite(b, (c * T + T - b.width, top + r * T + T - b.height))
    return img


def night(img, lights):
    """Lọc đêm: nhân màu xanh tối, rồi trả lại màu ấm trong bán kính các nguồn sáng (chia bậc cho hợp pixel art)."""
    a = np.asarray(img.convert("RGB")).astype(np.float32) / 255
    h, w, _ = a.shape
    dark = a * np.array([0.26, 0.32, 0.55]) + np.array([0.02, 0.03, 0.08])
    yy, xx = np.mgrid[0:h, 0:w]
    light = np.zeros((h, w), np.float32)
    for lx, ly, r in lights:
        dist = np.sqrt((xx - lx) ** 2 + (yy - ly) ** 2) / r
        light = np.maximum(light, np.clip(1 - dist, 0, 1))
    light = np.floor(light * 4) / 4                 # 4 bậc sáng
    warm = np.clip(a * np.array([1.08, 0.94, 0.78]) + 0.04, 0, 1)
    out = dark * (1 - light[..., None]) + warm * light[..., None]
    return Image.fromarray((out * 255).astype(np.uint8)).convert("RGBA")


def night_lights(top):
    lights = []
    for r, row in enumerate(MAP):
        for c, ch in enumerate(row):
            if ch == "F":
                lights += [(c * T + 3, top + r * T + 7, 30), (c * T + 9, top + r * T + 7, 30)]
            elif ch in "VvX":
                lights.append((c * T + 7, top + r * T + 20, 26))
    for (c, r), (name, _) in MAP_UNITS.items():
        if name.startswith("tayson"):
            lights.append((c * T + 16, top + r * T + 14, 34))
    return lights


def torch_overlay(img, top):
    """Đuốc trên tay lính Tây Sơn (vẽ sau lọc đêm để giữ màu lửa)."""
    p = Pen(img)
    for (c, r), (name, _) in MAP_UNITS.items():
        if name.startswith("tayson") and name not in ("tayson_voichien", "tayson_daibac"):
            x, y = c * T + 7, top + r * T + 9
            p.vline(x, y, y + 6, "wood_dark")
            p.rect(x - 1, y - 2, x + 1, y - 1, "fire")
            p.px(x, y - 3, "fire_light")
            p.px(x, y - 1, "fire_light")


# =============================================================================
# 5. MOCKUP
# =============================================================================
W, H, TOP, S = 288, 512, 32, 3


def lacquer_bar(p, y0, y1):
    p.rect(0, y0, W - 1, y1, "lacquer")
    for y in range(y0, y1 + 1, 3):
        p.hline(0, W - 1, y, (100, 28, 26))
    p.hline(0, W - 1, y0, "gold_dark")
    p.hline(0, W - 1, y1, "gold_dark")


def text(d, xy, s, size, fill, bold=True, anchor="la"):
    d.text(xy, s, font=ImageFont.truetype(FONT_BOLD if bold else FONT_MED, size), fill=fill, anchor=anchor)


def mockup_battle(tiles, units, portraits):
    img = canvas(W, H, C["lacquer_dark"])
    img.alpha_composite(draw_map(tiles, units, TOP), (0, 0))
    p = Pen(img)
    cur = canvas(T, T)
    q = Pen(cur)
    for sx in (0, 1):
        for sy in (0, 1):
            x, y = (0, 31)[sx], (0, 31)[sy]
            dx, dy = (1, -1)[sx], (1, -1)[sy]
            for i in range(7):
                q.px(x + dx * i, y, "gold_light")
                q.px(x, y + dy * i, "gold_light")
                q.px(x + dx * i, y + dy, "gold_dark")
                q.px(x + dx, y + dy * i, "gold_dark")
    img.alpha_composite(cur, (4 * T, TOP + 8 * T))
    lacquer_bar(p, 0, TOP - 1)
    panel = TOP + len(MAP) * T
    lacquer_bar(p, panel, H - 1)
    img.alpha_composite(portrait_frame(portraits["qt"], "tayson"), (6, panel + 4))
    for i in range(3):
        bx = 104 + i * 60
        p.rect(bx, panel + 64, bx + 54, panel + 88, "lacquer_light" if i == 2 else "lacquer_dark")
        p.hline(bx, bx + 54, panel + 64, "gold")
    img.alpha_composite(Image.open(os.path.join(HERE, "assets", "ui_coin.png")).resize((12, 12)), (196, 10))

    big = img.resize((W * S, H * S), Image.NEAREST)
    d = ImageDraw.Draw(big)
    gold, white, dim = rgba(C["gold_light"]), rgba(C["white"]), (220, 200, 170, 255)
    text(d, (18, 14), "Hà Hồi · Lượt 2", 38, gold)
    text(d, (18, 60), "Mục tiêu: hạ đồn trước rạng sáng", 24, dim, bold=False)
    text(d, (634, 22), "800", 40, white)
    py = panel * S
    text(d, (312, py + 18), "Quang Trung", 46, gold)
    text(d, (312, py + 82), "Máu 100   Công 55–65", 30, white, bold=False)
    text(d, (312, py + 122), "Thủ 20   Đi 4   Cấp 2", 30, white, bold=False)
    for i, label in enumerate(("Chờ", "Đi", "Đánh")):
        text(d, ((104 + i * 60 + 27) * S, py + 76 * S), label, 32, gold, anchor="mm")
    return big


def mockup_dialogue(tiles, units, portraits):
    m = draw_map(tiles, units, TOP, highlights=False)
    m = night(m, night_lights(TOP))
    torch_overlay(m, TOP)
    img = canvas(W, H, C["ink"])
    img.alpha_composite(m, (0, 0))
    p = Pen(img)
    lacquer_bar(p, 0, TOP - 1)
    box_y = 372
    shade = canvas(W, H - box_y + 30)
    Pen(shade).rect(0, 0, W - 1, shade.height - 1, (0, 0, 0, 120))
    img.alpha_composite(shade, (0, box_y - 30))
    p.rect(4, box_y, W - 5, H - 6, (24, 10, 12, 236))
    p.rect(4, box_y, W - 5, box_y + 1, "gold")
    p.rect(4, H - 7, W - 5, H - 6, "gold_dark")
    p.rect(4, box_y, 5, H - 6, "gold_dark")
    p.rect(W - 6, box_y, W - 5, H - 6, "gold_dark")
    img.alpha_composite(portrait_frame(portraits["qt"], "tayson"), (10, box_y - 56))
    p.rect(104, box_y - 14, 210, box_y + 4, TEAMS["tayson"]["team"])   # bảng tên
    p.hline(104, 210, box_y - 14, "gold")
    p.hline(104, 210, box_y + 4, "gold_dark")
    p.rect(W - 22, H - 22, W - 16, H - 18, "gold")  # ▼ tiếp
    p.rect(W - 21, H - 17, W - 17, H - 16, "gold")
    p.px(W - 19, H - 15, "gold")

    big = img.resize((W * S, H * S), Image.NEAREST)
    d = ImageDraw.Draw(big)
    gold, white = rgba(C["gold_light"]), rgba(C["white"])
    text(d, (18, 14), "Đêm 30 Tết · Hà Hồi", 38, gold)
    text(d, (18, 60), "Kỷ Dậu 1789", 24, (220, 200, 170, 255), bold=False)
    text(d, (157 * S, (box_y - 5) * S), "Quang Trung", 34, white, anchor="mm")
    lines = [
        "Đánh cho để dài tóc,",
        "đánh cho để đen răng,",
        "đánh cho nó chích luân bất phản,",
        "đánh cho nó phiến giáp bất hoàn...",
    ]
    for i, ln in enumerate(lines):
        text(d, (36, (box_y + 38) * S + i * 52), ln, 36, white, bold=False)
    return big


# =============================================================================
# 6. MAIN
# =============================================================================
def preview(groups, scale=3, width=820, step=132):
    font = ImageFont.truetype(FONT_MED, 18)
    title = ImageFont.truetype(FONT_BOLD, 26)
    per_row = lambda size: max(1, (width - 24) // max(step, size * scale + 12))
    height = 12 + sum(40 + -(-len(items) // per_row(size)) * (size * scale + 28) for _, items, size in groups)
    sheet = canvas(width, height, (34, 30, 36))
    d = ImageDraw.Draw(sheet)
    y = 10
    for name, items, size in groups:
        d.text((12, y), name, font=title, fill=rgba(C["gold_light"]))
        y += 40
        n, cell = per_row(size), max(step, size * scale + 12)
        for i, (label, im) in enumerate(items):
            x = 12 + (i % n) * cell
            yy = y + (i // n) * (size * scale + 28)
            bg = canvas(size, size, (58, 54, 62))
            bg.alpha_composite(im.crop((0, 0, size, size)))
            sheet.alpha_composite(bg.resize((size * scale, size * scale), Image.NEAREST), (x, yy))
            d.text((x, yy + size * scale + 2), label, font=font, fill=rgba(C["white"]))
        y += -(-len(items) // n) * (size * scale + 28)
    return sheet


def main():
    os.makedirs(OUT_DIR, exist_ok=True)

    def save(im, name):
        im.save(os.path.join(OUT_DIR, name + ".png"))
        print(f"  {name}.png  {im.width}x{im.height}")

    units = {}
    for name, fn in UNITS.items():
        units[name] = strip([fn(0), fn(1)])
        save(units[name], f"unit_{name}_strip2")
    tiles = {name: fn() for name, fn in TILES.items()}
    for name, im in tiles.items():
        save(im, "tile_" + name)
    save(strip([t_water(0), t_water(1)]), "tile_water_strip2")
    portraits = {who: portrait(who) for who in ("qt", "tsn")}
    save(portraits["qt"], "portrait_quangtrung")
    save(portraits["tsn"], "portrait_tonsinghi")

    framed = [("quangtrung", portrait_frame(portraits["qt"], "tayson")),
              ("tonsinghi", portrait_frame(portraits["tsn"], "thanh"))]
    save(preview([
        ("Tây Sơn (32px)", [(n.split("_", 1)[1], im) for n, im in units.items() if n.startswith("tayson")], 32),
        ("Quân Thanh (32px)", [(n.split("_", 1)[1], im) for n, im in units.items() if n.startswith("thanh")], 32),
        ("Địa hình (32px)", [(n.replace("village_", "làng ").replace("castle_", "thành ").replace("fort_", "đồn ")
                              .replace("neutral", "trống"), im) for n, im in tiles.items()], 32),
        ("Chân dung hội thoại", framed, 88),
    ]), "preview_sheet")
    save(mockup_battle(tiles, units, portraits), "mockup_battle")
    save(mockup_dialogue(tiles, units, portraits), "mockup_dialogue_night")


if __name__ == "__main__":
    main()
