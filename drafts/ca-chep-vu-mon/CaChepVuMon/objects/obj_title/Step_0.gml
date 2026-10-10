scroll += 1;
timer += 1;
if (keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter)) {
    room_goto(rm_game);
}
