class_name Rules
extends RefCounted
## Luật chơi (docs/02-luat-choi.md). Mọi hàm là static, nhận BattleState và trả về danh sách sự kiện
## (Dictionary có khóa "loai") để lớp hiển thị chạy hoạt cảnh. Không phụ thuộc Node.

const DIRS: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
const XP_LEVELS: Array[int] = [100, 250, 450, 700]
const LEVEL_ATK := 3
const LEVEL_DEF := 2
const NO_QUAN_TAN: Array[String] = ["cau", "cau_phao", "song", "dam", "don", "thanh"]
const CHAN_HAU_TERRAIN: Array[String] = ["cau", "cau_phao", "de", "song_can"]
const INF := 1 << 30
const FIRE_ROUNDS := 3   # ô doanh trại bị Đốt cháy 3 vòng rồi thành "doanh trại cháy" (02 §12)


# ================================================================ tiện ích

static func manhattan(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)


static func chebyshev(a: Vector2i, b: Vector2i) -> int:
	return maxi(absi(a.x - b.x), absi(a.y - b.y))


## Số ngẫu nhiên tất định theo (seed, vòng, người đánh, bị đánh, số thứ tự đòn) — 02 §4.5.
static func roll(state: BattleState, a: int, b: int, n: int, lo: int, hi: int) -> int:
	var h := 0x811C9DC5
	for v in [state.rng_seed, state.vong, a, b, n]:
		h = ((h ^ (int(v) & 0xFFFFFFFF)) * 0x01000193) & 0xFFFFFFFF
	h ^= h >> 16
	h = (h * 0x85EBCA6B) & 0xFFFFFFFF
	h ^= h >> 13
	h = (h * 0xC2B2AE35) & 0xFFFFFFFF
	h ^= h >> 16
	return lo + h % (hi - lo + 1)


static func is_night(state: BattleState) -> bool:
	return state.tam_nhin > 0 and state.tam_nhin <= 3


# ================================================================ đêm, tầm nhìn (02 §10)

const LIGHT_OBJECTS: Array[String] = ["den", "duoc_don", "lua"]


static func is_dark(state: BattleState) -> bool:
	return state.tam_nhin > 0


static func light_sources(state: BattleState) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for p in state.objects:
		if LIGHT_OBJECTS.has(state.objects[p].get("loai", "")):
			out.append(p)
	for u in state.units:
		if u.duoc:
			out.append(u.pos)
	return out


## Ô sáng: nguồn sáng và 4 ô kề — luôn được thấy, cả hai phe.
static func lit_tiles(state: BattleState) -> Dictionary:
	var lit := {}
	for p in light_sources(state):
		lit[p] = true
		for d in DIRS:
			lit[p + d] = true
	return lit


## Các ô phe f thấy được. Ban ngày: trả về {} và dùng can_see() (luôn đúng).
static func visible_tiles(state: BattleState, f: String) -> Dictionary:
	if not is_dark(state):
		return {}
	var vis := lit_tiles(state)
	for u in state.units:
		if not state.are_allies(u.faction, f) or u.ngu:
			continue
		var r := state.tam_nhin + (1 if u.duoc else 0)
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				if absi(dx) + absi(dy) <= r:
					vis[u.pos + Vector2i(dx, dy)] = true
	return vis


static func can_see(state: BattleState, f: String, p: Vector2i, vis: Dictionary = {}) -> bool:
	if not is_dark(state):
		return true
	if vis.is_empty():
		vis = visible_tiles(state, f)
	return vis.has(p)


## Quân địch thức có thấy quân `target` không (để báo động).
static func watcher_sees(state: BattleState, watcher: Unit, target: Unit, lit: Dictionary) -> bool:
	if watcher.ngu:
		return false
	var d := manhattan(watcher.pos, target.pos)
	return d <= maxi(state.tam_nhin, 2) or (lit.has(target.pos) and d <= 5)


# ================================================================ di chuyển

static func move_cost(state: BattleState, u: Unit, p: Vector2i) -> int:
	var t := state.terrain_at(p)
	var c: int = t["chi_phi"][u.data()["kieu_di"]]
	if c > 0 and u.has_tag("tho_dia") and (t["id"] == "doi" or t["id"] == "rung_tre"):
		c = 1
	return c


static func move_points(state: BattleState, u: Unit) -> int:
	var di: int = u.data()["di"]
	if u.chay_turns > 0:
		di -= 1
	if u.data()["kieu_di"] == "thuy" and not u.has_tag("tuong") and _near_tag(state, u, u.pos, "thuy_quan"):
		di += 1
	return maxi(di, 0)


## Ô bị khống chế bởi quân đối phương có thẻ `chan` (02 §3). `vis` khác rỗng: chỉ tính quân địch phe u thấy.
static func zoc_tiles(state: BattleState, u: Unit, vis: Dictionary = {}) -> Dictionary:
	var zoc := {}
	for e in state.units:
		if state.are_allies(e.faction, u.faction) or not e.has_tag("chan"):
			continue
		if not vis.is_empty() and not vis.has(e.pos):
			continue
		for d in DIRS:
			zoc[e.pos + d] = true
	return zoc


static func _enterable(state: BattleState, u: Unit, p: Vector2i, vis: Dictionary = {}) -> bool:
	if not state.in_bounds(p) or move_cost(state, u, p) < 0:
		return false
	var occ := state.unit_at(p)
	if occ != null and not state.are_allies(occ.faction, u.faction) and (vis.is_empty() or vis.has(p)):
		return false
	var obj: Dictionary = state.object_at(p)
	if obj.get("loai", "") == "quan_tan":
		return false
	if obj.get("loai", "") == "dia_loi" and obj.get("phe", "") == u.faction and not _fleeing(u):
		return false   # máy biết và tránh địa lôi của phe mình, trừ khi đang Chạy / Rút lui (02 §12)
	return true


static func _fleeing(u: Unit) -> bool:
	return u.ai_mode == "rut_lui" or u.ai_mode == "chay"


## Ô bẫy làm quân dừng lại (02 §12): chông sắt; địa lôi mà phe quân đó biết (đã lộ, hoặc của phe mình).
static func _trap_known(state: BattleState, u: Unit, p: Vector2i) -> bool:
	var obj: Dictionary = state.object_at(p)
	match obj.get("loai", ""):
		"chong":
			return true
		"dia_loi":
			# Quân đang Chạy / Rút lui hoảng loạn, không còn nhớ chỗ địa lôi của mình (Liệt truyện: giẫm phải mà chết).
			return obj.get("lo", false) or (obj.get("phe", "") == u.faction and not _fleeing(u))
	return false


## Bước vào ô bẫy thật (kể cả địa lôi ẩn): chông, địa lôi.
static func _trap_at(state: BattleState, p: Vector2i) -> bool:
	return state.object_at(p).get("loai", "") in ["chong", "dia_loi"]


## Các ô quân có thể dừng lại: {Vector2i: {"chi_phi": int, "duong": Array[Vector2i]}}. Gồm cả ô đang đứng.
## `fog`: tính như người chơi thấy — quân địch trong sương coi như không có (02 §3 "phục kích").
static func reachable(state: BattleState, u: Unit, fog := false) -> Dictionary:
	var mp := move_points(state, u)
	var vis := visible_tiles(state, u.faction) if fog else {}
	var zoc: Dictionary = {} if u.has_tag("xung_phong") else zoc_tiles(state, u, vis)
	var dist := {u.pos: 0}
	var prev := {}
	var open: Array[Vector2i] = [u.pos]
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
		if p != u.pos and (zoc.has(p) or _trap_known(state, u, p)):
			continue  # vào vùng khống chế / ô chông / địa lôi đã biết thì dừng
		for d in DIRS:
			var n := p + d
			if not _enterable(state, u, n, vis):
				continue
			var nd: int = dist[p] + move_cost(state, u, n)
			if nd > mp or nd >= dist.get(n, INF):
				continue
			dist[n] = nd
			prev[n] = p
			open.append(n)
	var out := {}
	for p in dist:
		var occ := state.unit_at(p)
		var hidden := occ != null and not vis.is_empty() and not vis.has(p)
		if p == u.pos or occ == null or hidden:
			var path: Array[Vector2i] = [p]
			var c: Vector2i = p
			while c != u.pos:
				c = prev[c]
				path.push_front(c)
			out[p] = {"chi_phi": dist[p], "duong": path}
	return out


static func path_to(reach: Dictionary, _start: Vector2i, target: Vector2i) -> Array[Vector2i]:
	if not reach.has(target):
		return [] as Array[Vector2i]
	return reach[target]["duong"]


