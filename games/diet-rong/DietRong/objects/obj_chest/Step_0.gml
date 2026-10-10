if (!opened && instance_exists(obj_player) && point_distance(x, y, obj_player.x, obj_player.y) < 24) {
    opened = true;
    image_index = 1;
    spawn_fx(x, y - 8, spr_fx_sparkle, 0, 2);
    event_user(0);
}
