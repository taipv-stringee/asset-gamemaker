var _t = clamp(distance / GOAL_DIST, 0, 1);

// Lau sậy trang trí trôi dọc hai bờ.
if (state == "play" || state == "gate") {
    decor_timer -= global.scroll;
    if (decor_timer <= 0) {
        var _r = instance_create_depth(choose(10, VIEW_W - 10), -30, 900, obj_reed);
        _r.image_xscale = choose(1, -1);
        decor_timer = random_range(60, 200);
    }
}

switch (state) {
    case "play":
        global.scroll = lerp(1.4, 2.6, _t);
        distance += global.scroll;
        spawn_timer -= 1;
        if (spawn_timer <= 0 && distance < GOAL_DIST - 450) {
            spawn_wave(_t);
            spawn_timer = irandom_range(round(lerp(70, 34, _t)), round(lerp(95, 50, _t)));
        }
        if (distance >= GOAL_DIST) {
            instance_create_depth(VIEW_W / 2, -150, 50, obj_gate);
            state = "gate";
            state_timer = 0;
        }
        if (keyboard_check_pressed(vk_escape)) room_goto(rm_title);
        break;

    case "gate":
        // Sông chậm lại khi Vũ Môn trôi vào, rồi dừng hẳn.
        state_timer += 1;
        if (obj_gate.arrived) {
            global.scroll = max(0, global.scroll - 0.05);
        } else {
            global.scroll = max(1.4, global.scroll - 0.02);
        }
        distance += global.scroll;
        if (keyboard_check_pressed(vk_escape)) room_goto(rm_title);
        break;

    case "over":
        state_timer += 1;
        if (state_timer > 40) {
            if (keyboard_check_pressed(vk_space) || keyboard_check_pressed(ord("R"))) room_restart();
            if (keyboard_check_pressed(vk_escape)) room_goto(rm_title);
        }
        break;

    case "win":
        state_timer += 1;
        if (state_timer > 180 && (keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter))) {
            room_goto(rm_title);
        }
        break;
}
