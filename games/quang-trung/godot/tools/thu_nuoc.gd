extends SceneTree
## Chạy một lời giải viết sẵn, in bản đồ sau mỗi vòng (để thiết kế / kiểm tra màn). Cú pháp lệnh: tests/loi_giai.gd.
## godot --headless --path . -s res://tools/thu_nuoc.gd -- --man=m04_gian_khau --lenh=res://tests/loi_giai/m04_gian_khau.txt --seed=1

func _init() -> void:
	var args := {}
	for a in OS.get_cmdline_user_args():
		var kv: PackedStringArray = a.trim_prefix("--").split("=")
		args[kv[0]] = kv[1] if kv.size() > 1 else ""
	var carry := {}
	for c in String(args.get("co", "")).split(",", false):
		carry[c] = true   # --co=trinh_sat_thoat: chạy như có hệ quả từ màn trước
	var r := LoiGiai.run(args.get("man", "m04_gian_khau"), int(args.get("seed", "1")), args.get("lenh", ""), true, carry)
	var s: BattleState = r["state"]
	if r["loi"] != "":
		print("!! ", r["loi"])
	print("KẾT QUẢ: ", s.result, " vòng ", s.vong, " báo động ", s.flags["bao_dong"], " ", Rules.side_objectives(s))
	quit()
