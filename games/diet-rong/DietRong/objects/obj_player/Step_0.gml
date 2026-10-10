/// Vòng lặp chính của người chơi (máy trạng thái giống material_8).
player_input();
if (dash_cd > 0) dash_cd--;
if (reload > 0) reload--;
if (skill_timer > 0) skill_timer--;
if (inv_timer > 0) inv_timer--;
if (flash > 0) flash--;
if (tele_cd > 0 && !place_meeting(x, y, obj_teleport)) tele_cd--;   // phải bước ra khỏi bàn dịch chuyển mới dùng lại được
global.mana = min(global.mana_max, global.mana + 0.07);   // năng lượng tự hồi
aim_dir = point_direction(x, y + 2, mouse_x, mouse_y);

switch (state) {
    case PSTATE.MOVE:
        player_move();
        player_switch_weapon();
        player_attack();
        player_skill();
        player_try_dash();
        break;

    case PSTATE.DASH:
        move_collide(lengthdir_x(dash_spd, dash_dir), lengthdir_y(dash_spd, dash_dir));
        if (dash_timer mod 3 == 0) spawn_fx(x, y + 10, spr_fx_dust);
        dash_timer--;
        if (dash_timer <= 0) state = PSTATE.MOVE;
        break;

    case PSTATE.HURT:   // bị đẩy lùi một chút, vẫn đánh được
        move_collide(knock_x, knock_y);
        knock_x *= 0.8;
        knock_y *= 0.8;
        player_attack();
        hurt_timer--;
        if (hurt_timer <= 0) state = PSTATE.MOVE;
        break;

    case PSTATE.DEAD:
        dead_timer++;
        image_speed = 0;
        break;
}

if (state != PSTATE.DEAD) {
    player_animate();
    player_weapon_update();
}
player_camera(false);
