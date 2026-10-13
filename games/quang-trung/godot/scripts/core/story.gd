class_name Story
extends RefCounted
## Đọc dữ liệu truyện: hội thoại (data/hoi_thoai/), Sử liệu (data/su_lieu.json), danh sách màn (data/chien_dich.json).


static func _json(path: String) -> Variant:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("Không mở được " + path)
		return null
	return JSON.parse_string(f.get_as_text())


static func dialogue(id: String, part: String) -> Array:
	if id == "":
		return []
	var d: Variant = _json("res://data/hoi_thoai/%s.json" % id)
	return d.get(part, []) if typeof(d) == TYPE_DICTIONARY else []


static func codex() -> Array:
	var d: Variant = _json("res://data/su_lieu.json")
	return d.get("muc", []) if typeof(d) == TYPE_DICTIONARY else []


static func codex_entry(id: String) -> Dictionary:
	for e in codex():
		if e["id"] == id:
			return e
	return {}


static func campaign() -> Array:
	var d: Variant = _json("res://data/chien_dich.json")
	return d.get("man", []) if typeof(d) == TYPE_DICTIONARY else []
