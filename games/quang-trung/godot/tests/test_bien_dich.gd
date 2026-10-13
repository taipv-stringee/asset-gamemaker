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
