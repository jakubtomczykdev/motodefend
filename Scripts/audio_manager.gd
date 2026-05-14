extends Node
## AudioManager – globalny zarządca dźwięku
## Obsługuje muzykę, SFX, UI przez AudioBus

const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"
const UI_BUS := "UI"

var _music_players: Array[AudioStreamPlayer] = []
var _current_music_track: String = ""

# Mapa nazw dźwięków na ścieżki — zapobiega błędom "Resource not found"
var _sfx_paths: Dictionary = {
	"blaster_shot": "res://Audio/blaster_shot.wav",
	"drone_shoot": "res://Audio/drone_shoot.wav",
	"shockwave": "res://Audio/shockwave.wav",
	"sword_swing": "res://Audio/sword_swing.wav",
}

func _ready() -> void:
	_create_buses()

func _create_buses() -> void:
	# Sprawdza czy busy istnieją, jeśli nie – tworzy je
	var bus_count := AudioServer.bus_count
	var has_music := false
	var has_sfx := false
	var has_ui := false

	for i in bus_count:
		var bus_name := AudioServer.get_bus_name(i)
		if bus_name == MUSIC_BUS:
			has_music = true
		elif bus_name == SFX_BUS:
			has_sfx = true
		elif bus_name == UI_BUS:
			has_ui = true

	if not has_music:
		AudioServer.add_bus(bus_count)
		AudioServer.set_bus_name(bus_count, MUSIC_BUS)
		bus_count += 1
	if not has_sfx:
		AudioServer.add_bus(bus_count)
		AudioServer.set_bus_name(bus_count, SFX_BUS)
		bus_count += 1
	if not has_ui:
		AudioServer.add_bus(bus_count)
		AudioServer.set_bus_name(bus_count, UI_BUS)
		bus_count += 1

func set_bus_volume(bus_name: String, volume: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index >= 0:
		var db := linear_to_db(volume) if volume > 0 else -80.0
		AudioServer.set_bus_volume_db(bus_index, db)

func set_master_volume(volume: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(volume) if volume > 0 else -80.0)

func set_music_volume(volume: float) -> void:
	set_bus_volume(MUSIC_BUS, volume)

func set_sfx_volume(volume: float) -> void:
	set_bus_volume(SFX_BUS, volume)

func set_ui_volume(volume: float) -> void:
	set_bus_volume(UI_BUS, volume)

func apply_all_volumes() -> void:
	var gd = get_node_or_null("/root/GameData")
	if gd == null:
		return
	set_master_volume(gd.master_volume)
	set_music_volume(gd.music_volume)
	set_sfx_volume(gd.sfx_volume)
	set_ui_volume(gd.ui_volume)

func play_music(track_path: String, fade_in: float = 0.5) -> void:
	if track_path == _current_music_track:
		return

	# Wycisz poprzednią muzykę
	for player: AudioStreamPlayer in _music_players:
		if player.playing:
			_stop_player(player, 0.3)

	var stream: AudioStream = load(track_path)
	if stream == null:
		push_warning("[AudioManager] Nie znaleziono: " + track_path)
		return

	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = MUSIC_BUS
	add_child(player)
	_music_players.append(player)

	player.volume_db = -80.0
	player.play()
	_current_music_track = track_path

	var tween := create_tween()
	tween.tween_property(player, "volume_db", 0.0, fade_in)

func play_sfx(sfx_path: String, pitch_variation: float = 0.1) -> void:
	var resolved_path: String = _sfx_paths.get(sfx_path, sfx_path)
	
	var stream: AudioStream = load(resolved_path)
	if stream == null:
		# Po cichu ignoruj brakujące dźwięki (brak plików audio w projekcie)
		return

	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = SFX_BUS
	player.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
	add_child(player)
	player.play()

	player.finished.connect(player.queue_free)

func play_ui(sfx_path: String) -> void:
	var stream: AudioStream = load(sfx_path)
	if stream == null:
		push_warning("[AudioManager] Nie znaleziono: " + sfx_path)
		return

	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = UI_BUS
	add_child(player)
	player.play()

	player.finished.connect(player.queue_free)

func _stop_player(player: AudioStreamPlayer, fade_out: float) -> void:
	var tween := create_tween()
	tween.tween_property(player, "volume_db", -80.0, fade_out)
	tween.tween_callback(_remove_player.bind(player))

func _remove_player(player: AudioStreamPlayer) -> void:
	_music_players.erase(player)
	player.queue_free()
	if _music_players.is_empty():
		_current_music_track = ""

func stop_all_music(fade_out: float = 0.5) -> void:
	for player: AudioStreamPlayer in _music_players:
		_stop_player(player, fade_out)

func refresh_volumes() -> void:
	apply_all_volumes()
