class_name Progress
extends RefCounted
## Tiến trình chiến dịch và file lưu trận (docs/06 §7, 08 §3.4).
## - user://tien_trinh.json : màn đã thắng, mục tiêu phụ tốt nhất, mục Sử liệu đã mở.
## - user://luu_tran.txt    : trận đang dở (var_to_str), tự lưu đầu mỗi lượt của người chơi.

const VERSION := 1

## Đổi được trong test để không đụng vào tiến trình thật.
static var PROGRESS_PATH := "user://tien_trinh.json"
static var BATTLE_PATH := "user://luu_tran.txt"

static var _cache: Dictionary = {}


static func data() -> Dictionary:
	if _cache.is_empty():
		_cache = {"phien_ban": VERSION, "xong": {}, "su_lieu": []}
		var f := FileAccess.open(PROGRESS_PATH, FileAccess.READ)
		if f != null:
			var parsed: Variant = JSON.parse_string(f.get_as_text())
			if typeof(parsed) == TYPE_DICTIONARY:
				_cache.merge(parsed, true)
	return _cache


static func save() -> void:
	var f := FileAccess.open(PROGRESS_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(data(), " "))


## Ghi nhận thắng một màn. Trả về id các mục Sử liệu vừa mở lần đầu.
static func record_win(state: BattleState) -> Array[String]:
	var d := data()
	var objs := Rules.side_objectives(state)
	var got: Array = []
	for o in objs:
		got.append(o["dat"])
	var prev: Dictionary = d["xong"].get(state.mission_id, {})
	var best: Array = prev.get("muc_tieu_phu", [])
	for i in got.size():
		if i < best.size() and best[i]:
			got[i] = true
	d["xong"][state.mission_id] = {"muc_tieu_phu": got, "vong": mini(int(prev.get("vong", 999)), state.won_round)}
	var opened: Array[String] = []
	for id in state.mission.get("su_lieu", []):
		if not d["su_lieu"].has(id):
			d["su_lieu"].append(id)
			opened.append(id)
	save()
	return opened


static func is_won(mission_id: String) -> bool:
	return data()["xong"].has(mission_id)


static func stars(mission_id: String) -> int:
	var n := 0
	for ok in data()["xong"].get(mission_id, {}).get("muc_tieu_phu", []):
		if ok:
			n += 1
	return n


static func codex_unlocked(id: String) -> bool:
	return data()["su_lieu"].has(id)


# ---------------------------------------------------------------- trận đang dở

static func save_battle(state: BattleState) -> void:
	var f := FileAccess.open(BATTLE_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(var_to_str({"phien_ban": VERSION, "tran": state.to_dict()}))


static func has_battle() -> bool:
	return FileAccess.file_exists(BATTLE_PATH)


static func load_battle() -> BattleState:
	var f := FileAccess.open(BATTLE_PATH, FileAccess.READ)
	if f == null:
		return null
	var v: Variant = str_to_var(f.get_as_text())
	if typeof(v) != TYPE_DICTIONARY or int(v.get("phien_ban", 0)) != VERSION:
		return null
	return BattleState.from_dict(v["tran"])


static func clear_battle() -> void:
	if has_battle():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(BATTLE_PATH))


## Chỉ dùng trong test: xóa bộ nhớ đệm để đọc lại từ đĩa.
static func reset_cache() -> void:
	_cache = {}
