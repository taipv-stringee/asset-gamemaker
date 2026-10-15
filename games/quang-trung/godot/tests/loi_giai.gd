class_name LoiGiai
extends RefCounted
## Chạy một lời giải viết sẵn (tests/loi_giai/*.txt) trên luật thật, máy chơi phe địch.
## Lệnh (mỗi dòng, "#" là chú thích):
##   di X Y X2 Y2              đi rồi chờ
##   danh X Y X2 Y2 X3 Y3      đi tới X2 Y2 rồi đánh quân ở X3 Y3
##   chiem X Y X2 Y2           đi rồi chiếm
##   danh_neu X Y X2 Y2 X3 Y3  như "danh" nhưng bỏ qua (không lỗi) nếu không có quân ta chưa đi ở X Y, mục tiêu không còn,
##                             hoặc không đi / đánh được — để viết dòng dự phòng khi bàn cờ khác nhau theo seed
##   mua X Y LOAI              mua lính ở ô X Y
##   toi X Y TX TY             đi tới ô đi được gần (TX, TY) nhất (cùng gần thì ô tốn ít điểm đi hơn), rồi chiếm nếu chiếm
##                             được ô đó, chiêu hàng nếu kề quân tan (quân sư), không thì chờ
##   toi_loai LOAI TX TY       như "toi" cho quân ta đầu tiên thuộc loại LOAI chưa đi (không có thì bỏ qua)
##   mua_neu X Y LOAI          như "mua" nhưng không đủ vàng / đồn có quân thì bỏ qua
##   goi_hang X Y [X2 Y2]      quân ở X Y (đi tới X2 Y2 trước nếu có) gọi hàng khu đồn đứng kề (02 §11); lỗi nếu không gọi được / không thành
##   ai_khong_mua              như "ai" nhưng máy không mua lính
##   ai_giu                    như "ai_khong_mua" và máy cũng không chiếm ô (để hoãn điều kiện chuyển giai đoạn)
##   ai                        để máy (SimpleAI) đi nốt các quân ta còn lại trong lượt này
##   rut TX TY                 mọi quân ta chưa đi làm "toi" về (TX, TY), quân gần đích đi trước
##   het                       hết lượt; máy chơi lượt địch


## Trả về {"state": BattleState, "loi": String rỗng nếu chạy hết, "nhat_ky": Array[String]}.
static func run(mission: String, p_seed: int, path: String, verbose := false, carry: Dictionary = {}) -> Dictionary:
	var s := Missions.new_battle(mission, p_seed)
	Rules.apply_carry(s, carry)   # hệ quả màn trước (vd. {"trinh_sat_thoat": true} cho màn 6)
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
			"danh_neu":
				var nu := s.unit_at(Vector2i(int(w[1]), int(w[2])))
				var nt := s.unit_at(Vector2i(int(w[5]), int(w[6])))
				if nu == null or nu.done or nt == null or s.are_allies(nt.faction, nu.faction):
					continue
				var nto := Vector2i(int(w[3]), int(w[4]))
				if nto != nu.pos and not Rules.reachable(s, nu).has(nto):
					continue   # ô đứng bị chặn (bàn cờ khác đi theo seed): dòng dự phòng sau sẽ lo
				if not Rules.targets_from(s, nu, nto, nto != nu.pos).has(nt):
					continue
				if nto != nu.pos:
					ev = Rules.cmd_move(s, nu, nto)
				ev.append_array(Rules.cmd_attack(s, nu, nt))
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
					continue   # chưa có (chưa mua) hoặc đã đi: bỏ qua
				ev = _toward(s, found, Vector2i(int(w[2]), int(w[3])))
				if verbose:
					print("   %s → %s" % [line, found.pos])
			"ai", "ai_khong_mua", "ai_giu":
				SimpleAI.allow_recruit = w[0] == "ai"
				SimpleAI.allow_capture = w[0] != "ai_giu"
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
				SimpleAI.allow_recruit = true
				SimpleAI.allow_capture = true
			"rut":
				var goal2 := Vector2i(int(w[1]), int(w[2]))
				var order := s.units_of(s.current_faction()).filter(func(x: Unit) -> bool: return not x.done)
				order.sort_custom(func(a: Unit, b: Unit) -> bool: return Rules.manhattan(a.pos, goal2) < Rules.manhattan(b.pos, goal2))
				for ru in order:
					ev.append_array(_toward(s, ru, goal2, false))
				if verbose:
					print("   %s" % line)
			"toi":
				var tu := s.unit_at(Vector2i(int(w[1]), int(w[2])))
				if tu == null:
					return {"state": s, "loi": "không có quân ở %s,%s (%s)" % [w[1], w[2], line], "nhat_ky": log}
				ev = _toward(s, tu, Vector2i(int(w[3]), int(w[4])))
				if verbose:
					print("   %s → %s" % [line, tu.pos])
			"goi_hang":
				var gu := s.unit_at(Vector2i(int(w[1]), int(w[2])))
				if gu == null:
					return {"state": s, "loi": "không có quân ở %s,%s (%s)" % [w[1], w[2], line], "nhat_ky": log}
				if w.size() >= 5 and Vector2i(int(w[3]), int(w[4])) != gu.pos:
					ev = Rules.cmd_move(s, gu, Vector2i(int(w[3]), int(w[4])))
					if ev.is_empty():
						return {"state": s, "loi": "không đi được: " + line, "nhat_ky": log}
				var zs := Rules.goi_hang_zones(s, gu)
				if zs.is_empty():
					var holes: Array = []
					for zn in Rules.fort_zones(s):
						holes.append(Rules.siege_gaps(s, zn, gu.faction))
					return {"state": s, "loi": "không gọi hàng được (ô hở %s): %s" % [holes, line], "nhat_ky": log}
				var gev := Rules.cmd_goi_hang(s, gu, zs[0])
				if not gev[0]["thanh_cong"]:
					return {"state": s, "loi": "gọi hàng không thành (%d/%d): %s" % [gev[0]["ta"], gev[0]["can"], line], "nhat_ky": log}
				ev.append_array(gev)
			"mua_neu":
				ev = Rules.cmd_recruit(s, s.current_faction(), Vector2i(int(w[1]), int(w[2])), w[3])
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


