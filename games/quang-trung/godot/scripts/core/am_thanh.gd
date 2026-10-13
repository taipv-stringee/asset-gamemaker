extends Node
## Autoload "AmThanh": nhạc nền (chuyển mượt) và hiệu ứng (nhiều kênh). Gọi qua lớp tĩnh Sfx để
## các script chạy không có autoload (test headless) vẫn biên dịch được.

const MUSIC_DIR := "res://assets/audio/nhac/"
const SFX_DIR := "res://assets/audio/sfx/"
const VOICES := 8
const FADE := 0.8

var _music: Array[AudioStreamPlayer] = []
var _cur := 0
var _music_name := ""
var _voices: Array[AudioStreamPlayer] = []
var _next_voice := 0
var _cache: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for bus in ["Nhac", "HieuUng"]:
		if AudioServer.get_bus_index(bus) < 0:
			AudioServer.add_bus()
			var i := AudioServer.bus_count - 1
			AudioServer.set_bus_name(i, bus)
			AudioServer.set_bus_send(i, "Master")
	for i in 2:
		var p := AudioStreamPlayer.new()
		p.bus = "Nhac"
		add_child(p)
		_music.append(p)
	for i in VOICES:
		var p := AudioStreamPlayer.new()
		p.bus = "HieuUng"
		add_child(p)
		_voices.append(p)


func _load(path: String) -> AudioStream:
	if not _cache.has(path):
		_cache[path] = load(path) if ResourceLoader.exists(path) else null
	return _cache[path]


## Phát nhạc nền theo tên (lặp). Cùng bài đang phát thì để nguyên. loop=false cho đoạn thắng/thua.
func play_music(name: String, loop := true, volume_db := -4.0) -> void:
	if name == _music_name and _music[_cur].playing:
		return
	var stream := _load(MUSIC_DIR + name + ".ogg")
	if stream == null:
		return
	if stream is AudioStreamOggVorbis:
		stream.loop = loop  # mỗi bài luôn dùng cùng một kiểu lặp nên đặt thẳng trên tài nguyên
	var old := _music[_cur]
	_cur = 1 - _cur
	var p := _music[_cur]
	p.stream = stream
	p.volume_db = -40.0
	p.play()
	_music_name = name
	var tw := create_tween().set_parallel()
	tw.tween_property(p, "volume_db", volume_db, FADE)
	if old.playing:
		tw.tween_property(old, "volume_db", -40.0, FADE)
		tw.chain().tween_callback(old.stop)


func stop_music() -> void:
	_music_name = ""
	for p in _music:
		if p.playing:
			var tw := create_tween()
			tw.tween_property(p, "volume_db", -40.0, FADE)
			tw.tween_callback(p.stop)


func play_sfx(name: String, volume_db := 0.0, pitch_jitter := 0.05) -> void:
	var stream := _load(SFX_DIR + name + ".wav")
	if stream == null:
		return
	var p := _voices[_next_voice]
	_next_voice = (_next_voice + 1) % VOICES
	p.stream = stream
	p.volume_db = volume_db
	p.pitch_scale = 1.0 + randf_range(-pitch_jitter, pitch_jitter)
	p.play()


func _exit_tree() -> void:
	for p in _music + _voices:
		p.stop()
		p.stream = null
	_cache.clear()
