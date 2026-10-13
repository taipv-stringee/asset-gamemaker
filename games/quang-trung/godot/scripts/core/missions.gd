class_name Missions
extends RefCounted
## Đọc dữ liệu màn từ data/missions/<id>.json.

const DIR := "res://data/missions/"


static func load_mission(id: String) -> Dictionary:
	var f := FileAccess.open(DIR + id + ".json", FileAccess.READ)
	if f == null:
		push_error("Không mở được màn %s" % id)
		return {}
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Màn %s: JSON lỗi" % id)
		return {}
	return parsed


static func new_battle(id: String, p_seed: int = 0) -> BattleState:
	var m := load_mission(id)
	var s := BattleState.from_mission(m, p_seed)
	Rules.start_turn(s)
	return s
