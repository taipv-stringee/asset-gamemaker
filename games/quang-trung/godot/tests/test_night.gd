extends RefCounted
## Test luật đêm (docs/02 §10, §11-12).


static func make(rows: Array, quan: Array, extra: Dictionary = {}) -> BattleState:
	var m := {"id": "test_dem", "ban_do": rows, "phe": ["tayson", "le"], "quan": quan, "tam_nhin": 2}
	m.merge(extra, true)
	var s := BattleState.from_mission(m, 3)
	Rules.start_turn(s)
	return s


static func q(id: String, phe: String, x: int, y: int, more: Dictionary = {}) -> Dictionary:
	var d := {"id": id, "phe": phe, "x": x, "y": y}
	d.merge(more, true)
	return d


func test_visibility(t) -> bool:
	var s := make([".........."], [q("linh_giao", "tayson", 0, 0), q("quan_le", "le", 5, 0), q("quan_le", "le", 9, 0)],
		{"vat_the": [{"loai": "den", "o": [9, 0]}]})
	t.check(not Rules.can_see(s, "tayson", Vector2i(5, 0)), "không thấy quân ở xa trong đêm")
	t.check(Rules.can_see(s, "tayson", Vector2i(2, 0)), "thấy trong 2 ô")
	t.check(Rules.can_see(s, "tayson", Vector2i(9, 0)), "thấy ô có đèn")
	t.check(Rules.can_see(s, "tayson", Vector2i(8, 0)), "thấy ô kề đèn")
	return true


func test_targets_need_vision(t) -> bool:
	var s := make(["......"], [q("hoa_mai", "tayson", 0, 0), q("quan_le", "le", 2, 0)], {"tam_nhin": 1})
	t.eq(Rules.targets_from(s, s.unit_at(Vector2i(0, 0)), Vector2i(0, 0), false).size(), 0, "không bắn được quân không thấy")
	return true


func test_two_hits_no_alarm(t) -> bool:
	# Hai quân hạ gọn quân ngủ trong cùng lượt → không báo động.
	var s := make([".D.", "..."], [q("linh_giao", "tayson", 0, 0), q("linh_giao", "tayson", 1, 1),
		q("quan_le", "le", 1, 0, {"ngu": true}), q("quan_le", "le", 2, 1, {"ngu": true, "ai": "ngu"})])
	var target := s.unit_at(Vector2i(1, 0))
	Rules.cmd_attack(s, s.unit_at(Vector2i(0, 0)), target)
	t.check(target.keu, "bị đánh mà còn sống thì kêu")
	Rules.cmd_attack(s, s.unit_at(Vector2i(1, 1)), target)
	t.check(s.unit_at(Vector2i(1, 0)) == null, "đòn thứ hai hạ được")
	var other := s.unit_at(Vector2i(2, 1))
	Rules.cmd_end_turn(s)  # sang lượt Lê → xử lý báo động
	t.eq(int(s.flags["bao_dong"]), 0, "không có báo động")
	t.check(other.ngu, "quân bên cạnh vẫn ngủ")
	return true


func test_alarm_and_drum(t) -> bool:
	var s := make(["..........", ".........."], [q("linh_giao", "tayson", 0, 0),
		q("quan_le", "le", 1, 0, {"ngu": true}), q("quan_le", "le", 9, 1, {"ngu": true, "ai": "ngu"})],
		{"vat_the": [{"loai": "trong", "o": [2, 0], "khu": "don"}], "khu": {"don": [[1, 0], [9, 1]]}})
	var target := s.unit_at(Vector2i(1, 0))
	Rules.cmd_attack(s, s.unit_at(Vector2i(0, 0)), target)
	Rules.cmd_end_turn(s)
	t.eq(int(s.flags["bao_dong"]), 1, "báo động 1 lần")
	t.check(not s.unit_at(Vector2i(9, 1)).ngu, "trống đánh thức cả khu đồn")
	t.eq(s.unit_at(Vector2i(9, 1)).ai_mode, "giu_don", "chuyển sang giữ đồn")
	return true


func test_patrol_spots(t) -> bool:
	var s := make(["......"], [q("linh_giao", "tayson", 0, 0),
		q("quan_le", "le", 2, 0, {"ai": "tuan_tra", "diem": [[5, 0], [2, 0]]})])
	Rules.cmd_end_turn(s)
	t.eq(int(s.flags["bao_dong"]), 1, "lính tuần thấy quân ta trong 2 ô → báo động")
	return true


func test_dawn(t) -> bool:
	var s := make(["...."], [q("linh_giao", "tayson", 0, 0), q("quan_le", "le", 3, 0, {"ngu": true})], {"rang_sang": 2})
	Rules.cmd_end_turn(s)
	Rules.cmd_end_turn(s)  # vòng 2
	t.eq(s.tam_nhin, 3, "rạng sáng: tầm nhìn 3")
	t.check(not s.unit_at(Vector2i(3, 0)).ngu, "mọi quân thức")
	Rules.cmd_end_turn(s)
	Rules.cmd_end_turn(s)
	t.eq(s.tam_nhin, 5, "vòng R+1: tầm nhìn 5")
	Rules.cmd_end_turn(s)
	Rules.cmd_end_turn(s)
	t.eq(s.tam_nhin, 0, "vòng R+2: hết sương mù")
	return true


func test_side_objectives(t) -> bool:
	var s := make(["F."], [q("quang_trung", "tayson", 1, 0, {"tuong_chinh": true})],
		{"chu_o": {"0,0": "le"}, "thang": {"loai": "chiem_o", "o": [0, 0]},
		"muc_tieu_phu": [{"loai": "truoc_luot", "n": 2, "ten": "nhanh"}, {"loai": "khong_bao_dong", "ten": "im lặng"}]})
	var u := s.unit_at(Vector2i(1, 0))
	Rules.cmd_move(s, u, Vector2i(0, 0))
	Rules.cmd_capture(s, u)
	var obj := Rules.side_objectives(s)
	t.check(obj[0]["dat"] and obj[1]["dat"], "đạt cả hai mục tiêu phụ")
	return true
