extends Node
## Cảnh khởi động. Tham số dòng lệnh (sau "--"):
##   --man=<id>          màn cần mở (mặc định m_thu)
##   --seed=<số>         seed ngẫu nhiên
##   --tu-dong           máy chơi cả hai phe (kiểm thử)
##   --anh=<đường dẫn>   chụp màn hình sau --cho=<giây> (mặc định 1.5) rồi thoát
##   --vong=<n>          khi tự động: chụp khi tới vòng n
##   --kich-ban=<file>   chạy kịch bản chạm (xem tests/kich_ban/README.md), mỗi bước có thể chụp ảnh
##   --moi               xóa tiến trình và file lưu trước khi chạy (kiểm thử từ đầu)
##   --mo-het            mở khóa mọi màn đã làm (kiểm thử)
##   --menu              vẫn đi qua menu (dùng kèm --kich-ban để kiểm thử menu, hội thoại, lưu)
## Không có tham số nào: vào menu chính như người chơi.

var battle: Battle
var screen: Control                # màn hình menu đang mở (null khi đang trong trận)
var ui_layer: CanvasLayer          # menu, giới thiệu màn, hội thoại nằm trên trận
var _mission := "m_thu"
var _seed := 0
var _auto := false
var _story := false


func _ready() -> void:
	_apply_pixel_scale()
	get_window().size_changed.connect(_apply_pixel_scale)
	get_tree().set_quit_on_go_back(false)
	ui_layer = CanvasLayer.new()
	ui_layer.layer = 10
	add_child(ui_layer)
	var args := _args()
	_seed = int(args.get("seed", "0"))
	_auto = args.has("tu-dong")
	Progress.unlock_all = args.has("mo-het")
	if args.has("moi"):
		Progress.clear_battle()
		DirAccess.remove_absolute(ProjectSettings.globalize_path(Progress.PROGRESS_PATH))
		Progress.reset_cache()
	# Có --man / --kich-ban / --anh / --tu-dong: vào thẳng trận (kiểm thử). Không có: vào menu như người chơi.
	var direct := args.has("man") or args.has("kich-ban") or args.has("anh") or _auto
	if direct and not args.has("menu"):
		_mission = args.get("man", "m_thu")
		_new_battle()
	else:
		_show_menu()
	if args.has("kich-ban"):
		_run_script(args["kich-ban"])
	elif args.has("anh"):
		_screenshot_later(args["anh"], float(args.get("cho", "1.5")), int(args.get("vong", "0")))


# ================================================================ luồng màn hình (06 §4)

func _set_screen(c: Control) -> void:
	if screen != null:
		screen.queue_free()
	screen = c
	if c != null:
		ui_layer.add_child(c)


func _close_battle() -> void:
	if battle != null:
		battle.queue_free()
		battle = null


func _show_menu() -> void:
	_close_battle()
	Sfx.music("chu_de")
	var m := MainMenu.new()
	m.continue_pressed.connect(_continue)
	m.campaign_pressed.connect(_show_campaign)
	m.codex_pressed.connect(_show_codex)
	_set_screen(m)


func _show_campaign() -> void:
	var c := CampaignScreen.new()
	c.mission_chosen.connect(_show_briefing)
	c.back.connect(_show_menu)
	_set_screen(c)


func _show_codex() -> void:
	var c := CodexScreen.new()
	c.back.connect(_show_menu)
	_set_screen(c)


func _show_briefing(id: String) -> void:
	var m := Missions.load_mission(id)
	if not m.has("gioi_thieu"):
		_start_story_battle(id)  # màn luyện tập: không có giới thiệu
		return
	var b := Briefing.new().setup(m)
	b.start_pressed.connect(_start_story_battle.bind(id))
	b.back.connect(_show_campaign)
	_set_screen(b)


