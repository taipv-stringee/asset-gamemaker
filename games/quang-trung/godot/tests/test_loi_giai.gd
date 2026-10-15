extends RefCounted
## Mỗi màn có một lời giải mẫu trong tests/loi_giai/<màn>.txt: chạy trên luật thật (máy chơi phe địch) với 3 seed,
## phải thắng và đạt mọi mục tiêu phụ — bảo đảm màn thắng được và mục tiêu phụ không bất khả.

const DIR := "res://tests/loi_giai/"


func test_all_solutions(t) -> bool:
	var files := DirAccess.get_files_at(DIR)
	t.check(files.size() >= 2, "có lời giải mẫu")
	for f in files:
		if not f.ends_with(".txt"):
			continue
		# <màn>__<cờ>.txt: lời giải cho biến thể có hệ quả từ màn trước (vd. m06_ha_hoi__trinh_sat_thoat: đồn đã thức).
		var parts := f.get_basename().split("__")
		var mission := parts[0]
		var carry := {}
		if parts.size() > 1:
			carry[parts[1]] = true
		for sd in [1, 2, 3]:
			var r := LoiGiai.run(mission, sd, DIR + f, false, carry)
			var s: BattleState = r["state"]
			t.eq(r["loi"], "", "%s seed %d: lời giải chạy hết" % [mission, sd])
			t.eq(s.result, "thang", "%s seed %d: thắng" % [mission, sd])
			for o in Rules.side_objectives(s):
				t.check(o["dat"], "%s seed %d: đạt \"%s\"" % [mission, sd, o["ten"]])
	return true
