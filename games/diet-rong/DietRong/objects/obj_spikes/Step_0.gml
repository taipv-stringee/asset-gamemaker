t = (t + 1) mod 120;
if (t == 60) sfx_at(snd_spikes, x, y, 0.4);
if (t < 60) image_index = 0;          // ẩn
else if (t < 66) image_index = 1;     // nhú lên
else if (t < 100) image_index = 2;    // dựng hết - nguy hiểm!
else if (t < 106) image_index = 3;    // thụt xuống
else image_index = 0;
if (image_index == 2 && instance_exists(obj_player) && place_meeting(x, y, obj_player)) {
    player_hurt(1, x, y);
}
