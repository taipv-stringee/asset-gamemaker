#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
generate_assets.py — Asset THAM KHẢO (thử phong cách) cho game chiến thuật theo lượt
lấy cảm hứng từ Quang Trung, lối chơi kiểu Ancient Empires 2, chạy trên điện thoại.

Chạy:
    pip install pillow
    python generate_assets.py

Kết quả (thư mục assets/):
    unit_<phe>_<loại>_strip2.png   lính 24x24, 2 frame đứng thở (nhìn sang phải)
    tile_<loại>.png                ô địa hình 24x24 (nước có 2 frame)
    ui_*.png                       con trỏ, ô tô sáng di chuyển / tấn công, đồng tiền
    preview_sheet.png              xem nhanh mọi sprite (phóng to x4, có nhãn)
    mockup_phone.png               màn hình chơi dọc 9:16 trên điện thoại (x3)

Quy ước:
    - Ô lưới 24x24 giống Ancient Empires 2; màn hình gốc 216x384 (bản đồ 9 x 12 ô + thanh trên + bảng dưới), phóng x3 = 648x1152.
    - Lính vẽ HƯỚNG SANG PHẢI; phe địch lật ngang khi đặt lên bản đồ.
    - Màu phe chỉ nằm ở 3 màu team_dark / team / team_light -> thêm phe mới chỉ cần thêm bảng màu.
    - Không anti-alias: chỉ đặt từng điểm ảnh, viền tối 1px tự động (outline()).
