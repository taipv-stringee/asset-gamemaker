class_name Unit
extends RefCounted
## Một quân trên bản đồ. Chỉ chứa dữ liệu; luật nằm ở Rules.

var uid: int = 0
var type_id: String = ""
var faction: String = ""
var pos: Vector2i = Vector2i.ZERO
var hp: int = 100
var xp: int = 0
var level: int = 0

# Trạng thái trong lượt
var moved: bool = false          # đã đi trong lượt này (kể cả đứng yên rồi chọn hành động)
var done: bool = false           # đã hành động xong, xám đến hết lượt
var move_origin: Vector2i = Vector2i.ZERO
var straight_steps: int = 0      # số ô đi thẳng trong lượt (cho Xung phong)

# Trạng thái kéo dài
var chay_turns: int = 0          # số lần "hết lượt của phe mình" còn lại trước khi hết Cháy
var than_trong: bool = false     # Ngô Văn Sở đứng yên lượt trước → +10 thủ
var ngu: bool = false            # đang ngủ (màn đêm)
var keu: bool = false            # bị đánh mà còn sống ở màn đêm → báo động đầu lượt phe nó

# Cờ do kịch bản đặt
var tuong_chinh: bool = false
var toi_thieu_1: bool = false
var rut_khi_yeu: int = 0
var ngoai_gioi_han: bool = false
var duoc: bool = false
var ai_mode: String = "tan_cong"
var ai_params: Dictionary = {}


func data() -> Dictionary:
	return GameData.get_data().unit(type_id)


func has_tag(tag: String) -> bool:
	return data()["the"].has(tag)


func display_name() -> String:
	return data()["ten"]


func is_alive() -> bool:
	return hp > 0


func to_dict() -> Dictionary:
	return {
		"uid": uid, "type_id": type_id, "faction": faction, "x": pos.x, "y": pos.y,
		"hp": hp, "xp": xp, "level": level, "moved": moved, "done": done,
		"chay_turns": chay_turns, "than_trong": than_trong, "ngu": ngu, "keu": keu,
		"tuong_chinh": tuong_chinh, "toi_thieu_1": toi_thieu_1, "rut_khi_yeu": rut_khi_yeu,
		"ngoai_gioi_han": ngoai_gioi_han, "duoc": duoc, "ai_mode": ai_mode, "ai_params": ai_params,
	}


static func from_dict(d: Dictionary) -> Unit:
	var u := Unit.new()
	u.uid = int(d["uid"])
	u.type_id = d["type_id"]
	u.faction = d["faction"]
	u.pos = Vector2i(int(d["x"]), int(d["y"]))
	u.move_origin = u.pos
	u.hp = int(d["hp"])
	u.xp = int(d["xp"])
	u.level = int(d["level"])
	u.moved = d["moved"]
	u.done = d["done"]
	u.chay_turns = int(d["chay_turns"])
	u.than_trong = d["than_trong"]
	u.ngu = d["ngu"]
	u.keu = d["keu"]
	u.tuong_chinh = d["tuong_chinh"]
	u.toi_thieu_1 = d["toi_thieu_1"]
	u.rut_khi_yeu = int(d["rut_khi_yeu"])
	u.ngoai_gioi_han = d["ngoai_gioi_han"]
	u.duoc = d["duoc"]
	u.ai_mode = d["ai_mode"]
	u.ai_params = d["ai_params"]
	return u
