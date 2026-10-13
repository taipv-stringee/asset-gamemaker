#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
gen_placeholders.py — Sinh HÌNH TẠM cho project Godot (godot/assets/), dùng lại bút vẽ của bản nháp
drafts/quang-trung/generate_v2.py. Hình thật sẽ thay đúng tên file (docs/07 §4).

Chạy:   python3 gen_placeholders.py        (cần pillow, numpy)

Kết quả:
    godot/assets/units/unit_<phe>_<ma>_dung_strip2.png   lính 32x32, 2 frame đứng, nhìn sang phải
    godot/assets/tiles/tiles.png + tiles.json            atlas địa hình 32x32 (một hàng), chỉ số theo mã
    godot/assets/ui/*.png                                con trỏ, quân tan, cờ phe
    godot/assets/portraits/portrait_<ma>.png             chân dung 80x80 (tạm)

Theo hướng nghệ thuật đã sửa (docs/07 §2): lính Tây Sơn chít khăn đỏ (không đội nón), quân bắn xa dùng hỏa mai.
"""

import csv
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
DRAFT = os.path.normpath(os.path.join(ROOT, "..", "..", "drafts", "quang-trung"))
sys.path.insert(0, DRAFT)

import generate_assets as v1  # noqa: E402
import generate_v2 as v2       # noqa: E402
from generate_assets import Pen, outline  # noqa: E402

OUT = os.path.join(ROOT, "godot", "assets")
DATA = os.path.join(ROOT, "godot", "data")
T = 32

# Màu phe mới: Lê (vàng đất), Diễn tập (đỏ sẫm)
v1.TEAMS["le"] = {"team_dark": (122, 92, 30), "team": (184, 146, 58), "team_light": (226, 196, 112)}
v1.TEAMS["dien_tap"] = {"team_dark": (78, 20, 26), "team": (124, 36, 40), "team_light": (170, 74, 66)}
v1.TEAMS["trung_lap"] = v1.TEAMS["neutral"]
v1.C.update({"khan_den": (40, 34, 40), "khan_den_light": (78, 70, 76)})

_orig_hat2 = v2.hat2


def hat2(p, kind, y):
    """Thêm các kiểu khăn; 'non' của bản nháp đổi thành khăn đỏ (docs/07: không đội nón)."""
    if kind in ("non", "khan_do", "khan_den"):
        main, light = ("team", "team_light") if kind != "khan_den" else ("khan_den", "khan_den_light")
        for ry, x0, x1 in ((3, 13, 20), (4, 12, 21), (5, 12, 21), (6, 13, 20)):
            for x in range(x0, x1 + 1):
                p.px(x, ry + y, light if (x + ry) % 3 == 0 else main)
        p.hline(14, 19, 2 + y, main)
        p.px(11, 5 + y, main)          # đuôi khăn
        p.px(10, 6 + y, main)
        return
    _orig_hat2(p, kind, y)


v2.hat2 = hat2


def soldier(team, hat, bob, weapon, robe=False, badge=False):
    img = v2.canvas()
    p = Pen(img, team)
    v2.body2(p, bob, wraps=False, robe=robe, badge=badge)
    v2.head2(p, bob)
    hat2(p, hat, bob)
    weapon(p, bob)
    return v2.shadow_under(outline(img))


def w_musket(p, y):
    p.hline(14, 30, 15 + y, "steel_dark")       # nòng
    p.hline(17, 29, 14 + y, "steel")
    p.rect(12, 15 + y, 17, 16 + y, "wood")      # báng
    p.px(18, 16 + y, "wood_dark")
    p.px(16, 13 + y, "fire")                    # mồi dây
    v2.arm(p, y, 18, 15)


def w_short_sword(p, y):
    p.line(22, 15 + y, 26, 9 + y, "steel_light")
    p.hline(21, 23, 16 + y, "gold_dark")
    v2.arm(p, y, 20, 15)


def w_fan(p, y):
    p.rect(22, 11 + y, 26, 14 + y, "white")
    p.line(22, 14 + y, 26, 11 + y, "white_dark")
    v2.arm(p, y, 21, 14)


def w_drum(p, y):
    p.ellipse(22, 20, 5, 4, "wood")
    p.ellipse(22, 17, 5, 1, "white")
    p.hline(17, 27, 20, "team")
    p.line(18, 12 + y, 23, 8 + 2 * y, "wood_dark")
    v2.arm(p, y, 18, 13)


def w_fire_tube(p, y):
    p.hline(15, 27, 15 + y, "bamboo")
    p.hline(15, 27, 14 + y, "bamboo_light")
    p.px(21, 14 + y, "bamboo_dark")
    p.rect(28, 13 + y, 30, 16 + y, "fire")
    p.px(31, 14 + y, "fire_light")
    p.px(29, 12 + y, "fire_dark")
    v2.arm(p, y, 16, 15)


def w_rattan(p, y):
    p.ellipse(23, 17 + y, 5, 6, "straw_dark")
    p.ellipse(23, 17 + y, 4, 5, "straw")
    p.ellipse(23, 17 + y, 1, 1, "team")
    p.line(19, 8 + y, 21, 4 + y, "steel_light")
    v2.arm(p, y, 20, 12)


def w_paddle(p, y):
    p.line(20, 6 + y, 26, 26, "wood")
    p.rect(25, 24, 27, 28, "wood_dark")
    v2.arm(p, y, 21, 14)


def commander(team, hat, bob, beard="short"):
    img = v2.canvas()
    p = Pen(img, team)
    v2.body2(p, bob, cape=True, armor=True, wraps=False)
    v2.head2(p, bob, beard)
    hat2(p, hat, bob)
    y = bob
    p.line(23, 14 + y, 29, 2 + y, "steel_light")
    p.line(24, 14 + y, 30, 2 + y, "steel")
    p.hline(21, 24, 15 + y, "gold")
    v2.arm(p, y, 21, 14)
    return v2.shadow_under(outline(img))


def u(fn):
    return lambda team, b: fn(team, b)


DRAW = {
    "linh_giao": lambda t, b: v2.u_spear(t, "khan_do", b),
    "hoa_mai": lambda t, b: soldier(t, "khan_do", b, w_musket),
    "thuy_binh": lambda t, b: soldier(t, "khan_do", b, w_paddle),
    "quan_su": lambda t, b: soldier(t, "khan_den", b, w_fan, robe=True),
    "trong_tran": lambda t, b: soldier(t, "khan_do", b, w_drum),
    "hoa_ho": lambda t, b: soldier(t, "khan_do", b, w_fire_tube),
    "moc_thuan": lambda t, b: v2.u_shield(t, b),
    "than_cong": lambda t, b: v2.u_cannon(t, b),
    "voi_chien": lambda t, b: v2.u_elephant(t, b),
    "hang_binh": lambda t, b: v2.u_spear(t, "mu", b),
    "truong_mau": lambda t, b: v2.u_spear(t, "mu", b),
    "dieu_thuong": lambda t, b: soldier(t, "mu", b, w_musket, badge=True),
    "cung_tien": lambda t, b: v2.u_ranged(t, "mu", b),
    "dang_bai": lambda t, b: soldier(t, "mu", b, w_rattan, badge=True),
    "phao_binh": lambda t, b: v2.u_cannon(t, b),
    "tho_binh": lambda t, b: v2.u_spear(t, "khan_den", b),
    "trinh_sat": lambda t, b: soldier(t, "mu", b, w_short_sword),
    "quan_le": lambda t, b: v2.u_spear(t, "khan_den", b),
    "quan_giu_don": lambda t, b: commander(t, "mu", b, "long"),
    "quan_giu_don_le": lambda t, b: commander(t, "khan_den", b),
    "quang_trung": lambda t, b: v2.u_commander(t, b, "qt"),
    "ngo_van_so": lambda t, b: commander(t, "khan_den", b),
    "ngo_thi_nham": lambda t, b: soldier(t, "khan_den", b, w_fan, robe=True),
    "phan_van_lan": lambda t, b: commander(t, "khan_do", b, None),
    "do_doc_long": lambda t, b: commander(t, "khan_do", b),
    "do_doc_bao": lambda t, b: v2.u_elephant(t, b),
    "do_doc_tuyet": lambda t, b: commander(t, "khan_do", b, None),
    "do_doc_loc": lambda t, b: commander(t, "khan_do", b),
    "ton_si_nghi": lambda t, b: v2.u_commander(t, b, "tsn"),
    "hua_the_hanh": lambda t, b: commander(t, "mu_quan", b, "long"),
    "sam_nghi_dong": lambda t, b: commander(t, "khan_den", b, "long"),
    "truong_trieu_long": lambda t, b: commander(t, "mu", b, "short"),
    "thuong_duy_thang": lambda t, b: commander(t, "mu", b, "long"),
}

# Phe nào cần hình của loại lính nào
FACTIONS_FOR = {"tayson": ["tayson", "dien_tap"], "thanh": ["thanh"], "le": ["le"]}


# ------------------------------------------------------------------ địa hình mới

def t_de():
    img = v2.t_grass(21, False)
    p = Pen(img)
    p.rect(0, 10, 31, 21, "earth")
    p.hline(0, 31, 10, "earth_light")
    p.hline(0, 31, 21, "earth_dark")
    for x in range(1, 31, 5):
        p.px(x, 14, "grass_light")
    return img


def t_song_can():
    img = v2.t_water(0)
    p = Pen(img)
    for cx, cy in ((6, 6), (16, 12), (25, 7), (10, 22), (22, 25)):
        p.ellipse(cx, cy, 3, 2, "rock")
        p.px(cx - 1, cy - 1, "rock_light")
    p.rect(0, 13, 31, 18, (96, 150, 190))
    return img


def t_cau_phao():
    img = v2.t_water(1)
    p = Pen(img)
    for y in (2, 12, 22):
        p.ellipse(15, y + 4, 12, 3, "wood_dark")
    p.rect(8, 0, 23, 31, "wood")
    for y in range(0, 32, 3):
        p.hline(8, 23, y, "wood_dark")
    return img


def t_dam():
    img = v2.canvas(fill=(60, 84, 70))
    p = Pen(img)
    for cx, cy in ((7, 8), (20, 6), (12, 20), (26, 22)):
        p.ellipse(cx, cy, 4, 2, (44, 66, 70))
    for x, y in ((4, 14), (9, 4), (24, 14), (17, 27), (28, 4)):
        p.vline(x, y - 4, y, "bamboo")
        p.px(x, y - 5, "straw")
    return img


def t_doanh(burnt=False):
    img = v2.t_grass(23, False)
    p = Pen(img)
    if burnt:
        p.ellipse(16, 20, 12, 6, "outline")
        p.ellipse(16, 20, 9, 4, (60, 52, 48))
        for x in (9, 14, 20):
            p.line(x, 22, x + 3, 15, "wood_dark")
        return img
    for i in range(12):
        p.hline(16 - i, 16 + i, 8 + i, "white" if i % 3 else "white_dark")
    p.vline(16, 8, 19, "wood_dark")
    p.rect(14, 15, 18, 19, "outline")
    p.vline(16, 4, 8, "wood_dark")
    return img


def t_luy():
    img = v2.t_grass(24, False)
    p = Pen(img)
    p.ellipse(16, 18, 15, 8, "earth_dark")
    p.ellipse(16, 17, 14, 7, "earth")
    p.ellipse(13, 14, 8, 3, "earth_light")
    for x in range(3, 30, 4):
        p.vline(x, 8, 12, "wood")
        p.px(x, 7, "wood_light")
    return img


def tile_images():
    """Trả về [(khóa, ảnh)]: khóa là mã địa hình, hoặc 'ma:phe' cho ô có chủ."""
    owners = ["trung_lap", "tayson", "dien_tap", "thanh", "le"]
    base = {
        "co": v2.t_grass(), "duong": v2.t_road(), "de": t_de(), "ruong": v2.t_paddy(), "vuon": v2.t_peach(),
        "rung_tre": v2.t_bamboo(), "doi": v2.t_hill(), "nui": v2.t_karst(), "song": v2.t_water(0),
        "song_can": t_song_can(), "cau": v2.t_bridge(), "cau_phao": t_cau_phao(), "dam": t_dam(),
        "doanh": t_doanh(), "doanh_chay": t_doanh(True), "luy": t_luy(),
    }
    out = []
    with open(os.path.join(DATA, "terrain.csv"), encoding="utf-8") as f:
        for row in csv.DictReader(f):
            tid = row["id"]
            if row["so_huu"] == "1":
                for o in owners:
                    fn = {"lang": v2.t_village, "don": v2.t_fort, "thanh": v2.t_castle}[tid]
                    out.append((f"{tid}:{o}", fn(o)))
            else:
                out.append((tid, base[tid]))
    return out


# ------------------------------------------------------------------ giao diện

def ui_cursor():
    img = v2.canvas()
    p = Pen(img)
    for sx in (0, 1):
        for sy in (0, 1):
            x, y = (0, 31)[sx], (0, 31)[sy]
            dx, dy = (1, -1)[sx], (1, -1)[sy]
            for i in range(7):
                p.px(x + dx * i, y, "gold_light")
                p.px(x, y + dy * i, "gold_light")
                p.px(x + dx * i, y + dy, "gold_dark")
                p.px(x + dx, y + dy * i, "gold_dark")
    return img


def ui_quan_tan():
    img = v2.canvas()
    p = Pen(img)
    p.line(8, 26, 20, 10, "wood_dark")                # cán cờ đổ
    p.rect(19, 7, 25, 11, "white_dark")               # cờ rách
    p.px(24, 11, (0, 0, 0, 0))
    p.px(22, 8, "outline")
    p.line(10, 20, 24, 26, "steel")                   # giáo vứt
    p.ellipse(15, 27, 7, 2, (0, 0, 0, 70))
    return outline(img)


def ui_flag(team):
    img = v2.canvas(10, 10)
    p = Pen(img, team)
    p.vline(1, 0, 9, "wood_dark")
    p.rect(2, 0, 8, 4, "team")
    p.hline(2, 8, 0, "team_light")
    return outline(img)


def portraits():
    out = {"quang_trung": v2.portrait("qt"), "ton_si_nghi": v2.portrait("tsn")}
    return out


# ------------------------------------------------------------------ main

def main():
    for sub in ("units", "tiles", "ui", "portraits"):
        os.makedirs(os.path.join(OUT, sub), exist_ok=True)
    count = 0
    with open(os.path.join(DATA, "units.csv"), encoding="utf-8") as f:
        rows = list(csv.DictReader(f))
    for row in rows:
        uid = row["id"]
        if uid not in DRAW:
            print("  ! thiếu hình", uid)
            continue
        for team in FACTIONS_FOR[row["phe"]]:
            if row["phe"] == "tayson" and team == "dien_tap" and "tuong" in row["the"].split() and uid != "quang_trung":
                continue
            img = v2.strip([DRAW[uid](team, 0), DRAW[uid](team, 1)])
            img.save(os.path.join(OUT, "units", f"unit_{team}_{uid}_dung_strip2.png"))
            count += 1
    # quan_giu_don cần cả màu Diễn tập (màn 1)
    img = v2.strip([commander("dien_tap", "khan_den", 0), commander("dien_tap", "khan_den", 1)])
    img.save(os.path.join(OUT, "units", "unit_dien_tap_quan_giu_don_dung_strip2.png"))
    tiles = tile_images()
    atlas = v2.canvas(T * len(tiles), T)
    index = {}
    for i, (key, im) in enumerate(tiles):
        atlas.alpha_composite(im, (i * T, 0))
        index[key] = i
    atlas.save(os.path.join(OUT, "tiles", "tiles.png"))
    with open(os.path.join(OUT, "tiles", "tiles.json"), "w", encoding="utf-8") as f:
        json.dump(index, f, ensure_ascii=False, indent=1)
    ui_cursor().save(os.path.join(OUT, "ui", "cursor.png"))
    ui_quan_tan().save(os.path.join(OUT, "ui", "quan_tan.png"))
    for team in ("tayson", "dien_tap", "thanh", "le"):
        ui_flag(team).save(os.path.join(OUT, "ui", f"flag_{team}.png"))
    for key, im in portraits().items():
        im.save(os.path.join(OUT, "portraits", f"portrait_{key}.png"))
    print(f"{count} dải hình lính, {len(tiles)} ô địa hình")


if __name__ == "__main__":
    main()
