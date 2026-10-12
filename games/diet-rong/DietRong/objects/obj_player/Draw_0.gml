/// Vẽ người chơi: nháy khi bất tử, chớp trắng khi trúng đòn, bóng mờ khi lướt.
if (state == PSTATE.DEAD) {
    draw_sprite_ext(sprite_index, 0, x, y + 6, 1, 1, 90, c_gray, 1);   // nằm gục
    exit;
}
if (state == PSTATE.DASH) {
    draw_sprite_ext(sprite_index, image_index, x - lengthdir_x(8, dash_dir), y - lengthdir_y(8, dash_dir),
                    1, 1, 0, c_aqua, 0.35);
}
var _alpha = 1;
if (inv_timer > 0 && state != PSTATE.DASH && (inv_timer div 4) mod 2 == 0) _alpha = 0.45;
if (flash > 0) {
    gpu_set_fog(true, c_white, 0, 0);
    draw_sprite_ext(sprite_index, image_index, x, y, 1, 1, 0, c_white, 1);
    gpu_set_fog(false, c_white, 0, 0);
} else {
    draw_sprite_ext(sprite_index, image_index, x, y, 1, 1, 0, c_white, _alpha);
}