## Đường thẳng cho Xung phong; rỗng nếu không đi thẳng được.
static func straight_path(state: BattleState, u: Unit, target: Vector2i) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	if target == u.pos or (target.x != u.pos.x and target.y != u.pos.y):
		return path
	var step := (target - u.pos).sign()
	var cost := 0
	var p := u.pos
	path.append(p)
	while p != target:
		p += step
		if not _enterable(state, u, p):
			return [] as Array[Vector2i]
		cost += move_cost(state, u, p)
		if cost > move_points(state, u):
			return [] as Array[Vector2i]
		path.append(p)
	if state.unit_at(target) != null:
		return [] as Array[Vector2i]
	return path


# ================================================================ đánh

static func _near_tag(state: BattleState, u: Unit, at: Vector2i, tag: String) -> bool:
	for o in state.units:
		if o != u and o.faction == u.faction and chebyshev(o.pos, at) == 1 and o.has_tag(tag):
			return true
	return false


static func _aura_attack(state: BattleState, u: Unit, at: Vector2i) -> int:
	var total := 0
	if _near_tag(state, u, at, "hao_quang"):
		total += 10
	if _near_tag(state, u, at, "uy_danh"):
		total += 5
	if _near_tag(state, u, at, "thong_soai"):
		total += 5
	return mini(total, 10)


static func _match(sel: String, u: Unit, state: BattleState, at: Vector2i) -> bool:
	if sel.begins_with("id:"):
		return u.type_id == sel.substr(3)
	if sel.begins_with("the:"):
		return u.has_tag(sel.substr(4))
	if sel.begins_with("o:"):
		return state.terrain_id(at) == sel.substr(2)
	return sel == "*"


## Chỉ số một đòn: {"cong_min","cong_max","thu"} — 02 §4.2.
static func strike_stats(state: BattleState, att: Unit, att_at: Vector2i, def: Unit, def_at: Vector2i,
		is_counter: bool, charge_steps: int = 0) -> Dictionary:
	var bonus := att.level * LEVEL_ATK + _aura_attack(state, att, att_at)
	var def_bonus := def.level * LEVEL_DEF
	for c in GameData.get_data().counters:
		if _match(c["ben_danh"], att, state, att_at) and _match(c["ben_bi_danh"], def, state, def_at):
			bonus += c["cong"]
			def_bonus += c["thu"]
	if not is_counter:
		if att.has_tag("xung_phong") and charge_steps >= 3:
			bonus += 10
		if att.has_tag("hang_mau"):
			bonus += 10
	if def.ngu:
		bonus += 15
	if att.has_tag("tap_kich") and is_night(state):
		bonus += 10
	if att.chay_turns > 0:
		bonus -= 10
	var tid := state.terrain_id(def_at)
	def_bonus += int(state.terrain_at(def_at)["thu"])
	if def.than_trong:
		def_bonus += 10
	if def.has_tag("chan_hau") and CHAN_HAU_TERRAIN.has(tid):
		def_bonus += 10
	if def.has_tag("tu_thu") and tid == "don":
		def_bonus += 10
	if _near_tag(state, def, def_at, "muu_si"):
		def_bonus += 5
	if def.type_id == "voi_chien" and _near_tag(state, def, def_at, "tuong_binh"):
		def_bonus += 5
	if def.chay_turns > 0:
		def_bonus -= 10
	var d := att.data()
	return {
		"cong_min": int(d["cong_min"]) + bonus,
		"cong_max": int(d["cong_max"]) + bonus,
		"thu": int(def.data()["thu"]) + def_bonus,
	}


static func damage(cong: int, thu: int, hp_att: int) -> int:
	var st := (maxi(0, cong - thu) * hp_att) / 100
	return maxi(st, cong / 10)


static func in_range(att: Unit, from: Vector2i, target: Vector2i) -> bool:
	var dist := manhattan(from, target)
	return dist >= int(att.data()["tam_min"]) and dist <= int(att.data()["tam_max"])


static func can_counter(def: Unit, def_at: Vector2i, att_at: Vector2i) -> bool:
	if def.has_tag("ban_dung") or def.ngu:
		return false
	return in_range(def, def_at, att_at)


## Mục tiêu đánh được khi đứng ở `from`. `will_have_moved`: quân đã / sẽ di chuyển trong lượt.
static func targets_from(state: BattleState, u: Unit, from: Vector2i, will_have_moved: bool) -> Array[Unit]:
	var out: Array[Unit] = []
	if u.has_tag("ban_dung") and will_have_moved:
		return out
	var vis := visible_tiles(state, u.faction)
	for e in state.units:
		if state.are_allies(e.faction, u.faction):
			continue
		if in_range(u, from, e.pos) and can_see(state, u.faction, e.pos, vis):
			out.append(e)
	return out


## Dự báo (02 §4.4): khoảng sát thương, % hạ, khoảng phản đòn.
static func forecast(state: BattleState, att: Unit, from: Vector2i, def: Unit, charge_steps: int = 0) -> Dictionary:
	var s := strike_stats(state, att, from, def, def.pos, false, charge_steps)
	var lo := INF
	var hi := 0
	var kills := 0
	var n := 0
	for c in range(s["cong_min"], s["cong_max"] + 1):
		var st := damage(c, s["thu"], att.hp)
		lo = mini(lo, st)
		hi = maxi(hi, st)
		if st >= def.hp and not def.toi_thieu_1:
			kills += 1
		n += 1
	var out := {"st_min": lo, "st_max": hi, "ti_le_ha": float(kills) / float(n),
		"phan_don": false, "pd_min": 0, "pd_max": 0}
	if kills < n and can_counter(def, def.pos, from):
		var cs := strike_stats(state, def, def.pos, att, from, true)
		var hp_hi := def.hp - lo
		var hp_lo := maxi(def.hp - hi, 1)
		out["phan_don"] = true
		out["pd_min"] = damage(cs["cong_min"], cs["thu"], hp_lo)
		out["pd_max"] = damage(cs["cong_max"], cs["thu"], hp_hi)
	return out


static func _apply_damage(u: Unit, st: int) -> void:
	u.hp = maxi(0, u.hp - st)
	if u.toi_thieu_1 and u.hp < 1:
		u.hp = 1
	# Còn sống mà máu dưới ngưỡng thì chuyển sang Rút lui (02 §14, màn 8). Đòn đủ hạ thì vẫn hạ: trước đây giữ lại 1 máu
	# làm mỗi quân Thanh cần thêm một đòn, màn 8 quá khó. Tướng không bị hạ ở màn 8 là nhờ toi_thieu_1.
	if u.rut_khi_yeu > 0 and u.hp > 0 and u.hp < u.rut_khi_yeu:
		u.ai_mode = "rut_lui"


static func _strike(state: BattleState, att: Unit, def: Unit, is_counter: bool, n: int) -> Dictionary:
	var s := strike_stats(state, att, att.pos, def, def.pos, is_counter, att.straight_steps)
	var cong := roll(state, att.uid, def.uid, n * 2 + (1 if is_counter else 0), s["cong_min"], s["cong_max"])
	var st := damage(cong, s["thu"], att.hp)
	_apply_damage(def, st)
	att.xp += st
	if att.has_tag("gay_chay") and not def.has_tag("khong_chay") and def.hp > 0:
		def.chay_turns = 2 if def.faction == state.current_faction() else 1
	return {"loai": "danh", "uid": att.uid, "muc_tieu": def.uid, "st": st, "mau_con": def.hp,
		"phan_don": is_counter, "chay": def.chay_turns > 0 and att.has_tag("gay_chay")}


# ================================================================ lệnh

static func can_act(state: BattleState, u: Unit) -> bool:
	return state.result == "" and u.faction == state.current_faction() and not u.done


static func cmd_move(state: BattleState, u: Unit, target: Vector2i, fog := false) -> Array[Dictionary]:
	var ev: Array[Dictionary] = []
	if not can_act(state, u) or u.moved:
		return ev
	var reach := reachable(state, u, fog and is_dark(state))
	if not reach.has(target):
		return ev
	var path: Array[Vector2i] = []
	if u.has_tag("xung_phong"):
		path = straight_path(state, u, target)
	u.straight_steps = path.size() - 1 if path.size() > 1 else 0
	if path.is_empty():
		path = path_to(reach, u.pos, target)
	var seen_before := _seen_enemies(state, u.faction)
	var ambush := _ambush_stop(state, u, path)
	if ambush["dung"] < path.size() - 1:
		path = path.slice(0, ambush["dung"] + 1)
		target = path[-1]
		u.khoa_hoan_tac = true
	var trap_i := -1
	for i in range(1, path.size()):
		if _trap_at(state, path[i]):
			trap_i = i
			break
	if trap_i > 0 and trap_i < path.size() - 1:
		path = path.slice(0, trap_i + 1)   # bẫy: dừng lại ở ô đó
		target = path[-1]
	u.move_origin = u.pos
	u.pos = target
	u.moved = true
	ev.append({"loai": "di", "uid": u.uid, "duong": path})
	if trap_i > 0:
		u.khoa_hoan_tac = true
		ev.append_array(_spring_trap(state, u))
		if not state.units.has(u):
			return ev
	for i in range(1, path.size()):
		if state.object_at(path[i]).get("loai", "") == "lua":
			ev.append_array(_catch_fire(state, u))   # bước vào ô lửa: Cháy (02 §12)
			u.khoa_hoan_tac = true   # như phục kích: đã bị Cháy thì không hoàn tác được (kiểm thử M3 lần 6)
			break
	if ambush.has("dich"):
		ev.append({"loai": "phuc_kich", "uid": u.uid, "dich": ambush["dich"], "o": target})
	if is_dark(state):
		for uid in _seen_enemies(state, u.faction):
			if not seen_before.has(uid):
				u.khoa_hoan_tac = true
				ev.append({"loai": "lo_dien", "uid": uid})
	ev.append_array(_escape(state, u))
	_reveal_mines(state)
	return ev


