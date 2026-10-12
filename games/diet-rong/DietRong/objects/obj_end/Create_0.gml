/// Màn chiến thắng.
game_init();
t = 0;
music_stop();
sfx(snd_victory);
if (!variable_global_exists("new_record")) global.new_record = false;
