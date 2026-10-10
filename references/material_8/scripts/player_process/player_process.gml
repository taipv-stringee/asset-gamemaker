function player_input(){
	right = keyboard_check(ord("D"))
	left = keyboard_check(ord("A"))	
	up = keyboard_check(ord("W"))	
	down = keyboard_check(ord("S"))	
	space = keyboard_check_pressed(vk_space)
	mouse_right = mouse_check_button_pressed(mb_right)
	mouse_left = mouse_check_button_pressed(mb_left)

}


function player_move(_wall){
	
	_xspeed = right - left
	_yspeed = down - up
	// ko sử dụng dis, dir vẫn dc, chỉ dùng để khi đi chéo thì không ăn gian tốc độ
	dir = point_direction(0,0,_xspeed,_yspeed)
	dis = clamp(point_distance(0,0,_xspeed,_yspeed),0,1)
	
	if dash <= 0 {
		if space {
			spd = dash_spd
			dash = dash_delay
		}
		
		
	}else{
		spd += (base_spd - spd)/5	
	}
	
	xspeed = lengthdir_x(dis,dir) * spd
	yspeed =lengthdir_y(dis,dir) * spd
	

	//handle place_meeting
	if place_meeting(x+xspeed,y,_wall){
		while(!place_meeting(x+sign(xspeed),y,_wall)){
			x+= sign(xspeed)	
		}
		xspeed = 0
	}
	
	if place_meeting(x,y+yspeed,_wall){
		while(!place_meeting(x,y+sign(yspeed),_wall)){
			y+= sign(yspeed)	
		}
		yspeed = 0
	}
	
	
	
	x+=xspeed
	y+=yspeed
}

function player_ani(){
	// adjust sprite
	dir = point_direction(x,y-32,mouse_x,mouse_y)
	index = round(dir/90)%4
	sprite_index = sprite[index]
	// adjust image_speed
	if dis == 0{
		image_speed = 0
		image_index = 0
	}else image_speed = 1
	depth = -bbox_bottom
}

function player_takdmg(){
	if place_meeting(x,y,obj_enemy){
		var _ene = instance_place(x,y,obj_enemy)
		hp -= _ene.dmg
		if hp <=0 game_restart()
		state = STATE.TAKEDMG
	}	
	if place_meeting(x,y,obj_bullet_ene3){
		var _ene = instance_place(x,y,obj_enemy)
		hp -= 1
		if hp <=0 game_restart()
		state = STATE.TAKEDMG
	}	
}

function player_camera(){
	
	x_to = x - cam_width/2  // tìm vị trí x của camera
	y_to = y - cam_height/2 // tìm vị trí y của camera

	
	x_cam = x_cam + (x_to - x_cam)/25  // x_cam từ từ tiến tới x_to
	y_cam = y_cam + (y_to - y_cam)/25  // y_cam từ từ tiến tới y_to

	camera_set_view_pos(view_camera[0],x_cam,y_cam) // đặt vị trí camera[0]

}
	