## Chông sắt: −15 máu (voi, mộc thuẫn −5), không mất. Địa lôi: −30 máu rồi mất (02 §12). Bị hạ được.
static func _spring_trap(state: BattleState, u: Unit) -> Array[Dictionary]:
	var ev: Array[Dictionary] = []
	var o: Dictionary = state.object_at(u.pos)
	var st := 0
	if o.get("loai", "") == "chong":
		st = 5 if (u.has_tag("voi") or u.type_id == "moc_thuan") else 15
		ev.append({"loai": "chong", "uid": u.uid, "o": u.pos, "st": st})
	elif o.get("loai", "") == "dia_loi":
		st = 30
		state.objects.erase(u.pos)
		ev.append({"loai": "dia_loi_no", "uid": u.uid, "o": u.pos, "st": st})
	_apply_damage(u, st)
	if u.hp <= 0:
		ev.append_array(_defeat(state, u))
		ev.append_array(check_result(state))
	return ev


## Quân có thẻ thay_dia_loi (quân sư) thấy địa lôi ở 4 ô kề.
static func _reveal_mines(state: BattleState) -> void:
	for u in state.units:
		if not u.has_tag("thay_dia_loi"):
			continue
		for d in DIRS:
			var o: Dictionary = state.object_at(u.pos + d)
			if o.get("loai", "") == "dia_loi" and o.get("phe", "") != u.faction:
				o["lo"] = true


# ================================================================ trinh sát (màn 5; 02 §14 chế độ Chạy)
# Quân "ai": "do_tham" đứng / tuần tra như thường; đầu lượt phe nó, thấy quân đối phương trong bán kính "thay" (mặc định 3)
# thì đổi sang "chay" về khu "khu". Quân đang chạy tới được khu đó thì rời bản đồ ("báo tin"): đếm vào flags["thoat"]
# và bật cờ màn "co_khi_thoat" (nếu có) — màn sau đọc được qua Progress (luu_co).

static func _scouts_spot(state: BattleState, f: String) -> Array[Dictionary]:
	var ev: Array[Dictionary] = []
	var lit := lit_tiles(state) if is_dark(state) else {}
	for u in state.units_of(f):
		if u.ai_mode != "do_tham" or u.ngu:
			continue
		var r := int(u.ai_params.get("thay", 3))
		for e in state.enemies_of(f):
			var near := manhattan(u.pos, e.pos) <= r
			if near and (not is_dark(state) or watcher_sees(state, u, e, lit)):
				u.ai_mode = "chay"
				var zone: Array[Vector2i] = []
				for c in state.zones.get(u.ai_params.get("khu", ""), []):
					zone.append(c)
				u.ai_params["vung"] = zone
				ev.append({"loai": "trinh_sat_chay", "uid": u.uid})
				break
	return ev


static func _escape(state: BattleState, u: Unit) -> Array[Dictionary]:
	var ev: Array[Dictionary] = []
	if u.ai_mode == "rut_lui":
		# Màn 8: quân rút lui tới khu "khu_rut_lui" (mép bắc) thì rời bản đồ — tướng sang màn 9.
		if (state.zones.get(state.mission.get("khu_rut_lui", ""), []) as Array).has(u.pos):
			state.remove_unit(u)
			var gone: Array = state.flags.get("rut_khoi", [])
			gone.append(u.type_id)
			state.flags["rut_khoi"] = gone
			ev.append({"loai": "rut_khoi", "uid": u.uid, "o": u.pos, "phe": u.faction})
		return ev
	if u.ai_mode != "chay" or not u.ai_params.has("khu"):
		return ev
	if not (state.zones.get(u.ai_params["khu"], []) as Array).has(u.pos):
		return ev
	state.remove_unit(u)
	state.flags["thoat"] = int(state.flags.get("thoat", 0)) + 1
	var fled: Array = state.flags.get("thoat_loai", [])
	fled.append(u.type_id)   # màn 9: Tôn Sĩ Nghị qua hết cầu thì cầu rung
	state.flags["thoat_loai"] = fled
	var flag: String = state.mission.get("co_khi_thoat", "")
	if flag != "":
		var flags: Dictionary = state.flags.get("co", {})
		flags[flag] = true
		state.flags["co"] = flags
	ev.append({"loai": "thoat", "uid": u.uid, "o": u.pos, "phe": u.faction})
	return ev


## Đi theo `path` (tính trong sương) với luật thật: gặp quân địch ẩn thì dừng ở ô trước đó;
## bước vào vùng khống chế của quân địch ẩn thì dừng ở đó. Trả về {"dung": chỉ số ô dừng, "dich": uid (nếu phục kích)}.
static func _ambush_stop(state: BattleState, u: Unit, path: Array[Vector2i]) -> Dictionary:
	var last := path.size() - 1
	var zoc: Dictionary = {} if u.has_tag("xung_phong") else zoc_tiles(state, u)
	for i in range(1, path.size()):
		var occ := state.unit_at(path[i])
		if occ != null and not state.are_allies(occ.faction, u.faction):
			var stop := i - 1
			while stop > 0 and state.unit_at(path[stop]) != null:
				stop -= 1  # không dừng trên ô có quân mình
			return {"dung": stop, "dich": occ.uid}
		if zoc.has(path[i]) and i < last and state.unit_at(path[i]) == null:
			for d in DIRS:
				var e := state.unit_at(path[i] + d)
				if e != null and not state.are_allies(e.faction, u.faction) and e.has_tag("chan"):
					return {"dung": i, "dich": e.uid}
	return {"dung": last}


## uid các quân địch phe `f` đang thấy (ban đêm).
static func _seen_enemies(state: BattleState, f: String) -> Dictionary:
	var out := {}
	if not is_dark(state):
		return out
	var vis := visible_tiles(state, f)
	for e in state.enemies_of(f):
		if vis.has(e.pos):
			out[e.uid] = true
	return out


static func cmd_undo_move(state: BattleState, u: Unit) -> Array[Dictionary]:
	var ev: Array[Dictionary] = []
	if not can_act(state, u) or not u.moved or u.khoa_hoan_tac:
		return ev
	var from := u.pos
	u.pos = u.move_origin
	u.moved = false
	u.straight_steps = 0
	ev.append({"loai": "hoan_tac", "uid": u.uid, "tu": from, "ve": u.pos})
	return ev


static func cmd_attack(state: BattleState, u: Unit, target: Unit) -> Array[Dictionary]:
	var ev: Array[Dictionary] = []
	if not can_act(state, u) or target == null:
		return ev
	if not targets_from(state, u, u.pos, u.moved and u.pos != u.move_origin).has(target):
		return ev
	var n := state.strike_counter
	state.strike_counter += 1
	var was_asleep := target.ngu
	if u.faction == state.factions[0] and fort_zones(state).has(state.zone_of(target.pos)):
		state.flags["danh_trong_khu"] = true   # mục tiêu phụ "gọi hàng mà không đánh quân nào trong khu" (màn 6)
	ev.append(_strike(state, u, target, false, n))
	if was_asleep:
		target.ngu = false
	if target.hp <= 0:
		u.xp += 30
		ev.append_array(_defeat(state, target))
	else:
		if is_night(state):
			target.keu = true
		if not was_asleep and can_counter(target, target.pos, u.pos):
			ev.append(_strike(state, target, u, true, n))
			if u.hp <= 0:
				target.xp += 30
				ev.append_array(_defeat(state, u))
	for x in [u, target]:
		if x.hp > 0 and state.units.has(x):
			var lv := _check_level(x)
			if not lv.is_empty() and x.faction == state.factions[0]:
				state.flags["cap_cao_nhat"] = maxi(int(state.flags.get("cap_cao_nhat", 0)), x.level)
			ev.append_array(lv)
	u.done = true
	ev.append_array(run_events(state))
	ev.append_array(check_result(state))
	return ev


