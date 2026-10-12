/// Sinh chướng ngại vật, kẻ địch và vật phẩm phía trên màn hình.

/// _items: mảng [giá_trị, trọng_số]. Trả về một giá_trị, trọng số càng lớn càng hay ra.
function choose_weighted(_items) {
    var _sum = 0;
    for (var _i = 0; _i < array_length(_items); _i++) _sum += _items[_i][1];
    var _r = random(_sum);
    for (var _k = 0; _k < array_length(_items); _k++) {
        _r -= _items[_k][1];
        if (_r < 0) return _items[_k][0];
    }
    return _items[0][0];
}

/// Tìm một vị trí x chưa bị vật khác chiếm ở hàng y. _half = nửa bề rộng vật.
function find_free_x(_y, _half) {
    var _x = VIEW_W / 2;
    repeat (6) {
        _x = random_range(RIVER_L + _half + 4, RIVER_R - _half - 4);
        if (collision_rectangle(_x - _half - 16, _y - 48, _x + _half + 16, _y + 48, obj_scroller, false, true) == noone) break;
    }
    return _x;
}

/// _t: tiến độ 0..1. Càng gần Vũ Môn càng nhiều kẻ địch khó.
function spawn_wave(_t) {
    var _kind = choose_weighted([
        ["rock_small", 3],
        ["rock_large", 2],
        ["log",        2],
        ["pike",       1 + 2 * _t],
        ["snake",      _t > 0.15 ? 2 : 0],
        ["otter",      _t > 0.35 ? 1.5 : 0],
        ["whirlpool",  _t > 0.25 ? 1.2 : 0],
        ["pearls",     3],
        ["energy",     1.2],
        ["shield",     0.4],
        ["heart",      0.25],
    ]);

    switch (_kind) {
        case "rock_small": instance_create_depth(find_free_x(-32, 16), -32, 10, obj_rock_small); break;
        case "rock_large": instance_create_depth(find_free_x(-48, 32), -48, 10, obj_rock_large); break;
        case "log":        instance_create_depth(find_free_x(-32, 48), -32, 10, obj_log); break;
        case "pike":       instance_create_depth(find_free_x(-32, 16), -32, 8, obj_pike); break;
        case "snake":      instance_create_depth(find_free_x(-32, 50), -32, 8, obj_snake); break;
        case "whirlpool":  instance_create_depth(find_free_x(-48, 32), -48, 15, obj_whirlpool); break;
        case "energy":     instance_create_depth(find_free_x(-24, 12), -24, 9, obj_energy); break;
        case "shield":     instance_create_depth(find_free_x(-24, 12), -24, 9, obj_shield_item); break;
        case "heart":      instance_create_depth(find_free_x(-24, 12), -24, 9, obj_heart_item); break;

        case "pearls":
            var _px = find_free_x(-60, 12);
            var _n = irandom_range(3, 5);
            for (var _i = 0; _i < _n; _i++) {
                instance_create_depth(_px, -24 - _i * 28, 9, obj_pearl);
            }
            break;

        case "otter":
            // Rái cá lao ra từ một bên bờ, chéo xuống lòng sông.
            var _left = choose(true, false);
            var _o = instance_create_depth(_left ? RIVER_L - 8 : RIVER_R + 8, random_range(-24, 40), 8, obj_otter);
            _o.hsp = _left ? 1.7 : -1.7;
            _o.vsp = 0.6;
            break;
    }
}
