draw_set_font(global.font_small);
text_align(fa_center, fa_bottom);
draw_set_alpha(min(1, life / 15));
draw_text_outlined(x, y, text, col);
draw_set_alpha(1);
text_align(fa_left, fa_top);