## path=true: khoảng cách đi bộ thật (vòng qua sông, núi); false: khoảng cách thẳng (lệnh "rut", cả đoàn dàn hàng ngang).
static func _toward(s: BattleState, u: Unit, goal: Vector2i, path := true) -> Array[Dictionary]:
	var reach := Rules.reachable(s, u)
	var best := u.pos
	var walk := SimpleAI.distance_map(s, u, [goal] as Array[Vector2i]) if path else {}
	var dist := func(p: Vector2i) -> int:
		return int(walk.get(p, 1000 + Rules.manhattan(p, goal))) if path else Rules.manhattan(p, goal)
	for rp in reach:
		var d: int = dist.call(rp)
		var bd: int = dist.call(best)
		if d < bd or (d == bd and int(reach[rp]["chi_phi"]) < int(reach[best]["chi_phi"])):
			best = rp
	var ev: Array[Dictionary] = []
	if best != u.pos:
		ev = Rules.cmd_move(s, u, best)
	var ch := Rules.chieu_hang_targets(s, u)
	if Rules.can_capture(s, u):
		ev.append_array(Rules.cmd_capture(s, u))   # tới đúng ô chiếm được (đồn, làng) thì chiếm luôn
	elif not ch.is_empty():
		ev.append_array(Rules.cmd_chieu_hang(s, u, ch[0]))   # quân sư kề quân tan thì chiêu hàng
	else:
		ev.append_array(Rules.cmd_wait(s, u))
	return ev


static func print_map(s: BattleState) -> void:
	print("--- vòng %d, báo động %d, vàng %d, thoát %d" % [s.vong, int(s.flags["bao_dong"]), s.gold.get(s.factions[0], 0), int(s.flags.get("thoat", 0))])
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
					ch = "z" if u.ngu else ("e" if u.type_id != "trinh_sat" else ("c" if u.ai_mode == "chay" else "s"))
			row += ch + " "
		for u in s.units:
			if u.pos.y == y and u.hp < 100:
				row += " %s%s:%d" % [u.type_id.substr(0, 4), u.pos, u.hp]
		print(row)
	var foes: PackedStringArray = []
	for u in s.units:
		if u.faction != s.factions[0]:
			foes.append("%s%s:%d" % [u.type_id.substr(0, 6), u.pos, u.hp])
	print("   địch: ", " ".join(foes))
