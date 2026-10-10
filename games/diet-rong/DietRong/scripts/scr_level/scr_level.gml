/// Màn chơi: dựng tường từ tile layer (như obj_controller của material_8), tên màn, chuyển màn.

/// Mỗi ô có tile trên layer "lay_wall" -> tạo một obj_wall vô hình để va chạm,
/// rồi tạo lưới mp_grid cho quái tìm đường.
function level_build_walls() {
    var _w = ceil(room_width / TS);
    var _h = ceil(room_height / TS);
    global.tile_wall = layer_tilemap_get_id("lay_wall");
    if (global.tile_wall != -1) {
        for (var _i = 0; _i < _w; _i++) {
            for (var _j = 0; _j < _h; _j++) {
                if (tilemap_get(global.tile_wall, _i, _j) != 0) {
                    instance_create_layer(_i * TS, _j * TS, "Instances", obj_wall);
                }
            }
        }
    }
    if (variable_global_exists("mp_grid") && global.mp_grid != -1) mp_grid_destroy(global.mp_grid);
    global.mp_grid = mp_grid_create(0, 0, _w, _h, TS, TS);
    mp_grid_add_instances(global.mp_grid, obj_wall, false);
    mp_grid_add_instances(global.mp_grid, obj_door, false);   // cửa khóa cũng chặn đường
}

/// Tên và mục tiêu của từng màn (hiện khi vào màn).
function level_info() {
    switch (room) {
        case rm_level1: return { name: "Màn 1 - Rừng Sương Mù", goal: "Tìm chìa khóa, mở cổng đá và vào cổng dịch chuyển" };
        case rm_level2: return { name: "Màn 2 - Hầm Ngục Xương", goal: "Mở các cửa khóa, tránh bẫy chông, tìm lối ra" };
        case rm_level3: return { name: "Màn 3 - Hang Hỏa Long", goal: "Đánh bại Hỏa Long!" };
    }
    return { name: "", goal: "" };
}

/// Room tiếp theo sau khi đi vào cổng dịch chuyển.
function level_next() {
    switch (room) {
        case rm_level1: return rm_level2;
        case rm_level2: return rm_level3;
    }
    return rm_end;
}

/// Thắng game: lưu kỷ lục thời gian cho nhân vật đang chơi.
function save_best_time() {
    var _t = global.time;
    var _best = global.best_time[global.hero];
    global.new_record = (_best == 0 || _t < _best);
    if (global.new_record) {
        global.best_time[global.hero] = _t;
        ini_open("save.ini");
        ini_write_real("best", "t" + string(global.hero), _t);
        ini_close();
    }
}
