#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
art_sample.py — Mẫu hình "bản thật" (final-quality sample) cho Tây Sơn.

    python3 art_sample.py      # -> ../godot/assets/sample/

Draft 1 — đang lặp.
"""

import os

from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.normpath(os.path.join(HERE, "..", "godot", "assets", "sample"))
SCRATCH = os.environ.get("ART_SCRATCH")

# =============================================================================
# 1. BẢNG MÀU
# =============================================================================
PAL = {
    "outline":      (28, 20, 22),
    "ink":          (20, 14, 16),
    # Da
    "skin_light":   (252, 214, 176),
    "skin":         (236, 186, 140),
    "skin_dark":    (196, 136, 98),
    "skin_shadow":  (146, 90, 70),
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
    # Tua giáo (đỏ cố định, không đổi theo phe)
    "tassel_light": (240, 92, 72),
    "tassel":       (196, 36, 36),
    "tassel_dark":  (122, 20, 28),
    # Vàng
    "gold_light":   (255, 232, 140),
    "gold":         (236, 186, 52),
    "gold_dark":    (168, 112, 24),
}

# Màu phe: 3 ô màu có tên -> đổi phe = đổi 3 màu này.
TEAMS = {
    "tayson": {"team_dark": (128, 20, 28), "team": (204, 42, 44), "team_light": (246, 104, 84)},
    "thanh":  {"team_dark": (32, 54, 124), "team": (58, 96, 184), "team_light": (116, 156, 226)},
}

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


def grid(text):
    """Bản vẽ ASCII -> list hàng; kiểm tra mọi hàng cùng độ dài."""
    rows = [r.strip() for r in text.strip("\n").split("\n")]
    rows = [r.strip("|") for r in rows]
    w = len(rows[0])
    for i, r in enumerate(rows):
        assert len(r) == w, f"hàng {i} dài {len(r)} != {w}: {r!r}"
    return rows


def paint(img, rows, pal, ox=0, oy=0):
    for y, row in enumerate(rows):
        for x, ch in enumerate(row):
            if ch in ".":
                continue
            X, Y = ox + x, oy + y
            if 0 <= X < img.width and 0 <= Y < img.height:
                img.putpixel((X, Y), rgba(pal[KEY[ch]]))


def outline(img, color=PAL["outline"]):
    """Viền tối 1px quanh phần đã vẽ (4 hướng)."""
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


def shadow(sprite, cx=16, cy=29, rx=8):
    """Bóng bầu dục mờ dưới chân (vẽ sau viền)."""
    base = Image.new("RGBA", sprite.size, (0, 0, 0, 0))
    for y in range(cy - 2, cy + 3):
        for x in range(cx - rx - 1, cx + rx + 2):
            dx, dy = (x - cx) / (rx + 0.5), (y - cy) / 2.5
            if dx * dx + dy * dy <= 1:
                base.putpixel((x, y), (0, 0, 0, 72))
    base.alpha_composite(sprite)
    return base


# =============================================================================
# 2. LÍNH GIÁO TÂY SƠN (32x32, nhìn sang phải)
# =============================================================================
IDLE = ["."*32]*32  # placeholder



def unit_frames(team):
    pal = palette(team)
    frames = {}
    img = Image.new("RGBA", (32, 32))
    paint(img, IDLE, pal)
    frames["idle0"] = img
    return frames


def finish(img):
    return shadow(outline(img.copy()))


# =============================================================================
# 5. MAIN
# =============================================================================
def debug_view(frames, path, s=12):
    n = len(frames)
    sheet = Image.new("RGBA", (n * 32 * s + (n + 1) * 8, 32 * s + 16), (70, 72, 78, 255))
    for i, f in enumerate(frames):
        big = f.resize((32 * s, 32 * s), Image.NEAREST)
        x = 8 + i * (32 * s + 8)
        sheet.alpha_composite(big, (x, 8))
        d = ImageDraw.Draw(sheet)
        for k in range(33):
            d.line((x + k * s, 8, x + k * s, 8 + 32 * s), fill=(255, 255, 255, 18))
            d.line((x, 8 + k * s, x + 32 * s, 8 + k * s), fill=(255, 255, 255, 18))
    sheet.save(path)


def main():
    fr = unit_frames("tayson")
    if SCRATCH:
        debug_view([finish(fr["idle0"]), finish(unit_frames("thanh")["idle0"])],
                   os.path.join(SCRATCH, "dbg_unit.png"))


if __name__ == "__main__":
    main()
