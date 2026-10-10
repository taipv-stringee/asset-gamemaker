if (msg_cd > 0) msg_cd--;
if (instance_exists(obj_player) && point_distance(x + 16, y + 16, obj_player.x, obj_player.y) < 30) {
    if (global.keys > 0) {
        global.keys--;
        mp_grid_clear_cell(global.mp_grid, x div TS, y div TS);   // quái đi qua được
        spawn_fx(x + 16, y + 16, spr_fx_poof, 0, 1.5);
        show_msg("Đã mở cửa!", 90);
        instance_destroy();
    } else if (msg_cd <= 0) {
        show_msg("Cửa khóa - cần tìm chìa khóa", 90);
        msg_cd = 120;
    }
}
