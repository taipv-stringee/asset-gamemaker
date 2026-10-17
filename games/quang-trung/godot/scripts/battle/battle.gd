class_name Battle
extends Node2D
## Màn hình trận đánh: vẽ bản đồ, quân, xử lý chạm, chạy lượt máy có hoạt cảnh.
## Toàn bộ luật nằm ở Rules / SimpleAI; ở đây chỉ hiển thị và gọi lệnh.

signal battle_finished(result: String)
signal restart_requested
signal exit_requested               # về menu (chế độ chiến dịch)

const T := 32
const TOP_H := 40
const BOTTOM_H := 168   # đủ 3 dòng thông tin + 2 hàng nút cỡ chữ lớn (phản hồi M2)
const FONT_MED := preload("res://assets/fonts/BeVietnamPro-Medium.ttf")
const FONT_BOLD := preload("res://assets/fonts/BeVietnamPro-Bold.ttf")
const C_LACQUER := Color(0.36, 0.09, 0.09)
const C_LACQUER_DARK := Color(0.16, 0.05, 0.05)
const C_GOLD := Color(0.93, 0.73, 0.2)
const C_GOLD_LIGHT := Color(1.0, 0.91, 0.55)
const PLAYER := "tayson"
const OBJECT_TEX := {
	"quan_tan": "res://assets/ui/quan_tan.png",
	"trong": "res://assets/objects/obj_trong_strip2.png",
	"den": "res://assets/objects/obj_den_strip2.png",
	"kho_luong": "res://assets/objects/obj_kho_luong_strip2.png",
}

enum Mode { IDLE, SELECTED, MOVED, TARGETING, FORECAST, BUSY, ENDED }

var state: BattleState
var mode := Mode.IDLE
var selected: Unit = null
var reach: Dictionary = {}
var pending_dest := Vector2i(-1, -1)
var targets: Array[Unit] = []
var forecast_target: Unit = null
var end_turn_armed := false
var auto_play := false            # cả hai phe do máy chơi (kiểm thử)
var story_mode := false           # trong chiến dịch: tự lưu, kết quả do main hiện sau hội thoại
var pause_panel: Panel
var recruit_panel: Panel
var input_locked := false         # đang có hội thoại phủ lên trận
var story_player: Callable        # main đặt: func(phan) phát một phần hội thoại giữa trận (await được)
var hint_panel: Panel
var _hint_queue: Array = []
var _hint_h := 0.0                # chiều cao khung gợi ý đang hiện (camera chừa chỗ)
var _hints_shown: Array = []      # chỉ số gợi ý đã hiện trong trận này (bảng tạm dừng chỉ liệt kê những cái này)

var terrain_layer: TileMapLayer
var objects_layer: Node2D
var overlay: Node2D
var units_layer: Node2D
var fx_layer: Node2D
var night_layer: Node2D            # bóng tối / sương mù theo từng ô (02 §10)
var night_tint: CanvasModulate
var vis: Dictionary = {}           # ô phe người chơi đang thấy (rỗng = ban ngày)
var _obj_time := 0.0
var cursor: Sprite2D
var camera: Camera2D
var sprites: Dictionary = {}       # uid -> UnitSprite
var tile_index: Dictionary = {}

# HUD
var hud: CanvasLayer
var top_label: Label
var gold_label: Label
var bottom: Panel
var portrait: TextureRect
var name_label: Label
var info_label: Label
var buttons: HFlowContainer
var end_button: Button
var banner: Label
var result_panel: Panel

var _touch_start := Vector2.ZERO
var _dragging := false


func start(mission_id: String, p_seed: int = 0) -> void:
	start_from_state(Missions.new_battle(mission_id, p_seed))


## Mở trận từ một trạng thái có sẵn (màn mới, hoặc "Tiếp tục" từ file lưu).
func start_from_state(s: BattleState) -> void:
	state = s
	_build_world()
	_build_hud()
	_refresh_all()
	_center_camera_on(_first_unit_pos())
	_show_banner("Vòng %d · lượt Tây Sơn" % state.vong)
	Sfx.music(state.mission.get("nhac", "chu_de"))
	if auto_play or state.current_faction() != PLAYER:
		_run_ai_turns()
	else:
		_autosave()


# ================================================================ gợi ý hướng dẫn (06 §8)
# Màn khai báo "goi_y": [{"khi": "bat_dau|chon_quan|sau_di|du_bao|mua_linh|len_cap|vong", "n": vòng, "loi": "..."}].
# "neu_co" / "khong_co": cờ trận (vd. "he_qua_trinh_sat_thoat") phải bật / tắt thì gợi ý mới hiện — cho các bản màn đổi theo
# hệ quả màn trước (kiểm thử M3 lần 4: bản đồn đã thức vẫn hiện gợi ý "đang ngủ").
# Mỗi gợi ý hiện một lần (lưu trong tiến trình), không chặn bản đồ; xem lại trong bảng tạm dừng. Chỉ hiện trong chiến dịch.

func hint(trigger: String, n := 0) -> void:
	if not story_mode or mode == Mode.ENDED:
		return
	var list: Array = state.mission.get("goi_y", [])
	for i in list.size():
		var h: Dictionary = list[i]
		if h.get("khi", "") != trigger or (trigger == "vong" and int(h.get("n", 0)) != n):
			continue
		if (h.has("neu_co") and not Rules.has_flag(state, h["neu_co"])) or (h.has("khong_co") and Rules.has_flag(state, h["khong_co"])):
			continue
		var id := "%s/%d" % [state.mission_id, i]
		if Progress.hint_seen(id) or _hint_queue.has(id):
			continue
		_hint_queue.append(id)
	_show_next_hint()


func _show_next_hint() -> void:
	if hint_panel != null or _hint_queue.is_empty():
		return
	var id: String = _hint_queue.pop_front()
	var idx := int(id.get_slice("/", 1))
	var text: String = state.mission["goi_y"][idx]["loi"]
	# Đặt ngay trên bảng dưới (báo cáo M3: đặt dưới thanh trên thì che quân ở các hàng trên cùng, đúng chỗ viện binh hiện).
	# Chạm xuyên qua phần chữ (chỉ nút "Đã hiểu" bắt chạm); camera chừa thêm chỗ để kéo bản đồ ra khỏi chỗ bị che.
	hint_panel = _panel(Color(0.08, 0.1, 0.16, 0.95))
	hint_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	hint_panel.offset_left = 8
	hint_panel.offset_right = -8
	hint_panel.offset_bottom = -BOTTOM_H - 6
	hint_panel.offset_top = -BOTTOM_H - 60
	hud.get_child(0).add_child(hint_panel)
	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.offset_left = 10
	row.offset_right = -6
	row.offset_top = 6
	row.offset_bottom = -6
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint_panel.add_child(row)
	var l := UiKit.wrap_label(text, UiKit.FS_SMALL, Color(0.92, 0.95, 1.0))
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(l)
	_hints_shown.append(idx)
	var ok := UiKit.button("Đã hiểu", func() -> void:
		Progress.mark_hint(id)
		_close_hint()
		_show_next_hint(), UiKit.FS_SMALL, 70)
	ok.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(ok)
	# Chiều cao theo chữ (tối đa 5 dòng).
	await get_tree().process_frame
	if hint_panel != null:
		_hint_h = minf(row.get_combined_minimum_size().y + 12, 140)
		hint_panel.offset_top = -BOTTOM_H - 6 - _hint_h
		camera.position = _clamp_camera(camera.position)


func _close_hint() -> void:
	if hint_panel != null:
		hint_panel.queue_free()
		hint_panel = null
	_hint_h = 0.0


