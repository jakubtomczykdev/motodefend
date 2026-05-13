extends Node
## GameData – globalny stan gry i ustawienia
## Przechowuje konfigurację użytkownika i dane gry

const SETTINGS_PATH: String = "user://settings.cfg"

# Ustawienia audio
var master_volume: float = 1.0
var music_volume: float = 0.8
var sfx_volume: float = 1.0
var ui_volume: float = 1.0

# Ustawienia grafiki
var resolution: Vector2i = Vector2i(1920, 1080)
var fullscreen: bool = false
var vsync: bool = true
var graphics_quality: int = 2  # 0=Low, 1=Medium, 2=High
var particles_enabled: bool = true
var shadows_enabled: bool = true
var screen_shake: bool = true

# Ustawienia sterowania – przechowujemy mapę akcja → klawisz
# (załadowane z InputMap; do rebindowania)
var custom_inputs: Dictionary = {}

# Dane gry
var current_wave: int = 0
var score: int = 0
var gold: int = 100
var inventory: Array = []
var pending_weapon_ids: Array = []
var player_hp: int = 100
var player_max_hp: int = 100
var return_scene: String = ""

func _ready() -> void:
	var window := get_window()
	if window:
		window.size = Vector2i(1920, 1080)
		window.mode = Window.MODE_WINDOWED
	load_settings()
	apply_video_settings()

func load_settings() -> void:
	var config := ConfigFile.new()
	var err := config.load(SETTINGS_PATH)
	if err != OK:
		return  # Pierwsze uruchomienie – użyj domyślnych

	master_volume = config.get_value("audio", "master_volume", 1.0)
	music_volume = config.get_value("audio", "music_volume", 0.8)
	sfx_volume = config.get_value("audio", "sfx_volume", 1.0)
	ui_volume = config.get_value("audio", "ui_volume", 1.0)

	resolution = Vector2i(
		config.get_value("graphics", "resolution_x", 1920),
		config.get_value("graphics", "resolution_y", 1080)
	)
	fullscreen = config.get_value("graphics", "fullscreen", false)
	vsync = config.get_value("graphics", "vsync", true)
	graphics_quality = config.get_value("graphics", "quality", 2)
	particles_enabled = config.get_value("graphics", "particles", true)
	shadows_enabled = config.get_value("graphics", "shadows", true)
	screen_shake = config.get_value("graphics", "screen_shake", true)

	player_hp = config.get_value("game", "player_hp", 100)
	player_max_hp = config.get_value("game", "player_max_hp", 100)

func save_settings() -> void:
	var config := ConfigFile.new()

	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("audio", "ui_volume", ui_volume)

	config.set_value("graphics", "resolution_x", resolution.x)
	config.set_value("graphics", "resolution_y", resolution.y)
	config.set_value("graphics", "fullscreen", fullscreen)
	config.set_value("graphics", "vsync", vsync)
	config.set_value("graphics", "quality", graphics_quality)
	config.set_value("graphics", "particles", particles_enabled)
	config.set_value("graphics", "shadows", shadows_enabled)
	config.set_value("graphics", "screen_shake", screen_shake)

	config.set_value("game", "player_hp", player_hp)
	config.set_value("game", "player_max_hp", player_max_hp)

	config.save(SETTINGS_PATH)

func apply_video_settings() -> void:
	var window := get_window()
	if window:
		window.size = resolution
		if fullscreen:
			window.mode = Window.MODE_FULLSCREEN
		else:
			window.mode = Window.MODE_WINDOWED

	if vsync:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func reset_to_defaults() -> void:
	var config := ConfigFile.new()
	var err := config.load(SETTINGS_PATH)
	if err == OK:
		var dir := DirAccess.open("user://")
		if dir and dir.file_exists("settings.cfg"):
			dir.remove("settings.cfg")

	master_volume = 1.0
	music_volume = 0.8
	sfx_volume = 1.0
	ui_volume = 1.0
	resolution = Vector2i(1920, 1080)
	fullscreen = false
	vsync = true
	graphics_quality = 2
	particles_enabled = true
	shadows_enabled = true
	screen_shake = true

	save_settings()
	apply_video_settings()

func add_inventory_item(item) -> void:
	inventory.append(item)
