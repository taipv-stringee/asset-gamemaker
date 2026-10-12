/// Các hàm chiến đấu dùng chung: di chuyển có va chạm, gây sát thương, hiệu ứng.

/// Di chuyển instance hiện tại (dx, dy) nhưng không đi xuyên tường (obj_wall và con của nó).
/// Giống player_move của material_8: tiến từng pixel tới sát tường thì dừng.
function move_collide(_dx, _dy) {
    if (place_meeting(x + _dx, y, obj_wall)) {
        var _sx = sign(_dx);
        repeat (ceil(abs(_dx))) {
            if (place_meeting(x + _sx, y, obj_wall)) break;
            x += _sx;
        }
    } else {
        x += _dx;
    }
    if (place_meeting(x, y + _dy, obj_wall)) {
        var _sy = sign(_dy);
        repeat (ceil(abs(_dy))) {
            if (place_meeting(x, y + _sy, obj_wall)) break;
            y += _sy;
        }
    } else {
        y += _dy;
    }
}

/// Hiệu ứng chạy hết animation rồi tự huỷ.
function spawn_fx(_x, _y, _sprite, _angle = 0, _scale = 1) {
    var _fx = instance_create_depth(_x, _y, -10000, obj_fx);
    _fx.sprite_index = _sprite;
    _fx.image_index = 0;
    _fx.image_angle = _angle;
    _fx.image_xscale = _scale;
    _fx.image_yscale = _scale;
    return _fx;
}

/// Chữ bay lên (số sát thương, +1 vàng...).
function spawn_text(_x, _y, _text, _col = c_white) {
    var _t = instance_create_depth(_x, _y, -10001, obj_float_text);
    _t.text = _text;
    _t.col = _col;
    return _t;
}

/// Rung màn hình (giá trị lớn = rung mạnh).
function screen_shake(_amount) {
    global.shake = max(global.shake, _amount);
}

/// Hiện thông báo giữa màn hình trong vài giây.
function show_msg(_text, _frames = 150) {
    global.msg = _text;
    global.msg_timer = _frames;
}

/// Gây sát thương cho một con quái. _dir: hướng đòn đánh (để đẩy lùi).
function enemy_hurt(_enemy, _dmg, _dir, _knock) {
    with (_enemy) {
        hp -= _dmg;
        flash = 6;
        spawn_text(x, bbox_top - 4, string(_dmg), c_yellow);
        spawn_fx(x + irandom_range(-4, 4), y + irandom_range(-4, 4), spr_fx_hit);
        sfx(snd_hit, 0.5, heavy ? 0.7 : 1);
        if (!heavy) {
            knock_x = lengthdir_x(_knock, _dir);
            knock_y = lengthdir_y(_knock, _dir);
            hurt_timer = 8;
            path_end();
        }
        if (state == ESTATE.IDLE || state == ESTATE.WANDER) state = ESTATE.CHASE;
        if (hp <= 0) enemy_die();
    }
}

/// Gây sát thương cho mọi con quái trong vòng tròn (dùng cho nổ, lốc xoáy, vòng băng).
/// Trả về số quái trúng đòn.
function hurt_enemies_circle(_x, _y, _r, _dmg, _knock, _freeze = 0) {
    var _n = 0;
    with (obj_enemy) {
        if (point_distance(_x, _y, x, y) <= _r + (bbox_right - bbox_left) / 2) {
            if (_freeze > 0 && !heavy) freeze_timer = _freeze;
            enemy_hurt(id, _dmg, point_direction(_x, _y, x, y), _knock);
            _n++;
        }
    }
    return _n;
}

/// Phá đạn của quái trong vòng tròn (khiên / lốc xoáy / vòng băng).
function destroy_eproj_circle(_x, _y, _r) {
    with (obj_eproj) {
        if (point_distance(_x, _y, x, y) <= _r) {
            spawn_fx(x, y, spr_fx_hit);
            instance_destroy();
        }
    }
}

/// Gây sát thương cho người chơi (bỏ qua nếu đang bất tử).
function player_hurt(_dmg, _from_x, _from_y) {
    with (obj_player) {
        if (inv_timer > 0 || state == PSTATE.DEAD) exit;
        global.hp -= _dmg;
        inv_timer = 60;
        flash = 8;
        screen_shake(4);
        sfx(snd_player_hurt, 0.8);
        spawn_text(x, y - 20, "-" + string(_dmg), c_red);
        var _d = point_direction(_from_x, _from_y, x, y);
        knock_x = lengthdir_x(4, _d);
        knock_y = lengthdir_y(4, _d);
        state = PSTATE.HURT;
        hurt_timer = 10;
        if (global.hp <= 0) {
            global.hp = 0;
            state = PSTATE.DEAD;
            dead_timer = 0;
            instance_destroy(gun);
            gun = noone;
            spawn_fx(x, y, spr_fx_poof, 0, 1.5);
            sfx(snd_player_die);
            music_stop();
        }
    }
}