static func _check_level(u: Unit) -> Array[Dictionary]:
	var ev: Array[Dictionary] = []
	while u.level < XP_LEVELS.size() and u.xp >= XP_LEVELS[u.level]:
		u.level += 1
		u.hp = mini(100, u.hp + 10)
		ev.append({"loai": "len_cap", "uid": u.uid, "cap": u.level})
	return ev


static func _defeat(state: BattleState, u: Unit) -> Array[Dictionary]:
	var ev: Array[Dictionary] = []
	ev.append({"loai": "ha", "uid": u.uid, "o": u.pos, "loai_quan": u.type_id, "phe": u.faction})
	state.remove_unit(u)
	if u.faction == state.factions[0]:
		var lost: Dictionary = state.flags["mat_quan"]
		lost[u.type_id] = int(lost.get(u.type_id, 0)) + 1
		for o in state.mission.get("muc_tieu_phu", []):
			if o.get("loai", "") == "khong_mat_truoc_co" and o["quan"] == u.type_id and not has_flag(state, o["co"]):
				var early: Dictionary = state.flags.get("mat_truoc_co", {})
				early[o["co"]] = true
				state.flags["mat_truoc_co"] = early
	else:
		var spots: Array = state.flags.get("ha_vi_tri", [])
		spots.append([u.pos.x, u.pos.y])   # mục tiêu phụ "ha_tren_khu" (màn 8: Đầm Mực)
		state.flags["ha_vi_tri"] = spots
		var kinds: Array = state.flags.get("ha_loai", [])
		kinds.append(u.type_id)            # điều kiện thắng "ha_loai" (màn 9: ba tướng chặn hậu)
		state.flags["ha_loai"] = kinds
	var leaves_trace: bool = (u.faction == "thanh" or u.faction == "le") and not u.has_tag("tuong")
	var keeps_object: bool = state.objects.has(u.pos) and state.objects[u.pos].get("loai", "") != "quan_tan"
	if leaves_trace and not keeps_object and not NO_QUAN_TAN.has(state.terrain_id(u.pos)):
		state.objects[u.pos] = {"loai": "quan_tan", "vong": state.vong}
		ev.append({"loai": "quan_tan", "o": u.pos})
	if u.tuong_chinh and u.faction == state.factions[0]:
		state.result = "thua"
		state.result_reason = "%s bị hạ" % u.display_name()
		ev.append({"loai": "ket_qua", "ket_qua": "thua", "ly_do": state.result_reason})
	return ev


static func can_capture(state: BattleState, u: Unit) -> bool:
	if _granary_at(state, u):
		return true
	var t := state.terrain_at(u.pos)
	if not t["so_huu"] or state.are_allies(state.owner_of(u.pos), u.faction) and state.owner_of(u.pos) != "":
		return false
	if state.owner_of(u.pos) == u.faction:
		return false
	if t["id"] == "lang":
		return u.has_tag("chiem_lang") or u.has_tag("tuong")
	return u.has_tag("tuong")


static func cmd_capture(state: BattleState, u: Unit) -> Array[Dictionary]:
	var ev: Array[Dictionary] = []
	if not can_act(state, u) or not can_capture(state, u):
		return ev
	if _granary_at(state, u):
		var o: Dictionary = state.objects[u.pos]
		state.objects.erase(u.pos)
		var flags: Dictionary = state.flags.get("co", {})
		flags[o.get("co", "lay_kho_luong")] = true
		state.flags["co"] = flags
		u.moved = true
		u.done = true
		ev.append({"loai": "lay_kho", "uid": u.uid, "o": u.pos})
		ev.append_array(run_events(state))
		ev.append_array(check_result(state))
		return ev
	state.owners[u.pos] = u.faction
	u.moved = true
	u.done = true
	ev.append({"loai": "chiem", "uid": u.uid, "o": u.pos, "phe": u.faction})
	ev.append_array(_village_reward(state, u))
	ev.append_array(run_events(state))
	ev.append_array(check_result(state))
	return ev


## Màn 2: mỗi làng chiếm lần đầu tặng một quân (tượng trưng cho tuyển quân) — "thuong_chiem_lang": {"quan": "linh_giao"}.
static func _village_reward(state: BattleState, u: Unit) -> Array[Dictionary]:
	var ev: Array[Dictionary] = []
	var reward: Dictionary = state.mission.get("thuong_chiem_lang", {})
	if reward.is_empty() or u.faction != state.factions[0] or state.terrain_id(u.pos) != "lang":
		return ev
	var key := "%d,%d" % [u.pos.x, u.pos.y]
	var done: Array = state.flags.get("lang_da_thuong", [])
	if done.has(key):
		return ev
	done.append(key)
	state.flags["lang_da_thuong"] = done
	if state.count_toward_limit(u.faction) >= int(state.limits.get(u.faction, 99)):
		return ev
	var at := _free_tile_near(state, u.pos)
	if at.x < 0:
		return ev
	var nu := state.spawn_unit(reward["quan"], u.faction, at)
	nu.moved = true
	nu.done = true
	ev.append({"loai": "tuyen_quan", "uid": nu.uid, "o": at})
	return ev


# ================================================================ sự kiện kịch bản (màn 2 trở đi)
# "su_kien": [{"id", "khi": {...}, "lam": [{...}]}] — mỗi sự kiện xảy ra một lần.
#   khi: {"loai": "vao_o", "o": [x, y]} quân phe người chơi đứng ở ô đó; {"loai": "so_lang", "n": N} phe người chơi giữ ≥ N làng;
#        {"loai": "chiem_o", "o": [x, y]} phe người chơi làm chủ ô đó;
#        {"loai": "mau_duoi", "quan": loại, "n": N} có quân loại đó còn dưới N máu (màn 7: Sầm Nghi Đống, `toi_thieu_1`, còn 1 máu).
#   lam: {"loai": "co", "co": tên} bật cờ; {"loai": "hoi_thoai", "phan": tên phần trong file hội thoại};
#        {"loai": "quan", "phe": f, "quan": [{id, x, y, ai}]} đặt quân; {"loai": "bang", "chu": "..."} dải chữ;
#        {"loai": "roi_ban_do", "quan": loại} mọi quân loại đó rời bản đồ (không để quân tan).

static func has_flag(state: BattleState, name: String) -> bool:
	return (state.flags.get("co", {}) as Dictionary).has(name)


static func villages_owned(state: BattleState, f: String) -> int:
	var n := 0
	for p in state.owners:
		if state.owners[p] == f and state.terrain_id(p) == "lang":
			n += 1
	return n


static func run_events(state: BattleState) -> Array[Dictionary]:
	var ev: Array[Dictionary] = []
	var player := state.factions[0]
	var fired: Array = state.flags.get("su_kien_da", [])
	for e in state.mission.get("su_kien", []):
		if fired.has(e["id"]):
			continue
		var cond: Dictionary = e.get("khi", {})
		var ok := false
		match cond.get("loai", ""):
			"vao_o":
				var u := state.unit_at(Vector2i(int(cond["o"][0]), int(cond["o"][1])))
				ok = u != null and u.faction == player
			"so_lang":
				ok = villages_owned(state, player) >= int(cond["n"])
			"chiem_o":
				ok = state.owner_of(Vector2i(int(cond["o"][0]), int(cond["o"][1]))) == player
			"vao_khu":   # quân phe người chơi (loại "quan" nếu có) đứng trong khu
				var cells: Array = state.zones.get(cond["khu"], [])
				for u in state.units_of(player):
					if cells.has(u.pos) and (not cond.has("quan") or u.type_id == cond["quan"]):
						ok = true
			"mau_duoi":
				for u in state.units:
					if u.type_id == cond["quan"] and u.hp < int(cond["n"]):
						ok = true
		if ok and cond.has("truoc_vong") and state.vong >= int(cond["truoc_vong"]):
			ok = false   # chỉ tính khi xảy ra trước vòng đó (màn 9: vào thành trước vòng 8)
		if not ok:
			continue
		fired.append(e["id"])
		state.flags["su_kien_da"] = fired
		for a in e.get("lam", []):
			match a.get("loai", ""):
				"co":
					var flags: Dictionary = state.flags.get("co", {})
					flags[a["co"]] = true
					state.flags["co"] = flags
				"hoi_thoai":
					ev.append({"loai": "hoi_thoai", "phan": a["phan"]})
				"bang":
					ev.append({"loai": "bang", "chu": a["chu"]})
				"quan":
					ev.append_array(_spawn_list(state, a["phe"], a["quan"], "vien_binh"))
				"roi_ban_do":
					for u in state.units.duplicate():
						if u.type_id == a["quan"]:
							state.remove_unit(u)
							ev.append({"loai": "roi_ban_do", "uid": u.uid, "o": u.pos})
	return ev


