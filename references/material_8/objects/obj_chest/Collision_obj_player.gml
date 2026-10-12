


if taken == false {
	var _weapon_index =  array_find_index(global.weapon_list ,wp_to_find)
	if _weapon_index == -1
		array_push(global.weapon_list ,weapon) // insert weapon ì dont have
	else{
		global.weapon_list[_weapon_index].quantity += 5
	}
	image_index = 1
	alarm[0] = 45
	//making animation
	
	item = instance_create_layer(x,y,"Instances",obj_fake_item)
	with item{
		sprite_index = 	other.weapon.sprite
	}
	taken = true
}



































































