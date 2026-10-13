class_name BattleState
extends RefCounted
## Toàn bộ trạng thái một trận đánh. Dữ liệu thuần, không phụ thuộc Node: lưu / tải / test được.

const ALLY_GROUPS := [["thanh", "le"]]

var mission_id: String = ""
var mission: Dictionary = {}
var width: int = 0
var height: int = 0
var tiles: PackedStringArray = []      # id địa hình, chỉ số = y * width + x
var owners: Dictionary = {}            # Vector2i -> phe
var objects: Dictionary = {}           # Vector2i -> {"loai": ..., ...}
var units: Array[Unit] = []
var next_uid: int = 1

var factions: PackedStringArray = []   # thứ tự đi trong một vòng
var current: int = 0                   # chỉ số phe đang đi
var vong: int = 1
var gold: Dictionary = {}
var limits: Dictionary = {}
var buyable: Dictionary = {}           # phe -> PackedStringArray
var tam_nhin: int = 0                  # 0 = ban ngày, không sương mù
var rng_seed: int = 0
var strike_counter: int = 0            # số đòn trong vòng, để lấy số ngẫu nhiên
var result: String = ""                # "", "thang", "thua"
var result_reason: String = ""
var won_round: int = 0
var zones: Dictionary = {}             # tên khu -> Array[Vector2i]
var flags: Dictionary = {"bao_dong": 0, "mat_quan": {}, "tu_binh": 0, "hang_binh": 0}


static func from_mission(m: Dictionary, p_seed: int = 0) -> BattleState:
	var s := BattleState.new()
	var data := GameData.get_data()
	s.mission = m
	s.mission_id = m.get("id", "")
	var rows: Array = m["ban_do"]
	s.height = rows.size()
	s.width = String(rows[0]).length()
	s.tiles.resize(s.width * s.height)
	for y in s.height:
		var row: String = rows[y]
		assert(row.length() == s.width, "Hàng %d của bản đồ dài %d, cần %d" % [y, row.length(), s.width])
		for x in s.width:
			var ch := row[x]
			assert(data.terrain_by_char.has(ch), "Ký tự bản đồ lạ '%s' ở (%d,%d)" % [ch, x, y])
			s.tiles[y * s.width + x] = data.terrain_by_char[ch]
	var chu: Dictionary = m.get("chu_o", {})
	for key in chu:
		var parts: PackedStringArray = String(key).split(",")
		s.owners[Vector2i(int(parts[0]), int(parts[1]))] = chu[key]
	s.factions = PackedStringArray(m["phe"])
	for f in s.factions:
		s.gold[f] = int(m.get("vang", {}).get(f, 0))
		s.limits[f] = int(m.get("gioi_han", {}).get(f, 99))
		s.buyable[f] = PackedStringArray(m.get("mua_duoc", {}).get(f, []))
	s.tam_nhin = int(m.get("tam_nhin", 0))
	s.rng_seed = p_seed if p_seed != 0 else int(m.get("seed", 12345))
	for q in m.get("quan", []):
		var u := s.spawn_unit(q["id"], q["phe"], Vector2i(int(q["x"]), int(q["y"])))
		u.tuong_chinh = q.get("tuong_chinh", false)
		u.toi_thieu_1 = q.get("toi_thieu_1", false)
		u.rut_khi_yeu = int(q.get("rut_khi_yeu", 0))
		u.ngu = q.get("ngu", false)
		u.duoc = q.get("duoc", false)
		u.ngoai_gioi_han = q.get("ngoai_gioi_han", false)
		u.hp = int(q.get("mau", 100))
		u.level = int(q.get("cap", 0))
		u.ai_mode = q.get("ai", "tan_cong")
		var params := {}
		if q.has("ban_kinh"):
			params["ban_kinh"] = int(q["ban_kinh"])
		if q.has("tam"):
			params["tam"] = Vector2i(int(q["tam"][0]), int(q["tam"][1]))
		if q.has("vung"):
			var zone: Array[Vector2i] = []
			for p in q["vung"]:
				zone.append(Vector2i(int(p[0]), int(p[1])))
			params["vung"] = zone
		if q.has("diem"):
			var pts: Array[Vector2i] = []
			for p in q["diem"]:
				pts.append(Vector2i(int(p[0]), int(p[1])))
			params["diem"] = pts
			params["i"] = 0
		u.ai_params = params
	var khu: Dictionary = m.get("khu", {})
	for name in khu:
		var cells: Array[Vector2i] = []
		for c in khu[name]:
			cells.append(Vector2i(int(c[0]), int(c[1])))
		s.zones[name] = cells
	for o in m.get("vat_the", []):
		var d: Dictionary = o.duplicate()
		var at := Vector2i(int(o["o"][0]), int(o["o"][1]))
		d.erase("o")
		s.objects[at] = d
	return s


