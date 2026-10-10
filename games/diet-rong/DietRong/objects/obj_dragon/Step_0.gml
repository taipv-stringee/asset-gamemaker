/// Không gọi event_inherited(): trùm dùng máy trạng thái riêng.
if (flash > 0) flash--;
if (!instance_exists(obj_player)) exit;
var _p = obj_player;

if (!awake) {
    if (point_distance(x, y, _p.x, _p.y) < 230) {
        awake = true;
        global.boss = id;
        show_msg("Hỏa Long thức giấc!", 150);
        screen_shake(8);
    }
    exit;
}

t++;
var _rage = (hp < hp_max * 0.5);           // dưới nửa máu: đánh nhanh hơn, có thêm chiêu gọi dơi
var _pd = point_direction(x, y - 6, _p.x, _p.y);

switch (mode) {
    case 0:   // bay lượn phía trên người chơi
        sprite_index = spr_dragon_fly;
        var _tx = clamp(_p.x + sin(t / 50) * 110, 80, room_width - 80);
        var _ty = clamp(_p.y - 110, 80, room_height - 80);
        x += (_tx - x) * 0.02;
        y += (_ty - y) * 0.02;
        timer--;
        if (timer <= 0) {
            if (_rage) mode = choose(1, 2, 3);
            else mode = choose(1, 2);
            if (mode == 1) timer = 70;
            else if (mode == 2) timer = 100;
            else timer = 40;
            shots = 0;
        }
        break;

    case 1:   // phun lửa hình nón về phía người chơi
        sprite_index = spr_dragon_breath;
        if (timer mod 4 == 0) {
            var _b = enemy_shoot(spr_dragon_fire, 3.2, 1, _pd + random_range(-14, 14));
            _b.y = y - 6;
        }
        timer--;
        if (timer <= 0) {
            mode = 0;
            timer = _rage ? 70 : 110;
        }
        break;

    case 2:   // vòng cầu lửa toả ra mọi hướng (3 đợt)
        sprite_index = spr_dragon_fly;
        if (timer mod 30 == 0) {
            var _n = _rage ? 16 : 12;
            for (var _i = 0; _i < _n; _i++) {
                enemy_shoot(spr_dragon_fire, 2.2, 1, _i * 360 / _n + shots * 15);
            }
            shots++;
            screen_shake(3);
        }
        timer--;
        if (timer <= 0) {
            mode = 0;
            timer = _rage ? 70 : 110;
        }
        break;

    case 3:   // gọi đàn dơi
        sprite_index = spr_dragon_breath;
        if (timer == 20) {
            repeat (2) {
                if (instance_number(obj_bat) < 5) {
                    var _bat = instance_create_depth(x + random_range(-40, 40), y + 20, 0, obj_bat);
                    _bat.state = ESTATE.CHASE;
                    _bat.chase_distance = 600;
                }
            }
            show_msg("Hỏa Long gọi đàn dơi!", 90);
        }
        timer--;
        if (timer <= 0) {
            mode = 0;
            timer = 90;
        }
        break;
}

depth = -bbox_bottom;
if (place_meeting(x, y, _p)) player_hurt(contact_dmg, x, y);
