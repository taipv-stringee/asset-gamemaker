/// Hàm vẽ giao diện.

/// Chữ có viền đen để đọc rõ trên mọi nền.
function draw_text_outlined(_x, _y, _str, _col, _outline = c_black) {
    draw_set_colour(_outline);
    draw_text(_x - 1, _y, _str);
    draw_text(_x + 1, _y, _str);
    draw_text(_x, _y - 1, _str);
    draw_text(_x, _y + 1, _str);
    draw_set_colour(_col);
    draw_text(_x, _y, _str);
    draw_set_colour(c_white);
}

/// Khung hộp thoại bán trong suốt.
function draw_panel(_x1, _y1, _x2, _y2, _alpha = 0.8) {
    draw_set_alpha(_alpha);
    draw_set_colour(make_colour_rgb(20, 18, 34));
    draw_rectangle(_x1, _y1, _x2, _y2, false);
    draw_set_alpha(1);
    draw_set_colour(make_colour_rgb(242, 188, 48));
    draw_rectangle(_x1, _y1, _x2, _y2, true);
    draw_set_colour(c_white);
}

/// Đặt căn lề chữ một lần cho gọn.
function text_align(_h, _v) {
    draw_set_halign(_h);
    draw_set_valign(_v);
}

/// Vẽ con trỏ ngắm tại vị trí chuột (trên lớp GUI).
function draw_cursor_gui() {
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    draw_sprite(spr_cursor, 0, _mx, _my);
}
