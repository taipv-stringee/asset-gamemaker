// bình máu: hồi 2 tim (đầy máu thì đổi thành 5 vàng)
if (global.hp < global.hp_max) {
    global.hp = min(global.hp_max, global.hp + 2);
    spawn_text(x, y - 10, "+2 máu", c_lime);
} else {
    global.coins += 5;
    spawn_text(x, y - 10, "+5 vàng", c_yellow);
}
spawn_fx(x, y - 6, spr_fx_heal);
