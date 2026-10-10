// bình năng lượng: hồi 50 năng lượng
global.mana = min(global.mana_max, global.mana + 50);
spawn_text(x, y - 10, "+50 năng lượng", c_aqua);
spawn_fx(x, y - 6, spr_fx_sparkle, 0, 1.5);
