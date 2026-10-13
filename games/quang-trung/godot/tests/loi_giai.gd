class_name LoiGiai
extends RefCounted
## Chạy một lời giải viết sẵn (tests/loi_giai/*.txt) trên luật thật, máy chơi phe địch.
## Lệnh (mỗi dòng, "#" là chú thích):
##   di X Y X2 Y2              đi rồi chờ
##   danh X Y X2 Y2 X3 Y3      đi tới X2 Y2 rồi đánh quân ở X3 Y3
##   chiem X Y X2 Y2           đi rồi chiếm
##   mua X Y LOAI              mua lính ở ô X Y
##   toi X Y TX TY             đi tới ô đi được gần (TX, TY) nhất (cùng gần thì ô tốn ít điểm đi hơn), rồi chiếm nếu chiếm
##                             được ô đó, không thì chờ
##   toi_loai LOAI TX TY       như "toi" cho quân ta đầu tiên thuộc loại LOAI (vd. tướng có tên)
##   ai                        để máy (SimpleAI) đi nốt các quân ta còn lại trong lượt này
##   rut TX TY                 mọi quân ta chưa đi làm "toi" về (TX, TY), quân gần đích đi trước
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
			"toi_loai":
				var found: Unit = null
				for cu in s.units_of(s.current_faction()):
					if cu.type_id == w[1] and not cu.done:
						found = cu
						break
				if found == null:
					return {"state": s, "loi": "không có quân %s chưa đi (%s)" % [w[1], line], "nhat_ky": log}
				ev = _toward(s, found, Vector2i(int(w[2]), int(w[3])))
				if verbose:
					print("   %s → %s" % [line, found.pos])
			"ai":
				for _i in 60:
					var act := SimpleAI.next_action(s)
					if act.is_empty() or s.result != "":
						break
					var step := SimpleAI.execute(s, act)
					if step.is_empty():
						var stuck := s.unit_by_uid(act.get("uid", -1))
						if stuck != null:
							stuck.done = true
					ev.append_array(step)
			"rut":
				var goal2 := Vector2i(int(w[1]), int(w[2]))
				var order := s.units_of(s.current_faction()).filter(func(x: Unit) -> bool: return not x.done)
				order.sort_custom(func(a: Unit, b: Unit) -> bool: return Rules.manhattan(a.pos, goal2) < Rules.manhattan(b.pos, goal2))
				for ru in order:
					ev.append_array(_toward(s, ru, goal2))
				if verbose:
					print("   %s" % line)
			"toi":
				var tu := s.unit_at(Vector2i(int(w[1]), int(w[2])))
				if tu == null:
					return {"state": s, "loi": "không có quân ở %s,%s (%s)" % [w[1], w[2], line], "nhat_ky": log}
				ev = _toward(s, tu, Vector2i(int(w[3]), int(w[4])))
				if verbose:
					print("   %s → %s" % [line, tu.pos])
			"mua":
				ev = Rules.cmd_recruit(s, s.current_faction(), Vector2i(int(w[1]), int(w[2])), w[3])
				if ev.is_empty():
					return {"state": s, "loi": "không mua được: " + line, "nhat_ky": log}
			"het":
				ev = Rules.cmd_end_turn(s)
				while s.result == "" and s.current != 0:   # mọi phe máy (màn có 3 phe: Tây Sơn, Thanh, Lê)
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


static func _toward(s: BattleState, u: Unit, goal: Vector2i) -> Array[Dictionary]:
	var reach := Rules.reachable(s, u)
	var best := u.pos
	for rp in reach:
		var d := Rules.manhattan(rp, goal)
		var bd := Rules.manhattan(best, goal)
		if d < bd or (d == bd and int(reach[rp]["chi_phi"]) < int(reach[best]["chi_phi"])):
			best = rp
	var ev: Array[Dictionary] = []
	if best != u.pos:
		ev = Rules.cmd_move(s, u, best)
	if Rules.can_capture(s, u):
		ev.append_array(Rules.cmd_capture(s, u))   # tới đúng ô chiếm được (đồn, làng) thì chiếm luôn
	else:
		ev.append_array(Rules.cmd_wait(s, u))
	return ev


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
