class_name SimpleAI
extends RefCounted
## AI chấm điểm đơn giản (docs/02 §14). Mỗi lần gọi next_action trả về MỘT việc cho phe đang đi,
## để lớp hiển thị chạy hoạt cảnh từng bước. Trả về {} khi phe đó hết việc.
## Dùng được cho cả phe Tây Sơn (kiểm thử "phát hiện kẹt").

const UNREACHABLE := 9999


static func next_action(state: BattleState) -> Dictionary:
	if state.result != "":
		return {}
	var f := state.current_faction()
	var buy := _plan_recruit(state, f) if allow_recruit else {}
	if not buy.is_empty():
		return buy
	var pending: Array[Unit] = []
	for u in state.units_of(f):
		if not u.done and not u.ngu:
			pending.append(u)
	if pending.is_empty():
		return {}
	pending.sort_custom(func(a: Unit, b: Unit) -> bool: return _order(a) < _order(b))
	return plan_unit(state, pending[0])


## Thực hiện một việc do next_action trả về. Trả về sự kiện.
static func execute(state: BattleState, action: Dictionary) -> Array[Dictionary]:
	var ev: Array[Dictionary] = []
	match action.get("lenh", ""):
		"mua":
			ev = Rules.cmd_recruit(state, state.current_faction(), action["o"], action["loai_quan"])
		"ke_hoach":
			var u := state.unit_by_uid(action["uid"])
			if u == null:
				return ev
			if action["den"] != u.pos:
				ev.append_array(Rules.cmd_move(state, u, action["den"]))
			if not state.units.has(u):
				return ev   # trinh sát tới khu thoát, đã rời bản đồ
			var done_ev: Array[Dictionary] = []
			match action["hanh_dong"]:
				"danh":
					done_ev = Rules.cmd_attack(state, u, state.unit_by_uid(action["muc_tieu"]))
				"chiem":
					done_ev = Rules.cmd_capture(state, u)
			if done_ev.is_empty():
				done_ev = Rules.cmd_wait(state, u)
			ev.append_array(done_ev)
	return ev


## Chạy hết lượt máy của phe hiện tại (dùng trong test / chế độ không hoạt cảnh).
static func play_turn(state: BattleState, max_actions: int = 200) -> Array[Dictionary]:
	var ev: Array[Dictionary] = []
	for i in max_actions:
		var a := next_action(state)
		if a.is_empty():
			break
		var step := execute(state, a)
		if step.is_empty():
			# Phòng kẹt: đánh dấu quân xong việc.
			var u := state.unit_by_uid(a.get("uid", -1))
			if u != null:
				u.done = true
			else:
				break
		ev.append_array(step)
	return ev


static func _order(u: Unit) -> int:
	if u.has_tag("tuong"):
		return 2
	if u.has_tag("ban_xa"):
		return 0
	return 1


## Tắt mua lính (lời giải mẫu: máy đi hộ quân nhưng người viết lời giải giữ vàng để mua thứ khác).
static var allow_recruit := true
## Tắt chiếm ô (lời giải mẫu: hoãn đủ số làng để còn làm việc khác trước khi màn chuyển giai đoạn).
static var allow_capture := true
## Lời giải mẫu (lệnh "ai_huong"): quân phe người chơi nhắm các ô này thay cho mục tiêu thường, và không lui về hồi máu.
static var goal_override: Array[Vector2i] = []


static func _plan_recruit(state: BattleState, f: String) -> Dictionary:
	if state.buyable.get(f, PackedStringArray()).is_empty():
		return {}
	for p in state.owners:
		if state.owners[p] != f:
			continue
		var opts := Rules.recruit_options(state, f, p)
		if opts.is_empty():
			continue
		var affordable: Array[String] = []
		for id in opts:
			if Rules.can_afford(state, f, id):
				affordable.append(id)
		if affordable.is_empty():
			continue
		var data := GameData.get_data()
		affordable.sort_custom(func(a: String, b: String) -> bool: return data.unit(a)["gia"] < data.unit(b)["gia"])
		var pick: String = affordable[0] if state.units_of(f).size() < 4 else affordable[-1]
		return {"lenh": "mua", "o": p, "loai_quan": pick}
	return {}


