class_name Rules
extends RefCounted
## Luật chơi (docs/02-luat-choi.md). Mọi hàm là static, nhận BattleState và trả về danh sách sự kiện
## (Dictionary có khóa "loai") để lớp hiển thị chạy hoạt cảnh. Không phụ thuộc Node.

const DIRS: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
const XP_LEVELS: Array[int] = [100, 250, 450, 700]
const LEVEL_ATK := 3
const LEVEL_DEF := 2
const NO_QUAN_TAN: Array[String] = ["cau", "cau_phao", "song", "dam"]
const CHAN_HAU_TERRAIN: Array[String] = ["cau", "cau_phao", "de", "song_can"]
const INF := 1 << 30


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


## Ô bị khống chế bởi quân đối phương có thẻ `chan` (02 §3).
static func zoc_tiles(state: BattleState, u: Unit) -> Dictionary:
	var zoc := {}
	for e in state.units:
		if state.are_allies(e.faction, u.faction) or not e.has_tag("chan"):
			continue
		for d in DIRS:
			zoc[e.pos + d] = true
	return zoc


static func _enterable(state: BattleState, u: Unit, p: Vector2i) -> bool:
	if not state.in_bounds(p) or move_cost(state, u, p) < 0:
		return false
	var occ := state.unit_at(p)
	if occ != null and not state.are_allies(occ.faction, u.faction):
		return false
	if state.object_at(p).get("loai", "") == "quan_tan":
		return false
	return true


## Các ô quân có thể dừng lại: {Vector2i: {"chi_phi": int, "duong": Array[Vector2i]}}. Gồm cả ô đang đứng.
static func reachable(state: BattleState, u: Unit) -> Dictionary:
	var mp := move_points(state, u)
	var zoc: Dictionary = {} if u.has_tag("xung_phong") else zoc_tiles(state, u)
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
		if p != u.pos and zoc.has(p):
			continue  # vào vùng khống chế thì dừng
		for d in DIRS:
			var n := p + d
			if not _enterable(state, u, n):
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
		if p == u.pos or occ == null:
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
		if st >= def.hp and not def.toi_thieu_1 and def.rut_khi_yeu == 0:
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
	if u.rut_khi_yeu > 0 and u.hp < u.rut_khi_yeu:
		u.hp = maxi(u.hp, 1)
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


static func cmd_move(state: BattleState, u: Unit, target: Vector2i) -> Array[Dictionary]:
	var ev: Array[Dictionary] = []
	if not can_act(state, u) or u.moved:
		return ev
	var reach := reachable(state, u)
	if not reach.has(target):
		return ev
	var path: Array[Vector2i] = []
	if u.has_tag("xung_phong"):
		path = straight_path(state, u, target)
	u.straight_steps = path.size() - 1 if path.size() > 1 else 0
	if path.is_empty():
		path = path_to(reach, u.pos, target)
	var seen_before := _seen_enemies(state, u.faction)
	u.move_origin = u.pos
	u.pos = target
	u.moved = true
	ev.append({"loai": "di", "uid": u.uid, "duong": path})
	if is_dark(state):
		for uid in _seen_enemies(state, u.faction):
			if not seen_before.has(uid):
				u.khoa_hoan_tac = true
				ev.append({"loai": "lo_dien", "uid": uid})
	return ev


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
			ev.append_array(_check_level(x))
	u.done = true
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
	state.owners[u.pos] = u.faction
	u.moved = true
	u.done = true
	ev.append({"loai": "chiem", "uid": u.uid, "o": u.pos, "phe": u.faction})
	ev.append_array(check_result(state))
	return ev


static func cmd_wait(state: BattleState, u: Unit) -> Array[Dictionary]:
	var ev: Array[Dictionary] = []
	if not can_act(state, u):
		return ev
	u.moved = true
	u.done = true
	ev.append({"loai": "cho", "uid": u.uid})
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


static func start_turn(state: BattleState) -> Array[Dictionary]:
	var ev: Array[Dictionary] = []
	var f := state.current_faction()
	ev.append({"loai": "bat_dau_luot", "phe": f, "vong": state.vong})
	# Vàng: chỉ phe có lính mua được mới có thu nhập (02 §2).
	if not state.buyable.get(f, PackedStringArray()).is_empty():
		var income := 0
		for p in state.owners:
			if state.owners[p] == f:
				income += int(state.terrain_at(p)["vang"])
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
	if f != state.factions[0]:
		ev.append_array(_alarm(state, f))
	# Quân tan hết hạn đầu lượt Tây Sơn của vòng N + 2 (02 §8).
	if state.current == 0:
		for p in state.objects.keys():
			var o: Dictionary = state.objects[p]
			if o.get("loai", "") == "quan_tan" and int(o["vong"]) <= state.vong - 2:
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
			"truoc_luot":
				ok = state.result == "thang" and state.won_round <= int(o["n"]) - 1
			"khong_bao_dong":
				ok = state.result == "thang" and int(state.flags.get("bao_dong", 0)) == 0
			"khong_mat":
				ok = state.result == "thang" and int(state.flags["mat_quan"].get(o.get("quan", ""), 0)) == 0
			"khong_mat_quan_nao":
				ok = state.result == "thang" and state.flags["mat_quan"].is_empty()
			"hang_binh_toi_thieu":
				ok = state.result == "thang" and int(state.flags.get("hang_binh", 0)) >= int(o["n"])
		out.append({"ten": o.get("ten", ""), "dat": ok})
	return out


static func check_result(state: BattleState) -> Array[Dictionary]:
	var ev: Array[Dictionary] = []
	if state.result != "":
		return ev
	var player := state.factions[0]
	var win: Dictionary = state.mission.get("thang", {})
	var ok := false
	match win.get("loai", ""):
		"chiem_o":
			var p := Vector2i(int(win["o"][0]), int(win["o"][1]))
			ok = state.owner_of(p) == player
		"ha_het":
			ok = state.enemies_of(player).is_empty()
	if ok:
		state.result = "thang"
		state.won_round = state.vong
		ev.append({"loai": "ket_qua", "ket_qua": "thang"})
	return ev
