class_name Battle
extends Node2D
## Màn hình trận đánh: vẽ bản đồ, quân, xử lý chạm, chạy lượt máy có hoạt cảnh.
## Toàn bộ luật nằm ở Rules / SimpleAI; ở đây chỉ hiển thị và gọi lệnh.

signal battle_finished(result: String)

const T := 32
const TOP_H := 32
const BOTTOM_H := 104
const FONT_MED := preload("res://assets/fonts/BeVietnamPro-Medium.ttf")
const FONT_BOLD := preload("res://assets/fonts/BeVietnamPro-Bold.ttf")
const C_LACQUER := Color(0.36, 0.09, 0.09)
const C_LACQUER_DARK := Color(0.16, 0.05, 0.05)
const C_GOLD := Color(0.93, 0.73, 0.2)
const C_GOLD_LIGHT := Color(1.0, 0.91, 0.55)
const PLAYER := "tayson"

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

var terrain_layer: TileMapLayer
var objects_layer: Node2D
var overlay: Node2D
var units_layer: Node2D
var fx_layer: Node2D
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
var buttons: HBoxContainer
var end_button: Button
var banner: Label
var result_panel: Panel

var _touch_start := Vector2.ZERO
var _dragging := false


func start(mission_id: String, p_seed: int = 0) -> void:
	state = Missions.new_battle(mission_id, p_seed)
	_build_world()
	_build_hud()
	_refresh_all()
	_center_camera_on(_first_unit_pos())
	_show_banner("Lượt Tây Sơn · vòng %d" % state.vong)
	if auto_play:
		_run_ai_turns()


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
	var qt: Texture2D = load("res://assets/ui/quan_tan.png")
	for p in state.objects:
		if state.objects[p].get("loai", "") == "quan_tan":
			var s := Sprite2D.new()
			s.texture = qt
			s.centered = false
			s.position = Vector2(p * T)
			objects_layer.add_child(s)


func _refresh_all() -> void:
	_refresh_map()
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
	# Thanh trên
	var top := _panel(C_LACQUER)
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top.offset_bottom = TOP_H
	root.add_child(top)
	top_label = _label(FONT_BOLD, 13, C_GOLD_LIGHT)
	top_label.position = Vector2(8, 7)
	top.add_child(top_label)
	gold_label = _label(FONT_BOLD, 13, Color.WHITE)
	gold_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	gold_label.offset_left = -96
	gold_label.offset_right = -8
	gold_label.offset_top = 7
	gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	top.add_child(gold_label)
	# Bảng dưới
	bottom = _panel(C_LACQUER)
	bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom.offset_top = -BOTTOM_H
	root.add_child(bottom)
	var frame := _panel(C_LACQUER_DARK)
	frame.position = Vector2(6, 8)
	frame.size = Vector2(56, 56)
	bottom.add_child(frame)
	portrait = TextureRect.new()
	portrait.position = Vector2(8, 10)
	portrait.size = Vector2(52, 52)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	bottom.add_child(portrait)
	name_label = _label(FONT_BOLD, 13, C_GOLD_LIGHT)
	name_label.position = Vector2(70, 6)
	bottom.add_child(name_label)
	info_label = _label(FONT_MED, 10, Color.WHITE)
	info_label.position = Vector2(70, 25)
	info_label.size = Vector2(210, 40)
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bottom.add_child(info_label)
	buttons = HBoxContainer.new()
	buttons.position = Vector2(6, 70)
	buttons.add_theme_constant_override("separation", 4)
	bottom.add_child(buttons)
	end_button = _button("Hết lượt", _on_end_turn_pressed)
	end_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	end_button.offset_left = -72
	end_button.offset_top = -32
	end_button.offset_right = -6
	end_button.offset_bottom = -6
	bottom.add_child(end_button)
	# Băng thông báo
	banner = _label(FONT_BOLD, 14, C_GOLD_LIGHT)
	banner.set_anchors_preset(Control.PRESET_CENTER_TOP)
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.add_theme_color_override("font_outline_color", C_LACQUER_DARK)
	banner.add_theme_constant_override("outline_size", 6)
	banner.offset_left = -130
	banner.offset_right = 130
	banner.offset_top = TOP_H + 8
	banner.offset_bottom = TOP_H + 32
	banner.modulate.a = 0.0
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(banner)
	_show_idle_info()


