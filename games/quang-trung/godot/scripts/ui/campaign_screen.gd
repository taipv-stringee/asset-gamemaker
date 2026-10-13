class_name CampaignScreen
extends Control
## Danh sách màn của chiến dịch (bản đồ chiến dịch thật làm ở M3). Màn chưa làm thì mờ.

signal mission_chosen(id: String)
signal back


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(UiKit.backdrop())
	var col := UiKit.scroll_column(self, 16, 60)
	var title := UiKit.label("Chiến dịch", 18, UiKit.C_GOLD_LIGHT, true)
	col.add_child(title)
	col.add_child(UiKit.wrap_label("Từ Phú Xuân ra Thăng Long, cuối năm Mậu Thân – đầu năm Kỷ Dậu.", 10, UiKit.C_MUTED))
	for m in Story.campaign():
		var id: String = m["id"]
		var text := "Màn %s · %s" % [m["so"], m["ten"]]
		if id != "" and Progress.is_won(id):
			# Sao đặt trước tên để không bị cắt mất khi tên dài.
			text = "%s %s" % ["★".repeat(Progress.stars(id)) + "☆".repeat(3 - Progress.stars(id)), text]
		elif id == "":
			text += "  (đang làm)"
		var b := UiKit.button(text, func() -> void: mission_chosen.emit(id), 11)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		b.disabled = id == ""
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		col.add_child(b)
	col.add_child(UiKit.label("Luyện tập", 12, UiKit.C_GOLD, true))
	var practice := UiKit.button("Trận thử luật (ban ngày)", func() -> void: mission_chosen.emit("m_thu"), 11)
	practice.alignment = HORIZONTAL_ALIGNMENT_LEFT
	practice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_child(practice)
	UiKit.bottom_bar(self).add_child(UiKit.button("Quay lại", func() -> void: back.emit(), 12, 100))
