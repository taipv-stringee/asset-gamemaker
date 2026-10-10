if (blink > 0 && (blink div 4) mod 2 == 0) {
    // nhấp nháy: bỏ qua khung này
} else {
    draw_self();
}
if (shield) {
    draw_sprite_ext(spr_shield, (current_time div 120) mod 4, x, y, 1.6, 1.6, 0, c_white, 0.8);
}
