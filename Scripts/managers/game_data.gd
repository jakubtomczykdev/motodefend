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
var current_level: int = 1
var experience: int = 0
var experience_to_next_level: int = 100
var current_wave: int = 0
var score: int = 0
var gold: int = BalanceData.STARTING_GOLD
var inventory: Array = []
var pending_weapon_ids: Array = []
var max_item_slots_bonus: int = 0
var player_hp: int = 100
var player_max_hp: int = 100
var run_started: bool = false
var play_menu_spawn_intro: bool = false
var identity_trap_seen: bool = false
var return_scene: String = ""
var level_upgrade_flat_bonuses: Dictionary = {}
var level_upgrade_multiplier_bonuses: Dictionary = {}
var economy_totals: Dictionary = {}
var economy_by_wave: Dictionary = {}

func _ready() -> void:
	var window := get_window()
	if window:
		window.size = Vector2i(1920, 1080)
		window.mode = Window.MODE_WINDOWED
	reset_economy_tracking()
	load_settings()
	apply_video_settings()

func load_settings() -> void:
	var config := ConfigFile.new()
	var err := config.load(SETTINGS_PATH)
	if err != OK:
		# Initial XP requirement from BalanceData if load fails
		experience_to_next_level = BalanceData.STARTING_XP_REQUIREMENT
		return

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
	current_level = config.get_value("game", "current_level", 1)
	experience = config.get_value("game", "experience", 0)
	experience_to_next_level = config.get_value("game", "experience_to_next_level", 100)
	identity_trap_seen = config.get_value("game", "identity_trap_seen", false)
	level_upgrade_flat_bonuses = config.get_value("game", "level_upgrade_flat_bonuses", {})
	level_upgrade_multiplier_bonuses = config.get_value("game", "level_upgrade_multiplier_bonuses", {})

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
	config.set_value("game", "current_level", current_level)
	config.set_value("game", "experience", experience)
	config.set_value("game", "experience_to_next_level", experience_to_next_level)
	config.set_value("game", "identity_trap_seen", identity_trap_seen)
	config.set_value("game", "level_upgrade_flat_bonuses", level_upgrade_flat_bonuses)
	config.set_value("game", "level_upgrade_multiplier_bonuses", level_upgrade_multiplier_bonuses)

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
	identity_trap_seen = false
	max_item_slots_bonus = 0
	clear_level_upgrades()

	save_settings()
	apply_video_settings()

func add_inventory_item(item) -> void:
	inventory.append(item)

func add_max_item_slots_bonus(amount: int = 1) -> int:
	max_item_slots_bonus = maxi(0, max_item_slots_bonus + amount)
	return get_max_item_slots()

func get_max_item_slots() -> int:
	return BalanceData.MAX_BUILD_SLOTS + max_item_slots_bonus

func add_level_upgrade(stat_name: String, value: float) -> void:
	if _is_flat_level_upgrade(stat_name):
		var current_flat := float(level_upgrade_flat_bonuses.get(stat_name, 0.0))
		level_upgrade_flat_bonuses[stat_name] = current_flat + value
	elif value < 1.0:
		var current_multiplier := float(level_upgrade_multiplier_bonuses.get(stat_name, 1.0))
		level_upgrade_multiplier_bonuses[stat_name] = current_multiplier * (1.0 + value)
	else:
		var current_flat := float(level_upgrade_flat_bonuses.get(stat_name, 0.0))
		level_upgrade_flat_bonuses[stat_name] = current_flat + value

func _is_flat_level_upgrade(stat_name: String) -> bool:
	return stat_name in ["hp_regen", "crit_chance", "dodge_chance", "cooldown_reduction", "armor", "max_health", "pierce", "projectile_count"]

func clear_level_upgrades() -> void:
	level_upgrade_flat_bonuses.clear()
	level_upgrade_multiplier_bonuses.clear()

func reset_economy_tracking() -> void:
	economy_totals = _make_empty_economy_snapshot()
	economy_by_wave.clear()

func record_gold_income(source: String, amount: int, wave_number: int = -1) -> void:
	_record_economy_value(_get_economy_key(source), amount, wave_number)

func record_gold_spent(source: String, amount: int, wave_number: int = -1) -> void:
	_record_economy_value(_get_economy_key(source), amount, wave_number)

func print_economy_report(wave_number: int = -1) -> void:
	if economy_totals.is_empty():
		return

	if wave_number >= 0 and economy_by_wave.has(wave_number):
		var wave_report: Dictionary = economy_by_wave[wave_number]
		print("[Economy] Wave %d | kill=%d wave=%d boss=%d spent=%d reroll=%d refund=%d gold_now=%d" % [
			wave_number,
			int(wave_report.get("gold_from_kills", 0)),
			int(wave_report.get("gold_from_wave_reward", 0)),
			int(wave_report.get("gold_from_boss_fallback", 0)),
			int(wave_report.get("gold_spent_shop", 0)),
			int(wave_report.get("gold_spent_reroll", 0)),
			int(wave_report.get("gold_refunded_sale", 0)),
			gold
		])
		return

	print("[Economy] Run totals | kill=%d wave=%d boss=%d spent=%d reroll=%d refund=%d gold_now=%d" % [
		int(economy_totals.get("gold_from_kills", 0)),
		int(economy_totals.get("gold_from_wave_reward", 0)),
		int(economy_totals.get("gold_from_boss_fallback", 0)),
		int(economy_totals.get("gold_spent_shop", 0)),
		int(economy_totals.get("gold_spent_reroll", 0)),
		int(economy_totals.get("gold_refunded_sale", 0)),
		gold
	])

func _get_economy_key(source: String) -> String:
	match source:
		"enemy_kill":
			return "gold_from_kills"
		"wave_reward":
			return "gold_from_wave_reward"
		"boss_fallback":
			return "gold_from_boss_fallback"
		"shop_purchase":
			return "gold_spent_shop"
		"reroll":
			return "gold_spent_reroll"
		"sale_refund":
			return "gold_refunded_sale"
		_:
			return source

func _make_empty_economy_snapshot() -> Dictionary:
	return {
		"gold_from_kills": 0,
		"gold_from_wave_reward": 0,
		"gold_from_boss_fallback": 0,
		"gold_spent_shop": 0,
		"gold_spent_reroll": 0,
		"gold_refunded_sale": 0
	}

func _record_economy_value(key: String, amount: int, wave_number: int = -1) -> void:
	if amount == 0:
		return
	if economy_totals.is_empty():
		reset_economy_tracking()

	var resolved_wave := maxi(wave_number, current_wave)
	if not economy_by_wave.has(resolved_wave):
		economy_by_wave[resolved_wave] = _make_empty_economy_snapshot()

	economy_totals[key] = int(economy_totals.get(key, 0)) + amount

	var wave_report: Dictionary = economy_by_wave[resolved_wave]
	wave_report[key] = int(wave_report.get(key, 0)) + amount
	economy_by_wave[resolved_wave] = wave_report

func reset_run_progress() -> void:
	run_started = false
	current_level = 1
	experience = 0
	experience_to_next_level = BalanceData.STARTING_XP_REQUIREMENT
	current_wave = 0
	score = 0
	gold = BalanceData.STARTING_GOLD
	inventory.clear()
	pending_weapon_ids.clear()
	max_item_slots_bonus = 0
	player_max_hp = BalanceData.BASE_PLAYER_HP
	player_hp = player_max_hp
	clear_level_upgrades()
	reset_economy_tracking()
