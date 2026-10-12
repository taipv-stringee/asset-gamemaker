draw_set_font(global.font_small);
draw_set_valign(fa_top);
draw_set_halign(fa_left);

// --- máu
var _hp = instance_exists(obj_carp) ? obj_carp.hp : 0;
var _hp_slots = instance_exists(obj_carp) ? max(3, obj_carp.hp) : 3;
for (var _i = 0; _i < _hp_slots; _i++) {
    draw_sprite(_i < _hp ? spr_heart_full : spr_heart_empty, 0, 13 + _i * 17, 13);
}

// --- ngọc
draw_sprite(spr_icon_pearl, 0, VIEW_W - 46, 13);
draw_text_outlined(VIEW_W - 36, 4, "x" + string(pearls), c_white);

// --- năng lượng lướt
var _energy = instance_exists(obj_carp) ? obj_carp.energy : 0;
draw_sprite(spr_bar_energy_bg, 0, 8, VIEW_H - 20);
draw_sprite_part(spr_bar_energy_fill, 0, 0, 0, 3 + 90 * _energy, 12, 8, VIEW_H - 20);
draw_text_outlined(108, VIEW_H - 23, "LƯỚT", _energy >= 0.34 ? c_aqua : c_gray);

// --- tiến độ tới Vũ Môn (thanh dọc bên phải)
var _top = 32, _bot = VIEW_H - 32;
draw_set_colour(c_black);
draw_line_width(VIEW_W - 7, _top, VIEW_W - 7, _bot, 4);
draw_set_colour(make_colour_rgb(120, 200, 255));
draw_line_width(VIEW_W - 7, _top, VIEW_W - 7, _bot, 2);
draw_set_colour(c_white);
draw_sprite_ext(spr_icon_pearl, 0, VIEW_W - 7, _top, 0.75, 0.75, 0, c_red, 1);
var _p = clamp(distance / GOAL_DIST, 0, 1);
draw_sprite_ext(spr_carp_swim, 0, VIEW_W - 7, lerp(_bot, _top, _p), 0.5, 0.5, 0, c_white, 1);

// --- lời nhắc
draw_set_halign(fa_center);
if (state == "play" && distance < 260) {
    draw_text_outlined(VIEW_W / 2, 120, "Bơi ngược dòng tới Vũ Môn!", c_yellow);
}
if (state == "gate" && instance_exists(obj_gate) && obj_gate.arrived && (state_timer div 30) mod 2 == 0) {
    draw_text_outlined(VIEW_W / 2, 230, "Nhấn SPACE để lướt qua thác!", c_yellow);
}

// --- thua
if (state == "over" && state_timer > 20) {
    draw_set_alpha(0.6);
    draw_set_colour(c_black);
    draw_rectangle(0, 0, VIEW_W, VIEW_H, false);
    draw_set_alpha(1);
    draw_set_font(global.font_big);
    draw_text_outlined(VIEW_W / 2, 130, "CÁ ĐÃ KIỆT SỨC!", c_red);
    draw_set_font(global.font_small);
    draw_text_outlined(VIEW_W / 2, 180, "Điểm: " + string(final_score), c_white);
    draw_text_outlined(VIEW_W / 2, 198, (new_record ? "KỶ LỤC MỚI! " : "Kỷ lục: ") + string(global.best), c_yellow);
    if (state_timer > 40) {
        draw_text_outlined(VIEW_W / 2, 240, "SPACE: chơi lại    ESC: menu", c_white);
    }
}

// --- thắng
if (state == "win" && state_timer > 150) {
    draw_set_alpha(min(0.5, (state_timer - 150) / 60));
    draw_set_colour(c_black);
    draw_rectangle(0, 0, VIEW_W, VIEW_H, false);
    draw_set_alpha(1);
    draw_set_font(global.font_big);
    draw_text_outlined(VIEW_W / 2, 120, "HÓA RỒNG!", c_yellow, c_red);
    draw_set_font(global.font_small);
    draw_text_outlined(VIEW_W / 2, 170, "Ngọc nhặt được: " + string(pearls), c_white);
    draw_text_outlined(VIEW_W / 2, 188, "Điểm: " + string(final_score), c_white);
    draw_text_outlined(VIEW_W / 2, 206, (new_record ? "KỶ LỤC MỚI! " : "Kỷ lục: ") + string(global.best), c_yellow);
    if (state_timer > 180) {
        draw_text_outlined(VIEW_W / 2, 250, "Nhấn SPACE về menu", c_white);
    }
}

draw_set_halign(fa_left);
draw_set_colour(c_white);
