if (partner == noone) {
    with (obj_teleport) {
        if (id != other.id) other.partner = id;
    }
}
if (partner != noone && instance_exists(obj_player) && obj_player.tele_cd <= 0
    && point_distance(x, y, obj_player.x, obj_player.y + 8) < 12) {
    spawn_fx(obj_player.x, obj_player.y, spr_fx_sparkle, 0, 2);
    obj_player.x = partner.x;
    obj_player.y = partner.y - 8;
    obj_player.tele_cd = 30;
    sfx(snd_teleport);
    spawn_fx(partner.x, partner.y - 8, spr_fx_sparkle, 0, 2);
}