func _autosave() -> void:
	if story_mode and state.result == "":
		Progress.save_battle(state)


func _notification(what: int) -> void:
	# Đưa app xuống nền / đóng cửa sổ: lưu ngay (06 §7).
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		if state != null and mode != Mode.ENDED:
			_autosave()


# ================================================================ dựng cảnh

func _build_world() -> void:
	var tex: Texture2D = load("res://assets/tiles/tiles.png")
	var f := FileAccess.open("res://assets/tiles/tiles.json", FileAccess.READ)
	tile_index = JSON.parse_string(f.get_as_text())
	var ts := TileSet.new()
	ts.tile_size = Vector2i(T, T)
	var src := TileSetAtlasSource.new()
	src.texture = tex
	src.texture_region_size = Vector2i(T, T)
	for i in tex.get_width() / T:
		src.create_tile(Vector2i(i, 0))
	ts.add_source(src, 0)
	terrain_layer = TileMapLayer.new()
	terrain_layer.tile_set = ts
	add_child(terrain_layer)
	objects_layer = Node2D.new()
	add_child(objects_layer)
	night_layer = Node2D.new()
	night_layer.draw.connect(_draw_night)
	add_child(night_layer)
	night_tint = CanvasModulate.new()
	night_tint.color = Color.WHITE
	add_child(night_tint)
	overlay = Node2D.new()
	overlay.draw.connect(_draw_overlay)
	add_child(overlay)
	units_layer = Node2D.new()
	add_child(units_layer)
	cursor = Sprite2D.new()
	cursor.texture = load("res://assets/ui/cursor.png")
	cursor.centered = false
	cursor.visible = false
	add_child(cursor)
	fx_layer = Node2D.new()
	add_child(fx_layer)
	camera = Camera2D.new()
	camera.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	add_child(camera)
	camera.make_current()
	for u in state.units:
		_add_sprite(u)


func _add_sprite(u: Unit) -> UnitSprite:
	var s := UnitSprite.new()
	s.setup(u, FONT_BOLD)
	units_layer.add_child(s)
	sprites[u.uid] = s
	return s


func _tile_key(p: Vector2i) -> String:
	var tid := state.terrain_id(p)
	if state.terrain_at(p)["so_huu"]:
		var o := state.owner_of(p)
		return "%s:%s" % [tid, o if o != "" else "trung_lap"]
	return tid


func _refresh_map() -> void:
	for y in state.height:
		for x in state.width:
			var p := Vector2i(x, y)
			terrain_layer.set_cell(p, 0, Vector2i(int(tile_index.get(_tile_key(p), 0)), 0))
	for c in objects_layer.get_children():
		c.queue_free()
	for p in state.objects:
		var path: String = OBJECT_TEX.get(state.objects[p].get("loai", ""), "")
		if path == "":
			continue
		var s := Sprite2D.new()
		s.texture = load(path)
		s.centered = false
		s.hframes = 2 if s.texture.get_width() >= T * 2 else 1
		s.position = Vector2(p * T)
		objects_layer.add_child(s)
	_update_night()


## Bóng tối, sương mù, ẩn quân địch không thấy. Gọi sau mỗi thay đổi trạng thái.
func _update_night() -> void:
	vis = Rules.visible_tiles(state, PLAYER)
	var dark := Rules.is_dark(state)
	# Sắc đêm xanh lạnh; rạng sáng ấm dần (02 §10).
	if not dark:
		night_tint.color = Color.WHITE
	elif state.tam_nhin >= 5:
		night_tint.color = Color(0.92, 0.88, 0.86)
	elif state.tam_nhin >= 3:
		night_tint.color = Color(0.82, 0.8, 0.9)
	else:
		night_tint.color = Color(0.56, 0.62, 0.9)
	# Quân được bù gần hết sắc đêm: nền tối, quân vẫn rõ màu áo và vật cầm.
	var tint := night_tint.color
	var boost := Color(minf(0.85 / tint.r, 1.6), minf(0.85 / tint.g, 1.6), minf(0.92 / tint.b, 1.6)) if dark else Color.WHITE
	for u in state.units:
		if sprites.has(u.uid):
			var sp: UnitSprite = sprites[u.uid]
			sp.visible = _shown(u)
			if sp.night_boost != boost:
				sp.night_boost = boost
				sp.refresh(u)
	night_layer.queue_redraw()


func _shown(u: Unit) -> bool:
	return state.are_allies(u.faction, PLAYER) or not Rules.is_dark(state) or vis.has(u.pos)


func _draw_night() -> void:
	if not Rules.is_dark(state):
		return
	var lit := Rules.lit_tiles(state)
	var fog := Color(0.01, 0.02, 0.07, 0.68 if state.tam_nhin < 3 else 0.45)
	var dim := Color(0.01, 0.02, 0.07, 0.25 if state.tam_nhin < 3 else 0.12)
	for y in state.height:
		for x in state.width:
			var p := Vector2i(x, y)
			if lit.has(p):
				continue
			var r := Rect2(Vector2(p * T), Vector2(T, T))
			night_layer.draw_rect(r, dim if vis.has(p) else fog)
			if not vis.has(p):
				# viền lốm đốm ở mép sương cho đỡ cứng (pixel art: dither 2px)
				for d in Rules.DIRS:
					if vis.has(p + d):
						_dither_edge(r, d, fog)
	# Quầng sáng ấm quanh nguồn sáng
	for p in Rules.light_sources(state):
		var c := Vector2(p * T) + Vector2(16, 16)
		night_layer.draw_circle(c, 44.0, Color(1.0, 0.55, 0.15, 0.08))
		night_layer.draw_circle(c, 26.0, Color(1.0, 0.7, 0.3, 0.1))


func _dither_edge(r: Rect2, d: Vector2i, c: Color) -> void:
	var soft := Color(c.r, c.g, c.b, c.a * 0.5)
	for i in range(0, T, 4):
		var o := Vector2.ZERO
		match d:
			Vector2i.UP: o = Vector2(i, -2)
			Vector2i.DOWN: o = Vector2(i, T)
			Vector2i.LEFT: o = Vector2(-2, i)
			Vector2i.RIGHT: o = Vector2(T, i)
		night_layer.draw_rect(Rect2(r.position + o, Vector2(2, 2)), soft)


func _process(delta: float) -> void:
	_obj_time += delta
	if _obj_time >= 0.45 and objects_layer != null:
		_obj_time = 0.0
		for c in objects_layer.get_children():
			if c is Sprite2D and c.hframes > 1:
				c.frame = 1 - c.frame


func _refresh_all() -> void:
	_refresh_map()
	UnitSprite.turn_faction = state.current_faction()
	for u in state.units:
		if sprites.has(u.uid):
			sprites[u.uid].refresh(u)
			sprites[u.uid].position = Vector2(u.pos * T)
	_refresh_top()
	overlay.queue_redraw()


# ================================================================ HUD

func _label(font: Font, size: int, color: Color) -> Label:
	var l := Label.new()
	l.add_theme_font_override("font", font)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l


func _panel(color: Color) -> Panel:
	var p := Panel.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.border_color = C_GOLD
	sb.set_border_width_all(0)
	sb.border_width_top = 1
	sb.border_width_bottom = 1
	p.add_theme_stylebox_override("panel", sb)
	p.mouse_filter = Control.MOUSE_FILTER_STOP
	return p


