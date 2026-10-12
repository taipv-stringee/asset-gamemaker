if (obj_game.state != "play" && obj_game.state != "gate") exit;

var _ix = (keyboard_check(vk_right) || keyboard_check(ord("D"))) - (keyboard_check(vk_left) || keyboard_check(ord("A")));
var _iy = (keyboard_check(vk_down) || keyboard_check(ord("S"))) - (keyboard_check(vk_up) || keyboard_check(ord("W")));

// --- lướt nhanh
if ((keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_shift)) && dash_timer <= 0 && energy >= dash_cost) {
    energy -= dash_cost;
    dash_timer = 22;
    invuln = max(invuln, 22);
    var _dx = _ix, _dy = _iy;
    if (_dx == 0 && _dy == 0) _dy = -1;
    var _len = point_distance(0, 0, _dx, _dy);
    hsp = _dx / _len * 6.5;
    vsp = _dy / _len * 6.5;
    spawn_fx(x, y + 12, spr_splash, 5);
}

// --- di chuyển
if (dash_timer > 0) {
    dash_timer -= 1;
    hsp *= 0.94;
    vsp *= 0.94;
} else {
    hsp += _ix * accel;
    vsp += _iy * accel;
    if (_ix == 0) hsp *= fric;
    if (_iy == 0) vsp *= fric;
    hsp = clamp(hsp, -max_spd, max_spd);
    vsp = clamp(vsp, -max_spd, max_spd);
}

// Dòng nước đẩy cá trôi xuống.
y += global.scroll * 0.35;

// --- Vũ Môn: thác nước đẩy lùi, chỉ lướt mới vượt qua được
if (instance_exists(obj_gate)) {
    var _g = obj_gate;
    var _fall_top = _g.y + 64;
    var _fall_bot = _g.y + 128;
    if (y > _fall_top && y < _fall_bot + 8 && dash_timer <= 0) {
        vsp = max(vsp, 0) + 0.9;
        if (irandom(6) == 0) spawn_fx(x + random_range(-8, 8), y - 10, spr_bubble, -6);
    }
    // Hai cột cổng chặn hai bên.
    if (y < _fall_top && abs(x - _g.x) >= 56) y = _fall_top;
    // Lọt qua cổng => hóa rồng.
    if (y < _g.y + 60 && abs(x - _g.x) < 56) {
        obj_game.win_game(x, y);
        instance_destroy();
        exit;
    }
}

// --- xoáy nước hút cá vào tâm
var _w = instance_nearest(x, y, obj_whirlpool);
if (_w != noone && dash_timer <= 0) {
    var _d = point_distance(x, y, _w.x, _w.y);
    if (_d < 60) {
        var _pull = (1 - _d / 60) * 1.5;
        var _wdir = point_direction(x, y, _w.x, _w.y);
        x += lengthdir_x(_pull, _wdir);
        y += lengthdir_y(_pull, _wdir);
        if (_d < 12) take_hit(_w.x, _w.y + 1);
    }
}

x += hsp;
y += vsp;
x = clamp(x, RIVER_L + 10, RIVER_R - 10);
y = clamp(y, 16, VIEW_H - 16);

// --- va chạm
var _h = instance_place(x, y, obj_hazard);
if (_h != noone) take_hit(_h.x, _h.y);
if (!instance_exists(id)) exit;

var _p = instance_place(x, y, obj_pickup);
if (_p != noone) {
    switch (_p.kind) {
        case "pearl":  obj_game.pearls += 1; break;
        case "energy": energy = min(1, energy + 0.5); break;
        case "shield": shield = true; break;
        case "heart":  hp = min(hp_max, hp + 1); break;
    }
    spawn_fx(_p.x, _p.y, spr_sparkle);
    instance_destroy(_p);
}

// --- hồi năng lượng, bộ đếm
energy = min(1, energy + (obj_game.state == "gate" ? 0.004 : 0.0012));
if (invuln > 0) invuln -= 1;
if (blink > 0) blink -= 1;
if (hurt_timer > 0) hurt_timer -= 1;

bubble_timer += 1;
if (bubble_timer >= 18) {
    bubble_timer = 0;
    spawn_fx(x + random_range(-4, 4), y + 14, spr_bubble, 5);
}

// --- hình ảnh
if (hurt_timer > 0) sprite_index = spr_carp_hurt;
else if (dash_timer > 0) sprite_index = spr_carp_dash;
else sprite_index = spr_carp_swim;
image_angle = clamp(-hsp * 7, -25, 25);
