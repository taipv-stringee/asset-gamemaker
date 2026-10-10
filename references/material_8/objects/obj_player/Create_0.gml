
// camera setting here...



#region // code lập trình người chơi, không quan tâm phần này
	// movement var
	xspeed = 0
	yspeed = 0
	base_spd = 4
	dash_spd = 15
	spd = base_spd
	dash = 0
	dash_delay = 60
	tele = 0
	tele_delay = 300
	// animation
	index = 3
	sprite = [
		spr_player_right,
		spr_player_up,
		spr_player_left,
		spr_player_down
	]
	sprite_index = spr_player_down

	// play
	hp = 5
	//weapon
	offsety = -20
	wp_index = 0
	wp_reload = 30
	wp_dir = 0
	wp_dis = 10
	weapon = noone
	gun = instance_create_layer(x,y+offsety,"Instances",obj_weapon)
	dmg_delay = 60
	dmg_timer = dmg_delay
	// state machine
	enum STATE {
		MOVE,
		TAKEDMG
	}

	state = STATE.MOVE
#endregion




























































