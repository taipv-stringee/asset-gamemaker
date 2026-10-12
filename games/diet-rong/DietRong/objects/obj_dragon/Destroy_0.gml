/// Rồng bị hạ: nổ liên hoàn, rơi nhiều vàng, mở cổng về nhà.
global.boss = noone;
screen_shake(12);
sfx(snd_explosion);
sfx(snd_dragon_roar, 1, 0.7);
music_play(mus_dungeon);
for (var _i = 0; _i < 6; _i++) {
    spawn_fx(x + random_range(-30, 30), y + random_range(-30, 30), spr_fx_explosion, 0, 1.5);
}
repeat (30) {
    var _c = instance_create_depth(x, y, 0, obj_coin);
    _c.vx = random_range(-4, 4);
    _c.vy = random_range(-4, 4);
}
show_msg("Bạn đã đánh bại Hỏa Long! Hãy vào cổng sáng.", 300);
