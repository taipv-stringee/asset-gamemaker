extends RefCounted
## Mọi script trong scripts/ phải biên dịch được. Test luật không nạp các script giao diện (battle.gd, ui/…),
## nên một lỗi cú pháp ở đó trước đây chỉ lộ ra khi mở game (13/10/2026: lỗi suy kiểu làm game treo màn đen).


func _scripts(dir: String, out: Array[String]) -> void:
	for f in DirAccess.get_files_at(dir):
		if f.ends_with(".gd"):
			out.append(dir.path_join(f))
	for d in DirAccess.get_directories_at(dir):
		_scripts(dir.path_join(d), out)


func test_all_scripts_compile(t) -> bool:
	var files: Array[String] = []
	_scripts("res://scripts", files)
	t.check(files.size() >= 15, "tìm thấy các script (%d)" % files.size())
	for f in files:
		var s: GDScript = load(f)
		t.check(s != null and s.can_instantiate(), "biên dịch được: " + f)
	return true


## tests/ bị loại khỏi bản xuất (export_presets.cfg), nên script game không được gọi class_name khai báo trong tests/:
## test headless vẫn qua nhưng APK báo lỗi biên dịch lúc mở (kiểm thử M3 lần 4, LoiGiai trong main.gd).
func test_scripts_do_not_use_test_classes(t) -> bool:
	var names: Array[String] = []
	for f in DirAccess.get_files_at("res://tests"):
		if f.ends_with(".gd"):
			var m := RegEx.create_from_string("(?m)^class_name\\s+(\\w+)").search(FileAccess.get_file_as_string("res://tests/" + f))
			if m != null:
				names.append(m.get_string(1))
	t.check(names.has("LoiGiai"), "tìm thấy class_name trong tests/")
	var files: Array[String] = []
	_scripts("res://scripts", files)
	for f in files:
		var src := FileAccess.get_file_as_string(f)
		for n in names:
			t.check(not RegEx.create_from_string("\\b%s\\b" % n).search(src), "%s không dùng %s (chỉ có trong tests/)" % [f, n])
	return true
