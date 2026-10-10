/// Cá chép do người chơi điều khiển.
hsp = 0;
vsp = 0;
accel = 0.35;
max_spd = 2.4;
fric = 0.82;

hp = 3;
hp_max = 5;
energy = 1;          // 0..1
dash_cost = 0.34;
dash_timer = 0;
invuln = 0;          // khung hình còn bất tử
blink = 0;           // nhấp nháy sau khi bị đánh
hurt_timer = 0;
shield = false;
bubble_timer = 0;

take_hit = function(_from_x, _from_y) {
    if (invuln > 0) return;
    spawn_fx(x, y, spr_splash);
    if (shield) {
        shield = false;
        invuln = 60;
        return;
    }
    hp -= 1;
    invuln = 90;
    blink = 90;
    hurt_timer = 24;
    var _dir = point_direction(_from_x, _from_y, x, y);
    hsp = lengthdir_x(4, _dir);
    vsp = lengthdir_y(4, _dir) + 1;
    if (hp <= 0) {
        repeat (3) spawn_fx(x + random_range(-10, 10), y + random_range(-10, 10), spr_splash);
        obj_game.game_over();
        instance_destroy();
    }
};
