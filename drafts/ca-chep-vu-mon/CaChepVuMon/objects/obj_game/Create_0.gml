/// Điều khiển màn chơi: cuộn sông, sinh chướng ngại, điểm, thắng / thua.
game_init();
depth = 1000;               // vẽ nền nước dưới mọi thứ
state = "play";             // play -> gate -> win | over
state_timer = 0;
distance = 0;
pearls = 0;
final_score = 0;
new_record = false;
spawn_timer = 90;
decor_timer = 0;
global.scroll = 1.4;

instance_create_depth(VIEW_W / 2, VIEW_H - 70, 0, obj_carp);

calc_score = function(_won) {
    var _s = pearls * 10 + floor(distance / 10);
    if (_won) _s += 500 + (instance_exists(obj_carp) ? obj_carp.hp * 100 : 0);
    return _s;
};

game_over = function() {
    if (state == "over" || state == "win") return;
    state = "over";
    state_timer = 0;
    final_score = calc_score(false);
    new_record = save_best(final_score);
};

win_game = function(_x, _y) {
    if (state == "win") return;
    final_score = calc_score(true);
    new_record = save_best(final_score);
    state = "win";
    state_timer = 0;
    global.scroll = 0;
    instance_create_depth(_x, _y, -20, obj_dragon);
    repeat (3) {
        instance_create_depth(random_range(40, VIEW_W - 40), random_range(20, 200), -30, obj_cloud);
    }
};
