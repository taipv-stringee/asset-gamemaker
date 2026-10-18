extends RefCounted
## Chông sắt, địa lôi (02 §12), rút lui khi yếu và khu rút lui, mục tiêu phụ "ha_tren_khu" / "khong_mat_truoc_co" (màn 8).

const ROWS := ["......", "......", "......", "......", "&&&&&&"]


static func make(quan: Array, extra: Dictionary = {}) -> BattleState:
	var m := {"id": "test_bay", "ban_do": ROWS, "phe": ["tayson", "thanh"], "quan": quan,
		"gioi_han": {"tayson": 99}, "khu": {"bac": [[0, 0], [1, 0], [2, 0], [3, 0], [4, 0], [5, 0]],
		"dam": [[0, 4], [1, 4], [2, 4], [3, 4], [4, 4], [5, 4]]}}
	m.merge(extra, true)
	var s := BattleState.from_mission(m, 3)
	Rules.start_turn(s)
	return s


static func q(id: String, phe: String, x: int, y: int, more: Dictionary = {}) -> Dictionary:
	var d := {"id": id, "phe": phe, "x": x, "y": y}
	d.merge(more, true)
	return d


func test_chong(t) -> bool:
	var s := make([q("linh_giao", "tayson", 0, 2), q("voi_chien", "tayson", 0, 3)],
		{"vat_the": [{"loai": "chong", "o": [2, 2]}, {"loai": "chong", "o": [2, 3]}]})
	var lg := s.unit_at(Vector2i(0, 2))
	t.check(not Rules.reachable(s, lg).has(Vector2i(3, 2)), "không đi xuyên qua ô chông")
	t.check(Rules.reachable(s, lg).has(Vector2i(2, 2)), "dừng trên ô chông được")
	Rules.cmd_move(s, lg, Vector2i(2, 2))
	t.eq(lg.hp, 85, "lính giáo giẫm chông −15")
	t.check(lg.khoa_hoan_tac, "giẫm bẫy thì không hoàn tác")
	t.eq(s.object_at(Vector2i(2, 2)).get("loai", ""), "chong", "chông không mất")
	var voi := s.unit_at(Vector2i(0, 3))
	Rules.cmd_move(s, voi, Vector2i(2, 3))
	t.eq(voi.hp, 95, "voi −5")
	return true


func test_dia_loi(t) -> bool:
	var mine := {"vat_the": [{"loai": "dia_loi", "o": [2, 2], "phe": "thanh"}]}
	var s := make([q("linh_giao", "tayson", 0, 2), q("truong_mau", "thanh", 5, 2, {"ai": "dung_yen"})], mine)
	var lg := s.unit_at(Vector2i(0, 2))
	t.check(Rules.reachable(s, lg, true).has(Vector2i(4, 2)), "địa lôi ẩn: người chơi thấy đường đi qua")
	var ev := Rules.cmd_move(s, lg, Vector2i(4, 2), true)
	t.eq(lg.pos, Vector2i(2, 2), "giẫm địa lôi: dừng lại")
	t.eq(lg.hp, 70, "−30 máu")
	t.check(s.object_at(Vector2i(2, 2)).is_empty(), "địa lôi mất")
	t.check(ev.any(func(e: Dictionary) -> bool: return e["loai"] == "dia_loi_no"), "sự kiện nổ")
	# Máy tránh địa lôi của phe mình, trừ khi rút lui
	s = make([q("truong_mau", "thanh", 0, 2, {"ai": "tan_cong"})], mine)
	var tm := s.unit_at(Vector2i(0, 2))
	t.check(not Rules.reachable(s, tm).has(Vector2i(2, 2)), "quân Thanh không bước vào địa lôi của mình")
	tm.ai_mode = "rut_lui"
	t.check(Rules.reachable(s, tm).has(Vector2i(2, 2)), "đang rút lui thì giẫm phải")
	return true


