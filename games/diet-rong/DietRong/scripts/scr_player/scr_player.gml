/// Xử lý người chơi: điều khiển, di chuyển, đánh, kỹ năng, camera.
/// Cấu trúc giống player_process của material_8.

function player_input() {
    right = keyboard_check(ord("D")) || keyboard_check(vk_right);
    left  = keyboard_check(ord("A")) || keyboard_check(vk_left);
    up    = keyboard_check(ord("W")) || keyboard_check(vk_up);
    down  = keyboard_check(ord("S")) || keyboard_check(vk_down);
    key_dash   = keyboard_check_pressed(vk_space);
    key_attack = mouse_check_button(mb_left);
    key_skill  = mouse_check_button_pressed(mb_right) || keyboard_check_pressed(ord("E"));
    key_switch = keyboard_check_pressed(ord("Q")) || mouse_wheel_up() || mouse_wheel_down();
    key_1 = keyboard_check_pressed(ord("1"));
    key_2 = keyboard_check_pressed(ord("2"));
}

function player_move() {
    var _xs = right - left;
    var _ys = down - up;
    // đi chéo không nhanh hơn đi thẳng
    dir = point_direction(0, 0, _xs, _ys);
    dis = clamp(point_distance(0, 0, _xs, _ys), 0, 1);
    xspeed = lengthdir_x(dis, dir) * spd;
    yspeed = lengthdir_y(dis, dir) * spd;
    move_collide(xspeed, yspeed);
}

/// Chọn hình theo hướng chuột (0 phải, 1 lên, 2 trái, 3 xuống) như material_8.
function player_animate() {
    var _index = round(aim_dir / 90) mod 4;
    sprite_index = sprite[_index];
    if (dis == 0 && state != PSTATE.DASH) {
        image_speed = 0;
        image_index = 0;
    } else {
        image_speed = (state == PSTATE.DASH) ? 2 : 1;
    }
    depth = -bbox_bottom;
}

/// Vũ khí cầm tay xoay theo chuột.
function player_weapon_update() {
    if (!instance_exists(gun)) exit;
    var _wp = global.weapons[global.wp_index];
    gun.sprite_index = _wp.sprite;
    gun.image_angle = aim_dir;
    gun.image_yscale = (aim_dir > 90 && aim_dir < 270) ? -1 : 1;   // không bị lộn ngược
    var _d = 8 - gun.kick;
    gun.x = x + lengthdir_x(_d, aim_dir);
    gun.y = y + 3 + lengthdir_y(_d, aim_dir) * 0.6;
    gun.kick *= 0.7;
    // chĩa lên thì vũ khí nằm sau lưng, chĩa xuống thì ở trước
    gun.depth = (aim_dir > 20 && aim_dir < 160) ? depth + 1 : depth - 1;
}

/// Đánh thường bằng vũ khí đang cầm.
function player_attack() {
    var _wp = global.weapons[global.wp_index];
    if (reload > 0 || !key_attack) exit;
    reload = _wp.reload;
    if (instance_exists(gun)) gun.kick = 4;
    if (_wp.snd != -1) sfx(_wp.snd, 0.7);
    var _ox = x + lengthdir_x(12, aim_dir);
    var _oy = y + 3 + lengthdir_y(12, aim_dir);

    if (_wp.kind == "melee") {
        var _s = instance_create_depth(_ox, _oy, depth - 2, obj_slash);
        _s.sprite_index = _wp.proj;
        _s.image_angle = aim_dir;
        _s.dmg = _wp.dmg;
        _s.range = _wp.range;
        _s.arc = _wp.arc;
        _s.knock = _wp.knock;
        _s.owner = id;
    } else {
        for (var _i = 0; _i < _wp.num; _i++) {
            var _a = aim_dir;
            if (_wp.num > 1) _a += lerp(-_wp.spread, _wp.spread, _i / (_wp.num - 1));
            else _a += random_range(-_wp.spread, _wp.spread);
            shoot_projectile(_ox, _oy, _a, _wp.proj, _wp.spd, _wp.dmg, _wp.range, _wp.pierce, _wp.aoe, _wp.knock);
        }
    }
}

