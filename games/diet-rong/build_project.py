#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build_project.py — Dựng project GameMaker "DietRong" từ:
    assets/            (do generate_assets.py vẽ ra)
    maps/levelN.txt    (bản đồ ASCII của từng màn)
    DietRong/objects/**.gml, DietRong/scripts/**.gml  (code GML viết tay)

Script này tạo / ghi đè các file .yy (sprite, object, script, room, tileset, project),
cắt dải ảnh thành từng frame, và vẽ ảnh xem trước bản đồ vào maps/preview_levelN.png.
Code GML không bị đụng tới.

Chạy:
    python generate_assets.py      # (khi sửa hình)
    python build_project.py        # (khi sửa bản đồ, thêm object / sự kiện)
Lưu ý: room được tạo lại từ maps/*.txt, nên chỉnh room trong GameMaker sẽ bị ghi đè
khi chạy lại script — muốn giữ thì sửa bản đồ trong file .txt.
"""

import hashlib
import json
import os
import random
import re
import shutil
import uuid

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ASSETS = os.path.join(HERE, "assets")
MAPS = os.path.join(HERE, "maps")
TEMPLATE = os.path.join(HERE, "template")
NAME = "DietRong"
TITLE = "Truyền Thuyết Diệt Rồng"
PROJ = os.path.join(HERE, NAME)
IDE_VERSION = "2026.0.0.16"
TS = 32

# =============================================================================
# 1. GHI JSON KIỂU GAMEMAKER (có dấu phẩy cuối, mỗi khoá cấp 1 một dòng)
# =============================================================================
def gm_value(v):
    if isinstance(v, dict):
        return "{" + "".join(f"{json.dumps(k, ensure_ascii=False)}:{gm_value(x)}," for k, x in v.items()) + "}"
    if isinstance(v, list):
        return "[" + "".join(f"{gm_value(x)}," for x in v) + "]"
    return json.dumps(v, ensure_ascii=False)


def gm_dump(obj):
    lines = ["{"]
    for k, v in obj.items():
        if isinstance(v, list) and v and isinstance(v[0], dict):
            inner = "".join(f"    {gm_value(x)},\n" for x in v)
            lines.append(f"  {json.dumps(k, ensure_ascii=False)}:[\n{inner}  ],")
        else:
            lines.append(f"  {json.dumps(k, ensure_ascii=False)}:{gm_value(v)},")
    lines.append("}")
    return "\n".join(lines)


def write(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)


def uid(*parts):
    """UUID cố định theo tên (chạy lại không đổi -> git diff gọn)."""
    return str(uuid.uuid5(uuid.NAMESPACE_URL, "dietrong/" + "/".join(map(str, parts))))


def ref(name, kind):
    return {"name": name, "path": f"{kind}/{name}/{name}.yy"}


FOLDERS = []          # thư mục trong cây tài nguyên của GameMaker
RESOURCES = []        # mọi tài nguyên của project


def folder(path):
    """'Sprites/heroes' -> tham chiếu thư mục (tạo nếu chưa có)."""
    parts = path.split("/")
    for i in range(1, len(parts) + 1):
        p = "/".join(parts[:i])
        if p not in FOLDERS:
            FOLDERS.append(p)
    return {"name": parts[-1], "path": f"folders/{path}.yy"}


# =============================================================================
# 2. SPRITE
# =============================================================================
SPRITE_FOLDER = {"heroes": "Sprites/heroes", "enemies": "Sprites/enemies", "boss": "Sprites/boss",
                 "weapons": "Sprites/weapons", "projectiles": "Sprites/projectiles", "fx": "Sprites/fx",
                 "items": "Sprites/items", "world": "Sprites/world", "ui": "Sprites/ui", "tiles": "Tile Sets"}


def build_sprite(meta, frames):
    name, w, h = meta["name"], meta["w"], meta["h"]
    d = os.path.join(PROJ, "sprites", name)
    if os.path.isdir(d):
        shutil.rmtree(d)
    layer_id = uid(name, "layer")
    frame_ids = [uid(name, "frame", i) for i in range(len(frames))]
    for fid, im in zip(frame_ids, frames):
        os.makedirs(os.path.join(d, "layers", fid), exist_ok=True)
        im.save(os.path.join(d, fid + ".png"))
        im.save(os.path.join(d, "layers", fid, layer_id + ".png"))
    l, t, r, b = meta["mask"]
    ox, oy = meta["origin"]
    origin_kind = 4 if (ox, oy) == (w // 2, h // 2) else 0 if (ox, oy) == (0, 0) else 9
    path = f"sprites/{name}/{name}.yy"
    keyframes = [{"$Keyframe<SpriteFrameKeyframe>": "", "Channels": {"0": {
        "$SpriteFrameKeyframe": "", "Id": {"name": fid, "path": path},
        "resourceType": "SpriteFrameKeyframe", "resourceVersion": "2.0"}},
        "Disabled": False, "id": uid(name, "key", i), "IsCreationKey": False, "Key": float(i), "Length": 1.0,
        "resourceType": "Keyframe<SpriteFrameKeyframe>", "resourceVersion": "2.0", "Stretch": False}
        for i, fid in enumerate(frame_ids)]
    yy = {
        "$GMSprite": "v2", "%Name": name,
        "bboxMode": 2, "bbox_bottom": b, "bbox_left": l, "bbox_right": r, "bbox_top": t,
        "collisionKind": 1, "collisionTolerance": 0, "DynamicTexturePage": False, "edgeFiltering": False,
        "For3D": False,
        "frames": [{"$GMSpriteFrame": "v1", "%Name": fid, "name": fid, "resourceType": "GMSpriteFrame",
                    "resourceVersion": "2.0"} for fid in frame_ids],
        "gridX": 0, "gridY": 0, "height": h, "HTile": False,
        "layers": [{"$GMImageLayer": "", "%Name": layer_id, "blendMode": 0, "displayName": "default",
                    "isLocked": False, "name": layer_id, "opacity": 100.0, "resourceType": "GMImageLayer",
                    "resourceVersion": "2.0", "visible": True}],
        "name": name, "nineSlice": None, "origin": origin_kind,
        "parent": folder(SPRITE_FOLDER[meta["group"]]), "preMultiplyAlpha": False,
        "resourceType": "GMSprite", "resourceVersion": "2.0",
        "sequence": {
            "$GMSequence": "v1", "%Name": name, "autoRecord": True, "backdropHeight": 768,
            "backdropImageOpacity": 0.5, "backdropImagePath": "", "backdropWidth": 1366,
            "backdropXOffset": 0.0, "backdropYOffset": 0.0,
            "events": {"$KeyframeStore<MessageEventKeyframe>": "", "Keyframes": [],
                       "resourceType": "KeyframeStore<MessageEventKeyframe>", "resourceVersion": "2.0"},
            "eventStubScript": None, "eventToFunction": {}, "length": float(len(frames)), "lockOrigin": False,
            "moments": {"$KeyframeStore<MomentsEventKeyframe>": "", "Keyframes": [],
                        "resourceType": "KeyframeStore<MomentsEventKeyframe>", "resourceVersion": "2.0"},
            "name": name, "playback": 1, "playbackSpeed": float(meta["fps"]), "playbackSpeedType": 0,
            "resourceType": "GMSequence", "resourceVersion": "2.0", "showBackdrop": True,
            "showBackdropImage": False, "timeUnits": 1,
            "tracks": [{"$GMSpriteFramesTrack": "", "builtinName": 0, "events": [], "inheritsTrackColour": True,
                        "interpolation": 1, "isCreationTrack": False,
                        "keyframes": {"$KeyframeStore<SpriteFrameKeyframe>": "", "Keyframes": keyframes,
                                      "resourceType": "KeyframeStore<SpriteFrameKeyframe>", "resourceVersion": "2.0"},
                        "modifiers": [], "name": "frames", "resourceType": "GMSpriteFramesTrack",
                        "resourceVersion": "2.0", "spriteId": None, "trackColour": 0, "tracks": [], "traits": 0}],
            "visibleRange": None, "volume": 1.0, "xorigin": ox, "yorigin": oy},
        "swatchColours": None, "swfPrecision": 2.525,
        "textureGroupId": {"name": "Default", "path": "texturegroups/Default"},
        "type": 0, "VTile": False, "width": w,
    }
    write(os.path.join(d, name + ".yy"), gm_dump(yy))
    RESOURCES.append(ref(name, "sprites"))


def load_sprites():
    metas = json.load(open(os.path.join(ASSETS, "sprites.json"), encoding="utf-8"))
    out = {}
    for m in metas:
        sheet = Image.open(os.path.join(ASSETS, m["file"])).convert("RGBA")
        frames = [sheet.crop((i * m["w"], 0, (i + 1) * m["w"], m["h"])) for i in range(m["n"])]
        out[m["name"]] = (m, frames)
    return out


# =============================================================================
# 3. TILESET
# =============================================================================
def build_tileset(name, sprite, image):
    cols, rows = image.width // TS, image.height // TS
    # ảnh "output_tileset.png": mỗi ô có viền 2px kéo dài màu mép (GameMaker tự tạo lại khi cần)
    b = 2
    out = Image.new("RGBA", (cols * (TS + 2 * b), rows * (TS + 2 * b)))
    for i in range(cols * rows):
        tile = image.crop(((i % cols) * TS, (i // cols) * TS, (i % cols + 1) * TS, (i // cols + 1) * TS))
        big = Image.new("RGBA", (TS + 2 * b, TS + 2 * b))
        big.paste(tile.resize((TS + 2 * b, TS + 2 * b), Image.NEAREST), (0, 0))
        big.paste(tile, (b, b))
        out.paste(big, ((i % cols) * (TS + 2 * b), (i // cols) * (TS + 2 * b)))
    d = os.path.join(PROJ, "tilesets", name)
    os.makedirs(d, exist_ok=True)
    out.save(os.path.join(d, "output_tileset.png"))
    yy = {
        "$GMTileSet": "v1", "%Name": name, "autoTileSets": [],
        "macroPageTiles": {"SerialiseHeight": 0, "SerialiseWidth": 0, "TileSerialiseData": []},
        "name": name, "out_columns": cols, "out_tilehborder": b, "out_tilevborder": b,
        "parent": folder("Tile Sets"), "resourceType": "GMTileSet", "resourceVersion": "2.0",
        "spriteId": ref(sprite, "sprites"), "spriteNoExport": False,
        "textureGroupId": {"name": "Default", "path": "texturegroups/Default"},
        "tileAnimationFrames": [], "tileAnimationSpeed": 15.0, "tileHeight": TS, "tilehsep": 0,
        "tilevsep": 0, "tileWidth": TS, "tilexoff": 0, "tileyoff": 0, "tile_count": cols * rows,
    }
    write(os.path.join(d, name + ".yy"), gm_dump(yy))
    RESOURCES.append(ref(name, "tilesets"))


# =============================================================================
# 4. OBJECT (sự kiện lấy theo tên file .gml có sẵn trong thư mục object)
# =============================================================================
#  tên            : (sprite, cha, hiện?, thư mục)
OBJECTS = {
    "obj_level":        (None, None, True, "system"),
    "obj_menu":         (None, None, True, "system"),
    "obj_end":          (None, None, True, "system"),
    "obj_player":       ("spr_knight_down", None, True, "player"),
    "obj_weapon":       ("spr_wp_sword", None, True, "player"),
    "obj_slash":        ("spr_slash", None, True, "combat"),
    "obj_spin":         ("spr_spin", None, True, "combat"),
    "obj_nova":         ("spr_nova", None, True, "combat"),
    "obj_proj":         ("spr_arrow", None, True, "combat"),
    "obj_eproj":        ("spr_bone_arrow", None, True, "combat"),
    "obj_fx":           ("spr_fx_hit", None, True, "combat"),
    "obj_float_text":   (None, None, True, "combat"),
    "obj_fake_item":    ("spr_wp_sword", None, True, "combat"),
    "obj_enemy":        ("spr_slime", None, True, "enemies"),
    "obj_slime":        ("spr_slime", "obj_enemy", True, "enemies"),
    "obj_goblin":       ("spr_goblin_walk", "obj_enemy", True, "enemies"),
    "obj_skeleton":     ("spr_skeleton_walk", "obj_enemy", True, "enemies"),
    "obj_bat":          ("spr_bat", "obj_enemy", True, "enemies"),
    "obj_orc":          ("spr_orc_walk", "obj_enemy", True, "enemies"),
    "obj_dragon":       ("spr_dragon_fly", "obj_enemy", True, "enemies"),
    "obj_wall":         ("spr_wall_mask", None, False, "world"),
    "obj_door":         ("spr_door", "obj_wall", True, "world"),
    "obj_chest":        ("spr_chest", None, True, "world"),
    "obj_chest_gold":   ("spr_chest_gold", "obj_chest", True, "world"),
    "obj_portal":       ("spr_portal", None, True, "world"),
    "obj_teleport":     ("spr_teleport", None, True, "world"),
    "obj_spikes":       ("spr_spikes", None, True, "world"),
    "obj_lava":         ("spr_lava", None, True, "world"),
    "obj_torch":        ("spr_torch", None, True, "world"),
    "obj_sign":         ("spr_sign", None, True, "world"),
    "obj_pickup":       ("spr_coin", None, True, "items"),
    "obj_coin":         ("spr_coin", "obj_pickup", True, "items"),
    "obj_potion_hp":    ("spr_potion_hp", "obj_pickup", True, "items"),
    "obj_potion_mp":    ("spr_potion_mp", "obj_pickup", True, "items"),
    "obj_key":          ("spr_key", "obj_pickup", True, "items"),
    "obj_heart_pickup": ("spr_heart_pickup", "obj_pickup", True, "items"),
}

# tên file sự kiện -> (eventType, eventNum)
EVENT_TYPES = {"Create": 0, "Destroy": 1, "Alarm": 2, "Step": 3, "Collision": 4, "Other": 7, "Draw": 8, "CleanUp": 12}


def build_object(name, sprite, parent, visible, group):
    d = os.path.join(PROJ, "objects", name)
    os.makedirs(d, exist_ok=True)
    events = []
    for f in sorted(os.listdir(d)):
        m = re.match(r"^(Create|Destroy|Alarm|Step|Collision|Other|Draw|CleanUp)_(\w+)\.gml$", f)
        if not m:
            continue
        kind, num = m.groups()
        coll = None
        if kind == "Collision":
            coll, num = ref(num, "objects"), 0
        events.append({"$GMEvent": "v1", "%Name": "", "collisionObjectId": coll, "eventNum": int(num),
                       "eventType": EVENT_TYPES[kind], "isDnD": False, "name": "",
                       "resourceType": "GMEvent", "resourceVersion": "2.0"})
    yy = {
        "$GMObject": "", "%Name": name, "eventList": events, "managed": True, "name": name,
        "overriddenProperties": [], "parent": folder("Objects/" + group),
        "parentObjectId": ref(parent, "objects") if parent else None, "persistent": False,
        "physicsAngularDamping": 0.1, "physicsDensity": 0.5, "physicsFriction": 0.2, "physicsGroup": 1,
        "physicsKinematic": False, "physicsLinearDamping": 0.1, "physicsObject": False,
        "physicsRestitution": 0.1, "physicsSensor": False, "physicsShape": 1, "physicsShapePoints": [],
        "physicsStartAwake": True, "properties": [], "resourceType": "GMObject", "resourceVersion": "2.0",
        "solid": False, "spriteId": ref(sprite, "sprites") if sprite else None, "spriteMaskId": None,
        "visible": visible,
    }
    write(os.path.join(d, name + ".yy"), gm_dump(yy))
    RESOURCES.append(ref(name, "objects"))


def build_scripts():
    for name in sorted(os.listdir(os.path.join(PROJ, "scripts"))):
        if not os.path.exists(os.path.join(PROJ, "scripts", name, name + ".gml")):
            continue
        yy = {"$GMScript": "v1", "%Name": name, "isCompatibility": False, "isDnD": False, "name": name,
              "parent": folder("Scripts"), "resourceType": "GMScript", "resourceVersion": "2.0"}
        write(os.path.join(PROJ, "scripts", name, name + ".yy"), gm_dump(yy))
        RESOURCES.append(ref(name, "scripts"))


# =============================================================================
# 5. BẢN ĐỒ -> ROOM
# =============================================================================
WALLS = set("#~o")
# ký tự -> object (đặt ở tâm ô)
SPAWN = {"P": "obj_player", "S": "obj_slime", "G": "obj_goblin", "K": "obj_skeleton", "B": "obj_bat",
         "O": "obj_orc", "X": "obj_orc", "D": "obj_dragon", "C": "obj_chest", "W": "obj_chest_gold",
         "k": "obj_key", "h": "obj_potion_hp", "m": "obj_potion_mp", "$": "obj_coin", "H": "obj_heart_pickup",
         "E": "obj_portal", "T": "obj_teleport", "^": "obj_spikes", "i": "obj_sign"}
# ký tự -> object đặt ở góc trên-trái ô (gốc 0,0)
SPAWN_TL = {"|": "obj_door", "L": "obj_lava"}

# chỉ số ô trong tileset (xem make_tilesets trong generate_assets.py)
BIOMES = {
    "forest":  dict(ground=[(1, 50), (2, 20), (3, 8), (4, 7), (7, 15)], wall_top=[(1, 1)], wall_front=[(2, 1)]),
    "dungeon": dict(ground=[(8, 60), (9, 22), (10, 8), (11, 6), (12, 3), (15, 1)],
                    wall_top=[(8, 1)], wall_front=[(9, 80), (10, 10), (11, 10)]),
    "lair":    dict(ground=[(16, 55), (17, 22), (18, 8), (19, 2), (20, 6), (21, 7)],
                    wall_top=[(12, 1)], wall_front=[(13, 80), (14, 20)]),
}

LEVELS = [
    ("rm_level1", "level1.txt", "forest", 4278190080),
    ("rm_level2", "level2.txt", "dungeon", 4278190080),
    ("rm_level3", "level3.txt", "lair", 4278190080),
]


def pick(rng, weighted):
    total = sum(w for _, w in weighted)
    v = rng.uniform(0, total)
    for t, w in weighted:
        v -= w
        if v <= 0:
            return t
    return weighted[-1][0]


def read_map(fname):
    lines = open(os.path.join(MAPS, fname), encoding="utf-8").read().splitlines()
    grid, signs = [], []
    for ln in lines:
        if ln.startswith("i:"):
            signs.append(ln[2:].strip())
        elif ln.strip() and not ln.startswith("# "):     # "# ..." là dòng chú thích
            grid.append(ln.rstrip())
    w = max(len(r) for r in grid)
    grid = [r.ljust(w, "#") for r in grid]
    return grid, signs


def rle(values):
    """Nén dữ liệu tile theo kiểu TileCompressedData của GameMaker:
    số âm -n + 1 giá trị = lặp n lần; số dương n + n giá trị = n giá trị khác nhau."""
    out, i, n = [], 0, len(values)
    while i < n:
        j = i
        while j < n and values[j] == values[i]:
            j += 1
        if j - i >= 2:
            out += [-(j - i), values[i]]
            i = j
        else:
            k = i
            lit = []
            while k < n and (k + 1 >= n or values[k + 1] != values[k]):
                lit.append(values[k])
                k += 1
            out += [len(lit)] + lit
            i = k
    return out


def inst_name(room, i):
    return "inst_" + hashlib.md5(f"{room}/{i}".encode()).hexdigest()[:8].upper()


def tile_layer(name, depth, tileset, w, h, data):
    return {"$GMRTileLayer": "", "%Name": name, "depth": depth, "effectEnabled": True, "effectType": None,
            "gridX": TS, "gridY": TS, "hierarchyFrozen": False, "inheritLayerDepth": False,
            "inheritLayerSettings": False, "inheritSubLayers": True, "inheritVisibility": True, "layers": [],
            "name": name, "properties": [], "resourceType": "GMRTileLayer", "resourceVersion": "2.0",
            "tiles": {"SerialiseHeight": h, "SerialiseWidth": w, "TileCompressedData": rle(data), "TileDataFormat": 1},
            "tilesetId": ref(tileset, "tilesets"), "userdefinedDepth": True, "visible": True, "x": 0, "y": 0}


def build_room(name, width, height, instances, tile_layers=(), bg=4278190080):
    """instances: [(object, x, y, creation_code)] — instance đầu tiên được tạo trước."""
    d = os.path.join(PROJ, "rooms", name)
    if os.path.isdir(d):
        shutil.rmtree(d)
    os.makedirs(d)
    insts = []
    for i, (obj, x, y, code) in enumerate(instances):
        iname = inst_name(name, i)
        if code:
            write(os.path.join(d, f"InstanceCreationCode_{iname}.gml"), code)
        insts.append({"$GMRInstance": "v4", "%Name": iname, "colour": 4294967295, "frozen": False,
                      "hasCreationCode": bool(code), "ignore": False, "imageIndex": 0, "imageSpeed": 1.0,
                      "inheritCode": False, "inheritedItemId": None, "inheritItemSettings": False, "isDnd": False,
                      "name": iname, "objectId": ref(obj, "objects"), "properties": [],
                      "resourceType": "GMRInstance", "resourceVersion": "2.0", "rotation": 0.0,
                      "scaleX": 1.0, "scaleY": 1.0, "x": float(x), "y": float(y)})
    layers = [{"$GMRInstanceLayer": "", "%Name": "Instances", "depth": 0, "effectEnabled": True,
               "effectType": None, "gridX": TS, "gridY": TS, "hierarchyFrozen": False,
               "inheritLayerDepth": False, "inheritLayerSettings": False, "inheritSubLayers": True,
               "inheritVisibility": True, "instances": insts, "layers": [], "name": "Instances",
               "properties": [], "resourceType": "GMRInstanceLayer", "resourceVersion": "2.0",
               "userdefinedDepth": True, "visible": True}]
    layers += list(tile_layers)
    layers.append({"$GMRBackgroundLayer": "", "%Name": "Background", "animationFPS": 30.0,
                   "animationSpeedType": 0, "colour": bg, "depth": 2000, "effectEnabled": True,
                   "effectType": None, "gridX": TS, "gridY": TS, "hierarchyFrozen": False, "hspeed": 0.0,
                   "htiled": False, "inheritLayerDepth": False, "inheritLayerSettings": False,
                   "inheritSubLayers": True, "inheritVisibility": True, "layers": [], "name": "Background",
                   "properties": [], "resourceType": "GMRBackgroundLayer", "resourceVersion": "2.0",
                   "spriteId": None, "stretch": False, "userdefinedAnimFPS": False, "userdefinedDepth": True,
                   "visible": True, "vspeed": 0.0, "vtiled": False, "x": 0, "y": 0})
    view = {"hborder": 32, "hport": 540, "hspeed": -1, "hview": 270, "inherit": False, "objectId": None,
            "vborder": 32, "visible": True, "vspeed": -1, "wport": 960, "wview": 480, "xport": 0,
            "xview": 0, "yport": 0, "yview": 0}
    yy = {
        "$GMRoom": "v1", "%Name": name, "creationCodeFile": "", "inheritCode": False,
        "inheritCreationOrder": False, "inheritLayers": False,
        "instanceCreationOrder": [{"name": i["name"], "path": f"rooms/{name}/{name}.yy"} for i in insts],
        "isDnd": False, "layers": layers, "name": name, "parent": folder("Rooms"), "parentRoom": None,
        "physicsSettings": {"inheritPhysicsSettings": False, "PhysicsWorld": False, "PhysicsWorldGravityX": 0.0,
                            "PhysicsWorldGravityY": 10.0, "PhysicsWorldPixToMetres": 0.1},
        "resourceType": "GMRoom", "resourceVersion": "2.0",
        "roomSettings": {"Height": height, "inheritRoomSettings": False, "persistent": False, "Width": width},
        "sequenceId": None,
        "views": [view] + [dict(view, visible=False) for _ in range(7)],
        "viewSettings": {"clearDisplayBuffer": True, "clearViewBackground": False, "enableViews": True,
                         "inheritViewSettings": False},
        "volume": 1.0,
    }
    write(os.path.join(d, name + ".yy"), gm_dump(yy))
    RESOURCES.append(ref(name, "rooms"))


def gml_string(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def build_level(room, fname, biome, bg, sprites):
    grid, signs = read_map(fname)
    H, W = len(grid), len(grid[0])
    rng = random.Random(room)
    B = BIOMES[biome]
    ground = [0] * (W * H)
    wall = [0] * (W * H)
    instances = [("obj_level", 0, 0, None)]       # obj_level phải được tạo đầu tiên
    sign_i = 0
    torches = []
    for y in range(H):
        for x in range(W):
            c = grid[y][x]
            below = grid[y + 1][x] if y + 1 < H else "#"
            i = y * W + x
            if c in WALLS:
                front = below not in WALLS
                if c == "~":
                    wall[i] = 3 if not front else 4
                elif c == "o":
                    wall[i] = 5 if not front else 6
                else:
                    wall[i] = pick(rng, B["wall_front"] if front else B["wall_top"])
                    if front and biome == "dungeon" and x % 4 == 1 and wall[i] == 9:
                        torches.append((x * TS + 16, y * TS + 18))
                if biome == "forest" and c == "#" and front:
                    ground[i] = 1
                continue
            ground[i] = pick(rng, B["ground"])
            if c in SPAWN:
                code = None
                if c == "X":
                    code = "// orc này giữ chìa khóa\ndrop_key = true;\n"
                if c == "i":
                    text = signs[sign_i] if sign_i < len(signs) else "..."
                    sign_i += 1
                    code = "// nội dung biển chỉ dẫn\ntext = " + gml_string(text) + ";\n"
                instances.append((SPAWN[c], x * TS + 16, y * TS + 16, code))
            elif c in SPAWN_TL:
                instances.append((SPAWN_TL[c], x * TS, y * TS, None))
    instances += [("obj_torch", tx, ty, None) for tx, ty in torches]
    # người chơi tạo ngay sau obj_level, trước quái
    order = [instances[0]] + [it for it in instances[1:] if it[0] == "obj_player"] + \
            [it for it in instances[1:] if it[0] != "obj_player"]
    layers = [tile_layer("lay_wall", 500, "ts_wall", W, H, wall),
              tile_layer("lay_ground", 1000, "ts_ground", W, H, ground)]
    build_room(room, W * TS, H * TS, order, layers, bg)
    render_preview(room, grid, ground, wall, order, sprites)
    return W, H, len(order)


def render_preview(room, grid, ground, wall, instances, sprites):
    """Vẽ ảnh xem trước bản đồ (giống trong game) để kiểm tra nhanh."""
    H, W = len(grid), len(grid[0])
    img = Image.new("RGBA", (W * TS, H * TS), (0, 0, 0, 255))
    ts_g = sprites["spr_ts_ground"][1][0]
    ts_w = sprites["spr_ts_wall"][1][0]
    for layer, sheet in ((ground, ts_g), (wall, ts_w)):
        for i, t in enumerate(layer):
            if t:
                tile = sheet.crop(((t % 8) * TS, (t // 8) * TS, (t % 8 + 1) * TS, (t // 8 + 1) * TS))
                img.alpha_composite(tile, ((i % W) * TS, (i // W) * TS))
    order = sorted(instances[1:], key=lambda it: (OBJECTS[it[0]][0] not in ("spr_lava", "spr_spikes", "spr_teleport"), it[2]))
    for obj, x, y, _ in order:
        spr = OBJECTS[obj][0]
        if obj == "obj_player":
            spr = "spr_knight_down"
        if not spr or spr not in sprites:
            continue
        meta, frames = sprites[spr]
        fr = frames[min(2, len(frames) - 1)] if obj == "obj_spikes" else frames[0]
        img.alpha_composite(fr, (int(x - meta["origin"][0]), int(y - meta["origin"][1])))
    img.convert("RGB").save(os.path.join(MAPS, f"preview_{room[3:]}.png"))


# =============================================================================
# 6. PROJECT (.yyp) + OPTIONS
# =============================================================================
def build_options():
    dst = os.path.join(PROJ, "options")
    if os.path.isdir(dst):
        shutil.rmtree(dst)
    shutil.copytree(os.path.join(TEMPLATE, "options"), dst)
    for root, _, files in os.walk(dst):
        for f in files:
            p = os.path.join(root, f)
            s = open(p, encoding="utf-8").read()
            s = s.replace("Cá chép vượt Vũ Môn", TITLE)
            s = re.sub(r'"option_gameguid":"[^"]*"', f'"option_gameguid":"{uid("gameguid")}"', s)
            s = re.sub(r'"option_(operagx_game_name|operagx_mod_game_name|reddit_game_name)":"[^"]*"',
                       lambda m: f'"option_{m.group(1)}":"{NAME}"', s)
            write(p, s)
    dfiles = os.path.join(PROJ, "datafiles")
    os.makedirs(dfiles, exist_ok=True)
    for f in os.listdir(os.path.join(TEMPLATE, "datafiles")):
        shutil.copy(os.path.join(TEMPLATE, "datafiles", f), dfiles)


def build_yyp():
    std = ["Animation Curves", "Extensions", "Fonts", "Notes", "Objects", "Particle Systems", "Paths", "Rooms",
           "Scripts", "Sequences", "Shaders", "Sounds", "Sprites", "Tile Sets", "Timelines"]
    for s in std:
        if s not in FOLDERS:
            FOLDERS.append(s)
    folders = [{"$GMFolder": "", "%Name": p.split("/")[-1], "folderPath": f"folders/{p}.yy",
                "name": p.split("/")[-1], "resourceType": "GMFolder", "resourceVersion": "2.0"}
               for p in sorted(FOLDERS, key=str.lower)]
    included = [{"$GMIncludedFile": "", "%Name": f, "CopyToMask": -1, "filePath": "datafiles", "name": f,
                 "resourceType": "GMIncludedFile", "resourceVersion": "2.0"}
                for f in sorted(os.listdir(os.path.join(PROJ, "datafiles")))]
    rooms = ["rm_menu", "rm_level1", "rm_level2", "rm_level3", "rm_end"]
    yy = {
        "$GMProject": "v1", "%Name": NAME,
        "AudioGroups": [{"$GMAudioGroup": "v1", "%Name": "audiogroup_default", "exportDir": "",
                         "name": "audiogroup_default", "resourceType": "GMAudioGroup", "resourceVersion": "2.0",
                         "targets": -1}],
        "configs": {"children": [], "name": "Default"},
        "defaultScriptType": 0,
        "Folders": folders,
        "ForcedPrefabProjectReferences": [],
        "IncludedFiles": included,
        "isEcma": False, "LibraryEmitters": [],
        "MetaData": {"IDEVersion": IDE_VERSION},
        "name": NAME,
        "resources": [{"id": r} for r in sorted(RESOURCES, key=lambda r: r["name"])],
        "resourceType": "GMProject", "resourceVersion": "2.0",
        "RoomOrderNodes": [{"roomId": ref(r, "rooms")} for r in rooms],
        "templateType": "game",
        "TextureGroups": [{"$GMTextureGroup": "", "%Name": "Default", "autocrop": True, "border": 2,
                           "compressFormat": "bz2", "customOptions": "", "directory": "", "groupParent": None,
                           "isScaled": True, "loadType": "default", "mipsToGenerate": 0, "name": "Default",
                           "resourceType": "GMTextureGroup", "resourceVersion": "2.0", "targets": -1}],
    }
    write(os.path.join(PROJ, NAME + ".yyp"), gm_dump(yy))


# =============================================================================
# 7. CHƯƠNG TRÌNH CHÍNH
# =============================================================================
def main():
    sprites = load_sprites()
    for name, (meta, frames) in sprites.items():
        build_sprite(meta, frames)
    build_tileset("ts_ground", "spr_ts_ground", sprites["spr_ts_ground"][1][0])
    build_tileset("ts_wall", "spr_ts_wall", sprites["spr_ts_wall"][1][0])
    for name, (spr, parent, vis, group) in OBJECTS.items():
        build_object(name, spr, parent, vis, group)
    build_scripts()
    build_room("rm_menu", 480, 270, [("obj_menu", 0, 0, None)], bg=4280422418)
    build_room("rm_end", 480, 270, [("obj_end", 0, 0, None)], bg=4280422418)
    print("Room:")
    for room, fname, biome, bg in LEVELS:
        w, h, n = build_level(room, fname, biome, bg, sprites)
        print(f"  {room:10s} {w}x{h} ô ({w * TS}x{h * TS} px), {n} instance  -> maps/preview_{room[3:]}.png")
    build_options()
    build_yyp()
    # object có thư mục nhưng chưa khai báo trong OBJECTS -> nhắc
    for d in sorted(os.listdir(os.path.join(PROJ, "objects"))):
        if d not in OBJECTS:
            print("  ! thư mục objects/" + d + " chưa có trong bảng OBJECTS")
    print(f"Xong: {len(sprites)} sprite, {len(OBJECTS)} object, project {NAME}/{NAME}.yyp")


if __name__ == "__main__":
    main()
