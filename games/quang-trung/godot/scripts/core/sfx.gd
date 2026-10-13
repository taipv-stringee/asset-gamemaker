class_name Sfx
extends RefCounted
## Gọi âm thanh qua autoload AmThanh nếu có (không có khi chạy test headless bằng -s).


static func _node() -> Node:
	var tree := Engine.get_main_loop() as SceneTree
	return tree.root.get_node_or_null("AmThanh") if tree != null else null


static func play(name: String, volume_db := 0.0) -> void:
	var n := _node()
	if n != null:
		n.play_sfx(name, volume_db)


static func music(name: String, loop := true) -> void:
	var n := _node()
	if n != null:
		n.play_music(name, loop)


static func stop_music() -> void:
	var n := _node()
	if n != null:
		n.stop_music()