## Màn "vao_vung" (màn 0): phe người chơi (khi máy chơi thay) chạy về khu thắng, không ham đánh.
static func _escaping(state: BattleState, u: Unit) -> bool:
	var win: Dictionary = state.mission.get("thang", {})
	return u.faction == state.factions[0] and win.get("loai", "") == "vao_vung" \
		and not state.zones.get(win["khu"], []).has(u.pos)


## Màn 9: "vao_vung" nằm trong "tat_ca". Tướng chính (phe người chơi) nhắm khu đó luôn; quân khác nhắm khu khi mọi điều kiện còn lại
## đã xong. Trả về các ô khu, hoặc rỗng.
static func _zone_goal(state: BattleState, u: Unit) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var win: Dictionary = state.mission.get("thang", {})
	if u.faction != state.factions[0] or win.get("loai", "") != "tat_ca":
		return out
	var zone_cond: Dictionary = {}
	var others_done := true
	for c in win.get("dk", []):
		if c.get("loai", "") == "vao_vung":
			zone_cond = c
		elif not Rules._condition(state, c):
			others_done = false
	if zone_cond.is_empty() or not (u.tuong_chinh or others_done):
		return out
	for p in state.zones.get(zone_cond["khu"], []):
		out.append(p)
	return out


static func _goals(state: BattleState, u: Unit) -> Array[Vector2i]:
	var goals: Array[Vector2i] = []
	if not goal_override.is_empty() and u.faction == state.factions[0]:
		return goal_override.duplicate()
	if (u.ai_mode == "tuan_tra" or u.ai_mode == "do_tham") and u.ai_params.has("diem"):
		var pts: Array = u.ai_params["diem"]
		var i := int(u.ai_params.get("i", 0)) % pts.size()
		if u.pos == pts[i]:
			i = (i + 1) % pts.size()
			u.ai_params["i"] = i
		goals.append(pts[i])
		return goals
	if u.ai_mode == "rut_lui" or u.ai_mode == "chay":
		if u.ai_params.has("vung"):
			for p in u.ai_params["vung"]:
				goals.append(p)
		elif u.ai_mode == "chay" and state.zones.has(u.ai_params.get("khu", "")):
			for p in state.zones[u.ai_params["khu"]]:
				goals.append(p)   # màn 9: Tôn Sĩ Nghị chạy sang bờ đông
		elif u.ai_mode == "rut_lui" and state.zones.has(state.mission.get("khu_rut_lui", "")):
			for p in state.zones[state.mission["khu_rut_lui"]]:
				goals.append(p)
		else:
			for x in state.width:
				goals.append(Vector2i(x, 0))
		return goals
	# Tướng chính phe người chơi (khi máy chơi thay để kiểm thử) nhắm thẳng mục tiêu màn.
	var win: Dictionary = state.mission.get("thang", {})
	if _escaping(state, u):
		for p in state.zones.get(win["khu"], []):
			goals.append(p)
		return goals
	var zg := _zone_goal(state, u)
	if not zg.is_empty():
		return zg
	if u.tuong_chinh and u.faction == state.factions[0] and win.get("loai", "") == "chiem_o":
		var obj := Vector2i(int(win["o"][0]), int(win["o"][1]))
		var guarded := false
		for e in state.enemies_of(u.faction):
			if Rules.manhattan(e.pos, obj) <= 3:
				guarded = true
		if not guarded:
			goals.append(obj)
			return goals
		# Mục tiêu còn quân giữ: đi sau đội hình (ô của quân mình), không xông lên một mình.
		for o in state.units_of(u.faction):
			if o != u:
				goals.append(o.pos)
		if not goals.is_empty():
			return goals
	# Ban đêm máy chỉ biết quân đối phương mà phe mình đang thấy (02 §14).
	var vis := Rules.visible_tiles(state, u.faction)
	for e in state.enemies_of(u.faction):
		if Rules.can_see(state, u.faction, e.pos, vis):
			goals.append(e.pos)
	# Ô chiếm được (cả làng chưa có chủ — màn 2): quân chiếm được thì nhắm tới; quân khác nhắm ô của đối phương.
	var can_village := u.has_tag("chiem_lang") or u.has_tag("tuong")
	for y in state.height:
		for x in state.width:
			var p := Vector2i(x, y)
			var t := state.terrain_at(p)
			if not t["so_huu"]:
				continue
			var own := state.owner_of(p)
			if own != "" and state.are_allies(own, u.faction):
				continue
			if own == "" and not (can_village and t["id"] == "lang"):
				continue
			goals.append(p)
	return goals


