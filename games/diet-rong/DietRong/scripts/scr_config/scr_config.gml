/// Cấu hình chung: hằng số, enum, dữ liệu nhân vật và vũ khí.
/// Muốn chỉnh độ khó / sức mạnh: sửa số trong file này là chính.

#macro TS 32            // kích thước 1 ô tile (pixel)
#macro VIEW_W 480       // khung nhìn của camera; cửa sổ phóng to x2 = 960x540
#macro VIEW_H 270

enum HERO { KNIGHT, ARCHER, WIZARD }
enum PSTATE { MOVE, DASH, HURT, DEAD }
enum ESTATE { IDLE, WANDER, CHASE, ATK }

/// Vũ khí (giống WeaponInit của material_8, thêm vài thuộc tính).
/// _kind: "melee" = chém gần, "shot" = bắn đạn.
function WeaponInit(_name, _sprite, _kind, _proj, _dmg, _reload, _spd, _num, _spread, _range) constructor {
    name = _name;          // tên hiện trên HUD
    sprite = _sprite;      // hình vũ khí cầm tay
    kind = _kind;
    proj = _proj;          // hình đạn / vệt chém
    dmg = _dmg;            // sát thương mỗi phát
    reload = _reload;      // số frame chờ giữa 2 lần đánh
    spd = _spd;            // tốc độ đạn
    num = _num;            // số viên mỗi lần bắn
    spread = _spread;      // góc toả (độ)
    range = _range;        // tầm xa (pixel) / tầm chém
    pierce = false;        // đạn xuyên qua quái
    aoe = 0;               // bán kính nổ (0 = không nổ)
    arc = 120;             // góc chém (cho vũ khí cận chiến)
    knock = 3;             // lực đẩy lùi quái
}

/// Gọi một lần lúc mở game (an toàn nếu gọi nhiều lần).
function game_init() {
    if (variable_global_exists("heroes")) return;

    randomize();
    // Font VT323 (SIL Open Font License) nằm trong Included Files, có đủ dấu tiếng Việt.
    global.font_small = font_add("VT323-Regular.ttf", 14, false, false, 32, 7929);
    global.font_mid   = font_add("VT323-Regular.ttf", 22, false, false, 32, 7929);
    global.font_big   = font_add("VT323-Regular.ttf", 32, false, false, 32, 7929);
    display_set_gui_size(VIEW_W, VIEW_H);

    // ---- Vũ khí: tên, hình, loại, đạn, sát thương, hồi, tốc độ, số viên, góc toả, tầm
    global.wp_sword = new WeaponInit("Kiếm thép", spr_wp_sword, "melee", spr_slash, 3, 20, 0, 1, 0, 34);
    global.wp_axe   = new WeaponInit("Rìu chiến", spr_wp_axe, "melee", spr_slash_big, 5, 34, 0, 1, 0, 44);
    global.wp_axe.arc = 170;
    global.wp_axe.knock = 6;

    global.wp_bow      = new WeaponInit("Cung gỗ", spr_wp_bow, "shot", spr_arrow, 2, 14, 7, 1, 0, 260);
    global.wp_crossbow = new WeaponInit("Nỏ ba tên", spr_wp_crossbow, "shot", spr_bolt, 2, 26, 8, 3, 12, 220);

    global.wp_fire  = new WeaponInit("Gậy lửa", spr_wp_staff_fire, "shot", spr_fireball, 3, 28, 4, 1, 0, 240);
    global.wp_fire.aoe = 30;
    global.wp_storm = new WeaponInit("Gậy sét", spr_wp_staff_storm, "shot", spr_spark, 2, 12, 9, 1, 4, 200);
    global.wp_storm.pierce = true;

    // ---- 3 nhân vật. sprites theo thứ tự [phải, lên, trái, xuống] như material_8
    global.heroes = [
        {
            name: "Hiệp sĩ", hp: 6, spd: 2.0,
            sprites: [spr_knight_right, spr_knight_up, spr_knight_left, spr_knight_down],
            weapons: [global.wp_sword, global.wp_axe],
            skill: "Lốc xoáy kiếm", skill_cost: 30, skill_cd: 90,
            desc: "Máu trâu, chém gần.\nLốc xoáy: chém quanh mình,\nbất tử trong lúc xoay."
        },
        {
            name: "Cung thủ", hp: 5, spd: 2.5,
            sprites: [spr_archer_right, spr_archer_up, spr_archer_left, spr_archer_down],
            weapons: [global.wp_bow, global.wp_crossbow],
            skill: "Mưa tên", skill_cost: 25, skill_cd: 60,
            desc: "Nhanh nhẹn, bắn xa.\nMưa tên: 9 mũi tên\nxuyên thấu toả hình quạt."
        },
        {
            name: "Phù thủy", hp: 4, spd: 1.9,
            sprites: [spr_wizard_right, spr_wizard_up, spr_wizard_left, spr_wizard_down],
            weapons: [global.wp_fire, global.wp_storm],
            skill: "Vòng băng", skill_cost: 35, skill_cd: 120,
            desc: "Ít máu, phép mạnh.\nVòng băng: đóng băng và\ngây sát thương xung quanh."
        }
    ];

    global.hero = HERO.KNIGHT;
    global.boss = noone;      // trùm đang đánh (để vẽ thanh máu)
    global.shake = 0;         // độ rung màn hình
    global.msg = "";          // thông báo giữa màn hình
    global.msg_timer = 0;
    global.mana_max = 100;
    reset_stats(global.hero);

    ini_open("save.ini");
    global.best_time = [ini_read_real("best", "t0", 0), ini_read_real("best", "t1", 0), ini_read_real("best", "t2", 0)];
    ini_close();
}

/// Đặt lại chỉ số cho một lượt chơi mới.
function reset_stats(_hero) {
    global.hero = _hero;
    var _h = global.heroes[_hero];
    global.hp_max = _h.hp;
    global.hp = _h.hp;
    global.mana = global.mana_max;
    global.coins = 0;
    global.keys = 0;
    global.kills = 0;
    global.time = 0;              // số frame đã chơi (60 frame = 1 giây)
    global.weapons = [_h.weapons[0]];
    global.wp_index = 0;
}

/// Bắt đầu lượt chơi mới với nhân vật đã chọn.
function new_game(_hero) {
    reset_stats(_hero);
    room_goto(rm_level1);
}

/// Sao chép mảng (để lưu checkpoint mà không dính tham chiếu).
function copy_array(_a) {
    var _b = [];
    for (var _i = 0; _i < array_length(_a); _i++) array_push(_b, _a[_i]);
    return _b;
}

/// Lưu trạng thái lúc vào màn (để chơi lại màn khi thua).
function checkpoint_save() {
    global.cp = {
        hp: global.hp, hp_max: global.hp_max, mana: global.mana, coins: global.coins,
        keys: global.keys, kills: global.kills, time: global.time,
        weapons: copy_array(global.weapons), wp_index: global.wp_index
    };
}

function checkpoint_load() {
    var _c = global.cp;
    global.hp = _c.hp_max;            // chơi lại thì hồi đầy máu
    global.hp_max = _c.hp_max;
    global.mana = global.mana_max;
    global.coins = _c.coins;
    global.keys = _c.keys;
    global.kills = _c.kills;
    global.time = _c.time;
    global.weapons = copy_array(_c.weapons);
    global.wp_index = _c.wp_index;
}

/// Đổi số frame thành chuỗi phút:giây.
function time_string(_frames) {
    var _s = floor(_frames / 60);
    var _m = _s div 60;
    _s = _s mod 60;
    return string(_m) + ":" + (_s < 10 ? "0" : "") + string(_s);
}
