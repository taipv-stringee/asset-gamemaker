

function chase_player(){
	var _dis =  distance_to_object(obj_player)
	// ask the distance if can chase
	if _dis < chase_distance and _dis >= atk_dis{
		
		//its time to find the path
		if calc_path_timer-- <= 0 {
			
			calc_path_timer = calc_path_delay
			
			var _p = mp_grid_path(global.mp_grid, path, x, y, obj_player.x, obj_player.y, choose(0, 1))
			if _p
			{
				path_start(path, spd, path_action_stop, 0)
			}
		}
		
	}
	else{
		path_end()	
	}

}

function ene_animate_leftright(){
	dir_to_player = point_direction(x,y,obj_player.x,obj_player.y)
	if dir_to_player > 90 and dir_to_player <270  image_xscale = -1
	else image_xscale = 1	
}

function ene_take_dmg(){
	if place_meeting(x,y,obj_bullet){
	var _bul_list = ds_list_create()
	instance_place_list(x,y,obj_bullet,_bul_list,true)
	for(var _i = 0; _i < ds_list_size(_bul_list);_i++){
		var _bul = ds_list_find_value(_bul_list,_i)
		hp -= _bul.dmg
		_bul.des = true
		
	}
	ds_list_clear(_bul_list)
	if hp <= 0 {
		image_index = 0
		image_speed = 0.1
		state = ESTATE.DEATH
	}
}

}