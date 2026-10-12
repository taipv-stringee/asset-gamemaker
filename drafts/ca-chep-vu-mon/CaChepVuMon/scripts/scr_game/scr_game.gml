/// Hằng số, khởi tạo và các hàm dùng chung cho cả game.

// Kích thước màn hình game (pixel art, cửa sổ phóng to x2).
#macro VIEW_W 288
#macro VIEW_H 416
// Mép trái / phải của lòng sông (hai bên là bờ).
#macro RIVER_L 32
#macro RIVER_R 256
// Quãng đường phải bơi để tới Vũ Môn.
#macro GOAL_DIST 5200

/// Gọi một lần lúc mở game: font tiếng Việt, kích thước GUI, kỷ lục.
function game_init() {
    if (variable_global_exists("font_small")) return;
    // VT323 (SIL Open Font License) nằm trong Included Files, có đủ dấu tiếng Việt.
    global.font_small = font_add("VT323-Regular.ttf", 16, false, false, 32, 7929);
    global.font_big   = font_add("VT323-Regular.ttf", 32, false, false, 32, 7929);
    display_set_gui_size(VIEW_W, VIEW_H);
    global.scroll = 0;
    ini_open("save.ini");
    global.best = ini_read_real("score", "best", 0);
    ini_close();
}

function save_best(_score) {
    if (_score <= global.best) return false;
    global.best = _score;
    ini_open("save.ini");
    ini_write_real("score", "best", _score);
    ini_close();
    return true;
}

/// Vẽ nền: nước chảy + hai bờ sông. _offset tăng dần => nước trôi xuống.
function draw_river(_offset) {
    var _frame = (current_time div 250) mod 4;
    var _oy = _offset mod 32;
    for (var _y = -32; _y < VIEW_H + 32; _y += 32) {
        var _cy = _y + _oy + 16;
        for (var _x = RIVER_L; _x < RIVER_R; _x += 32) {
            draw_sprite(spr_water, _frame, _x + 16, _cy);
        }
        draw_sprite(spr_bank_left, 0, 16, _cy);
        draw_sprite(spr_bank_right, 0, VIEW_W - 16, _cy);
    }
}

/// Chữ có viền để đọc được trên nền nước.
function draw_text_outlined(_x, _y, _str, _col, _outline = c_black) {
    draw_set_colour(_outline);
    for (var _i = -1; _i <= 1; _i++) {
        for (var _j = -1; _j <= 1; _j++) {
            if (_i != 0 || _j != 0) draw_text(_x + _i, _y + _j, _str);
        }
    }
    draw_set_colour(_col);
    draw_text(_x, _y, _str);
    draw_set_colour(c_white);
}

/// Hiệu ứng chạy hết animation rồi tự hủy (bọt nước, lấp lánh, bong bóng).
function spawn_fx(_x, _y, _sprite, _depth = -5) {
    var _fx = instance_create_depth(_x, _y, _depth, obj_fx);
    _fx.sprite_index = _sprite;
    _fx.image_index = 0;
    return _fx;
}