static func _spawn_list(state: BattleState, f: String, list: Array, kind: String) -> Array[Dictionary]:
	var ev: Array[Dictionary] = []
	for q in list:
		var at := _free_tile_near(state, Vector2i(int(q["x"]), int(q["y"])))
		if at.x < 0:
			continue
		var u := state.spawn_unit(q["id"], f, at)
		u.ai_mode = q.get("ai", "tan_cong")
		if q.has("tam"):
			u.ai_params["tam"] = Vector2i(int(q["tam"][0]), int(q["tam"][1]))
		if q.has("ban_kinh"):
			u.ai_params["ban_kinh"] = int(q["ban_kinh"])
		u.ngoai_gioi_han = true
		ev.append({"loai": kind, "uid": u.uid, "o": at})
	return ev


static func cmd_wait(state: BattleState, u: Unit) -> Array[Dictionary]:
	var ev: Array[Dictionary] = []
	if not can_act(state, u):
		return ev
	u.moved = true
	u.done = true
	ev.append({"loai": "cho", "uid": u.uid})
	ev.append_array(run_events(state))
	ev.append_array(check_result(state))
	return ev


## Loại lính mua được ở ô p cho phe f (rỗng nếu ô không mua được).
static func recruit_options(state: BattleState, f: String, p: Vector2i) -> Array[String]:
	var out: Array[String] = []
	if state.result != "" or state.current_faction() != f or not state.in_bounds(p):
		return out
	if not state.terrain_at(p)["mua_linh"] or state.owner_of(p) != f:
		return out
	if state.unit_at(p) != null or state.object_at(p).get("loai", "") == "quan_tan":
		return out
	for id in state.buyable.get(f, PackedStringArray()):
		out.append(id)
	return out


static func can_afford(state: BattleState, f: String, type_id: String) -> bool:
	var cost: int = GameData.get_data().unit(type_id)["gia"]
	return state.gold.get(f, 0) >= cost and state.count_toward_limit(f) < int(state.limits.get(f, 0))


static func cmd_recruit(state: BattleState, f: String, p: Vector2i, type_id: String) -> Array[Dictionary]:
	var ev: Array[Dictionary] = []
	if not recruit_options(state, f, p).has(type_id) or not can_afford(state, f, type_id):
		return ev
	var cost: int = GameData.get_data().unit(type_id)["gia"]
	state.gold[f] -= cost
	var u := state.spawn_unit(type_id, f, p)
	u.moved = true
	u.done = true
	ev.append({"loai": "mua", "uid": u.uid, "o": p, "loai_quan": type_id, "gia": cost})
	return ev


static func chieu_hang_targets(state: BattleState, u: Unit) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	if not u.has_tag("chieu_hang") or state.count_toward_limit(u.faction) >= int(state.limits.get(u.faction, 0)):
		return out
	for d in DIRS:
		var p := u.pos + d
		if state.object_at(p).get("loai", "") == "quan_tan" and state.unit_at(p) == null:
			out.append(p)
	return out


static func cmd_chieu_hang(state: BattleState, u: Unit, p: Vector2i) -> Array[Dictionary]:
	var ev: Array[Dictionary] = []
	if not can_act(state, u) or not chieu_hang_targets(state, u).has(p):
		return ev
	state.objects.erase(p)
	var hb := state.spawn_unit("hang_binh", u.faction, p)
	hb.hp = 50
	hb.moved = true
	hb.done = true
	u.moved = true
	u.done = true
	state.flags["hang_binh"] = int(state.flags.get("hang_binh", 0)) + 1
	ev.append({"loai": "chieu_hang", "uid": u.uid, "o": p, "uid_moi": hb.uid})
	return ev


# ================================================================ Đốt, lửa (02 §12; màn 7)
# Hỏa hổ (thẻ `dot`) chọn một ô kề (tầm 1) đốt được (`chay_duoc`: doanh trại), không có vật thể (trừ quân tan), không có quân phe mình
# → vật thể {"loai": "lua", "het": vòng tắt}. Lửa cháy FIRE_ROUNDS vòng, là nguồn sáng; quân đứng trên / bước vào bị Cháy
# (trừ `khong_chay`); tắt đầu vòng "het" thì ô thành "doanh trại cháy". Quân đứng trên ô bị đốt: Cháy, thức dậy và kêu.
# flags["dot"]: vòng của từng lần đốt (mục tiêu phụ "dot_doanh").

static func burn_targets(state: BattleState, u: Unit) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	if not can_act(state, u) or not u.has_tag("dot"):
		return out
	for d in DIRS:
		var p := u.pos + d
		var obj: String = state.object_at(p).get("loai", "") if state.in_bounds(p) else ""
		if not state.in_bounds(p) or not state.terrain_at(p)["chay_duoc"] or (obj != "" and obj != "quan_tan"):
			continue   # quân tan trên ô doanh thì lửa đuổi đi (hạ quân trong doanh xong vẫn đốt được ô đó)
		var occ := state.unit_at(p)
		if occ != null and state.are_allies(occ.faction, u.faction):
			continue
		out.append(p)
	return out


static func cmd_dot(state: BattleState, u: Unit, p: Vector2i) -> Array[Dictionary]:
	var ev: Array[Dictionary] = []
	if not burn_targets(state, u).has(p):
		return ev
	state.objects[p] = {"loai": "lua", "het": state.vong + FIRE_ROUNDS}
	var burned: Array = state.flags.get("dot", [])
	burned.append(state.vong)
	state.flags["dot"] = burned
	u.moved = true
	u.done = true
	ev.append({"loai": "dot", "uid": u.uid, "o": p})
	var occ := state.unit_at(p)
	if occ != null:
		ev.append_array(_catch_fire(state, occ))
		occ.ngu = false
		if is_night(state):
			occ.keu = true
	ev.append_array(run_events(state))
	ev.append_array(check_result(state))
	return ev


## Số ô đã đốt trong các vòng trước vòng `before` (0 = mọi vòng).
static func burned_count(state: BattleState, before := 0) -> int:
	var n := 0
	for v in state.flags.get("dot", []):
		if before <= 0 or int(v) < before:
			n += 1
	return n


static func _catch_fire(state: BattleState, u: Unit) -> Array[Dictionary]:
	var ev: Array[Dictionary] = []
	if u.has_tag("khong_chay"):
		return ev
	# Như trúng đòn hỏa hổ: tới hết lượt kế tiếp của phe quân đó (02 §9).
	u.chay_turns = maxi(u.chay_turns, 2 if u.faction == state.current_faction() else 1)
	ev.append({"loai": "chay", "uid": u.uid})
	return ev


## Đầu lượt: quân phe f đứng trên lửa bị Cháy; đầu vòng (lượt Tây Sơn) lửa hết hạn thì tắt.
static func _fires(state: BattleState, f: String) -> Array[Dictionary]:
	var ev: Array[Dictionary] = []
	for u in state.units_of(f):
		if state.object_at(u.pos).get("loai", "") == "lua" and not u.has_tag("khong_chay"):
			u.chay_turns = maxi(u.chay_turns, 1)
			ev.append({"loai": "chay", "uid": u.uid})
	if state.current == 0:
		for p in state.objects.keys():
			var o: Dictionary = state.objects[p]
			if o.get("loai", "") == "lua" and state.vong >= int(o["het"]):
				state.objects.erase(p)
				if state.terrain_id(p) == "doanh":
					state.set_terrain(p, "doanh_chay")
				ev.append({"loai": "lua_tat", "o": p})
	return ev


# ================================================================ khu đồn, vây đồn, gọi hàng (02 §11; màn 6)
# mission["khu_don"] = [tên khu]. Kho lương: vật thể {"loai": "kho_luong", "co": tên cờ} (02 §12).

static func fort_zones(state: BattleState) -> Array:
	return state.mission.get("khu_don", [])


static func _granary_at(state: BattleState, u: Unit) -> bool:
	return state.object_at(u.pos).get("loai", "") == "kho_luong" and u.faction == state.factions[0] \
		and (u.has_tag("tuong") or u.has_tag("chiem_lang"))


static func zone_enemies(state: BattleState, name: String, f: String) -> Array[Unit]:
	var cells: Array = state.zones.get(name, [])
	var out: Array[Unit] = []
	for e in state.enemies_of(f):
		if cells.has(e.pos):
			out.append(e)
	return out


## Ô kề ngoài khu (4 hướng).
static func zone_ring(state: BattleState, name: String) -> Array[Vector2i]:
	var cells: Array = state.zones.get(name, [])
	var ring: Array[Vector2i] = []
	for c in cells:
		for d in DIRS:
			var p: Vector2i = c + d
			if state.in_bounds(p) and not cells.has(p) and not ring.has(p):
				ring.append(p)
	return ring


