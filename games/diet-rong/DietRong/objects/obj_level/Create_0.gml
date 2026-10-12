/// Điều khiển màn chơi (giống obj_controller của material_8):
/// dựng tường từ tile layer, lưới tìm đường, HUD, thua / chơi lại.
/// Phải đứng ĐẦU TIÊN trong thứ tự tạo instance của room.
game_init();
level_build_walls();
checkpoint_save();
var _info = level_info();
level_name = _info.name;
level_goal = _info.goal;
banner = 240;           // thời gian hiện tên màn
global.boss = noone;
global.shake = 0;
global.msg_timer = 0;
sign_text = "";
over_timer = 0;
window_set_cursor(cr_none);

// nhạc nền theo màn (đánh trùm sẽ đổi sang mus_boss)
switch (room) {
    case rm_level1: music_play(mus_forest); break;
    default: music_play(mus_dungeon); break;
}
