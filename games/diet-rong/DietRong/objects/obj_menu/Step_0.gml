t++;
var _old = sel;
if (keyboard_check_pressed(ord("A")) || keyboard_check_pressed(vk_left)) sel = (sel + 2) mod 3;
if (keyboard_check_pressed(ord("D")) || keyboard_check_pressed(vk_right)) sel = (sel + 1) mod 3;
if (keyboard_check_pressed(ord("1"))) sel = 0;
if (keyboard_check_pressed(ord("2"))) sel = 1;
if (keyboard_check_pressed(ord("3"))) sel = 2;

// chọn bằng chuột (toạ độ trên lớp GUI)
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
for (var _i = 0; _i < 3; _i++) {
    var _x1 = 12 + _i * (card_w + 6);
    if (point_in_rectangle(_mx, _my, _x1, card_y, _x1 + card_w, card_y + card_h)) {
        sel = _i;
        if (mouse_check_button_pressed(mb_left)) new_game(sel);
    }
}
if (_old != sel) sfx(snd_menu_move);
if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) new_game(sel);
audio_toggle_check();
if (keyboard_check_pressed(vk_escape)) game_end();
