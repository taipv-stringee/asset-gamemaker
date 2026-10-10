/// @description Insert description here
// You can write your code in this editor


draw_self()
// draw loading
#region
	draw_set_color(c_green)
	var _hp_long = 30
	var _offsetx = x - 10
	draw_rectangle(_offsetx,y,_offsetx+_hp_long,y+10,false)

	draw_set_color(c_red)
	draw_rectangle(_offsetx,y,_offsetx+_hp_long*(wp_reload/weapon.reload),y+10,false)

#endregion
draw_set_color(c_green)
if room == rm_main1 {
	draw_text(64,256,"WASD as moving")
	draw_text(64,456,"Aware of bullet")
	draw_text(451,256,"Left click to shoot")
	draw_text(451,456,"Right click to change weapon")
}






































































































