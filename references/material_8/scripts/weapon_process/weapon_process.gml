

function WeaponInit (_spr,_spd,_num,_quantity,_range,_dis,_reload,_bullet,_dmg) constructor{
	sprite = _spr
	spd  = _spd
	num = _num
	quantity = _quantity
	range = _range
	dis = _dis
	reload = _reload
	bullet_sprite = _bullet
	dmg = _dmg
	
}

global.wp1 = new WeaponInit(spr_weapon1,14,1,10,0,700,15,spr_bullet1,10)
global.wp2 = new WeaponInit(spr_weapon2,7,5,5,30,300,30,spr_bullet2,4)
global.wp3 = new WeaponInit(spr_weapon3,6,5,5,45,400,20,spr_bullet3,2)
global.weapon_list = [global.wp1]
function weapon_ani(){
	weapon = global.weapon_list[wp_index]

	gun.sprite_index = weapon.sprite // weapon sprite
	wp_dir = point_direction(x,y+offsety,mouse_x,mouse_y)
	gun.image_angle = wp_dir - 45
	gun.x = x +lengthdir_x(wp_dis,wp_dir)
	gun.y = y+offsety +lengthdir_y(wp_dis,wp_dir)

	gun.depth = -gun.bbox_bottom	
}

function weapon_switch(){
	// get to next weapon, but only in range
}