func _build_hud() -> void:
	hud = CanvasLayer.new()
	add_child(hud)
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(root)
	# Thanh trên: tên màn · vòng | vàng | ≡
	var top := _panel(C_LACQUER)
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top.offset_bottom = TOP_H
	root.add_child(top)
	var top_row := HBoxContainer.new()
	top_row.set_anchors_preset(Control.PRESET_FULL_RECT)
	top_row.offset_left = 8
	top_row.offset_right = -4
	top_row.offset_top = 3
	top_row.offset_bottom = -3
	top_row.add_theme_constant_override("separation", 6)
	top.add_child(top_row)
	top_label = _label(FONT_BOLD, UiKit.FS_BUTTON, C_GOLD_LIGHT)
	top_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	top_label.custom_minimum_size.x = 40
	top_row.add_child(top_label)
	gold_label = _label(FONT_BOLD, UiKit.FS_BUTTON, Color.WHITE)
	gold_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top_row.add_child(gold_label)
	var menu_btn := _button("≡", _toggle_pause)
	menu_btn.custom_minimum_size = Vector2(40, TOP_H - 6)
	top_row.add_child(menu_btn)
	# Bảng dưới: [chân dung | tên + thông tin] / [nút hành động (xuống dòng được) | Hết lượt]
	bottom = _panel(C_LACQUER)
	bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom.offset_top = -BOTTOM_H
	root.add_child(bottom)
	var col := VBoxContainer.new()
	col.set_anchors_preset(Control.PRESET_FULL_RECT)
	col.offset_left = 6
	col.offset_right = -6
	col.offset_top = 6
	col.offset_bottom = -6
	col.add_theme_constant_override("separation", 4)
	bottom.add_child(col)
	var info_row := HBoxContainer.new()
	info_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	info_row.add_theme_constant_override("separation", 8)
	col.add_child(info_row)
	var frame := _panel(C_LACQUER_DARK)
	frame.custom_minimum_size = Vector2(52, 52)
	frame.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	info_row.add_child(frame)
	portrait = TextureRect.new()
	portrait.position = Vector2(2, 2)
	portrait.size = Vector2(48, 48)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	frame.add_child(portrait)
	var text_col := VBoxContainer.new()
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.add_theme_constant_override("separation", 0)
	info_row.add_child(text_col)
	name_label = _label(FONT_BOLD, UiKit.FS_HEAD, C_GOLD_LIGHT)
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_label.custom_minimum_size.x = 40
	text_col.add_child(name_label)
	info_label = _label(FONT_MED, UiKit.FS_SMALL, Color.WHITE)
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_label.custom_minimum_size.x = 40
	info_label.max_lines_visible = 3
	text_col.add_child(info_label)
	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 6)
	col.add_child(btn_row)
	buttons = HFlowContainer.new()
	buttons.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buttons.add_theme_constant_override("h_separation", 5)
	buttons.add_theme_constant_override("v_separation", 5)
	btn_row.add_child(buttons)
	end_button = _button("Hết lượt", _on_end_turn_pressed)
	end_button.size_flags_vertical = Control.SIZE_SHRINK_END
	btn_row.add_child(end_button)
	# Băng thông báo
	banner = _label(FONT_BOLD, 18, C_GOLD_LIGHT)
	banner.set_anchors_preset(Control.PRESET_CENTER_TOP)
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.add_theme_color_override("font_outline_color", C_LACQUER_DARK)
	banner.add_theme_constant_override("outline_size", 6)
	banner.set_anchors_preset(Control.PRESET_TOP_WIDE)
	banner.offset_left = 8
	banner.offset_right = -8
	banner.offset_top = TOP_H + 10
	banner.offset_bottom = TOP_H + 60
	banner.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	banner.modulate.a = 0.0
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(banner)
	_show_idle_info()


