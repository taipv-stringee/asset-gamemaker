life--;
if (place_meeting(x, y, obj_wall) || life <= 0) {
    spawn_fx(x, y, spr_fx_hit);
    instance_destroy();
    exit;
}
if (place_meeting(x, y, obj_player)) {
    if (obj_player.state != PSTATE.DASH) {   // đang lướt thì né được
        player_hurt(dmg, x - hspeed * 4, y - vspeed * 4);
        spawn_fx(x, y, spr_fx_hit);
        instance_destroy();
    }
}
