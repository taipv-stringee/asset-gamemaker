#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Kiểm tra tĩnh code GML của project (không cần GameMaker):
- cân ngoặc (), [], {} trong từng file
- tên spr_/obj_/rm_/ts_ dùng trong code phải tồn tại trong project
- hàm được gọi phải là hàm tự viết (trong scripts) hoặc nằm trong danh sách hàm có sẵn của GML
- giá trị enum (PSTATE.X, ESTATE.X, HERO.X) phải được khai báo
"""
import os, re, sys, json

HERE = os.path.dirname(os.path.abspath(__file__))
PROJ = os.path.join(HERE, "DietRong")

BUILTINS = set("""
abs angle_difference array_contains array_length array_push ceil choose clamp collision_line
camera_set_view_pos device_mouse_x_to_gui device_mouse_y_to_gui display_set_gui_size distance_to_object
draw_circle draw_circle_colour draw_ellipse draw_point draw_rectangle draw_self draw_set_alpha draw_set_colour
draw_set_font draw_set_halign draw_set_valign draw_sprite draw_sprite_ext draw_sprite_part draw_text
draw_text_ext event_inherited event_user floor font_add game_end gpu_set_blendmode gpu_set_fog ini_close
ini_open ini_read_real ini_write_real instance_create_depth instance_create_layer instance_destroy
instance_exists instance_nearest instance_number instance_place irandom irandom_range keyboard_check
keyboard_check_pressed layer_tilemap_get_id lengthdir_x lengthdir_y lerp make_colour_rgb max min
mouse_check_button mouse_check_button_pressed mouse_wheel_down mouse_wheel_up mp_grid_add_instances
mp_grid_clear_cell mp_grid_create mp_grid_destroy mp_grid_path ord path_add path_delete path_end path_start
place_meeting point_direction point_distance point_in_rectangle random random_range random_set_seed
randomize room_goto room_restart round sign sin cos sprite_get_width sprite_get_xoffset string tilemap_get
variable_global_exists window_set_cursor
""".split())
KEYWORDS = set("if else for while repeat switch case break continue return exit with function var new do until default and or not".split())

def strip(code):
    """Bỏ chú thích và chuỗi để kiểm tra cú pháp."""
    code = re.sub(r"/\*.*?\*/", "", code, flags=re.S)
    code = re.sub(r'"(\\.|[^"\\])*"', '""', code)
    code = re.sub(r"//[^\n]*", "", code)
    return code

files = []
for root, _, fs in os.walk(PROJ):
    for f in fs:
        if f.endswith(".gml"):
            files.append(os.path.join(root, f))
resources = set()
yyp = open(os.path.join(PROJ, "DietRong.yyp"), encoding="utf-8").read()
for m in re.finditer(r'"name":"([a-zA-Z0-9_]+)","path":"(sprites|objects|rooms|tilesets|scripts)/', yyp):
    resources.add(m.group(1))

funcs, enums, macros = set(), {}, set()
for p in files:
    c = strip(open(p, encoding="utf-8").read())
    funcs |= set(re.findall(r"\bfunction\s+(\w+)\s*\(", c))
    for m in re.finditer(r"\benum\s+(\w+)\s*\{([^}]*)\}", c):
        enums[m.group(1)] = {x.strip().split("=")[0].strip() for x in m.group(2).split(",") if x.strip()}
    macros |= set(re.findall(r"#macro\s+(\w+)", c))
    # các method gán trong object: ten = function(...)
    funcs |= set(re.findall(r"\b(\w+)\s*=\s*function\s*\(", c))

errors = 0
def err(p, msg):
    global errors
    errors += 1
    print(f"  {os.path.relpath(p, HERE)}: {msg}")

for p in sorted(files):
    raw = open(p, encoding="utf-8").read()
    c = strip(raw)
    stack = []
    pairs = {")": "(", "]": "[", "}": "{"}
    for i, ch in enumerate(c):
        if ch in "([{":
            stack.append((ch, i))
        elif ch in ")]}":
            if not stack or stack[-1][0] != pairs[ch]:
                err(p, f"ngoặc '{ch}' không khớp ở dòng {c[:i].count(chr(10)) + 1}")
                break
            stack.pop()
    if stack:
        err(p, f"thiếu đóng ngoặc '{stack[-1][0]}' (mở ở dòng {c[:stack[-1][1]].count(chr(10)) + 1})")
    for name in set(re.findall(r"\b((?:spr|obj|rm|ts)_\w+)", c)):
        if name not in resources:
            err(p, f"không có tài nguyên '{name}'")
    for name in set(re.findall(r"(?<![\.\w])([A-Za-z_]\w*)\s*\(", c)):
        if name in KEYWORDS or name in funcs or name in BUILTINS:
            continue
        err(p, f"hàm lạ '{name}()' (chưa định nghĩa / không có trong danh sách hàm có sẵn)")
    for m in re.finditer(r"\b(PSTATE|ESTATE|HERO)\.(\w+)", c):
        if m.group(2) not in enums.get(m.group(1), ()):
            err(p, f"enum {m.group(1)} không có '{m.group(2)}'")
    # dấu chấm phẩy thiếu sau gán đơn giản ở cuối dòng (cảnh báo nhẹ)
    for ln_no, ln in enumerate(c.split("\n"), 1):
        s = ln.strip()
        if re.match(r"^[\w\.\[\]]+\s*(=|\+=|-=|\*=)\s*[^;{]+$", s) and not s.endswith((",", "(", "[", "&&", "||", "+", "?", ":")):
            err(p, f"dòng {ln_no} có thể thiếu ';': {s}")

print(f"{len(files)} file GML, {len(funcs)} hàm tự viết, {len(resources)} tài nguyên.")
print("Không thấy lỗi." if errors == 0 else f"{errors} vấn đề cần xem.")
sys.exit(1 if errors else 0)
