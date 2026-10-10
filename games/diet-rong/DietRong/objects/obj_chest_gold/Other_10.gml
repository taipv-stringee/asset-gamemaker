/// Rương tím: chứa vũ khí thứ hai của nhân vật (như obj_chest_wp của material_8).
var _w = global.heroes[global.hero].weapons[1];
var _has = false;
for (var _i = 0; _i < array_length(global.weapons); _i++) {
    if (global.weapons[_i] == _w) _has = true;
}
if (!_has) {
    array_push(global.weapons, _w);
    global.wp_index = array_length(global.weapons) - 1;
    show_msg("Nhận được " + _w.name + "!  (Q để đổi vũ khí)", 240);
    var _f = instance_create_depth(x, y - 10, -9999, obj_fake_item);
    _f.sprite_index = _w.sprite;
} else {
    instance_create_depth(x, y + 14, 0, obj_heart_pickup);
}
