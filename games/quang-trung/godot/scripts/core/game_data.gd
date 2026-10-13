class_name GameData
extends RefCounted
## Nạp dữ liệu tĩnh (lính, địa hình, khắc chế) từ data/*.csv. Dùng chung qua GameData.get_data().

const UNITS_PATH := "res://data/units.csv"
const TERRAIN_PATH := "res://data/terrain.csv"
const COUNTERS_PATH := "res://data/counters.csv"

static var _instance: GameData

var units: Dictionary = {}            # id -> Dictionary
var terrain: Dictionary = {}          # id -> Dictionary
var terrain_by_char: Dictionary = {}  # ký tự bản đồ -> id
var counters: Array[Dictionary] = []
var errors: PackedStringArray = []


static func get_data() -> GameData:
	if _instance == null:
		_instance = GameData.new()
		_instance._load_all()
	return _instance


func _load_all() -> void:
	for row in _read_csv(UNITS_PATH):
		var tags := PackedStringArray(row["the"].split(" ", false))
		units[row["id"]] = {
			"id": row["id"],
			"phe": row["phe"],
			"ten": row["ten"],
			"gia": int(row["gia"]),
			"cong_min": int(row["cong_min"]),
			"cong_max": int(row["cong_max"]),
			"thu": int(row["thu"]),
			"di": int(row["di"]),
			"tam_min": int(row["tam_min"]),
			"tam_max": int(row["tam_max"]),
			"kieu_di": row["kieu_di"],
			"the": tags,
		}
	for row in _read_csv(TERRAIN_PATH):
		var t := {
			"id": row["id"],
			"ky_tu": row["ky_tu"],
			"ten": row["ten"],
			"chi_phi": {
				"bo": int(row["bo"]),
				"nang": int(row["nang"]),
				"voi": int(row["voi"]),
				"thuy": int(row["thuy"]),
			},
			"thu": int(row["thu"]),
			"vang": int(row["vang"]),
			"hoi_mau": int(row["hoi_mau"]),
			"mua_linh": row["mua_linh"] == "1",
			"chay_duoc": row["chay_duoc"] == "1",
			"so_huu": row["so_huu"] == "1",
		}
		terrain[t["id"]] = t
		if terrain_by_char.has(t["ky_tu"]):
			errors.append("Trùng ký tự bản đồ: %s" % t["ky_tu"])
		terrain_by_char[t["ky_tu"]] = t["id"]
	for row in _read_csv(COUNTERS_PATH):
		counters.append({
			"ben_danh": row["ben_danh"],
			"ben_bi_danh": row["ben_bi_danh"],
			"cong": int(row["cong_them"]),
			"thu": int(row["thu_them"]),
		})
	_validate()


func _read_csv(path: String) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		errors.append("Không mở được %s" % path)
		return rows
	var header := f.get_csv_line()
	while not f.eof_reached():
		var line := f.get_csv_line()
		if line.size() < header.size():
			continue
		var row := {}
		for i in header.size():
			row[header[i]] = line[i].strip_edges()
		rows.append(row)
	return rows


func _validate() -> void:
	for c in counters:
		for key in ["ben_danh", "ben_bi_danh"]:
			var sel: String = c[key]
			if sel.begins_with("id:") and not units.has(sel.substr(3)):
				errors.append("counters.csv: không có lính %s" % sel)
			if sel.begins_with("o:") and not terrain.has(sel.substr(2)):
				errors.append("counters.csv: không có địa hình %s" % sel)
	for id in units:
		var u: Dictionary = units[id]
		if not ["bo", "nang", "voi", "thuy"].has(u["kieu_di"]):
			errors.append("units.csv: kiểu di chuyển lạ ở %s" % id)
	for e in errors:
		push_error(e)


func unit(id: String) -> Dictionary:
	return units.get(id, {})


func terrain_of(id: String) -> Dictionary:
	return terrain.get(id, {})
