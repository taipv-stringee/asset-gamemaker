/// @description Insert description here
// You can write your code in this editor

draw_text(100,100,dash)
// draw health
for (var _i=0; _i<hp; _i++){
	draw_sprite(spr_heart,0,70+_i*30,50)
}


draw_set_color(c_white)

for (var _i = 0; _i < array_length(global.weapon_list);_i++){
	draw_sprite_ext (global.weapon_list[_i].bullet_sprite,0,50,_i*80+90,0.8,0.8,0,c_white,1)
	draw_text(70,_i*80+80," X " + string(global.weapon_list[_i].quantity))
}
























































