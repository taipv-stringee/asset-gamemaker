class_name MainMenu
extends Control
## Màn hình tiêu đề + menu chính (docs/06 §4): Tiếp tục | Chiến dịch | Sử liệu.

signal continue_pressed
signal campaign_pressed
signal codex_pressed

## Lời lưu truyền — nhãn Tương truyền (05 §4.3): không gắn vào sự kiện nào, chép đúng "chích luân bất phản, phiến giáp bất hoàn".
const LEGEND := "Đánh cho để dài tóc\nĐánh cho để đen răng\nĐánh cho nó chích luân bất phản\nĐánh cho nó phiến giáp bất hoàn\nĐánh cho sử tri Nam quốc anh hùng chi hữu chủ"


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(UiKit.backdrop())
	var col := VBoxContainer.new()
	col.set_anchors_preset(Control.PRESET_FULL_RECT)
	col.offset_left = 20
	col.offset_right = -20
	col.offset_top = 22
	col.offset_bottom = -14
	col.add_theme_constant_override("separation", 7)
	add_child(col)
	var icon := TextureRect.new()
	icon.texture = load("res://assets/icon/icon_192.png")
	icon.custom_minimum_size = Vector2(72, 72)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	col.add_child(icon)
	var title := UiKit.label("TÂY SƠN", 40, UiKit.C_GOLD_LIGHT, true)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_outline_color", UiKit.C_INK)
	title.add_theme_constant_override("outline_size", 6)
	col.add_child(title)
	var sub := UiKit.label("Xuân Kỷ Dậu 1789", UiKit.FS_HEAD, UiKit.C_MUTED)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(sub)
	var legend := UiKit.wrap_label(LEGEND, UiKit.FS_SMALL, Color(0.88, 0.82, 0.7))
	legend.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	legend.add_theme_constant_override("line_spacing", 1)
	col.add_child(legend)
	var tag := UiKit.source_tag("Tương truyền")
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(tag)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(spacer)
	if Progress.has_battle():
		col.add_child(_menu_button("Tiếp tục", func() -> void: continue_pressed.emit()))
	col.add_child(_menu_button("Chiến dịch", func() -> void: campaign_pressed.emit()))
	col.add_child(_menu_button("Sử liệu", func() -> void: codex_pressed.emit()))
	var foot := UiKit.label("Bản thử M3 · trò chơi miễn phí", UiKit.FS_TAG, UiKit.C_MUTED)
	foot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(foot)


func _menu_button(text: String, cb: Callable) -> Button:
	var b := UiKit.button(text, cb, 18)
	b.custom_minimum_size = Vector2(220, 52)
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	return b
