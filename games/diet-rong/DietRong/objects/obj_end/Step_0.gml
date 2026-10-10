t++;
if (t mod 10 == 0) {
    spawn_fx(random(VIEW_W), random(VIEW_H * 0.6), choose(spr_fx_sparkle, spr_fx_hit), 0, 2);
}
if (t > 60 && (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || mouse_check_button_pressed(mb_left))) {
    room_goto(rm_menu);
}
