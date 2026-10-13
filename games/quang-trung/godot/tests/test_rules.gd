extends RefCounted
## Test luật lõi theo docs/02 và các phép tính kiểm tra ở docs/03 §6.


static func make(rows: Array, quan: Array, extra: Dictionary = {}) -> BattleState:
	var m := {"id": "test", "ban_do": rows, "phe": ["tayson", "thanh"], "quan": quan,
		"vang": {"tayson": 1000, "thanh": 1000}, "gioi_han": {"tayson": 10, "thanh": 10}}
	m.merge(extra, true)
	var s := BattleState.from_mission(m, 7)
	Rules.start_turn(s)
	return s


static func q(id: String, phe: String, x: int, y: int, more: Dictionary = {}) -> Dictionary:
	var d := {"id": id, "phe": phe, "x": x, "y": y}
	d.merge(more, true)
	return d


func _range(s: BattleState, att: Unit, def: Unit) -> Vector2i:
	var st := Rules.strike_stats(s, att, att.pos, def, def.pos, false)
	var lo := 999
	var hi := 0
	for c in range(st["cong_min"], st["cong_max"] + 1):
		var d := Rules.damage(c, st["thu"], att.hp)
		lo = mini(lo, d)
		hi = maxi(hi, d)
	return Vector2i(lo, hi)


func test_data_loads(t) -> bool:
	var d := GameData.get_data()
	t.eq(d.errors.size(), 0, "dữ liệu không lỗi")
	t.check(d.units.has("voi_chien"), "có voi chiến")
	t.eq(d.terrain_by_char["F"], "don", "ký tự F là đồn")
	return true


func test_damage_examples_from_doc(t) -> bool:
	# docs/03 §6: điểu thương → mộc thuẫn trên cỏ: 15–20
	var s := make(["..."], [q("moc_thuan", "tayson", 0, 0), q("dieu_thuong", "thanh", 1, 0)])
	t.eq(_range(s, s.unit_at(Vector2i(1, 0)), s.unit_at(Vector2i(0, 0))), Vector2i(15, 20), "điểu thương → mộc thuẫn")
	# trường mâu → voi chiến: 40–45
	s = make(["..."], [q("voi_chien", "tayson", 0, 0), q("truong_mau", "thanh", 1, 0)])
	t.eq(_range(s, s.unit_at(Vector2i(1, 0)), s.unit_at(Vector2i(0, 0))), Vector2i(40, 45), "trường mâu → voi")
	# voi → trường mâu: 75–85
	t.eq(_range(s, s.unit_at(Vector2i(0, 0)), s.unit_at(Vector2i(1, 0))), Vector2i(75, 85), "voi → trường mâu")
	# lính giáo + Bất ngờ → quân Lê ngủ trên doanh trại: 55–60
	s = make([".D"], [q("linh_giao", "tayson", 0, 0), q("quan_le", "thanh", 1, 0, {"ngu": true})])
	t.eq(_range(s, s.unit_at(Vector2i(0, 0)), s.unit_at(Vector2i(1, 0))), Vector2i(55, 60), "đánh quân ngủ")
	# điểu thương → Quang Trung cấp 4 trên đồn: 7–12
	s = make(["F."], [q("quang_trung", "tayson", 0, 0, {"cap": 4}), q("dieu_thuong", "thanh", 1, 0)])
	t.eq(_range(s, s.unit_at(Vector2i(1, 0)), s.unit_at(Vector2i(0, 0))), Vector2i(7, 12), "điểu thương → QT cấp 4")
	return true


func test_damage_floor(t) -> bool:
	t.eq(Rules.damage(40, 60, 100), 4, "sàn 10% công")
	t.eq(Rules.damage(60, 20, 50), 20, "tỉ lệ máu người đánh")
	return true


func test_movement_costs(t) -> bool:
	var s := make([".rrrr", "....."], [q("linh_giao", "tayson", 0, 0), q("truong_mau", "thanh", 4, 1)])
	var u := s.unit_at(Vector2i(0, 0))
	var reach := Rules.reachable(s, u)
	t.check(reach.has(Vector2i(2, 0)), "ruộng tốn 2: đi tới (2,0) với 3 điểm")
	t.check(not reach.has(Vector2i(3, 0)), "ruộng: không tới (3,0)")
	t.check(reach.has(Vector2i(3, 1)), "đường cỏ: tới (3,1)")
	return true


