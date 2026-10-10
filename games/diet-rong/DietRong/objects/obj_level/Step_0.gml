if (banner > 0) banner--;
if (global.msg_timer > 0) global.msg_timer--;
global.shake *= 0.85;
if (global.shake < 0.3) global.shake = 0;

sign_text = "";
if (instance_exists(obj_player)) {
    var _p = obj_player;
    if (_p.state == PSTATE.DEAD) {
        over_timer++;
        if (over_timer > 45 && keyboard_check_pressed(ord("R"))) {
            checkpoint_load();
            room_restart();
        }
    } else {
        global.time++;
    }
    // biển chỉ dẫn ở gần
    var _s = instance_nearest(_p.x, _p.y, obj_sign);
    if (_s != noone && point_distance(_s.x, _s.y, _p.x, _p.y) < 40) sign_text = _s.text;
}
if (keyboard_check_pressed(vk_escape)) room_goto(rm_menu);
