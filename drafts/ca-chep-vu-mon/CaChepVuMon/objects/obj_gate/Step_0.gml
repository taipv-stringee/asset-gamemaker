if (!arrived) {
    y += max(global.scroll, 1);
    if (y >= target_y) {
        y = target_y;
        arrived = true;
    }
}
if (irandom(5) == 0) {
    spawn_fx(random_range(RIVER_L + 8, RIVER_R - 8), y + 128, spr_splash, depth - 1);
}