/// Tạo một viên đạn của người chơi.
function shoot_projectile(_x, _y, _dir, _sprite, _spd, _dmg, _range, _pierce, _aoe, _knock) {
    var _b = instance_create_depth(_x, _y, -9000, obj_proj);
    _b.sprite_index = _sprite;
    _b.direction = _dir;
    _b.image_angle = _dir;
    _b.speed = _spd;
    _b.dmg = _dmg;
    _b.range = _range;
    _b.pierce = _pierce;
    _b.aoe = _aoe;
    _b.knock = _knock;
    return _b;
}

/// Kỹ năng đặc biệt (chuột phải hoặc E), tốn năng lượng.
function player_skill() {
    var _h = global.heroes[global.hero];
    if (!key_skill || skill_timer > 0) exit;
    if (global.mana < _h.skill_cost) {
        show_msg("Không đủ năng lượng!", 60);
        sfx(snd_no_mana, 0.6);
        exit;
    }
    global.mana -= _h.skill_cost;
    skill_timer = _h.skill_cd;

    switch (global.hero) {
        case HERO.KNIGHT:      // Lốc xoáy kiếm: xoay 3 vòng quanh mình
            var _sp = instance_create_depth(x, y + 2, depth - 2, obj_spin);
            _sp.owner = id;
            inv_timer = max(inv_timer, 36);
            sfx(snd_spin);
            break;
        case HERO.ARCHER:      // Mưa tên: 9 mũi xuyên thấu toả hình quạt
            for (var _i = 0; _i < 9; _i++) {
                var _a = aim_dir + lerp(-40, 40, _i / 8);
                shoot_projectile(x, y + 2, _a, spr_arrow, 7, 2, 260, true, 0, 3);
            }
            screen_shake(2);
            sfx(snd_arrow_rain);
            break;
        case HERO.WIZARD:      // Vòng băng: đóng băng quái xung quanh
            instance_create_depth(x, y + 2, -9500, obj_nova);
            screen_shake(4);
            sfx(snd_ice);
            break;
    }
}

/// Lướt nhanh (SPACE): bất tử trong lúc lướt.
function player_try_dash() {
    if (!key_dash || dash_cd > 0 || dis == 0) exit;
    state = PSTATE.DASH;
    dash_timer = 10;
    dash_cd = 45;
    dash_dir = dir;
    inv_timer = max(inv_timer, 12);
    sfx(snd_dash, 0.6);
}

/// Đổi vũ khí (Q / con lăn chuột / phím 1, 2).
function player_switch_weapon() {
    var _n = array_length(global.weapons);
    var _old = global.wp_index;
    if (key_switch) global.wp_index = (global.wp_index + 1) mod _n;
    if (key_1) global.wp_index = 0;
    if (key_2 && _n > 1) global.wp_index = 1;
    if (_old != global.wp_index) {
        reload = 10;
        show_msg(global.weapons[global.wp_index].name, 60);
        sfx(snd_menu_move);
    }
}

/// Camera đi theo người chơi, không ra ngoài room, có rung khi trúng đòn.
function player_camera(_snap) {
    var _cam = view_camera[0];
    var _tx = clamp(x - VIEW_W / 2, 0, room_width - VIEW_W);
    var _ty = clamp(y - VIEW_H / 2, 0, room_height - VIEW_H);
    if (_snap) {
        cam_x = _tx;
        cam_y = _ty;
    } else {
        cam_x += (_tx - cam_x) / 8;      // từ từ tiến tới vị trí mới
        cam_y += (_ty - cam_y) / 8;
    }
    var _sx = random_range(-global.shake, global.shake);
    var _sy = random_range(-global.shake, global.shake);
    camera_set_view_pos(_cam, round(cam_x + _sx), round(cam_y + _sy));
}
