// nền trời đêm có sao
draw_set_colour(make_colour_rgb(18, 16, 34));
draw_rectangle(0, 0, VIEW_W, VIEW_H, false);
random_set_seed(7);
for (var _i = 0; _i < 60; _i++) {
    var _sx = random(VIEW_W);
    var _sy = random(VIEW_H);
    draw_set_alpha(0.4 + 0.4 * sin(t / 30 + _i));
    draw_set_colour(c_white);
    draw_point(_sx, _sy);
}
randomize();
draw_set_alpha(1);
// rồng bay ở góc
draw_sprite_ext(spr_dragon_fly, (t div 8) mod 6, VIEW_W - 40, 30 + sin(t / 40) * 4, 0.6, 0.6, 0, c_white, 0.5);
draw_sprite_ext(spr_dragon_fly, (t div 8) mod 6, 40, 30 + cos(t / 40) * 4, -0.6, 0.6, 0, c_white, 0.5);

// tiêu đề
text_align(fa_center, fa_top);
draw_set_font(global.font_big);
draw_text_outlined(VIEW_W / 2, 6, "TRUYỀN THUYẾT DIỆT RỒNG", c_yellow, make_colour_rgb(126, 22, 36));
draw_set_font(global.font_small);
draw_text_outlined(VIEW_W / 2, 36, "Chọn anh hùng của bạn", c_silver);

// 3 thẻ nhân vật
for (var _i = 0; _i < 3; _i++) {
    var _h = global.heroes[_i];
    var _x1 = 12 + _i * (card_w + 6);
    var _y1 = card_y;
    var _cx = _x1 + card_w / 2;
    var _on = (_i == sel);
    draw_panel(_x1, _y1, _x1 + card_w, _y1 + card_h, _on ? 0.95 : 0.6);
    if (_on) {
        draw_set_colour(c_yellow);
        draw_rectangle(_x1 + 1, _y1 + 1, _x1 + card_w - 1, _y1 + card_h - 1, true);
        draw_set_colour(c_white);
    }
    var _frame = _on ? (t div 8) mod 4 : 0;
    draw_sprite_ext(_h.sprites[3], _frame, _cx, _y1 + 34 + (_on ? sin(t / 10) : 0), 2, 2, 0, _on ? c_white : c_gray, 1);
    draw_sprite_ext(_h.weapons[0].sprite, 0, _cx + 26, _y1 + 40, 1, 1, 45, _on ? c_white : c_gray, 1);

    text_align(fa_center, fa_top);
    draw_set_font(global.font_mid);
    draw_text_outlined(_cx, _y1 + 64, _h.name, _on ? c_yellow : c_silver);
    draw_set_font(global.font_small);
    // máu
    for (var _k = 0; _k < _h.hp; _k++) {
        draw_sprite_ext(spr_ui_heart, 0, _cx - _h.hp * 5 + _k * 10, _y1 + 86, 0.6, 0.6, 0, c_white, 1);
    }
    draw_text_outlined(_cx, _y1 + 96, "Vũ khí: " + _h.weapons[0].name, c_white);
    draw_text_outlined(_cx, _y1 + 108, "Chiêu: " + _h.skill, c_aqua);
    draw_text_ext(_cx, _y1 + 122, _h.desc, 11, card_w - 10);
    var _best = global.best_time[_i];
    if (_best > 0) draw_text_outlined(_cx, _y1 + card_h + 2, "Kỷ lục: " + time_string(_best), c_lime);
}

// hướng dẫn
text_align(fa_center, fa_top);
draw_text_outlined(VIEW_W / 2, VIEW_H - 40, "A/D hoặc chuột: chọn     ENTER / nhấp chuột: bắt đầu", c_yellow);
draw_text_outlined(VIEW_W / 2, VIEW_H - 26, "WASD đi  -  Chuột trái đánh  -  Chuột phải chiêu  -  SPACE lướt  -  Q đổi vũ khí", c_silver);
text_align(fa_left, fa_top);
draw_cursor_gui();