"""

import os
import random
from collections import deque

from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
OUT_DIR = os.path.join(HERE, "assets")
FONT_PATH = os.path.join(HERE, "fonts", "VT323-Regular.ttf")
T = 24  # kích thước ô lưới

# =============================================================================
# 1. BẢNG MÀU
# =============================================================================
C = {
    "outline":     (28, 20, 22),
    "skin":        (236, 186, 140),
    "skin_dark":   (190, 132, 96),
    "hair":        (34, 26, 28),
    "pants":       (60, 48, 44),
    "pants_dark":  (40, 32, 30),
    "shoe":        (30, 24, 24),
    "white":       (246, 240, 224),
    # Kim loại
    "steel_dark":  (92, 98, 112),
    "steel":       (160, 168, 180),
    "steel_light": (222, 228, 236),
    "bronze_dark": (110, 70, 30),
    "bronze":      (172, 118, 50),
    "bronze_light": (228, 178, 92),
    "gold_dark":   (168, 112, 24),
    "gold":        (236, 186, 52),
    "gold_light":  (255, 232, 140),
    # Gỗ, rơm, tre
    "wood_dark":   (78, 48, 28),
    "wood":        (128, 82, 46),
    "wood_light":  (178, 124, 74),
    "straw_dark":  (150, 112, 52),
    "straw":       (206, 168, 88),
    "straw_light": (240, 212, 136),
    "bamboo_dark": (52, 96, 40),
    "bamboo":      (96, 150, 58),
    "bamboo_light": (156, 198, 92),
    # Voi
    "ele_dark":    (82, 78, 92),
    "ele":         (126, 122, 136),
    "ele_light":   (168, 164, 176),
    # Lửa
    "fire_dark":   (200, 56, 20),
    "fire":        (248, 140, 30),
    "fire_light":  (255, 226, 100),
    "smoke":       (190, 186, 180),
    # Địa hình
    "grass_dark":  (58, 110, 48),
    "grass":       (88, 148, 62),
    "grass_light": (136, 184, 80),
    "rice_dark":   (70, 136, 40),
    "rice":        (122, 182, 56),
    "rice_light":  (186, 220, 96),
    "paddy_water": (104, 156, 150),
    "dirt_dark":   (122, 86, 54),
    "dirt":        (166, 124, 78),
    "dirt_light":  (206, 166, 110),
    "rock_dark":   (70, 72, 82),
    "rock":        (116, 118, 126),
    "rock_light":  (166, 168, 172),
    "water_dark":  (34, 82, 140),
    "water":       (54, 122, 188),
    "water_light": (128, 188, 230),
    "blossom_dark": (206, 92, 134),
    "blossom":     (244, 150, 180),
    "blossom_light": (255, 214, 226),
    "wall_dark":   (110, 92, 72),
    "wall":        (164, 140, 108),
    "wall_light":  (206, 186, 150),
    "roof_dark":   (96, 40, 30),
    "roof":        (150, 64, 42),
    "roof_light":  (196, 98, 64),
    # Sơn mài (khung UI)
    "lacquer_dark": (40, 14, 14),
    "lacquer":     (92, 24, 22),
    "lacquer_light": (140, 40, 32),
}

# Màu phe. "neutral" dùng cho làng / thành chưa ai chiếm.
TEAMS = {
    "tayson":  {"team_dark": (128, 20, 28), "team": (204, 42, 44), "team_light": (246, 104, 84)},
    "thanh":   {"team_dark": (32, 54, 124), "team": (58, 96, 184), "team_light": (116, 156, 226)},
    "neutral": {"team_dark": (110, 106, 100), "team": (176, 172, 162), "team_light": (226, 222, 212)},
}


def rgba(c, a=255):
    return (c[0], c[1], c[2], a)


# =============================================================================
# 2. HÀM VẼ CƠ BẢN
# =============================================================================
class Pen:
    """Bút vẽ điểm ảnh trên một ảnh; màu tra theo tên trong C hoặc bảng màu phe."""

    def __init__(self, img, team="neutral"):
        self.img = img
        self.pal = dict(C)
        self.pal.update(TEAMS[team])

    def c(self, name):
        return rgba(self.pal[name]) if isinstance(name, str) else name

    def px(self, x, y, name):
        if 0 <= x < self.img.width and 0 <= y < self.img.height:
            self.img.putpixel((x, y), self.c(name))

    def rect(self, x0, y0, x1, y1, name):
        """Hình chữ nhật đặc, toạ độ bao gồm cả hai đầu."""
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                self.px(x, y, name)

    def hline(self, x0, x1, y, name):
        self.rect(x0, y, x1, y, name)

    def vline(self, x, y0, y1, name):
        self.rect(x, y0, x, y1, name)

    def ellipse(self, cx, cy, rx, ry, name):
        for y in range(cy - ry, cy + ry + 1):
            for x in range(cx - rx, cx + rx + 1):
                dx = (x - cx) / (rx + 0.5)
                dy = (y - cy) / (ry + 0.5)
                if dx * dx + dy * dy <= 1.0:
                    self.px(x, y, name)

    def line(self, x0, y0, x1, y1, name):
        n = max(abs(x1 - x0), abs(y1 - y0), 1)
        for i in range(n + 1):
            self.px(round(x0 + (x1 - x0) * i / n), round(y0 + (y1 - y0) * i / n), name)


def new(w=T, h=T, fill=None):
    return Image.new("RGBA", (w, h), rgba(fill) if fill else (0, 0, 0, 0))


def outline(img, color=C["outline"]):
    """Thêm viền 1px quanh phần đã vẽ (chỉ viền ngoài, 4 hướng)."""
    src = img.copy()
    w, h = img.size
    for y in range(h):
        for x in range(w):
            if src.getpixel((x, y))[3] != 0:
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if 0 <= nx < w and 0 <= ny < h and src.getpixel((nx, ny))[3] == 255:
                    img.putpixel((x, y), rgba(color))
                    break
    return img


def with_shadow(sprite, cx=12, cy=21, rx=7):
    """Đặt bóng đổ hình bầu dục dưới chân rồi chồng sprite lên."""
    base = new(sprite.width, sprite.height)
    p = Pen(base)
    p.ellipse(cx, cy, rx, 1, (0, 0, 0, 90))
    base.alpha_composite(sprite)
    return base


def strip(frames):
    out = new(T * len(frames), T)
    for i, f in enumerate(frames):
        out.alpha_composite(f, (i * T, 0))
    return out


# =============================================================================
# 3. LÍNH
# =============================================================================
def humanoid(p, bob, hat, cape=False):
    """Thân người nhìn sang phải. bob = 0/1: frame thở (thân hạ 1px, chân đứng yên)."""
    y = bob
    if cape:
        p.rect(6, 10 + y, 8, 18, "team_dark")
        p.px(5, 17, "team_dark")
    # Chân + giày
    p.rect(9, 17, 10, 20, "pants_dark")
    p.rect(12, 17, 13, 20, "pants")
    p.hline(9, 11, 21, "shoe")
    p.hline(12, 14, 21, "shoe")
    # Áo
    p.rect(8, 10 + y, 14, 16 + y, "team")
    p.vline(8, 10 + y, 16 + y, "team_dark")
    p.vline(13, 11 + y, 13 + y, "team_light")
    p.hline(8, 14, 14 + y, "wood_dark")          # thắt lưng
    # Đầu
    p.rect(9, 4 + y, 14, 9 + y, "skin")
    p.rect(9, 4 + y, 10, 8 + y, "hair")
    p.vline(14, 8 + y, 9 + y, "skin_dark")
    p.px(13, 6 + y, "outline")                    # mắt
    draw_hat(p, hat, y)


def draw_hat(p, hat, y):
    if hat == "non":          # nón lá chóp (lính Tây Sơn)
        p.hline(11, 12, 1 + y, "straw_light")
        p.hline(10, 13, 2 + y, "straw")
        p.hline(8, 15, 3 + y, "straw")
        p.hline(7, 16, 4 + y, "straw_dark")
        p.px(12, 2 + y, "straw_light")
        p.hline(9, 14, 5 + y, "team")              # quai / khăn đỏ
    elif hat == "khan":       # khăn vàng chít đầu (Quang Trung)
        p.rect(9, 2 + y, 14, 4 + y, "gold")
        p.hline(9, 14, 2 + y, "gold_light")
        p.rect(7, 4 + y, 8, 6 + y, "gold_dark")    # đuôi khăn bay ra sau
        p.px(6, 6 + y, "gold_dark")
        p.px(12, 1 + y, "team")                    # hạt ngọc đỏ
    elif hat == "mu":         # mũ tròn có chỏm đỏ + bím tóc (lính Thanh)
        p.rect(9, 2 + y, 14, 3 + y, "pants_dark")
        p.hline(8, 15, 4 + y, "outline")
        p.hline(11, 12, 1 + y, "team")
        p.px(11, 0 + y, "team_light")
        p.rect(7, 8 + y, 7, 13 + y, "hair")        # bím tóc
    elif hat == "mu_quan":    # mũ quan có lông công (tướng Thanh)
        p.rect(9, 1 + y, 14, 3 + y, "pants_dark")
        p.hline(8, 15, 4 + y, "gold_dark")
        p.px(12, 0 + y, "gold")
        p.hline(4, 8, 2 + y, "bamboo")             # lông công
        p.hline(3, 6, 3 + y, "bamboo_dark")
        p.px(4, 2 + y, (60, 110, 200))
        p.rect(7, 8 + y, 7, 13 + y, "hair")


def unit_spear(team, hat, bob):
    img = new()
    p = Pen(img, team)
    humanoid(p, bob, hat)
    y = bob
    p.vline(16, 3 + y, 21, "wood")
    p.px(16, 0 + y, "steel_light")
    p.vline(16, 1 + y, 2 + y, "steel")
    p.px(15, 2 + y, "steel_dark")
    p.px(17, 2 + y, "steel_dark")
    p.hline(15, 17, 3 + y, "team")                 # tua cờ
    p.rect(14, 11 + y, 15, 12 + y, "skin")         # tay
    return with_shadow(outline(img))


def unit_crossbow(team, hat, bob):
    """Nỏ (Tây Sơn) hoặc cung (Thanh)."""
    img = new()
    p = Pen(img, team)
    humanoid(p, bob, hat)
    y = bob
    if hat == "non":
        p.hline(13, 20, 11 + y, "wood")            # báng nỏ
        p.vline(19, 8 + y, 14 + y, "wood_dark")    # cánh nỏ
        p.px(20, 8 + y, "wood_dark")
        p.px(20, 14 + y, "wood_dark")
        p.hline(20, 22, 11 + y, "steel_light")     # mũi tên
        p.rect(13, 11 + y, 14, 12 + y, "skin")
    else:
        for i, x in enumerate((16, 17, 17, 18, 18, 18, 18, 18, 17, 17, 16)):
            p.px(x, 6 + y + i, "wood_dark")        # cánh cung cong
        p.vline(15, 7 + y, 15 + y, "white")        # dây cung
        p.rect(16, 10 + y, 17, 11 + y, "skin")
        p.rect(4, 9 + y, 6, 15 + y, "wood")        # ống tên sau lưng
        p.hline(4, 6, 8 + y, "white")
    return with_shadow(outline(img))


def unit_shield(team, hat, bob):
    """Mộc thuẫn: khiên gỗ bện rơm tẩm nước (trận Ngọc Hồi). Vai trò 'xe tăng'."""
    img = new()
    p = Pen(img, team)
    humanoid(p, bob, hat)
    y = bob
    p.rect(14, 7 + y, 19, 20, "straw")
    p.vline(14, 7 + y, 20, "straw_dark")
    p.vline(18, 8 + y, 19, "straw_light")
    for ry in (10, 14, 18):
        p.hline(14, 19, ry + (y if ry < 18 else 0), "wood_dark")   # dây buộc
    p.px(16, 12 + y, "straw_dark")                 # vệt ướt
    p.px(17, 16, "straw_dark")
    p.px(14, 7 + y, (0, 0, 0, 0))
    p.px(19, 7 + y, (0, 0, 0, 0))
    p.vline(20, 2 + y, 11 + y, "steel")            # đoản đao giơ sau khiên
    p.px(20, 1 + y, "steel_light")
    return with_shadow(outline(img))


def unit_fire_lance(team, hat, bob):
    """Hỏa hổ: ống tre phun lửa. Gây 'cháy' (mất máu mỗi lượt) thay cho độc của Spider."""
    img = new()
    p = Pen(img, team)
    humanoid(p, bob, hat)
    y = bob
    p.hline(13, 20, 12 + y, "bamboo")
    p.hline(13, 20, 11 + y, "bamboo_light")
    p.px(16, 11 + y, "bamboo_dark")
    p.px(16, 12 + y, "bamboo_dark")
    p.rect(13, 11 + y, 14, 12 + y, "skin")
    if bob == 0:
        p.rect(21, 10, 22, 13, "fire")
        p.px(23, 11, "fire_light")
        p.px(22, 11, "fire_light")
        p.px(21, 9, "fire_dark")
    else:
        p.rect(21, 11, 23, 13, "fire")
        p.px(22, 12, "fire_light")
        p.px(23, 10, "fire_dark")
    return with_shadow(outline(img))


def unit_drummer(team, hat, bob):
    """Lính trống trận: hào quang +công cho quân xung quanh (vai trò Wisp)."""
    img = new()
    p = Pen(img, team)
    humanoid(p, bob, hat)
    y = bob
    p.ellipse(16, 15, 4, 3, "wood")                # trống
    p.ellipse(16, 13, 4, 1, "white")
    p.hline(13, 19, 15, "team")
    p.px(13, 17, "gold")
    p.px(19, 17, "gold")
    p.line(14, 10 + y, 18, 6 + 2 * y, "wood_dark")  # dùi trống
    p.px(18, 6 + 2 * y, "team_light")
    p.rect(13, 10 + y, 14, 11 + y, "skin")
    return with_shadow(outline(img))


def unit_commander(team, hat, bob):
    img = new()
    p = Pen(img, team)
    humanoid(p, bob, hat, cape=True)
    y = bob
    p.rect(10, 10 + y, 13, 13 + y, "gold")         # giáp ngực
    p.hline(10, 13, 10 + y, "gold_light")
    p.vline(10, 11 + y, 13 + y, "gold_dark")
    p.line(15, 10 + y, 20, 2 + y, "steel_light")   # kiếm giơ cao
    p.line(16, 10 + y, 21, 3 + y, "steel")
    p.hline(14, 17, 11 + y, "gold")                # chuôi kiếm
    p.rect(14, 10 + y, 15, 11 + y, "skin")
    return with_shadow(outline(img))


def unit_elephant(team, bob):
    """Voi chiến có bành. Lính mạnh nhất, đắt nhất (vai trò Wyvern)."""
    img = new()
    p = Pen(img, team)
    # Chân sau (tối) rồi thân
    for x0 in (4, 12):
        p.rect(x0, 17, x0 + 2, 21, "ele_dark")
    p.ellipse(10, 13, 8, 5, "ele")
    p.hline(5, 14, 9, "ele_light")
    p.hline(4, 15, 18, "ele_dark")
    for x0 in (7, 15):
        p.rect(x0, 17, x0 + 2, 21, "ele")
        p.hline(x0, x0 + 2, 21, "ele_light")
    # Đầu, tai, mắt, ngà, vòi
    p.ellipse(18, 11, 4, 4, "ele")
    p.rect(14, 8, 16, 14, "ele_dark")
    p.px(19, 9, "outline")
    p.hline(20, 22, 15, "white")
    p.px(22, 14, "white")
    sway = bob
    p.vline(21, 12, 18, "ele")
    p.vline(22, 13, 17, "ele_dark")
    p.px(22 + sway, 19, "ele")
    p.px(23, 18 + sway, "ele")
    # Bành + người cưỡi + cờ
    p.rect(5, 6, 13, 8, "wood")
    p.hline(5, 13, 8, "wood_dark")
    p.rect(9, 2, 11, 5, "skin")
    p.px(11, 3, "outline")
    p.hline(8, 12, 1, "straw")
    p.hline(9, 11, 0, "straw_light")
    p.rect(4, 4, 13, 5, "team")
    p.hline(4, 13, 4, "team_light")
    p.vline(5, 0, 5, "wood_dark")
    p.rect(2, 0, 4, 2, "team")                     # cờ đuôi nheo
    p.px(1, 1, "team_dark")
    img = outline(img)
    return with_shadow(img, cx=11, cy=22, rx=10)


def unit_cannon(team, bob):
    """Đại bác / thần công: bắn xa, không bắn được ô sát bên (vai trò Catapult)."""
    img = new()
    p = Pen(img, team)
    p.line(1, 19, 8, 15, "wood_dark")              # càng
    p.line(1, 20, 8, 16, "wood")
    p.rect(5, 10, 19, 13, "bronze")                # nòng
    p.hline(5, 19, 10, "bronze_light")
    p.hline(5, 19, 13, "bronze_dark")
    p.rect(19, 9, 21, 14, "bronze")
    p.vline(21, 9, 14, "bronze_dark")
    p.vline(9, 9, 14, "bronze_dark")
    p.rect(3, 10, 5, 13, "bronze_dark")
    p.ellipse(11, 17, 4, 4, "wood")                # bánh xe
    p.ellipse(11, 17, 2, 2, "wood_dark")
    p.px(11, 17, "gold")
    p.vline(2, 2, 10, "wood_dark")                 # cờ phe
    p.rect(3, 2, 6, 4, "team")
    p.hline(3, 6, 2, "team_light")
    img = outline(img)
    if bob:
        q = Pen(img)
        q.px(22, 8, "smoke")
        q.px(23, 7, "smoke")
    return with_shadow(img, cx=11, cy=22, rx=8)


UNITS = {
    # tên file: (phe, hàm vẽ)
    "tayson_quangtrung": ("tayson", lambda b: unit_commander("tayson", "khan", b)),
    "tayson_linhgiao":   ("tayson", lambda b: unit_spear("tayson", "non", b)),
    "tayson_noithu":     ("tayson", lambda b: unit_crossbow("tayson", "non", b)),
    "tayson_mocthuan":   ("tayson", lambda b: unit_shield("tayson", "non", b)),
    "tayson_hoaho":      ("tayson", lambda b: unit_fire_lance("tayson", "non", b)),
    "tayson_trongtran":  ("tayson", lambda b: unit_drummer("tayson", "non", b)),
    "tayson_voichien":   ("tayson", lambda b: unit_elephant("tayson", b)),
    "tayson_daibac":     ("tayson", lambda b: unit_cannon("tayson", b)),
    "thanh_tuong":       ("thanh", lambda b: unit_commander("thanh", "mu_quan", b)),
    "thanh_linhgiao":    ("thanh", lambda b: unit_spear("thanh", "mu", b)),
    "thanh_cungthu":     ("thanh", lambda b: unit_crossbow("thanh", "mu", b)),
    "thanh_daibac":      ("thanh", lambda b: unit_cannon("thanh", b)),
}


# =============================================================================
# 4. ĐỊA HÌNH
# =============================================================================
def tile_grass(seed=1):
    img = new(fill=C["grass"])
    p = Pen(img)
    rnd = random.Random(seed)
    for _ in range(9):
        x, y = rnd.randrange(1, 22), rnd.randrange(1, 23)
        p.px(x, y, "grass_light")
        p.px(x + 1, y - 1, "grass_light")
    for _ in range(7):
        p.px(rnd.randrange(24), rnd.randrange(24), "grass_dark")
    return img


def tile_road():
    img = tile_grass(2)
    p = Pen(img)
    p.rect(7, 0, 16, 23, "dirt")
    p.vline(7, 0, 23, "dirt_dark")
    p.vline(16, 0, 23, "dirt_dark")
    rnd = random.Random(3)
    for _ in range(6):
        p.px(rnd.randrange(9, 15), rnd.randrange(24), "dirt_light")
    return img


def tile_paddy():
    """Ruộng lúa: đi chậm, không có phòng thủ."""
    img = new(fill=C["paddy_water"])
    p = Pen(img)
    for ry in (2, 8, 14, 20):
        for rx in range(1, 24, 4):
            p.vline(rx + 1, ry - 1, ry + 1, "rice")
            p.px(rx, ry - 1, "rice_light")
            p.px(rx + 2, ry - 1, "rice_light")
            p.px(rx + 1, ry + 2, "rice_dark")
    p.hline(0, 23, 23, "dirt")                     # bờ ruộng
    p.hline(0, 23, 22, "dirt_light")
    return img


def bamboo_clump(p, x, y, h):
    for i, dx in enumerate((0, 2, 4)):
        top = y - h + (i % 2) * 2
        p.vline(x + dx, top, y, "bamboo")
        p.vline(x + dx + 1, top, y, "bamboo_dark")
        for ny in range(top + 2, y, 4):
            p.hline(x + dx, x + dx + 1, ny, "bamboo_light")
    p.rect(x - 2, y - h - 2, x + 6, y - h, "bamboo_dark")
    p.hline(x - 1, x + 5, y - h - 2, "bamboo_light")


def tile_bamboo():
    """Rừng tre: +phòng thủ, che tầm nhìn."""
    img = tile_grass(4)
    p = Pen(img)
    bamboo_clump(p, 2, 22, 14)
    bamboo_clump(p, 14, 18, 12)
    bamboo_clump(p, 10, 23, 8)
    return img


def tile_peach():
    """Cây đào nở hoa Tết (biến thể của rừng)."""
    img = tile_grass(5)
    p = Pen(img)
    p.rect(11, 13, 12, 21, "wood_dark")
    p.line(12, 14, 17, 10, "wood_dark")
    p.line(11, 15, 6, 11, "wood_dark")
    p.ellipse(12, 8, 9, 6, "blossom")
    rnd = random.Random(6)
    for _ in range(14):
        p.px(rnd.randrange(4, 21), rnd.randrange(3, 14), "blossom_light")
    for _ in range(10):
        p.px(rnd.randrange(4, 21), rnd.randrange(4, 15), "blossom_dark")
    p.px(18, 19, "blossom")                        # cánh hoa rơi
    p.px(5, 20, "blossom_light")
    return img


def tile_karst():
    """Núi đá vôi: chỉ lính bay / đặc biệt qua được."""
    img = tile_grass(7)
    p = Pen(img)
    for cx, top, w in ((7, 2, 5), (16, 6, 5)):
        p.rect(cx - w, top + 3, cx + w, 23, "rock")
        p.ellipse(cx, top + 3, w, 3, "rock")
        p.vline(cx - w, top + 4, 23, "rock_dark")
        p.vline(cx + w - 1, top + 5, 23, "rock_light")
        p.vline(cx - 1, top + 7, 20, "rock_dark")
        p.ellipse(cx, top + 1, 3, 2, "grass_dark")  # cây trên đỉnh
        p.px(cx - 1, top, "grass")
    return img


def tile_hill():
    img = tile_grass(8)
    p = Pen(img)
    p.ellipse(12, 16, 11, 7, "grass_dark")
    p.ellipse(12, 15, 10, 6, "grass")
    p.ellipse(10, 13, 6, 3, "grass_light")
    p.rect(0, 22, 23, 23, "grass")
    return img


def tile_water(frame):
    img = new(fill=C["water"])
    p = Pen(img)
    for wx, wy in ((2, 4), (13, 9), (5, 15), (16, 20)):
        x = (wx + frame * 2) % 24
        p.hline(x, x + 3, wy, "water_light")
        p.hline(x + 1, x + 2, wy - 1, "water_light")
    p.hline(0, 23, 0, "water_dark")
    return img


def tile_bridge():
    img = tile_water(0)
    p = Pen(img)
    p.rect(5, 0, 18, 23, "wood")
    for y in range(0, 24, 4):
        p.hline(5, 18, y, "wood_dark")
        p.hline(6, 17, y + 1, "wood_light")
    p.vline(5, 0, 23, "wood_dark")
    p.vline(18, 0, 23, "wood_dark")
    return img


def tile_village(owner):
    """Làng (nhà tranh): chiếm để có vàng mỗi lượt; đứng trên làng được hồi máu."""
    img = tile_grass(9)
    p = Pen(img, owner)
    p.rect(4, 13, 17, 21, "wall")                  # tường đất
    p.vline(4, 13, 21, "wall_dark")
    p.rect(9, 16, 12, 21, "wood_dark")             # cửa
    p.rect(14, 15, 16, 17, "wood_dark")            # cửa sổ
    for i in range(7):                             # mái rạ
        p.hline(5 - i // 2 + (0 if i < 6 else 1), 16 + i // 2, 6 + i, "straw" if i % 2 else "straw_light")
    p.hline(2, 19, 12, "straw_dark")
    p.hline(8, 13, 5, "straw_dark")
    p.vline(20, 3, 21, "wood_dark")                # cột cờ
    p.rect(21, 3, 23, 6, "team")
    p.hline(21, 23, 3, "team_light")
    return img


def tile_castle(owner):
    """Thành / đồn: mua lính ở đây; chỉ chủ tướng chiếm được."""
    img = tile_grass(10)
    p = Pen(img, owner)
    p.rect(1, 12, 22, 22, "wall")                  # tường thành
    p.hline(1, 22, 12, "wall_light")
    p.hline(1, 22, 22, "wall_dark")
    for x in range(1, 23, 4):
        p.hline(x, x + 1, 11, "wall")              # răng cưa
    for y in (15, 18):
        for x in range(2 + (y % 2) * 2, 22, 5):
            p.hline(x, x + 2, y, "wall_dark")      # mạch gạch
    p.ellipse(11, 19, 3, 3, "outline")             # cổng vòm
    p.rect(8, 19, 14, 22, "outline")
    p.rect(5, 7, 18, 11, "roof")                   # lầu, mái cong
    p.hline(3, 20, 6, "roof_dark")
    p.px(2, 5, "roof_dark")
    p.px(21, 5, "roof_dark")
    p.hline(5, 18, 7, "roof_light")
    p.rect(7, 9, 16, 11, "wood")
    p.rect(9, 9, 10, 10, "outline")
    p.rect(13, 9, 14, 10, "outline")
    p.vline(11, 0, 6, "wood_dark")                 # cờ lớn
    p.rect(12, 0, 16, 3, "team")
    p.hline(12, 16, 0, "team_light")
    p.px(16, 4, "team_dark")
    return img


def tile_grave():
    """Mộ (khi lính chết). Thầy pháp có thể gọi âm binh từ mộ (vai trò Wizard)."""
    img = tile_grass(11)
    p = Pen(img)
    p.ellipse(12, 17, 8, 4, "dirt_dark")
    p.ellipse(12, 16, 7, 3, "dirt")
    p.rect(10, 7, 14, 15, "rock")                  # bia đá
    p.hline(10, 14, 7, "rock_light")
    p.vline(10, 8, 15, "rock_dark")
    p.hline(11, 13, 10, "rock_dark")
    p.hline(11, 13, 12, "rock_dark")
    p.vline(16, 11, 15, "wood")                    # nén nhang
    p.px(16, 10, "fire")
    p.px(17, 8, "smoke")
    p.px(16, 7, "smoke")
    return img


TILES = {
    "tile_grass": tile_grass,
    "tile_road": tile_road,
    "tile_paddy": tile_paddy,
    "tile_bamboo": tile_bamboo,
    "tile_peach": tile_peach,
    "tile_karst": tile_karst,
    "tile_hill": tile_hill,
    "tile_bridge": tile_bridge,
    "tile_grave": tile_grave,
    "tile_village_neutral": lambda: tile_village("neutral"),
    "tile_village_tayson": lambda: tile_village("tayson"),
    "tile_village_thanh": lambda: tile_village("thanh"),
    "tile_castle_neutral": lambda: tile_castle("neutral"),
    "tile_castle_tayson": lambda: tile_castle("tayson"),
    "tile_castle_thanh": lambda: tile_castle("thanh"),
}


# =============================================================================
# 5. UI
# =============================================================================
def ui_cursor(frame):
    img = new()
    p = Pen(img)
    o = frame  # frame 1 co vào 1px
    for sx, sy in ((0, 0), (1, 0), (0, 1), (1, 1)):
        x = o if sx == 0 else 23 - o
        y = o if sy == 0 else 23 - o
        dx = 1 if sx == 0 else -1
        dy = 1 if sy == 0 else -1
        for i in range(5):
            p.px(x + dx * i, y, "gold_light")
            p.px(x, y + dy * i, "gold_light")
            p.px(x + dx * i, y + dy, "gold_dark")
            p.px(x + dx, y + dy * i, "gold_dark")
    return img


def ui_highlight(color):
    img = new()
    p = Pen(img)
    p.rect(0, 0, 23, 23, (*color, 90))
    p.rect(1, 1, 22, 22, (*color, 70))
    return img


def ui_coin():
    """Đồng tiền xu lỗ vuông."""
    img = new(12, 12)
    p = Pen(img)
    p.ellipse(5, 5, 5, 5, "gold_dark")
    p.ellipse(5, 5, 4, 4, "gold")
    p.px(3, 3, "gold_light")
    p.px(2, 4, "gold_light")
    p.rect(4, 4, 6, 6, (0, 0, 0, 0))
    p.rect(4, 4, 6, 6, "gold_dark")
    p.px(5, 5, (0, 0, 0, 0))
    return outline(img)


# Chữ số 3x5 để hiện máu lính trên bản đồ (giống AE2)
DIGITS = {
    "0": ["111", "101", "101", "101", "111"], "1": ["010", "110", "010", "010", "111"],
    "2": ["111", "001", "111", "100", "111"], "3": ["111", "001", "011", "001", "111"],
    "4": ["101", "101", "111", "001", "001"], "5": ["111", "100", "111", "001", "111"],
    "6": ["111", "100", "111", "101", "111"], "7": ["111", "001", "010", "010", "010"],
    "8": ["111", "101", "111", "101", "111"], "9": ["111", "101", "111", "001", "111"],
}


def hp_badge(value):
    text = str(value)
    w = len(text) * 4 + 1
    img = new(w + 2, 9)
    p = Pen(img)
    p.rect(0, 0, w + 1, 8, "outline")
    for i, ch in enumerate(text):
        for ry, row in enumerate(DIGITS[ch]):
            for rx, bit in enumerate(row):
                if bit == "1":
                    p.px(2 + i * 4 + rx, 2 + ry, "white")
    return img


# =============================================================================
# 6. MOCKUP MÀN HÌNH ĐIỆN THOẠI (dọc 9:16)
# =============================================================================
MAP = [
    "kkbgCgbkk",
    "kbgdrdgbk",
    "bgXgrggvb",
    "hgggrgggh",
    "pppgrgppp",
    "wwwwBwwww",
    "pppgrgppp",
    "dggVrgggd",
    "bgggrgvgb",
    "hggprpggh",
    "kbgdrdgbk",
    "kkbgcgbkk",
]
MAP_TILES = {
    "g": "tile_grass", "r": "tile_road", "p": "tile_paddy", "b": "tile_bamboo", "d": "tile_peach",
    "k": "tile_karst", "h": "tile_hill", "B": "tile_bridge", "v": "tile_village_neutral",
    "V": "tile_village_tayson", "X": "tile_village_thanh", "c": "tile_castle_tayson",
    "C": "tile_castle_thanh", "w": "tile_water",
}
# (cột, hàng): (sprite, máu)
MAP_UNITS = {
    (4, 8): ("tayson_quangtrung", 100), (4, 6): ("tayson_mocthuan", 100),
    (6, 7): ("tayson_linhgiao", 80), (3, 9): ("tayson_noithu", 100),
    (2, 8): ("tayson_voichien", 100), (5, 10): ("tayson_daibac", 60),
    (3, 7): ("tayson_trongtran", 100),
    (4, 0): ("thanh_tuong", 100), (4, 4): ("thanh_linhgiao", 70),
    (6, 3): ("thanh_cungthu", 100), (2, 2): ("thanh_daibac", 100),
    (7, 4): ("thanh_linhgiao", 40),
}
SELECTED = (4, 8)
MOVE = 4


def reachable(start, move):
    """BFS đơn giản: mỗi ô tốn 1 bước; nước (trừ cầu) và núi chặn; lính địch chặn."""
    seen = {start: 0}
    q = deque([start])
    while q:
        x, y = q.popleft()
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            n = (x + dx, y + dy)
            if not (0 <= n[0] < 9 and 0 <= n[1] < len(MAP)) or n in seen:
                continue
            if MAP[n[1]][n[0]] in "wk":
                continue
            u = MAP_UNITS.get(n)
            if u and u[0].startswith("thanh"):
                continue
            if seen[(x, y)] + 1 <= move:
                seen[n] = seen[(x, y)] + 1
                q.append(n)
    return seen


def mockup(tiles, units, font_path):
    W, H, S = 9 * T, 16 * T, 3
    top, map_h = 24, len(MAP) * T
    img = new(W, H, C["lacquer_dark"])
    for r, row in enumerate(MAP):
        for c, ch in enumerate(row):
            img.alpha_composite(tiles[MAP_TILES[ch]], (c * T, top + r * T))
    reach = reachable(SELECTED, MOVE)
    move_hl, atk_hl = ui_highlight((80, 150, 255)), ui_highlight((255, 60, 50))
    for (c, r) in reach:
        if (c, r) not in MAP_UNITS:
            img.alpha_composite(move_hl, (c * T, top + r * T))
    for (c, r), (name, _) in MAP_UNITS.items():
        if name.startswith("thanh") and any((c + dx, r + dy) in reach for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
            img.alpha_composite(atk_hl, (c * T, top + r * T))
    for (c, r), (name, hp) in MAP_UNITS.items():
        frame = units[name].crop((0, 0, T, T))
        if name.startswith("thanh"):
            frame = frame.transpose(Image.FLIP_LEFT_RIGHT)
        img.alpha_composite(frame, (c * T, top + r * T))
        if hp < 100:
            badge = hp_badge(hp)
            img.alpha_composite(badge, (c * T + T - badge.width, top + r * T + T - badge.height))
    img.alpha_composite(ui_cursor(0), (SELECTED[0] * T, top + SELECTED[1] * T))

    # Khung sơn mài: thanh trên + bảng thông tin dưới
    p = Pen(img)
    p.rect(0, 0, W - 1, top - 1, "lacquer")
    p.hline(0, W - 1, top - 2, "gold_dark")
    p.hline(0, W - 1, top - 1, "outline")
    panel_y = top + map_h
    p.rect(0, panel_y, W - 1, H - 1, "lacquer")
    p.hline(0, W - 1, panel_y, "outline")
    p.hline(0, W - 1, panel_y + 1, "gold_dark")
    p.rect(4, panel_y + 8, 57, panel_y + 61, "lacquer_dark")   # khung chân dung
    p.hline(4, 57, panel_y + 8, "gold_dark")
    portrait = units["tayson_quangtrung"].crop((0, 0, T, T)).resize((48, 48), Image.NEAREST)
    img.alpha_composite(portrait, (7, panel_y + 12))
    img.alpha_composite(ui_coin(), (W - 70, 6))
    for i, label in enumerate(("Chờ", "Đi", "Đánh")):          # nút hành động
        bx = 64 + i * 50
        p.rect(bx, panel_y + 48, bx + 44, panel_y + 64, "lacquer_light" if i == 2 else "lacquer_dark")
        p.hline(bx, bx + 44, panel_y + 48, "gold_dark")

    big = img.resize((W * S, H * S), Image.NEAREST)
    d = ImageDraw.Draw(big)
    d.fontmode = "1"
    f_big = ImageFont.truetype(font_path, 48)
    f_med = ImageFont.truetype(font_path, 36)
    gold, white = rgba(C["gold_light"]), rgba(C["white"])
    d.text((12, 4), "Lượt 3 · Tây Sơn", font=f_big, fill=gold)
    d.text(((W - 54) * S, 6), "1200", font=f_big, fill=white)
    py = panel_y * S
    d.text((64 * S, py + 16), "Quang Trung", font=f_big, fill=gold)
    d.text((64 * S, py + 66), "Máu 100  Công 55-65", font=f_med, fill=white)
    d.text((64 * S, py + 100), "Thủ 20  Di chuyển 4", font=f_med, fill=white)
    for i, label in enumerate(("Chờ", "Đi", "Đánh")):
        bx = (64 + i * 50) * S
        d.text((bx + 22, py + 48 * S + 6), label, font=f_med, fill=gold)
    return big


# =============================================================================
# 7. PREVIEW SHEET
# =============================================================================
def preview_sheet(groups, font_path, scale=4):
    font = ImageFont.truetype(font_path, 20)
    cell_w, cell_h, cols = 38 * scale, T * scale + 26, 7
    rows = sum((len(items) + cols - 1) // cols for _, items in groups)
    sheet = new(cols * cell_w + 16, rows * cell_h + len(groups) * 34 + 16, (34, 30, 36))
    d = ImageDraw.Draw(sheet)
    d.fontmode = "1"
    y = 8
    for title, items in groups:
        d.text((8, y), title, font=ImageFont.truetype(font_path, 30), fill=rgba(C["gold_light"]))
        y += 34
        for i, (name, im) in enumerate(items):
            cx, cy = 8 + (i % cols) * cell_w, y + (i // cols) * cell_h
            frame = im.crop((0, 0, min(im.width, T), min(im.height, T)))
            bg = new(T, T, (58, 54, 62))
            for yy in range(0, T, 4):                # nền caro
                for xx in range((yy // 4 % 2) * 4, T, 8):
                    Pen(bg).rect(xx, yy, xx + 3, yy + 3, (70, 66, 74))
            bg.alpha_composite(frame)
            sheet.alpha_composite(bg.resize((T * scale, T * scale), Image.NEAREST), (cx, cy))
            d.text((cx, cy + T * scale + 2), name.replace("tile_", "").replace("ui_", ""),
                   font=font, fill=rgba(C["white"]))
        y += ((len(items) + cols - 1) // cols) * cell_h
    return sheet


# =============================================================================
# 8. MAIN
# =============================================================================
def main():
    os.makedirs(OUT_DIR, exist_ok=True)

    def save(img, name):
        path = os.path.join(OUT_DIR, name + ".png")
        img.save(path)
        print(f"  {name}.png  {img.width}x{img.height}")

    units = {}
    for name, (_, fn) in UNITS.items():
        units[name] = strip([fn(0), fn(1)])
        save(units[name], f"unit_{name}_strip2")

    tiles = {name: fn() for name, fn in TILES.items()}
    tiles["tile_water"] = tile_water(0)
    for name, im in tiles.items():
        save(im, name)
    save(strip([tile_water(0), tile_water(1)]), "tile_water_strip2")

    ui = {
        "ui_cursor": strip([ui_cursor(0), ui_cursor(1)]),
        "ui_move": ui_highlight((80, 150, 255)),
        "ui_attack": ui_highlight((255, 60, 50)),
        "ui_coin": ui_coin(),
    }
    save(ui["ui_cursor"], "ui_cursor_strip2")
    for name in ("ui_move", "ui_attack", "ui_coin"):
        save(ui[name], name)

    save(preview_sheet([
        ("Tây Sơn", [(n.split("_", 1)[1], im) for n, im in units.items() if n.startswith("tayson")]),
        ("Quân Thanh", [(n.split("_", 1)[1], im) for n, im in units.items() if n.startswith("thanh")]),
        ("Địa hình", list(tiles.items())),
        ("UI", list(ui.items())),
    ], FONT_PATH), "preview_sheet")
    save(mockup(tiles, units, FONT_PATH), "mockup_phone")


if __name__ == "__main__":
    main()
