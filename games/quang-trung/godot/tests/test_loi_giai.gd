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
		var mission := f.get_basename()
		for sd in [1, 2, 3]:
			var r := LoiGiai.run(mission, sd, DIR + f)
			var s: BattleState = r["state"]
			t.eq(r["loi"], "", "%s seed %d: lời giải chạy hết" % [mission, sd])
			t.eq(s.result, "thang", "%s seed %d: thắng" % [mission, sd])
			for o in Rules.side_objectives(s):
				t.check(o["dat"], "%s seed %d: đạt \"%s\"" % [mission, sd, o["ten"]])
	return true
