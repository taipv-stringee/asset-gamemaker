// Thác nước phủ kín lòng sông ngay dưới cổng.
var _frame = (current_time div 100) mod 4;
var _top = y + 64;
draw_sprite_part(spr_waterfall, _frame, 0, 0, 128, 64, RIVER_L, _top);
draw_sprite_part(spr_waterfall, _frame, 0, 0, RIVER_R - RIVER_L - 128, 64, RIVER_L + 128, _top);
draw_self();