func _button(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_override("font", FONT_BOLD)
	b.add_theme_font_size_override("font_size", UiKit.FS_BUTTON)
	var normal := StyleBoxFlat.new()
	normal.bg_color = C_LACQUER_DARK
	normal.border_color = C_GOLD
	normal.border_width_top = 1
	normal.border_width_bottom = 1
	normal.content_margin_left = 9
	normal.content_margin_right = 9
	normal.content_margin_top = 6
	normal.content_margin_bottom = 6
	var pressed := normal.duplicate()
	pressed.bg_color = Color(0.5, 0.15, 0.12)
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", normal)
	b.add_theme_stylebox_override("pressed", pressed)
	b.add_theme_stylebox_override("focus", normal)
	b.add_theme_color_override("font_color", C_GOLD_LIGHT)
	b.custom_minimum_size = Vector2(44, 40)
	var disabled := normal.duplicate()
	disabled.bg_color = Color(0.13, 0.08, 0.08)
	b.add_theme_stylebox_override("disabled", disabled)
	b.add_theme_color_override("font_disabled_color", Color(0.5, 0.42, 0.36))
	b.pressed.connect(func() -> void: Sfx.play("cham", -6.0))
	b.pressed.connect(cb)
	return b


func _set_buttons(list: Array) -> void:
	for c in buttons.get_children():
		c.queue_free()
	for item in list:
		buttons.add_child(_button(item[0], item[1]))


func _refresh_top() -> void:
	var name: String = state.mission.get("ten_ngan", state.mission.get("ten", ""))
	var limit := int(state.mission.get("thua_het_luot", 0))
	# Vòng đứng trước: màn hẹp thì phần bị cắt là tên màn chứ không phải số vòng.
	top_label.text = "Vòng %d%s · %s" % [state.vong, ("/%d" % limit) if limit > 0 else "", name]
	gold_label.text = "%d vàng" % int(state.gold.get(PLAYER, 0))
	end_button.disabled = mode == Mode.BUSY or mode == Mode.ENDED or state.current_faction() != PLAYER


func _portrait_for(u: Unit) -> Texture2D:
	var path := "res://assets/portraits/portrait_%s.png" % u.type_id
	if ResourceLoader.exists(path):
		return load(path)
	return sprites[u.uid].sprite.texture if sprites.has(u.uid) else null


func _unit_info(u: Unit) -> void:
	var d := u.data()
	portrait.texture = _portrait_for(u)
	if portrait.texture != null and portrait.texture.get_width() == T * 2:
		var at := AtlasTexture.new()
		at.atlas = portrait.texture
		at.region = Rect2(0, 0, T, T)
		portrait.texture = at
	name_label.text = "%s%s" % [u.display_name(), ("  · cấp %d" % u.level) if u.level > 0 else ""]
	var lines := "Máu %d   Công %d–%d   Thủ %d\nDi %d   Tầm %s" % [u.hp,
		int(d["cong_min"]) + u.level * Rules.LEVEL_ATK, int(d["cong_max"]) + u.level * Rules.LEVEL_ATK,
		int(d["thu"]) + u.level * Rules.LEVEL_DEF, Rules.move_points(state, u),
		str(d["tam_min"]) if d["tam_min"] == d["tam_max"] else "%d–%d" % [d["tam_min"], d["tam_max"]]]
	var notes: PackedStringArray = []
	if u.chay_turns > 0:
		notes.append("đang Cháy")
	if u.ngu:
		notes.append("đang ngủ")
	if u.duoc and Rules.is_dark(state):
		notes.append("cầm đuốc: ô quanh sáng, địch thấy từ xa")
	if u.ai_mode == "do_tham":
		notes.append("dò thám: thấy quân ta trong %d ô sẽ chạy" % int(u.ai_params.get("thay", 3)))
	elif u.ai_mode == "chay" and u.ai_params.has("khu"):
		notes.append("đang chạy về báo tin")
	if not notes.is_empty():
		lines += "   (" + ", ".join(notes) + ")"
	info_label.text = lines


func _terrain_info(p: Vector2i) -> void:
	var t := state.terrain_at(p)
	portrait.texture = null
	name_label.text = t["ten"]
	var parts: PackedStringArray = ["Thủ %+d" % int(t["thu"])]
	if Rules.tile_income(state, p) > 0:
		parts.append("+%d vàng mỗi vòng" % Rules.tile_income(state, p))
	if t["mua_linh"]:
		parts.append("mua lính")
	var o := state.owner_of(p)
	if t["so_huu"]:
		parts.append("chủ: %s" % _faction_name(o))
	var obj: String = state.object_at(p).get("loai", "")
	var obj_note: String = {"trong": "\nTrống báo động: quân địch kêu hay đứng cạnh trống thì cả khu đồn thức.",
		"den": "\nĐèn: ô này và 4 ô kề luôn sáng; lính canh thấy quân ta ở đây từ 5 ô.",
		"quan_tan": "\nQuân tan: không đi vào được; quân sư chiêu hàng được."}.get(obj, "")
	# Khung chữ chỉ 3 dòng: trạng thái vây thay cho ghi chú khu (ghi chú vẫn còn trong gợi ý), không thì bị cắt mất
	# (kiểm thử M3 lần 4, lỗi 1).
	var zn := state.zone_of(p)
	if Rules.fort_zones(state).has(zn) and not Rules.zone_enemies(state, zn, PLAYER).is_empty():
		var zone_name := "Khu đồn"
		for z in state.mission.get("hien_khu", []):
			if z["khu"] == zn and z.has("ten"):
				zone_name = String(z["ten"]).left(1).to_upper() + String(z["ten"]).substr(1)
		var gaps := Rules.siege_gaps(state, zn, PLAYER).size()
		obj_note += ("\n%s đã bị vây: quân sư / tướng đứng kề khu thì Gọi hàng được." % zone_name) if gaps == 0 else \
			("\n%s chưa bị vây: còn %d ô hở (dấu ×), cần quân ta đứng hay lính giáo kề." % [zone_name, gaps])
	else:
		for z in state.mission.get("hien_khu", []):
			if (state.zones.get(z["khu"], []) as Array).has(p) and z.has("ghi"):
				obj_note += "\n" + String(z["ghi"])
	if obj == "kho_luong":
		obj_note += "\nKho lương: tướng hay lính giáo đứng lên rồi Lấy kho lương."
	if Rules.is_dark(state) and not vis.has(p) and not Rules.lit_tiles(state).has(p):
		obj_note += "\nTrong bóng tối: không thấy quân địch."
	info_label.text = "   ".join(parts) + obj_note


func _faction_name(f: String) -> String:
	return {"tayson": "Tây Sơn", "thanh": "quân Thanh", "le": "quân Lê", "dien_tap": "Diễn tập", "": "chưa có"}.get(f, f)


func _show_idle_info() -> void:
	portrait.texture = null
	name_label.text = "Lượt của %s" % _faction_name(state.current_faction())
	var can_buy: bool = not state.buyable.get(PLAYER, PackedStringArray()).is_empty()
	info_label.text = "Chạm một quân để chọn.%s Kéo để xem bản đồ." % (" Chạm đồn trống của ta để mua lính." if can_buy else "")
	_set_buttons([])


func _show_banner(text: String, color: Color = C_GOLD_LIGHT, hold := 0.9) -> void:
	banner.text = text
	banner.add_theme_color_override("font_color", color)
	var tw := create_tween()
	tw.tween_property(banner, "modulate:a", 1.0, 0.15)
	tw.tween_interval(hold)
	tw.tween_property(banner, "modulate:a", 0.0, 0.3)


# ================================================================ camera

func _view_size() -> Vector2:
	return get_viewport_rect().size


func _map_px() -> Vector2:
	return Vector2(state.width * T, state.height * T)


func _clamp_camera(pos: Vector2) -> Vector2:
	var vs := _view_size()
	var map := _map_px()
	var area_h := vs.y - TOP_H - BOTTOM_H - _hint_h
	var x: float
	if map.x <= vs.x:
		x = -(vs.x - map.x) / 2.0
	else:
		x = clampf(pos.x, 0.0, map.x - vs.x)
	var y: float
	if map.y <= area_h:
		y = -TOP_H - (area_h - map.y) / 2.0
	else:
		y = clampf(pos.y, -TOP_H, map.y - area_h - TOP_H)
	return Vector2(roundf(x), roundf(y))


func _center_camera_on(p: Vector2i) -> void:
	var vs := _view_size()
	var area_h := vs.y - TOP_H - BOTTOM_H - _hint_h
	camera.position = _clamp_camera(Vector2(p * T) + Vector2(T, T) / 2.0 - Vector2(vs.x / 2.0, TOP_H + area_h / 2.0))


func _first_unit_pos() -> Vector2i:
	for u in state.units:
		if u.faction == PLAYER and u.tuong_chinh:
			return u.pos
	return Vector2i(state.width / 2, state.height - 1)


# ================================================================ chạm

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_touch_start = event.position
			_dragging = false
		elif not _dragging:
			_on_tap(event.position)
	elif event is InputEventScreenDrag:
		if _dragging or event.position.distance_to(_touch_start) > 6.0:
			_dragging = true
			camera.position = _clamp_camera(camera.position - event.relative)


func _screen_to_tile(screen: Vector2) -> Vector2i:
	var world := get_viewport().get_canvas_transform().affine_inverse() * screen
	return Vector2i(floori(world.x / T), floori(world.y / T))


func _on_tap(screen: Vector2) -> void:
	if mode == Mode.BUSY or mode == Mode.ENDED or state.current_faction() != PLAYER:
		return
	if pause_panel != null or input_locked:
		return
	if recruit_panel != null:
		_close_recruit()
	var p := _screen_to_tile(screen)
	if not state.in_bounds(p):
		return
	# Đồng bộ lại hình mọi quân (xám / máu) mỗi lần chạm: báo cáo M3 lần 3 thấy một lần quân đã xong lượt chưa xám.
	UnitSprite.turn_faction = state.current_faction()
	for su in state.units:
		if sprites.has(su.uid):
			sprites[su.uid].refresh(su)
	cursor.visible = true
	cursor.position = Vector2(p * T)
	end_turn_armed = false
	var u := state.unit_at(p)
	if u != null and not _shown(u):
		u = null  # quân địch trong sương: người chơi không biết
	match mode:
		Mode.IDLE:
			_tap_idle(p, u)
		Mode.SELECTED:
			_tap_selected(p, u)
		Mode.MOVED, Mode.TARGETING, Mode.FORECAST:
			_tap_moved(p, u)
	overlay.queue_redraw()


func _tap_idle(p: Vector2i, u: Unit) -> void:
	if u != null and u.faction == PLAYER and not u.done:
		_select(u)
	elif u != null:
		_unit_info(u)
		_set_buttons([])
	elif not Rules.recruit_options(state, PLAYER, p).is_empty():
		_show_recruit(p)
	else:
		_terrain_info(p)
		_set_buttons([])


func _select(u: Unit) -> void:
	Sfx.play("chon", -4.0)
	hint("chon_quan")
	selected = u
	reach = Rules.reachable(state, u, true)
	targets = Rules.targets_from(state, u, u.pos, false)
	pending_dest = Vector2i(-1, -1)
	mode = Mode.SELECTED
	_unit_info(u)
	_set_buttons([["Đứng yên", func() -> void: _do_move(u.pos)], ["Bỏ chọn", _deselect]])


func _deselect() -> void:
	selected = null
	reach = {}
	targets = []
	forecast_target = null
	mode = Mode.IDLE
	cursor.visible = false
	_show_idle_info()
	overlay.queue_redraw()


func _tap_selected(p: Vector2i, u: Unit) -> void:
	if u != null and u != selected and u.faction == PLAYER and not u.done:
		_select(u)
		return
	if u != null and not state.are_allies(u.faction, PLAYER) and targets.has(u):
		# đánh ngay từ chỗ đứng
		_do_move(selected.pos)
		_open_forecast(u)
		return
	if reach.has(p):
		if pending_dest == p or p == selected.pos:
			_do_move(p)
		else:
			pending_dest = p
			name_label.text = selected.display_name()
			info_label.text = "Chạm lại ô này để đi."
		return
	if u != null:
		_unit_info(u)
	else:
		_deselect()


func _do_move(p: Vector2i) -> void:
	var u := selected
	var stay := p == u.pos
	var ev := [] as Array[Dictionary] if stay else Rules.cmd_move(state, u, p, true)
	if stay:
		u.moved = true
		u.move_origin = u.pos
	mode = Mode.BUSY
	await _play(ev)
	mode = Mode.MOVED
	reach = {}
	_refresh_top()  # bật lại nút Hết lượt (bị tắt trong lúc BUSY)
	_show_actions()
	hint("sau_di")


func _show_actions() -> void:
	var u := selected
	targets = Rules.targets_from(state, u, u.pos, u.pos != u.move_origin)
	var list: Array = []
	if not targets.is_empty():
		list.append(["Đánh", func() -> void:
			mode = Mode.TARGETING
			info_label.text = "Chạm quân địch (ô đỏ) để xem dự báo."
			overlay.queue_redraw()])
	if Rules.can_capture(state, u):
		var granary: bool = state.object_at(u.pos).get("loai", "") == "kho_luong"
		list.append(["Lấy kho lương" if granary else "Chiếm", func() -> void: _run(Rules.cmd_capture(state, u))])
	for zname in Rules.goi_hang_zones(state, u):
		list.append(["Gọi hàng", func() -> void: _open_goi_hang(u, zname)])
	var ch := Rules.chieu_hang_targets(state, u)
	if not ch.is_empty():
		list.append(["Chiêu hàng", func() -> void: _run(Rules.cmd_chieu_hang(state, u, ch[0]))])
	list.append(["Chờ", func() -> void: _run(Rules.cmd_wait(state, u))])
	if u.pos != u.move_origin and not u.khoa_hoan_tac:
		list.append(["Hoàn tác", _undo])
	_unit_info(u)
	_set_buttons(list)
	overlay.queue_redraw()


## Gọi hàng (02 §11): kết quả tất định nên cho xem trước con số rồi mới gọi.
func _open_goi_hang(u: Unit, zname: String) -> void:
	var fc := Rules.goi_hang_forecast(state, zname, u.faction)
	name_label.text = "Gọi hàng · %s" % _zone_title(zname)
	# Bảng dưới chỉ đủ 3 dòng (báo cáo M2): viết gọn.
	info_label.text = "Ta: %d máu trong 2 ô quanh khu.\nCần %d (%s).\n%s" % [
		fc["ta"], fc["can"], ("đồn %d máu, ngủ: ½" % fc["dich"]) if fc["ngu_qua_nua"] else ("đồn %d máu, đã thức" % fc["dich"]),
		"✓ Đủ: sẽ ra hàng." if fc["thanh_cong"] else "✗ Chưa đủ: gọi sẽ không thành."]
	_set_buttons([["Gọi", func() -> void: _run(Rules.cmd_goi_hang(state, u, zname))], ["Thôi", _show_actions]])


func _zone_title(zname: String) -> String:
	for z in state.mission.get("hien_khu", []):
		if z["khu"] == zname and z.has("ten"):
			return String(z["ten"])
	return "khu đồn"


func _undo() -> void:
	var u := selected
	Rules.cmd_undo_move(state, u)
	sprites[u.uid].position = Vector2(u.pos * T)
	_select(u)
	overlay.queue_redraw()


func _tap_moved(p: Vector2i, u: Unit) -> void:
	if u != null and targets.has(u):
		if mode == Mode.FORECAST and forecast_target == u:
			_run(Rules.cmd_attack(state, selected, u))
		else:
			_open_forecast(u)
	elif u != null:
		_unit_info(u)


func _open_forecast(t: Unit) -> void:
	hint("du_bao")
	forecast_target = t
	mode = Mode.FORECAST
	var fc := Rules.forecast(state, selected, selected.pos, t, selected.straight_steps)
	_unit_info(t)
	var txt := "Gây %d–%d · hạ %d%%" % [fc["st_min"], fc["st_max"], roundi(fc["ti_le_ha"] * 100.0)]
	if fc["phan_don"]:
		txt += " · phản đòn %d–%d" % [fc["pd_min"], fc["pd_max"]]
	else:
		txt += " · không phản đòn"
	info_label.text = txt + "\nChạm lần nữa để đánh"
	_set_buttons([["Đánh", func() -> void: _run(Rules.cmd_attack(state, selected, t))], ["Thôi", _show_actions]])
	overlay.queue_redraw()


func _run(ev: Array[Dictionary]) -> void:
	mode = Mode.BUSY
	_refresh_top()
	await _play(ev)
	selected = null
	forecast_target = null
	targets = []
	reach = {}
	cursor.visible = false
	if state.result != "":
		_finish()
		return
	mode = Mode.IDLE
	_show_idle_info()
	_refresh_all()


## Bảng mua lính (06 §4): hình, giá, chỉ số, đặc tính; không đủ vàng / đủ quân thì mờ.
func _show_recruit(p: Vector2i) -> void:
	_close_recruit()
	hint("mua_linh")
	portrait.texture = null
	name_label.text = "Mua lính — %d vàng" % int(state.gold.get(PLAYER, 0))
	info_label.text = "Quân: %d/%d. Lính mới đứng ở đồn, đi được từ vòng sau." % [state.count_toward_limit(PLAYER), int(state.limits.get(PLAYER, 0))]
	_set_buttons([["Đóng", _close_recruit]])
	var data := GameData.get_data()
	recruit_panel = _panel(Color(0.12, 0.04, 0.04, 0.97))
	recruit_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	recruit_panel.offset_left = 6
	recruit_panel.offset_right = -6
	recruit_panel.offset_bottom = -BOTTOM_H - 4
	hud.get_child(0).add_child(recruit_panel)
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 6
	scroll.offset_right = -6
	scroll.offset_top = 6
	scroll.offset_bottom = -6
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	recruit_panel.add_child(scroll)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 3)
	scroll.add_child(col)
	var opts := Rules.recruit_options(state, PLAYER, p)
	for id in opts:
		var d := data.unit(id)
		var tam := str(d["tam_min"]) if d["tam_min"] == d["tam_max"] else "%d–%d" % [d["tam_min"], d["tam_max"]]
		var text := "%s · %d\nCông %d–%d  Thủ %d  Di %d  Tầm %s" % [d["ten"], d["gia"], d["cong_min"], d["cong_max"], d["thu"], d["di"], tam]
		var b := UiKit.list_button(text, func() -> void:
			_close_recruit()
			_run(Rules.cmd_recruit(state, PLAYER, p, id)), UiKit.FS_SMALL)
		b.custom_minimum_size = Vector2(0, 54)
		b.icon = _unit_icon(id)
		b.add_theme_constant_override("icon_max_width", 32)
		b.disabled = not Rules.can_afford(state, PLAYER, id)
		col.add_child(b)
	# Cao theo nội dung thật (nút hai dòng cao hơn custom_minimum_size), tối đa là chỗ trống giữa hai thanh; dư thì cuộn.
	var room := _view_size().y - TOP_H - BOTTOM_H - 12
	recruit_panel.offset_top = -BOTTOM_H - 4 - minf(col.get_combined_minimum_size().y + 12, room)