## Màn chuyện (loai "chuyen", màn 3): chuỗi cảnh hội thoại trên nền sơn mài, rồi sa bàn; xong là qua màn.
func _start_story_only(m: Dictionary) -> void:
	_close_battle()
	var stage := UiKit.backdrop()
	var title := UiKit.wrap_label(m.get("ten", ""), UiKit.FS_TITLE, UiKit.C_GOLD_LIGHT, true)
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_left = 20
	title.offset_right = -20
	title.offset_top = 130
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stage.add_child(title)
	var sub := UiKit.wrap_label(m.get("ngay", ""), UiKit.FS_SMALL, UiKit.C_MUTED)
	sub.set_anchors_preset(Control.PRESET_TOP_WIDE)
	sub.offset_left = 20
	sub.offset_right = -20
	sub.offset_top = 170
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stage.add_child(sub)
	_set_screen(stage)
	for part in m.get("canh", []):
		await _dialogue(Story.dialogue(m.get("hoi_thoai", ""), part))
	var sb := SaBan.new().setup(m)
	_set_screen(sb)
	await sb.done
	var opened := Progress.record_story(m)
	var names: PackedStringArray = []
	for id in opened:
		names.append("• " + Story.codex_entry(id).get("tieu_de", id))
	var end := UiKit.backdrop()
	var col := UiKit.scroll_column(end, 40, 64)
	col.add_child(UiKit.label("Xong màn chuyện", UiKit.FS_TITLE, UiKit.C_GOLD_LIGHT, true))
	if not names.is_empty():
		col.add_child(UiKit.label("Sử liệu mới", UiKit.FS_HEAD, UiKit.C_GOLD, true))
		col.add_child(UiKit.wrap_label("\n".join(names), UiKit.FS_BODY, UiKit.C_PAPER))
	UiKit.bottom_bar(end).add_child(UiKit.button("Tiếp", _show_campaign, UiKit.FS_BUTTON, 120))
	_set_screen(end)


func _start_story_battle(id: String) -> void:
	var sm := Missions.load_mission(id)
	if sm.get("loai", "") == "chuyen":
		_start_story_only(sm)
		return
	_mission = id
	_story = true
	Progress.clear_battle()
	_set_screen(null)
	_new_battle()
	await _dialogue(Story.dialogue(battle.state.mission.get("hoi_thoai", ""), "truoc"))
	if battle != null:
		battle.hint("bat_dau")
		battle.hint("vong", battle.state.vong)


func _continue() -> void:
	var s := Progress.load_battle()
	if s == null:
		Progress.clear_battle()
		_show_menu()
		return
	_mission = s.mission_id
	_story = true
	_set_screen(null)
	_new_battle(s)


func _new_battle(from: BattleState = null) -> void:
	_close_battle()
	battle = Battle.new()
	battle.auto_play = _auto
	battle.story_mode = _story
	battle.restart_requested.connect(_restart, CONNECT_DEFERRED)
	battle.exit_requested.connect(_on_battle_exit, CONNECT_DEFERRED)
	battle.battle_finished.connect(_on_battle_finished)
	battle.story_player = _story_part
	add_child(battle)
	if from != null:
		battle.start_from_state(from)
	else:
		# Trong chiến dịch mỗi lần chơi một seed mới (trừ khi kiểm thử truyền --seed).
		var sd := _seed if _seed != 0 or not _story else randi_range(1, 999999)
		battle.start(_mission, sd)


func _on_battle_exit() -> void:
	# Xong trận → về danh sách màn; bỏ dở (đã lưu) → về menu chính để thấy "Tiếp tục".
	if battle != null and battle.state.result != "":
		_show_campaign()
	else:
		_show_menu()


func _restart() -> void:
	if _story:
		Progress.clear_battle()
	_new_battle()


func _on_battle_finished(result: String) -> void:
	if not _story:
		return
	Progress.clear_battle()
	var opened: Array[String] = []
	if result == "thang":
		opened = Progress.record_win(battle.state)
		await _dialogue(Story.dialogue(battle.state.mission.get("hoi_thoai", ""), "sau_thang"))
	battle.show_result(opened)


## Hội thoại giữa trận do sự kiện kịch bản gọi (màn 2: gặp Nguyễn Thiếp, duyệt binh).
func _story_part(part: String) -> void:
	if battle == null:
		return
	await _dialogue(Story.dialogue(battle.state.mission.get("hoi_thoai", ""), part))


