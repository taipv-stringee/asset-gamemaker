extends RefCounted
## Dữ liệu màn và truyện khớp nhau: màn trong chiến dịch nạp được, mục Sử liệu và phần hội thoại được nhắc tới đều có thật.


func test_campaign_data_consistent(t) -> bool:
	var codex_ids := {}
	for e in Story.codex():
		t.check(not codex_ids.has(e["id"]), "mục Sử liệu không trùng id: " + e["id"])
		codex_ids[e["id"]] = true
		t.check(e.get("nhan", "") in UiKit.LABEL_COLORS, "nhãn hợp lệ: " + e["id"])
	for m in Story.campaign():
		var id: String = m["id"]
		if id == "":
			continue
		var mission := Missions.load_mission(id)
		t.check(not mission.is_empty(), "nạp được màn " + id)
		for c in mission.get("su_lieu", []):
			t.check(codex_ids.has(c), "%s: có mục Sử liệu %s" % [id, c])
		var dlg: String = mission.get("hoi_thoai", "")
		var parts: Array = []
		if mission.get("loai", "") == "chuyen":
			parts = mission.get("canh", [])
			for d in mission.get("sa_ban", {}).get("dao", []):
				t.check(codex_ids.has(d["id"]), "%s: đạo %s có mục Sử liệu" % [id, d["id"]])
		else:
			var s := Missions.new_battle(id, 1)
			t.check(s.width > 0 and not s.units.is_empty(), "dựng được trận " + id)
			parts = ["truoc", "sau_thang"]
			for e in mission.get("su_kien", []):
				for a in e.get("lam", []):
					if a.get("loai", "") == "hoi_thoai":
						parts.append(a["phan"])
		for part in parts:
			var lines := Story.dialogue(dlg, part)
			t.check(not lines.is_empty(), "%s: có hội thoại phần %s" % [id, part])
			for l in lines:
				t.check(String(l["loi"]).length() <= 90, "%s/%s: câu ≤ 90 ký tự" % [id, part])
				t.check(l.get("nhan", "") in UiKit.LABEL_COLORS, "%s/%s: câu có nhãn" % [id, part])
	return true
