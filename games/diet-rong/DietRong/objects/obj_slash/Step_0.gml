// đi theo người chơi
if (instance_exists(owner)) {
    x = owner.x + lengthdir_x(10, image_angle);
    y = owner.y + 3 + lengthdir_y(10, image_angle);
}
var _cx = x - lengthdir_x(10, image_angle);
var _cy = y - lengthdir_y(10, image_angle);
var _ang = image_angle;
var _half = arc / 2;

with (obj_enemy) {
    var _rad = (bbox_right - bbox_left) / 2;
    var _d = point_distance(_cx, _cy, x, y);
    var _a = abs(angle_difference(point_direction(_cx, _cy, x, y), _ang));
    if (_d <= other.range + _rad && (_a <= _half || _d < _rad + 6) && !array_contains(other.hits, id)) {
        array_push(other.hits, id);
        enemy_hurt(id, other.dmg, point_direction(_cx, _cy, x, y), other.knock);
    }
}
// chém trúng đạn của quái thì phá luôn (đỡ tên!)
with (obj_eproj) {
    if (point_distance(_cx, _cy, x, y) <= other.range + 8
        && abs(angle_difference(point_direction(_cx, _cy, x, y), _ang)) <= _half) {
        spawn_fx(x, y, spr_fx_hit);
        instance_destroy();
    }
}
