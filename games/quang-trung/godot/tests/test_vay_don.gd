extends RefCounted
## Khu đồn, vây đồn, gọi hàng, kho lương (02 §11–12; màn 6) và hệ quả từ màn trước.

# Khu 2×1 ở (2,1)-(3,1); hàng trên và dưới là ô kề ngoài; tây và đông là ao.
const ROWS := ["......", ".~DF~.", "......"]


static func make(quan: Array, extra: Dictionary = {}) -> BattleState:
	var m := {"id": "test_vay", "ban_do": ROWS, "phe": ["tayson", "thanh"], "quan": quan,
		"khu": {"don": [[2, 1], [3, 1]]}, "khu_don": ["don"], "chu_o": {"3,1": "thanh"},
		"gioi_han": {"tayson": 99}, "tam_nhin": 2}
	m.merge(extra, true)
	var s := BattleState.from_mission(m, 3)
	Rules.start_turn(s)
	return s


static func q(id: String, phe: String, x: int, y: int, more: Dictionary = {}) -> Dictionary:
	var d := {"id": id, "phe": phe, "x": x, "y": y}
	d.merge(more, true)
	return d


static func garrison() -> Array:
	return [q("dieu_thuong", "thanh", 2, 1, {"ngu": true, "ai": "ngu"}), q("quan_giu_don", "thanh", 3, 1, {"ngu": true, "ai": "ngu"})]


func test_siege_gaps(t) -> bool:
	var s := make(garrison())
	t.eq(Rules.zone_ring(s, "don").size(), 6, "6 ô kề ngoài (ao 2 ô)")
	t.eq(Rules.siege_gaps(s, "don", "tayson").size(), 4, "ao không tính là ô hở")
	# Lính giáo ở (2,0) khống chế (3,0); quân sư đứng (2,2); lính giáo (3,2) → kín.
	s = make(garrison() + [q("linh_giao", "tayson", 2, 0), q("quan_su", "tayson", 2, 2), q("linh_giao", "tayson", 3, 2)])
	t.eq(Rules.siege_gaps(s, "don", "tayson").size(), 0, "đủ quân và khống chế: bị vây")
	s = make(garrison() + [q("hoa_mai", "tayson", 2, 0), q("quan_su", "tayson", 2, 2), q("linh_giao", "tayson", 3, 2)])
	t.eq(Rules.siege_gaps(s, "don", "tayson"), [Vector2i(3, 0)] as Array[Vector2i], "hỏa mai không khống chế ô bên cạnh")
	s.objects[Vector2i(3, 0)] = {"loai": "quan_tan", "vong": 1}
	t.eq(Rules.siege_gaps(s, "don", "tayson").size(), 0, "ô có quân tan không vào được: coi như kín")
	return true


func test_goi_hang_success(t) -> bool:
	var s := make(garrison() + [q("linh_giao", "tayson", 2, 0), q("quan_su", "tayson", 2, 2), q("linh_giao", "tayson", 3, 2)])
	var qs := s.unit_at(Vector2i(2, 2))
	t.eq(Rules.goi_hang_zones(s, qs), ["don"] as Array[String], "quân sư kề khu bị vây: gọi hàng được")
	t.eq(Rules.goi_hang_zones(s, s.unit_at(Vector2i(2, 0))), [] as Array[String], "lính giáo không có thẻ goi_hang")
	var fc := Rules.goi_hang_forecast(s, "don", "tayson")
	t.check(fc["ngu_qua_nua"], "cả khu đang ngủ")
	t.eq(fc["can"], 100, "200 máu × ½")
	t.eq(fc["ta"], 300, "3 quân ta trong 2 ô")
	var ev := Rules.cmd_goi_hang(s, qs, "don")
	t.check(ev[0]["thanh_cong"], "thành công")
	t.eq(Rules.zone_enemies(s, "don", "tayson").size(), 0, "quân trong khu đã ra hàng")
	t.eq(int(s.flags["hang_binh"]), 2, "2 hàng binh")
	t.check(s.unit_at(Vector2i(3, 1)) == null, "không đặt hàng binh lên ô đồn")
	t.eq(s.owner_of(Vector2i(3, 1)), "", "đồn thành trung lập")
	t.check(Rules.has_flag(s, "goi_hang_don"), "cờ gọi hàng")
	t.eq(Rules.goi_hang_zones(s, s.unit_at(Vector2i(3, 2))), [] as Array[String], "khu không còn quân: không gọi nữa")
	return true


