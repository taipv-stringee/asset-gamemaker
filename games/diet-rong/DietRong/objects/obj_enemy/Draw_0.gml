// vòng đỏ báo trước đòn đánh mạnh (orc)
if (state == ESTATE.ATK && telegraph_r > 0 && !atk_done) {
    draw_set_alpha(0.25 + 0.15 * sin(current_time / 60));
    draw_set_colour(c_red);
    draw_circle(x + image_xscale * 14, y + 10, telegraph_r, false);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}
// thân quái: chớp trắng khi trúng đòn, xanh băng khi bị đóng băng
if (flash > 0) {
    gpu_set_fog(true, c_white, 0, 0);
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, 0, c_white, 1);
    gpu_set_fog(false, c_white, 0, 0);
} else {
    var _col = (freeze_timer > 0) ? make_colour_rgb(140, 210, 255) : c_white;
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, 0, _col, 1);
}
// thanh máu nhỏ khi đã bị thương
if (hp < hp_max && !heavy) {
    var _w = 16;
    var _x1 = x - _w / 2;
    var _y1 = bbox_top - 5;
    draw_set_colour(c_black);
    draw_rectangle(_x1 - 1, _y1 - 1, _x1 + _w + 1, _y1 + 2, false);
    draw_set_colour(c_red);
    draw_rectangle(_x1, _y1, _x1 + _w * hp / hp_max, _y1 + 1, false);
    draw_set_colour(c_white);
}
