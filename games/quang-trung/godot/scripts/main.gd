extends Node
## Cảnh khởi động. Tham số dòng lệnh (sau "--"):
##   --man=<id>          màn cần mở (mặc định m_thu)
##   --seed=<số>         seed ngẫu nhiên
##   --tu-dong           máy chơi cả hai phe (kiểm thử)
##   --anh=<đường dẫn>   chụp màn hình sau --cho=<giây> (mặc định 1.5) rồi thoát
##   --vong=<n>          khi tự động: chụp khi tới vòng n
##   --kich-ban=<file>   chạy kịch bản chạm (xem tests/kich_ban/README.md), mỗi bước có thể chụp ảnh

var battle: Battle


func _ready() -> void:
	var args := _args()
	battle = Battle.new()
	battle.auto_play = args.has("tu-dong")
	add_child(battle)
	battle.start(args.get("man", "m_thu"), int(args.get("seed", "0")))
	if args.has("kich-ban"):
		_run_script(args["kich-ban"])
	elif args.has("anh"):
		_screenshot_later(args["anh"], float(args.get("cho", "1.5")), int(args.get("vong", "0")))


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
##   kiem <biểu thức đơn giản>  ghi ra trạng thái: vang | vong | ket_qua | quan X Y
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
			"cham":
				var xy := rest.split(" ", false)
				var tile := Vector2i(int(xy[0]), int(xy[1]))
				var world := Vector2(tile * Battle.T) + Vector2(Battle.T, Battle.T) / 2.0
				var screen := get_viewport().get_canvas_transform() * world
				battle._on_tap(screen)
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
		while battle.mode == Battle.Mode.BUSY:
			await get_tree().create_timer(0.1).timeout
	get_tree().quit()


func _press(text: String) -> bool:
	var candidates: Array = battle.buttons.get_children()
	candidates.append(battle.end_button)
	for b in candidates:
		if b is Button and b.text == text and not b.disabled:
			b.pressed.emit()
			return true
	return false


func _inspect(what: String) -> String:
	var st := battle.state
	var p := what.split(" ", false)
	match p[0]:
		"vang":
			return str(st.gold.get("tayson", 0))
		"vong":
			return str(st.vong)
		"ket_qua":
			return st.result if st.result != "" else "(chưa)"
		"quan":
			var u := st.unit_at(Vector2i(int(p[1]), int(p[2])))
			return "trống" if u == null else "%s %s máu %d%s" % [u.faction, u.type_id, u.hp, " (xong)" if u.done else ""]
	return "?"
