timer += 1;
if (timer < 60) {
    var _s = lerp(0.5, 1, timer / 60);
    image_xscale = _s;
    image_yscale = _s;
    if (timer mod 4 == 0) spawn_fx(x + random_range(-24, 24), y + random_range(-24, 24), spr_sparkle, depth - 1);
} else {
    y -= 2.2;
    x = x0 + dsin(timer * 4) * 10;
    if (timer mod 6 == 0) spawn_fx(x + random_range(-10, 10), y + 30, spr_sparkle, depth + 1);
}
if (y < -120) instance_destroy();
