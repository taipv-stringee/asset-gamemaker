/// HUD: máu, năng lượng, vàng, chìa khóa, vũ khí, kỹ năng, thanh máu trùm, thông báo.
draw_set_font(global.font_small);
text_align(fa_left, fa_top);
var _p = instance_exists(obj_player) ? obj_player.id : noone;

// ---- máu và năng lượng (góc trên trái)
for (var _i = 0; _i < global.hp_max; _i++) {
    draw_sprite(spr_ui_heart, (_i < global.hp) ? 0 : 1, 6 + _i * 15, 5);
}
draw_sprite(spr_ui_mana_bg, 0, 7, 23);
draw_sprite_part(spr_ui_mana_fill, 0, 0, 0, 2 + 60 * global.mana / global.mana_max, 8, 7, 23);

// ---- vàng, chìa khóa
draw_sprite(spr_coin, 0, 14, 41);
draw_text_outlined(24, 34, string(global.coins), c_yellow);
draw_sprite(spr_key, 0, 62, 41);
draw_text_outlined(72, 34, string(global.keys), c_white);

// ---- thời gian, quái đã hạ (góc trên phải)
text_align(fa_right, fa_top);
draw_text_outlined(VIEW_W - 6, 4, time_string(global.time), c_white);
draw_text_outlined(VIEW_W - 6, 18, "Hạ gục: " + string(global.kills), c_silver);

// ---- ô vũ khí và ô kỹ năng (góc dưới trái)
text_align(fa_left, fa_top);
var _sx = 6;
var _sy = VIEW_H - 30;
var _wp = global.weapons[global.wp_index];
draw_sprite(spr_ui_slot, 0, _sx, _sy);
var _cx = _sx + 12 - (sprite_get_width(_wp.sprite) / 2 - sprite_get_xoffset(_wp.sprite)) * 0.7;
draw_sprite_ext(_wp.sprite, 0, _cx, _sy + 12, 0.7, 0.7, 45, c_white, 1);
if (_p != noone && _p.reload > 0) {
    draw_set_alpha(0.55);
    draw_set_colour(c_black);
    draw_rectangle(_sx + 2, _sy + 2, _sx + 21, _sy + 2 + 19 * _p.reload / _wp.reload, false);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}
draw_text_outlined(_sx + 2, _sy - 14, _wp.name + ((array_length(global.weapons) > 1) ? " [Q]" : ""), c_white);

var _h = global.heroes[global.hero];
var _kx = _sx + 30;
draw_sprite(spr_ui_slot, 0, _kx, _sy);
var _ready = (_p != noone && _p.skill_timer <= 0 && global.mana >= _h.skill_cost);
draw_sprite_ext(spr_ui_skill, global.hero, _kx + 4, _sy + 4, 1, 1, 0, _ready ? c_white : c_dkgray, 1);
if (_p != noone && _p.skill_timer > 0) {
    draw_set_alpha(0.55);
    draw_set_colour(c_black);
    draw_rectangle(_kx + 2, _sy + 2, _kx + 21, _sy + 2 + 19 * _p.skill_timer / _h.skill_cd, false);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}
draw_text_outlined(_kx + 28, _sy + 2, _h.skill + " (chuột phải)", _ready ? c_aqua : c_gray);
draw_text_outlined(_kx + 28, _sy + 13, "Tốn " + string(_h.skill_cost) + " năng lượng", c_gray);

// ---- thanh máu trùm
if (instance_exists(global.boss)) {
    var _b = global.boss;
    text_align(fa_center, fa_top);
    draw_text_outlined(VIEW_W / 2, 34, _b.name, c_orange);
    draw_sprite(spr_ui_boss_bg, 0, VIEW_W / 2 - 100, 48);
    draw_sprite_part(spr_ui_boss_fill, 0, 0, 0, 2 + 196 * max(0, _b.hp) / _b.hp_max, 10, VIEW_W / 2 - 100, 48);
}

// ---- tên màn khi mới vào
if (banner > 0) {
    var _a = min(1, banner / 40);
    draw_set_alpha(_a);
    draw_panel(VIEW_W / 2 - 160, 70, VIEW_W / 2 + 160, 120, 0.8 * _a);
    draw_set_alpha(_a);
    text_align(fa_center, fa_top);
    draw_set_font(global.font_mid);
    draw_text_outlined(VIEW_W / 2, 74, level_name, c_yellow);
    draw_set_font(global.font_small);
    draw_text_outlined(VIEW_W / 2, 100, level_goal, c_white);
    draw_set_alpha(1);
}

// ---- thông báo
if (global.msg_timer > 0) {
    text_align(fa_center, fa_top);
    draw_set_alpha(min(1, global.msg_timer / 20));
    draw_text_outlined(VIEW_W / 2, VIEW_H - 64, global.msg, c_yellow);
    draw_set_alpha(1);
}

// ---- nội dung biển chỉ dẫn
if (sign_text != "") {
    draw_panel(90, VIEW_H - 50, VIEW_W - 90, VIEW_H - 6);
    text_align(fa_center, fa_middle);
    draw_text_ext(VIEW_W / 2, VIEW_H - 28, sign_text, 13, VIEW_W - 200);
}

// ---- thua
if (_p != noone && _p.state == PSTATE.DEAD) {
    draw_set_alpha(min(0.7, over_timer / 60));
    draw_set_colour(c_black);
    draw_rectangle(0, 0, VIEW_W, VIEW_H, false);
    draw_set_alpha(1);
    draw_set_colour(c_white);
    if (over_timer > 30) {
        text_align(fa_center, fa_middle);
        draw_set_font(global.font_big);
        draw_text_outlined(VIEW_W / 2, VIEW_H / 2 - 30, "BẠN ĐÃ GỤC NGÃ", c_red);
        draw_set_font(global.font_small);
        draw_text_outlined(VIEW_W / 2, VIEW_H / 2 + 10, "R: chơi lại màn này     ESC: về menu", c_white);
    }
}

text_align(fa_left, fa_top);
draw_cursor_gui();