func test_zone_of_control(t) -> bool:
	var s := make([".......", "......."], [q("linh_giao", "tayson", 0, 0), q("truong_mau", "thanh", 3, 1)])
	var u := s.unit_at(Vector2i(0, 0))
	var reach := Rules.reachable(s, u)
	t.check(reach.has(Vector2i(3, 0)), "vào được ô kề địch")
	t.check(not reach.has(Vector2i(4, 0)), "không đi xuyên qua vùng khống chế")
	# voi bỏ qua vùng khống chế
	s = make([".......", "......."], [q("voi_chien", "tayson", 0, 0), q("truong_mau", "thanh", 3, 1)])
	reach = Rules.reachable(s, s.unit_at(Vector2i(0, 0)))
	t.check(reach.has(Vector2i(4, 0)), "voi xung phong qua vùng khống chế")
	# quân không có thẻ chan (điểu thương) không khống chế
	s = make([".......", "......."], [q("linh_giao", "tayson", 0, 0), q("dieu_thuong", "thanh", 3, 1)])
	reach = Rules.reachable(s, s.unit_at(Vector2i(0, 0)))
	t.check(reach.has(Vector2i(4, 0)), "điểu thương không khống chế")
	return true


func test_attack_and_counter(t) -> bool:
	var s := make(["..."], [q("linh_giao", "tayson", 0, 0), q("truong_mau", "thanh", 1, 0)])
	var a := s.unit_at(Vector2i(0, 0))
	var d := s.unit_at(Vector2i(1, 0))
	var ev := Rules.cmd_attack(s, a, d)
	t.check(ev.size() >= 2, "có đòn và phản đòn")
	t.check(d.hp < 100 and a.hp < 100, "cả hai mất máu")
	t.check(a.done, "người đánh hết lượt")
	# thần công không phản đòn
	s = make(["...."], [q("linh_giao", "tayson", 0, 0), q("phao_binh", "thanh", 1, 0)])
	a = s.unit_at(Vector2i(0, 0))
	Rules.cmd_attack(s, a, s.unit_at(Vector2i(1, 0)))
	t.eq(a.hp, 100, "pháo binh không phản đòn")
	# cung tiễn không phản đòn ở cự ly 1
	s = make(["...."], [q("linh_giao", "tayson", 0, 0), q("cung_tien", "thanh", 1, 0)])
	a = s.unit_at(Vector2i(0, 0))
	Rules.cmd_attack(s, a, s.unit_at(Vector2i(1, 0)))
	t.eq(a.hp, 100, "cung tiễn không phản đòn cự ly 1")
	return true


func test_ban_dung(t) -> bool:
	var s := make(["......"], [q("than_cong", "tayson", 0, 0), q("truong_mau", "thanh", 4, 0)])
	var u := s.unit_at(Vector2i(0, 0))
	t.eq(Rules.targets_from(s, u, Vector2i(1, 0), true).size(), 0, "thần công đi rồi không bắn")
	t.eq(Rules.targets_from(s, u, Vector2i(1, 0), false).size(), 1, "đứng yên thì bắn tầm 2–4")
	return true


func test_capture_and_win(t) -> bool:
	var s := make(["F.", ".."], [q("quang_trung", "tayson", 1, 0, {"tuong_chinh": true})],
		{"chu_o": {"0,0": "thanh"}, "thang": {"loai": "chiem_o", "o": [0, 0]}})
	var u := s.unit_at(Vector2i(1, 0))
	Rules.cmd_move(s, u, Vector2i(0, 0))
	var ev := Rules.cmd_capture(s, u)
	t.eq(s.owner_of(Vector2i(0, 0)), "tayson", "đã chiếm đồn")
	t.eq(s.result, "thang", "thắng màn")
	t.check(not ev.is_empty(), "có sự kiện")
	# lính giáo không chiếm được đồn
	s = make(["F."], [q("linh_giao", "tayson", 0, 0)], {"chu_o": {"0,0": "thanh"}})
	t.check(not Rules.can_capture(s, s.unit_at(Vector2i(0, 0))), "lính giáo không chiếm đồn")
	return true


func test_recruit(t) -> bool:
	var s := make(["F.."], [q("quang_trung", "tayson", 2, 0)],
		{"chu_o": {"0,0": "tayson"}, "vang": {"tayson": 300}, "mua_duoc": {"tayson": ["linh_giao", "voi_chien"]}})
	t.eq(Rules.recruit_options(s, "tayson", Vector2i(0, 0)).size(), 2, "2 loại mua được")
	t.check(not Rules.can_afford(s, "tayson", "voi_chien"), "không đủ vàng mua voi")
	var gold_before: int = s.gold["tayson"]
	Rules.cmd_recruit(s, "tayson", Vector2i(0, 0), "linh_giao")
	var nu := s.unit_at(Vector2i(0, 0))
	t.check(nu != null and nu.done, "quân mới xuất hiện trên ô đồn, xám")
	t.eq(s.gold["tayson"], gold_before - 150, "trừ vàng")
	return true


