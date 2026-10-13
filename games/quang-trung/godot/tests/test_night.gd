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


func test_reveal_locks_undo(t) -> bool:
	var s := make(["........"], [q("linh_giao", "tayson", 0, 0), q("quan_le", "le", 6, 0, {"ngu": true})])
	var u := s.unit_at(Vector2i(0, 0))
	var ev := Rules.cmd_move(s, u, Vector2i(4, 0))
	t.check(u.khoa_hoan_tac, "lộ quân địch → khóa hoàn tác")
	t.eq(Rules.cmd_undo_move(s, u).size(), 0, "không hoàn tác được")
	t.eq(ev[-1]["loai"], "lo_dien", "có sự kiện lộ diện")
	return true


func test_mission4_loads_and_quiet(t) -> bool:
	var s := Missions.new_battle("m04_gian_khau", 7)
	t.eq(s.width, 10, "rộng 10")
	t.eq(s.height, 18, "cao 18")
	t.eq(s.units_of("le").size(), 9, "9 quân Lê")
	t.eq(s.units_of("tayson").size(), 11, "11 quân ta")
	t.eq(s.zone_of(Vector2i(4, 2)), "gian_khau", "đồn thuộc khu")
	var patrol := s.unit_at(Vector2i(8, 7))
	# Quân ta đứng yên 3 vòng: lính tuần đi lại, không báo động.
	for i in 3:
		Rules.cmd_end_turn(s)
		SimpleAI.play_turn(s)
		Rules.cmd_end_turn(s)
	t.eq(int(s.flags["bao_dong"]), 0, "đứng yên ở bờ nam thì không bị phát hiện")
	t.check(patrol.pos != Vector2i(8, 7), "lính tuần có đi")
	t.check(s.unit_at(Vector2i(4, 2)).ngu, "quan giữ đồn vẫn ngủ")
	return true


func test_ambush(t) -> bool:
	# Quân địch nằm trong sương: ô của nó trông như đi được; đi vào thì bị chặn ("phục kích").
	var s := make(["......", "......"], [q("linh_giao", "tayson", 0, 0), q("quan_le", "le", 4, 0, {"ngu": true})], {"tam_nhin": 1})
	var u := s.unit_at(Vector2i(0, 0))
	t.check(Rules.reachable(s, u, true).has(Vector2i(4, 0)), "ô có địch ẩn trông như đi được")
	t.check(not Rules.reachable(s, u).has(Vector2i(4, 0)), "luật thật thì không")
	var ev := Rules.cmd_move(s, u, Vector2i(4, 0), true)
	t.eq(u.pos, Vector2i(3, 0), "dừng ở ô kề (bước vào vùng khống chế)")
	t.check(u.khoa_hoan_tac, "phục kích → không hoàn tác")
	var kinds := []
	for e in ev:
		kinds.append(e["loai"])
	t.check(kinds.has("phuc_kich"), "có sự kiện phục kích")
	return true


func test_escape_zone_and_reinforcements(t) -> bool:
	var s := make(["......", "......"], [q("ngo_van_so", "tayson", 0, 0, {"tuong_chinh": true}), q("linh_giao", "tayson", 0, 1)],
		{"tam_nhin": 0, "phe": ["tayson", "thanh"], "khu": {"thoat": [[4, 0], [5, 0], [4, 1], [5, 1]]},
		"thang": {"loai": "vao_vung", "khu": "thoat", "so_quan": 1},
		"vien_binh": [{"phe": "thanh", "tu_vong": 1, "moi": 2, "den_vong": 5, "quan": [{"id": "truong_mau", "x": 5, "y": 0}]}],
		"muc_tieu_phu": [{"loai": "ve_vung", "quan": "linh_giao", "khu": "thoat", "ten": "lính giáo về"}]})
	Rules.cmd_end_turn(s)  # lượt Thanh vòng 1 → viện binh
	t.eq(s.units_of("thanh").size(), 1, "viện binh vòng 1")
	t.eq(s.units_of("thanh")[0].pos, Vector2i(5, 0), "đúng chỗ")
	Rules.cmd_end_turn(s)
	Rules.cmd_end_turn(s)  # Thanh vòng 2: không có viện binh
	t.eq(s.units_of("thanh").size(), 1, "vòng 2 không có")
	Rules.cmd_end_turn(s)
	Rules.cmd_end_turn(s)  # Thanh vòng 3: ô (5,0) có quân → lùi sang ô trống gần nhất
	t.eq(s.units_of("thanh").size(), 2, "viện binh vòng 3")
	Rules.cmd_end_turn(s)  # vòng 4, lượt ta
	var so := s.unit_at(Vector2i(0, 0))
	Rules.cmd_move(s, so, Vector2i(4, 0)) if Rules.reachable(s, so).has(Vector2i(4, 0)) else null
	t.eq(s.result, "", "chưa đủ quân trong khu thì chưa thắng")
	return true


func test_escape_zone_win(t) -> bool:
	var s := make(["......", "......"], [q("ngo_van_so", "tayson", 3, 0, {"tuong_chinh": true}), q("linh_giao", "tayson", 3, 1)],
		{"tam_nhin": 0, "khu": {"thoat": [[4, 0], [5, 0], [4, 1], [5, 1]]}, "thang": {"loai": "vao_vung", "khu": "thoat", "so_quan": 1},
		"muc_tieu_phu": [{"loai": "ve_vung", "quan": "linh_giao", "khu": "thoat", "ten": "lính giáo về"}, {"loai": "len_cap", "n": 1, "ten": "lên cấp"}]})
	var so := s.unit_at(Vector2i(3, 0))
	Rules.cmd_move(s, so, Vector2i(4, 0))
	Rules.cmd_wait(s, so)
	t.eq(s.result, "", "mới có tướng chính")
	var lg := s.unit_at(Vector2i(3, 1))
	Rules.cmd_move(s, lg, Vector2i(4, 1))
	Rules.cmd_wait(s, lg)
	t.eq(s.result, "thang", "tướng chính + 1 quân trong khu → thắng")
	var obj := Rules.side_objectives(s)
	t.check(obj[0]["dat"], "lính giáo về vùng")
	t.check(not obj[1]["dat"], "chưa ai lên cấp")
	return true


func test_reinforcement_rounds_from_json(t) -> bool:
	# Dữ liệu màn đọc từ JSON: số vòng là float.
	var m: Dictionary = JSON.parse_string('{"vien_binh": [{"phe": "thanh", "vong": [1, 3], "quan": [{"id": "truong_mau", "x": 5, "y": 0}]}]}')
	var s := make(["......"], [q("linh_giao", "tayson", 0, 0)], {"tam_nhin": 0, "phe": ["tayson", "thanh"], "vien_binh": m["vien_binh"]})
	Rules.cmd_end_turn(s)
	t.eq(s.units_of("thanh").size(), 1, "viện binh vòng 1 (vòng ghi trong JSON)")
	return true
