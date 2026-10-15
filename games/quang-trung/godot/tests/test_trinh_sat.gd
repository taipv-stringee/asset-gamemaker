extends RefCounted
## Trinh sát (màn 5; 02 §14 chế độ Chạy), hệ quả sang màn sau, quân tan trên đồn, sự kiện chiem_o.


static func make(rows: Array, quan: Array, extra: Dictionary = {}) -> BattleState:
	var m := {"id": "test_trinh_sat", "ban_do": rows, "phe": ["tayson", "thanh"], "quan": quan,
		"khu": {"thoat": [[9, 0]]}, "co_khi_thoat": "trinh_sat_thoat", "luu_co": ["trinh_sat_thoat"],
		"muc_tieu_phu": [{"loai": "khong_thoat", "ten": "Không để trinh sát nào thoát"}]}
	m.merge(extra, true)
	var s := BattleState.from_mission(m, 3)
	Rules.start_turn(s)
	return s


static func scout(x: int, y: int, more: Dictionary = {}) -> Dictionary:
	var d := {"id": "trinh_sat", "phe": "thanh", "x": x, "y": y, "ai": "do_tham", "khu": "thoat", "thay": 3}
	d.merge(more, true)
	return d


static func _has_event(ev: Array, kind: String) -> bool:
	for e in ev:
		if e["loai"] == kind:
			return true
	return false


func test_spot_radius(t) -> bool:
	var s := make([".........."], [{"id": "linh_giao", "phe": "tayson", "x": 0, "y": 0}, scout(4, 0)])
	var ev := Rules.cmd_end_turn(s)
	t.eq(s.unit_at(Vector2i(4, 0)).ai_mode, "do_tham", "quân ta cách 4 ô: trinh sát chưa thấy")
	t.check(not _has_event(ev, "trinh_sat_chay"), "chưa có sự kiện chạy")
	SimpleAI.play_turn(s)
	Rules.cmd_end_turn(s)
	t.eq(s.unit_at(Vector2i(4, 0)).ai_mode, "do_tham", "trinh sát không có điểm tuần thì đứng yên")
	# Quân ta tiến vào trong 3 ô → đầu lượt Thanh trinh sát đổi sang chạy về khu thoát.
	Rules.cmd_move(s, s.unit_at(Vector2i(0, 0)), Vector2i(1, 0))
	ev = Rules.cmd_end_turn(s)
	var u := s.unit_at(Vector2i(4, 0))
	t.eq(u.ai_mode, "chay", "thấy quân ta trong 3 ô thì chạy")
	t.check(_has_event(ev, "trinh_sat_chay"), "có sự kiện trinh_sat_chay")
	t.check((u.ai_params["vung"] as Array).has(Vector2i(9, 0)), "chạy về khu thoát")
	return true


func test_escape(t) -> bool:
	var s := make([".........."], [{"id": "linh_giao", "phe": "tayson", "x": 3, "y": 0, "tuong_chinh": true}, scout(5, 0)])
	Rules.cmd_end_turn(s)   # đầu lượt Thanh: thấy quân ta (cách 2 ô) → chạy
	var ev := SimpleAI.play_turn(s)
	t.check(_has_event(ev, "thoat"), "tới khu thoát thì rời bản đồ")
	t.eq(s.units_of("thanh").size(), 0, "trinh sát không còn trên bản đồ")
	t.eq(int(s.flags.get("thoat", 0)), 1, "đếm 1 trinh sát thoát")
	t.check(Rules.has_flag(s, "trinh_sat_thoat"), "bật cờ co_khi_thoat")
	t.eq(Rules.side_objectives_live(s)[0]["trang_thai"], "hong", "mục tiêu không để thoát đã hỏng")
	t.eq(int(s.flags["mat_quan"].size()), 0, "thoát không tính là quân ta mất")
	return true


