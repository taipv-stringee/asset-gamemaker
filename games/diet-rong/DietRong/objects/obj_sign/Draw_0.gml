draw_self();
// dấu "!" nhấp nháy để người chơi biết có thể đọc
if (instance_exists(obj_player) && point_distance(x, y, obj_player.x, obj_player.y) < 80) {
    draw_set_font(global.font_small);
    text_align(fa_center, fa_bottom);
    draw_text_outlined(x, y - 14 + sin(current_time / 150) * 2, "!", c_yellow);
    text_align(fa_left, fa_top);
}
