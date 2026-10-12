var _end = false;
var _e = instance_place(x, y, obj_enemy);
if (_e != noone && !array_contains(hits, _e)) {
    array_push(hits, _e);
    if (aoe <= 0) enemy_hurt(_e, dmg, direction, knock);
    if (!pierce) _end = true;
}
if (place_meeting(x, y, obj_wall)) _end = true;
if (point_distance(xstart, ystart, x, y) > range) _end = true;

if (_end) {
    if (aoe > 0) {   // cầu lửa: nổ lan
        hurt_enemies_circle(x, y, aoe, dmg, knock);
        spawn_fx(x, y, spr_fx_explosion, 0, 0.8);
        screen_shake(2);
        sfx(snd_explosion, 0.5);
    } else {
        spawn_fx(x, y, spr_fx_hit);
    }
    instance_destroy();
}