## Khoảng cách đi bộ (theo chi phí địa hình, bỏ qua quân) từ mọi ô tới mục tiêu gần nhất.
static func distance_map(state: BattleState, u: Unit, goals: Array[Vector2i]) -> Dictionary:
	var dist := {}
	var open: Array[Vector2i] = []
	for g in goals:
		dist[g] = 0
		open.append(g)
	var closed := {}
	while not open.is_empty():
		var best := 0
		for i in range(1, open.size()):
			if dist[open[i]] < dist[open[best]]:
				best = i
		var p: Vector2i = open[best]
		open.remove_at(best)
		if closed.has(p):
			continue
		closed[p] = true
		for d in Rules.DIRS:
			var n := p + d
			if not state.in_bounds(n):
				continue
			var c := Rules.move_cost(state, u, n)
			if c < 0:
				continue
			var nd: int = dist[p] + c
			if nd < dist.get(n, UNREACHABLE):
				dist[n] = nd
				open.append(n)
	return dist


static func _target_value(t: Unit) -> float:
	if t.tuong_chinh:
		return 2.0
	if t.has_tag("tuong"):
		return 1.5
	return 0.6 + float(t.data()["gia"]) / 1000.0


## Mối đe dọa ở lượt sau: với mỗi ô, tổng công tối đa của quân đối phương có thể đi tới và đánh ô đó.
static func threat_map(state: BattleState, f: String) -> Dictionary:
	var threat := {}
	for e in state.enemies_of(f):
		if e.ngu:
			continue
		var hit := {}
		var spots: Array = [e.pos] if e.has_tag("ban_dung") else Rules.reachable(state, e).keys()
		var lo := int(e.data()["tam_min"])
		var hi := int(e.data()["tam_max"])
		for sp in spots:
			for dy in range(-hi, hi + 1):
				for dx in range(-hi, hi + 1):
					var dist := absi(dx) + absi(dy)
					if dist >= lo and dist <= hi:
						hit[Vector2i(sp.x + dx, sp.y + dy)] = true
		var power := int(e.data()["cong_max"]) + e.level * Rules.LEVEL_ATK
		for p in hit:
			threat[p] = int(threat.get(p, 0)) + power
	return threat


