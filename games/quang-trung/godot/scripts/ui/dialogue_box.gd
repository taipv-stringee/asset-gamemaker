class_name DialogueBox
extends Control
## Hội thoại (docs/06 §4): chân dung 88×88 khung sơn mài phía trên bên trái khung chữ, bảng tên, chữ hiện dần.
## Chạm: hiện hết chữ / sang câu sau. Nút "Bỏ qua" bỏ cả đoạn. Dùng: `await box.play(lines)`.

signal finished

const CHAR_TIME := 0.022
const BOX_H := 180   # phủ kín bảng dưới của trận (168)
const PORTRAIT_DIR := "res://assets/portraits/"

var _lines: Array = []
var _i := -1
var _tween: Tween
var _frame: Panel
var _portrait: TextureRect
var _name: Label
var _text: Label
var _hint: Label
var _tag: Label   # nhãn nguồn của câu (05 §1) — kiểm thử M3 lần 6: hội thoại chưa hiện nhãn


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.01, 0.03, 0.45)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	var box := UiKit.panel(Color(0.12, 0.04, 0.04, 1.0), 2)
	box.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	box.offset_left = 8
	box.offset_right = -8
	box.offset_top = -BOX_H
	box.offset_bottom = -10
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(box)
	_text = UiKit.wrap_label("", 16, UiKit.C_PAPER)
	_text.set_anchors_preset(Control.PRESET_FULL_RECT)
	_text.offset_left = 12
	_text.offset_right = -12
	_text.offset_top = 28
	_text.offset_bottom = -18
	_text.add_theme_constant_override("line_spacing", 3)
	box.add_child(_text)
	_hint = UiKit.label("▼", UiKit.FS_SMALL, UiKit.C_GOLD, true)
	_hint.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_hint.offset_left = -20
	_hint.offset_top = -18
	_hint.offset_right = -8
	_hint.offset_bottom = -4
	box.add_child(_hint)
	_frame = UiKit.panel(UiKit.C_LACQUER, 2)
	_frame.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_frame.offset_left = 14
	_frame.offset_right = 14 + 88
	_frame.offset_top = -BOX_H - 84
	_frame.offset_bottom = -BOX_H + 4
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_frame)
	_portrait = TextureRect.new()
	_portrait.position = Vector2(4, 4)
	_portrait.size = Vector2(80, 80)
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_frame.add_child(_portrait)
	_name = UiKit.label("", UiKit.FS_HEAD + 1, UiKit.C_GOLD_LIGHT, true)
	_name.position = Vector2(12, 5)
	box.add_child(_name)
	_tag = UiKit.source_tag("")
	_tag.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_tag.offset_left = -150
	_tag.offset_right = -12
	_tag.offset_top = 7
	box.add_child(_tag)
	var skip := UiKit.button("Bỏ qua", _skip)
	skip.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	skip.offset_left = -96
	skip.offset_right = -8
	skip.offset_top = 52
	skip.offset_bottom = 52 + UiKit.BTN_H
	add_child(skip)


func play(lines: Array) -> void:
	_lines = lines
	_i = -1
	if lines.is_empty():
		return
	_next()
	await finished


func _next() -> void:
	_i += 1
	if _i >= _lines.size():
		finished.emit()
		return
	var line: Dictionary = _lines[_i]
	var who: String = line.get("ai", "")
	var tex := _portrait_for(who)
	_frame.visible = tex != null
	_portrait.texture = tex
	_name.text = line.get("ten", "")
	_name.position.x = 104 if _frame.visible else 12
	_text.text = line.get("loi", "")
	var nhan: String = line.get("nhan", "")
	_tag.visible = nhan != ""
	_tag.text = "[%s]" % nhan
	_tag.add_theme_color_override("font_color", UiKit.LABEL_COLORS.get(nhan, UiKit.C_MUTED))
	# Lời dẫn: nghiêng màu giấy cũ, không bảng tên.
	_text.add_theme_color_override("font_color", UiKit.C_PAPER if who != "" else Color(0.85, 0.8, 0.7))
	_text.visible_ratio = 0.0
	_hint.visible = false
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_text, "visible_ratio", 1.0, _text.text.length() * CHAR_TIME)
	_tween.tween_callback(func() -> void: _hint.visible = true)


func _portrait_for(who: String) -> Texture2D:
	if who == "":
		return null
	var path := PORTRAIT_DIR + "portrait_%s.png" % who
	if ResourceLoader.exists(path):
		return load(path)
	# Chưa có chân dung: dùng frame đầu của hình quân (phe Tây Sơn).
	var strip := "res://assets/units/unit_tayson_%s_dung_strip2.png" % who
	if ResourceLoader.exists(strip):
		var at := AtlasTexture.new()
		at.atlas = load(strip)
		at.region = Rect2(0, 0, 32, 32)
		return at
	return null


func advance() -> void:
	if _i < 0 or _i >= _lines.size():
		return
	if _text.visible_ratio < 1.0:
		if _tween != null:
			_tween.kill()
		_text.visible_ratio = 1.0
		_hint.visible = true
	else:
		_next()


func _skip() -> void:
	_i = _lines.size()
	finished.emit()


func _gui_input(event: InputEvent) -> void:
	# Chỉ bắt chuột: chạm trên điện thoại cũng sinh sự kiện chuột giả lập (mặc định của Godot), bắt cả hai sẽ nhảy 2 câu.
	if event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		advance()
