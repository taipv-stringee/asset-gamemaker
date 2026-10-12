if (instance_exists(obj_player) && obj_player.state != PSTATE.DASH && place_meeting(x, y, obj_player)) {
    player_hurt(1, x + 16, y + 16);
}