func _unit_icon(id: String) -> Texture2D:
	var path := "res://assets/units/unit_%s_%s_dung_strip2.png" % [PLAYER, id]
	if not ResourceLoader.exists(path):
		return null
	var at := AtlasTexture.new()
	at.atlas = load(path)
	at.region = Rect2(0, 0, T, T)
	return at


func _close_recruit() -> void:
	if recruit_panel != null:
		recruit_panel.queue_free()
		recruit_panel = null
		_show_idle_info()


func _on_end_turn_pressed() -> void:
	if mode == Mode.BUSY or mode == Mode.ENDED or state.current_faction() != PLAYER:
		return
	var left := 0
	for u in state.units_of(PLAYER):
		if not u.done:
			left += 1
	if left > 0 and not end_turn_armed:
		end_turn_armed = true
		name_label.text = "Còn %d quân chưa đi" % left
		info_label.text = "Bấm \"Hết lượt\" lần nữa để kết thúc lượt."
		return
	end_turn_armed = false
	_deselect()
	mode = Mode.BUSY
	var ev := Rules.cmd_end_turn(state)
	await _play(ev)
	await _run_ai_turns()


func _run_ai_turns() -> void:
	mode = Mode.BUSY
	_refresh_top()
	while state.result == "" and (auto_play or state.current_faction() != PLAYER):
		_show_banner("Lượt %s" % _faction_name(state.current_faction()))
		var guard := 0
		while guard < 200:
			guard += 1
			var a := SimpleAI.next_action(state)
			if a.is_empty():
				break
			var ev := SimpleAI.execute(state, a)
			if ev.is_empty():
				var stuck := state.unit_by_uid(a.get("uid", -1))
				if stuck != null:
					stuck.done = true
				continue
			if a.get("lenh", "") == "ke_hoach":
				var u := state.unit_by_uid(a["uid"])
				if u != null and _shown(u):
					_center_camera_on(u.pos)
			await _play(ev)
			if state.result != "":
				break
		if state.result != "":
			break
		await _play(Rules.cmd_end_turn(state))
		if auto_play and state.vong > 40:
			break
	if state.result != "":
		_finish()
		return
	mode = Mode.IDLE
	_show_banner("Vòng %d · lượt Tây Sơn" % state.vong)
	_show_idle_info()
	_refresh_all()
	_autosave()
	hint("vong", state.vong)


