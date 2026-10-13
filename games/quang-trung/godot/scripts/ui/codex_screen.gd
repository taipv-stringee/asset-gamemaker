class_name CodexScreen
extends Control
## Sử liệu (docs/05 §6): danh mục theo nhóm; mục chưa mở hiện "???"; mỗi mục có nhãn nguồn và danh sách nguồn.

signal back

const GROUPS := ["Sự kiện", "Nhân vật", "Binh chủng", "Địa danh", "Tranh cãi", "Về các nguồn"]

var _body: Control


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(UiKit.backdrop())
	_show_list()


func _clear() -> void:
	if _body != null:
		_body.queue_free()
	_body = Control.new()
	_body.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_body)


func _show_list() -> void:
	_clear()
	var col := UiKit.scroll_column(_body, 16, 60)
	col.add_child(UiKit.label("Sử liệu", 18, UiKit.C_GOLD_LIGHT, true))
	col.add_child(UiKit.wrap_label("Mỗi mục ghi rõ nguồn: Sử liệu, Theo Hoàng Lê nhất thống chí, Tương truyền, hay Sáng tạo của game.", 10, UiKit.C_MUTED))
	var entries := Story.codex()
	var locked := 0
	for g in GROUPS:
		var in_group: Array = entries.filter(func(e: Dictionary) -> bool: return e["nhom"] == g)
		if in_group.is_empty():
			continue
		col.add_child(UiKit.label(g, 12, UiKit.C_GOLD, true))
		for e in in_group:
			if Progress.codex_unlocked(e["id"]):
				var b := UiKit.button(e["tieu_de"], _show_entry.bind(e), 11)
				b.alignment = HORIZONTAL_ALIGNMENT_LEFT
				b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				col.add_child(b)
			else:
				locked += 1
				var l := UiKit.label("  ???", 11, Color(0.5, 0.42, 0.36))
				col.add_child(l)
	if locked > 0:
		col.add_child(UiKit.wrap_label("Còn %d mục chưa mở. Thắng các màn để mở thêm." % locked, 10, UiKit.C_MUTED))
	UiKit.bottom_bar(_body).add_child(UiKit.button("Quay lại", func() -> void: back.emit(), 12, 100))


func _show_entry(e: Dictionary) -> void:
	_clear()
	var col := UiKit.scroll_column(_body, 16, 60)
	col.add_child(UiKit.label(e.get("nhom", ""), 10, UiKit.C_MUTED, true))
	col.add_child(UiKit.wrap_label(e["tieu_de"], 16, UiKit.C_GOLD_LIGHT, true))
	col.add_child(UiKit.source_tag(e.get("nhan", "")))
	var text := UiKit.wrap_label(e.get("noi_dung", ""), 11, UiKit.C_PAPER)
	text.add_theme_constant_override("line_spacing", 2)
	col.add_child(text)
	var sources: Array = e.get("nguon", [])
	if not sources.is_empty():
		col.add_child(UiKit.label("Nguồn", 12, UiKit.C_GOLD, true))
		var rt := RichTextLabel.new()
		rt.bbcode_enabled = true
		rt.fit_content = true
		rt.scroll_active = false
		rt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		rt.add_theme_font_override("normal_font", UiKit.FONT_MED)
		rt.add_theme_font_size_override("normal_font_size", 10)
		rt.add_theme_color_override("default_color", UiKit.C_PAPER)
		var lines: PackedStringArray = []
		for s in sources:
			if String(s.get("url", "")) != "":
				lines.append("• [url=%s][color=#e8c86a]%s[/color][/url]" % [s["url"], s["ten"]])
			else:
				lines.append("• " + s["ten"])
		rt.text = "\n".join(lines)
		rt.meta_clicked.connect(func(meta: Variant) -> void: OS.shell_open(str(meta)))
		col.add_child(rt)
	UiKit.bottom_bar(_body).add_child(UiKit.button("Danh mục", _show_list, 12, 100))


func go_back() -> bool:
	## Nút Back của Android: đang xem mục thì về danh mục; đang ở danh mục thì trả false để main xử lý.
	if _body != null and _body.find_children("*", "Button", true, false).any(func(b: Button) -> bool: return b.text == "Danh mục"):
		_show_list()
		return true
	return false
