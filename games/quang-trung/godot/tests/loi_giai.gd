class_name LoiGiai
extends RefCounted
## Chạy một lời giải viết sẵn (tests/loi_giai/*.txt) trên luật thật, máy chơi phe địch.
## Lệnh (mỗi dòng, "#" là chú thích):
##   di X Y X2 Y2              đi rồi chờ
##   danh X Y X2 Y2 X3 Y3      đi tới X2 Y2 rồi đánh quân ở X3 Y3
##   chiem X Y X2 Y2           đi rồi chiếm
##   mua X Y LOAI              mua lính ở ô X Y
##   het                       hết lượt; máy chơi lượt địch


## Trả về {"state": BattleState, "loi": String rỗng nếu chạy hết, "nhat_ky": Array[String]}.
static func run(mission: String, p_seed: int, path: String, verbose := false) -> Dictionary:
	var s := Missions.new_battle(mission, p_seed)
	var log: Array[String] = []
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {"state": s, "loi": "không mở được " + path, "nhat_ky": log}
	if verbose:
		print_map(s)
	for raw in f.get_as_text().split("\n"):
		var line := raw.strip_edges()
		if line == "" or line.begins_with("#"):
			continue
		var w := line.split(" ", false)
		var ev: Array[Dictionary] = []
		match w[0]:
			"di", "danh", "chiem":
				var u := s.unit_at(Vector2i(int(w[1]), int(w[2])))
				if u == null:
					return {"state": s, "loi": "không có quân ở %s,%s (%s)" % [w[1], w[2], line], "nhat_ky": log}
				var to := Vector2i(int(w[3]), int(w[4]))
				if to != u.pos:
					ev = Rules.cmd_move(s, u, to)
					if ev.is_empty():
						return {"state": s, "loi": "không đi được: " + line, "nhat_ky": log}
				if w[0] == "danh":
					var r := Rules.cmd_attack(s, u, s.unit_at(Vector2i(int(w[5]), int(w[6]))))
					if r.is_empty():
						return {"state": s, "loi": "không đánh được: " + line, "nhat_ky": log}
					ev.append_array(r)
				elif w[0] == "chiem":
					var r2 := Rules.cmd_capture(s, u)
					if r2.is_empty():
						return {"state": s, "loi": "không chiếm được: " + line, "nhat_ky": log}
					ev.append_array(r2)
				else:
					ev.append_array(Rules.cmd_wait(s, u))
			"mua":
				ev = Rules.cmd_recruit(s, s.current_faction(), Vector2i(int(w[1]), int(w[2])), w[3])
				if ev.is_empty():
					return {"state": s, "loi": "không mua được: " + line, "nhat_ky": log}
			"het":
				ev = Rules.cmd_end_turn(s)
				ev.append_array(SimpleAI.play_turn(s))
				ev.append_array(Rules.cmd_end_turn(s))
				if verbose:
					print_map(s)
			_:
				return {"state": s, "loi": "lệnh lạ: " + line, "nhat_ky": log}
		for e in ev:
			if e["loai"] in ["danh", "ha", "bao_dong", "trong_bao_dong", "ket_qua", "lo_dien"]:
				log.append("%s → %s" % [line, e])
				if verbose:
					print("   ", log[-1])
		if s.result != "":
			break
	return {"state": s, "loi": "", "nhat_ky": log}


static func print_map(s: BattleState) -> void:
	print("--- vòng %d, báo động %d, vàng %d" % [s.vong, int(s.flags["bao_dong"]), s.gold.get(s.factions[0], 0)])
	var marks := {"quang_trung": "@", "voi_chien": "V", "thuy_binh": "W", "hoa_ho": "X"}
	for y in s.height:
		var row := "%2d " % y
		for x in s.width:
			var u := s.unit_at(Vector2i(x, y))
			var ch: String = GameData.get_data().terrain[s.terrain_id(Vector2i(x, y))]["ky_tu"]
			if u != null:
				if u.faction == s.factions[0]:
					ch = marks.get(u.type_id, u.type_id.substr(0, 1).to_upper())
				else:
					ch = "z" if u.ngu else "e"
			row += ch + " "
		for u in s.units:
			if u.pos.y == y and u.hp < 100:
				row += " %s%s:%d" % [u.type_id.substr(0, 4), u.pos, u.hp]
		print(row)
