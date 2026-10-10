event_inherited();
// Khúc gỗ trôi ngang, chạm bờ thì quay đầu.
x += hsp;
if (bbox_left < RIVER_L || bbox_right > RIVER_R) hsp = -hsp;
