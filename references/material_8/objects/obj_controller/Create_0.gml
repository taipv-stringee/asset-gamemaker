
#macro TS	64

w_num =ceil(room_width/TS)
h_num =ceil(room_height/TS)
global.tile_wall = layer_tilemap_get_id("lay_ts_wall")
// create wall
for (var _i =0; _i < w_num; _i++){
	for (var _j = 0; _j < h_num; _j++){
		var _grd = tilemap_get(global.tile_wall,_i,_j)
		if _grd != 0{
			instance_create_layer(_i*TS,_j*TS,"ins_wall",obj_wall)	
		}
	}
}
//create map grid
global.mp_grid = mp_grid_create(0,0,w_num,h_num,TS,TS)
mp_grid_add_instances(global.mp_grid,obj_wall,false)








































































