## Ô kề ngoài khu còn hở (02 §11): đi bộ được, không có quân phe f, không nằm trong vùng khống chế của quân phe f.
## Rỗng = khu bị vây.
static func siege_gaps(state: BattleState, name: String, f: String) -> Array[Vector2i]:
	var ctrl := {}
	for u in state.units_of(f):
		if u.has_tag("chan"):
			for d in DIRS:
				ctrl[u.pos + d] = true
	var gaps: Array[Vector2i] = []
	for p in zone_ring(state, name):
		if int(state.terrain_at(p)["chi_phi"]["bo"]) < 0 or state.object_at(p).get("loai", "") == "quan_tan":
			continue   # không vào được
		var occ := state.unit_at(p)
		if (occ != null and occ.faction == f) or ctrl.has(p):
			continue
		gaps.append(p)
	return gaps


## Khu mà quân u gọi hàng được lúc này: u có thẻ goi_hang, đứng kề ngoài khu, khu còn quân địch, đã bị vây,
## chưa gọi khu đó trong vòng này.
static func goi_hang_zones(state: BattleState, u: Unit) -> Array[String]:
	var out: Array[String] = []
	if not can_act(state, u) or not u.has_tag("goi_hang"):
		return out
	var tried: Dictionary = state.flags.get("goi_hang_da", {})
	for name in fort_zones(state):
		var cells: Array = state.zones.get(name, [])
		if int(tried.get(name, 0)) == state.vong or cells.has(u.pos):
			continue
		var next_to := false
		for d in DIRS:
			if cells.has(u.pos + d):
				next_to = true
		if next_to and not zone_enemies(state, name, u.faction).is_empty() and siege_gaps(state, name, u.faction).is_empty():
			out.append(name)
	return out


## Dự báo gọi hàng (tất định): máu quân ta trong 2 ô quanh khu so với máu quân trong khu × k (k = ½ nếu quá nửa đang ngủ).
static func goi_hang_forecast(state: BattleState, name: String, f: String) -> Dictionary:
	var cells: Array = state.zones.get(name, [])
	var ours := 0
	for u in state.units_of(f):
		for c in cells:
			if manhattan(u.pos, c) <= 2:
				ours += u.hp
				break
	var foes := zone_enemies(state, name, f)
	var theirs := 0
	var asleep := 0
	for e in foes:
		theirs += e.hp
		if e.ngu:
			asleep += 1
	var half := asleep * 2 > foes.size()
	var need := ceili(theirs / 2.0) if half else theirs
	return {"ta": ours, "dich": theirs, "can": need, "ngu_qua_nua": half, "so_quan": foes.size(), "thanh_cong": ours >= need}


static func cmd_goi_hang(state: BattleState, u: Unit, name: String) -> Array[Dictionary]:
	var ev: Array[Dictionary] = []
	if not goi_hang_zones(state, u).has(name):
		return ev
	var tried: Dictionary = state.flags.get("goi_hang_da", {})
	tried[name] = state.vong
	state.flags["goi_hang_da"] = tried
	var fc := goi_hang_forecast(state, name, u.faction)
	u.moved = true
	u.done = true
	ev.append({"loai": "goi_hang", "uid": u.uid, "khu": name, "thanh_cong": fc["thanh_cong"], "ta": fc["ta"], "can": fc["can"]})
	if not fc["thanh_cong"]:
		return ev   # thất bại: không có gì xảy ra, quân ngủ vẫn ngủ
	var cells: Array = state.zones.get(name, [])
	for e in zone_enemies(state, name, u.faction):
		var at := e.pos
		state.remove_unit(e)
		var new_uid := -1
		if state.count_toward_limit(u.faction) < int(state.limits.get(u.faction, 0)):
			# Không đặt hàng binh lên ô đồn: để ô đồn trống cho tướng chiếm.
			var spot := at
			if state.terrain_at(at)["mua_linh"]:
				spot = Vector2i(-1, -1)
				for c in cells + zone_ring(state, name):   # ô trống trong khu, không có thì ô kề ngoài khu
					if state.unit_at(c) == null and not state.terrain_at(c)["mua_linh"] and state.object_at(c).is_empty() \
						and int(state.terrain_at(c)["chi_phi"]["bo"]) > 0:
						spot = c
						break
			if spot != Vector2i(-1, -1):
				var hb := state.spawn_unit("hang_binh", u.faction, spot)
				hb.hp = 50
				hb.moved = true
				hb.done = true
				new_uid = hb.uid
				state.flags["hang_binh"] = int(state.flags.get("hang_binh", 0)) + 1
		if new_uid == -1:
			state.flags["tu_binh"] = int(state.flags.get("tu_binh", 0)) + 1
		ev.append({"loai": "ra_hang", "uid": e.uid, "o": at, "uid_moi": new_uid})
	for c in cells:
		if state.terrain_at(c)["so_huu"]:
			state.owners.erase(c)   # đồn thành trung lập: tướng vào chiếm
	var flags: Dictionary = state.flags.get("co", {})
	flags["goi_hang_" + name] = true
	state.flags["co"] = flags
	ev.append_array(run_events(state))
	ev.append_array(check_result(state))
	return ev


## Quân mang từ màn trước (màn 8 → 9, 04): mission["quan_mang_theo"] = {"toi_da": N, "o": [ô]}. Quân phe người chơi (trừ tướng
## chính) đứng trên các ô đó là đội hình mặc định (chơi lẻ / kiểm thử); trong chiến dịch thay bằng tối đa N quân trong `army`
## (Progress "quan_mang_theo": [{id, cap, xp}], cấp cao trước), đầy máu, giữ cấp và kinh nghiệm.
static func apply_army(state: BattleState, army: Array) -> void:
	var spec: Dictionary = state.mission.get("quan_mang_theo", {})
	if spec.is_empty() or army.is_empty():
		return
	var slots: Array[Vector2i] = []
	for c in spec.get("o", []):
		slots.append(Vector2i(int(c[0]), int(c[1])))
	for u in state.units_of(state.factions[0]):
		if slots.has(u.pos) and not u.tuong_chinh:
			state.remove_unit(u)
	var n := mini(army.size(), mini(int(spec.get("toi_da", 10)), slots.size()))
	var picked: Array = army.slice(0, n)
	# Giữ ít nhất một quân sư nếu có (chiêu hàng: mục tiêu phụ hàng binh), thay quân cuối danh sách.
	if n > 0 and not picked.any(func(a: Dictionary) -> bool: return a["id"] == "quan_su"):
		for a in army.slice(n):
			if a["id"] == "quan_su":
				picked[n - 1] = a
				break
	for i in n:
		var a: Dictionary = picked[i]
		var u := state.spawn_unit(a["id"], state.factions[0], slots[i])
		u.level = int(a.get("cap", 0))
		u.xp = int(a.get("xp", 0))


## Hệ quả từ màn trước (Progress.campaign_flag), áp lúc mở màn mới trong chiến dịch:
## mission["he_qua"] = [{"co": tên, "thuc_khu": khu, "bang": "..."}] — cờ bật thì mọi quân trong khu thức sẵn.
static func apply_carry(state: BattleState, carried: Dictionary) -> void:
	for h in state.mission.get("he_qua", []):
		if not bool(carried.get(h.get("co", ""), false)):
			continue
		var flags: Dictionary = state.flags.get("co", {})
		flags["he_qua_" + String(h["co"])] = true
		state.flags["co"] = flags
		var cells: Array = state.zones.get(h.get("thuc_khu", ""), [])
		for u in state.units:
			if cells.has(u.pos) and (u.ngu or u.ai_mode == "ngu"):
				u.ngu = false
				u.ai_mode = "giu_don"
				u.ai_params["tam"] = u.pos
				u.ai_params["ban_kinh"] = 0   # thức nhưng giữ chỗ: bắn quân ta vào tầm, không ra khỏi lũy


# ================================================================ lượt

static func cmd_end_turn(state: BattleState) -> Array[Dictionary]:
	var ev: Array[Dictionary] = []
	if state.result != "":
		return ev
	var f := state.current_faction()
	for u in state.units_of(f):
		if u.chay_turns > 0:
			u.chay_turns -= 1
		u.than_trong = u.has_tag("than_trong") and not (u.moved and u.pos != u.move_origin)
	ev.append({"loai": "het_luot", "phe": f})
	state.current += 1
	if state.current >= state.factions.size():
		state.current = 0
		var limit := int(state.mission.get("thua_het_luot", 0))
		if limit > 0 and state.vong >= limit:
			state.result = "thua"
			state.result_reason = state.mission.get("ly_do_het_luot", "Hết lượt")
			ev.append({"loai": "ket_qua", "ket_qua": "thua", "ly_do": state.result_reason})
			return ev
		state.vong += 1
		state.strike_counter = 0
	ev.append_array(start_turn(state))
	return ev


