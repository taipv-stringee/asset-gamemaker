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
	var buy := _plan_recruit(state, f)
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


static func _goals(state: BattleState, u: Unit) -> Array[Vector2i]:
	var goals: Array[Vector2i] = []
	if u.ai_mode == "rut_lui" or u.ai_mode == "chay":
		if u.ai_params.has("vung"):
			for p in u.ai_params["vung"]:
				goals.append(p)
		else:
			for x in state.width:
				goals.append(Vector2i(x, 0))
		return goals
	for e in state.enemies_of(u.faction):
		goals.append(e.pos)
	for p in state.owners:
		if not state.are_allies(state.owners[p], u.faction):
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


static func plan_unit(state: BattleState, u: Unit) -> Dictionary:
	var plan := {"lenh": "ke_hoach", "uid": u.uid, "den": u.pos, "hanh_dong": "cho", "muc_tieu": -1}
	if u.ai_mode == "dung_yen":
		return plan
	var reach := Rules.reachable(state, u)
	var fleeing := u.ai_mode == "rut_lui" or u.ai_mode == "chay"
	var dmap := distance_map(state, u, _goals(state, u))
	var center: Vector2i = u.ai_params.get("tam", u.pos)
	var radius: int = u.ai_params.get("ban_kinh", -1)
	var best_score := -INF
	var original := u.pos
	for p in reach:
		if u.ai_mode == "giu_don" and radius >= 0 and Rules.manhattan(p, center) > radius:
			continue
		var base: float = -float(dmap.get(p, UNREACHABLE)) * (3.0 if fleeing else 1.5)
		if u.ai_mode == "giu_don":
			base = -float(Rules.manhattan(p, center)) * 0.5
		base += float(state.terrain_at(p)["thu"]) * 0.3
		if base > best_score:
			best_score = base
			plan = {"lenh": "ke_hoach", "uid": u.uid, "den": p, "hanh_dong": "cho", "muc_tieu": -1}
		if fleeing:
			continue
		# Chiếm
		u.pos = p
		var cap := Rules.can_capture(state, u)
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
			var s2: float = base * 0.2 + exp * val + fc["ti_le_ha"] * 60.0 * val - counter * 0.7
			if s2 > best_score:
				best_score = s2
				plan = {"lenh": "ke_hoach", "uid": u.uid, "den": p, "hanh_dong": "danh", "muc_tieu": t.uid}
	return plan
