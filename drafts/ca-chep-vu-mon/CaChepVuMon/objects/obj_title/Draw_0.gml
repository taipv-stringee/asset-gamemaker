draw_river(scroll);
draw_sprite(spr_gate, 0, VIEW_W / 2, 150);
draw_sprite(spr_dragon, (timer div 8) mod 6, VIEW_W / 2, 262 + dsin(timer * 3) * 4);
