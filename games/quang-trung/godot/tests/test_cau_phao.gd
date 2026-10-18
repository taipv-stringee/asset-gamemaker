extends RefCounted
## Cầu phao rung rồi đứt, điều kiện thắng "ha_loai", quân mang từ màn trước (màn 9), mở khóa "mo_sau" (màn 7, 8, 9).

# Sông dọc cột 2–3, cầu phao ở hàng 1; bờ đông cột 4–5.
const ROWS := ["..~~..", "..%%..", "..~~.."]


static func make(quan: Array, extra: Dictionary = {}) -> BattleState:
	var m := {"id": "test_cau", "ban_do": ROWS, "phe": ["tayson", "thanh"], "quan": quan, "gioi_han": {"tayson": 99},
		"khu": {"dong": [[4, 0], [5, 0], [4, 1], [5, 1], [4, 2], [5, 2]]},
		"cau_phao": {"o": [[2, 1], [3, 1]], "rung": 3, "khi_qua": "ton_si_nghi"}}
	m.merge(extra, true)
	var s := BattleState.from_mission(m, 3)
	Rules.start_turn(s)
	return s


static func q(id: String, phe: String, x: int, y: int, more: Dictionary = {}) -> Dictionary:
	var d := {"id": id, "phe": phe, "x": x, "y": y}
	d.merge(more, true)
	return d


static func end_round(s: BattleState) -> Array[Dictionary]:
	var ev := Rules.cmd_end_turn(s)
	ev.append_array(Rules.cmd_end_turn(s))
	return ev


func test_bridge_shakes_then_breaks(t) -> bool:
	var s := make([q("linh_giao", "tayson", 0, 1), q("thuy_binh", "tayson", 1, 0), q("truong_mau", "thanh", 3, 1, {"ai": "dung_yen"})])
	var ev := end_round(s)
	t.check(not ev.any(func(e: Dictionary) -> bool: return e["loai"] == "cau_rung"), "vòng 2: chưa rung")
	ev = end_round(s)
	t.check(ev.any(func(e: Dictionary) -> bool: return e["loai"] == "cau_rung"), "vòng 3: cầu rung")
	t.eq(s.terrain_id(Vector2i(2, 1)), "cau_phao", "rung chưa đứt")
	Rules.cmd_move(s, s.unit_at(Vector2i(0, 1)), Vector2i(2, 1))
	Rules.cmd_move(s, s.unit_at(Vector2i(1, 0)), Vector2i(1, 1))
	Rules.cmd_move(s, s.unit_at(Vector2i(1, 1)), Vector2i(1, 1))
	var tb := s.unit_at(Vector2i(1, 1))
	ev = end_round(s)
	t.check(ev.any(func(e: Dictionary) -> bool: return e["loai"] == "cau_dut"), "vòng 4: cầu đứt")
	t.eq(s.terrain_id(Vector2i(2, 1)), "song", "ô cầu thành sông")
	t.check(s.unit_at(Vector2i(3, 1)) == null, "quân Thanh trên cầu rơi xuống sông")
	t.check(s.unit_at(Vector2i(2, 1)) == null, "lính giáo trên cầu rơi xuống sông")
	t.check(s.units.has(tb), "thủy binh không trên cầu thì không sao")
	t.eq(int(s.flags["mat_quan"].get("linh_giao", 0)), 1, "tính mất quân")
	return true


func test_bridge_shakes_early_when_crossed(t) -> bool:
	var s := make([q("linh_giao", "tayson", 0, 0), q("ton_si_nghi", "thanh", 1, 1, {"ai": "chay", "khu": "dong", "toi_thieu_1": true})])
	Rules.cmd_end_turn(s)
	SimpleAI.play_turn(s)
	t.eq(s.flags.get("thoat_loai", []), ["ton_si_nghi"], "Tôn Sĩ Nghị qua cầu sang bờ đông, rời bản đồ")
	var ev := Rules.cmd_end_turn(s)
	t.check(ev.any(func(e: Dictionary) -> bool: return e["loai"] == "cau_rung"), "qua hết cầu thì vòng sau rung (sớm hơn vòng 3)")
	ev = end_round(s)
	t.check(ev.any(func(e: Dictionary) -> bool: return e["loai"] == "cau_dut"), "rồi đứt vòng kế")
	return true


func test_win_ha_loai(t) -> bool:
	var s := make([q("voi_chien", "tayson", 4, 0), q("hua_the_hanh", "thanh", 5, 0, {"mau": 5}), q("truong_mau", "thanh", 4, 2)],
		{"thang": {"loai": "ha_loai", "quan": ["hua_the_hanh"]}})
	Rules.cmd_attack(s, s.unit_at(Vector2i(4, 0)), s.unit_at(Vector2i(5, 0)))
	t.eq(s.result, "thang", "hạ đủ loại quân trong danh sách thì thắng (còn quân khác cũng được)")
	return true


func test_apply_army(t) -> bool:
	var slots := [[0, 0], [1, 0], [0, 2]]
	var s := make([q("quang_trung", "tayson", 1, 2, {"tuong_chinh": true}), q("linh_giao", "tayson", 0, 0), q("linh_giao", "tayson", 1, 0),
		q("linh_giao", "tayson", 0, 2)], {"quan_mang_theo": {"toi_da": 2, "o": slots}})
	Rules.apply_army(s, [])
	t.eq(s.units_of("tayson").size(), 4, "không có quân mang theo: giữ đội hình mặc định")
	Rules.apply_army(s, [{"id": "voi_chien", "cap": 2, "xp": 300}, {"id": "hoa_mai", "cap": 1, "xp": 120}, {"id": "quan_su", "cap": 0, "xp": 0}])
	var types: Array = s.units_of("tayson").map(func(u: Unit) -> String: return u.type_id)
	t.eq(types.size(), 3, "tướng chính + tối đa 2 quân")
	t.check(types.has("quang_trung") and types.has("voi_chien") and types.has("quan_su"), "giữ một quân sư (thay quân cuối danh sách)")
	t.eq(s.unit_at(Vector2i(0, 0)).level, 2, "giữ cấp")
	t.eq(s.unit_at(Vector2i(0, 0)).hp, 100, "đầy máu")
	return true


func test_unlock_mo_sau(t) -> bool:
	Progress.PROGRESS_PATH = "user://test_tien_trinh_mo.json"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Progress.PROGRESS_PATH))
	Progress.reset_cache()
	var d := Progress.data()
	d["xong"]["m06_ha_hoi"] = {"muc_tieu_phu": [], "vong": 5}
	t.check(Progress.mission_unlocked("m07_khuong_thuong"), "màn 7 mở sau màn 6")
	t.check(Progress.mission_unlocked("m08_ngoc_hoi"), "màn 8 mở sau màn 6, chưa cần màn 7")
	t.check(not Progress.mission_unlocked("m09_cau_phao"), "màn 9 cần thắng cả màn 7 và 8")
	d["xong"]["m08_ngoc_hoi"] = {"muc_tieu_phu": [], "vong": 9}
	t.check(not Progress.mission_unlocked("m09_cau_phao"), "mới thắng màn 8: màn 9 chưa mở")
	d["xong"]["m07_khuong_thuong"] = {"muc_tieu_phu": [], "vong": 7}
	t.check(Progress.mission_unlocked("m09_cau_phao"), "thắng cả hai: màn 9 mở")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Progress.PROGRESS_PATH))
	Progress.PROGRESS_PATH = "user://tien_trinh.json"
	Progress.reset_cache()
	return true