# ---------------------------------------------------------------- truy vấn

func in_bounds(p: Vector2i) -> bool:
	return p.x >= 0 and p.y >= 0 and p.x < width and p.y < height


func terrain_id(p: Vector2i) -> String:
	return tiles[p.y * width + p.x]


func terrain_at(p: Vector2i) -> Dictionary:
	return GameData.get_data().terrain_of(terrain_id(p))


func set_terrain(p: Vector2i, id: String) -> void:
	tiles[p.y * width + p.x] = id


func owner_of(p: Vector2i) -> String:
	return owners.get(p, "")


func unit_at(p: Vector2i) -> Unit:
	for u in units:
		if u.pos == p:
			return u
	return null


func unit_by_uid(uid: int) -> Unit:
	for u in units:
		if u.uid == uid:
			return u
	return null


func object_at(p: Vector2i) -> Dictionary:
	return objects.get(p, {})


func zone_of(p: Vector2i) -> String:
	for name in zones:
		if zones[name].has(p):
			return name
	return ""


func current_faction() -> String:
	return factions[current]


func are_allies(a: String, b: String) -> bool:
	if a == b:
		return true
	for g in ALLY_GROUPS:
		if g.has(a) and g.has(b):
			return true
	return false


func units_of(f: String) -> Array[Unit]:
	var out: Array[Unit] = []
	for u in units:
		if u.faction == f:
			out.append(u)
	return out


func enemies_of(f: String) -> Array[Unit]:
	var out: Array[Unit] = []
	for u in units:
		if not are_allies(u.faction, f):
			out.append(u)
	return out


func count_toward_limit(f: String) -> int:
	var n := 0
	for u in units:
		if u.faction == f and not u.ngoai_gioi_han:
			n += 1
	return n


# ---------------------------------------------------------------- thay đổi

func spawn_unit(type_id: String, faction: String, p: Vector2i) -> Unit:
	assert(GameData.get_data().units.has(type_id), "Không có loại lính %s" % type_id)
	var u := Unit.new()
	u.uid = next_uid
	next_uid += 1
	u.type_id = type_id
	u.faction = faction
	u.pos = p
	u.move_origin = p
	units.append(u)
	return u


func remove_unit(u: Unit) -> void:
	units.erase(u)


# ---------------------------------------------------------------- lưu / tải

func to_dict() -> Dictionary:
	var unit_list: Array = []
	for u in units:
		unit_list.append(u.to_dict())
	var owner_list: Array = []
	for p in owners:
		owner_list.append([p.x, p.y, owners[p]])
	var object_list: Array = []
	for p in objects:
		object_list.append([p.x, p.y, objects[p]])
	var d := {
		"mission": mission, "tiles": tiles, "owners": owner_list, "objects": object_list,
		"units": unit_list, "next_uid": next_uid, "current": current, "vong": vong,
		"gold": gold, "seed": rng_seed, "strike_counter": strike_counter, "result": result,
		"result_reason": result_reason, "won_round": won_round, "flags": flags, "tam_nhin": tam_nhin,
	}
	return d.duplicate(true)  # bản sao sâu: trạng thái lưu không dùng chung dữ liệu với trận đang chạy


static func from_dict(src: Dictionary) -> BattleState:
	var d := src.duplicate(true)
	var s := BattleState.from_mission(d["mission"], int(d["seed"]))
	s.tiles = PackedStringArray(d["tiles"])
	s.owners.clear()
	for o in d["owners"]:
		s.owners[Vector2i(int(o[0]), int(o[1]))] = o[2]
	s.objects.clear()
	for o in d["objects"]:
		s.objects[Vector2i(int(o[0]), int(o[1]))] = o[2]
	s.units.clear()
	for ud in d["units"]:
		s.units.append(Unit.from_dict(ud))
	s.next_uid = int(d["next_uid"])
	s.current = int(d["current"])
	s.vong = int(d["vong"])
	s.gold = d["gold"]
	s.strike_counter = int(d["strike_counter"])
	s.result = d["result"]
	s.result_reason = d.get("result_reason", "")
	s.won_round = int(d.get("won_round", 0))
	s.flags = d.get("flags", s.flags)
	s.tam_nhin = int(d.get("tam_nhin", s.tam_nhin))
	return s
