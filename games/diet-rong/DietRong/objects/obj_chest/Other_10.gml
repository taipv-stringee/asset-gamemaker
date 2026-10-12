/// Đồ trong rương (User Event 0). Rương vàng viết lại sự kiện này.
repeat (coins) {
    var _c = instance_create_depth(x, y + 10, 0, obj_coin);
    _c.vx = random_range(-2.5, 2.5);
    _c.vy = random_range(0.5, 3);
}
if (has_potion) instance_create_depth(x + 10, y + 14, 0, obj_potion_hp);
