/// Người chơi: hiệp sĩ / cung thủ / phù thủy (chọn ở menu, lưu trong global.hero).
game_init();
hero = global.heroes[global.hero];
sprite = hero.sprites;          // [phải, lên, trái, xuống] như material_8
sprite_index = sprite[3];
mask_index = sprite[3];         // cả 4 hình dùng chung một vùng va chạm ở chân
image_speed = 0;

// di chuyển
spd = hero.spd;
xspeed = 0;
yspeed = 0;
dir = 0;
dis = 0;
dash_spd = 6;
dash_timer = 0;
dash_cd = 0;
dash_dir = 0;

// chiến đấu
aim_dir = 270;
reload = 0;          // hồi đánh thường
skill_timer = 0;     // hồi kỹ năng
inv_timer = 60;      // bất tử vài giây đầu màn
flash = 0;
knock_x = 0;
knock_y = 0;
hurt_timer = 0;
dead_timer = 0;
tele_cd = 0;

// biến điều khiển (player_input gán lại mỗi frame)
right = 0; left = 0; up = 0; down = 0;
key_dash = false; key_attack = false; key_skill = false; key_switch = false; key_1 = false; key_2 = false;

state = PSTATE.MOVE;

// vũ khí cầm tay
gun = instance_create_depth(x, y, depth - 1, obj_weapon);
gun.owner = id;

// camera
cam_x = 0;
cam_y = 0;
player_camera(true);
