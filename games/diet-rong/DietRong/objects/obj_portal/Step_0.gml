active = !instance_exists(obj_dragon);
visible = active;
if (active && instance_exists(obj_player) && place_meeting(x, y, obj_player)) {
    var _next = level_next();
    if (_next == rm_end) save_best_time();
    sfx(snd_portal);
    room_goto(_next);
}