## Vàng mỗi vòng của một ô sở hữu. Màn có thể đặt "vang_lang" riêng (màn 2: làng đã tặng lính nên thu ít hơn).
static func tile_income(state: BattleState, p: Vector2i) -> int:
	if state.terrain_id(p) == "lang" and state.mission.has("vang_lang"):
		return int(state.mission["vang_lang"])
	return int(state.terrain_at(p)["vang"])


static func start_turn(state: BattleState) -> Array[Dictionary]:
	var ev: Array[Dictionary] = []
	var f := state.current_faction()
	ev.append({"loai": "bat_dau_luot", "phe": f, "vong": state.vong})
	# Vàng: chỉ phe có lính mua được mới có thu nhập (02 §2).
	if not state.buyable.get(f, PackedStringArray()).is_empty() and not (state.mission.get("khong_thu_nhap", []) as Array).has(f):
		var income := 0
		for p in state.owners:
			if state.owners[p] == f:
				income += tile_income(state, p)
		if income > 0:
			state.gold[f] = int(state.gold.get(f, 0)) + income
			ev.append({"loai": "vang", "phe": f, "them": income})
	# Hồi máu trên làng / đồn / thành của mình hoặc đồng minh.
	for u in state.units_of(f):
		var heal := int(state.terrain_at(u.pos)["hoi_mau"])
		var own := state.owner_of(u.pos)
		if heal > 0 and own != "" and state.are_allies(own, f) and u.hp < 100:
			var before := u.hp
			u.hp = mini(100, u.hp + heal)
			ev.append({"loai": "hoi_mau", "uid": u.uid, "them": u.hp - before})
		u.moved = false
		u.done = false
		u.straight_steps = 0
		u.move_origin = u.pos
		u.khoa_hoan_tac = false
		u.than_trong = false
	ev.append_array(_dawn(state))
	ev.append_array(_bridge(state))
	ev.append_array(_fires(state, f))
	_reveal_mines(state)
	ev.append_array(_reinforcements(state, f))
	if f != state.factions[0]:
		ev.append_array(_alarm(state, f))
		ev.append_array(_scouts_spot(state, f))
	# Quân tan hết hạn đầu lượt Tây Sơn của vòng N + 2 (02 §8).
	if state.current == 0:
		for p in state.objects.keys():
			var o: Dictionary = state.objects[p]
			if o.get("loai", "") == "quan_tan" and not o.get("vinh_vien", false) and int(o["vong"]) <= state.vong - 2:
				state.objects.erase(p)
				ev.append({"loai": "quan_tan_het", "o": p})
	return ev


## Báo động đầu lượt phe f (02 §10): quân "kêu" hoặc quân thức đang thấy quân đối phương.
static func _alarm(state: BattleState, f: String) -> Array[Dictionary]:
	var ev: Array[Dictionary] = []
	if not is_dark(state):
		for u in state.units_of(f):
			u.keu = false
		return ev
	var lit := lit_tiles(state)
	var triggers: Array[Unit] = []
	for u in state.units_of(f):
		var spotted := false
		if not u.ngu:
			for e in state.enemies_of(f):
				if watcher_sees(state, u, e, lit):
					spotted = true
					break
		if u.keu or spotted:
			triggers.append(u)
		u.keu = false
	# Một lần báo động = một quân phát hiện làm thức / đổi lệnh ít nhất một quân (kể cả chính nó).
	# Quân đã thức cả rồi mà vẫn thấy quân ta thì không tính thêm.
	var raised := false
	for t in triggers:
		var woken: Array[Unit] = [t]
		for o in state.units_of(f):
			if manhattan(o.pos, t.pos) <= 5:
				woken.append(o)
		var drum_hit := false
		for p in state.objects:
			if state.objects[p].get("loai", "") == "trong" and manhattan(p, t.pos) <= 1:
				var khu: String = state.objects[p].get("khu", "")
				for o in state.units_of(f):
					if (khu != "" and state.zone_of(o.pos) == khu) or manhattan(o.pos, p) <= 6:
						if o.ngu or o.ai_mode == "ngu" or o.ai_mode == "tuan_tra":
							drum_hit = true
						woken.append(o)
				if drum_hit:
					ev.append({"loai": "trong_bao_dong", "o": p})
		var changed := false
		for o in woken:
			if o.ngu or o.ai_mode == "ngu" or o.ai_mode == "tuan_tra":
				changed = true
			o.ngu = false
			if o.ai_mode == "ngu" or o.ai_mode == "tuan_tra":
				o.ai_mode = "giu_don"
				o.ai_params["tam"] = _nearest_fort(state, o.pos, f)
				o.ai_params["ban_kinh"] = 4
		if changed:
			raised = true
			ev.append({"loai": "bao_dong", "uid": t.uid, "o": t.pos})
	if raised:
		state.flags["bao_dong"] = int(state.flags.get("bao_dong", 0)) + 1
	return ev


static func _nearest_fort(state: BattleState, from: Vector2i, f: String) -> Vector2i:
	var best := from
	var best_d := INF
	for p in state.owners:
		if state.terrain_at(p)["mua_linh"] and state.are_allies(state.owner_of(p), f) and manhattan(p, from) < best_d:
			best_d = manhattan(p, from)
			best = p
	return best


## Cầu phao (02 §12, màn 9): mission["cau_phao"] = {"o": [ô], "rung": R, "khi_qua": loại quân}. Đầu vòng R (hoặc đầu vòng ngay
## sau khi quân "khi_qua" đã qua hết cầu, nếu sớm hơn) cầu rung; đầu vòng kế tiếp cầu đứt: ô cầu thành sông, quân trên cầu rơi xuống
## sông và bị hạ, trừ quân đi thủy (thủy binh) ở lại trên ô sông.
static func _bridge(state: BattleState) -> Array[Dictionary]:
	var ev: Array[Dictionary] = []
	var b: Dictionary = state.mission.get("cau_phao", {})
	if b.is_empty() or state.current != 0 or state.flags.get("cau_dut", false):
		return ev
	var shook := int(state.flags.get("cau_rung", 0))
	if shook > 0 and state.vong > shook:
		state.flags["cau_dut"] = true
		ev.append({"loai": "cau_dut"})
		for c in b.get("o", []):
			var p := Vector2i(int(c[0]), int(c[1]))
			state.set_terrain(p, "song")
			var u := state.unit_at(p)
			if u != null and u.data()["kieu_di"] != "thuy":
				ev.append_array(_defeat(state, u))
		ev.append_array(check_result(state))
		return ev
	var crossed: bool = (state.flags.get("thoat_loai", []) as Array).has(b.get("khi_qua", "?"))
	if shook == 0 and (state.vong >= int(b.get("rung", 99)) or crossed):
		state.flags["cau_rung"] = state.vong
		ev.append({"loai": "cau_rung"})
	return ev


## Rạng sáng (02 §10): mission["rang_sang"] = R → vòng R tầm nhìn 3, R+1 tầm nhìn 5, từ R+2 hết sương mù.
static func _dawn(state: BattleState) -> Array[Dictionary]:
	var ev: Array[Dictionary] = []
	var r := int(state.mission.get("rang_sang", 0))
	if r <= 0 or state.current != 0:
		return ev
	var before := state.tam_nhin
	if state.vong == r:
		state.tam_nhin = 3
		for u in state.units:
			u.ngu = false
	elif state.vong == r + 1:
		state.tam_nhin = 5
	elif state.vong >= r + 2:
		state.tam_nhin = 0
	if state.tam_nhin != before:
		ev.append({"loai": "rang_sang", "tam_nhin": state.tam_nhin})
	return ev


## Mục tiêu phụ (02 §13): [{"ten": ..., "dat": bool}]. Chỉ có nghĩa khi đã thắng.
static func side_objectives(state: BattleState) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for o in state.mission.get("muc_tieu_phu", []):
		var ok := false
		match o.get("loai", ""):
			"truoc_vong", "truoc_luot":  # thắng trong vòng ≤ n − 1 ("trước vòng n"); tên cũ truoc_luot
				ok = state.result == "thang" and state.won_round <= int(o["n"]) - 1
			"khong_bao_dong":
				ok = state.result == "thang" and int(state.flags.get("bao_dong", 0)) == 0
			"khong_mat":
				ok = state.result == "thang" and int(state.flags["mat_quan"].get(o.get("quan", ""), 0)) == 0
			"khong_mat_quan_nao":
				ok = state.result == "thang" and state.flags["mat_quan"].is_empty()
			"hang_binh_toi_thieu":
				ok = state.result == "thang" and int(state.flags.get("hang_binh", 0)) >= int(o["n"])
			"len_cap":
				ok = state.result == "thang" and int(state.flags.get("cap_cao_nhat", 0)) >= int(o.get("n", 1))
			"co":
				ok = state.result == "thang" and has_flag(state, o["co"])
			"ve_vung":
				ok = state.result == "thang" and _type_in_zone(state, o["quan"], o["khu"])
			"khong_thoat":
				ok = state.result == "thang" and int(state.flags.get("thoat", 0)) == 0
			"goi_hang_sach":   # gọi hàng thành công khu o["khu"] mà không đánh quân nào đứng trong khu đồn
				ok = state.result == "thang" and has_flag(state, "goi_hang_" + String(o["khu"])) \
					and not state.flags.get("danh_trong_khu", false)
			"hang_tu_binh":
				ok = state.result == "thang" and int(state.flags.get("hang_binh", 0)) + int(state.flags.get("tu_binh", 0)) >= int(o["n"])
			"dot_doanh":   # đốt ≥ n ô (doanh trại) trong các vòng trước vòng "truoc_vong" (màn 7)
				ok = state.result == "thang" and burned_count(state, int(o.get("truoc_vong", 0))) >= int(o["n"])
			"ha_tren_khu":   # hạ ≥ n quân đối phương khi chúng đứng trong khu (màn 8: Đầm Mực)
				ok = state.result == "thang" and kills_in_zone(state, o["khu"]) >= int(o["n"])
			"khong_mat_truoc_co":   # không mất quân loại "quan" trước khi cờ "co" bật (màn 8: mộc thuẫn trước khi qua hàng chông)
				ok = state.result == "thang" and not (state.flags.get("mat_truoc_co", {}) as Dictionary).has(o["co"])
		out.append({"ten": o.get("ten", ""), "dat": ok})
	return out


