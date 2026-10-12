// bắn tên xương về phía người chơi
if (instance_exists(obj_player)) {
    sfx_at(snd_enemy_shoot, x, y);
    enemy_shoot(spr_bone_arrow, 3.5, 1, point_direction(x, y, obj_player.x, obj_player.y));
}
