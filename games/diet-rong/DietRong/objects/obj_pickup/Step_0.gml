// văng ra rồi chậm dần (không bay vào tường)
if (abs(vx) + abs(vy) > 0.05) {
    move_collide(vx, vy);
    vx *= 0.85;
    vy *= 0.85;
}
bob += 0.08;
if (instance_exists(obj_player) && obj_player.state != PSTATE.DEAD) {
    var _d = point_distance(x, y, obj_player.x, obj_player.y + 6);
    if (magnet > 0 && _d < magnet) {
        var _a = point_direction(x, y, obj_player.x, obj_player.y + 6);
        x += lengthdir_x(3, _a);
        y += lengthdir_y(3, _a);
    }
    if (_d < 12) {
        event_user(0);      // hiệu quả riêng của từng vật phẩm
        instance_destroy();
    }
}
depth = -bbox_bottom;
