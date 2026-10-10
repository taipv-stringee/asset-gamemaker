draw_set_alpha(0.25);
draw_set_colour(c_black);
draw_ellipse(x - 4, y + 5, x + 4, y + 8, false);
draw_set_alpha(1);
draw_set_colour(c_white);
draw_sprite(sprite_index, image_index, x, y + sin(bob) * 1.5);
