class_name UiKit
extends RefCounted
## Kiểu chung cho giao diện: sơn mài đỏ – đen, viền vàng, chữ Be Vietnam Pro (docs/06, 07).

const FONT_MED := preload("res://assets/fonts/BeVietnamPro-Medium.ttf")
const FONT_BOLD := preload("res://assets/fonts/BeVietnamPro-Bold.ttf")
const C_LACQUER := Color(0.36, 0.09, 0.09)
const C_LACQUER_DARK := Color(0.16, 0.05, 0.05)
const C_INK := Color(0.08, 0.03, 0.03)
const C_GOLD := Color(0.93, 0.73, 0.2)
const C_GOLD_LIGHT := Color(1.0, 0.91, 0.55)
const C_PAPER := Color(0.96, 0.92, 0.82)
const C_MUTED := Color(0.72, 0.62, 0.55)

## Màu nhãn nguồn (05 §1) — để người đọc nhận ra nhanh trong Sử liệu.
const LABEL_COLORS := {
	"Sử liệu": Color(0.55, 0.85, 0.55),
	"Theo HLNTC": Color(0.95, 0.78, 0.4),
	"Tương truyền": Color(0.75, 0.7, 0.95),
	"Sáng tạo của game": Color(0.6, 0.8, 0.95),
}


static func label(text: String, size: int = 11, color: Color = Color.WHITE, bold := false) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", FONT_BOLD if bold else FONT_MED)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l


static func wrap_label(text: String, size: int = 11, color: Color = Color.WHITE, bold := false) -> Label:
	var l := label(text, size, color, bold)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size.x = 10
	return l


static func style(color: Color, border := 1, border_color := C_GOLD) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.border_color = border_color
	sb.set_border_width_all(border)
	return sb


static func panel(color: Color = C_LACQUER, border := 1) -> Panel:
	var p := Panel.new()
	p.add_theme_stylebox_override("panel", style(color, border))
	p.mouse_filter = Control.MOUSE_FILTER_STOP
	return p


static func button(text: String, cb: Callable, size: int = 12, min_w: int = 44) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_override("font", FONT_BOLD)
	b.add_theme_font_size_override("font_size", size)
	var normal := style(C_LACQUER_DARK, 0)
	normal.border_width_top = 1
	normal.border_width_bottom = 1
	normal.content_margin_left = 8
	normal.content_margin_right = 8
	normal.content_margin_top = 6
	normal.content_margin_bottom = 6
	var pressed := normal.duplicate()
	pressed.bg_color = Color(0.5, 0.15, 0.12)
	var disabled := normal.duplicate()
	disabled.bg_color = Color(0.13, 0.08, 0.08)
	disabled.border_color = Color(0.4, 0.3, 0.2)
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", normal)
	b.add_theme_stylebox_override("pressed", pressed)
	b.add_theme_stylebox_override("focus", normal)
	b.add_theme_stylebox_override("disabled", disabled)
	b.add_theme_color_override("font_color", C_GOLD_LIGHT)
	b.add_theme_color_override("font_disabled_color", Color(0.5, 0.42, 0.36))
	b.custom_minimum_size = Vector2(min_w, 32)
	b.pressed.connect(func() -> void: Sfx.play("cham", -6.0))
	b.pressed.connect(cb)
	return b


## Nền toàn màn hình: sơn mài với hai đường viền vàng (dùng cho menu, giới thiệu màn, Sử liệu).
static func backdrop() -> Control:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = C_LACQUER_DARK
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(bg)
	var frame := Panel.new()
	var sb := style(Color(0, 0, 0, 0), 1)
	frame.add_theme_stylebox_override("panel", sb)
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.offset_left = 6
	frame.offset_top = 6
	frame.offset_right = -6
	frame.offset_bottom = -6
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(frame)
	return root


## Cột nội dung cuộn được, có lề, đặt trong `parent` (dùng anchor toàn màn hình trừ phần dưới cho nút).
static func scroll_column(parent: Control, top := 16, bottom := 56) -> VBoxContainer:
	var sc := ScrollContainer.new()
	sc.set_anchors_preset(Control.PRESET_FULL_RECT)
	sc.offset_left = 16
	sc.offset_right = -16
	sc.offset_top = top
	sc.offset_bottom = -bottom
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	parent.add_child(sc)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 8)
	sc.add_child(col)
	return col


## Hàng nút ở đáy màn hình.
static func bottom_bar(parent: Control) -> HBoxContainer:
	var bar := HBoxContainer.new()
	bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bar.offset_left = 16
	bar.offset_right = -16
	bar.offset_top = -48
	bar.offset_bottom = -12
	bar.alignment = BoxContainer.ALIGNMENT_CENTER
	bar.add_theme_constant_override("separation", 8)
	parent.add_child(bar)
	return bar


static func source_tag(nhan: String) -> Label:
	var l := label("[%s]" % nhan, 10, LABEL_COLORS.get(nhan, C_MUTED), true)
	return l
