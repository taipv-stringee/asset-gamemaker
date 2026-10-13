extends SceneTree
## Chạy toàn bộ test: godot --headless --path . -s res://tests/run_tests.gd
## Mỗi file tests/test_*.gd là một RefCounted có các hàm test_*(t) -> bool, trả về true ở cuối hàm
## (để phát hiện test bị dừng giữa chừng vì lỗi script). `t` là đối tượng này (dùng t.check / t.eq).

var failures: PackedStringArray = []
var checks := 0
var current := ""


func _init() -> void:
	var files: PackedStringArray = []
	var dir := DirAccess.open("res://tests")
	for f in dir.get_files():
		if f.begins_with("test_") and f.ends_with(".gd"):
			files.append(f)
	files.sort()
	var tests_run := 0
	for f in files:
		var script: GDScript = load("res://tests/" + f)
		if script == null or not script.can_instantiate():
			failures.append("%s: không nạp được (lỗi biên dịch)" % f)
			continue
		var obj: Object = script.new()
		for m in obj.get_method_list():
			var name: String = m["name"]
			if not name.begins_with("test_"):
				continue
			current = "%s::%s" % [f, name]
			var ok: Variant = obj.call(name, self)
			if ok != true:
				failures.append("%s: test dừng giữa chừng (lỗi script) hoặc không trả về true" % current)
			tests_run += 1
	var data_errors := GameData.get_data().errors
	for e in data_errors:
		failures.append("Dữ liệu: " + e)
	print("")
	print("%d test, %d kiểm tra, %d lỗi" % [tests_run, checks, failures.size()])
	for fl in failures:
		print("  FAIL ", fl)
	quit(0 if failures.is_empty() else 1)


func check(cond: bool, msg: String = "") -> void:
	checks += 1
	if not cond:
		failures.append("%s: %s" % [current, msg])


func eq(a: Variant, b: Variant, msg: String = "") -> void:
	checks += 1
	if a != b:
		failures.append("%s: %s (được %s, cần %s)" % [current, msg, str(a), str(b)])
