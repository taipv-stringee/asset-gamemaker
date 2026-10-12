/// Máy trạng thái của quái: IDLE -> WANDER / CHASE -> ATK.
if (flash > 0) flash--;
if (atk_cd > 0) atk_cd--;

// bị đóng băng: đứng im, không gây sát thương
if (freeze_timer > 0) {
    freeze_timer--;
    path_end();
    image_speed = 0;
    exit;
}
image_speed = 1;

// vừa trúng đòn: bật lùi
if (hurt_timer > 0) {
    hurt_timer--;
    if (flying) {
        x += knock_x;
        y += knock_y;
    } else {
        move_collide(knock_x, knock_y);
    }
    knock_x *= 0.75;
    knock_y *= 0.75;
    exit;
}

var _dist = 99999;
if (instance_exists(obj_player) && obj_player.state != PSTATE.DEAD) {
    _dist = point_distance(x, y, obj_player.x, obj_player.y);
}

switch (state) {
    case ESTATE.IDLE:
        sprite_index = sprite[0];
        if (_dist < chase_distance) {
            state = ESTATE.CHASE;
            calc_path_timer = 0;
        } else if (wander_timer-- <= 0) {
            wander_timer = irandom_range(120, 300);
            enemy_start_wander();
        }
        break;

    case ESTATE.WANDER:
        sprite_index = sprite[1];
        if (flying) {
            var _wd = point_direction(x, y, wander_x, wander_y);
            x += lengthdir_x(spd * 0.5, _wd);
            y += lengthdir_y(spd * 0.5, _wd);
            if (point_distance(x, y, wander_x, wander_y) < 4) state = ESTATE.IDLE;
        } else if (path_index == -1) {
            state = ESTATE.IDLE;
        }
        if (_dist < chase_distance) {
            path_end();
            state = ESTATE.CHASE;
            calc_path_timer = 0;
        }
        break;

    case ESTATE.CHASE:
        sprite_index = sprite[2];
        if (_dist > chase_distance * 1.6) {
            path_end();
            state = ESTATE.IDLE;
        } else if (atk_dis > 0 && _dist <= atk_dis && atk_cd <= 0 && enemy_can_see_player()) {
            path_end();
            state = ESTATE.ATK;
            sprite_index = sprite[3];
            image_index = 0;
            atk_done = false;
        } else if (keep_away > 0 && _dist < keep_away) {
            path_end();   // lùi ra xa người chơi
            var _ad = point_direction(obj_player.x, obj_player.y, x, y);
            move_collide(lengthdir_x(spd, _ad), lengthdir_y(spd, _ad));
        } else {
            enemy_chase();
        }
        break;

    case ESTATE.ATK:
        sprite_index = sprite[3];
        if (!atk_done && image_index >= atk_frame) {
            atk_done = true;
            event_user(0);          // đòn đánh riêng của từng loại quái
        }
        if (image_index >= image_number - 1) {
            atk_cd = atk_delay;
            state = ESTATE.CHASE;
            calc_path_timer = 0;
        }
        break;
}

// không đứng chồng lên nhau
var _o = instance_place(x, y, obj_enemy);
if (_o != noone && !flying) {
    var _sd = point_direction(_o.x, _o.y, x, y);
    move_collide(lengthdir_x(0.6, _sd), lengthdir_y(0.6, _sd));
}

if (state != ESTATE.ATK) enemy_face_player();
depth = -bbox_bottom;

// chạm vào người chơi thì gây sát thương
if (contact_dmg > 0 && place_meeting(x, y, obj_player)) player_hurt(contact_dmg, x, y);
