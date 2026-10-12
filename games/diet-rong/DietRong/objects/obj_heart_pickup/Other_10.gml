// trái tim: tăng 1 máu tối đa (tối đa 10) và hồi đầy
global.hp_max = min(10, global.hp_max + 1);
global.hp = global.hp_max;
show_msg("Tăng máu tối đa!", 120);
sfx(snd_heart);
spawn_fx(x, y - 6, spr_fx_heal, 0, 1.5);
