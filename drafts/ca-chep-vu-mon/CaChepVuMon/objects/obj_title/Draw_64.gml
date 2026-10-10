draw_set_halign(fa_center);
draw_set_valign(fa_top);

draw_set_font(global.font_big);
draw_text_outlined(VIEW_W / 2, 18, "CÁ CHÉP", c_orange);
draw_text_outlined(VIEW_W / 2, 46, "VƯỢT VŨ MÔN", c_yellow);

draw_set_font(global.font_small);
draw_text_outlined(VIEW_W / 2, 302, "Mũi tên / WASD : bơi", c_white);
draw_text_outlined(VIEW_W / 2, 318, "SPACE : lướt nhanh (tốn năng lượng)", c_white);
draw_text_outlined(VIEW_W / 2, 334, "Né đá, cá dữ, rắn nước, xoáy nước", c_white);
draw_text_outlined(VIEW_W / 2, 350, "Lướt qua thác để hóa rồng!", c_white);
if ((timer div 30) mod 2 == 0) {
    draw_text_outlined(VIEW_W / 2, 374, "Nhấn SPACE để bắt đầu", c_yellow);
}
draw_text_outlined(VIEW_W / 2, 396, "Kỷ lục: " + string(global.best), make_colour_rgb(150, 220, 255));

draw_set_halign(fa_left);