func _dialogue(lines: Array) -> void:
	if lines.is_empty():
		return
	if battle != null:
		battle.input_locked = true
	var box := DialogueBox.new()
	ui_layer.add_child(box)
	await box.play(lines)
	box.queue_free()
	if battle != null:
		battle.input_locked = false


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_go_back()


## Nút Back của Android.
func _go_back() -> void:
	if screen is CodexScreen and (screen as CodexScreen).go_back():
		return
	if screen is Briefing:
		_show_campaign()
	elif screen is CampaignScreen or screen is CodexScreen:
		_show_menu()
	elif screen is MainMenu:
		get_tree().quit()
	elif battle != null:
		battle._toggle_pause()


func _args() -> Dictionary:
	var out := {}
	for a in OS.get_cmdline_user_args():
		var s: String = a.trim_prefix("--")
		var i := s.find("=")
		if i >= 0:
			out[s.substr(0, i)] = s.substr(i + 1)
		else:
			out[s] = ""
	return out


func _screenshot_later(path: String, wait: float, until_round: int) -> void:
	if until_round > 0:
		while battle.state.vong < until_round and battle.state.result == "":
			await get_tree().create_timer(0.2).timeout
	await get_tree().create_timer(wait).timeout
	var img := get_viewport().get_texture().get_image()
	img.save_png(path)
	print("Đã chụp: ", path)
	get_tree().quit()


## Kịch bản chạm: mỗi dòng một lệnh.
##   cham X Y        chạm vào ô (X, Y)
##   nut <chữ>       bấm nút có chữ đó (ở bảng dưới, kể cả "Hết lượt")
##   cho <giây>      chờ
##   anh <file.png>  chụp màn hình (đường dẫn tương đối → <thư mục dữ liệu người dùng>/anh/)
##   keo DX DY       kéo bản đồ (điểm ảnh logic)
##   tiep            chạm vào khung hội thoại (hiện hết chữ / sang câu sau)
##   vuot X Y DY     vuốt cảm ứng từ điểm logic (X, Y) theo chiều dọc DY (âm = vuốt lên)
##   kiem <...>      ghi ra trạng thái: vang | vong | ket_qua | camera | quan X Y | vat X Y
##   thoat           thoát
func _run_script(path: String) -> void:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("Không mở được kịch bản %s" % path)
		get_tree().quit(1)
		return
	await get_tree().create_timer(0.5).timeout
	var line_no := 0
	while not f.eof_reached():
		var line := f.get_line().strip_edges()
		line_no += 1
		if line == "" or line.begins_with("#"):
			continue
		var parts := line.split(" ", false, 1)
		var cmd := parts[0]
		var rest := parts[1] if parts.size() > 1 else ""
		match cmd:
			"vuot":
				# vuốt cảm ứng thật (qua Input) bắt đầu ở điểm logic (X, Y), kéo dọc DY — để thử cuộn danh sách bắt đầu trên nút
				var v := rest.split(" ", false)
				await _swipe(Vector2(float(v[0]), float(v[1])), float(v[2]))
			"tiep":
				for box in ui_layer.find_children("*", "DialogueBox", true, false):
					box.advance()
			"cham":
				var xy := rest.split(" ", false)
				var tile := Vector2i(int(xy[0]), int(xy[1]))
				var world := Vector2(tile * Battle.T) + Vector2(Battle.T, Battle.T) / 2.0
				var screen := get_viewport().get_canvas_transform() * world
				battle._on_tap(screen)
			"keo":
				var d := rest.split(" ", false)
				var ev := InputEventScreenDrag.new()
				ev.position = get_viewport().get_visible_rect().size / 2.0
				ev.relative = Vector2(float(d[0]), float(d[1]))
				battle._dragging = true
				battle._unhandled_input(ev)
				battle._dragging = false
			"nut":
				if not _press(rest):
					print("KỊCH BẢN dòng %d: không thấy nút '%s'" % [line_no, rest])
			"cho":
				await get_tree().create_timer(float(rest)).timeout
			"anh":
				var out := rest
				if not out.is_absolute_path():
					DirAccess.make_dir_recursive_absolute(OS.get_user_data_dir() + "/anh")
					out = OS.get_user_data_dir() + "/anh/" + rest
				get_viewport().get_texture().get_image().save_png(out)
				print("Đã chụp: ", out)
			"kiem":
				print("KIỂM dòng %d: %s = %s" % [line_no, rest, _inspect(rest)])
			"thoat":
				get_tree().quit()
				return
		await get_tree().create_timer(0.35).timeout
		# Hội thoại giữa trận (màn 2) giữ trận ở BUSY cho tới khi người chơi chạm: đừng chờ, để lệnh "tiep" / "nut Bỏ qua" chạy.
		while battle != null and battle.mode == Battle.Mode.BUSY and ui_layer.find_children("*", "DialogueBox", true, false).is_empty():
			await get_tree().create_timer(0.1).timeout
	get_tree().quit()


