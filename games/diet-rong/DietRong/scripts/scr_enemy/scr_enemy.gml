/// Xử lý quái vật: đuổi theo bằng mp_grid (như material_8), đi lang thang, tấn công, chết.

/// Tìm đường tới người chơi; tính lại đường sau mỗi calc_path_delay frame.
function enemy_chase() {
    if (!instance_exists(obj_player)) exit;
    var _p = obj_player;
    if (flying) {   // dơi bay thẳng, không cần tìm đường, lượn hình sin
        var _d = point_direction(x, y, _p.x, _p.y);
        wobble += 0.15;
        x += lengthdir_x(spd, _d) + lengthdir_x(sin(wobble) * 1.2, _d + 90);
        y += lengthdir_y(spd, _d) + lengthdir_y(sin(wobble) * 1.2, _d + 90);
        exit;
    }
    if (calc_path_timer-- <= 0) {
        calc_path_timer = calc_path_delay;
        if (mp_grid_path(global.mp_grid, path, x, y, _p.x, _p.y, true)) {
            path_start(path, spd, path_action_stop, false);
        }
    }
}

/// Chọn một điểm ngẫu nhiên gần đó rồi đi tới (trạng thái WANDER).
function enemy_start_wander() {
    var _tries = 10;
    while (_tries-- > 0) {
        var _tx = x + irandom_range(-3, 3) * TS;
        var _ty = y + irandom_range(-3, 3) * TS;
        if (flying || mp_grid_path(global.mp_grid, path, x, y, _tx, _ty, true)) {
            wander_x = _tx;
            wander_y = _ty;
            if (!flying) path_start(path, spd * 0.5, path_action_stop, false);
            state = ESTATE.WANDER;
            return;
        }
    }
}

/// Quái nhìn về phía người chơi (hình vẽ quay phải, lật khi người chơi ở bên trái).
function enemy_face_player() {
    if (!instance_exists(obj_player) || !can_flip) exit;
    image_xscale = (obj_player.x < x) ? -1 : 1;
}

/// Không có tường chắn giữa quái và người chơi?
function enemy_can_see_player() {
    if (!instance_exists(obj_player)) return false;
    return collision_line(x, y, obj_player.x, obj_player.y, obj_wall, false, true) == noone;
}

/// Quái chết: khói, rơi vàng / bình máu, cộng điểm.
function enemy_die() {
    path_end();
    global.kills++;
    sfx(snd_enemy_die, 0.6);
    spawn_fx(x, y, spr_fx_poof, 0, 1 + heavy * 0.8);
    repeat (coin_drop) {
        var _c = instance_create_depth(x, y + 4, 0, obj_coin);
        _c.vx = random_range(-2, 2);
        _c.vy = random_range(-2.5, -0.5);
    }
    if (random(1) < potion_chance) {
        instance_create_depth(x, y + 4, 0, choose(obj_potion_hp, obj_potion_mp));
    }
    if (drop_key) {
        instance_create_depth(x, y + 4, 0, obj_key);
        show_msg("Quái rơi ra chìa khóa!", 120);
    }
    instance_destroy();
}

/// Bắn một viên đạn của quái về phía (_tx, _ty).
function enemy_shoot(_sprite, _spd, _dmg, _dir) {
    var _b = instance_create_depth(x, y, -9000, obj_eproj);
    _b.sprite_index = _sprite;
    _b.direction = _dir;
    _b.image_angle = _dir;
    _b.speed = _spd;
    _b.dmg = _dmg;
    return _b;
}