func test_caught_scout_leaves_no_flag(t) -> bool:
	var s := make([".........."], [{"id": "voi_chien", "phe": "tayson", "x": 3, "y": 0}, scout(4, 0, {"mau": 10})])
	Rules.cmd_attack(s, s.unit_at(Vector2i(3, 0)), s.unit_at(Vector2i(4, 0)))
	t.eq(s.units_of("thanh").size(), 0, "trinh sát bị hạ")
	t.check(not Rules.has_flag(s, "trinh_sat_thoat"), "không có cờ thoát")
	s.result = "thang"
	t.check(Rules.side_objectives(s)[0]["dat"], "thắng mà không ai thoát: đạt mục tiêu")
	return true


func test_carry_flag_to_next_mission(t) -> bool:
	Progress.PROGRESS_PATH = "user://test_tien_trinh.json"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Progress.PROGRESS_PATH))
	Progress.reset_cache()
	var s := make([".........."], [{"id": "linh_giao", "phe": "tayson", "x": 0, "y": 0}])
	s.flags["co"] = {"trinh_sat_thoat": true}
	s.result = "thang"
	Progress.record_win(s)
	t.check(Progress.campaign_flag("trinh_sat_thoat"), "thắng mà có trinh sát thoát → màn sau biết")
	var clean := make([".........."], [{"id": "linh_giao", "phe": "tayson", "x": 0, "y": 0}])
	clean.result = "thang"
	Progress.record_win(clean)
	t.check(not Progress.campaign_flag("trinh_sat_thoat"), "chơi lại sạch thì xóa hệ quả")
	Progress.reset_cache()
	t.check(not Progress.campaign_flag("trinh_sat_thoat"), "ghi ra file")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Progress.PROGRESS_PATH))
	Progress.PROGRESS_PATH = "user://tien_trinh.json"
	Progress.reset_cache()
	return true


func test_no_quan_tan_on_fort(t) -> bool:
	var s := make([".F."], [{"id": "voi_chien", "phe": "tayson", "x": 0, "y": 0},
		{"id": "truong_mau", "phe": "thanh", "x": 1, "y": 0, "mau": 5}])
	Rules.cmd_attack(s, s.unit_at(Vector2i(0, 0)), s.unit_at(Vector2i(1, 0)))
	t.check(s.object_at(Vector2i(1, 0)).is_empty(), "quân bị hạ trên đồn không để lại quân tan")
	return true


func test_event_on_capture(t) -> bool:
	var s := make(["=F."], [{"id": "quang_trung", "phe": "tayson", "x": 0, "y": 0, "tuong_chinh": true}],
		{"chu_o": {"1,0": "thanh"}, "su_kien": [{"id": "lay_don", "khi": {"loai": "chiem_o", "o": [1, 0]},
			"lam": [{"loai": "bang", "chu": "Đã lấy đồn"}]}]})
	var qt := s.unit_at(Vector2i(0, 0))
	Rules.cmd_move(s, qt, Vector2i(1, 0))
	var ev := Rules.cmd_capture(s, qt)
	t.check(_has_event(ev, "bang"), "chiếm đồn thì chạy sự kiện chiem_o")
	return true


func test_live_objective_done_before_win(t) -> bool:
	# Báo cáo M3 lần 3: mục tiêu phụ đã làm được giữa trận hiện "xong" (✓), không còn ☆ như chưa làm.
	var s := make([".........."], [{"id": "linh_giao", "phe": "tayson", "x": 0, "y": 0}],
		{"muc_tieu_phu": [{"loai": "co", "co": "moi_thiep", "ten": "Mời"}]})
	t.eq(Rules.side_objectives_live(s)[0]["trang_thai"], "dang", "chưa làm: còn mở")
	s.flags["co"] = {"moi_thiep": true}
	t.eq(Rules.side_objectives_live(s)[0]["trang_thai"], "xong", "đã làm, chưa thắng: xong")
	s.result = "thang"
	t.eq(Rules.side_objectives_live(s)[0]["trang_thai"], "dat", "thắng: đạt")
	return true
