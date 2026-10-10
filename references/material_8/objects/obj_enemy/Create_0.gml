
// movement var
spd = 3
hp = 5
dmg = 1
image_speed = 0.3
path = path_add()
dir_to_player = 0
//playe style
chase_distance = 200
atk_dis = 15
calc_path_delay = irandom_range(30,60)
calc_path_timer = calc_path_delay
wander_delay = irandom_range(200,400)
wander_timer = wander_delay
dis = 0;
dir = 0
xx=0
yy=0
bullet = noone
step = 0
// state machine
sprite = [
	spr_ene1_idle,
	spr_ene1_chase,
	spr_ene1_chase,
	spr_ene1_chase,
	spr_ene1_death
	]

enum ESTATE {
	IDLE,
	WANDER,
	CHASE,
	ATK,
	DEATH,
}
state = ESTATE.IDLE

function end_atk(_obj){
	if object_exists(_obj)
		instance_create_layer(x,y,"Instances",_obj)
}


































































































