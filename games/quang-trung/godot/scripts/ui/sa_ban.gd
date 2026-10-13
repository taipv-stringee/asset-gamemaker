class_name SaBan
extends Control
## Sa bàn năm đạo (màn 3, docs/04): sơ đồ cách điệu trên giấy dó; chạm một đạo (nút dưới sơ đồ) để tô đạo đó và đọc
## mục Sử liệu của nó. Nút "Xong" kết thúc màn chuyện.

signal done

const PAPER := Color(0.9, 0.84, 0.7)
const INK := Color(0.2, 0.14, 0.1)
const RIVER := Color(0.35, 0.5, 0.65)
const SEA := Color(0.55, 0.68, 0.78)
const ROUTE_COLORS := {
	"tayson": Color(0.75, 0.12, 0.1), "vang": Color(0.75, 0.55, 0.05), "cam": Color(0.85, 0.4, 0.1),
	"xanh": Color(0.15, 0.45, 0.75), "xanh_dam": Color(0.1, 0.25, 0.5),
}

var _data: Dictionary
var _map: Control
var _selected := ""
var _text_col: VBoxContainer
var _buttons: Dictionary = {}     # id đạo → nút; đạo đang chọn có dấu ▶ và nền sáng


func setup(mission: Dictionary) -> SaBan:
	_data = mission.get("sa_ban", {})
	set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(UiKit.backdrop())
	var col := UiKit.scroll_column(self, 14, 64)
	col.add_child(UiKit.label("Sa bàn năm đạo", UiKit.FS_TITLE, UiKit.C_GOLD_LIGHT, true))
	col.add_child(UiKit.wrap_label("Đêm 30 tháng Chạp, quân Tây Sơn chia năm đạo tiến ra Thăng Long (sơ đồ theo sách giáo khoa hiện nay). Chạm một đạo để đọc.", UiKit.FS_SMALL, UiKit.C_MUTED))
	_map = Control.new()
	_map.custom_minimum_size = Vector2(0, 300)
	_map.mouse_filter = Control.MOUSE_FILTER_PASS   # vuốt bắt đầu trên sơ đồ vẫn cuộn được trang
	_map.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_map.draw.connect(_draw_map)
	col.add_child(_map)
	for d in _data.get("dao", []):
		var b := UiKit.list_button("■ " + d["ten"], _pick.bind(d["id"]))
		var c: Color = ROUTE_COLORS.get(d["mau"], Color.WHITE).lightened(0.35)
		for st in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color"]:
			b.add_theme_color_override(st, c)
		b.set_meta("chu", "■ " + d["ten"])
		_buttons[d["id"]] = b
		col.add_child(b)
	var hl := UiKit.list_button("Cách chia quân trong Hoàng Lê nhất thống chí", _pick.bind("cach_chia_hlntc"))
	hl.set_meta("chu", hl.text)
	_buttons["cach_chia_hlntc"] = hl
	col.add_child(hl)
	_text_col = VBoxContainer.new()
	_text_col.add_theme_constant_override("separation", 6)
	col.add_child(_text_col)
	UiKit.bottom_bar(self).add_child(UiKit.button("Xong", func() -> void: done.emit(), UiKit.FS_BUTTON, 120))
	return self


func _pick(id: String) -> void:
	Sfx.play("lat_trang", -4.0)
	_selected = id
	_map.queue_redraw()
	for k in _buttons:
		var b: Button = _buttons[k]
		b.text = ("▶ " if k == id else "") + String(b.get_meta("chu"))
		var sb := (b.get_theme_stylebox("normal") as StyleBoxFlat).duplicate() as StyleBoxFlat
		sb.bg_color = Color(0.32, 0.12, 0.1) if k == id else UiKit.C_LACQUER_DARK
		b.add_theme_stylebox_override("normal", sb)
		b.add_theme_stylebox_override("hover", sb)
	for c in _text_col.get_children():
		c.queue_free()
	var e := Story.codex_entry(id)
	if e.is_empty():
		return
	_text_col.add_child(UiKit.wrap_label(e["tieu_de"], UiKit.FS_HEAD, UiKit.C_GOLD_LIGHT, true))
	_text_col.add_child(UiKit.source_tag(e.get("nhan", "")))
	_text_col.add_child(UiKit.wrap_label(e.get("noi_dung", ""), UiKit.FS_BODY, UiKit.C_PAPER))


func _pt(p: Array, rect: Rect2) -> Vector2:
	return rect.position + Vector2(float(p[0]) / 100.0 * rect.size.x, float(p[1]) / 140.0 * rect.size.y)


func _draw_map() -> void:
	var size := _map.size
	var h := minf(size.y, 300.0)
	var w := minf(size.x, h * 100.0 / 140.0 * 1.25)
	var rect := Rect2(Vector2((size.x - w) / 2.0, 0), Vector2(w, h))
	_map.draw_rect(rect, PAPER)
	_map.draw_rect(rect, INK, false, 2.0)
	var sea: Array = _data.get("bien", [])
	if sea.size() >= 3:
		var poly := PackedVector2Array()
		for p in sea:
			poly.append(_pt(p, rect))
		_map.draw_colored_polygon(poly, SEA)
	for river in _data.get("song", []):
		var line := PackedVector2Array()
		for p in river:
			line.append(_pt(p, rect))
		_map.draw_polyline(line, RIVER, 3.0)
	var font := UiKit.FONT_MED
	for d in _data.get("dao", []):
		var line := PackedVector2Array()
		for p in d["duong"]:
			line.append(_pt(p, rect))
		var c: Color = ROUTE_COLORS.get(d["mau"], Color.WHITE)
		var picked: bool = _selected == "" or _selected == d["id"]
		if not picked:
			c = Color(c, 0.3)
		_map.draw_polyline(line, c, 4.0 if _selected == d["id"] else 2.5)
		# đầu mũi tên ở điểm cuối
		var a: Vector2 = line[line.size() - 2]
		var b: Vector2 = line[line.size() - 1]
		var dir := (b - a).normalized()
		var side := Vector2(-dir.y, dir.x)
		_map.draw_colored_polygon(PackedVector2Array([b + dir * 4, b - dir * 6 + side * 5, b - dir * 6 - side * 5]), c)
	for place in _data.get("dia_danh", []):
		var at := _pt(place["o"], rect)
		var big: bool = place.get("lon", false)
		_map.draw_circle(at, 4.0 if big else 2.5, INK)
		var fs := UiKit.FS_SMALL if big else UiKit.FS_TAG
		var tw := font.get_string_size(place["ten"], HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		# Địa danh nửa phải sơ đồ ghi sang trái chấm cho khỏi tràn mép.
		var off := Vector2(-tw - 5, 4) if at.x + 5 + tw > rect.end.x - 2 else Vector2(5, 4)
		match place.get("nhan", ""):
			"trai":
				off = Vector2(-tw - 5, 4)
			"duoi":
				off = Vector2(-tw / 2.0, 16)
		_map.draw_string(font, at + off, place["ten"], HORIZONTAL_ALIGNMENT_LEFT, -1, fs, INK)
