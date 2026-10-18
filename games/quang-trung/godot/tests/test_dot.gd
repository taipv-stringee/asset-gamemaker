extends RefCounted
## Đốt doanh trại, ô lửa (02 §12; màn 7), sự kiện "mau_duoi" / "roi_ban_do" và mục tiêu phụ "dot_doanh".

# Hàng 1: ba ô doanh trại (1,1)-(3,1); (4,1) là đồn.
const ROWS := ["......", ".DDDF.", "......"]


static func make(quan: Array, extra: Dictionary = {}) -> BattleState:
	var m := {"id": "test_dot", "ban_do": ROWS, "phe": ["tayson", "thanh"], "quan": quan,
		"chu_o": {"4,1": "thanh"}, "gioi_han": {"tayson": 99}, "tam_nhin": 2}
	m.merge(extra, true)
	var s := BattleState.from_mission(m, 3)
	Rules.start_turn(s)
	return s


static func q(id: String, phe: String, x: int, y: int, more: Dictionary = {}) -> Dictionary:
	var d := {"id": id, "phe": phe, "x": x, "y": y}
	d.merge(more, true)
	return d


static func end_round(s: BattleState) -> void:
	Rules.cmd_end_turn(s)   # sang lượt Thanh (không cho máy đi: chỉ thử thời hạn lửa)
	Rules.cmd_end_turn(s)   # sang vòng sau, lượt Tây Sơn


func test_burn_targets(t) -> bool:
	var s := make([q("hoa_ho", "tayson", 1, 0), q("linh_giao", "tayson", 2, 0), q("tho_binh", "thanh", 2, 1, {"ngu": true, "ai": "ngu"})])
	var hh := s.unit_at(Vector2i(1, 0))
	t.eq(Rules.burn_targets(s, hh), [Vector2i(1, 1)] as Array[Vector2i], "hỏa hổ: ô doanh trại kề")
	t.eq(Rules.burn_targets(s, s.unit_at(Vector2i(2, 0))), [] as Array[Vector2i], "lính giáo không có thẻ dot")
	s = make([q("hoa_ho", "tayson", 0, 2), q("tho_binh", "thanh", 2, 1, {"ngu": true, "ai": "ngu"})])
	hh = s.unit_at(Vector2i(0, 2))
	Rules.cmd_move(s, hh, Vector2i(2, 2))
	t.eq(hh.pos, Vector2i(2, 2), "đi tới (2,2)")
	var got := Rules.burn_targets(s, hh)
	t.check(got.has(Vector2i(2, 1)), "đi rồi vẫn đốt được; ô có quân địch đốt được")
	t.check(not got.has(Vector2i(2, 3)) and not got.has(Vector2i(3, 2)), "ô cỏ không đốt được")
	s = make([q("hoa_ho", "tayson", 1, 0), q("linh_giao", "tayson", 1, 1)])
	t.eq(Rules.burn_targets(s, s.unit_at(Vector2i(1, 0))), [] as Array[Vector2i], "không đốt ô có quân mình")
	return true


func test_burn_and_expire(t) -> bool:
	var s := make([q("hoa_ho", "tayson", 1, 0)])
	var hh := s.unit_at(Vector2i(1, 0))
	var ev := Rules.cmd_dot(s, hh, Vector2i(1, 1))
	t.eq(ev[0]["loai"], "dot", "sự kiện đốt")
	t.check(hh.done, "đốt xong là hết lượt quân đó")
	t.eq(s.object_at(Vector2i(1, 1)).get("loai", ""), "lua", "ô thành lửa")
	t.check(Rules.lit_tiles(s).has(Vector2i(1, 2)), "lửa là nguồn sáng")
	t.eq(Rules.cmd_dot(s, s.unit_at(Vector2i(1, 0)), Vector2i(1, 1)), [] as Array[Dictionary], "không đốt lại ô đang cháy")
	for i in 2:
		end_round(s)
		t.eq(s.object_at(Vector2i(1, 1)).get("loai", ""), "lua", "vòng %d: vẫn cháy" % s.vong)
	end_round(s)
	t.eq(s.vong, 4, "vòng 4")
	t.check(s.object_at(Vector2i(1, 1)).is_empty(), "cháy 3 vòng rồi tắt")
	t.eq(s.terrain_id(Vector2i(1, 1)), "doanh_chay", "thành doanh trại cháy")
	t.eq(Rules.burned_count(s), 1, "đếm 1 ô đã đốt")
	t.eq(Rules.burned_count(s, 1), 0, "không ô nào đốt trước vòng 1")
	return true


func test_burn_occupied_wakes(t) -> bool:
	var s := make([q("hoa_ho", "tayson", 1, 0), q("tho_binh", "thanh", 1, 1, {"ngu": true, "ai": "ngu"})])
	var tb := s.unit_at(Vector2i(1, 1))
	Rules.cmd_dot(s, s.unit_at(Vector2i(1, 0)), Vector2i(1, 1))
	t.check(not tb.ngu, "quân trên ô bị đốt thức dậy")
	t.check(tb.keu, "ban đêm: nó kêu (báo động đầu lượt Thanh)")
	t.eq(tb.chay_turns, 1, "Cháy tới hết lượt Thanh kế tiếp")
	Rules.cmd_end_turn(s)
	t.check(tb.chay_turns >= 1, "đầu lượt Thanh vẫn đứng trên lửa: Cháy")
	t.check(int(s.flags["bao_dong"]) > 0, "báo động")
	return true


