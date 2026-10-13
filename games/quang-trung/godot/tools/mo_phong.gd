extends SceneTree
## Máy tự chơi cả hai phe nhiều lần, in kết quả (không hiển thị).
## godot --headless --path . -s res://tools/mo_phong.gd -- --man=m_thu --lan=10

func _init() -> void:
	var args := {}
	for a in OS.get_cmdline_user_args():
		var kv: PackedStringArray = a.trim_prefix("--").split("=")
		args[kv[0]] = kv[1] if kv.size() > 1 else ""
	var mission: String = args.get("man", "m_thu")
	var runs := int(args.get("lan", "10"))
	var wins := 0
	var total_rounds := 0
	for i in runs:
		var s := Missions.new_battle(mission, 1000 + i)
		while s.result == "" and s.vong <= 60:
			SimpleAI.play_turn(s)
			Rules.cmd_end_turn(s)
		var qt_alive := false
		for u in s.units:
			if u.tuong_chinh:
				qt_alive = true
		print("seed %d: %s ở vòng %d (tướng chính %s)" % [1000 + i, s.result if s.result != "" else "chưa xong", s.vong, "còn" if qt_alive else "mất"])
		if s.result == "thang":
			wins += 1
		total_rounds += s.vong
	print("Tây Sơn thắng %d/%d, trung bình %.1f vòng" % [wins, runs, float(total_rounds) / runs])
	quit()
