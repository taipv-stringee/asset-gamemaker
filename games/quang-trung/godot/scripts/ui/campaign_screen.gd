class_name CampaignScreen
extends Control
## Danh sách màn của chiến dịch (bản đồ chiến dịch thật làm ở M3). Màn chưa làm thì mờ.

signal mission_chosen(id: String)
signal back


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(UiKit.backdrop())
	var col := UiKit.scroll_column(self, 16, 60)
	var title := UiKit.label("Chiến dịch", UiKit.FS_TITLE, UiKit.C_GOLD_LIGHT, true)
	col.add_child(title)
	col.add_child(UiKit.wrap_label("Từ Phú Xuân ra Thăng Long, cuối năm Mậu Thân – đầu năm Kỷ Dậu.", UiKit.FS_SMALL, UiKit.C_MUTED))
	for m in Story.campaign():
		var id: String = m["id"]
		var text := "Màn %s · %s" % [m["so"], m["ten"]]
		var open := Progress.mission_unlocked(id)
		if id != "" and Progress.is_won(id):
			var n := Progress.stars(id)
			var total := (Missions.load_mission(id).get("muc_tieu_phu", []) as Array).size()
			text += ("\n" + "★".repeat(n) + "☆".repeat(maxi(total - n, 0))) if total > 0 else "\nĐã xem"
		elif id != "" and not open:
			text += "\nThắng màn trước để mở"
		elif id == "":
			text += "\n(đang làm)"
		var b := UiKit.list_button(text, func() -> void: mission_chosen.emit(id))
		b.disabled = not open
		col.add_child(b)
	col.add_child(UiKit.label("Luyện tập", UiKit.FS_HEAD, UiKit.C_GOLD, true))
	col.add_child(UiKit.list_button("Trận thử luật (ban ngày)", func() -> void: mission_chosen.emit("m_thu")))
	UiKit.bottom_bar(self).add_child(UiKit.button("Quay lại", func() -> void: back.emit(), UiKit.FS_BUTTON, 100))
