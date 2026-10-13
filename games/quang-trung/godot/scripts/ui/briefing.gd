class_name Briefing
extends Control
## Giới thiệu màn (docs/06 §4): ngày âm + dương lịch, địa danh, bản đồ nhỏ, mục tiêu, một đoạn lịch sử có nhãn nguồn.

signal start_pressed
signal back

const MINI := 5   # điểm ảnh mỗi ô trên bản đồ nhỏ
const MINI_COLORS := {
	"co": Color(0.36, 0.52, 0.27), "duong": Color(0.62, 0.5, 0.33), "de": Color(0.5, 0.45, 0.32),
	"ruong": Color(0.45, 0.6, 0.35), "vuon": Color(0.3, 0.48, 0.24), "rung_tre": Color(0.18, 0.36, 0.18),
	"doi": Color(0.5, 0.5, 0.3), "nui": Color(0.45, 0.45, 0.48), "song": Color(0.2, 0.36, 0.62),
	"song_can": Color(0.35, 0.52, 0.7), "cau": Color(0.55, 0.4, 0.25), "cau_phao": Color(0.55, 0.4, 0.25),
	"dam": Color(0.3, 0.42, 0.4), "lang": Color(0.75, 0.6, 0.35), "doanh": Color(0.6, 0.5, 0.4),
	"doanh_chay": Color(0.3, 0.25, 0.22), "luy": Color(0.55, 0.42, 0.3), "don": Color(0.85, 0.75, 0.3),
	"thanh": Color(0.9, 0.85, 0.5),
}

var _mission: Dictionary


func setup(mission: Dictionary) -> Briefing:
	_mission = mission
	set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(UiKit.backdrop())
	var col := UiKit.scroll_column(self, 16, 60)
	var so_v: Variant = mission.get("so", "")
	var so := UiKit.label("Màn %s" % (str(int(so_v)) if typeof(so_v) == TYPE_FLOAT else str(so_v)), 11, UiKit.C_MUTED, true)
	col.add_child(so)
	col.add_child(UiKit.wrap_label(mission.get("ten", ""), 17, UiKit.C_GOLD_LIGHT, true))
	if mission.has("ngay"):
		col.add_child(UiKit.wrap_label(mission["ngay"], 10, UiKit.C_PAPER))
	if mission.has("dia_danh"):
		col.add_child(UiKit.wrap_label(mission["dia_danh"], 10, UiKit.C_MUTED))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	col.add_child(row)
	var mini := Control.new()
	var rows: Array = mission.get("ban_do", [])
	var w: int = String(rows[0]).length() if not rows.is_empty() else 0
	mini.custom_minimum_size = Vector2(w * MINI + 4, rows.size() * MINI + 4)
	mini.draw.connect(_draw_mini.bind(mini))
	row.add_child(mini)
	var hist := VBoxContainer.new()
	hist.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(hist)
	hist.add_child(UiKit.wrap_label(mission.get("gioi_thieu", ""), 10, UiKit.C_PAPER))
	if mission.has("nhan_gioi_thieu"):
		hist.add_child(UiKit.source_tag(mission["nhan_gioi_thieu"]))
	col.add_child(_heading("Mục tiêu"))
	col.add_child(UiKit.wrap_label("• " + mission.get("muc_tieu_chinh", ""), 11, Color.WHITE))
	if mission.has("dieu_kien_thua"):
		col.add_child(UiKit.wrap_label("Thua: " + mission["dieu_kien_thua"], 10, Color(1, 0.7, 0.6)))
	var side: Array = mission.get("muc_tieu_phu", [])
	if not side.is_empty():
		col.add_child(_heading("Mục tiêu phụ"))
		var best: Array = Progress.data()["xong"].get(mission.get("id", ""), {}).get("muc_tieu_phu", [])
		for i in side.size():
			var done: bool = i < best.size() and best[i]
			col.add_child(UiKit.wrap_label(("★ " if done else "☆ ") + side[i].get("ten", ""), 11, UiKit.C_GOLD_LIGHT if done else Color.WHITE))
	if Rules.is_dark(_fake_state()):
		col.add_child(_heading("Đánh đêm"))
		col.add_child(UiKit.wrap_label("Chỉ thấy quân địch trong %d ô quanh quân ta hoặc ở vùng sáng. Đánh một quân mà không hạ được, nó sẽ kêu: đầu lượt sau, quân quanh nó thức dậy." % int(mission.get("tam_nhin", 0)), 10, UiKit.C_PAPER))
	var bar := UiKit.bottom_bar(self)
	bar.add_child(UiKit.button("Quay lại", func() -> void: back.emit(), 12, 90))
	bar.add_child(UiKit.button("Vào trận", func() -> void: start_pressed.emit(), 13, 120))
	return self


func _fake_state() -> BattleState:
	var s := BattleState.new()
	s.tam_nhin = int(_mission.get("tam_nhin", 0))
	return s


func _heading(text: String) -> Label:
	return UiKit.label(text, 12, UiKit.C_GOLD, true)


func _draw_mini(c: Control) -> void:
	var rows: Array = _mission.get("ban_do", [])
	var data := GameData.get_data()
	c.draw_rect(Rect2(Vector2.ZERO, c.custom_minimum_size), UiKit.C_GOLD, false, 1.0)
	var owners: Dictionary = _mission.get("chu_o", {})
	for y in rows.size():
		var row: String = rows[y]
		for x in row.length():
			var tid: String = data.terrain_by_char.get(row[x], "co")
			var col: Color = MINI_COLORS.get(tid, Color.GRAY)
			var own: String = owners.get("%d,%d" % [x, y], "")
			if own == "tayson":
				col = Color(0.85, 0.2, 0.2)
			elif own != "":
				col = Color(0.75, 0.6, 0.25) if own == "le" else Color(0.3, 0.45, 0.8)
			c.draw_rect(Rect2(Vector2(2 + x * MINI, 2 + y * MINI), Vector2(MINI, MINI)), col)