static func plan_unit(state: BattleState, u: Unit) -> Dictionary:
	var plan := {"lenh": "ke_hoach", "uid": u.uid, "den": u.pos, "hanh_dong": "cho", "muc_tieu": -1}
	if u.ai_mode == "dung_yen" or u.ai_mode == "ngu" or (u.ai_mode == "do_tham" and not u.ai_params.has("diem")):
		return plan
	var reach := Rules.reachable(state, u)
	var fleeing := u.ai_mode in ["rut_lui", "chay", "tuan_tra", "do_tham"] or _escaping(state, u)
	var goals := _goals(state, u)
	# Quân yếu (máu < 35) lui về làng / đồn của phe mình để hồi máu; chỉ đánh khi chắc hạ được.
	var healing := false
	if not fleeing and u.hp < 35 and u.ai_mode != "giu_don" and (goal_override.is_empty() or u.faction != state.factions[0]):
		var heal_spots: Array[Vector2i] = []
		for p in state.owners:
			if state.are_allies(state.owners[p], u.faction) and int(state.terrain_at(p)["hoi_mau"]) > 0:
				var occ := state.unit_at(p)
				if occ == null or occ == u:
					heal_spots.append(p)
		if not heal_spots.is_empty():
			goals = heal_spots
			healing = true
	var dmap := distance_map(state, u, goals)
	var center: Vector2i = u.ai_params.get("tam", u.pos)
	var radius: int = u.ai_params.get("ban_kinh", -1)
	var best_score := -INF
	var original := u.pos
	# Tướng chính tránh chỗ nguy hiểm; quân thường chỉ cân nhắc nhẹ.
	var win: Dictionary = state.mission.get("thang", {})
	# Ô phải chiếm để thắng (cả trong "tat_ca", vd. màn phụ P chiếm hai bến): quân thường của phe người chơi không đứng chắn.
	var objectives: Array[Vector2i] = []
	if u.faction == state.factions[0]:
		for c in [win] + win.get("dk", []):
			if c.get("loai", "") == "chiem_o":
				objectives.append(Vector2i(int(c["o"][0]), int(c["o"][1])))
	var threat := threat_map(state, u.faction)
	var danger_w := 0.25 if u.tuong_chinh else 0.02
	# Quân giữ đồn đang ở ngoài vùng (vd. lính tuần vừa báo động) thì chạy về; ở trong vùng thì không ra.
	var guard_outside := u.ai_mode == "giu_don" and radius >= 0 and Rules.manhattan(u.pos, center) > radius
	for p in reach:
		if u.ai_mode == "giu_don" and radius >= 0 and not guard_outside and Rules.manhattan(p, center) > radius:
			continue
		var base: float = -float(dmap.get(p, UNREACHABLE)) * (3.0 if fleeing else 1.5)
		if u.ai_mode == "giu_don":
			base = -float(Rules.manhattan(p, center)) * (3.0 if guard_outside else 0.5)
		if not goal_override.is_empty() and u.faction == state.factions[0]:
			base -= float(Rules.manhattan(p, goal_override[0])) * 0.05   # "ai_huong": hòa điểm thì nhích lên, không đứng chắn hàng
		if u.ai_mode != "rut_lui":
			base += float(state.terrain_at(p)["thu"]) * 0.3   # quân rút lui chỉ lo chạy: không thì đứng lì trên đê, không xuống đầm (màn 8)
		if state.object_at(p).get("loai", "") == "lua" and not u.has_tag("khong_chay"):
			base -= 30.0   # đừng đứng trên ô lửa, đang đứng thì bước ra (02 §12)
		if state.object_at(p).get("loai", "") == "chong" and p != original and u.faction != state.factions[0]:
			base -= 12.0   # chông: −15 máu (quân Thanh tránh; phe người chơi khi máy chơi thay thì phải qua chông mới tới đồn)
		if state.object_at(p).get("loai", "") == "dia_loi" and p != original:
			base -= 25.0   # địa lôi đã biết
		if u.ai_mode != "rut_lui":
			base -= float(threat.get(p, 0)) * danger_w   # quân rút lui cứ chạy: không thì kẹt lại khi quân ta đông (màn 8)
		if u.tuong_chinh and int(threat.get(p, 0)) >= u.hp + 20:
			base -= 200.0  # có thể bị hạ ở lượt sau
		if state.terrain_at(p)["mua_linh"] and state.owner_of(p) == u.faction and not u.tuong_chinh:
			base -= 25.0   # đừng đứng chắn ô mua lính của phe mình
		if objectives.has(p) and not u.has_tag("tuong"):
			base -= 100.0  # đừng đứng lên ô mục tiêu chiếm: chỉ tướng chiếm được, quân thường đứng đó là chắn đường tướng
		if base > best_score:
			best_score = base
			plan = {"lenh": "ke_hoach", "uid": u.uid, "den": p, "hanh_dong": "cho", "muc_tieu": -1}
		if fleeing:
			continue
		# Chiếm
		u.pos = p
		var cap := allow_capture and Rules.can_capture(state, u)
		u.pos = original
		if cap:
			var tid := state.terrain_id(p)
			var s: float = base + (140.0 if tid != "lang" else 60.0)
			if s > best_score:
				best_score = s
				plan = {"lenh": "ke_hoach", "uid": u.uid, "den": p, "hanh_dong": "chiem", "muc_tieu": -1}
		# Đánh
		for t in Rules.targets_from(state, u, p, p != original):
			var charge := 0
			if u.has_tag("xung_phong"):
				u.pos = original
				charge = maxi(Rules.straight_path(state, u, p).size() - 1, 0)
			var fc := Rules.forecast(state, u, p, t, charge)
			var exp: float = (fc["st_min"] + fc["st_max"]) / 2.0
			var val: float = _target_value(t)
			var counter: float = (fc["pd_min"] + fc["pd_max"]) / 2.0 if fc["phan_don"] else 0.0
			var counter_w := 2.0 if u.tuong_chinh else 0.7
			if healing and fc["ti_le_ha"] < 0.5:
				continue
			var s2: float = base * 0.2 + exp * val + fc["ti_le_ha"] * 60.0 * val - counter * counter_w
			if u.tuong_chinh:
				s2 -= float(threat.get(p, 0)) * danger_w
			if s2 > best_score:
				best_score = s2
				plan = {"lenh": "ke_hoach", "uid": u.uid, "den": p, "hanh_dong": "danh", "muc_tieu": t.uid}
	return plan