func _swipe(from: Vector2, dy: float) -> void:
	var to_screen := get_viewport().get_screen_transform()
	var t := InputEventScreenTouch.new()
	t.position = to_screen * from
	t.pressed = true
	Input.parse_input_event(t)
	await get_tree().process_frame
	var steps := 12
	var pos := from
	for i in steps:
		var d := InputEventScreenDrag.new()
		var nxt := from + Vector2(0, dy * (i + 1) / steps)
		d.position = to_screen * nxt
		d.relative = to_screen.basis_xform(nxt - pos)
		d.velocity = d.relative * 60.0
		pos = nxt
		Input.parse_input_event(d)
		await get_tree().process_frame
	var r := InputEventScreenTouch.new()
	r.position = to_screen * pos
	r.pressed = false
	Input.parse_input_event(r)
	await get_tree().create_timer(0.3).timeout


func _press(text: String) -> bool:
	for b in find_children("*", "Button", true, false):
		if (b.text == text or b.text.split("\n")[0] == text) and not b.disabled and b.is_visible_in_tree() and not b.is_queued_for_deletion():
			b.pressed.emit()
			return true
	return false


func _inspect(what: String) -> String:
	if what == "luu":
		return "có" if Progress.has_battle() else "không"
	if what.begins_with("sao "):
		return str(Progress.stars(what.substr(4)))
	if what == "cuon":
		for sc in find_children("*", "ScrollContainer", true, false):
			if sc.is_visible_in_tree():
				return str(sc.scroll_vertical)
		return "(không có danh sách cuộn)"
	if what == "man_hinh":
		return "(trận)" if screen == null else str(screen.get_script().get_global_name())
	if battle == null:
		return "(không có trận)"
	var st := battle.state
	var p := what.split(" ", false)
	match p[0]:
		"vang":
			return str(st.gold.get("tayson", 0))
		"vong":
			return str(st.vong)
		"ket_qua":
			return st.result if st.result != "" else "(chưa)"
		"camera":
			return "%d,%d" % [int(battle.camera.position.x), int(battle.camera.position.y)]
		"vat":
			var o := st.object_at(Vector2i(int(p[1]), int(p[2])))
			return o.get("loai", "trống")
		"quan":
			var u := st.unit_at(Vector2i(int(p[1]), int(p[2])))
			return "trống" if u == null else "%s %s máu %d%s" % [u.faction, u.type_id, u.hp, " (xong)" if u.done else ""]
	return "?"


## Phóng nguyên số (docs/08 §4) nhưng dùng hết màn hình: chọn hệ số s = floor(min(rộng/288, cao/512)),
## rồi đặt vùng logic = kích thước màn hình / s. Chế độ "integer" có sẵn của Godot để lại viền đen
## (báo cáo kiểm thử 13/10/2026, Pixel 3), nên tự tính ở đây.
func _apply_pixel_scale() -> void:
	var win := get_window()
	var screen := win.size
	if screen.x <= 0 or screen.y <= 0:
		return
	var s := maxi(1, mini(screen.x / 288, screen.y / 512))
	win.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	win.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	win.content_scale_stretch = Window.CONTENT_SCALE_STRETCH_FRACTIONAL
	win.content_scale_size = Vector2i(screen.x / s, screen.y / s)
