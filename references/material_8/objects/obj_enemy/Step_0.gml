

switch state {
	case ESTATE.IDLE: 
		sprite_index = sprite[0]
		mask_index = sprite[0]
		ene_take_dmg()
		chase_player()
		if wander_timer-- <=0{
			wander_delay = irandom_range(200,400)
			wander_timer = wander_delay
			dis = 64*irandom_range(1,5)
			dir = random(360)
			xx = lengthdir_x(dis,dir)
			yy = lengthdir_y(dis,dir)
			while(place_meeting(x+xx,y+yy,obj_wall)){
				dis = 64*random_range(1,5)
				dir = random(360)
				xx = lengthdir_x(dis,dir)
				yy = lengthdir_y(dis,dir)
			}
			
			state = ESTATE.WANDER	
		}
		if path_index != -1 state = ESTATE.CHASE
	break
	
	case ESTATE.CHASE:
		sprite_index = sprite[2]
		ene_take_dmg()

		chase_player()
		if path_index == -1 {
			if distance_to_object(obj_player) <= atk_dis {
				image_index = 0
				state = ESTATE.ATK
			}else{
				state = ESTATE.IDLE	
			}
		}
	break
	
	case ESTATE.ATK:
		sprite_index = sprite[3]
		mask_index = sprite[3]
		ene_take_dmg()
		if image_index >= sprite_get_number(sprite_index) - 1 {
			end_atk(bullet)
			state = ESTATE.IDLE
		}
		
	break
	
	case ESTATE.WANDER:
		sprite_index = sprite[1]
		ene_take_dmg()
		if step++ == 1 {
			var _p = mp_grid_path(global.mp_grid, path, x, y, x+xx, y+yy, choose(0, 1))
			if _p
			{
				path_start(path, 1, path_action_stop, 0)
			}
		}
		if distance_to_object(obj_player) < chase_distance state = ESTATE.CHASE
		if path_index == -1 and step >1{
			step = 0
			state = ESTATE.IDLE	
		}
		
		
		
	break
	
	case ESTATE.DEATH:
		path_end()
		sprite_index = sprite[4]
		if image_index >= sprite_get_number(sprite_index) - 1 instance_destroy()
	break
}


// animation left right
ene_animate_leftright()
mask_index = sprite[0]

//handle being shoot























































































