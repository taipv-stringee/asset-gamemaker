// đâm dao: lao tới một chút, trúng nếu người chơi ở gần
move_collide(image_xscale * 4, 0);
if (instance_exists(obj_player) && point_distance(x, y, obj_player.x, obj_player.y) < 30) {
    player_hurt(1, x, y);
}
