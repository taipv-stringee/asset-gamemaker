#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
gen_objects.py — Vật thể trên bản đồ (32x32, pixel art): trống báo động, đèn lồng, kho lương, lửa (doanh trại bị đốt).
Mỗi vật thể có 2 frame (dải 64x32) để nhấp nháy lửa / rung trống.

Kết quả: godot/assets/objects/obj_<loai>_strip2.png
"""

import os

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(os.path.dirname(HERE), "godot", "assets", "objects")
T = 32

C = {
    "ink": (24, 14, 12), "wood_d": (70, 40, 22), "wood": (112, 68, 36), "wood_l": (150, 98, 54),
    "skin_d": (176, 140, 92), "skin": (214, 184, 132), "skin_l": (236, 214, 170),
    "red_d": (120, 22, 24), "red": (190, 40, 36), "red_l": (232, 86, 60),
    "gold": (232, 182, 52), "fire_d": (214, 92, 24), "fire": (250, 160, 40), "fire_l": (255, 236, 150),
    "shadow": (0, 0, 0, 90),
    "sack_d": (150, 120, 76), "sack": (196, 166, 112), "sack_l": (226, 204, 150),
    "straw_d": (130, 96, 40), "straw": (186, 146, 64), "straw_l": (222, 190, 104),
}


def px(img, x, y, c):
    if 0 <= x < img.width and 0 <= y < img.height:
        img.putpixel((x, y), C[c] + (255,) if len(C[c]) == 3 else C[c])


def rect(img, x0, y0, x1, y1, c):
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            px(img, x, y, c)


def shadow(img, cx, y, w):
    for x in range(cx - w, cx + w + 1):
        px(img, x, y, "shadow")
        if abs(x - cx) < w - 1:
            px(img, x, y + 1, "shadow")


def trong(frame):
    """Trống cái trên giá gỗ, mặt da, thân sơn đỏ đóng đinh vàng; frame 1: mặt trống rung (sáng hơn)."""
    img = Image.new("RGBA", (T, T), (0, 0, 0, 0))
    shadow(img, 16, 28, 11)
    # giá chữ A
    for i in range(12):
        px(img, 6 + i // 3, 27 - i, "wood_d")
        px(img, 25 - i // 3, 27 - i, "wood_d")
    rect(img, 7, 22, 24, 22, "wood")
    # thân trống (hình trống nằm, nhìn chếch)
    rect(img, 8, 9, 23, 20, "red")
    rect(img, 8, 9, 23, 10, "red_l")
    rect(img, 8, 19, 23, 20, "red_d")
    for x in (8, 23):
        rect(img, x, 9, x, 20, "ink")
    rect(img, 8, 8, 23, 8, "ink")
    rect(img, 8, 21, 23, 21, "ink")
    for x in range(10, 23, 3):  # đinh vàng
        px(img, x, 11, "gold")
        px(img, x, 18, "gold")
    # mặt da (elip bên trái)
    face = "skin_l" if frame else "skin"
    for y in range(9, 21):
        for x in range(4, 10):
            if ((x - 7) / 3.2) ** 2 + ((y - 14.5) / 6.2) ** 2 <= 1:
                px(img, x, y, face)
    for y in range(9, 21):
        for x in range(3, 11):
            if 0.85 < ((x - 7) / 3.6) ** 2 + ((y - 14.5) / 6.6) ** 2 <= 1.25:
                px(img, x, y, "ink")
    px(img, 6, 13, "skin_d")
    px(img, 7, 16, "skin_d")
    # dùi trống
    dy = -2 if frame else 0
    for i in range(7):
        px(img, 1 + i // 2, 5 + i + dy, "wood_l")
    px(img, 1, 4 + dy, "red")
    return img


def den(frame):
    """Đèn lồng đỏ treo trên cột tre; frame 1: lửa sáng hơn."""
    img = Image.new("RGBA", (T, T), (0, 0, 0, 0))
    shadow(img, 16, 29, 6)
    rect(img, 15, 4, 16, 28, "wood")
    rect(img, 15, 4, 15, 28, "wood_l")
    rect(img, 13, 28, 18, 28, "wood_d")
    rect(img, 16, 5, 22, 5, "wood")       # cần treo
    px(img, 22, 6, "ink")
    # lồng đèn
    glow = "fire_l" if frame else "fire"
    for y in range(8, 19):
        half = [2, 3, 4, 4, 5, 5, 5, 4, 4, 3, 2][y - 8]
        for x in range(22 - half, 22 + half + 1):
            edge = abs(x - 22) == half
            px(img, x, y, "ink" if edge else ("red_l" if abs(x - 22) < 2 else "red"))
    rect(img, 21, 11, 23, 15, glow)
    rect(img, 20, 7, 24, 7, "gold")
    rect(img, 20, 19, 24, 19, "gold")
    px(img, 22, 20, "red")
    px(img, 22, 21, "red_d")
    return img


def kho_luong(frame):
    """Kho lương: mái rạ trên bốn cột, dưới là các bao thóc xếp chồng; frame 1 giống frame 0 (vật tĩnh)."""
    img = Image.new("RGBA", (T, T), (0, 0, 0, 0))
    shadow(img, 16, 29, 13)
    for x in (5, 26):                       # cột
        rect(img, x, 12, x + 1, 28, "wood_d")
    # bao thóc: 3 dưới, 2 giữa, 1 trên
    def sack(cx, cy):
        for y in range(cy - 3, cy + 4):
            for x in range(cx - 4, cx + 5):
                if ((x - cx) / 4.6) ** 2 + ((y - cy) / 3.6) ** 2 <= 1:
                    px(img, x, y, "sack_l" if y < cy - 1 else ("sack_d" if y > cy + 1 else "sack"))
        px(img, cx, cy - 3, "ink")
        px(img, cx - 1, cy - 4, "ink")
        px(img, cx + 1, cy - 4, "ink")
    for cx in (9, 16, 23):
        sack(cx, 25)
    for cx in (12, 20):
        sack(cx, 20)
    sack(16, 15)
    # mái rạ
    for y in range(3, 12):
        w = 6 + (y - 3) * 2
        for x in range(16 - w, 16 + w + 1):
            if 0 <= x < T:
                band = (x + y * 2) % 5
                px(img, x, y, "straw_l" if band == 0 else ("straw_d" if y > 9 else "straw"))
    rect(img, 0, 11, 31, 11, "straw_d")
    rect(img, 10, 2, 22, 2, "ink")
    return img


def lua(frame):
    """Lửa trên ô doanh trại bị Đốt (02 §12): cột lều cháy đen, ba lưỡi lửa; frame 1 lưỡi lửa đổi cao thấp."""
    img = Image.new("RGBA", (T, T), (0, 0, 0, 0))
    shadow(img, 16, 29, 12)
    # cột lều cháy dở, nghiêng
    for i in range(14):
        px(img, 7 + i // 4, 28 - i, "ink")
        px(img, 25 - i // 4, 28 - i, "ink")
    rect(img, 4, 27, 27, 28, "wood_d")
    for x in range(5, 27, 3):
        px(img, x, 26, "ink")
    # ba lưỡi lửa: (tâm x, chiều cao frame 0, frame 1, nửa bề ngang)
    tongues = ((10, 14, 18, 4), (17, 21, 16, 5), (24, 12, 15, 4))
    for cx, h0, h1, half in tongues:
        h = h1 if frame else h0
        top = 27 - h
        for y in range(top, 27):
            t = (y - top) / max(h, 1)          # 0 ở đỉnh → 1 ở chân
            w = max(0, round(half * min(1.0, t * 1.6)))
            sway = 1 if (frame and y < top + h // 2) else 0
            for x in range(cx - w + sway, cx + w + 1 + sway):
                core = abs(x - cx - sway) <= w // 2 and t > 0.35
                px(img, x, y, "fire_l" if core and t > 0.6 else ("fire" if core or t > 0.5 else "fire_d"))
    # tàn lửa
    for x, y in (((6, 9), (27, 6)) if frame else ((12, 4), (22, 8))):
        px(img, x, y, "fire_l")
    return img


def main():
    os.makedirs(OUT, exist_ok=True)
    for name, fn in (("trong", trong), ("den", den), ("kho_luong", kho_luong), ("lua", lua)):
        strip = Image.new("RGBA", (T * 2, T), (0, 0, 0, 0))
        for f in range(2):
            strip.paste(fn(f), (T * f, 0))
        strip.save(os.path.join(OUT, f"obj_{name}_strip2.png"))
        strip.resize((T * 2 * 6, T * 6), Image.NEAREST).save(os.path.join(HERE, f"_xem_obj_{name}.png"))
    print("Đã tạo vật thể trong", OUT)


if __name__ == "__main__":
    main()
