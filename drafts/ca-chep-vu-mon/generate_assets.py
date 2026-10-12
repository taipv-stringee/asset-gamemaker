#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
generate_assets.py — Tạo toàn bộ hình ảnh pixel art cho game
"Cá chép vượt Vũ Môn" (GameMaker, top-down cuộn dọc).

Cách chạy:
    pip install pillow
    python generate_assets.py

Kết quả nằm trong thư mục assets/:
  - Sprite có animation: dải ngang  tên_stripN.png  (N = số frame)
  - Sprite tĩnh:                    tên.png
  - preview_sheet.png: xem nhanh mọi sprite (phóng to 4x, nền caro)

Quy ước chung:
  - Mọi sinh vật (cá chép, rồng, kẻ địch) đều vẽ ĐẦU HƯỚNG LÊN.
    Trong GameMaker: image_angle = direction - 90.
  - Gốc (origin) của mọi sprite đặt ở GIỮA (Middle Centre).
  - Không làm mờ: chỉ đặt từng điểm ảnh, không anti-alias.
"""

import math
import os
import random

from PIL import Image, ImageFont, ImageDraw

OUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "assets")

# =============================================================================
# 1. BẢNG MÀU CHUNG — mọi sprite chỉ lấy màu từ đây để đồng bộ phong cách
# =============================================================================
PALETTE = {
    # Viền và màu trung tính
    "outline":      (24, 28, 48),    # viền tối 1px (xanh đen)
    "white":        (250, 250, 242),
    "bg":           (232, 240, 230), # nền nhạt
    # Nước
    "water_deep":   (26, 62, 116),
    "water_dark":   (36, 94, 158),
    "water":        (52, 132, 196),
    "water_light":  (100, 184, 224),
    "teal":         (58, 196, 184),
    "foam":         (206, 238, 246),
    # Cá chép (cam - đỏ)
    "carp_dark":    (178, 44, 32),
    "carp":         (234, 94, 40),
    "carp_light":   (252, 166, 86),
    # Vàng (ngọc, rồng, trang trí)
    "gold_dark":    (190, 118, 22),
    "gold":         (244, 190, 44),
    "gold_light":   (255, 236, 140),
    # Rêu, rong, cỏ
    "moss_dark":    (38, 98, 56),
    "moss":         (78, 150, 62),
    "moss_light":   (148, 202, 86),
    # Đá xám xanh
    "stone_dark":   (66, 84, 98),
    "stone":        (110, 130, 140),
    "stone_light":  (160, 180, 182),
    # Gỗ, đất, cát
    "brown_dark":   (92, 56, 36),
    "brown":        (142, 92, 52),
    "brown_light":  (198, 148, 96),
    "sand":         (228, 212, 162),
    "sand_dark":    (192, 168, 116),
    # Kẻ địch: cá dữ xám tím
    "purple_dark":  (76, 64, 104),
    "purple":       (122, 110, 150),
    "purple_light": (174, 166, 196),
    # Đỏ (tim, bờm rồng, cổng)
    "red_dark":     (146, 26, 42),
    "red":          (222, 52, 60),
}


def col(name, alpha=255):
    """Lấy màu RGBA từ bảng màu theo tên."""
    r, g, b = PALETTE[name]
    return (r, g, b, alpha)


def C(c):
    """Cho phép truyền tên màu (chuỗi) hoặc bộ RGBA."""
    return col(c) if isinstance(c, str) else c


# =============================================================================
# 2. CÁC HÀM VẼ CƠ BẢN (đặt từng điểm ảnh, không làm mờ)
#    Quy ước: tâm điểm ảnh (x, y) nằm ở toạ độ nguyên. Ảnh rộng 32 thì tâm
#    ảnh là 15.5 — vẽ quanh 15.5 sẽ cân đối tuyệt đối hai bên.
# =============================================================================
def new(w, h):
    """Tạo ảnh trong suốt."""
    return Image.new("RGBA", (w, h), (0, 0, 0, 0))


def put(img, x, y, c):
    """Đặt 1 điểm ảnh (bỏ qua nếu nằm ngoài khung)."""
    x, y = int(x), int(y)
    if 0 <= x < img.width and 0 <= y < img.height:
        img.putpixel((x, y), C(c))


def put_on(img, x, y, c):
    """Chỉ đặt điểm nếu ở đó đã có màu (dùng để vẽ hoa văn bên trong hình)."""
    x, y = int(x), int(y)
    if 0 <= x < img.width and 0 <= y < img.height and img.getpixel((x, y))[3] > 0:
        img.putpixel((x, y), C(c))


def rect(img, x0, y0, x1, y1, c):
    """Hình chữ nhật đặc (toạ độ bao gồm cả hai đầu)."""
    for y in range(int(y0), int(y1) + 1):
        for x in range(int(x0), int(x1) + 1):
            put(img, x, y, c)


def ellipse(img, cx, cy, rx, ry, c, only_on=False):
    """Elip đặc: điểm ảnh được tô nếu tâm của nó nằm trong elip."""
    f = put_on if only_on else put
    for y in range(math.floor(cy - ry), math.ceil(cy + ry) + 1):
        for x in range(math.floor(cx - rx), math.ceil(cx + rx) + 1):
            if ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 < 1:
                f(img, x, y, c)


def disk(img, cx, cy, r, c, only_on=False):
    """Hình tròn đặc."""
    if r > 0:
        ellipse(img, cx, cy, r, r, c, only_on)


def poly(img, pts, c):
    """Đa giác đặc (kiểm tra tâm từng điểm ảnh nằm trong đa giác)."""
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
                put(img, x, y, c)


def rnd(v):
    """Làm tròn kiểu thông thường (0.5 lên 1), tránh kiểu 'làm tròn ngân hàng'."""
    return int(math.floor(v + 0.5))


def line(img, x0, y0, x1, y1, c, w=1, only_on=False):
    """Đoạn thẳng; w > 1 thì vẽ nét dày bằng các chấm tròn."""
    n = int(max(abs(x1 - x0), abs(y1 - y0)) * 2) + 1
    for i in range(n + 1):
        t = i / n
        x = x0 + (x1 - x0) * t
        y = y0 + (y1 - y0) * t
        if w <= 1:
            (put_on if only_on else put)(img, rnd(x), rnd(y), c)
        else:
            disk(img, x, y, w / 2, c, only_on)


def outline(img, c="outline", diagonal=False, wrap_y=False):
    """Thêm viền 1px: tô mọi điểm trong suốt nằm cạnh điểm có màu.
    wrap_y=True dùng cho tile ghép dọc: coi mép trên và mép dưới nối nhau."""
    c = C(c)
    w, h = img.size
    pix = img.load()
    solid = [[pix[x, y][3] > 0 for x in range(w)] for y in range(h)]
    nbs = [(1, 0), (-1, 0), (0, 1), (0, -1)]
    if diagonal:
        nbs += [(1, 1), (1, -1), (-1, 1), (-1, -1)]
    for y in range(h):
        for x in range(w):
            if solid[y][x]:
                continue
            for dx, dy in nbs:
                nx, ny = x + dx, y + dy
                if wrap_y:
                    ny = ny % h
                if 0 <= nx < w and 0 <= ny < h and solid[ny][nx]:
                    pix[x, y] = c
                    break
    return img


def recolor(img, mapping):
    """Đổi màu theo bảng {tên màu cũ: tên màu mới} (giữ nguyên độ trong suốt)."""
    table = {PALETTE[k]: C(v)[:3] for k, v in mapping.items()}
    pix = img.load()
    for y in range(img.height):
        for x in range(img.width):
            r, g, b, a = pix[x, y]
            if a and (r, g, b) in table:
                pix[x, y] = table[(r, g, b)] + (a,)
    return img


def from_map(rows, colors):
    """Vẽ sprite từ 'bản đồ ký tự' — mỗi ký tự là một điểm ảnh.
    '.' = trong suốt, các ký tự khác tra trong dict colors."""
    img = new(len(rows[0]), len(rows))
    for y, row in enumerate(rows):
        for x, ch in enumerate(row):
            if ch != ".":
                put(img, x, y, colors[ch])
    return img


def body_span(c, hw):
    """Điểm ảnh trái nhất và phải nhất của một hàng thân có tâm c, nửa rộng hw."""
    return math.floor(c - hw) + 1, math.ceil(c + hw) - 1


# =============================================================================
# 3. LƯU FILE + TỰ KIỂM TRA
# =============================================================================
CREATED = []  # danh sách sprite đã tạo, dùng để in báo cáo và ghép preview


def save(name, frames, rotatable=True, edge_check=True, max_colors=6):
    """Ghép các frame thành dải ngang rồi lưu.
    rotatable : sprite có thể xoay -> kiểm tra nội dung nằm gọn trong
                hình tròn nội tiếp (xoay góc nào cũng không bị cắt).
    edge_check: cảnh báo nếu hình chạm mép khung (dấu hiệu bị cắt).
    max_colors: số màu tối đa mỗi frame (tính cả màu viền)."""
    if isinstance(frames, Image.Image):
        frames = [frames]
    n = len(frames)
    fw, fh = frames[0].size
    fname = f"{name}_strip{n}.png" if n > 1 else f"{name}.png"
    sheet = new(fw * n, fh)
    for i, f in enumerate(frames):
        sheet.paste(f, (i * fw, 0))
    sheet.save(os.path.join(OUT_DIR, fname))
    CREATED.append(dict(file=fname, frames=frames, fw=fw, fh=fh, sheet=sheet.size,
                        warnings=check(frames, rotatable, edge_check, max_colors)))


def check(frames, rotatable, edge_check, max_colors):
    """Tự kiểm tra lỗi thường gặp, trả về danh sách cảnh báo."""
    warns = []
    fw, fh = frames[0].size
    cx, cy = (fw - 1) / 2, (fh - 1) / 2
    radius = min(fw, fh) / 2
    for i, f in enumerate(frames):
        pix = f.load()
        colors = set()
        edge = clip = 0
        for y in range(fh):
            for x in range(fw):
                p = pix[x, y]
                if p[3] == 0:
                    continue
                colors.add(p[:3])
                if x in (0, fw - 1) or y in (0, fh - 1):
                    edge += 1
                if math.hypot(x - cx, y - cy) > radius - 0.5:
                    clip += 1
        if not colors:
            warns.append(f"frame {i}: trống")
        if len(colors) > max_colors:
            warns.append(f"frame {i}: {len(colors)} màu (> {max_colors})")
        if edge_check and edge:
            warns.append(f"frame {i}: {edge} điểm chạm mép khung")
        if rotatable and clip:
            warns.append(f"frame {i}: {clip} điểm có thể bị cắt khi xoay")
    return warns


# =============================================================================
# 4. CÁ CHÉP (nhân vật chính, 32x32, đầu hướng lên)
# =============================================================================
def fish_profile(t, kind):
    """Nửa bề rộng thân cá (0..1) theo vị trí t: 0 = mõm, 1 = cuống đuôi."""
    if kind == "pike":  # cá dữ: mõm dài nhọn, thân thẳng
        if t < 0.25:
            return 0.45 + 0.55 * t / 0.25
        if t < 0.55:
            return 1.0
        return 1.0 - (t - 0.55) / 0.45 * 0.65
    # cá chép: đầu tròn, thân bầu, thon dần về đuôi
    if t < 0.35:
        return math.sqrt(max(0.0, 1 - ((0.35 - t) / 0.39) ** 2))
    return 1.0 - (t - 0.35) / 0.65 * 0.72


def draw_fish(img, cx, top, length, max_hw, sway, cols, kind="carp",
              fin_len=3.0, fin_flap=0.0, tail_size=1.0, spine=True):
    """Vẽ một con cá nhìn từ trên xuống (chưa có viền).
    sway: độ uốn mình sang ngang ở cuống đuôi (đơn vị điểm ảnh).
    cols: dict màu 'body', 'dark', 'light', 'fin'.
    Trả về hàm offset(y) và hw(y) để vẽ thêm chi tiết."""
    bottom = top + length

    def offset(y):  # thân uốn dần từ giữa mình ra đuôi
        t = (y - top) / length
        return sway * max(0.0, t - 0.3) ** 2 / 0.49

    def hw(y):
        return max_hw * fish_profile(min(1.0, max(0.0, (y - top) / length)), kind)

    # --- Vây ngực (vẽ trước để thân đè lên) ---
    fy = top + length * 0.40
    for s in (-1, 1):
        bx = cx + offset(fy) + s * (hw(fy) - 1.5)
        flap = fin_flap * s
        poly(img, [(bx, fy - 1.5),
                   (bx + s * (fin_len + 1) + flap, fy + 2.5),
                   (bx + s * (fin_len * 0.5), fy + 4),
                   (bx, fy + 3)], cols["fin"])
    # --- Vây bụng nhỏ ---
    py = top + length * 0.72
    for s in (-1, 1):
        bx = cx + offset(py) + s * (hw(py) - 1)
        poly(img, [(bx, py - 1), (bx + s * fin_len * 0.7, py + 2.5), (bx, py + 2)], cols["fin"])

    # --- Đuôi chẻ đôi, xoay quanh cuống đuôi ---
    ang = sway * 0.16
    tx, ty = cx + offset(bottom), bottom
    shape = [(-1.6, -1.5), (-5.2, 7), (-1.8, 5.6), (0, 4.2), (1.8, 5.6), (5.2, 7), (1.6, -1.5)]
    pts = []
    for dx, dy in shape:
        dx, dy = dx * tail_size, dy * tail_size
        pts.append((tx + dx * math.cos(ang) + dy * math.sin(ang),
                    ty - dx * math.sin(ang) + dy * math.cos(ang)))
    poly(img, pts, cols["fin"])
    # gân giữa đuôi
    line(img, tx, ty, tx + 3.2 * tail_size * math.sin(ang), ty + 3.2 * tail_size * math.cos(ang), cols["dark"])

    # --- Thân: tô từng hàng ---
    for y in range(top, bottom + 1):
        c = cx + offset(y)
        x0, x1 = body_span(c, hw(y))
        for x in range(x0, x1 + 1):
            put(img, x, y, cols["body"])
    # --- Sống lưng / vây lưng: dải tối ở giữa ---
    if spine:
        for y in range(top + int(length * 0.30), top + int(length * 0.92)):
            c = cx + offset(y)
            put(img, math.floor(c), y, cols["dark"])
            put(img, math.ceil(c), y, cols["dark"])
    return offset, hw


CARP_COLS = dict(body="carp", dark="carp_dark", light="carp_light", fin="carp_light")


def draw_carp(sway=0.0, fin_flap=0.0, slim=1.0, top=3, length=18,
              fin_len=3.0, tail_size=1.0, cols=CARP_COLS):
    """Một frame cá chép 32x32."""
    img = new(32, 32)
    cx = 15.5
    offset, hw = draw_fish(img, cx, top, length, 5.2 * slim, sway, cols,
                           fin_len=fin_len, fin_flap=fin_flap, tail_size=tail_size)
    # Đầu sáng hơn (mảng màu nhạt trên đỉnh đầu)
    for y in range(top + 1, top + 5):
        c = cx + offset(y)
        x0, x1 = body_span(c, hw(y) - 1.6)
        for x in range(x0, x1 + 1):
            put(img, x, y, cols["light"])
    # Vảy: vài chấm nhạt so le hai bên sống lưng
    for k, y in enumerate(range(top + 8, top + length - 3, 3)):
        c = cx + offset(y)
        d = 2 if k % 2 == 0 else 3
        if hw(y) > d + 1:
            put(img, math.floor(c) - d, y, cols["light"])
            put(img, math.ceil(c) + d, y, cols["light"])
    outline(img)
    # Mắt: hai chấm tối ở hai bên đầu
    ey = top + 4
    x0, x1 = body_span(cx + offset(ey), hw(ey))
    put(img, x0 + 1, ey, "outline")
    put(img, x1 - 1, ey, "outline")
    # Râu cá chép: 2 sợi vàng ở mõm (đặc trưng của cá chép)
    ry = top + 1
    x0, x1 = body_span(cx, hw(ry))
    for i in range(1, 3):
        put(img, x0 - 1 - i, ry + i, "gold")
        put(img, x1 + 1 + i, ry + i, "gold")
    return img


def make_carp():
    """Cá chép: bơi, lướt nhanh, bị choáng."""
    # --- Bơi: đuôi đung đưa theo hình sin, vây ngực quạt ngược pha ---
    frames = []
    for f in range(4):
        ph = f * math.pi / 2
        frames.append(draw_carp(sway=2.6 * math.sin(ph), fin_flap=1.0 * math.cos(ph)))
    save("spr_carp_swim", frames)

    # --- Lướt: thân thon, dài hơn, vây khép, có vệt nước hai bên ---
    frames = []
    for f in range(4):
        ph = f * math.pi / 2
        img = draw_carp(sway=1.2 * math.sin(ph), slim=0.74, top=2, length=20,
                        fin_len=1.5, fin_flap=-1.0, tail_size=0.9)
        # vệt nước chạy dọc hai bên (dịch xuống mỗi frame)
        for s in (-1, 1):
            x = 15.5 + s * 8.5
            for base in (4, 14):
                y0 = base + (f * 3) % 10
                for k in range(5):
                    put(img, x, y0 + k, "foam")
        # vệt sóng hình chữ V sau đuôi
        for k in range(1, 4):
            if (k + f) % 2 == 0:
                put(img, 15 - k - 1, 26 + k, "foam")
                put(img, 16 + k + 1, 26 + k, "foam")
        frames.append(img)
    save("spr_carp_dash", frames)

    # --- Bị choáng: thân cong, nháy trắng rồi đỏ, sao vàng quanh đầu ---
    white = {k: "white" for k in ("carp", "carp_dark", "carp_light", "gold")}
    red = {"carp": "red", "carp_light": "carp", "carp_dark": "red_dark"}
    frames = []
    for f, mapping in enumerate((white, red)):
        img = recolor(draw_carp(sway=3.0, fin_flap=1.5), mapping)
        stars = [(7, 5), (24, 8)] if f == 0 else [(24, 4), (7, 9)]
        for sx, sy in stars:
            for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)):
                put(img, sx + dx, sy + dy, "gold" if (dx or dy) else "gold_light")
        frames.append(img)
    save("spr_carp_hurt", frames)


# =============================================================================
# 5. RỒNG VÀNG (64x64, 6 frame) — cá chép hoá rồng ở cuối game
# =============================================================================
def draw_dragon(f, n=6):
    img = new(64, 64)
    cx = 31.5
    ph = f * 2 * math.pi / n

    # Đường sống lưng: uốn lượn hình sin, sóng chạy từ đầu xuống đuôi
    def spine(t):
        amp = 8.0 * min(1.0, t / 0.3)
        x = cx + amp * math.sin(2 * math.pi * 1.15 * t - ph)
        y = 17 + 38 * t
        return x, y

    def radius(t):
        return 4.4 * (1 - t) + 1.2 * t

    N = 220
    pts = [(*spine(i / N), radius(i / N)) for i in range(N + 1)]

    # Chân (4 chân, có móng), vẽ trước để thân đè lên
    for tl, side_phase in ((0.18, 0.0), (0.55, math.pi)):
        x, y = spine(tl)
        x2, y2 = spine(tl + 0.01)
        tx, ty = x2 - x, y2 - y
        L = math.hypot(tx, ty)
        tx, ty = tx / L, ty / L
        nx, ny = -ty, tx  # pháp tuyến
        for s in (-1, 1):
            swing = 2.0 * math.sin(ph + side_phase + (0 if s < 0 else math.pi))
            r = radius(tl)
            fx = x + s * nx * (r + 4.5) - tx * swing
            fy = y + s * ny * (r + 4.5) - ty * swing
            line(img, x, y, fx, fy, "gold", w=3)
            disk(img, fx, fy, 1.9, "gold_dark")
            for k in (-1, 0, 1):   # 3 móng vuốt
                put(img, rnd(fx + s * nx * 2 + tx * k * 1.5), rnd(fy + s * ny * 2 + ty * k * 1.5), "gold_dark")

    # Bờm đỏ dọc lưng (các gai nhỏ hai bên)
    for i in range(14, N - 20, 16):
        x, y, r = pts[i]
        for s in (-1, 1):
            disk(img, x + s * (r + 0.6), y + 1, 1.5, "red")
    # Chùm lông đuôi đỏ
    tx, ty, _ = pts[-1]
    poly(img, [(tx - 1, ty - 4), (tx - 5, ty + 2), (tx, ty + 4.5), (tx + 5, ty + 2), (tx + 1, ty - 4)], "red")

    # Thân: chuỗi hình tròn dọc sống lưng
    for x, y, r in pts:
        disk(img, x, y, r, "gold")
    # Vệt sáng bên trái, vảy tối dọc giữa lưng
    for x, y, r in pts:
        disk(img, x - r * 0.45, y, r * 0.35, "gold_light")
    for i, (x, y, r) in enumerate(pts):
        if i > 12 and (i // 6) % 2 == 0:
            put(img, math.floor(x), rnd(y), "gold_dark")
            put(img, math.ceil(x), rnd(y), "gold_dark")

    # Đầu rồng (to, có sừng nhánh và bờm lửa)
    hx = cx
    for s in (-1, 1):
        # bờm đỏ hai bên má (vẽ trước để sừng đè lên)
        disk(img, hx + s * 6.0, 15, 2.6, "red")
        disk(img, hx + s * 4.6, 19, 2.2, "red")
    for s in (-1, 1):
        # sừng chĩa về sau, mỗi bên có một nhánh phụ
        line(img, hx + s * 3, 11, hx + s * 10, 21, "gold_light", w=2.0)
        line(img, hx + s * 6.5, 16, hx + s * 11.5, 12.5, "gold_light", w=1.6)
    ellipse(img, hx, 12, 6.2, 5.6, "gold")         # sọ
    ellipse(img, hx, 6.5, 4.2, 4.4, "gold")        # mõm
    ellipse(img, hx, 4.2, 2.8, 1.8, "gold_light")  # chóp mõm
    ellipse(img, hx - 2.5, 11, 1.8, 3.0, "gold_light")
    rect(img, math.floor(hx), 9, math.ceil(hx), 15, "gold_dark")  # gờ giữa trán
    outline(img)
    # mắt đỏ có điểm sáng, lỗ mũi
    for s in (-1, 1):
        ex = math.floor(hx) - 3 if s < 0 else math.ceil(hx) + 3
        put(img, ex, 10, "red")
        put(img, ex, 9, "red")
        put(img, ex + (1 if s < 0 else -1), 9, "white")
    put(img, math.floor(hx) - 1, 3, "outline")
    put(img, math.ceil(hx) + 1, 3, "outline")
    # râu rồng: hai sợi dài uốn lượn (không viền, màu đỏ)
    for s in (-1, 1):
        for k in range(15):
            wx = hx + s * (4.5 + k * 0.65)
            wy = 4 + k * 0.85 + 1.4 * math.sin(k * 0.6 - ph)
            put(img, rnd(wx), rnd(wy), "red")
    return img


def make_dragon():
    save("spr_dragon", [draw_dragon(f) for f in range(6)])


# =============================================================================
# 6. KẺ ĐỊCH (32x32, 4 frame, đầu hướng lên giống cá chép)
# =============================================================================
PIKE_COLS = dict(body="purple", dark="purple_dark", light="purple_light", fin="purple_light")


def draw_pike(f):
    """Cá dữ: thân dài thon, hai hàm nhọn há ra, răng trắng lởm chởm."""
    img = new(32, 32)
    cx, top, length = 15.5, 7, 16
    ph = f * math.pi / 2
    offset, hw = draw_fish(img, cx, top, length, 3.5, 2.0 * math.sin(ph), PIKE_COLS,
                           kind="pike", fin_len=2.0, fin_flap=0.6 * math.cos(ph),
                           tail_size=0.9, spine=False)
    # Hai hàm nhọn chĩa lên trên; độ há thay đổi theo frame
    gap = [2.2, 1.5, 0.8, 1.5][f]
    poly(img, [(cx - 3.4, 11), (cx - 1.7, 1.8), (cx + 1.7, 1.8), (cx + 3.4, 11)], "purple")
    # khe miệng hình chữ V cắt giữa hai hàm
    for y in range(1, 8):
        half = (0.4 + gap * 0.6) * (8.0 - y) / 6.5
        for x in range(32):
            if abs(x - cx) < half:
                img.putpixel((x, y), (0, 0, 0, 0))
    # Sọc tối ngang lưng
    for t in (0.35, 0.52, 0.69):
        y = rnd(top + length * t)
        x0, x1 = body_span(cx + offset(y), hw(y))
        for x in range(x0 + 1, x1):
            put(img, x, y, "purple_dark")
    # Vây lưng tối ở gần đuôi
    for y in range(rnd(top + length * 0.78), rnd(top + length * 0.98)):
        c = cx + offset(y)
        put(img, math.floor(c), y, "purple_dark")
        put(img, math.ceil(c), y, "purple_dark")
    outline(img)
    # Răng trắng: quét từ giữa ra, điểm thân cá đầu tiên của mỗi hàm là răng
    for y in (4, 6):
        for s in (-1, 1):
            x = math.floor(cx) if s < 0 else math.ceil(cx)
            for _ in range(5):
                if img.getpixel((x, y))[:3] == PALETTE["purple"]:
                    put(img, x, y, "white")
                    break
                x += s
    # Mắt đỏ, mày tối nhìn dữ
    ey = top + 2
    x0, x1 = body_span(cx, hw(ey))
    put(img, x0 + 1, ey, "red")
    put(img, x1 - 1, ey, "red")
    put(img, x0 + 2, ey - 1, "outline")
    put(img, x1 - 2, ey - 1, "outline")
    return img


def draw_otter(f):
    """Rái cá nhìn từ trên: thân dài thon, đầu tròn mặt sáng, 4 chân chèo, đuôi to."""
    img = new(32, 32)
    cx = 15.5
    ph = f * math.pi / 2
    s = math.sin(ph)
    # Đuôi dày, thon dần, vẫy sang hai bên
    for i in range(41):
        t = i / 40
        disk(img, cx + 3.0 * s * t * t, 21 + 8.5 * t, 2.5 * (1 - t) + 0.7 * t, "brown")
    # 4 chân màng: chân trước trái & chân sau phải cùng pha
    for (lx, ly, p) in ((-5.8, 11, 0), (5.8, 11, math.pi), (-5.6, 20, math.pi), (5.6, 20, 0)):
        ellipse(img, cx + lx, ly + 1.6 * math.sin(ph + p), 1.8, 2.2, "brown_dark")
    # Thân dài
    ellipse(img, cx, 15.5, 5.0, 8.2, "brown")
    ellipse(img, cx, 16, 1.2, 5.0, "brown_dark")         # sống lưng sẫm
    # Đầu
    disk(img, cx - 3.8, 4.6, 1.4, "brown_dark")          # tai
    disk(img, cx + 3.8, 4.6, 1.4, "brown_dark")
    disk(img, cx, 7, 4.3, "brown")
    ellipse(img, cx, 5.2, 3.2, 2.3, "brown_light")       # mặt / mõm sáng màu
    outline(img)
    put(img, 15, 3, "outline")   # mũi
    put(img, 16, 3, "outline")
    put(img, 13, 6, "outline")   # mắt
    put(img, 18, 6, "outline")
    put(img, 11, 5, "white")     # ria mép
    put(img, 20, 5, "white")
    return img


def draw_snake(f):
    """Rắn nước xanh: thân uốn lượn chữ S, lưỡi đỏ thè ra thụt vào."""
    img = new(32, 32)
    cx = 15.5
    ph = f * math.pi / 2
    N = 160
    pts = []
    for i in range(N + 1):
        t = i / N
        amp = 5.0 * min(1.0, t / 0.25)
        pts.append((cx + amp * math.sin(2 * math.pi * 1.1 * t - ph), 10 + 19 * t, 2.7 * (1 - t) + 0.7 * t))
    for x, y, r in pts:
        disk(img, x, y, r, "moss")
    # khoanh tối ngang thân
    for i, (x, y, r) in enumerate(pts):
        if i % 28 < 5 and i > 10:
            disk(img, x, y, r, "moss_dark")
    # sọc sáng dọc sống lưng
    for x, y, r in pts:
        disk(img, x, y, 0.6, "moss_light", only_on=True)
    # đầu hơi dẹt, rộng hơn cổ
    hx = cx + 0.8 * math.sin(-ph)
    ellipse(img, hx, 7.5, 3.8, 4.0, "moss")
    ellipse(img, hx, 8.5, 1.6, 1.8, "moss_dark")
    outline(img)
    put(img, rnd(hx - 2.6), 6, "gold")   # mắt vàng
    put(img, rnd(hx + 2.4), 6, "gold")
    if f in (0, 1):  # lưỡi chẻ đôi
        tx = rnd(hx - 0.5)
        put(img, tx, 3, "red")
        put(img, tx + 1, 3, "red")
        put(img, tx - 1, 2, "red")
        put(img, tx + 2, 2, "red")
    return img


def make_enemies():
    save("spr_enemy_pike", [draw_pike(f) for f in range(4)])
    save("spr_enemy_otter", [draw_otter(f) for f in range(4)])
    save("spr_enemy_snake", [draw_snake(f) for f in range(4)])


# =============================================================================
# 7. CHƯỚNG NGẠI VẬT (tĩnh, trừ xoáy nước)
# =============================================================================
def draw_rock(size, R, seed, moss_spots, cracks):
    """Tảng đá: hình tròn méo ngẫu nhiên, chiếu sáng từ trên-trái."""
    rng = random.Random(seed)
    a = [rng.uniform(0, 2 * math.pi) for _ in range(3)]
    img = new(size, size)
    c = (size - 1) / 2

    def edge_r(th):
        return R * (1 + 0.10 * math.sin(3 * th + a[0]) + 0.06 * math.sin(5 * th + a[1])
                    + 0.04 * math.sin(7 * th + a[2]))

    for y in range(size):
        for x in range(size):
            dx, dy = x - c, y - c
            rr = edge_r(math.atan2(dy, dx))
            if math.hypot(dx, dy) < rr:
                nx, ny = dx / rr, dy / rr
                nz = math.sqrt(max(0.0, 1 - nx * nx - ny * ny))
                light = 0.55 * nz + 0.6 * (-0.6 * nx - 0.8 * ny)  # mặt quay về phía trên-trái thì sáng
                put(img, x, y, "stone_light" if light > 0.62 else "stone" if light > 0.1 else "stone_dark")
    # vết nứt
    for _ in range(cracks):
        th = rng.uniform(0, 2 * math.pi)
        x, y = c + math.cos(th) * R * 0.2, c + math.sin(th) * R * 0.2
        for _ in range(3):
            th += rng.uniform(-0.8, 0.8)
            nx, ny = x + math.cos(th) * R * 0.25, y + math.sin(th) * R * 0.25
            line(img, x, y, nx, ny, "stone_dark", only_on=True)
            x, y = nx, ny
    # rêu bám
    for (ang, dist, r) in moss_spots:
        mx, my = c + math.cos(ang) * R * dist, c + math.sin(ang) * R * dist
        for _ in range(7):   # mảng rêu loang lổ = nhiều đốm nhỏ chồng nhau
            ox, oy = rng.uniform(-1, 1) * R * r, rng.uniform(-0.6, 0.6) * R * r
            disk(img, mx + ox, my + oy, R * r * rng.uniform(0.3, 0.55), "moss", only_on=True)
        for _ in range(4):
            put_on(img, rnd(mx + rng.uniform(-1, 1) * R * r * 0.8),
                   rnd(my + rng.uniform(-0.5, 0.5) * R * r), "moss_light")
    return outline(img)


def make_reed():
    """Bụi lau sậy / rong: các lá dài cong ra ngoài, vài bông lau nâu."""
    img = new(32, 48)

    def blade(bx, by, tx, ty, w, c):
        left, right = [], []
        for i in range(13):
            t = i / 12
            x = bx + (tx - bx) * t * t      # lá cong dần ra ngoài
            y = by + (ty - by) * t
            hw = w * (1 - t) / 2 + 0.15
            left.append((x - hw, y))
            right.append((x + hw, y))
        poly(img, left + right[::-1], c)

    ellipse(img, 15.5, 42.5, 9, 3, "moss_dark")       # gốc bụi
    # lá phía sau (tối)
    for bx, tx, ty in ((12, 3, 14), (19, 28, 12), (15, 9, 5), (16, 23, 6)):
        blade(bx, 43, tx, ty, 3.4, "moss_dark")
    # thân bông lau + bông nâu
    for sx, top in ((11.5, 8), (19.5, 4)):
        line(img, sx, 42, sx, top + 6, "moss_dark")
        ellipse(img, sx, top + 3, 1.7, 3.6, "brown")
        put(img, sx - 0.5, top + 1, "brown_light")
    # lá phía trước (sáng)
    for bx, tx, ty, c in ((14, 4, 24, "moss"), (17, 27, 22, "moss"),
                          (15, 12, 14, "moss_light"), (16, 18, 10, "moss")):
        blade(bx, 44, tx, ty, 3.0, c)
    return outline(img)


def make_log():
    """Khúc gỗ trôi (96x32): vỏ nâu, đầu cắt lộ vân gỗ, một cành gãy, rêu."""
    img = new(96, 32)
    rng = random.Random(5)
    jag = [rng.randint(0, 3) for _ in range(32)]   # đầu trái gãy lởm chởm
    for y in range(9, 23):
        x0 = 5 + jag[y]
        for x in range(x0, 87):
            if y in (9, 10):
                c = "brown_light"
            elif y >= 20:
                c = "brown_dark"
            else:
                c = "brown"
            put(img, x, y, c)
    # vân vỏ cây: các vạch tối ngắt quãng
    for y in (12, 15, 18):
        x = 8 + rng.randint(0, 4)
        while x < 82:
            L = rng.randint(4, 10)
            line(img, x, y, x + L, y, "brown_dark")
            x += L + rng.randint(3, 7)
    # mắt gỗ
    ellipse(img, 40, 14.5, 2.6, 1.8, "brown_dark")
    put(img, 40, 14, "brown_light")
    # cành gãy phía trên
    line(img, 58, 10, 64, 4, "brown", w=3)
    disk(img, 64.5, 3.5, 1.4, "sand")
    # đầu phải: mặt cắt có vòng tuổi
    ellipse(img, 86.5, 15.5, 4.2, 7.2, "sand")
    ellipse(img, 86.5, 15.5, 2.8, 4.8, "brown_light")
    ellipse(img, 86.5, 15.5, 1.6, 2.8, "sand")
    put(img, 86, 15, "brown")
    put(img, 87, 16, "brown")
    # rêu trên lưng khúc gỗ
    for x in range(20, 31):
        put(img, x, 9, "moss")
        if 22 <= x <= 28:
            put(img, x, 8, "moss")
    for x in range(70, 76):
        put(img, x, 21, "moss")
    return outline(img)


def draw_whirlpool(f, size=64):
    """Xoáy nước: 3 nhánh xoắn ốc, mỗi frame xoay 30 độ (4 frame = 120 độ = lặp)."""
    img = new(size, size)
    c = (size - 1) / 2
    R = 29.5
    for y in range(size):
        for x in range(size):
            dx, dy = x - c, y - c
            r = math.hypot(dx, dy)
            if r >= R:
                continue
            th = math.atan2(dy, dx)
            v = math.sin(3 * th + 0.32 * r - f * math.pi / 2)  # nhánh xoắn
            if r < 3.5:
                cc = "outline"           # tâm xoáy (hố sâu)
            elif r < 8:
                cc = "water_deep" if v < 0.5 else "water_dark"
            elif v > 0.75:
                cc = "foam" if r > 15 else "water_light"
            elif v > 0.15:
                cc = "water_light" if r > 15 else "water"
            elif v > -0.5:
                cc = "water" if r > 15 else "water_dark"
            else:
                cc = "water_dark" if r > 12 else "water_deep"
            put(img, x, y, cc)
    return outline(img, "water_deep")


def make_obstacles():
    save("spr_rock_small", draw_rock(32, 12.5, seed=3, moss_spots=[(2.4, 0.75, 0.32)], cracks=1))
    save("spr_rock_large", draw_rock(64, 25.0, seed=11,
                                     moss_spots=[(2.2, 0.8, 0.25), (0.9, 0.85, 0.18)], cracks=3))
    save("spr_reed", make_reed(), rotatable=False)
    save("spr_log", make_log(), rotatable=False)
    save("spr_whirlpool", [draw_whirlpool(f) for f in range(4)], max_colors=7)


# =============================================================================
# 8. VẬT PHẨM (24x24, 4 frame)
# =============================================================================
def draw_pearl(size, r, glint):
    """Viên ngọc vàng tròn; glint = độ lớn tia lấp lánh (0 = không có)."""
    img = new(size, size)
    c = (size - 1) / 2
    for y in range(size):
        for x in range(size):
            if math.hypot(x - c, y - c) < r:
                if math.hypot(x - (c - r * 0.35), y - (c - r * 0.35)) < r * 0.42:
                    cc = "gold_light"
                elif math.hypot(x - (c - r * 0.25), y - (c - r * 0.25)) > r * 0.95:
                    cc = "gold_dark"   # mép tối phía dưới - phải
                else:
                    cc = "gold"
                put(img, x, y, cc)
    put(img, rnd(c - r * 0.45), rnd(c - r * 0.45), "white")
    outline(img)
    if glint:
        gx, gy = rnd(c + r * 0.6), rnd(c - r * 0.6)
        put(img, gx, gy, "white")
        for k in range(1, glint + 1):
            for dx, dy in ((k, 0), (-k, 0), (0, k), (0, -k)):
                put(img, gx + dx, gy + dy, "white" if k < glint else "gold_light")
    return img


def draw_energy(f):
    """Giọt nước phát sáng: hình giọt, quầng sáng nhịp đập."""
    img = new(24, 24)
    c, tip, cy, r = 11.5, 3.0, 13.5, 6.4
    for y in range(24):
        if y >= cy:
            hw = math.sqrt(max(0.0, r * r - (y - cy) ** 2))
        elif y >= tip:
            hw = r * ((y - tip) / (cy - tip)) ** 1.3
        else:
            continue
        for x in range(24):
            if abs(x - c) < hw:
                light = math.hypot(x - (c - 2), y - (cy - 1))
                if math.hypot(x - (c - 1.5), y - (cy - 1.5)) > r * 0.95 and x > c - 2 and y > cy - 2:
                    cc = "water_dark"
                elif light < 2.5:
                    cc = "foam"
                else:
                    cc = "teal"
                put(img, x, y, cc)
    put(img, 9, 11, "white")
    put(img, 9, 12, "white")
    put(img, 10, 9, "white")
    outline(img)
    # quầng sáng bên ngoài viền: frame 0 không có, 1 & 3 chấm thưa, 2 đầy đủ
    if f:
        mask = img.copy()
        outline(mask, "teal")
        pix, mp = img.load(), mask.load()
        for y in range(24):
            for x in range(24):
                if pix[x, y][3] == 0 and mp[x, y][3]:
                    if f == 2 or (x + y + f) % 2 == 0:
                        pix[x, y] = col("teal")
    return img


def draw_shield(f):
    """Bong bóng bảo vệ: trong suốt một phần, viền sáng, rung nhẹ."""
    img = new(24, 24)
    c = 11.5
    rx, ry = [(9.0, 9.0), (9.6, 8.4), (9.0, 9.0), (8.4, 9.6)][f]
    for y in range(24):
        for x in range(24):
            d = math.hypot((x - c) / rx, (y - c) / ry)
            if d < 1:
                if d > 0.84:
                    cc = col("foam")
                else:
                    cc = col("water_light", 100)  # bên trong bán trong suốt
                    th = math.degrees(math.atan2(y - c, x - c))
                    if 0.55 < d < 0.75 and -165 < th < -110:
                        cc = col("white")         # vệt phản chiếu
                put(img, x, y, cc)
    put(img, c + 4, c + 3 + (f % 2), "white")
    return outline(img)


def make_items():
    save("spr_pearl", [draw_pearl(24, 7.5, g) for g in (0, 1, 3, 2)])
    save("spr_energy", [draw_energy(f) for f in range(4)])
    save("spr_shield", [draw_shield(f) for f in range(4)])


# =============================================================================
# 9. MÔI TRƯỜNG (tile nước, bờ sông, thác, cổng Vũ Môn, mây)
# =============================================================================
def make_water_tiles():
    """Tile nước 32x32 lặp liền mạch. Hoạ tiết sóng đặt theo toạ độ modulo 32,
    mỗi frame dịch xuống 8px (dòng chảy xuôi) -> 4 frame quay về ban đầu."""
    waves = [(3, 2), (19, 6), (10, 12), (26, 15), (5, 21), (17, 25), (28, 28)]
    glints = [(13, 4), (24, 10), (2, 15), (21, 19), (9, 29)]
    darks = [(7, 8), (29, 3), (14, 18), (24, 23), (1, 27)]
    frames = []
    for f in range(4):
        img = Image.new("RGBA", (32, 32), col("water"))
        sh = f * 8

        def p(x, y, c):
            put(img, x % 32, (y + sh) % 32, c)

        for x, y in darks:
            for k in range(3):
                p(x + k, y, "water_dark")
        for x, y in waves:   # gợn sóng hình vòm ⌒
            for k in range(1, 4):
                p(x + k, y, "water_light")
                p(x + k, y + 1, "water_dark")
            p(x, y + 1, "water_light")
            p(x + 4, y + 1, "water_light")
        for x, y in glints:
            p(x, y, "foam")
            p(x + 1, y, "water_light")
        frames.append(img)
    save("tile_water", frames, rotatable=False, edge_check=False)


def make_bank_tiles():
    """Bờ sông 32x32, ghép dọc liền mạch (mọi chi tiết dùng toạ độ modulo 32).
    Bờ trái vẽ trước, bờ phải là ảnh lật ngang của bờ trái."""
    img = new(32, 32)

    def edge(y):  # mép bờ uốn lượn, chu kỳ 32 để ghép dọc không lộ viền
        return 19 + 2.2 * math.sin(2 * math.pi * y / 32) + 1.2 * math.sin(4 * math.pi * y / 32 + 1.3)

    for y in range(32):
        e = edge(y)
        for x in range(32):
            if x < e - 5 + math.sin(2 * math.pi * y / 16):
                put(img, x, y, "moss")
            elif x < e - 1:
                put(img, x, y, "sand")
            elif x < e:
                put(img, x, y, "sand_dark")
    # hoạ tiết cỏ (toạ độ y modulo 32)
    for x, y in ((3, 2), (9, 9), (2, 15), (11, 22), (5, 27)):
        for dx, dy in ((0, 0), (2, 0), (1, 1)):
            put(img, x + dx, (y + dy) % 32, "moss_dark")
    for x, y in ((7, 5), (1, 11), (8, 18), (4, 24), (12, 30)):
        put(img, x, y, "moss_light")
    put(img, 6, 13, "gold")
    put(img, 2, 20, "gold")
    # sỏi trên bãi cát
    for y in (4, 13, 21, 29):
        x = rnd(edge(y)) - 4
        put(img, x, y, "stone")
        put(img, x + 1, y, "stone")
    outline(img, wrap_y=True)
    # bọt sóng vỗ bờ
    for y in range(32):
        if (y // 3) % 3 != 0:
            x = math.ceil(edge(y)) + 1
            while x < 32 and img.getpixel((x, y))[3]:
                x += 1
            put(img, x, y, "foam")
    save("tile_bank_left", img, rotatable=False, edge_check=False, max_colors=9)
    save("tile_bank_right", img.transpose(Image.FLIP_LEFT_RIGHT),
         rotatable=False, edge_check=False, max_colors=9)


def make_waterfall():
    """Đoạn thác 128x64: các vệt nước chạy xuống (mỗi frame 16px, 4 frame lặp),
    gờ thác sáng ở trên, bọt trắng ở dưới. Lặp liền được theo chiều ngang."""
    W, H = 128, 64
    rng = random.Random(21)
    shade = []
    while len(shade) < W:   # các dải nước dọc rộng 2-5px
        shade += [rng.choice(["water", "water", "water_light", "water_dark"])] * rng.randint(2, 5)
    shade = shade[:W]
    streaks = [(rng.randrange(W), rng.randrange(H), rng.randint(5, 12)) for _ in range(46)]
    blobs = [(rng.randrange(W), rng.uniform(55, 61), rng.uniform(2.5, 4.5)) for _ in range(22)]
    frames = []
    for f in range(4):
        img = new(W, H)
        for y in range(H):
            for x in range(W):
                put(img, x, y, shade[x])
        for sx, sy, L in streaks:
            for k in range(L):
                put(img, sx, (sy + f * 16 + k) % H, "foam" if k > L - 3 else "water_light")
        # gờ thác ở trên
        for x in range(W):
            crest = 2 + rnd(math.sin(2 * math.pi * x / 32))
            for y in range(0, crest + 3):
                put(img, x, y, "foam" if y < crest else "water_light")
            put(img, x, crest + 3, "water_dark")
        # bọt nước ở chân thác (vẽ cả bản sao ±W để lặp ngang)
        for i, (bx, by, r) in enumerate(blobs):
            rr = r + [0, 0.8, 1.6, 0.8][(f + i) % 4]
            for ox in (-W, 0, W):
                disk(img, bx + ox, by, rr, "foam")
                disk(img, bx + ox - 0.8, by - 0.8, rr * 0.55, "white")
        for y in range(61, 64):
            for x in range(W):
                put(img, x, y, "foam")
        frames.append(img)
    save("spr_waterfall", frames, rotatable=False, edge_check=False, max_colors=6)


# Phông chữ 5x7 tí hon cho tấm biển "VŨ MÔN"
FONT = {
    "V": ["X...X", "X...X", "X...X", "X...X", ".X.X.", ".X.X.", "..X.."],
    "U": ["X...X", "X...X", "X...X", "X...X", "X...X", "X...X", ".XXX."],
    "M": ["X...X", "XX.XX", "X.X.X", "X.X.X", "X...X", "X...X", "X...X"],
    "O": [".XXX.", "X...X", "X...X", "X...X", "X...X", "X...X", ".XXX."],
    "N": ["X...X", "XX..X", "X.X.X", "X.X.X", "X..XX", "X...X", "X...X"],
}
ACCENT = {"~": [".XX.X", "X.XX."], "^": ["..X..", ".X.X."]}


def draw_text(img, x, y, text, c):
    """Vẽ chữ; mỗi ký tự là (chữ, dấu) ví dụ ('U', '~') = Ũ."""
    for ch, acc in text:
        if ch == " ":
            x += 3
            continue
        if acc:
            for dy, row in enumerate(ACCENT[acc]):
                for dx, v in enumerate(row):
                    if v == "X":
                        put(img, x + dx, y + dy, c)
        for dy, row in enumerate(FONT[ch]):
            for dx, v in enumerate(row):
                if v == "X":
                    put(img, x + dx, y + 3 + dy, c)
        x += 6


def make_gate():
    """Cổng Vũ Môn 192x128: hai cột đá có câu đối, xà đỏ, biển 'VŨ MÔN',
    mái ngói xanh cong vút kiểu đình Việt, trên nóc 'lưỡng long chầu nguyệt'."""
    W, H = 192, 128
    img = new(W, H)
    cx = (W - 1) / 2
    rng = random.Random(8)

    # --- Hai cột đá ---
    for s in (-1, 1):
        def X(x):  # đổi toạ độ cột trái sang cột phải (đối xứng)
            return x if s < 0 else W - 1 - x
        for x in range(22, 46):
            c = "stone_light" if x < 25 else "stone_dark" if x > 42 else "stone"
            for y in range(48, 113):
                put(img, X(x), y, c)
        rect(img, min(X(18), X(49)), 112, max(X(18), X(49)), 121, "stone")       # chân cột
        rect(img, min(X(16), X(51)), 122, max(X(16), X(51)), 125, "stone_dark")
        rect(img, min(X(18), X(49)), 112, max(X(18), X(49)), 113, "stone_light")
        # bảng câu đối đỏ trên cột với các "chữ" vàng
        rect(img, min(X(29), X(38)), 60, max(X(29), X(38)), 106, "red_dark")
        for gy in range(62, 102, 8):
            for _ in range(5):
                gx = rng.randint(31, 35)
                yy = gy + rng.randint(0, 5)
                if rng.random() < 0.5:
                    line(img, X(gx), yy, X(gx + 2), yy, "gold")
                else:
                    line(img, X(gx + 1), yy, X(gx + 1), yy + 2, "gold")

    # --- Xà ngang đỏ ---
    rect(img, 14, 47, W - 15, 56, "carp_dark")
    rect(img, 14, 47, W - 15, 47, "gold_dark")
    rect(img, 14, 56, W - 15, 56, "red_dark")
    # --- Biển "VŨ MÔN" ---
    rect(img, 68, 51, 123, 70, "gold")
    rect(img, 70, 53, 121, 68, "red_dark")
    draw_text(img, 81, 56, [("V", ""), ("U", "~"), (" ", ""), ("M", ""), ("O", "^"), ("N", "")], "gold_light")

    # --- Mái ngói cong ---
    def bottom(dx):   # mép dưới mái, cong vút lên ở hai đầu (đầu đao)
        return 46 - (20 * ((dx - 64) / 28) ** 2 if dx > 64 else 0)

    def thick(dx):
        return 28 if dx < 48 else 28 - 24 * (dx - 48) / 44

    for x in range(W):
        dx = abs(x - cx)
        if dx > 92:
            continue
        yb = rnd(bottom(dx))
        yt = rnd(bottom(dx) - thick(dx))
        for y in range(yt, yb + 1):
            if y >= yb - 1:
                c = "gold_dark"                       # viền mép mái
            elif y <= yt + 2 and dx < 56:
                c = "moss_dark"                       # bờ nóc
            elif (yb - y) % 5 == 0:
                c = "moss_dark"                       # hàng ngói
            elif x % 6 == 0:
                c = "moss_light"                      # ngói ống
            else:
                c = "moss"
            put(img, x, y, c)
    # --- Trang trí nóc: hai rồng chầu mặt nguyệt ---
    for s in (-1, 1):
        for i in range(60):
            t = i / 59
            dx = 12 + 38 * t
            y = 13 - 3 * math.sin(t * 2 * math.pi) - (4 * (t - 0.85) / 0.15 if t > 0.85 else 0)
            disk(img, cx + s * dx, y, 1.8 if t < 0.15 else 1.3, "gold")
        disk(img, cx + s * 11, 11, 2.6, "gold")       # đầu rồng
        disk(img, cx + s * 91, 15, 1.8, "gold")       # trang trí đầu đao
    disk(img, cx, 8, 5.5, "gold")                     # mặt nguyệt (viên ngọc)
    disk(img, cx - 1.5, 6.5, 2.2, "gold_light")
    outline(img)
    put(img, rnd(cx - 11), 10, "red")                 # mắt rồng
    put(img, rnd(cx + 11), 10, "red")
    save("spr_gate", img, rotatable=False, max_colors=14)


def make_cloud():
    """Mây trắng 96x48: ghép nhiều hình tròn, bóng xanh nhạt ở phía dưới."""
    img = new(96, 48)
    bumps = [(22, 30, 11), (38, 21, 14), (57, 18, 13), (72, 27, 12), (48, 31, 12), (82, 33, 8)]

    def inside(x, y, ox=0, oy=0):
        if y + oy > 41:
            return False
        return any(math.hypot(x + ox - bx, y + oy - by) < r for bx, by, r in bumps)

    for y in range(48):
        for x in range(96):
            if inside(x, y):
                if not inside(x, y, 0, 3) or y > 37:
                    c = "foam"            # bóng phía dưới mỗi cụm
                elif not inside(x, y, 1, -2):
                    c = "bg"              # mép phải hơi xám
                else:
                    c = "white"
                put(img, x, y, c)
    save("spr_cloud", outline(img, "water_dark"), rotatable=False, max_colors=4)


def make_environment():
    make_water_tiles()
    make_bank_tiles()
    make_waterfall()
    make_gate()
    make_cloud()


# =============================================================================
# 10. HIỆU ỨNG
# =============================================================================
def draw_splash(f):
    """Bắn nước nhìn từ trên: vòng sóng loang rộng dần + giọt nước văng ra."""
    img = new(32, 32)
    c = 15.5
    ring_r, ring_w, drop_d, drop_r, gap = [
        (4.5, 2.2, 0, 0, 0),
        (7.5, 2.0, 10.5, 1.4, 0),
        (10.5, 1.6, 12.5, 1.0, 0.6),
        (12.5, 1.2, 13.5, 0.8, 0.3),
        (13.5, 1.0, 0, 0, -0.2),
    ][f]
    for y in range(32):
        for x in range(32):
            d = math.hypot(x - c, y - c)
            th = math.atan2(y - c, x - c)
            if ring_r - ring_w <= d < ring_r and math.sin(6 * th + f) < 1 - gap * 1.5 + 0.5:
                put(img, x, y, "foam" if d > ring_r - ring_w * 0.5 else "water_light")
    if f == 0:
        disk(img, c, c, 2.2, "water_light")
    if drop_r:
        for k in range(8):
            a = k * math.pi / 4 + 0.39
            disk(img, c + math.cos(a) * drop_d, c + math.sin(a) * drop_d, drop_r, "white")
    if f == 4:   # các chấm bọt cuối cùng tan dần
        for k in range(6):
            a = k * math.pi / 3 + 0.2
            put(img, rnd(c + math.cos(a) * 11), rnd(c + math.sin(a) * 11), "foam")
    return outline(img, "water_dark")


def draw_bubble(f):
    """Bong bóng nhỏ 16x16: nhỏ -> to -> vỡ."""
    img = new(16, 16)
    c = 7.5
    if f < 2:
        r = 2.8 if f == 0 else 4.6
        for y in range(16):
            for x in range(16):
                d = math.hypot(x - c, y - c)
                if d < r:
                    put(img, x, y, col("foam") if d > r - 1.1 else col("water_light", 110))
        put(img, rnd(c - r * 0.45), rnd(c - r * 0.45), "white")
        if f == 1:
            put(img, rnd(c - r * 0.45) + 1, rnd(c - r * 0.45), "white")
    else:
        for k in range(6):   # bóng vỡ: các mảnh văng ra
            a = k * math.pi / 3 + 0.5
            put(img, rnd(c + math.cos(a) * 5), rnd(c + math.sin(a) * 5), "foam")
            put(img, rnd(c + math.cos(a) * 3.5), rnd(c + math.sin(a) * 3.5), "white")
    return outline(img, "water_dark")


def draw_sparkle(f):
    """Tia sáng 4 cánh khi nhặt ngọc: lớn lên rồi tan thành chấm."""
    img = new(24, 24)
    c = 11.5
    L = [4.0, 9.0, 6.5, 0][f]

    def star(x, y, L):  # hình sao 4 cánh (đường cong astroid)
        return abs(x - c) ** 0.6 + abs(y - c) ** 0.6 < L ** 0.6

    for y in range(24):
        for x in range(24):
            if L and star(x, y, L):
                put(img, x, y, "white" if star(x, y, L * 0.4) else "gold_light")
    if f >= 2:   # chấm nhỏ bay ra theo đường chéo
        d = 6 if f == 2 else 7.5
        for sx in (-1, 1):
            for sy in (-1, 1):
                put(img, rnd(c + sx * d), rnd(c + sy * d), "gold_light")
                if f == 3:
                    put(img, rnd(c + sx * d * 0.5), rnd(c + sy * d * 0.5), "white")
    return outline(img, "gold_dark")


def make_effects():
    save("spr_splash", [draw_splash(f) for f in range(5)])
    save("spr_bubble", [draw_bubble(f) for f in range(3)])
    save("spr_sparkle", [draw_sparkle(f) for f in range(4)])


# =============================================================================
# 11. GIAO DIỆN (UI)
# =============================================================================
HEART = [
    "................",
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
]


def make_ui():
    full = {"o": "outline", "r": "red", "R": "red_dark", "w": "white"}
    empty = {"o": "outline", "r": "stone_dark", "R": "stone_dark", "w": "stone"}
    save("spr_heart_full", from_map(HEART, full), rotatable=False, edge_check=False)
    save("spr_heart_empty", from_map(HEART, empty), rotatable=False, edge_check=False)
    save("spr_icon_pearl", draw_pearl(16, 5.6, 0), rotatable=False)

    # Khung thanh năng lượng 96x12 (bo góc 1px)
    bg = new(96, 12)
    rect(bg, 1, 0, 94, 11, "outline")
    rect(bg, 0, 1, 95, 10, "outline")
    rect(bg, 1, 1, 94, 10, "stone")
    rect(bg, 1, 1, 94, 1, "stone_light")
    rect(bg, 1, 10, 94, 10, "stone_dark")
    rect(bg, 2, 2, 93, 9, "outline")
    rect(bg, 3, 3, 92, 8, "water_deep")
    for k in range(1, 4):   # vạch chia 1/4
        put(bg, 3 + rnd(90 * k / 4), 8, "water_dark")
        put(bg, 3 + rnd(90 * k / 4), 7, "water_dark")
    save("spr_bar_energy_bg", bg, rotatable=False, edge_check=False)

    # Phần đổ đầy: cùng kích thước 96x12, chỉ tô vùng bên trong (x 3..92, y 3..8)
    # -> trong GameMaker dùng draw_sprite_part để cắt theo % năng lượng.
    fill = new(96, 12)
    for y in range(3, 9):
        for x in range(3, 93):
            if y == 3:
                c = "foam"
            elif y == 8:
                c = "water_dark"
            elif (x + y) % 8 in (0, 1):
                c = "water_light"   # sọc chéo lấp lánh
            else:
                c = "teal"
            put(fill, x, y, c)
    save("spr_bar_energy_fill", fill, rotatable=False, edge_check=False)


# =============================================================================
# 12. TRANG XEM TRƯỚC (preview_sheet.png)
# =============================================================================
def make_preview(scale=4):
    """Ghép mọi sprite (từng frame tách rời) trên nền caro xám, phóng to 4x."""
    try:
        font = ImageFont.load_default(size=16)
    except TypeError:          # Pillow cũ không hỗ trợ size
        font = ImageFont.load_default()
    pad, gap, label_h, max_w = 16, 6, 24, 2300
    # xếp chỗ từng sprite theo hàng
    blocks, x, y, row_h = [], pad, pad, 0
    for e in CREATED:
        n = len(e["frames"])
        bw = n * e["fw"] * scale + (n - 1) * gap
        bh = e["fh"] * scale + label_h
        if x + bw > max_w and x > pad:
            x, y = pad, y + row_h + pad
            row_h = 0
        blocks.append((e, x, y))
        x += max(bw, 260) + pad * 2
        row_h = max(row_h, bh)
    W = max_w + pad
    H = y + row_h + pad
    sheet = Image.new("RGB", (W, H), (52, 54, 62))
    draw = ImageDraw.Draw(sheet)
    cell = 8
    for e, bx, by in blocks:
        draw.text((bx, by), f"{e['file']}  ({e['fw']}x{e['fh']})", fill=(240, 240, 240), font=font)
        fy = by + label_h
        for i, fr in enumerate(e["frames"]):
            fx = bx + i * (e["fw"] * scale + gap)
            fw, fh = e["fw"] * scale, e["fh"] * scale
            # nền caro xám để thấy rõ vùng trong suốt
            bgc = Image.new("RGBA", (fw, fh))
            bd = ImageDraw.Draw(bgc)
            for cy in range(0, fh, cell):
                for cx in range(0, fw, cell):
                    shade = 168 if (cx // cell + cy // cell) % 2 else 140
                    bd.rectangle([cx, cy, cx + cell - 1, cy + cell - 1], fill=(shade, shade, shade, 255))
            big = fr.resize((fw, fh), Image.NEAREST)   # phóng to giữ nét pixel
            bgc.alpha_composite(big)
            sheet.paste(bgc.convert("RGB"), (fx, fy))
    sheet.save(os.path.join(OUT_DIR, "preview_sheet.png"))
    return sheet.size


# =============================================================================
# 13. CHƯƠNG TRÌNH CHÍNH
# =============================================================================
def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    make_carp()
    make_dragon()
    make_enemies()
    make_obstacles()
    make_items()
    make_environment()
    make_effects()
    make_ui()
    pw, ph = make_preview()

    print(f"Đã tạo {len(CREATED)} sprite trong {OUT_DIR}:")
    print(f"  {'Tên file':34s} {'Ảnh':>9s}  {'Frame':>5s}  Cỡ frame")
    n_warn = 0
    for e in CREATED:
        n = len(e["frames"])
        print(f"  {e['file']:34s} {e['sheet'][0]:>4d}x{e['sheet'][1]:<4d}  {n:>5d}  {e['fw']}x{e['fh']}")
        for w in e["warnings"]:
            print(f"      ! {w}")
            n_warn += 1
    print(f"  {'preview_sheet.png':34s} {pw:>4d}x{ph:<4d}")
    print("Không có cảnh báo." if n_warn == 0 else f"Có {n_warn} cảnh báo (xem dấu !).")


if __name__ == "__main__":
    main()
