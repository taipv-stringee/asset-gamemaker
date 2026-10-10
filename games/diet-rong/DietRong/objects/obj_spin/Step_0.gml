if (instance_exists(owner)) {
    x = owner.x;
    y = owner.y + 2;
}
if (life mod 12 == 0) {
    hurt_enemies_circle(x, y, 40, 3, 5);
    screen_shake(2);
}
destroy_eproj_circle(x, y, 44);
life--;
if (life <= 0) instance_destroy();