# ================================================================ hoạt cảnh

func _play(events: Array[Dictionary]) -> void:
	for e in events:
		match e["loai"]:
			"di":
				var s: UnitSprite = sprites.get(e["uid"])
				var mu := state.unit_by_uid(e["uid"])
				if s != null and mu != null and not state.are_allies(mu.faction, PLAYER) and Rules.is_dark(state):
					# quân địch đi trong sương: chỉ hiện nếu điểm đầu hoặc cuối thấy được
					var path: Array = e["duong"]
					s.visible = vis.has(path[0]) or Rules.can_see(state, PLAYER, path[-1])
					if not s.visible:
						s.position = Vector2(path[-1] * T)
						continue
				if s != null:
					if mu != null and e["duong"].size() > 1:
						Sfx.play("voi_buoc" if mu.has_tag("voi") else "di", -6.0)
					var tw := create_tween()
					for p in e["duong"].slice(1):
						tw.tween_property(s, "position", Vector2(p * T), 0.07)
					await tw.finished
			"danh":
				var a: UnitSprite = sprites.get(e["uid"])
				var d: UnitSprite = sprites.get(e["muc_tieu"])
				if a != null and d != null:
					_attack_sound(e)
					var dir := (d.position - a.position).normalized() * 5.0
					var home := a.position
					var tw := create_tween()
					tw.tween_property(a, "position", home + dir, 0.08)
					tw.tween_property(a, "position", home, 0.1)
					await tw.finished
					_float_text(d.position + Vector2(8, -2), "-%d" % e["st"], Color(1, 0.85, 0.3))
					var du := state.unit_by_uid(e["muc_tieu"])
					if du != null:
						d.refresh(du)
					await get_tree().create_timer(0.25).timeout
			"ha":
				var s: UnitSprite = sprites.get(e["uid"])
				if s != null and s.visible:
					Sfx.play("ha", -3.0)
				if s != null:
					sprites.erase(e["uid"])
					var tw := create_tween()
					tw.tween_property(s, "modulate:a", 0.0, 0.3)
					await tw.finished
					s.queue_free()
			"tuyen_quan":
				var tu := state.unit_by_uid(e["uid"])
				if tu != null and not sprites.has(tu.uid):
					var ts := _add_sprite(tu)
					ts.modulate.a = 0.0
					create_tween().tween_property(ts, "modulate:a", 1.0, 0.3)
					Sfx.play("mua", -4.0)
					_float_text(ts.position + Vector2(-6, -6), "Tuyển quân!", C_GOLD_LIGHT)
			"hoi_thoai":
				if story_player.is_valid():
					await story_player.call(e["phan"])
			"bang":
				_show_banner(e["chu"])
				await get_tree().create_timer(1.0).timeout
			"vien_binh":
				var vu := state.unit_by_uid(e["uid"])
				if vu != null and not sprites.has(vu.uid):
					var vs := _add_sprite(vu)
					vs.modulate.a = 0.0
					create_tween().tween_property(vs, "modulate:a", 1.0, 0.3)
					if _shown(vu):
						_show_banner("Viện binh %s!" % _faction_name(vu.faction), Color(1, 0.6, 0.5))
			"mua", "chieu_hang":
				Sfx.play("mua", -4.0)
				var nu := state.unit_by_uid(e.get("uid_moi", e["uid"]))
				if nu != null and not sprites.has(nu.uid):
					var s := _add_sprite(nu)
					s.modulate.a = 0.0
					create_tween().tween_property(s, "modulate:a", 1.0, 0.25)
			"len_cap":
				Sfx.play("len_cap", -3.0)
				var lu := state.unit_by_uid(e["uid"])
				if lu != null and lu.faction == PLAYER:
					hint("len_cap")
				var s: UnitSprite = sprites.get(e["uid"])
				if s != null:
					_float_text(s.position + Vector2(0, -6), "Lên cấp!", C_GOLD_LIGHT)
			"chiem":
				Sfx.play("chiem", -3.0)
			"vang":
				if e["phe"] == PLAYER:
					Sfx.play("vang", -8.0)
					_float_text(camera.position + Vector2(_view_size().x - 70, TOP_H + 4), "+%d vàng" % e["them"], C_GOLD_LIGHT)
			"bat_dau_luot":
				_refresh_top()
			"bao_dong":
				Sfx.play("bao_dong", -2.0)
				var who := state.unit_by_uid(e["uid"])
				# Phản hồi M2: chữ nhỏ đỏ sẫm dễ lỡ → luôn có thêm dải chữ to giữa màn.
				if who != null and _shown(who) and sprites.has(who.uid):
					_float_text(sprites[who.uid].position + Vector2(-4, -6), "Báo động!", Color(1, 0.45, 0.38))
					_show_banner("Báo động! Quân %s đã thức." % _faction_name(who.faction).trim_prefix("quân "), Color(1, 0.55, 0.45))
				else:
					_show_banner("Có tiếng hô báo động trong đêm!", Color(1, 0.55, 0.45))
				await get_tree().create_timer(0.5).timeout
			"trong_bao_dong":
				Sfx.play("trong_bao_dong")
				_show_banner("Trống báo động! Cả đồn đã thức.", Color(1, 0.55, 0.45))
				await _shake(0.6)
			"phuc_kich":
				Sfx.play("phuc_kich")
				_update_night()
				var foe: UnitSprite = sprites.get(e["dich"])
				if foe != null:
					foe.visible = true
					_float_text(foe.position + Vector2(0, -6), "Phục kích!", Color(1, 0.45, 0.3))
				await get_tree().create_timer(0.4).timeout
			"trinh_sat_chay":
				var su: UnitSprite = sprites.get(e["uid"])
				if su != null and su.visible:
					Sfx.play("lo_dien", -4.0)
					_float_text(su.position + Vector2(-4, -6), "Chạy!", Color(1, 0.6, 0.4))
					_show_banner("Trinh sát thấy quân ta, bỏ chạy về báo tin!", Color(1, 0.6, 0.45))
					await get_tree().create_timer(0.6).timeout
			"thoat":
				var es: UnitSprite = sprites.get(e["uid"])
				if es != null:
					sprites.erase(e["uid"])
					var tw := create_tween()
					tw.tween_property(es, "modulate:a", 0.0, 0.4)
					await tw.finished
					es.queue_free()
				Sfx.play("bao_dong", -6.0)
				# Báo cáo M3 lần 3: dải này dễ lỡ → giữ lâu hơn và dừng một nhịp.
				_show_banner("Một trinh sát đã thoát về báo tin!", Color(1, 0.5, 0.42), 2.2)
				await get_tree().create_timer(1.8).timeout
			"goi_hang":
				Sfx.play("len_cap" if e["thanh_cong"] else "lo_dien", -3.0)
				if e["thanh_cong"]:
					_show_banner("Quân trong đồn ra hàng!", C_GOLD_LIGHT, 1.8)
				else:
					_show_banner("Gọi hàng không thành: cần %d máu quanh khu, mới có %d." % [e["can"], e["ta"]], Color(1, 0.6, 0.45), 1.8)
				await get_tree().create_timer(1.0).timeout
			"ra_hang":
				var rs: UnitSprite = sprites.get(e["uid"])
				if rs != null:
					sprites.erase(e["uid"])
					var tw := create_tween()
					tw.tween_property(rs, "modulate:a", 0.0, 0.25)
					await tw.finished
					rs.queue_free()
				var nu2 := state.unit_by_uid(int(e["uid_moi"]))
				if nu2 != null and not sprites.has(nu2.uid):
					var ns := _add_sprite(nu2)
					ns.modulate.a = 0.0
					create_tween().tween_property(ns, "modulate:a", 1.0, 0.25)
				elif nu2 == null:
					_float_text(Vector2(e["o"] * T) + Vector2(0, -6), "Tù binh", C_GOLD_LIGHT)
			"lay_kho":
				Sfx.play("chiem", -3.0)
				_show_banner("Đã lấy kho lương!", C_GOLD_LIGHT)
			"lo_dien":
				Sfx.play("lo_dien", -6.0)
				var seen: UnitSprite = sprites.get(e["uid"])
				if seen != null:
					seen.visible = true
					_float_text(seen.position + Vector2(12, -6), "!", Color(1, 0.9, 0.4))
		_refresh_map()
		UnitSprite.turn_faction = state.current_faction()
		for u in state.units:
			if sprites.has(u.uid):
				sprites[u.uid].refresh(u)
		_refresh_top()


