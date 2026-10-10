event_inherited();
y += spd;
if (instance_exists(obj_carp) && obj_carp.y > y) {
    var _dx = clamp(obj_carp.x - x, -0.6, 0.6);
    x += _dx;
    image_angle = 180 + _dx * 20;
}
x = clamp(x, RIVER_L + 12, RIVER_R - 12);
