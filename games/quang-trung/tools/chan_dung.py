#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
chan_dung.py — Chân dung hội thoại 80x80 cho nhân vật có tên (docs/05 §2, 07). Cùng nét vẽ với chân dung Quang Trung
của bản nháp (generate_v2.portrait), nhưng có tham số: khăn / mũ, áo, râu, lông mày, tuổi.

Ngoại hình là **hình dung của game** (05 §2): không có chân dung đương thời cho các nhân vật này.

Chạy:  python3 tools/chan_dung.py   → godot/assets/portraits/portrait_<ma>.png (+ ảnh xem phóng to trong tools/_xem_chan_dung.png)
"""

import math
import os
import sys

from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, os.path.normpath(os.path.join(ROOT, "..", "..", "drafts", "quang-trung")))

import generate_assets as v1  # noqa: E402
import generate_v2 as v2       # noqa: E402
from generate_assets import Pen, outline, rgba  # noqa: E402

OUT = os.path.join(ROOT, "godot", "assets", "portraits")
C = v1.C
C.update({
    "robe_navy_dark": (28, 34, 58), "robe_navy": (46, 56, 92), "robe_navy_light": (78, 92, 140),
    "robe_black_dark": (22, 20, 24), "robe_black": (44, 40, 46), "robe_black_light": (80, 74, 82),
    "robe_brown_dark": (70, 46, 28), "robe_brown": (112, 76, 46), "robe_brown_light": (156, 112, 72),
    "robe_red_dark": (110, 20, 22), "robe_red": (168, 36, 34), "robe_red_light": (214, 80, 64),
    "khan_den": (36, 30, 36), "khan_den_light": (70, 62, 70),
    "khan_do": (176, 34, 34), "khan_do_light": (222, 82, 70),
    "hair_grey": (150, 146, 146), "hair_white": (214, 210, 206),
    "wrinkle": (196, 146, 108),
})


def face(p, d, beard="none", brows="thin", age=0, hair="hair"):
    """Mặt nhìn hơi sang phải (cùng bố cục với generate_v2.face)."""
    f = lambda n: rgba(C[n])  # noqa: E731
    d.ellipse((23, 31, 28, 44), fill=f("skin_dark"))                  # tai
    d.ellipse((24, 33, 27, 42), fill=f("skin"))
    d.rectangle((33, 48, 46, 64), fill=f("skin_dark"))                # cổ
    d.rectangle((40, 50, 46, 64), fill=f("skin"))
    d.ellipse((26, 16, 54, 52), fill=f("skin_dark"))
    d.ellipse((28, 15, 55, 50), fill=f("skin"))
    d.polygon([(29, 40), (54, 40), (47, 54), (35, 54)], fill=f("skin"))
    d.polygon([(29, 40), (31, 40), (36, 54), (35, 54)], fill=f("skin_dark"))
    d.ellipse((42, 20, 51, 28), fill=f("skin_light"))
    p.rect(30, 41, 32, 43, "skin_dark")
    for ex, iris in ((30, 33), (43, 46)):                               # mắt
        p.hline(ex, ex + 5, 34, "ink")
        p.hline(ex, ex + 5, 35, "white")
        p.rect(iris, 35, iris + 1, 36, "ink")
        p.hline(ex + 1, ex + 4, 37, "skin_dark")
    if brows == "thick":
        d.line((28, 30, 35, 32), fill=f(hair), width=2)
        d.line((43, 32, 50, 29), fill=f(hair), width=2)
    elif brows == "fierce":                                             # chau mày, trẻ, hăng
        d.line((28, 29, 35, 32), fill=f(hair), width=2)
        d.line((43, 32, 50, 28), fill=f(hair), width=2)
    else:
        d.line((29, 31, 35, 31), fill=f(hair), width=1)
        d.line((43, 31, 49, 30), fill=f(hair), width=1)
    p.vline(39, 36, 43, "skin_dark")                                   # mũi
    p.hline(38, 42, 44, "skin_dark")
    p.vline(41, 39, 42, "skin_light")
    p.hline(36, 44, 49, "lip")
    p.hline(37, 43, 50, "skin_dark")
    if age >= 1:                                                        # nếp nhăn
        p.hline(30, 34, 39, "wrinkle")
        p.hline(44, 48, 39, "wrinkle")
        p.hline(42, 48, 25, "wrinkle")
    if age >= 2:
        p.line(33, 45, 35, 48, "wrinkle")
        p.line(46, 45, 44, 48, "wrinkle")
        p.hline(41, 49, 22, "wrinkle")
    if beard == "short":
        d.line((33, 47, 40, 46), fill=f(hair), width=2)
        d.line((40, 46, 47, 47), fill=f(hair), width=2)
        d.polygon([(37, 52), (43, 52), (41, 56), (39, 56)], fill=f(hair))
    elif beard == "long":
        d.line((40, 46, 33, 48), fill=f(hair))
        d.line((33, 48, 31, 58), fill=f(hair))
        d.line((40, 46, 47, 48), fill=f(hair))
        d.line((47, 48, 49, 58), fill=f(hair))
        d.polygon([(36, 52), (44, 52), (42, 66), (38, 66)], fill=f(hair))
    elif beard == "goatee":
        d.line((34, 47, 40, 46), fill=f(hair))
        d.line((40, 46, 46, 47), fill=f(hair))
        d.polygon([(38, 52), (42, 52), (41, 60), (39, 60)], fill=f(hair))


def robe(p, d, color, collar="white", armor=False, belt=None):
    f = lambda n: rgba(C[n])  # noqa: E731
    d.polygon([(4, 79), (10, 63), (26, 57), (54, 57), (70, 63), (76, 79)], fill=f(color + "_dark"))
    d.polygon([(12, 79), (16, 64), (30, 58), (50, 58), (64, 64), (68, 79)], fill=f(color))
    d.polygon([(30, 58), (40, 74), (50, 58)], fill=f(collar))           # cổ áo giao lĩnh
    d.line((30, 58, 40, 74), fill=f(color + "_light"), width=2)
    d.line((50, 58, 42, 70), fill=f(color + "_dark"), width=2)
    if armor:
        for cx in (17, 63):
            d.ellipse((cx - 11, 61, cx + 11, 78), fill=f("steel_dark"))
            d.ellipse((cx - 10, 61, cx + 10, 76), fill=f("steel"))
            for ry in (65, 70):
                for rx in range(cx - 8, cx + 8, 4):
                    p.hline(rx, rx + 2, ry, "steel_dark")
    if belt:
        d.rectangle((14, 76, 66, 79), fill=f(belt))


def khan(p, d, color, tall=False, tail=True):
    """Khăn chít quanh đầu; tall=True: khăn xếp cao (văn quan, nho sĩ)."""
    top = 4 if tall else 9
    for y in range(top, 31):
        for x in range(21, 60):
            dx, dy = (x - 40) / 19.5, (y - (top + 31) / 2) / ((31 - top) / 2 + 0.5)
            if dx * dx + dy * dy <= 1:
                band = (x * 0.5 + y) % 6 if tall else (x + y * 0.6) % 7
                name = color + "_light" if band < 1.2 else color
                if x < 26:
                    name = color
                p.px(x, y, name)
    p.hline(26, 54, 28, color)
    p.hline(26, 54, 29, "ink")
    if tail:
        d.polygon([(22, 18), (12, 26), (10, 36), (18, 28)], fill=rgba(C[color]))


def mu_canh_chuon(p, d):
    """Mũ cánh chuồn (văn quan Lê – Tây Sơn): chỏm tròn đen, hai cánh ngang."""
    f = lambda n: rgba(C[n])  # noqa: E731
    d.ellipse((24, 4, 56, 30), fill=f("khan_den"))
    d.rectangle((24, 18, 56, 30), fill=f("khan_den"))
    d.ellipse((30, 6, 50, 16), fill=f("khan_den_light"))
    d.rectangle((24, 27, 56, 29), fill=f("ink"))
    for x0, x1 in ((6, 24), (56, 74)):                                 # cánh chuồn
        d.ellipse((x0, 14, x1, 22), fill=f("khan_den"))
        d.ellipse((x0 + 2, 15, x1 - 2, 18), fill=f("khan_den_light"))


def ao_quan_thanh(p, d):
    """Áo quan nhà Thanh (cùng nét với chân dung Tôn Sĩ Nghị của bản nháp): bổ tử trước ngực, chuỗi triều châu."""
    f = lambda n: rgba(p.pal[n])  # noqa: E731
    d.polygon([(4, 79), (10, 63), (26, 57), (54, 57), (70, 63), (76, 79)], fill=f("team_dark"))
    d.polygon([(30, 57), (40, 68), (50, 57)], fill=f("team"))
    d.rectangle((28, 66, 52, 79), fill=f("gold"))                # bổ tử
    d.rectangle((30, 68, 50, 79), fill=f("team_light"))
    d.ellipse((35, 70, 45, 78), fill=f("white"))
    for i in range(17):                                            # chuỗi triều châu
        t = i / 16
        bx = round(22 + 36 * t)
        by = round(60 + 16 * math.sin(math.pi * t))
        d.ellipse((bx - 1, by - 1, bx + 1, by + 1), fill=f("coral" if i % 3 else "flower"))


def mu_luong_mao(p, d):
    """Mũ lương mạo tua đỏ của quan nhà Thanh (không lông công: lông công là của Tôn Sĩ Nghị)."""
    f = lambda n: rgba(p.pal[n])  # noqa: E731
    for y in range(6, 28):
        half = 4 + (y - 6) * 1.15
        for x in range(round(40 - half), round(40 + half) + 1):
            ang = (x - 40) / max(1, y - 3)
            p.px(x, y, "tassel" if int(ang * 6 + 20) % 2 else "tassel_dark")
    d.rectangle((14, 26, 66, 29), fill=f("pants_dark"))
    d.line((14, 26, 66, 26), fill=rgba(C["hair_light"]))
    d.rectangle((36, 6, 44, 8), fill=f("gold"))
    d.ellipse((36, 0, 44, 7), fill=f("team_light"))


def portrait(spec):
    img = v2.canvas(80, 80)
    p = Pen(img, spec.get("phe", "tayson"))
    d = ImageDraw.Draw(img)
    if spec["ao"] == "quan_thanh":
        ao_quan_thanh(p, d)
    else:
        robe(p, d, spec["ao"], collar=spec.get("co", "white"), armor=spec.get("giap", False), belt=spec.get("dai"))
    face(p, d, spec.get("rau", "none"), spec.get("may", "thin"), spec.get("tuoi", 0), spec.get("toc", "hair"))
    hat = spec["mu"]
    if hat == "mu_canh_chuon":
        mu_canh_chuon(p, d)
    elif hat == "luong_mao":
        mu_luong_mao(p, d)
    else:
        khan(p, d, hat, tall=spec.get("cao", False), tail=spec.get("duoi", True))
    return outline(img)


# Ngoại hình: hình dung của game (05 §2) — tính cách định hướng nét vẽ.
CHARACTERS = {
    # Thận trọng, chịu trách nhiệm: võ quan trung niên, khăn đen, áo bào chàm sẫm, giáp vai, râu ngắn.
    "ngo_van_so": {"ao": "robe_navy", "mu": "khan_den", "giap": True, "rau": "short", "may": "thick", "tuoi": 1},
    # Điềm tĩnh, lý lẽ: văn quan, mũ cánh chuồn, áo đen, râu dài thưa.
    "ngo_thi_nham": {"ao": "robe_black", "mu": "mu_canh_chuon", "rau": "goatee", "may": "thin", "tuoi": 1, "dai": "gold_dark"},
    # Hăng máu, thẳng tính: võ tướng trẻ, khăn đỏ, áo đỏ, giáp vai, không râu, mày chau.
    "phan_van_lan": {"ao": "robe_red", "mu": "khan_do", "giap": True, "rau": "none", "may": "fierce"},
    # Ẩn sĩ, nói ít: nho sĩ già, khăn xếp đen, áo nâu, râu tóc bạc.
    "nguyen_thiep": {"ao": "robe_brown", "mu": "khan_den", "cao": True, "duoi": False, "rau": "long", "toc": "hair_white",
                     "may": "thin", "tuoi": 2},
    # Táo bạo, giỏi đánh đêm (màn 7): võ tướng, khăn đen, áo đỏ sẫm, giáp vai, râu ngắn, mày chau.
    # Tên và danh tính còn tranh cãi (05 §3): không vẽ theo một nhân vật lịch sử cụ thể nào.
    "do_doc_long": {"ao": "robe_red", "mu": "khan_den", "giap": True, "rau": "short", "may": "fierce", "dai": "gold_dark"},
    # Tri phủ Điền Châu, tử thủ (màn 7): quan nhà Thanh trung niên, mũ lương mạo, râu ngắn. Vẽ trang nghiêm, không chế giễu.
    "sam_nghi_dong": {"phe": "thanh", "ao": "quan_thanh", "mu": "luong_mao", "rau": "short", "may": "thick", "tuoi": 1},
}


def main():
    os.makedirs(OUT, exist_ok=True)
    sheet = Image.new("RGBA", (len(CHARACTERS) * 84 * 4, 84 * 4), (60, 20, 20, 255))
    for i, (key, spec) in enumerate(CHARACTERS.items()):
        im = portrait(spec)
        im.save(os.path.join(OUT, f"portrait_{key}.png"))
        sheet.alpha_composite(im.resize((320, 320), Image.NEAREST), (i * 336 + 8, 8))
    sheet.save(os.path.join(HERE, "_xem_chan_dung.png"))
    print("Đã tạo", len(CHARACTERS), "chân dung trong", OUT)


if __name__ == "__main__":
    main()