## Tiếng đánh theo loại quân: hỏa mai bắn xa → súng; hỏa hổ → lửa; voi → rống; còn lại → chém.
func _attack_sound(e: Dictionary) -> void:
	var att := state.unit_by_uid(e["uid"])
	var def := state.unit_by_uid(e["muc_tieu"])
	var far := att != null and def != null and Rules.manhattan(att.pos, def.pos) > 1
	var name := "danh"
	if att != null:
		if att.has_tag("gay_chay") and not e.get("phan_don", false):
			name = "lua"
		elif att.has_tag("ban_xa"):
			name = "sung"
		elif att.has_tag("voi") and not e.get("phan_don", false) and randf() < 0.5:
			name = "voi_rong"
	Sfx.play(name, -3.0 if not far else 0.0)
	get_tree().create_timer(0.14).timeout.connect(func() -> void: Sfx.play("trung", -6.0))


func _shake(duration: float) -> void:
	var home := camera.offset
	var tw := create_tween()
	var steps := int(duration / 0.05)
	for i in steps:
		tw.tween_property(camera, "offset", home + Vector2(randf_range(-3, 3), randf_range(-2, 2)).round(), 0.05)
	tw.tween_property(camera, "offset", home, 0.05)
	await tw.finished


func _float_text(pos: Vector2, text: String, color: Color) -> void:
	var l := _label(FONT_BOLD, 13, color)
	l.text = text
	l.add_theme_color_override("font_outline_color", Color(0.08, 0.04, 0.04))
	l.add_theme_constant_override("outline_size", 3)
	# Giữ chữ trong khung nhìn: quân ở cột sát mép phải thì chữ không bị cắt.
	var left := camera.position.x + 2.0
	var right := camera.position.x + _view_size().x - l.get_combined_minimum_size().x - 2.0
	pos.x = clampf(pos.x, left, maxf(left, right))
	l.position = pos
	fx_layer.add_child(l)
	var tw := create_tween()
	tw.tween_property(l, "position", pos + Vector2(0, -14), 0.6)
	tw.parallel().tween_property(l, "modulate:a", 0.0, 0.6).set_delay(0.3)
	tw.tween_callback(l.queue_free)


func _draw_overlay() -> void:
	# Khu đồn chưa bị vây: dấu × đỏ trên các ô kề ngoài khu còn hở (02 §11) — chỉ trong lượt người chơi.
	if state.current_faction() == PLAYER and state.result == "":
		for zname in Rules.fort_zones(state):
			if Rules.zone_enemies(state, zname, PLAYER).is_empty():
				continue
			for p in Rules.siege_gaps(state, zname, PLAYER):
				var c := Vector2(p * T) + Vector2(T / 2.0, T / 2.0)
				overlay.draw_line(c + Vector2(-5, -5), c + Vector2(5, 5), Color(1, 0.35, 0.3, 0.9), 2.0)
				overlay.draw_line(c + Vector2(-5, 5), c + Vector2(5, -5), Color(1, 0.35, 0.3, 0.9), 2.0)
	# Khu kịch bản cho người chơi thấy ("hien_khu": [{khu, mau: vang|do}]): vùng thắng, đường thoát của trinh sát…
	for z in state.mission.get("hien_khu", []):
		var c := Color(1.0, 0.35, 0.25) if z.get("mau", "vang") == "do" else C_GOLD_LIGHT
		var cells: Array = state.zones.get(z["khu"], [])
		for p in cells:
			var r := Rect2(Vector2(p * T), Vector2(T, T))
			overlay.draw_rect(r, Color(c, 0.16))
			for d in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
				if not cells.has(p + d):
					var a := r.get_center() + Vector2(d) * (T / 2.0 - 1.0) - Vector2(d.y, d.x) * (T / 2.0 - 1.0)
					var b := r.get_center() + Vector2(d) * (T / 2.0 - 1.0) + Vector2(d.y, d.x) * (T / 2.0 - 1.0)
					overlay.draw_dashed_line(a, b, Color(c, 0.85), 2.0, 4.0)
	if selected != null and mode == Mode.SELECTED:
		for p in reach:
			overlay.draw_rect(Rect2(Vector2(p * T), Vector2(T, T)), Color(0.35, 0.6, 1.0, 0.33))
			overlay.draw_rect(Rect2(Vector2(p * T), Vector2(T, T)), Color(0.55, 0.75, 1.0, 0.5), false, 1.0)
		if reach.has(pending_dest):
			var path: Array = reach[pending_dest]["duong"]
			for i in range(1, path.size()):
				overlay.draw_line(Vector2(path[i - 1] * T) + Vector2(16, 16), Vector2(path[i] * T) + Vector2(16, 16), C_GOLD_LIGHT, 2.0)
	if selected != null and mode in [Mode.SELECTED, Mode.MOVED, Mode.TARGETING, Mode.FORECAST]:
		for t in targets:
			overlay.draw_rect(Rect2(Vector2(t.pos * T), Vector2(T, T)), Color(1.0, 0.25, 0.2, 0.35))
			overlay.draw_rect(Rect2(Vector2(t.pos * T), Vector2(T, T)), Color(1.0, 0.4, 0.3, 0.8), false, 1.0)
		overlay.draw_rect(Rect2(Vector2(selected.pos * T), Vector2(T, T)), C_GOLD_LIGHT, false, 1.0)
	if forecast_target != null and mode == Mode.FORECAST:
		overlay.draw_rect(Rect2(Vector2(forecast_target.pos * T) + Vector2(1, 1), Vector2(T - 2, T - 2)), Color.WHITE, false, 2.0)