## Tình trạng mục tiêu phụ giữa trận (cho bảng tạm dừng): "dat" | "hong" (đã không thể đạt) | "dang" (còn mở)
## | "xong" (đã làm được trong trận, thành ★ khi thắng — báo cáo M3 lần 3).
static func side_objectives_live(state: BattleState) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var won := state.result == "thang"
	var lost_game := state.result == "thua"
	var final := side_objectives(state)
	for o in state.mission.get("muc_tieu_phu", []):
		var st := "dang"
		match o.get("loai", ""):
			"truoc_vong", "truoc_luot":  # thắng trong vòng ≤ n − 1 ("trước vòng n"); tên cũ truoc_luot
				var last := int(o["n"]) - 1
				if won:
					st = "dat" if state.won_round <= last else "hong"
				elif state.vong > last:
					st = "hong"
			"khong_bao_dong":
				if int(state.flags.get("bao_dong", 0)) > 0:
					st = "hong"
			"khong_mat":
				if int(state.flags["mat_quan"].get(o.get("quan", ""), 0)) > 0:
					st = "hong"
			"khong_mat_quan_nao":
				if not state.flags["mat_quan"].is_empty():
					st = "hong"
			"khong_thoat":
				if int(state.flags.get("thoat", 0)) > 0:
					st = "hong"
			"goi_hang_sach":
				if state.flags.get("danh_trong_khu", false):
					st = "hong"
				elif has_flag(state, "goi_hang_" + String(o["khu"])):
					st = "dat" if won else "xong"
			"hang_tu_binh":
				if int(state.flags.get("hang_binh", 0)) + int(state.flags.get("tu_binh", 0)) >= int(o["n"]):
					st = "dat" if won else "xong"
			"ha_tren_khu":
				if kills_in_zone(state, o["khu"]) >= int(o["n"]):
					st = "dat" if won else "xong"
			"khong_mat_truoc_co":
				if (state.flags.get("mat_truoc_co", {}) as Dictionary).has(o["co"]):
					st = "hong"
				elif has_flag(state, o["co"]):
					st = "dat" if won else "xong"
			"dot_doanh":
				var before := int(o.get("truoc_vong", 0))
				if burned_count(state, before) >= int(o["n"]):
					st = "dat" if won else "xong"
				elif before > 0 and state.vong >= before:
					st = "hong"
			"hang_binh_toi_thieu":
				if int(state.flags.get("hang_binh", 0)) >= int(o["n"]):
					st = "dat" if won else "xong"
			"len_cap":
				if int(state.flags.get("cap_cao_nhat", 0)) >= int(o.get("n", 1)):
					st = "dat" if won else "xong"
			"co":
				if has_flag(state, o["co"]):
					st = "dat" if won else "xong"
			"ve_vung":
				if int(state.flags["mat_quan"].get(o["quan"], 0)) > 0:
					st = "hong"
				elif won:
					st = "dat" if _type_in_zone(state, o["quan"], o["khu"]) else "hong"
		if won:
			# Đã thắng: lấy đúng kết quả cuối (kiểm thử lần 6c: "đốt ≥ 4 ô" còn "dang" mà thắng sớm thì từng thành ★).
			st = "dat" if final[out.size()]["dat"] else "hong"
		if (st == "dang" or st == "xong") and lost_game:
			st = "hong"
		out.append({"ten": o.get("ten", ""), "trang_thai": st})
	return out


## Điều kiện thắng (04): chiem_o, ha_het, vao_vung, so_lang, co, và tat_ca (mọi điều kiện con trong "dk").
static func _condition(state: BattleState, win: Dictionary) -> bool:
	var player := state.factions[0]
	match win.get("loai", ""):
		"chiem_o":
			return state.owner_of(Vector2i(int(win["o"][0]), int(win["o"][1]))) == player
		"ha_het":
			return state.enemies_of(player).is_empty()
		"so_lang":
			return villages_owned(state, player) >= int(win["n"])
		"co":
			return has_flag(state, win["co"])
		"ha_loai":   # mọi loại trong "quan" đã bị hạ (màn 9: ba tướng chặn hậu)
			var gone: Array = state.flags.get("ha_loai", [])
			for t in win["quan"]:
				if not gone.has(t):
					return false
			return true
		"tat_ca":
			for c in win.get("dk", []):
				if not _condition(state, c):
					return false
			return true
		"vao_vung":
			# Tướng chính và ít nhất `so_quan` quân khác của ta cùng đứng trong khu (màn 0).
			var zone: Array = state.zones.get(win["khu"], [])
			var general_in := false
			var others := 0
			for u in state.units_of(player):
				if zone.has(u.pos):
					if u.tuong_chinh:
						general_in = true
					else:
						others += 1
			return general_in and others >= int(win.get("so_quan", 0))
	return false


static func kills_in_zone(state: BattleState, zone_name: String) -> int:
	var cells: Array = state.zones.get(zone_name, [])
	var n := 0
	for p in state.flags.get("ha_vi_tri", []):
		if cells.has(Vector2i(int(p[0]), int(p[1]))):
			n += 1
	return n


static func _type_in_zone(state: BattleState, type_id: String, zone_name: String) -> bool:
	var zone: Array = state.zones.get(zone_name, [])
	for u in state.units_of(state.factions[0]):
		if u.type_id == type_id and zone.has(u.pos):
			return true
	return false


## Viện binh theo kịch bản (04, màn 0): mỗi mục {"phe", "vong": [..] hoặc "tu_vong"/"moi"/"den_vong", "quan": [{id, x, y, ai}],
## "hoi_thoai": phần hội thoại (tùy chọn)}.
## Đầu lượt của phe đó; ô đã có quân thì lùi sang ô trống gần nhất đi được.
static func _reinforcements(state: BattleState, f: String) -> Array[Dictionary]:
	var ev: Array[Dictionary] = []
	for r in state.mission.get("vien_binh", []):
		if r.get("phe", "") != f:
			continue
		var rounds: Array = []
		for v in r.get("vong", []):
			rounds.append(int(v))   # JSON đọc số thành float: 1.0 != 1 với Array.has
		if rounds.is_empty() and r.has("tu_vong"):
			var v := int(r["tu_vong"])
			while v <= int(r.get("den_vong", 99)):
				rounds.append(v)
				v += int(r.get("moi", 1))
		if not rounds.has(state.vong):
			continue
		ev.append_array(_spawn_list(state, f, r.get("quan", []), "vien_binh"))
		if r.has("hoi_thoai"):
			ev.append({"loai": "hoi_thoai", "phan": r["hoi_thoai"]})   # màn 8: Đô đốc Bảo tới từ Đại Áng
	return ev


static func _free_tile_near(state: BattleState, want: Vector2i) -> Vector2i:
	for r in 4:
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				if absi(dx) + absi(dy) != r:
					continue
				var p := want + Vector2i(dx, dy)
				if state.in_bounds(p) and state.unit_at(p) == null and int(state.terrain_at(p)["chi_phi"]["bo"]) > 0 \
						and state.object_at(p).get("loai", "") != "quan_tan":
					return p
	return Vector2i(-1, -1)


static func check_result(state: BattleState) -> Array[Dictionary]:
	var ev: Array[Dictionary] = []
	if state.result != "":
		return ev
	var ok := _condition(state, state.mission.get("thang", {}))
	if ok:
		state.result = "thang"
		state.won_round = state.vong
		ev.append({"loai": "ket_qua", "ket_qua": "thang"})
	return ev
