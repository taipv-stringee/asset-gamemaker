#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
generate_assets.py — Vẽ toàn bộ hình ảnh pixel art cho game
"Truyền Thuyết Diệt Rồng" (GameMaker, top-down hành động nhập vai).

Chạy:
    pip install pillow
    python generate_assets.py

Kết quả:
    assets/*.png           mỗi sprite là một dải ngang (tên_stripN.png) hoặc ảnh tĩnh
    assets/sprites.json    thông tin cho build_project.py: số frame, tốc độ, gốc, vùng va chạm
    assets/preview_sheet.png   xem nhanh mọi sprite (phóng to, nền caro)

Quy ước:
    - Nhân vật chibi 32x32, nhìn từ trên chéo xuống (kiểu game nhập vai cổ điển).
    - Nhân vật có 4 hướng: xuống / lên / phải / trái (trái = lật ảnh phải).
    - Vũ khí và đạn vẽ HƯỚNG SANG PHẢI (góc 0 của GameMaker) -> image_angle = hướng bắn.
    - Không anti-alias: chỉ đặt từng điểm ảnh, viền tối 1px.
"""

import json
import math
import os
import random

from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
OUT_DIR = os.path.join(HERE, "assets")

# =============================================================================
# 1. BẢNG MÀU CHUNG (mọi sprite chỉ dùng màu trong bảng này)
# =============================================================================
PALETTE = {
    "outline":      (22, 20, 34),
    "white":        (248, 248, 240),
    "shadow":       (0, 0, 0),          # bóng đổ (dùng với độ trong suốt)
    # Da, tóc
    "skin":         (244, 194, 152),
    "skin_dark":    (200, 136, 102),
    "hair":         (118, 72, 40),
    "blond":        (238, 202, 102),
    # Kim loại
    "steel_dark":   (86, 96, 118),
    "steel":        (148, 160, 180),
    "steel_light":  (214, 222, 234),
    # Vải / màu đội
    "blue_dark":    (34, 54, 118),
    "blue":         (58, 96, 182),
    "blue_light":   (112, 152, 222),
    "red_dark":     (126, 22, 36),
    "red":          (204, 46, 54),
    "red_light":    (244, 104, 92),
    "green_dark":   (30, 84, 50),
    "green":        (58, 136, 66),
    "green_light":  (126, 194, 92),
    "purple_dark":  (58, 30, 94),
    "purple":       (106, 58, 162),
    "purple_light": (164, 112, 214),
    # Gỗ, da thuộc
    "wood_dark":    (82, 50, 30),
    "wood":         (134, 86, 48),
    "wood_light":   (184, 128, 78),
    # Vàng
    "gold_dark":    (176, 114, 22),
    "gold":         (242, 188, 48),
    "gold_light":   (255, 236, 142),
    # Xương
    "bone_dark":    (164, 154, 130),
    "bone":         (230, 222, 198),
    # Quái vật
    "slime_dark":   (36, 128, 70),
    "slime":        (88, 200, 92),
    "slime_light":  (184, 244, 144),
    "gob_dark":     (64, 106, 38),
    "gob":          (116, 160, 58),
    "gob_light":    (170, 206, 96),
    "orc_dark":     (78, 92, 52),
    "orc":          (122, 138, 74),
    "orc_light":    (170, 182, 104),
    "dragon_dark":  (92, 16, 34),
    "dragon":       (164, 32, 46),
    "dragon_light": (218, 72, 70),
    # Phép thuật
    "fire_dark":    (204, 62, 22),
    "fire":         (250, 142, 32),
    "fire_light":   (255, 224, 96),
    "ice_dark":     (58, 136, 200),
    "ice":          (132, 210, 242),
    "ice_light":    (222, 248, 255),
    "magic_dark":   (90, 40, 170),
    "magic":        (160, 90, 240),
    "magic_light":  (220, 180, 255),
    # Địa hình
    "grass_dark":   (50, 108, 54),
    "grass":        (80, 148, 66),
    "grass_light":  (130, 186, 82),
    "dirt_dark":    (118, 82, 52),
    "dirt":         (160, 118, 74),
    "dirt_light":   (198, 158, 106),
    "stone_dark":   (56, 60, 78),
    "stone":        (90, 96, 116),
    "stone_light":  (134, 140, 158),
    "rock_dark":    (38, 28, 34),
    "rock":         (66, 50, 54),
    "rock_light":   (100, 78, 76),
    "lava_dark":    (176, 38, 20),
    "lava":         (242, 112, 30),
    "lava_light":   (255, 204, 72),
    "water_dark":   (30, 78, 148),
    "water":        (50, 122, 200),
    "water_light":  (114, 182, 232),
}


def col(name, alpha=255):
    r, g, b = PALETTE[name]
    return (r, g, b, alpha)


def C(c):
    """Nhận tên màu (chuỗi) hoặc bộ RGBA."""
    return col(c) if isinstance(c, str) else c


SHADOW = (0, 0, 0, 72)   # bóng đổ bán trong suốt dưới chân nhân vật

# =============================================================================
# 2. HÀM VẼ CƠ BẢN — tâm điểm ảnh (x, y) ở toạ độ nguyên; ảnh rộng 32 thì
#    tâm là 15.5 nên vẽ quanh 15.5 sẽ cân đối hai bên.
# =============================================================================
def new(w, h):
    return Image.new("RGBA", (w, h), (0, 0, 0, 0))


def put(img, x, y, c):
    x, y = int(math.floor(x)), int(math.floor(y))
    if 0 <= x < img.width and 0 <= y < img.height:
        img.putpixel((x, y), C(c))


def put_on(img, x, y, c):
    """Chỉ tô lên điểm đã có màu (vẽ hoa văn bên trong hình)."""
    x, y = int(math.floor(x)), int(math.floor(y))
    if 0 <= x < img.width and 0 <= y < img.height and img.getpixel((x, y))[3] > 0:
        img.putpixel((x, y), C(c))


def rect(img, x0, y0, x1, y1, c, only_on=False):
    """Chữ nhật đặc, toạ độ tính cả hai đầu."""
    f = put_on if only_on else put
    for y in range(int(y0), int(y1) + 1):
        for x in range(int(x0), int(x1) + 1):
            f(img, x, y, c)


def ellipse(img, cx, cy, rx, ry, c, only_on=False):
    f = put_on if only_on else put
    for y in range(math.floor(cy - ry), math.ceil(cy + ry) + 1):
        for x in range(math.floor(cx - rx), math.ceil(cx + rx) + 1):
            if ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 < 1:
                f(img, x, y, c)


def disk(img, cx, cy, r, c, only_on=False):
    if r > 0:
        ellipse(img, cx, cy, r, r, c, only_on)


def ring(img, cx, cy, r, width, c):
    for y in range(math.floor(cy - r), math.ceil(cy + r) + 1):
        for x in range(math.floor(cx - r), math.ceil(cx + r) + 1):
            if r - width <= math.hypot(x - cx, y - cy) < r:
                put(img, x, y, c)


def poly(img, pts, c, only_on=False):
    """Đa giác đặc (tâm điểm ảnh nằm trong đa giác thì tô)."""
    f = put_on if only_on else put
    xs = [p[0] for p in pts]
    ys = [p[1] for p in pts]
    n = len(pts)
    for y in range(math.floor(min(ys)), math.ceil(max(ys)) + 1):
        for x in range(math.floor(min(xs)), math.ceil(max(xs)) + 1):
            inside = False
            j = n - 1
            for i in range(n):
                xi, yi = pts[i]
                xj, yj = pts[j]
                if (yi > y) != (yj > y) and x < (xj - xi) * (y - yi) / (yj - yi) + xi:
                    inside = not inside
                j = i
            if inside:
                f(img, x, y, c)


def rnd(v):
    return int(math.floor(v + 0.5))


def line(img, x0, y0, x1, y1, c, w=1, only_on=False):
    n = int(max(abs(x1 - x0), abs(y1 - y0)) * 2) + 1
    for i in range(n + 1):
        t = i / n
        x = x0 + (x1 - x0) * t
        y = y0 + (y1 - y0) * t
        if w <= 1:
            (put_on if only_on else put)(img, rnd(x), rnd(y), c)
        else:
            disk(img, x, y, w / 2, c, only_on)


def outline(img, c="outline", wrap=False):
    """Viền 1px quanh mọi vùng có màu (bỏ qua điểm bán trong suốt như bóng đổ).
    wrap=True: coi các mép ảnh nối vòng (dùng cho tile lặp)."""
    c = C(c)
    w, h = img.size
    pix = img.load()
    solid = [[pix[x, y][3] > 200 for x in range(w)] for y in range(h)]
    for y in range(h):
        for x in range(w):
            if solid[y][x]:
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if wrap:
                    nx, ny = nx % w, ny % h
                if 0 <= nx < w and 0 <= ny < h and solid[ny][nx]:
                    pix[x, y] = c
                    break
    return img


def flip(img):
    return img.transpose(Image.FLIP_LEFT_RIGHT)


def recolor(img, mapping):
    """Đổi màu theo bảng {tên cũ: tên mới}."""
    table = {PALETTE[k]: C(v)[:3] for k, v in mapping.items()}
    pix = img.load()
    for y in range(img.height):
        for x in range(img.width):
            r, g, b, a = pix[x, y]
            if a and (r, g, b) in table:
                pix[x, y] = table[(r, g, b)] + (a,)
    return img


def rotate(img, deg):
    """Xoay giữ nét pixel (nearest neighbor)."""
    return img.rotate(deg, resample=Image.NEAREST)


def scale_px(img, k):
    return img.resize((img.width * k, img.height * k), Image.NEAREST)


# =============================================================================
# 3. LƯU SPRITE + GHI THÔNG TIN CHO GAMEMAKER
# =============================================================================
SPRITES = []   # danh sách sprite đã tạo (để in báo cáo, ghép preview, xuất json)


def bbox_of(frames):
    """Hình chữ nhật bao mọi điểm có màu của tất cả frame (l, t, r, b)."""
    l, t, r, b = 10 ** 6, 10 ** 6, -1, -1
    for f in frames:
        bb = f.getbbox()
        if bb:
            l, t = min(l, bb[0]), min(t, bb[1])
            r, b = max(r, bb[2] - 1), max(b, bb[3] - 1)
    return (0, 0, frames[0].width - 1, frames[0].height - 1) if r < 0 else (l, t, r, b)


def save(name, frames, group, fps=8, origin=None, mask=None, edge_check=True, max_colors=12):
    """Lưu dải ngang + ghi lại thông tin.
    origin: (x, y) gốc sprite; mặc định ở giữa khung.
    mask  : (trái, trên, phải, dưới) vùng va chạm; mặc định bao sát hình."""
    if isinstance(frames, Image.Image):
        frames = [frames]
    n = len(frames)
    fw, fh = frames[0].size
    fname = f"{name}_strip{n}.png" if n > 1 else f"{name}.png"
    sheet = new(fw * n, fh)
    for i, f in enumerate(frames):
        sheet.paste(f, (i * fw, 0))
    sheet.save(os.path.join(OUT_DIR, fname))
    if origin is None:
        origin = (fw // 2, fh // 2)
    SPRITES.append(dict(name=name, file=fname, frames=frames, w=fw, h=fh, n=n, fps=fps,
                        origin=list(origin), mask=list(mask or bbox_of(frames)), group=group,
                        warnings=check(frames, edge_check, max_colors)))


def check(frames, edge_check, max_colors):
    """Tự kiểm tra: frame trống, quá nhiều màu, hình chạm mép khung."""
    warns = []
    fw, fh = frames[0].size
    for i, f in enumerate(frames):
        pix = f.load()
        colors, edge = set(), 0
        for y in range(fh):
            for x in range(fw):
                p = pix[x, y]
                if p[3] < 200:
                    continue
                colors.add(p[:3])
                if x in (0, fw - 1) or y in (0, fh - 1):
                    edge += 1
        if not colors:
            warns.append(f"frame {i}: trống")
        if len(colors) > max_colors:
            warns.append(f"frame {i}: {len(colors)} màu (> {max_colors})")
        if edge_check and edge:
            warns.append(f"frame {i}: {edge} điểm chạm mép khung")
    return warns


# =============================================================================
# 4. NHÂN VẬT CHIBI (khung 32x32, chân chạm đất ở y = 28)
# =============================================================================
def walk_phase(f):
    """Pha bước chân: 0 đứng, 1 chân trái lên trước, 2 đứng, 3 chân phải lên trước.
    Trả về (lệch chân trái, lệch chân phải, nhún người)."""
    return [(0, 0, 0), (1, -1, 1), (0, 0, 0), (-1, 1, 1)][f]


def draw_shadow(img, cx=15.5, cy=28.5, rx=6.5, ry=2.0):
    ellipse(img, cx, cy, rx, ry, SHADOW)


def body_front(img, f, c, wide=0, robe=False):
    """Thân nhìn từ trước/sau: chân, mình, tay, đầu (chưa có tóc/mũ).
    c: dict màu 'leg', 'boot', 'torso', 'torso_dark', 'belt', 'arm', 'skin'."""
    ll, rl, b = walk_phase(f)
    draw_shadow(img)
    if robe:   # áo choàng dài che chân, chỉ lộ mũi giày
        put(img, 12, 28 - (ll > 0), c["boot"]); put(img, 13, 28 - (ll > 0), c["boot"])
        put(img, 18, 28 - (rl > 0), c["boot"]); put(img, 19, 28 - (rl > 0), c["boot"])
        poly(img, [(10.5 - wide, 15 + b), (20.5 + wide, 15 + b), (22.5 + wide, 28), (8.5 - wide, 28)], c["torso"])
        rect(img, 18 + wide, 17 + b, 21 + wide, 27, c["torso_dark"], only_on=True)
    else:
        for lx, lift in ((12, ll > 0), (17, rl > 0)):
            bottom = 28 - lift
            rect(img, lx, 23, lx + 2, bottom, c["leg"])
            rect(img, lx, bottom - 1, lx + 2, bottom, c["boot"])
        rect(img, 10 - wide, 15 + b, 21 + wide, 23 + b, c["torso"])
        rect(img, 19 + wide, 15 + b, 21 + wide, 23 + b, c["torso_dark"])
        rect(img, 10 - wide, 21 + b, 21 + wide, 21 + b, c["belt"])
    # tay đung đưa ngược chân
    for ax, sw in ((8 - wide, -ll), (22 + wide, -rl)):
        top = 16 + b + max(0, sw)
        rect(img, ax, top, ax + 1, top + 4, c["arm"])
        rect(img, ax, top + 5, ax + 1, top + 5, c["skin"])
    ellipse(img, 15.5, 10 + b, 6.3, 5.7, c["skin"])   # đầu
    return b


def body_side(img, f, c, robe=False):
    """Thân nhìn nghiêng (quay phải)."""
    ll, rl, b = walk_phase(f)
    draw_shadow(img, rx=5.5)
    if robe:
        put(img, 13 + 2 * ll, 28, c["boot"]); put(img, 14 + 2 * ll, 28, c["boot"])
        put(img, 17 + 2 * rl, 28, c["boot"]); put(img, 18 + 2 * rl, 28, c["boot"])
        poly(img, [(11.5, 15 + b), (19.5, 15 + b), (21.5, 28), (9.5, 28)], c["torso"])
        rect(img, 10, 17 + b, 12, 27, c["torso_dark"], only_on=True)
    else:
        # chân sau (tối) rồi chân trước
        for off, colr in ((rl, c["boot"]), (ll, c["leg"])):
            x0 = 14 + 2 * off
            rect(img, x0, 23, x0 + 2, 28, colr)
            rect(img, x0, 27, x0 + 3, 28, c["boot"])
        rect(img, 11, 15 + b, 20, 23 + b, c["torso"])
        rect(img, 11, 15 + b, 12, 23 + b, c["torso_dark"])
        rect(img, 11, 21 + b, 20, 21 + b, c["belt"])
    ellipse(img, 16, 10 + b, 6.0, 5.7, c["skin"])
    return b


def arm_side(img, f, c, b):
    """Tay phía trước khi nhìn nghiêng (vẽ sau cùng để đè lên mình)."""
    sw = [0, 2, 0, -2][f]
    line(img, 15, 16 + b, 15 + sw, 21 + b, c["arm"], w=2)
    put(img, 15 + sw, 22 + b, c["skin"])
    put(img, 16 + sw, 22 + b, c["skin"])


def eyes_front(img, b, colr="outline"):
    for x in (13, 18):
        put(img, x, 11 + b, colr)
        put(img, x, 12 + b, colr)


def eye_side(img, b, colr="outline"):
    put(img, 19, 11 + b, colr)
    put(img, 19, 12 + b, colr)


# ---------------------------------------------------------------- Hiệp sĩ
KNIGHT = dict(leg="steel_dark", boot="outline", torso="steel", torso_dark="steel_dark",
              belt="wood", arm="steel", skin="skin")


def draw_knight(d, f):
    img = new(32, 32)
    c = KNIGHT
    if d == "down":
        b = body_front(img, f, c)
        rect(img, 13, 15 + b, 18, 22 + b, "blue")                 # áo khoác xanh có huy hiệu
        rect(img, 15, 17 + b, 16, 19 + b, "gold")
        rect(img, 10, 21 + b, 21, 21 + b, "wood")
        put(img, 15, 21 + b, "gold"); put(img, 16, 21 + b, "gold")
        ellipse(img, 15.5, 7 + b, 6.8, 4.0, "steel")                # mũ sắt
        rect(img, 9, 7 + b, 11, 13 + b, "steel")                     # má giáp
        rect(img, 20, 7 + b, 22, 13 + b, "steel")
        rect(img, 12, 8 + b, 19, 8 + b, "steel_dark")                # vành mũ
        rect(img, 10, 4 + b, 13, 5 + b, "steel_light")
        ellipse(img, 15.5, 3.2 + b, 1.8, 2.2, "red")                 # chùm lông đỏ
        outline(img)
        eyes_front(img, b)
    elif d == "up":
        b = body_front(img, f, c)
        poly(img, [(10, 15 + b), (21, 15 + b), (23, 26 + b), (8, 26 + b)], "red")   # áo choàng
        rect(img, 19, 16 + b, 22, 26 + b, "red_dark", only_on=True)
        ellipse(img, 15.5, 9.5 + b, 6.8, 6.0, "steel")
        rect(img, 10, 5 + b, 13, 7 + b, "steel_light")
        ellipse(img, 15.5, 3.6 + b, 1.8, 2.6, "red")
        outline(img)
    else:   # phải
        b = body_side(img, f, c)
        poly(img, [(11, 15 + b), (14, 15 + b), (12, 26 + b), (8, 25 + b)], "red")    # áo choàng bay sau lưng
        rect(img, 15, 15 + b, 19, 22 + b, "blue")
        ellipse(img, 15.5, 8.5 + b, 6.6, 5.0, "steel")
        rect(img, 10, 8 + b, 17, 14 + b, "steel")                    # mũ che gáy
        rect(img, 11, 5 + b, 14, 6 + b, "steel_light")
        ellipse(img, 13, 3 + b, 3.0, 1.8, "red")                     # lông mũ ngả ra sau
        arm_side(img, f, c, b)
        outline(img)
        eye_side(img, b)
        rect(img, 18, 9 + b, 21, 9 + b, "steel_dark")                # khe mắt mũ
    return img


# ---------------------------------------------------------------- Cung thủ
ARCHER = dict(leg="wood_dark", boot="wood", torso="green", torso_dark="green_dark",
              belt="wood", arm="green", skin="skin")


def draw_archer(d, f):
    img = new(32, 32)
    c = ARCHER
    if d == "down":
        b = body_front(img, f, c)
        rect(img, 10, 15 + b, 21, 16 + b, "green_dark")           # cổ áo choàng
        put(img, 15, 21 + b, "gold"); put(img, 16, 21 + b, "gold")
        ellipse(img, 15.5, 7 + b, 7.0, 4.4, "green")               # mũ trùm
        rect(img, 9, 7 + b, 11, 15 + b, "green")
        rect(img, 20, 7 + b, 22, 15 + b, "green")
        rect(img, 20, 8 + b, 22, 15 + b, "green_dark")
        rect(img, 12, 8 + b, 19, 9 + b, "blond")                   # tóc mái
        put(img, 12, 10 + b, "blond"); put(img, 19, 10 + b, "blond")
        rect(img, 11, 4 + b, 14, 4 + b, "green_light")
        outline(img)
        eyes_front(img, b)
    elif d == "up":
        b = body_front(img, f, c)
        line(img, 12, 16 + b, 19, 24 + b, "wood_dark", w=1.5)         # dây đeo
        rect(img, 18, 13 + b, 21, 22 + b, "wood")                     # bao tên
        rect(img, 18, 13 + b, 21, 13 + b, "wood_light")
        ellipse(img, 15.5, 9.5 + b, 7.0, 6.0, "green")
        poly(img, [(12, 14 + b), (19, 14 + b), (15.5, 19 + b)], "green_dark")   # chóp mũ trùm
        for k, fx in enumerate((18, 19, 20, 21)):                     # lông đuôi tên
            put(img, fx, 11 + b + k % 2, "red" if k % 2 else "white")
            put(img, fx, 12 + b + k % 2, "red")
        outline(img)
    else:
        b = body_side(img, f, c)
        rect(img, 8, 14 + b, 10, 22 + b, "wood")                     # bao tên sau lưng
        put(img, 8, 12 + b, "red"); put(img, 9, 11 + b, "white"); put(img, 10, 12 + b, "red")
        ellipse(img, 15, 9 + b, 6.8, 5.4, "green")
        rect(img, 9, 9 + b, 15, 15 + b, "green")
        poly(img, [(9, 10 + b), (11, 10 + b), (7, 16 + b)], "green_dark")       # chóp mũ trùm
        rect(img, 17, 7 + b, 21, 8 + b, "blond")
        arm_side(img, f, c, b)
        outline(img)
        eye_side(img, b)
    return img


# ---------------------------------------------------------------- Phù thủy
WIZARD = dict(leg="purple_dark", boot="outline", torso="purple", torso_dark="purple_dark",
              belt="gold", arm="purple", skin="skin")


def wizard_hat(img, b, lean):
    """Mũ chóp nhọn: vành rộng + chóp cong; lean = độ nghiêng chóp."""
    poly(img, [(9.5, 8 + b), (21.5, 8 + b), (16 + lean, 2 + b), (14.5 + lean, 1.6 + b)], "purple")
    ellipse(img, 15.5, 8 + b, 9.0, 2.2, "purple_dark")
    put(img, rnd(15 + lean * 0.6), 4 + b, "gold")
    rect(img, 11, 6 + b, 20, 6 + b, "gold", only_on=True)


def draw_wizard(d, f):
    img = new(32, 32)
    c = WIZARD
    if d == "down":
        b = body_front(img, f, c, robe=True)
        rect(img, 9, 27, 22, 27, "gold", only_on=True)              # viền gấu áo
        poly(img, [(11, 12 + b), (20, 12 + b), (15.5, 20 + b)], "white")   # râu bạc
        wizard_hat(img, b, 3)
        outline(img)
        eyes_front(img, b)
    elif d == "up":
        b = body_front(img, f, c, robe=True)
        rect(img, 9, 27, 22, 27, "gold", only_on=True)
        rect(img, 15, 16 + b, 16, 26, "purple_light", only_on=True)
        ellipse(img, 15.5, 11 + b, 5.6, 4.2, "white")               # tóc bạc sau gáy
        wizard_hat(img, b, -3)
        outline(img)
    else:
        b = body_side(img, f, c, robe=True)
        rect(img, 9, 27, 22, 27, "gold", only_on=True)
        poly(img, [(16, 12 + b), (22, 12 + b), (19, 19 + b)], "white")
        ellipse(img, 12, 11 + b, 3.0, 3.6, "white")
        wizard_hat(img, b, -4)
        arm_side(img, f, c, b)
        outline(img)
        eye_side(img, b)
    return img


def make_heroes():
    """3 nhân vật x 4 hướng, mỗi hướng 4 frame đi bộ (giống spr_player_* của material_8)."""
    mask = (10, 18, 21, 28)  # va chạm ở phần thân dưới + chân
    for name, fn in (("knight", draw_knight), ("archer", draw_archer), ("wizard", draw_wizard)):
        right = [fn("right", f) for f in range(4)]
        save(f"spr_{name}_down", [fn("down", f) for f in range(4)], "heroes", mask=mask)
        save(f"spr_{name}_up", [fn("up", f) for f in range(4)], "heroes", mask=mask)
        save(f"spr_{name}_right", right, "heroes", mask=mask)
        save(f"spr_{name}_left", [flip(im) for im in right], "heroes", mask=mask)


# =============================================================================
# 5. QUÁI VẬT
# =============================================================================
def draw_slime(f):
    """Slime nhún nhảy: bẹp xuống -> bật lên -> rơi."""
    img = new(32, 32)
    rx, ry, up = [(9.0, 7.0, 0), (10.5, 5.8, 0), (8.0, 8.4, -3), (9.4, 6.6, -1)][f]
    draw_shadow(img, rx=7.5 - up * 0.5)
    base = 27 + up
    cy = base - ry * 0.85
    for y in range(32):
        for x in range(32):
            if ((x - 15.5) / rx) ** 2 + ((y - cy) / ry) ** 2 < 1 and y <= base:
                put(img, x, y, "slime")
    ellipse(img, 15.5, base, rx * 0.9, 2.2, "slime_dark", only_on=True)     # đáy tối
    ellipse(img, 11.5, cy - ry * 0.45, 2.2, 1.6, "slime_light", only_on=True)
    outline(img)
    ey = rnd(cy - 1)
    for ex in (12, 18):   # mắt to
        rect(img, ex, ey, ex + 1, ey + 2, "white")
        rect(img, ex + 1, ey + 1, ex + 1, ey + 2, "outline")
    put(img, 15, ey + 4, "outline"); put(img, 16, ey + 4, "outline")
    return img


GOBLIN = dict(leg="wood_dark", boot="outline", torso="wood", torso_dark="wood_dark",
              belt="gob_dark", arm="gob", skin="gob")


def goblin_head(img, b):
    poly(img, [(12, 9 + b), (12, 13 + b), (5, 8 + b)], "gob")          # tai nhọn
    ellipse(img, 16.5, 11 + b, 5.6, 5.0, "gob")
    rect(img, 12, 6 + b, 19, 7 + b, "gob_dark", only_on=True)
    put(img, 22, 12 + b, "gob"); put(img, 22, 13 + b, "gob")          # mũi to


def draw_goblin(f, attack=False):
    """Yêu tinh cầm dao găm, nhìn nghiêng sang phải."""
    img = new(32, 32)
    c = GOBLIN
    b = body_side(img, 0 if attack else f, c)
    rect(img, 11, 15 + b, 20, 16 + b, "gob_dark", only_on=True)     # vai trần
    goblin_head(img, b)
    if attack:   # 0 lấy đà, 1 đâm, 2 giữ, 3 thu dao
        hx, hy = [(13, 15), (21, 18), (22, 18), (17, 19)][f]
        line(img, 15, 16, hx, hy, "gob", w=2)
        tip = [(13, 9), (28, 18), (29, 18), (22, 21)][f]
        line(img, hx, hy, tip[0], tip[1], "steel_light", w=1)
        put(img, hx, hy, "wood")
    else:
        sw = [0, 2, 0, -2][f]
        line(img, 15, 16 + b, 16 + sw, 21 + b, "gob", w=2)
        line(img, 16 + sw, 21 + b, 21 + sw, 19 + b, "steel_light")
    outline(img)
    put(img, 19, 11 + b, "red"); put(img, 20, 11 + b, "red")
    put(img, 20, 15 + b, "white")                                     # răng nanh
    return img


def draw_skeleton(f, attack=False):
    """Xương cung thủ: thân xương, cầm cung gỗ."""
    img = new(32, 32)
    ll, rl, b = walk_phase(0 if attack else f)
    draw_shadow(img, rx=5.5)
    for off in (rl, ll):   # chân xương
        x0 = 15 + 2 * off
        rect(img, x0, 23, x0 + 1, 28, "bone")
        rect(img, x0, 28, x0 + 2, 28, "bone_dark")
    rect(img, 13, 21 + b, 18, 22 + b, "bone_dark")                   # xương chậu
    rect(img, 12, 15 + b, 19, 20 + b, "outline")                     # lồng ngực
    for y in (15, 17, 19):
        rect(img, 12, y + b, 19, y + b, "bone")
    rect(img, 13, 15 + b, 13, 21 + b, "bone")                        # cột sống
    ellipse(img, 16, 10 + b, 5.2, 5.0, "bone")                       # sọ
    rect(img, 15, 14 + b, 20, 15 + b, "bone_dark")                   # hàm
    # cung: 0 giương, 1-2 kéo căng, 3 vừa bắn
    pull = [1, 4, 5, 0][f] if attack else 0
    bx = 23
    for k in range(13):
        y = 11 + k + b
        x = bx + rnd(2.5 * math.sin(math.pi * k / 12))
        put(img, x, y, "wood")
    line(img, bx, 11 + b, bx - pull, 17 + b, "white")
    line(img, bx - pull, 17 + b, bx, 23 + b, "white")
    if attack and f in (1, 2):
        line(img, bx - pull, 17 + b, bx + 5, 17 + b, "wood_light")
        put(img, bx + 6, 17 + b, "steel_light")
    line(img, 16, 16 + b, bx - pull, 17 + b, "bone", w=1)            # tay kéo dây
    line(img, 16, 17 + b, bx + 1, 17 + b, "bone", w=1)
    outline(img)
    rect(img, 17, 9 + b, 19, 11 + b, "outline")                      # hốc mắt
    put(img, 18, 10 + b, "red")
    for x in (16, 18, 20):
        put(img, x, 14 + b, "outline")                               # răng
    return img


def draw_bat(f):
    """Dơi bay vỗ cánh, nhìn trực diện."""
    img = new(32, 32)
    dy = [-6, -1, 5, -1][f]
    ellipse(img, 15.5, 29, 4, 1.4, SHADOW)
    for s in (-1, 1):
        pts = [(15.5 + s * 3, 12), (15.5 + s * 9, 9 + dy), (15.5 + s * 13.5, 12 + dy),
               (15.5 + s * 12.5, 18 + dy * 0.5), (15.5 + s * 10, 16 + dy * 0.4),
               (15.5 + s * 7, 20 + dy * 0.3), (15.5 + s * 3, 18)]
        poly(img, pts, "purple")
        line(img, 15.5 + s * 3, 13, 15.5 + s * 13, 12 + dy, "purple_light")
    ellipse(img, 15.5, 15, 4.2, 5.2, "purple_dark")
    poly(img, [(12, 12), (13, 6), (15, 11)], "purple_dark")
    poly(img, [(19, 12), (18, 6), (16, 11)], "purple_dark")
    outline(img)
    put(img, 13, 13, "red"); put(img, 18, 13, "red")
    put(img, 14, 17, "white"); put(img, 17, 17, "white")
    return img


def draw_orc(f, attack=False):
    """Orc to xác cầm chùy gai (khung 40x40, nhìn nghiêng phải).
    Tấn công 6 frame: giơ chùy ra sau (0-2) -> đập xuống phía trước (3-4) -> thu về (5)."""
    img = new(40, 40)
    ll, rl, b = walk_phase(0 if attack else f)
    ellipse(img, 19.5, 36.5, 9, 2.4, SHADOW)
    for off, colr in ((rl, "orc_dark"), (ll, "wood_dark")):    # chân
        x0 = 15 + 2 * off
        rect(img, x0, 29, x0 + 3, 36, colr)
        rect(img, x0, 35, x0 + 4, 36, "outline")
    ellipse(img, 18, 23 + b, 8.5, 8.0, "orc")                        # thân gù
    ellipse(img, 21, 24 + b, 4.0, 5.0, "orc_light")                  # bụng
    rect(img, 11, 27 + b, 25, 30 + b, "wood")                        # khố da
    rect(img, 11, 27 + b, 25, 27 + b, "wood_dark")
    ellipse(img, 13, 18 + b, 4.6, 3.6, "steel")                      # giáp vai sau
    rect(img, 10, 16 + b, 15, 16 + b, "steel_light", only_on=True)
    ellipse(img, 24, 12 + b, 5.6, 5.2, "orc")                        # đầu
    rect(img, 23, 14 + b, 29, 18 + b, "orc")                         # hàm bạnh
    rect(img, 20, 7 + b, 27, 8 + b, "orc_dark", only_on=True)        # tóc / da đầu sẫm
    # tay + chùy (góc tính theo độ, 0 = sang phải, 90 = lên trên)
    ang = [150, 125, 105, 25, 345, 320][f] if attack else 300 + [0, 8, 0, -8][f]
    a = math.radians(ang)
    sx, sy = 20, 19 + b
    hx, hy = sx + 6 * math.cos(a), sy - 6 * math.sin(a)
    line(img, sx, sy, hx, hy, "orc", w=3)
    ex, ey = hx + 7 * math.cos(a), hy - 7 * math.sin(a)
    line(img, hx, hy, ex, ey, "wood", w=2)
    disk(img, ex, ey, 3.0, "wood_dark")
    for k in range(4):   # gai sắt
        ka = a + k * math.pi / 2 + 0.4
        put(img, ex + 3.8 * math.cos(ka), ey - 3.8 * math.sin(ka), "steel_light")
    outline(img)
    rect(img, 25, 9 + b, 29, 9 + b, "outline")                       # mày rậm
    put(img, 27, 10 + b, "red")
    put(img, 28, 13 + b, "white"); put(img, 28, 12 + b, "white")     # răng nanh chĩa lên
    put(img, 25, 13 + b, "white")
    if attack and f == 4:   # bụi đất khi đập
        for k in range(5):
            put(img, ex - 6 + k * 3, 37 - k % 2, "dirt_light")
    return img


def draw_dragon(f, breath=False, n=6):
    """Hắc Long (trùm cuối) 96x96, nhìn trực diện, vỗ cánh.
    breath=True: há miệng phun lửa."""
    img = new(96, 96)
    cx = 47.5
    ph = f * 2 * math.pi / n
    dy = 8 * math.sin(ph) if not breath else -2      # cánh lên xuống
    bob = rnd(2 * math.sin(ph + 1.2)) if not breath else 0
    ellipse(img, cx, 88, 22, 4, SHADOW)
    # đuôi
    for i in range(30):
        t = i / 29
        x = cx + 4 + 30 * t
        y = 74 + bob - 14 * math.sin(t * 2.5) + 6 * t
        disk(img, x, y, 5 * (1 - t) + 1.5, "dragon")
    poly(img, [(cx + 32, 70 + bob), (cx + 42, 66 + bob), (cx + 38, 76 + bob)], "dragon_dark")
    # cánh
    for s in (-1, 1):
        sx = cx + s * 12
        pts = [(sx, 42 + bob), (cx + s * 30, 16 + dy), (cx + s * 45, 26 + dy),
               (cx + s * 42, 44 + dy * 0.6), (cx + s * 35, 40 + dy * 0.5),
               (cx + s * 31, 52 + dy * 0.4), (cx + s * 24, 47 + dy * 0.3),
               (cx + s * 19, 58 + bob)]
        poly(img, pts, "dragon_dark")
        for tx, ty in ((cx + s * 45, 26 + dy), (cx + s * 35, 40 + dy * 0.5), (cx + s * 24, 47 + dy * 0.3)):
            line(img, sx, 42 + bob, tx, ty, "dragon", w=2)
        line(img, sx, 42 + bob, cx + s * 30, 16 + dy, "dragon_light", w=2)
    # thân + bụng vảy vàng
    ellipse(img, cx, 58 + bob, 15, 18, "dragon")
    ellipse(img, cx, 61 + bob, 8.5, 13, "gold")
    for y in range(52, 74, 3):
        rect(img, cx - 9, y + bob, cx + 9, y + bob, "gold_dark", only_on=True)
    for s in (-1, 1):   # chân + móng
        ellipse(img, cx + s * 11, 74 + bob, 5, 4, "dragon_dark")
        for k in range(3):
            put(img, cx + s * 11 - 2 + k * 2, 78 + bob, "bone")
        ellipse(img, cx + s * 13, 52 + bob, 3, 4, "dragon_light")   # tay nhỏ
    # cổ + đầu
    ellipse(img, cx, 42 + bob, 8, 8, "dragon")
    for s in (-1, 1):   # sừng cong
        line(img, cx + s * 6, 25 + bob, cx + s * 13, 14 + bob, "bone", w=3)
        line(img, cx + s * 13, 14 + bob, cx + s * 12, 9 + bob, "bone", w=2)
        poly(img, [(cx + s * 9, 30 + bob), (cx + s * 18, 26 + bob), (cx + s * 11, 34 + bob)], "dragon_dark")  # tai
    ellipse(img, cx, 30 + bob, 11, 8.5, "dragon")
    ellipse(img, cx, 37 + bob, 7.5, 5.0, "dragon_light")             # mõm
    rect(img, cx - 1, 22 + bob, cx + 1, 27 + bob, "dragon_dark", only_on=True)
    if breath:   # miệng há có lửa
        ellipse(img, cx, 41 + bob, 5.5, 3.5 + f, "outline")
        ellipse(img, cx, 42 + bob, 3.8, 2.5 + f, "fire")
        ellipse(img, cx, 42.5 + bob, 2, 1.4 + f * 0.6, "fire_light")
    outline(img)
    for s in (-1, 1):   # mắt vàng rực, đồng tử dọc
        ex = cx + s * 5.5
        rect(img, ex - 1.5, 27 + bob, ex + 1.5, 29 + bob, "fire_light")
        put(img, ex if s > 0 else ex - 0.5, 27 + bob, "outline")
        put(img, ex if s > 0 else ex - 0.5, 28 + bob, "outline")
        line(img, ex - 2.5 * s, 25 + bob, ex + 2 * s, 26 + bob, "outline")   # mày nhíu
        put(img, cx + s * 2.5, 36 + bob, "outline")                         # lỗ mũi
    for k in range(5):  # gai trên đầu
        put(img, cx - 4 + k * 2, 21 + bob - (k % 2), "dragon_light")
    return img


def make_enemies():
    save("spr_slime", [draw_slime(f) for f in range(4)], "enemies", fps=8, mask=(8, 18, 23, 28))
    m = (11, 16, 21, 28)
    save("spr_goblin_walk", [draw_goblin(f) for f in range(4)], "enemies", fps=10, mask=m)
    save("spr_goblin_atk", [draw_goblin(f, True) for f in range(4)], "enemies", fps=12, mask=m)
    save("spr_skeleton_walk", [draw_skeleton(f) for f in range(4)], "enemies", fps=8, mask=m)
    save("spr_skeleton_atk", [draw_skeleton(f, True) for f in range(4)], "enemies", fps=6, mask=m)
    save("spr_bat", [draw_bat(f) for f in range(4)], "enemies", fps=12, mask=(9, 9, 22, 21))
    om = (11, 18, 27, 36)
    save("spr_orc_walk", [draw_orc(f) for f in range(4)], "enemies", fps=7, mask=om)
    save("spr_orc_atk", [draw_orc(f, True) for f in range(6)], "enemies", fps=8, mask=om)
    dm = (26, 24, 69, 82)
    save("spr_dragon_fly", [draw_dragon(f) for f in range(6)], "boss", fps=8, mask=dm, max_colors=16)
    save("spr_dragon_breath", [draw_dragon(f, True) for f in range(3)], "boss", fps=8, mask=dm, max_colors=16)


# =============================================================================
# 6. VŨ KHÍ CẦM TAY (32x32, hướng sang phải, gốc ở chuôi cầm (8, 16))
# =============================================================================
WEAPON_ORIGIN = (8, 16)


def make_weapons():
    g = "weapons"
    # Kiếm thép
    img = new(32, 32)
    rect(img, 10, 15, 27, 16, "steel")
    rect(img, 10, 15, 27, 15, "steel_light")
    poly(img, [(27.5, 14.5), (31, 15.5), (27.5, 17)], "steel_light")
    rect(img, 9, 11, 10, 20, "gold")
    rect(img, 5, 15, 8, 16, "wood")
    disk(img, 4, 15.5, 1.6, "gold")
    save("spr_wp_sword", outline(img), g, origin=WEAPON_ORIGIN, edge_check=False)
    # Rìu chiến (lưỡi kép)
    img = new(32, 32)
    rect(img, 3, 15, 26, 16, "wood")
    rect(img, 3, 16, 26, 16, "wood_dark")
    for s in (-1, 1):
        poly(img, [(20, 15.5 + s * 1), (21, 15.5 + s * 9), (26, 15.5 + s * 11), (29, 15.5 + s * 6), (25, 15.5 + s * 1)], "steel")
        line(img, 26, 15.5 + s * 11, 29, 15.5 + s * 6, "steel_light")
    rect(img, 19, 14, 25, 17, "steel_dark")
    save("spr_wp_axe", outline(img), g, origin=WEAPON_ORIGIN)
    # Cung gỗ
    img = new(32, 32)
    for k in range(25):
        y = 3.5 + k
        x = 13 + 6 * math.sin(math.pi * k / 24)
        put(img, x, y, "wood"); put(img, x + 1, y, "wood_light")
    line(img, 13, 4, 13, 27, "white")
    rect(img, 18, 14, 19, 17, "red")
    save("spr_wp_bow", outline(img), g, origin=(14, 16))
    # Nỏ
    img = new(32, 32)
    rect(img, 4, 15, 22, 17, "wood")
    rect(img, 4, 17, 22, 17, "wood_dark")
    for k in range(17):
        y = 7.5 + k
        put(img, 21 + 2.5 * math.sin(math.pi * k / 16), y, "steel")
    line(img, 20, 8, 15, 16, "white")
    line(img, 15, 16, 20, 23, "white")
    rect(img, 12, 14, 26, 14, "steel_light")
    put(img, 27, 14, "steel_light")
    save("spr_wp_crossbow", outline(img), g, origin=WEAPON_ORIGIN)
    # Gậy lửa và gậy sét
    for name, orb, orb_l, orb_d in (("spr_wp_staff_fire", "fire", "fire_light", "fire_dark"),
                                    ("spr_wp_staff_storm", "ice", "ice_light", "magic")):
        img = new(32, 32)
        rect(img, 2, 15, 23, 16, "wood")
        rect(img, 2, 16, 23, 16, "wood_dark")
        for k in (6, 12, 18):
            put(img, k, 15, "gold")
        poly(img, [(22, 12), (25, 15.5), (22, 20), (24, 15.5)], "gold")
        disk(img, 27, 15.5, 3.6, orb_d)
        disk(img, 27, 15.5, 2.6, orb)
        disk(img, 26.2, 14.6, 1.2, orb_l)
        save(name, outline(img), g, origin=WEAPON_ORIGIN, edge_check=False)


# =============================================================================
# 7. ĐẠN, PHÉP, ĐÒN CHÉM (hướng sang phải)
# =============================================================================
def make_projectiles():
    g = "projectiles"
    # Mũi tên
    for name, shaft, head, fl in (("spr_arrow", "wood_light", "steel_light", "red"),
                                  ("spr_bone_arrow", "bone", "outline", "purple")):
        img = new(16, 16)
        rect(img, 2, 7, 12, 7, shaft)
        poly(img, [(11.5, 5), (15.5, 7.5), (11.5, 10)], head)
        for x in (1, 2, 3):
            put(img, x, 6, fl); put(img, x, 8, fl)
        save(name, outline(img), g, edge_check=False)
    # Mũi nỏ ngắn, đầu to
    img = new(16, 16)
    rect(img, 3, 7, 11, 8, "wood")
    poly(img, [(10.5, 4.5), (15.5, 7.5), (10.5, 11)], "steel")
    put(img, 3, 6, "white"); put(img, 3, 9, "white")
    save("spr_bolt", outline(img), g, edge_check=False)
    # Cầu lửa (đuôi lửa phía sau, nhấp nháy)
    def fireball(size, r, f, cols=("fire_dark", "fire", "fire_light")):
        img = new(size, size)
        c = (size - 1) / 2
        for k in range(4):   # đuôi
            disk(img, c - r * (0.6 + k * 0.45), c + [0, 1, 0, -1][(f + k) % 4] * 0.8, r * (0.8 - k * 0.17), cols[0])
        disk(img, c, c, r, cols[1])
        disk(img, c + r * 0.15, c - r * 0.1, r * 0.55, cols[2])
        return outline(img, cols[0] if size < 20 else "outline")
    save("spr_fireball", [fireball(16, 4.0, f) for f in range(4)], g, fps=12, edge_check=False)
    save("spr_dragon_fire", [fireball(24, 6.0, f, ("red_dark", "fire_dark", "fire")) for f in range(4)],
         g, fps=12, edge_check=False)
    # Tia sét (quả cầu điện + tia lởm chởm)
    frames = []
    for f in range(4):
        img = new(16, 16)
        rng = random.Random(f + 3)
        for _ in range(3):
            x, y = 7.5, 7.5
            a = rng.uniform(0, 2 * math.pi)
            for _ in range(3):
                nx, ny = x + math.cos(a) * 2.6, y + math.sin(a) * 2.6
                line(img, x, y, nx, ny, "ice_light")
                x, y = nx, ny
                a += rng.uniform(-1, 1)
        disk(img, 7.5, 7.5, 3.2, "ice")
        disk(img, 7.5, 7.5, 1.8, "white")
        frames.append(outline(img, "magic"))
    save("spr_spark", frames, g, fps=16, edge_check=False)

    # Đòn chém: vệt cung trăng quét dần (5 frame)
    def slash(size, r_out, width, f, n, sweep, cols):
        img = new(size, size)
        c = (size - 1) / 2
        start = -sweep / 2
        end = start + sweep * (f + 1) / n
        tail = end - sweep * 0.65
        for y in range(size):
            for x in range(size):
                d = math.hypot(x - c, y - c)
                a = math.degrees(math.atan2(y - c, x - c))
                if tail <= a <= end and r_out - width <= d < r_out:
                    t = (a - tail) / max(1, end - tail)    # 0 đuôi -> 1 đầu
                    inner = r_out - width * (0.35 + 0.65 * t)
                    if d >= inner:
                        put(img, x, y, cols[0] if t > 0.75 else cols[1] if t > 0.35 else cols[2])
        if f == n - 1:   # frame cuối: vệt mờ dần thành chấm
            pix = img.load()
            for y in range(size):
                for x in range(size):
                    if (x + y) % 2 and pix[x, y][3]:
                        pix[x, y] = (0, 0, 0, 0)
        return img
    save("spr_slash", [slash(48, 22, 9, f, 5, 140, ("white", "steel_light", "ice")) for f in range(5)],
         g, fps=20, edge_check=False)
    save("spr_slash_big", [slash(64, 30, 13, f, 5, 170, ("white", "gold_light", "gold")) for f in range(5)],
         g, fps=18, edge_check=False)
    # Lốc xoáy kiếm: vòng tròn xoay
    frames = []
    for f in range(4):
        img = new(64, 64)
        for y in range(64):
            for x in range(64):
                d = math.hypot(x - 31.5, y - 31.5)
                a = math.atan2(y - 31.5, x - 31.5) + f * math.pi / 4
                v = (math.sin(a * 2) + 1) / 2
                if 22 <= d < 30 and v > 0.3:
                    put(img, x, y, "white" if v > 0.8 else "steel_light" if v > 0.55 else "ice")
        frames.append(img)
    save("spr_spin", frames, g, fps=20, edge_check=False)
    # Vòng băng của phù thủy: vòng lan rộng + mảnh băng
    frames = []
    for f in range(5):
        img = new(128, 128)
        r = 14 + f * 12
        ring(img, 63.5, 63.5, r, 5 if f < 4 else 3, "ice")
        ring(img, 63.5, 63.5, r - 1, 2, "ice_light")
        for k in range(12):
            a = k * math.pi / 6 + f * 0.15
            x, y = 63.5 + math.cos(a) * r, 63.5 + math.sin(a) * r
            poly(img, [(x + math.cos(a) * 5, y + math.sin(a) * 5), (x + math.cos(a + 1.6) * 2.4, y + math.sin(a + 1.6) * 2.4),
                       (x - math.cos(a) * 2, y - math.sin(a) * 2), (x + math.cos(a - 1.6) * 2.4, y + math.sin(a - 1.6) * 2.4)], "ice_light")
        frames.append(outline(img, "ice_dark"))
    save("spr_nova", frames, g, fps=14, edge_check=False)


# =============================================================================
# 8. HIỆU ỨNG
# =============================================================================
def make_fx():
    g = "fx"
    # Tia va chạm
    frames = []
    for f in range(4):
        img = new(16, 16)
        L = [3, 6.4, 5.5, 3][f]
        for k in range(8):
            a = k * math.pi / 4
            l = L if k % 2 == 0 else L * 0.55
            if f < 3 or k % 2 == 0:
                line(img, 7.5 + math.cos(a) * (f * 1.2), 7.5 + math.sin(a) * (f * 1.2),
                     7.5 + math.cos(a) * l, 7.5 + math.sin(a) * l, "white" if f < 2 else "gold_light")
        if f < 2:
            disk(img, 7.5, 7.5, 2 - f * 0.5, "gold_light")
        frames.append(img)
    save("spr_fx_hit", frames, g, fps=20)
    # Khói tan (quái chết)
    frames = []
    rng = random.Random(4)
    puffs = [(rng.uniform(0, 2 * math.pi), rng.uniform(0.2, 1)) for _ in range(7)]
    for f in range(5):
        img = new(32, 32)
        for a, d in puffs:
            r = [3, 4.5, 5, 4, 2.5][f]
            dist = 4 + f * 2.6 * d
            x, y = 15.5 + math.cos(a) * dist, 15.5 + math.sin(a) * dist - f
            disk(img, x, y, r, "stone_light" if f < 3 else "stone")
            disk(img, x - r * 0.3, y - r * 0.3, r * 0.5, "white" if f < 2 else "stone_light")
        frames.append(outline(img, "stone_dark"))
    save("spr_fx_poof", frames, g, fps=14)
    # Vụ nổ
    frames = []
    for f in range(6):
        img = new(48, 48)
        r = [6, 12, 16, 18, 17, 14][f]
        if f < 5:
            disk(img, 23.5, 23.5, r, "fire_dark" if f > 2 else "fire")
            disk(img, 23.5, 22.5, r * 0.7, "fire" if f > 2 else "fire_light")
            if f < 3:
                disk(img, 23.5, 22, r * 0.4, "white")
        if f >= 3:   # khói đen chiếm dần
            for k in range(8):
                a = k * math.pi / 4 + 0.3
                disk(img, 23.5 + math.cos(a) * r * 0.75, 23.5 + math.sin(a) * r * 0.75, 3 + f - 3, "stone")
        frames.append(outline(img))
    save("spr_fx_explosion", frames, g, fps=16)
    # Lấp lánh khi nhặt đồ
    frames = []
    for f in range(4):
        img = new(16, 16)
        L = [2, 5, 6.4, 4][f]
        for k in range(4):
            a = k * math.pi / 2
            line(img, 7.5, 7.5, 7.5 + math.cos(a) * L, 7.5 + math.sin(a) * L, "gold_light")
        put(img, 7.5, 7.5, "white")
        if f >= 2:
            for k in range(4):
                a = k * math.pi / 2 + math.pi / 4
                put(img, 7.5 + math.cos(a) * (L - 1), 7.5 + math.sin(a) * (L - 1), "white")
        frames.append(img)
    save("spr_fx_sparkle", frames, g, fps=14)
    # Hồi máu: dấu cộng xanh bay lên
    frames = []
    for f in range(4):
        img = new(24, 24)
        for k, (x, y0) in enumerate(((6, 18), (16, 20), (11, 14))):
            y = y0 - f * 3 - k
            if 2 < y < 22:
                rect(img, x - 1, y, x + 1, y, "green_light")
                rect(img, x, y - 1, x, y + 1, "green_light")
        frames.append(outline(img, "green_dark"))
    save("spr_fx_heal", frames, g, fps=10)
    # Bụi khi lướt
    frames = []
    for f in range(4):
        img = new(16, 16)
        for k, (x, y) in enumerate(((5, 10), (10, 9), (8, 6))):
            r = [2.5, 3, 2.2, 1.2][f] - k * 0.3
            disk(img, x - f * 0.5, y - f * 0.5, r, "dirt_light")
        frames.append(img)
    save("spr_fx_dust", frames, g, fps=14)
    # Lửa nhỏ (cháy trên dung nham / đuốc)
    frames = []
    for f in range(4):
        img = new(16, 16)
        sway = [0, 1, 0, -1][f]
        poly(img, [(4, 14), (12, 14), (10 + sway, 7), (8 + sway * 2, 1 + f % 2), (6 + sway, 7)], "fire")
        poly(img, [(6, 14), (10, 14), (9 + sway, 9), (8 + sway, 5), (7, 9)], "fire_light")
        frames.append(outline(img, "fire_dark"))
    save("spr_fx_flame", frames, g, fps=12)


# =============================================================================
# 9. VẬT PHẨM NHẶT ĐƯỢC
# =============================================================================
def make_pickups():
    g = "items"
    # Đồng vàng xoay
    frames = []
    for f, w in enumerate((5.5, 3.8, 1.4, 3.8)):
        img = new(16, 16)
        ellipse(img, 7.5, 7.5, w, 5.5, "gold")
        if w > 2:
            ellipse(img, 7.5, 7.5, w * 0.55, 3.2, "gold_dark")
            ellipse(img, 7.5 - w * 0.3, 6, w * 0.25, 1.6, "gold_light")
        frames.append(outline(img))
    save("spr_coin", frames, g, fps=10)
    # Bình máu / bình năng lượng
    for name, c, cl in (("spr_potion_hp", "red", "red_light"), ("spr_potion_mp", "blue", "blue_light")):
        img = new(16, 16)
        disk(img, 7.5, 9.5, 4.4, c)
        rect(img, 6, 3, 9, 5, "ice_light")
        rect(img, 6, 2, 9, 2, "wood")
        disk(img, 6, 8.5, 1.4, cl)
        put(img, 9, 11, "white")
        save(name, outline(img), g)
    # Chìa khóa vàng
    img = new(16, 16)
    ring(img, 5, 7.5, 3.6, 1.6, "gold")
    rect(img, 8, 7, 14, 8, "gold")
    rect(img, 12, 9, 12, 10, "gold"); rect(img, 14, 9, 14, 11, "gold")
    put(img, 4, 6, "gold_light")
    save("spr_key", outline(img), g, edge_check=False)
    # Trái tim nhặt thêm máu tối đa
    img = new(16, 16)
    for p in ((5, 6, 3.2), (10, 6, 3.2)):
        disk(img, p[0] + 0.5, p[1], p[2], "red")
    poly(img, [(2.5, 7), (13.5, 7), (8, 13.5)], "red")
    put(img, 4, 5, "white"); put(img, 5, 4, "red_light")
    save("spr_heart_pickup", outline(img), g)


# =============================================================================
# 10. ĐỒ VẬT TRONG MÀN CHƠI
# =============================================================================
def draw_chest(opened, gold=False):
    img = new(32, 32)
    body, body_d, band = ("purple", "purple_dark", "gold") if gold else ("wood", "wood_dark", "steel")
    ellipse(img, 15.5, 27.5, 11, 2, SHADOW)
    rect(img, 5, 15, 26, 27, body)
    rect(img, 5, 24, 26, 27, body_d)
    for x in (5, 25):
        rect(img, x, 15, x + 1, 27, band)
    if opened:
        rect(img, 5, 8, 26, 14, body_d)              # nắp mở ngửa ra sau
        rect(img, 7, 12, 24, 15, "outline")
        rect(img, 8, 13, 23, 15, "gold_light" if gold else "gold")
        for k in range(4):
            put(img, 9 + k * 4, 12, "white")
    else:
        rect(img, 5, 10, 26, 15, body)
        rect(img, 5, 10, 26, 11, "wood_light" if not gold else "purple_light")
        rect(img, 5, 15, 26, 15, band)
        rect(img, 14, 14, 17, 18, "gold")
        put(img, 15, 16, "outline"); put(img, 16, 16, "outline")
    return outline(img)


def make_world_objects():
    g = "world"
    save("spr_chest", [draw_chest(False), draw_chest(True)], g, fps=0, mask=(5, 10, 26, 27))
    save("spr_chest_gold", [draw_chest(False, True), draw_chest(True, True)], g, fps=0, mask=(5, 10, 26, 27))
    # Cửa gỗ có khóa (chặn lối, cần chìa)
    img = new(32, 32)
    rect(img, 0, 0, 31, 31, "stone_dark")
    rect(img, 4, 3, 27, 31, "wood")
    for x in (9, 15, 21):
        rect(img, x, 3, x, 31, "wood_dark")
    for y in (8, 22):
        rect(img, 4, y, 27, y + 1, "steel_dark")
    rect(img, 13, 13, 18, 18, "gold")
    rect(img, 15, 15, 16, 17, "outline")
    rect(img, 4, 3, 27, 3, "wood_light")
    save("spr_door", img, g, origin=(0, 0), edge_check=False)
    # Cổng dịch chuyển sang màn sau (xoáy phép thuật)
    frames = []
    for f in range(6):
        img = new(48, 48)
        ellipse(img, 23.5, 42, 14, 3.5, SHADOW)
        for y in range(48):
            for x in range(48):
                dx, dy = (x - 23.5) / 15, (y - 22.5) / 20
                d = math.hypot(dx, dy)
                if d < 1:
                    a = math.atan2(dy, dx)
                    v = math.sin(3 * a + d * 7 - f * math.pi / 3)
                    cc = "magic_light" if v > 0.6 else "magic" if v > -0.2 else "magic_dark"
                    if d < 0.25:
                        cc = "white"
                    put(img, x, y, cc)
        frames.append(outline(img, "purple_dark"))
    save("spr_portal", frames, g, fps=10, mask=(10, 6, 37, 40))
    # Bàn dịch chuyển (một cặp nối nhau)
    frames = []
    for f in range(4):
        img = new(32, 32)
        ellipse(img, 15.5, 16, 13, 9, "stone")
        ellipse(img, 15.5, 15, 12, 8, "stone_light")
        ellipse(img, 15.5, 15, 8.5, 5.5, "stone_dark")
        for k in range(6):
            a = k * math.pi / 3 + f * math.pi / 12
            put(img, 15.5 + math.cos(a) * 10, 15 + math.sin(a) * 6.6, "ice_light" if (k + f) % 2 else "ice")
        ellipse(img, 15.5, 15, 5.5 + (f % 2), 3.5 + (f % 2) * 0.6, "ice")
        ellipse(img, 15.5, 15, 3, 2, "ice_light")
        frames.append(outline(img))
    save("spr_teleport", frames, g, fps=8)
    # Bẫy chông: 0 ẩn, 1 nhú, 2 dựng hết, 3 nhú
    frames = []
    for f in range(4):
        img = new(32, 32)
        rect(img, 2, 2, 29, 29, "stone_dark")
        rect(img, 3, 3, 28, 28, "stone")
        h = [0, 3, 7, 3][f]
        for gx in range(3):
            for gy in range(3):
                x, y = 7.5 + gx * 8, 9 + gy * 8
                ellipse(img, x, y + 1.5, 2, 1.2, "outline")
                if h:
                    poly(img, [(x - 1.8, y + 1.5), (x + 1.8, y + 1.5), (x, y + 1.5 - h)], "steel_light")
                    line(img, x + 0.6, y + 1, x + 0.6, y + 1.5 - h * 0.6, "steel")
        frames.append(outline(img))
    save("spr_spikes", frames, g, fps=0, mask=(4, 4, 27, 27), edge_check=False)
    # Dung nham (lặp liền, bong bóng sủi)
    frames = []
    for f in range(4):
        img = Image.new("RGBA", (32, 32), col("lava"))
        for y in range(32):
            for x in range(32):
                v = math.sin((x + f * 8) * 2 * math.pi / 32) + math.sin((y * 2 + x) * 2 * math.pi / 32 + f * math.pi / 2)
                if v > 1.1:
                    put(img, x, y, "lava_light")
                elif v < -1.2:
                    put(img, x, y, "lava_dark")
        bx, by = [(8, 10), (22, 20), (14, 26), (26, 6)][f]
        ring(img, bx, by, 2.6, 1.2, "lava_light")
        frames.append(img)
    save("spr_lava", frames, g, fps=4, origin=(0, 0), edge_check=False)
    # Đuốc gắn tường
    frames = []
    for f in range(4):
        img = new(16, 32)
        rect(img, 7, 16, 8, 28, "wood")
        rect(img, 5, 15, 10, 17, "steel_dark")
        sway = [0, 1, 0, -1][f]
        poly(img, [(4, 15), (11, 15), (10 + sway, 9), (8 + sway * 2, 2 + f % 2), (5 + sway, 9)], "fire")
        poly(img, [(6, 15), (9, 15), (9 + sway, 11), (8 + sway, 7), (6, 11)], "fire_light")
        frames.append(outline(img))
    save("spr_torch", frames, g, fps=10)
    # Biển chỉ dẫn
    img = new(32, 32)
    ellipse(img, 15.5, 28, 6, 1.6, SHADOW)
    rect(img, 14, 16, 17, 28, "wood_dark")
    rect(img, 5, 6, 26, 17, "wood")
    rect(img, 5, 6, 26, 7, "wood_light")
    for y in (10, 13):
        rect(img, 8, y, 23 - (y % 3) * 2, y, "wood_dark")
    save("spr_sign", outline(img), g, mask=(5, 6, 26, 28))
    # Mặt nạ va chạm của tường (vô hình trong game)
    img = Image.new("RGBA", (32, 32), col("red"))
    save("spr_wall_mask", img, g, origin=(0, 0), mask=(0, 0, 31, 31), edge_check=False)


# =============================================================================
# 11. GIAO DIỆN
# =============================================================================
HEART = [
    "................",
    "..oooo....oooo..",
    ".orrrro..orrrro.",
    "orwwrrroorrrrrro",
    "orwrrrrrrrrrrrro",
    "orrrrrrrrrrrrrro",
    "orrrrrrrrrrrrRro",
    ".orrrrrrrrrrRro.",
    "..orrrrrrrrRro..",
    "...orrrrrrRro...",
    "....orrrrRro....",
    ".....orrRro.....",
    "......orro......",
    ".......oo.......",
    "................",
    "................",
]


def from_map(rows, colors):
    img = new(len(rows[0]), len(rows))
    for y, row in enumerate(rows):
        for x, ch in enumerate(row):
            if ch != ".":
                put(img, x, y, colors[ch])
    return img


def make_ui():
    g = "ui"
    full = from_map(HEART, {"o": "outline", "r": "red", "R": "red_dark", "w": "white"})
    empty = from_map(HEART, {"o": "outline", "r": "stone_dark", "R": "stone_dark", "w": "stone"})
    save("spr_ui_heart", [full, empty], g, fps=0, origin=(0, 0), edge_check=False)
    # Thanh năng lượng (mana) 64x8 và thanh máu trùm 200x10: nền + phần đổ đầy cùng cỡ
    for name, w, h, fill_cols in (("mana", 64, 8, ("ice_light", "blue_light", "blue")),
                                  ("boss", 200, 10, ("red_light", "red", "red_dark"))):
        bg = new(w, h)
        rect(bg, 1, 0, w - 2, h - 1, "outline")
        rect(bg, 0, 1, w - 1, h - 2, "outline")
        rect(bg, 2, 2, w - 3, h - 3, "stone_dark")
        save(f"spr_ui_{name}_bg", bg, g, origin=(0, 0), edge_check=False)
        fill = new(w, h)
        for y in range(2, h - 2):
            c = fill_cols[0] if y == 2 else fill_cols[2] if y == h - 3 else fill_cols[1]
            rect(fill, 2, y, w - 3, y, c)
        save(f"spr_ui_{name}_fill", fill, g, origin=(0, 0), edge_check=False)
    # Con trỏ ngắm
    img = new(16, 16)
    ring(img, 7.5, 7.5, 6, 1.4, "white")
    for a, b in (((7, 0), (8, 3)), ((7, 12), (8, 15)), ((0, 7), (3, 8)), ((12, 7), (15, 8))):
        rect(img, a[0], a[1], b[0], b[1], "white")
    put(img, 7, 7, "red"); put(img, 8, 8, "red"); put(img, 7, 8, "red"); put(img, 8, 7, "red")
    save("spr_cursor", outline(img), g, edge_check=False)
    # Ô kỹ năng (khung icon 24x24)
    img = new(24, 24)
    rect(img, 1, 0, 22, 23, "outline")
    rect(img, 0, 1, 23, 22, "outline")
    rect(img, 2, 2, 21, 21, "stone")
    rect(img, 2, 2, 21, 2, "stone_light")
    rect(img, 3, 3, 20, 20, "stone_dark")
    save("spr_ui_slot", img, g, origin=(0, 0), edge_check=False)
    # Biểu tượng kỹ năng đặc biệt cho 3 nhân vật
    icons = []
    img = new(16, 16)   # lốc xoáy kiếm: vòng cung có mũi tên + thanh kiếm
    for k in range(22):
        a = math.radians(-60 + k * 13)
        put(img, 7.5 + math.cos(a) * 6, 7.5 + math.sin(a) * 6, "steel_light")
        put(img, 7.5 + math.cos(a) * 5, 7.5 + math.sin(a) * 5, "ice")
    poly(img, [(11, 0.5), (15, 3.5), (10.5, 5)], "white")
    line(img, 5, 10, 10, 5, "white")
    put(img, 4, 11, "gold"); put(img, 5, 11, "gold"); put(img, 4, 10, "gold")
    icons.append(outline(img))
    img = new(16, 16)   # mưa tên
    for x in (3, 7, 11):
        line(img, x, 2, x + 2, 12, "wood_light")
        put(img, x + 2, 13, "steel_light")
    icons.append(outline(img))
    img = new(16, 16)   # vòng băng
    for k in range(6):
        a = k * math.pi / 3
        line(img, 7.5, 7.5, 7.5 + math.cos(a) * 6, 7.5 + math.sin(a) * 6, "ice_light")
    disk(img, 7.5, 7.5, 2, "white")
    icons.append(outline(img, "ice_dark"))
    save("spr_ui_skill", icons, g, fps=0, edge_check=False)


# =============================================================================
# 12. TILESET 32x32 (8 cột). Ô số 0 luôn trống theo quy ước của GameMaker.
# =============================================================================
TS = 32


def tile_canvas(rows):
    return new(8 * TS, rows * TS)


def tex(img, x0, y0, base, specks, seed, wrap_draw=True):
    """Tô một ô bằng màu nền + các chấm/vệt hoạ tiết (lặp liền mép)."""
    rect(img, x0, y0, x0 + TS - 1, y0 + TS - 1, base)
    rng = random.Random(seed)
    for colr, count, size in specks:
        for _ in range(count):
            x, y = rng.randrange(TS), rng.randrange(TS)
            for k in range(size):
                put(img, x0 + (x + k) % TS, y0 + y, colr)


def canopy(img, x0, y0, rows=TS):
    """Tán lá cây dày (dùng chung cho ô 'ngọn' và ô 'mặt trước' để nối liền)."""
    rect(img, x0, y0, x0 + TS - 1, y0 + rows - 1, "green_dark")
    rng = random.Random(77)
    blobs = [(rng.randrange(TS), rng.randrange(TS), rng.uniform(4, 6.5)) for _ in range(9)]
    for bx, by, r in blobs:
        for ox in (-TS, 0, TS):
            for oy in (-TS, 0, TS):
                for y in range(rows):
                    for x in range(TS):
                        dx, dy = x - (bx + ox), y - (by + oy)
                        d = math.hypot(dx, dy)
                        if d < r:
                            c = "green_light" if (dx < -r * 0.2 and dy < -r * 0.2 and d > r * 0.45) else "green"
                            if d > r - 1:
                                c = "outline" if dy > 0 else c
                            put(img, x0 + x, y0 + y, c)


def make_tilesets():
    # ---------------- ts_ground: nền đi được
    img = tile_canvas(4)
    T = lambda i: ((i % 8) * TS, (i // 8) * TS)
    grass = [("grass_dark", 26, 1), ("grass_light", 14, 1)]
    for i, extra in ((1, []), (2, [("grass_dark", 10, 2)]), (3, [("gold", 3, 1), ("red_light", 3, 1), ("white", 3, 1)]),
                     (4, [("stone_light", 4, 2)]), (7, [("grass_dark", 60, 1)])):
        x0, y0 = T(i)
        tex(img, x0, y0, "grass", grass + extra, seed=i)
    for i in (5, 6):   # đường đất
        x0, y0 = T(i)
        tex(img, x0, y0, "dirt", [("dirt_dark", 22, 1), ("dirt_light", 16, 1), ("stone_light", 3 if i == 6 else 0, 1)], seed=i)
    # sàn hầm ngục: phiến đá
    for i, kind in ((8, 0), (9, 1), (10, 2), (11, 3), (12, 4), (13, 0), (14, 1), (15, 5)):
        x0, y0 = T(i)
        rect(img, x0, y0, x0 + 31, y0 + 31, "stone")
        for y in (0, 16):
            rect(img, x0, y0 + y, x0 + 31, y0 + y, "stone_dark")
        for (x, y) in ((0, 1), (16, 1), (8, 17), (24, 17)):
            rect(img, x0 + x, y0 + y, x0 + x, y0 + y + 14, "stone_dark")
        for (x, y) in ((1, 1), (17, 1), (9, 17), (25, 17)):
            rect(img, x0 + x, y0 + y, x0 + x + 5, y0 + y, "stone_light")
        rng = random.Random(i)
        if kind == 2:   # nứt
            line(img, x0 + 5, y0 + 4, x0 + 12, y0 + 12, "stone_dark"); line(img, x0 + 12, y0 + 12, x0 + 10, y0 + 20, "stone_dark")
        if kind == 3:   # rêu
            for _ in range(5):
                disk(img, x0 + rng.uniform(4, 28), y0 + rng.uniform(4, 28), rng.uniform(1.5, 3), "green_dark")
        if kind == 4:   # xương vụn
            line(img, x0 + 8, y0 + 22, x0 + 16, y0 + 19, "bone"); disk(img, x0 + 21, y0 + 9, 2.4, "bone")
            put(img, x0 + 20, y0 + 9, "outline"); put(img, x0 + 22, y0 + 9, "outline")
        if kind == 5:   # lưới cống
            rect(img, x0 + 8, y0 + 8, x0 + 23, y0 + 23, "outline")
            for k in range(10, 23, 3):
                rect(img, x0 + k, y0 + 9, x0 + k, y0 + 22, "stone_dark")
        if kind == 1:
            for _ in range(8):
                put(img, x0 + rng.randrange(32), y0 + rng.randrange(32), "stone_light")
    # sàn hang rồng: đá bazan tối
    for i, kind in ((16, 0), (17, 1), (18, 2), (19, 3), (20, 4), (21, 0), (22, 1), (23, 0)):
        x0, y0 = T(i)
        tex(img, x0, y0, "rock", [("rock_dark", 30, 2), ("rock_light", 14, 1)], seed=i + 40)
        rng = random.Random(i)
        if kind == 2:   # than hồng
            for _ in range(6):
                put(img, x0 + rng.randrange(32), y0 + rng.randrange(32), "lava")
        if kind == 3:   # sọ
            disk(img, x0 + 15, y0 + 15, 4, "bone"); rect(img, x0 + 13, y0 + 18, x0 + 17, y0 + 19, "bone")
            put(img, x0 + 13, y0 + 15, "outline"); put(img, x0 + 17, y0 + 15, "outline")
        if kind == 4:   # khe nứt phát sáng
            for k in range(4):
                line(img, x0 + 4 + k * 6, y0 + 6 + (k % 2) * 8, x0 + 10 + k * 6, y0 + 14 + (k % 2) * 6, "lava_dark")
    # hàng 4: cầu gỗ + cát
    for i in (24, 25):
        x0, y0 = T(i)
        rect(img, x0, y0, x0 + 31, y0 + 31, "wood")
        for y in range(0, 32, 8):
            rect(img, x0, y0 + y, x0 + 31, y0 + y, "wood_dark")
            rect(img, x0, y0 + y + 1, x0 + 31, y0 + y + 1, "wood_light")
    for i in range(26, 32):
        x0, y0 = T(i)
        tex(img, x0, y0, "grass", grass, seed=i)
    save("spr_ts_ground", img, "tiles", origin=(0, 0), edge_check=False, max_colors=40)

    # ---------------- ts_wall: vật cản (ngọn/mặt trước)
    img = tile_canvas(2)
    # 1 ngọn cây, 2 mặt trước tán cây (thân cây trên nền cỏ)
    canopy(img, *T(1))
    x0, y0 = T(2)
    tex(img, x0, y0, "grass", grass, seed=2)
    rect(img, x0, y0 + 20, x0 + 31, y0 + 25, "grass_dark")      # bóng tán
    for tx in (5, 20):
        ellipse(img, x0 + tx + 3.5, y0 + 28, 6, 2, "grass_dark")
        rect(img, x0 + tx, y0 + 16, x0 + tx + 6, y0 + 28, "outline")
        rect(img, x0 + tx + 1, y0 + 16, x0 + tx + 5, y0 + 27, "wood")
        rect(img, x0 + tx + 4, y0 + 16, x0 + tx + 5, y0 + 27, "wood_dark")
        rect(img, x0 + tx + 2, y0 + 19, x0 + tx + 2, y0 + 24, "wood_light")
        put(img, x0 + tx - 1, y0 + 28, "outline"); put(img, x0 + tx + 7, y0 + 28, "outline")
    sub = new(TS, TS)
    canopy(sub, 0, 0, rows=22)
    for x in range(TS):   # mép dưới tán lượn sóng
        cut = 18 + rnd(2.0 * math.sin(x * 2 * math.pi / 16) + 1.5)
        for y in range(cut, 22):
            sub.putpixel((x, y), (0, 0, 0, 0))
        sub.putpixel((x, min(21, cut)), C("outline"))
    img.alpha_composite(sub, (x0, y0))
    # 3 mặt nước, 4 mép nước (bờ phía dưới)
    for i in (3, 4):
        x0, y0 = T(i)
        rect(img, x0, y0, x0 + 31, y0 + 31, "water")
        for (wx, wy) in ((3, 4), (18, 9), (9, 18), (24, 23), (14, 28)):
            rect(img, x0 + wx, y0 + wy, x0 + wx + 4, y0 + wy, "water_light")
            rect(img, x0 + wx + 1, y0 + wy + 1, x0 + wx + 3, y0 + wy + 1, "water_dark")
        if i == 4:
            rect(img, x0, y0 + 24, x0 + 31, y0 + 31, "grass")
            rect(img, x0, y0 + 23, x0 + 31, y0 + 23, "outline")
            rect(img, x0, y0 + 24, x0 + 31, y0 + 25, "dirt")
            rect(img, x0, y0 + 26, x0 + 31, y0 + 26, "grass_dark")
    # 5 đá tảng (ngọn), 6 đá tảng (mặt trước) ở rừng
    for i, front in ((5, False), (6, True)):
        x0, y0 = T(i)
        tex(img, x0, y0, "stone_light", [("stone", 30, 3), ("white", 6, 1)], seed=i)
        if front:
            rect(img, x0, y0 + 14, x0 + 31, y0 + 31, "stone")
            rect(img, x0, y0 + 14, x0 + 31, y0 + 14, "stone_light")
            for x in (5, 17, 27):
                rect(img, x0 + x, y0 + 16, x0 + x, y0 + 28, "stone_dark")
            rect(img, x0, y0 + 29, x0 + 31, y0 + 31, "stone_dark")
    # 8 tường hầm (ngọn), 9-11 tường hầm (mặt trước: gạch, cờ, sọ)
    x0, y0 = T(8)
    tex(img, x0, y0, "stone_dark", [("stone", 18, 3), ("outline", 10, 2)], seed=8)
    for i, deco in ((9, None), (10, "banner"), (11, "skull")):
        x0, y0 = T(i)
        rect(img, x0, y0, x0 + 31, y0 + 31, "stone")
        for r, y in enumerate(range(0, 32, 8)):
            rect(img, x0, y0 + y, x0 + 31, y0 + y, "stone_dark")
            rect(img, x0, y0 + y + 1, x0 + 31, y0 + y + 1, "stone_light")
            off = 0 if r % 2 == 0 else 8
            for x in range(off, 32, 16):
                rect(img, x0 + x, y0 + y + 1, x0 + x, y0 + y + 7, "stone_dark")
        rect(img, x0, y0 + 29, x0 + 31, y0 + 31, "outline")
        if deco == "banner":
            rect(img, x0 + 10, y0 + 2, x0 + 21, y0 + 22, "red")
            rect(img, x0 + 10, y0 + 2, x0 + 21, y0 + 3, "gold")
            poly(img, [(x0 + 10, y0 + 22), (x0 + 22, y0 + 22), (x0 + 15.5, y0 + 27)], "red")
            rect(img, x0 + 14, y0 + 9, x0 + 17, y0 + 14, "gold")
        if deco == "skull":
            disk(img, x0 + 15.5, y0 + 15, 4.4, "bone")
            rect(img, x0 + 13, y0 + 18, x0 + 18, y0 + 20, "bone")
            put(img, x0 + 13, y0 + 15, "outline"); put(img, x0 + 18, y0 + 15, "outline")
            put(img, x0 + 14, y0 + 15, "outline"); put(img, x0 + 17, y0 + 15, "outline")
    # 12 đá hang (ngọn), 13-14 đá hang (mặt trước, có pha lê)
    x0, y0 = T(12)
    tex(img, x0, y0, "rock_dark", [("rock", 26, 3), ("outline", 10, 2)], seed=12)
    for i, crystal in ((13, False), (14, True)):
        x0, y0 = T(i)
        tex(img, x0, y0, "rock", [("rock_light", 20, 2), ("rock_dark", 16, 2)], seed=i)
        for x in (4, 13, 25):
            line(img, x0 + x, y0 + 2, x0 + x + 2, y0 + 26, "rock_dark")
        rect(img, x0, y0 + 0, x0 + 31, y0 + 1, "rock_light")
        rect(img, x0, y0 + 28, x0 + 31, y0 + 31, "outline")
        if crystal:
            for (cx, cy, h) in ((10, 22, 10), (17, 24, 14), (23, 23, 8)):
                poly(img, [(x0 + cx - 2.5, y0 + cy), (x0 + cx + 2.5, y0 + cy), (x0 + cx, y0 + cy - h)], "magic")
                line(img, x0 + cx - 0.5, y0 + cy - 1, x0 + cx - 0.5, y0 + cy - h + 2, "magic_light")
    save("spr_ts_wall", img, "tiles", origin=(0, 0), edge_check=False, max_colors=40)


# =============================================================================
# 13. TRANG XEM TRƯỚC
# =============================================================================
def make_preview(scale=3):
    try:
        font = ImageFont.load_default(size=14)
    except TypeError:
        font = ImageFont.load_default()
    pad, gap, label_h, max_w = 14, 4, 20, 2400
    blocks, x, y, row_h = [], pad, pad, 0
    for s in SPRITES:
        k = scale if s["w"] <= 96 else 2
        bw = s["n"] * s["w"] * k + (s["n"] - 1) * gap
        bh = s["h"] * k + label_h
        if x + bw > max_w and x > pad:
            x, y, row_h = pad, y + row_h + pad, 0
        blocks.append((s, x, y, k))
        x += max(bw, 200) + pad * 2
        row_h = max(row_h, bh)
    sheet = Image.new("RGB", (max_w + pad, y + row_h + pad), (48, 50, 60))
    draw = ImageDraw.Draw(sheet)
    for s, bx, by, k in blocks:
        draw.text((bx, by), f"{s['name']} {s['w']}x{s['h']}" + (f" x{s['n']}" if s["n"] > 1 else ""),
                  fill=(235, 235, 235), font=font)
        for i, fr in enumerate(s["frames"]):
            fx = bx + i * (s["w"] * k + gap)
            fw, fh = s["w"] * k, s["h"] * k
            bg = Image.new("RGBA", (fw, fh))
            bd = ImageDraw.Draw(bg)
            cell = 8
            for cy in range(0, fh, cell):
                for cx in range(0, fw, cell):
                    v = 150 if (cx // cell + cy // cell) % 2 else 126
                    bd.rectangle([cx, cy, cx + cell - 1, cy + cell - 1], fill=(v, v, v, 255))
            bg.alpha_composite(fr.resize((fw, fh), Image.NEAREST))
            sheet.paste(bg.convert("RGB"), (fx, by + label_h))
    sheet.save(os.path.join(OUT_DIR, "preview_sheet.png"))
    return sheet.size


# =============================================================================
# 14. CHƯƠNG TRÌNH CHÍNH
# =============================================================================
def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    for f in os.listdir(OUT_DIR):
        if f.endswith(".png"):
            os.remove(os.path.join(OUT_DIR, f))
    make_heroes()
    make_enemies()
    make_weapons()
    make_projectiles()
    make_fx()
    make_pickups()
    make_world_objects()
    make_ui()
    make_tilesets()
    pw, ph = make_preview()

    meta = [{k: s[k] for k in ("name", "file", "w", "h", "n", "fps", "origin", "mask", "group")}
            for s in SPRITES]
    with open(os.path.join(OUT_DIR, "sprites.json"), "w", encoding="utf-8") as fp:
        json.dump(meta, fp, ensure_ascii=False, indent=1)

    print(f"Đã tạo {len(SPRITES)} sprite trong {OUT_DIR}")
    n_warn = 0
    for s in SPRITES:
        print(f"  {s['file']:34s} {s['w'] * s['n']:>4d}x{s['h']:<4d} {s['n']:>2d} frame {s['w']}x{s['h']}")
        for w in s["warnings"]:
            print(f"      ! {w}")
            n_warn += 1
    print(f"  {'preview_sheet.png':34s} {pw}x{ph}")
    print("Không có cảnh báo." if n_warn == 0 else f"Có {n_warn} cảnh báo (xem dấu !).")


if __name__ == "__main__":
    main()
