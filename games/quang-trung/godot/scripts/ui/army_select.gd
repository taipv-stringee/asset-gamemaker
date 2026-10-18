class_name ArmySelect
extends Control
## Chọn quân mang sang màn sau (04 §Màn 9): danh sách quân còn sống cuối màn 8, chạm để chọn / bỏ, tối đa `toi_da`.
## Mặc định chọn sẵn theo cấp giảm dần (thứ tự danh sách đã xếp sẵn trong tiến trình).

signal chosen(army: Array)
signal back

var _army: Array = []
var _picked: Array[bool] = []
var _limit := 10
var _buttons: Array[Button] = []
var _count: Label
var _go: Button


func setup(army: Array, limit: int) -> ArmySelect:
	_army = army
	_limit = limit
	set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(UiKit.backdrop())
	var col := UiKit.scroll_column(self, 16, 64)
	col.add_child(UiKit.wrap_label("Chọn quân sang Thăng Long", UiKit.FS_TITLE, UiKit.C_GOLD_LIGHT, true))
	col.add_child(UiKit.wrap_label("Quân còn sống sau trận Ngọc Hồi. Quang Trung luôn đi; chọn thêm tối đa %d quân. Quân đi giữ cấp, đầy máu." % _limit,
		UiKit.FS_SMALL, UiKit.C_MUTED))
	_count = UiKit.label("", UiKit.FS_SMALL, UiKit.C_GOLD, true)
	for i in _army.size():
		_picked.append(i < _limit)
		var b := UiKit.list_button("", _toggle.bind(i), UiKit.FS_BODY)
		b.custom_minimum_size = Vector2(0, 44)
		_buttons.append(b)
		col.add_child(b)
	var bar := UiKit.bottom_bar(self)
	bar.add_child(_count)   # ở thanh dưới: cuộn danh sách không mất (kiểm thử lần 8)
	bar.add_child(UiKit.button("Quay lại", func() -> void: back.emit(), UiKit.FS_BUTTON, 70))
	_go = UiKit.button("Vào trận", _confirm, UiKit.FS_BUTTON, 80)
	bar.add_child(_go)
	_refresh()
	return self


func _toggle(i: int) -> void:
	if not _picked[i] and _picked.count(true) >= _limit:
		return
	_picked[i] = not _picked[i]
	_refresh()


func _refresh() -> void:
	var data := GameData.get_data()
	for i in _army.size():
		var a: Dictionary = _army[i]
		var cap := int(a.get("cap", 0))
		_buttons[i].text = "%s %s%s" % ["✓" if _picked[i] else "  ", data.unit(a["id"])["ten"], ("  · cấp %d" % cap) if cap > 0 else ""]
	_count.text = "Chọn %d/%d" % [_picked.count(true), _limit]


func _confirm() -> void:
	var out: Array = []
	for i in _army.size():
		if _picked[i]:
			out.append(_army[i])
	chosen.emit(out)
