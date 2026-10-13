class_name UnitSprite
extends Node2D
## Hình một quân trên bản đồ: dải 2 frame đứng, số máu, sao cấp, biểu tượng trạng thái.

const T := 32
const UNITS_DIR := "res://assets/units/"

var uid: int = 0
var sprite: Sprite2D
var hp_label: Label
var _frame_time := 0.0
var _hp := 100
var _level := 0
var _done := false
var _burning := false
var _asleep := false

static var _fallback_cache: Dictionary = {}


func setup(u: Unit, font: Font) -> void:
	uid = u.uid
	position = Vector2(u.pos * T)
	sprite = Sprite2D.new()
	sprite.centered = false
	sprite.texture = _texture_for(u)
	sprite.hframes = 2 if sprite.texture.get_width() >= T * 2 else 1
	sprite.flip_h = u.faction != "tayson"
	add_child(sprite)
	hp_label = Label.new()
	hp_label.add_theme_font_override("font", font)
	hp_label.add_theme_font_size_override("font_size", 9)
	hp_label.add_theme_color_override("font_color", Color.WHITE)
	hp_label.add_theme_color_override("font_outline_color", Color(0.08, 0.05, 0.05))
	hp_label.add_theme_constant_override("outline_size", 3)
	hp_label.position = Vector2(17, 19)
	hp_label.size = Vector2(15, 12)
	hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(hp_label)
	refresh(u)


func refresh(u: Unit) -> void:
	_hp = u.hp
	_level = u.level
	_done = u.done
	_burning = u.chay_turns > 0
	_asleep = u.ngu
	hp_label.text = str(u.hp) if u.hp < 100 else ""
	sprite.modulate = Color(0.55, 0.55, 0.6) if u.done else Color.WHITE
	queue_redraw()


func _process(delta: float) -> void:
	if sprite.hframes < 2:
		return
	_frame_time += delta
	if _frame_time >= 0.5:
		_frame_time = 0.0
		sprite.frame = 1 - sprite.frame


func _draw() -> void:
	for i in _level:  # sao cấp: chấm vàng góc trên trái
		draw_rect(Rect2(2 + i * 4, 2, 3, 3), Color(0.98, 0.82, 0.25))
		draw_rect(Rect2(2 + i * 4, 2, 3, 3), Color(0.25, 0.12, 0.05), false, 1.0)
	if _burning:
		draw_rect(Rect2(26, 2, 4, 5), Color(1.0, 0.55, 0.1))
		draw_rect(Rect2(27, 1, 2, 2), Color(1.0, 0.9, 0.4))
	if _asleep:
		draw_string(ThemeDB.fallback_font, Vector2(24, 9), "z", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.8, 0.9, 1.0))


static func _texture_for(u: Unit) -> Texture2D:
	var path := "%sunit_%s_%s_dung_strip2.png" % [UNITS_DIR, u.faction, u.type_id]
	if ResourceLoader.exists(path):
		return load(path)
	var fallback := "%sunit_%s_%s_dung_strip2.png" % [UNITS_DIR, u.data()["phe"], u.type_id]
	if ResourceLoader.exists(fallback):
		return load(fallback)
	return _fallback(u.faction)


static func _fallback(faction: String) -> Texture2D:
	if _fallback_cache.has(faction):
		return _fallback_cache[faction]
	var colors := {"tayson": Color(0.8, 0.16, 0.17), "thanh": Color(0.23, 0.38, 0.72),
		"le": Color(0.72, 0.57, 0.23), "dien_tap": Color(0.49, 0.14, 0.16)}
	var img := Image.create(T, T, false, Image.FORMAT_RGBA8)
	var c: Color = colors.get(faction, Color.GRAY)
	for y in T:
		for x in T:
			var d := Vector2(x - 15.5, y - 17.5).length()
			if d < 10:
				img.set_pixel(x, y, c)
			elif d < 11:
				img.set_pixel(x, y, Color(0.1, 0.06, 0.06))
	var tex := ImageTexture.create_from_image(img)
	_fallback_cache[faction] = tex
	return tex
