gpu_set_blendmode(bm_add);
var _r = 26 + sin(current_time / 120 + x) * 2;
draw_circle_colour(x, y - 6, _r, make_colour_rgb(90, 50, 10), c_black, false);
gpu_set_blendmode(bm_normal);
draw_self();