func test_quan_su_thay_dia_loi(t) -> bool:
	var s := make([q("quan_su", "tayson", 0, 2)], {"vat_the": [{"loai": "dia_loi", "o": [2, 2], "phe": "thanh"}]})
	var qs := s.unit_at(Vector2i(0, 2))
	t.check(not s.object_at(Vector2i(2, 2)).get("lo", false), "chưa lộ")
	Rules.cmd_move(s, qs, Vector2i(1, 2))
	t.check(s.object_at(Vector2i(2, 2)).get("lo", false), "quân sư đứng kề: lộ")
	var lg_s := make([q("linh_giao", "tayson", 0, 2)], {"vat_the": [{"loai": "dia_loi", "o": [2, 2], "phe": "thanh", "lo": true}]})
	var lg := lg_s.unit_at(Vector2i(0, 2))
	t.check(not Rules.reachable(lg_s, lg, true).has(Vector2i(3, 2)), "địa lôi đã lộ: không đi xuyên qua")
	return true


func test_rut_lui(t) -> bool:
	var s := make([q("hoa_mai", "tayson", 2, 3), q("truong_mau", "thanh", 2, 1, {"rut_khi_yeu": 30, "mau": 60})],
		{"khu_rut_lui": "bac"})
	var tm := s.unit_at(Vector2i(2, 1))
	Rules.cmd_attack(s, s.unit_at(Vector2i(2, 3)), tm)
	t.check(s.units.has(tm) and tm.hp < 30, "còn sống, dưới 30 máu")
	t.eq(tm.ai_mode, "rut_lui", "chuyển sang rút lui")
	var s0 := make([q("voi_chien", "tayson", 2, 2), q("truong_mau", "thanh", 2, 1, {"rut_khi_yeu": 30, "mau": 20})])
	t.check(Rules.forecast(s0, s0.unit_at(Vector2i(2, 2)), Vector2i(2, 2), s0.unit_at(Vector2i(2, 1)))["ti_le_ha"] > 0.0, "đòn đủ hạ thì vẫn hạ")
	Rules.cmd_attack(s0, s0.unit_at(Vector2i(2, 2)), s0.unit_at(Vector2i(2, 1)))
	t.eq(s0.units_of("thanh").size(), 0, "bị hạ, không giữ lại 1 máu")
	Rules.cmd_end_turn(s)
	var ev := SimpleAI.play_turn(s)
	t.check(not s.units.has(tm), "rút tới khu mép bắc thì rời bản đồ")
	t.eq(s.flags.get("rut_khoi", []), ["truong_mau"], "ghi quân đã rút")
	t.check(ev.any(func(e: Dictionary) -> bool: return e["loai"] == "rut_khoi"), "sự kiện rút khỏi")
	return true


func test_objectives_dam_va_moc_thuan(t) -> bool:
	var extra := {"muc_tieu_phu": [{"loai": "ha_tren_khu", "khu": "dam", "n": 1, "ten": "Đầm"},
		{"loai": "khong_mat_truoc_co", "quan": "moc_thuan", "co": "qua_chong", "ten": "Mộc thuẫn"}],
		"thang": {"loai": "co", "co": "xong"}}
	var s := make([q("voi_chien", "tayson", 1, 3), q("truong_mau", "thanh", 1, 4, {"mau": 10})], extra)
	Rules.cmd_attack(s, s.unit_at(Vector2i(1, 3)), s.unit_at(Vector2i(1, 4)))
	var live := Rules.side_objectives_live(s)
	t.eq(live[0]["trang_thai"], "xong", "hạ một quân trên ô đầm")
	t.eq(live[1]["trang_thai"], "dang", "chưa qua chông, chưa mất mộc thuẫn: còn mở")
	var s2 := make([q("moc_thuan", "tayson", 1, 3, {"mau": 5}), q("voi_chien", "thanh", 1, 2)], extra)
	s2.current = 1
	Rules.cmd_attack(s2, s2.unit_at(Vector2i(1, 2)), s2.unit_at(Vector2i(1, 3)))
	t.eq(Rules.side_objectives_live(s2)[1]["trang_thai"], "hong", "mất mộc thuẫn trước khi qua chông: hỏng")
	var s3 := make([q("moc_thuan", "tayson", 1, 3, {"mau": 5}), q("voi_chien", "thanh", 1, 2)], extra)
	var flags: Dictionary = {"qua_chong": true}
	s3.flags["co"] = flags
	s3.current = 1
	Rules.cmd_attack(s3, s3.unit_at(Vector2i(1, 2)), s3.unit_at(Vector2i(1, 3)))
	t.eq(Rules.side_objectives_live(s3)[1]["trang_thai"], "xong", "mất sau khi đã qua chông: không tính")
	return true
