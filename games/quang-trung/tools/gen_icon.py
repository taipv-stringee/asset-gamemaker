#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
gen_icon.py — Biểu tượng ứng dụng "Tây Sơn" (pixel art 64x64, phóng nearest).

Hình: nền sơn mài đỏ – đen, viền vàng; ở giữa là đồng tiền lỗ vuông (motif Quang Trung thông bảo)
có lá cờ đỏ cắm chéo — đọc được ở cỡ 48 px.

Kết quả (godot/assets/icon/):
    icon_1024.png          App Store (không trong suốt, không bo góc — Apple tự bo)
    icon_192.png           Android launcher cũ, và config/icon của project
    icon_fg_432.png        Android adaptive: lớp trước (trong suốt)
    icon_bg_432.png        Android adaptive: lớp nền
    splash.png             màn khởi động (thay logo Godot): huy hiệu + chữ TÂY SƠN trên nền sơn mài sẫm
"""

import os

from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(os.path.dirname(HERE), "godot", "assets", "icon")
N = 64

C = {
    "lac_d": (40, 12, 12), "lac": (92, 24, 22), "lac_l": (128, 38, 30),
    "g_d": (150, 98, 20), "g": (232, 182, 52), "g_l": (255, 232, 140),
    "red_d": (128, 20, 28), "red": (204, 42, 44), "red_l": (246, 104, 84),
    "wood": (110, 70, 40), "ink": (24, 12, 12),
}


def px(img, x, y, c):
    if 0 <= x < img.width and 0 <= y < img.height:
        img.putpixel((x, y), C[c] + (255,) if isinstance(c, str) else c)


def disc(img, cx, cy, r, c):
    for y in range(cy - r, cy + r + 1):
        for x in range(cx - r, cx + r + 1):
            if (x - cx + 0.5) ** 2 + (y - cy + 0.5) ** 2 <= r * r:
                px(img, x, y, c)


def rect(img, x0, y0, x1, y1, c):
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            px(img, x, y, c)


def background(img):
    for y in range(N):
        for x in range(N):
            # sơn mài: chuyển màu tối dần xuống dưới, vân ngang nhẹ
            c = "lac_l" if y < 14 else "lac" if y < 44 else "lac_d"
            if y % 5 == 0 and 10 < y < 54:
                c = "lac_d" if c != "lac_d" else "ink"
            px(img, x, y, c)


def emblem(img, cx=33, cy=34):
    disc(img, cx, cy, 20, "ink")          # viền ngoài
    disc(img, cx, cy, 19, "g_d")
    disc(img, cx, cy, 18, "g")
    disc(img, cx - 3, cy - 3, 12, "g_l")  # ánh sáng góc trên trái
    disc(img, cx, cy, 11, "g")
    disc(img, cx, cy, 10, "g_d")          # vành trong
    disc(img, cx, cy, 9, "g")
    rect(img, cx - 5, cy - 5, cx + 4, cy + 4, "ink")      # lỗ vuông
    rect(img, cx - 4, cy - 4, cx + 3, cy + 3, "lac_d")
    for i in range(4):                    # bốn dấu chấm trên mặt tiền (gợi 4 chữ)
        for dx, dy in ((0, -14), (14, 0), (0, 14), (-14, 0)):
            rect(img, cx + dx - 1, cy + dy - 1, cx + dx + 1, cy + dy + 1, "g_d")
    # lá cờ đỏ cắm chéo qua lỗ vuông
    for t in range(30):
        x, y = cx - 15 + t, cy + 15 - t
        px(img, x, y, "wood")
        px(img, x + 1, y, "ink")
    for row in range(10):                 # cờ đuôi nheo bay về bên phải
        y = cy - 16 + row
        x0 = cx + 14 - (row // 2)
        for x in range(x0, x0 + 14 - abs(row - 5)):
            px(img, x, y, "red" if row > 1 else "red_l")
        px(img, x0 + 14 - abs(row - 5), y, "red_d")


def frame(img):
    for i in range(N):
        for t, c in ((0, "ink"), (1, "g_d"), (2, "g"), (3, "g_d")):
            px(img, i, t, c)
            px(img, i, N - 1 - t, c)
            px(img, t, i, c)
            px(img, N - 1 - t, i, c)


def main():
    os.makedirs(OUT, exist_ok=True)
    full = Image.new("RGBA", (N, N))
    background(full)
    emblem(full)
    frame(full)
    full.resize((1024, 1024), Image.NEAREST).convert("RGB").save(os.path.join(OUT, "icon_1024.png"))
    full.resize((192, 192), Image.NEAREST).save(os.path.join(OUT, "icon_192.png"))
    # Adaptive icon: 108dp, vùng an toàn 66dp ở giữa → biểu tượng chiếm ~60% khung
    bg = Image.new("RGBA", (N, N))
    background(bg)
    bg.resize((432, 432), Image.NEAREST).save(os.path.join(OUT, "icon_bg_432.png"))
    fg_small = Image.new("RGBA", (N, N), (0, 0, 0, 0))
    emblem(fg_small, 32, 32)
    fg = Image.new("RGBA", (432, 432), (0, 0, 0, 0))
    scaled = fg_small.resize((256, 256), Image.NEAREST)
    fg.alpha_composite(scaled, (88, 88))
    fg.save(os.path.join(OUT, "icon_fg_432.png"))
    splash()
    print("Đã tạo biểu tượng trong", OUT)


SPLASH_BG = (41, 13, 13)   # = UiKit.C_LACQUER_DARK; trùng boot_splash/bg_color trong project.godot


def splash():
    """Màn khởi động 480x640: huy hiệu (phóng nguyên số x5) và chữ TÂY SƠN. Nền trùng màu bg_color để liền với phần màn còn lại."""
    img = Image.new("RGB", (480, 640), SPLASH_BG)
    em = Image.new("RGBA", (N, N), (0, 0, 0, 0))
    emblem(em, 32, 32)
    em = em.resize((N * 5, N * 5), Image.NEAREST)
    img.paste(em, ((480 - N * 5) // 2, 90), em)
    font_path = os.path.join(os.path.dirname(OUT), "fonts", "BeVietnamPro-Bold.ttf")
    d = ImageDraw.Draw(img)
    font = ImageFont.truetype(font_path, 64)
    text = "TÂY SƠN"
    w = d.textlength(text, font=font)
    d.text(((480 - w) / 2 + 3, 433), text, font=font, fill=C["ink"])
    d.text(((480 - w) / 2, 430), text, font=font, fill=C["g_l"])
    d.rectangle((140, 530, 340, 532), fill=C["g_d"])
    img.save(os.path.join(OUT, "splash.png"))


if __name__ == "__main__":
    main()
