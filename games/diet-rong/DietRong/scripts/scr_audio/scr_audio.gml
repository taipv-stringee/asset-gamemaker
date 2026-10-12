/// Âm thanh: hiệu ứng (sfx) và nhạc nền. Toàn bộ file âm thanh do generate_sounds.py tạo ra.
/// Phím M bật / tắt toàn bộ âm thanh.

/// Phát một hiệu ứng âm thanh. Cao độ lệch ngẫu nhiên một chút để nghe đỡ lặp lại.
/// _gain: độ to (1 = bình thường), _pitch: cao độ (1 = gốc, 2 = cao gấp đôi).
function sfx(_snd, _gain = 1, _pitch = 1) {
    var _p = _pitch * random_range(0.94, 1.06);
    return audio_play_sound(_snd, 1, false, _gain * global.sfx_volume, 0, _p);
}

/// Hiệu ứng của quái / bẫy: chỉ phát khi ở gần người chơi, càng xa càng nhỏ.
function sfx_at(_snd, _x, _y, _gain = 1, _pitch = 1) {
    if (!instance_exists(obj_player)) return -1;
    var _d = point_distance(_x, _y, obj_player.x, obj_player.y);
    if (_d > 320) return -1;
    return sfx(_snd, _gain * (1 - _d / 400), _pitch);
}

/// Đổi nhạc nền (nếu bản đó đang phát rồi thì để nguyên).
function music_play(_mus) {
    if (global.music == _mus && audio_is_playing(global.music_id)) return;
    music_stop();
    global.music = _mus;
    global.music_id = audio_play_sound(_mus, 10, true, 0);
    audio_sound_gain(global.music_id, global.music_volume, 1500);   // to dần trong 1,5 giây
}

function music_stop() {
    if (global.music_id != -1) audio_stop_sound(global.music_id);
    global.music = -1;
    global.music_id = -1;
}

/// Phím M: bật / tắt tiếng (gọi trong Step của obj_level và obj_menu).
function audio_toggle_check() {
    if (keyboard_check_pressed(ord("M"))) {
        global.muted = !global.muted;
        audio_master_gain(global.muted ? 0 : 1);
        show_msg(global.muted ? "Đã tắt âm thanh (M)" : "Đã bật âm thanh (M)", 60);
    }
}