# ================================================================ kết thúc

func _finish() -> void:
	mode = Mode.ENDED
	_hint_queue.clear()
	_close_hint()  # không để gợi ý đè lên hội thoại cuối trận và bảng kết quả (báo cáo M3)
	selected = null
	_refresh_all()
	portrait.texture = null
	name_label.text = "Trận đã kết thúc"
	info_label.text = ""
	_set_buttons([])
	battle_finished.emit(state.result)
	if not story_mode:
		show_result([])


## Bảng nổi giữa hai thanh (kết quả, tạm dừng): rộng gần hết màn, cột nội dung bên trong.
## Trả về [panel, cột nội dung (cuộn được), hàng nút ở đáy (luôn thấy)]. Bảng phủ cả bảng dưới vì nó là hộp thoại chặn.
func _overlay_panel() -> Array:
	var panel := _panel(Color(0.12, 0.04, 0.04, 0.97))
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 10
	panel.offset_right = -10
	panel.offset_top = TOP_H + 10
	panel.offset_bottom = -10
	hud.get_child(0).add_child(panel)
	bottom.visible = false  # nút Hết lượt không lòi ra ở góc (báo cáo M2)
	var sc := ScrollContainer.new()
	sc.set_anchors_preset(Control.PRESET_FULL_RECT)
	sc.offset_left = 14
	sc.offset_right = -14
	sc.offset_top = 12
	sc.offset_bottom = -UiKit.BTN_H - 24
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(sc)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 8)
	sc.add_child(col)
	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	row.offset_left = 12
	row.offset_right = -12
	row.offset_top = -UiKit.BTN_H - 12
	row.offset_bottom = -12
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 10)
	panel.add_child(row)
	return [panel, col, row]


func _objective_line(ten: String, st: String) -> Label:
	var mark: String = {"dat": "★ ", "hong": "✗ ", "dang": "☆ ", "xong": "✓ "}[st]
	var color: Color = {"dat": C_GOLD_LIGHT, "hong": Color(0.95, 0.5, 0.45), "dang": Color(0.9, 0.86, 0.78),
		"xong": Color(0.6, 0.9, 0.6)}[st]
	var text := mark + ten + (" (đã hỏng)" if st == "hong" and state.result == "" else "") \
		+ (" (đã xong)" if st == "xong" else "")
	return UiKit.wrap_label(text, UiKit.FS_BODY, color)


## Bảng kết quả màn (06 §4): số vòng, quân mất, mục tiêu phụ, mục Sử liệu mới mở.
func show_result(opened: Array) -> void:
	var win := state.result == "thang"
	Sfx.music("thang" if win else "thua", false)
	var pc := _overlay_panel()
	result_panel = pc[0]
	var col: VBoxContainer = pc[1]
	var title := UiKit.label("THẮNG" if win else "THUA", 28, C_GOLD_LIGHT, true)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)
	var lost := 0
	for k in state.flags.get("mat_quan", {}):
		lost += int(state.flags["mat_quan"][k])
	var sub := "Sau %d vòng · mất %d quân" % [state.won_round if win else state.vong, lost]
	if not win and state.result_reason != "":
		sub = state.result_reason
	var sub_l := UiKit.wrap_label(sub, UiKit.FS_BODY, Color.WHITE)
	sub_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(sub_l)
	var objs := Rules.side_objectives_live(state)
	if win and not objs.is_empty():
		col.add_child(UiKit.label("Mục tiêu phụ", UiKit.FS_HEAD, C_GOLD, true))
		for o in objs:
			col.add_child(_objective_line(o["ten"], o["trang_thai"]))
	if not opened.is_empty():
		col.add_child(UiKit.label("Sử liệu mới", UiKit.FS_HEAD, C_GOLD, true))
		for id in opened:
			col.add_child(UiKit.wrap_label("• " + Story.codex_entry(id).get("tieu_de", id), UiKit.FS_BODY, UiKit.C_PAPER))
	var row: HBoxContainer = pc[2]
	row.add_child(UiKit.button("Chơi lại", func() -> void: restart_requested.emit(), UiKit.FS_BUTTON, 100))
	if story_mode:
		row.add_child(UiKit.button("Tiếp", func() -> void: exit_requested.emit(), UiKit.FS_BUTTON, 100))


# ================================================================ tạm dừng

func _toggle_pause() -> void:
	if pause_panel != null:
		pause_panel.queue_free()
		pause_panel = null
		bottom.visible = true
		return
	if mode == Mode.ENDED:
		return
	var pc := _overlay_panel()
	pause_panel = pc[0]
	var col: VBoxContainer = pc[1]
	col.add_child(UiKit.label("Tạm dừng", UiKit.FS_TITLE, C_GOLD_LIGHT, true))
	col.add_child(UiKit.label("Mục tiêu", UiKit.FS_HEAD, C_GOLD, true))
	col.add_child(UiKit.wrap_label(state.mission.get("muc_tieu_chinh", "Xem giới thiệu màn."), UiKit.FS_BODY, Color.WHITE))
	var objs := Rules.side_objectives_live(state)
	if not objs.is_empty():
		col.add_child(UiKit.label("Mục tiêu phụ", UiKit.FS_HEAD, C_GOLD, true))
		for o in objs:
			col.add_child(_objective_line(o["ten"], o["trang_thai"]))
	# Chỉ những gợi ý đã hiện (trong trận này hoặc đã xem từ trước), không lộ gợi ý chưa tới (báo cáo M3).
	var hints: Array = state.mission.get("goi_y", [])
	var seen: Array = []
	for i in hints.size():
		if _hints_shown.has(i) or Progress.hint_seen("%s/%d" % [state.mission_id, i]):
			seen.append(hints[i]["loi"])
	if not seen.is_empty():
		col.add_child(UiKit.label("Gợi ý", UiKit.FS_HEAD, C_GOLD, true))
		for text in seen:
			col.add_child(UiKit.wrap_label("• " + text, UiKit.FS_SMALL, Color(0.88, 0.9, 0.96)))
	var row: HBoxContainer = pc[2]
	row.add_child(UiKit.button("Tiếp tục", _toggle_pause))
	if story_mode:
		row.add_child(UiKit.button("Lưu, về menu", func() -> void:
			_autosave()
			exit_requested.emit()))
