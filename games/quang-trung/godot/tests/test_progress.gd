extends RefCounted
## Lưu / tiếp tục trận và ghi tiến trình (06 §7).


func _use_test_files() -> void:
	Progress.PROGRESS_PATH = "user://test_tien_trinh.json"
	Progress.BATTLE_PATH = "user://test_luu_tran.txt"
	Progress.clear_battle()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Progress.PROGRESS_PATH))
	Progress.reset_cache()


func test_save_and_continue(t) -> bool:
	_use_test_files()
	var r := LoiGiai.run("m04_gian_khau", 2, "res://tests/loi_giai/m04_gian_khau.txt")
	var won: BattleState = r["state"]
	# Lưu giữa chừng: chạy lại 3 vòng đầu rồi lưu, đọc lại, so trạng thái.
	var s := Missions.new_battle("m04_gian_khau", 2)
	for i in 3:
		Rules.cmd_end_turn(s)
		SimpleAI.play_turn(s)
		Rules.cmd_end_turn(s)
	Progress.save_battle(s)
	t.check(Progress.has_battle(), "có file lưu")
	var back := Progress.load_battle()
	t.check(back != null, "đọc lại được")
	t.eq(var_to_str(back.to_dict()), var_to_str(s.to_dict()), "trạng thái giống hệt sau khi đọc lại")
	Progress.clear_battle()
	t.check(not Progress.has_battle(), "xóa file lưu")
	# Thắng: ghi sao, mở Sử liệu một lần.
	var opened := Progress.record_win(won)
	t.eq(opened.size(), 3, "mở 3 mục Sử liệu")
	t.eq(Progress.stars("m04_gian_khau"), 3, "3 sao")
	t.eq(Progress.record_win(won).size(), 0, "thắng lại không mở trùng")
	Progress.reset_cache()
	t.eq(Progress.stars("m04_gian_khau"), 3, "đọc lại từ đĩa vẫn 3 sao")
	t.check(Progress.codex_unlocked("song_gian"), "mục sông Gián đã mở")
	for e in Story.codex():
		t.check(e["nhan"] in UiKit.LABEL_COLORS, "mục %s có nhãn hợp lệ" % e["id"])
	for line in Story.dialogue("m04_gian_khau", "truoc") + Story.dialogue("m04_gian_khau", "sau_thang"):
		t.check(line.get("nhan", "") in UiKit.LABEL_COLORS, "câu thoại có nhãn hợp lệ: " + line["loi"].left(20))
		t.check(line["loi"].length() <= 90, "câu thoại ≤ 90 ký tự (05 §4.2): " + line["loi"].left(20))
	Progress.clear_battle()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Progress.PROGRESS_PATH))
	return true
