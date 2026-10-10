// đập chùy xuống đất: sát thương 2 trong vòng tròn trước mặt
var _cx = x + image_xscale * 14;
var _cy = y + 10;
screen_shake(5);
spawn_fx(_cx, _cy, spr_fx_dust, 0, 2.5);
if (instance_exists(obj_player) && point_distance(_cx, _cy, obj_player.x, obj_player.y) < telegraph_r + 8) {
    player_hurt(2, _cx, _cy);
}