func test_goi_hang_awake_needs_full(t) -> bool:
	var g := [q("dieu_thuong", "thanh", 2, 1), q("quan_giu_don", "thanh", 3, 1)]
	var s := make(g + [q("linh_giao", "tayson", 2, 0, {"mau": 60}), q("quan_su", "tayson", 2, 2, {"mau": 60}),
		q("linh_giao", "tayson", 3, 2, {"mau": 60})])
	var fc := Rules.goi_hang_forecast(s, "don", "tayson")
	t.eq(fc["can"], 200, "thức: cần đủ máu")
	var qs := s.unit_at(Vector2i(2, 2))
	var ev := Rules.cmd_goi_hang(s, qs, "don")
	t.check(not ev[0]["thanh_cong"], "180 < 200: không thành")
	t.eq(Rules.zone_enemies(s, "don", "tayson").size(), 2, "quân vẫn trong khu")
	t.check(qs.done, "quân gọi hết lượt")
	t.eq(Rules.goi_hang_zones(s, s.unit_at(Vector2i(3, 2))), [] as Array[String], "mỗi khu một lần mỗi vòng")
	return true


func test_prisoners_over_limit(t) -> bool:
	var s := make(garrison() + [q("linh_giao", "tayson", 2, 0), q("quan_su", "tayson", 2, 2), q("linh_giao", "tayson", 3, 2)],
		{"gioi_han": {"tayson": 4}})
	Rules.cmd_goi_hang(s, s.unit_at(Vector2i(2, 2)), "don")
	t.eq(int(s.flags["hang_binh"]), 1, "còn 1 chỗ: 1 hàng binh")
	t.eq(int(s.flags["tu_binh"]), 1, "phần còn lại là tù binh")
	return true


func test_attack_in_zone_flag(t) -> bool:
	var s := make(garrison() + [q("linh_giao", "tayson", 2, 0)],
		{"muc_tieu_phu": [{"loai": "goi_hang_sach", "khu": "don", "ten": "x"}]})
	Rules.cmd_attack(s, s.unit_at(Vector2i(2, 0)), s.unit_at(Vector2i(2, 1)))
	t.check(s.flags.get("danh_trong_khu", false), "đánh quân trong khu đồn: bật cờ")
	t.eq(Rules.side_objectives_live(s)[0]["trang_thai"], "hong", "mục tiêu gọi hàng sạch đã hỏng")
	return true


func test_granary(t) -> bool:
	var s := make([q("linh_giao", "tayson", 0, 0), q("hoa_mai", "tayson", 5, 0)],
		{"vat_the": [{"loai": "kho_luong", "o": [1, 0], "co": "lay_kho_luong"}, {"loai": "kho_luong", "o": [4, 0], "co": "kho_2"}]})
	var lg := s.unit_at(Vector2i(0, 0))
	Rules.cmd_move(s, lg, Vector2i(1, 0))
	t.check(Rules.can_capture(s, lg), "lính giáo lấy được kho lương")
	Rules.cmd_capture(s, lg)
	t.check(Rules.has_flag(s, "lay_kho_luong"), "bật cờ kho lương")
	t.check(s.object_at(Vector2i(1, 0)).is_empty(), "kho đã lấy")
	var hm := s.unit_at(Vector2i(5, 0))
	Rules.cmd_move(s, hm, Vector2i(4, 0))
	t.check(not Rules.can_capture(s, hm), "hỏa mai không lấy được kho")
	return true


func test_carry_wakes_garrison(t) -> bool:
	var s := make(garrison() + [q("truong_mau", "thanh", 0, 0, {"ngu": true, "ai": "ngu"})],
		{"he_qua": [{"co": "trinh_sat_thoat", "thuc_khu": "don"}]})
	Rules.apply_carry(s, {})
	t.check(s.unit_at(Vector2i(3, 1)).ngu, "không có cờ: vẫn ngủ")
	Rules.apply_carry(s, {"trinh_sat_thoat": true})
	t.check(not s.unit_at(Vector2i(3, 1)).ngu, "có cờ: quân trong khu thức")
	t.eq(s.unit_at(Vector2i(3, 1)).ai_mode, "giu_don", "giữ đồn")
	t.eq(int(s.unit_at(Vector2i(3, 1)).ai_params["ban_kinh"]), 0, "không rời chỗ")
	t.check(s.unit_at(Vector2i(0, 0)).ngu, "quân ngoài khu không bị ảnh hưởng")
	t.check(Rules.has_flag(s, "he_qua_trinh_sat_thoat"), "cờ trận cho hội thoại mở màn")
	return true