func test_income_and_heal(t) -> bool:
	var s := make(["LF"], [q("linh_giao", "tayson", 0, 0, {"mau": 50})],
		{"chu_o": {"0,0": "tayson", "1,0": "tayson"}, "vang": {"tayson": 0}, "mua_duoc": {"tayson": ["linh_giao"]}})
	# start_turn đã chạy trong make(): +30 +50 vàng, +20 máu
	t.eq(s.gold["tayson"], 80, "thu nhập làng + đồn")
	t.eq(s.unit_at(Vector2i(0, 0)).hp, 70, "hồi máu trên làng")
	return true


func test_quan_tan_and_chieu_hang(t) -> bool:
	var s := make(["...."], [q("voi_chien", "tayson", 0, 0, {"cap": 4}), q("quan_su", "tayson", 3, 0),
		q("quan_le", "thanh", 1, 0, {"mau": 10})])
	var qs := s.unit_at(Vector2i(3, 0))
	var voi := s.unit_at(Vector2i(0, 0))
	Rules.cmd_attack(s, voi, s.unit_at(Vector2i(1, 0)))
	t.eq(s.object_at(Vector2i(1, 0)).get("loai", ""), "quan_tan", "có quân tan")
	# quân sư đi tới kề quân tan rồi chiêu hàng
	Rules.cmd_move(s, qs, Vector2i(2, 0))
	var ev := Rules.cmd_chieu_hang(s, qs, Vector2i(1, 0))
	t.check(not ev.is_empty(), "chiêu hàng được")
	var hb := s.unit_at(Vector2i(1, 0))
	t.check(hb != null and hb.type_id == "hang_binh" and hb.hp == 50, "hàng binh 50 máu")
	return true


func test_quan_tan_expiry(t) -> bool:
	var s := make(["..."], [q("quang_trung", "tayson", 2, 0)])
	s.objects[Vector2i(0, 0)] = {"loai": "quan_tan", "vong": 1}
	Rules.cmd_end_turn(s)  # Tây Sơn hết lượt → Thanh
	Rules.cmd_end_turn(s)  # Thanh hết → vòng 2, Tây Sơn
	t.check(not s.objects.is_empty(), "còn ở vòng 2")
	Rules.cmd_end_turn(s)
	Rules.cmd_end_turn(s)  # vòng 3
	t.check(s.objects.is_empty(), "hết ở đầu lượt Tây Sơn vòng 3")
	return true


func test_burn(t) -> bool:
	var s := make(["..."], [q("hoa_ho", "tayson", 0, 0), q("truong_mau", "thanh", 1, 0)])
	var d := s.unit_at(Vector2i(1, 0))
	Rules.cmd_attack(s, s.unit_at(Vector2i(0, 0)), d)
	t.eq(d.chay_turns, 1, "bị Cháy")
	t.eq(Rules.move_points(s, d), 3, "Cháy: −1 di chuyển")
	Rules.cmd_end_turn(s)
	Rules.cmd_end_turn(s)  # hết lượt Thanh → hết Cháy
	t.eq(d.chay_turns, 0, "hết Cháy sau lượt kế của phe nó")
	return true


func test_main_general_death_loses(t) -> bool:
	var s := make(["..."], [q("quang_trung", "tayson", 0, 0, {"tuong_chinh": true, "mau": 5}),
		q("voi_chien", "thanh", 1, 0)])
	Rules.cmd_end_turn(s)
	Rules.cmd_attack(s, s.unit_at(Vector2i(1, 0)), s.unit_at(Vector2i(0, 0)))
	t.eq(s.result, "thua", "tướng chính bị hạ thì thua")
	return true


func test_turn_limit(t) -> bool:
	var s := make(["..."], [q("quang_trung", "tayson", 0, 0)], {"thua_het_luot": 2})
	for i in 4:
		Rules.cmd_end_turn(s)
	t.eq(s.result, "thua", "hết lượt 2 thì thua")
	return true


func test_determinism_and_save(t) -> bool:
	var a := Missions.new_battle("m_thu", 99)
	var b := BattleState.from_dict(a.to_dict())
	for st in [a, b]:
		for i in 6:
			SimpleAI.play_turn(st)
			Rules.cmd_end_turn(st)
	t.eq(JSON.stringify(a.to_dict()), JSON.stringify(b.to_dict()), "lưu / tải không đổi kết quả")
	return true


func test_ai_full_game_terminates(t) -> bool:
	var s := Missions.new_battle("m_thu", 5)
	var rounds := 0
	while s.result == "" and rounds < 80:
		SimpleAI.play_turn(s)
		Rules.cmd_end_turn(s)
		rounds += 1
	t.check(s.result != "", "AI vs AI kết thúc (kết quả: %s, vòng %d)" % [s.result, s.vong])
	return true
