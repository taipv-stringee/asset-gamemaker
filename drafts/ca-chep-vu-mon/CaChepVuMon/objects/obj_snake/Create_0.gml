event_inherited();
/// Rắn nước: uốn lượn trái phải.
amp = random_range(24, 44);
x = clamp(x, RIVER_L + amp + 12, RIVER_R - amp - 12);
x0 = x;
wave = random(360);
