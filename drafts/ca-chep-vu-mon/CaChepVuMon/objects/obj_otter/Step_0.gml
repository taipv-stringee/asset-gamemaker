event_inherited();
x += hsp;
y += vsp;
image_angle = point_direction(0, 0, hsp, vsp + global.scroll) - 90;
if (x < -40 || x > VIEW_W + 40) instance_destroy();