func _button(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_override("font", FONT_BOLD)
	b.add_theme_font_size_override("font_size", 11)
	var normal := StyleBoxFlat.new()
	normal.bg_color = C_LACQUER_DARK
	normal.border_color = C_GOLD
	normal.border_width_top = 1
	normal.content_margin_left = 6
	normal.content_margin_right = 6
	normal.content_margin_top = 4
	normal.content_margin_bottom = 4
	var pressed := normal.duplicate()
	pressed.bg_color = Color(0.5, 0.15, 0.12)
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", normal)
	b.add_theme_stylebox_override("pressed", pressed)
	b.add_theme_stylebox_override("focus", normal)
	b.add_theme_color_override("font_color", C_GOLD_LIGHT)
	b.custom_minimum_size = Vector2(44, 26)
	b.pressed.connect(cb)
	return b


func _set_buttons(list: Array) -> void:
	for c in buttons.get_children():
		c.queue_free()
	for item in list:
		buttons.add_child(_button(item[0], item[1]))


func _refresh_top() -> void:
	var name: String = state.mission.get("ten", "")
	top_label.text = "%s · Vòng %d" % [name, state.vong]
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
	if not notes.is_empty():
		lines += "   (" + ", ".join(notes) + ")"
	info_label.text = lines


func _terrain_info(p: Vector2i) -> void:
	var t := state.terrain_at(p)
	portrait.texture = null
	name_label.text = t["ten"]
	var parts: PackedStringArray = ["Thủ %+d" % int(t["thu"])]
	if int(t["vang"]) > 0:
		parts.append("+%d vàng/lượt" % int(t["vang"]))
	if t["mua_linh"]:
		parts.append("mua lính")
	var o := state.owner_of(p)
	if t["so_huu"]:
		parts.append("chủ: %s" % _faction_name(o))
	info_label.text = "   ".join(parts)


func _faction_name(f: String) -> String:
	return {"tayson": "Tây Sơn", "thanh": "quân Thanh", "le": "quân Lê", "dien_tap": "Diễn tập", "": "chưa có"}.get(f, f)


func _show_idle_info() -> void:
	portrait.texture = null
	name_label.text = "Lượt của %s" % _faction_name(state.current_faction())
	info_label.text = "Chạm một quân để chọn. Chạm đồn trống của ta để mua lính. Kéo để xem bản đồ."
	_set_buttons([])


func _show_banner(text: String) -> void:
	banner.text = text
	var tw := create_tween()
	tw.tween_property(banner, "modulate:a", 1.0, 0.15)
	tw.tween_interval(0.9)
	tw.tween_property(banner, "modulate:a", 0.0, 0.3)


# ================================================================ camera

func _view_size() -> Vector2:
	return get_viewport_rect().size


func _map_px() -> Vector2:
	return Vector2(state.width * T, state.height * T)


func _clamp_camera(pos: Vector2) -> Vector2:
	var vs := _view_size()
	var map := _map_px()
	var area_h := vs.y - TOP_H - BOTTOM_H
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
	var area_h := vs.y - TOP_H - BOTTOM_H
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
	var p := _screen_to_tile(screen)
	if not state.in_bounds(p):
		return
	cursor.visible = true
	cursor.position = Vector2(p * T)
	end_turn_armed = false
	var u := state.unit_at(p)
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
	selected = u
	reach = Rules.reachable(state, u)
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
	var ev := [] as Array[Dictionary] if stay else Rules.cmd_move(state, u, p)
	if stay:
		u.moved = true
		u.move_origin = u.pos
	mode = Mode.BUSY
	await _play(ev)
	mode = Mode.MOVED
	reach = {}
	_show_actions()


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
		list.append(["Chiếm", func() -> void: _run(Rules.cmd_capture(state, u))])
	var ch := Rules.chieu_hang_targets(state, u)
	if not ch.is_empty():
		list.append(["Chiêu hàng", func() -> void: _run(Rules.cmd_chieu_hang(state, u, ch[0]))])
	list.append(["Chờ", func() -> void: _run(Rules.cmd_wait(state, u))])
	if u.pos != u.move_origin:
		list.append(["Hoàn tác", _undo])
	_unit_info(u)
	_set_buttons(list)
	overlay.queue_redraw()


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
	forecast_target = t
	mode = Mode.FORECAST
	var fc := Rules.forecast(state, selected, selected.pos, t, selected.straight_steps)
	_unit_info(t)
	var txt := "Gây %d–%d   (hạ: %d%%)" % [fc["st_min"], fc["st_max"], roundi(fc["ti_le_ha"] * 100.0)]
	if fc["phan_don"]:
		txt += "\nBị phản đòn %d–%d" % [fc["pd_min"], fc["pd_max"]]
	else:
		txt += "\nKhông bị phản đòn"
	info_label.text = txt + "   — chạm lần nữa để đánh"
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


func _show_recruit(p: Vector2i) -> void:
	portrait.texture = null
	name_label.text = "Mua lính — %d vàng" % int(state.gold.get(PLAYER, 0))
	var opts := Rules.recruit_options(state, PLAYER, p)
	var data := GameData.get_data()
	var names: PackedStringArray = []
	var list: Array = []
	for id in opts:
		var d := data.unit(id)
		names.append("%s %d" % [d["ten"], d["gia"]])
		if Rules.can_afford(state, PLAYER, id):
			list.append([String(d["ten"]).split(" ")[0] + " " + str(d["gia"]), func() -> void: _run(Rules.cmd_recruit(state, PLAYER, p, id))])
	info_label.text = ", ".join(names) if list.is_empty() else "Chọn loại lính:"
	if list.size() > 4:
		list = list.slice(0, 4)
	_set_buttons(list)


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
				if u != null:
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
	_show_banner("Lượt Tây Sơn · vòng %d" % state.vong)
	_show_idle_info()
	_refresh_all()


# ================================================================ hoạt cảnh

func _play(events: Array[Dictionary]) -> void:
	for e in events:
		match e["loai"]:
			"di":
				var s: UnitSprite = sprites.get(e["uid"])
				if s != null:
					var tw := create_tween()
					for p in e["duong"].slice(1):
						tw.tween_property(s, "position", Vector2(p * T), 0.07)
					await tw.finished
			"danh":
				var a: UnitSprite = sprites.get(e["uid"])
				var d: UnitSprite = sprites.get(e["muc_tieu"])
				if a != null and d != null:
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
				if s != null:
					sprites.erase(e["uid"])
					var tw := create_tween()
					tw.tween_property(s, "modulate:a", 0.0, 0.3)
					await tw.finished
					s.queue_free()
			"mua", "chieu_hang":
				var nu := state.unit_by_uid(e.get("uid_moi", e["uid"]))
				if nu != null and not sprites.has(nu.uid):
					var s := _add_sprite(nu)
					s.modulate.a = 0.0
					create_tween().tween_property(s, "modulate:a", 1.0, 0.25)
			"len_cap":
				var s: UnitSprite = sprites.get(e["uid"])
				if s != null:
					_float_text(s.position + Vector2(0, -6), "Lên cấp!", C_GOLD_LIGHT)
			"vang":
				if e["phe"] == PLAYER:
					_float_text(camera.position + Vector2(_view_size().x - 70, TOP_H + 4), "+%d vàng" % e["them"], C_GOLD_LIGHT)
			"bat_dau_luot":
				_refresh_top()
		_refresh_map()
		for u in state.units:
			if sprites.has(u.uid):
				sprites[u.uid].refresh(u)
		_refresh_top()


func _float_text(pos: Vector2, text: String, color: Color) -> void:
	var l := _label(FONT_BOLD, 10, color)
	l.text = text
	l.position = pos
	l.add_theme_color_override("font_outline_color", Color(0.08, 0.04, 0.04))
	l.add_theme_constant_override("outline_size", 3)
	fx_layer.add_child(l)
	var tw := create_tween()
	tw.tween_property(l, "position", pos + Vector2(0, -14), 0.6)
	tw.parallel().tween_property(l, "modulate:a", 0.0, 0.6).set_delay(0.3)
	tw.tween_callback(l.queue_free)


func _draw_overlay() -> void:
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
	_refresh_all()
	var win := state.result == "thang"
	result_panel = _panel(Color(0.12, 0.04, 0.04, 0.92))
	result_panel.set_anchors_preset(Control.PRESET_CENTER)
	result_panel.offset_left = -110
	result_panel.offset_right = 110
	result_panel.offset_top = -70
	result_panel.offset_bottom = 40
	hud.get_child(0).add_child(result_panel)
	var title := _label(FONT_BOLD, 20, C_GOLD_LIGHT)
	title.text = "THẮNG" if win else "THUA"
	title.position = Vector2(0, 14)
	title.size = Vector2(220, 28)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_panel.add_child(title)
	var sub := _label(FONT_MED, 11, Color.WHITE)
	sub.text = "Sau %d vòng" % state.vong
	sub.position = Vector2(0, 44)
	sub.size = Vector2(220, 18)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_panel.add_child(sub)
	var again := _button("Chơi lại", func() -> void: get_tree().reload_current_scene())
	again.position = Vector2(70, 70)
	again.size = Vector2(80, 28)
	result_panel.add_child(again)
	battle_finished.emit(state.result)
