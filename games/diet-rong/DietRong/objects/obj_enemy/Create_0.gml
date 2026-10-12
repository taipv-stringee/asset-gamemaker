/// Lớp cha của mọi quái (giống obj_enemy của material_8). Con chỉ cần đổi chỉ số.
hp = 4;
hp_max = 4;
spd = 1;
contact_dmg = 1;        // sát thương khi chạm vào người chơi
chase_distance = 200;   // thấy người chơi trong khoảng này thì đuổi
atk_dis = 0;            // 0 = không có đòn đánh riêng
atk_frame = 2;          // frame của animation tấn công gây sát thương
atk_delay = 60;         // thời gian chờ giữa 2 đòn
atk_cd = 0;
atk_done = false;
telegraph_r = 0;        // > 0: vẽ vòng đỏ báo trước đòn đánh
keep_away = 0;          // > 0: giữ khoảng cách với người chơi (quái bắn xa)
flying = false;         // bay: không cần tìm đường, đi xuyên chướng ngại
heavy = false;          // nặng (trùm): không bị đẩy lùi, không bị đóng băng
can_flip = true;        // lật hình theo hướng người chơi
coin_drop = 1;
potion_chance = 0.1;
drop_key = false;       // đặt true trong Creation Code để quái rơi chìa khóa

// tìm đường
path = path_add();
calc_path_delay = irandom_range(20, 40);
calc_path_timer = 0;
wander_timer = irandom_range(60, 200);
wander_x = x;
wander_y = y;
wobble = random(10);

// trúng đòn
hurt_timer = 0;
knock_x = 0;
knock_y = 0;
flash = 0;
freeze_timer = 0;

// hình theo trạng thái: [đứng, lang thang, đuổi, tấn công]
sprite = [sprite_index, sprite_index, sprite_index, sprite_index];
state = ESTATE.IDLE;
image_speed = 1;