func test_walk_into_fire(t) -> bool:
	var s := make([q("hoa_ho", "tayson", 1, 0), q("moc_thuan", "tayson", 0, 2)])
	Rules.cmd_dot(s, s.unit_at(Vector2i(1, 0)), Vector2i(1, 1))
	var mt := s.unit_at(Vector2i(0, 2))
	Rules.cmd_move(s, mt, Vector2i(1, 1))
	t.eq(mt.chay_turns, 0, "mộc thuẫn không bị Cháy")
	var s2 := make([q("hoa_ho", "tayson", 1, 0), q("linh_giao", "tayson", 2, 1)])
	Rules.cmd_dot(s2, s2.unit_at(Vector2i(1, 0)), Vector2i(1, 1))
	var lg2 := s2.unit_at(Vector2i(2, 1))
	var ev := Rules.cmd_move(s2, lg2, Vector2i(1, 1))
	t.eq(lg2.chay_turns, 2, "bước vào ô lửa: Cháy tới hết lượt sau của mình")
	t.check(ev.any(func(e: Dictionary) -> bool: return e["loai"] == "chay"), "sự kiện Cháy")
	t.eq(Rules.cmd_undo_move(s2, lg2), [] as Array[Dictionary], "đã bước vào lửa thì không Hoàn tác được (kiểm thử M3 lần 6)")
	t.eq(lg2.pos, Vector2i(1, 1), "vẫn đứng trên ô lửa")
	return true


func test_ai_avoids_fire(t) -> bool:
	var s := make([q("hoa_ho", "tayson", 1, 0), q("tho_binh", "thanh", 1, 1, {"ai": "giu_don", "tam": [1, 1], "ban_kinh": 2})])
	Rules.cmd_dot(s, s.unit_at(Vector2i(1, 0)), Vector2i(1, 1))
	Rules.cmd_end_turn(s)
	var tb: Unit = s.units_of("thanh")[0]
	var plan := SimpleAI.plan_unit(s, tb)
	t.check(plan["den"] != Vector2i(1, 1), "máy bước ra khỏi ô lửa")
	return true


func test_objective_dot_doanh(t) -> bool:
	var obj := {"muc_tieu_phu": [{"loai": "dot_doanh", "n": 2, "truoc_vong": 3, "ten": "Đốt"}], "thang": {"loai": "co", "co": "xong"}}
	var s := make([q("hoa_ho", "tayson", 1, 0), q("hoa_ho", "tayson", 3, 0)], obj)
	Rules.cmd_dot(s, s.unit_at(Vector2i(1, 0)), Vector2i(1, 1))
	t.eq(Rules.side_objectives_live(s)[0]["trang_thai"], "dang", "mới 1 ô: còn mở")
	Rules.cmd_dot(s, s.unit_at(Vector2i(3, 0)), Vector2i(3, 1))
	t.eq(Rules.side_objectives_live(s)[0]["trang_thai"], "xong", "2 ô trước vòng 3: đã xong")
	var s2 := make([q("hoa_ho", "tayson", 1, 0)], obj)
	end_round(s2)
	end_round(s2)
	t.eq(Rules.side_objectives_live(s2)[0]["trang_thai"], "hong", "tới vòng 3 chưa đủ: hỏng")
	return true


func test_event_mau_duoi_roi_ban_do(t) -> bool:
	var ev_def := [{"id": "tu_van", "khi": {"loai": "mau_duoi", "quan": "sam_nghi_dong", "n": 2},
		"lam": [{"loai": "co", "co": "da_tu_van"}, {"loai": "roi_ban_do", "quan": "sam_nghi_dong"}]}]
	var s := make([q("linh_giao", "tayson", 4, 0), q("sam_nghi_dong", "thanh", 4, 1, {"toi_thieu_1": true, "mau": 5})],
		{"su_kien": ev_def, "thang": {"loai": "chiem_o", "o": [4, 1]}})
	var snd := s.unit_at(Vector2i(4, 1))
	var ev := Rules.cmd_attack(s, s.unit_at(Vector2i(4, 0)), snd)
	t.eq(snd.hp, 1, "toi_thieu_1: còn 1 máu")
	t.check(not s.units.has(snd), "rời bản đồ")
	t.check(Rules.has_flag(s, "da_tu_van"), "cờ")
	t.check(s.object_at(Vector2i(4, 1)).is_empty(), "không để quân tan")
	t.check(ev.any(func(e: Dictionary) -> bool: return e["loai"] == "roi_ban_do"), "sự kiện rời bản đồ")
	t.eq(s.owner_of(Vector2i(4, 1)), "thanh", "đồn vẫn của Thanh: phải vào chiếm")
	return true
