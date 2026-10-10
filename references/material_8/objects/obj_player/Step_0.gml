
// camera setting here ...




#region // xử lý của player, không cần quan tâm
	player_input()
	dash--
	switch state {
		case STATE.MOVE:
			player_move([global.tile_wall])
			player_ani()
			player_takdmg()
		break
	
		case STATE.TAKEDMG:
			player_move([global.tile_wall])
			if dmg_timer-- <= 0{
				dmg_timer = dmg_delay
				state = STATE.MOVE
			}
		break
	}




	// weapon adjust
	if array_length(global.weapon_list) > 0 {
		//weapon animation
		weapon_ani()

		//switch
		if mouse_right {
			wp_index = ++wp_index % array_length(global.weapon_list)
		}
	
		//handle shooting
		if wp_reload-- <=0 and mouse_left and weapon.quantity > 0   {
			wp_reload = weapon.reload
			weapon.quantity --
			for (var _i = 0; _i < weapon.num; _i++){
				var _disx = x +lengthdir_x(32,wp_dir)
				var _disy = y + offsety +lengthdir_y(32,wp_dir)

				var _bul = instance_create_layer(_disx,_disy,"Instances",obj_bullet)
				with _bul{
					sprite_index = other.weapon.bullet_sprite
					speed = other.weapon.spd
					direction = other.wp_dir + random_range(-other.weapon.range,other.weapon.range)
					dis = other.weapon.dis
					dmg = other.weapon.dmg
				}
			}
		}
		if wp_reload <= -1 wp_reload = -1
	}

	// moving room
	if place_meeting(x,y,obj_gate){
		if room == rm_main1{
			x = 4292
			y = 1996
			room_goto(rm_main2)
		}
		if room == rm_main2{
			x = 128
			y = 128
			room_goto(rm_main3)
		}
	}

	// teleport
	if tele-- <= 0 {
		if place_meeting(x,y,obj_gate1){
			x = obj_gate2.x+32
			y = obj_gate2.y
			tele = tele_delay
		}
		if place_meeting(x,y,obj_gate2){
			x = obj_gate1.x+32
			y = obj_gate1.y
			tele = tele_delay
		}
	}

#endregion

	





























































