extends Node

const BossRewardChestScript := preload("res://Scripts/entities/boss_reward_chest.gd")
## Zarządza falami wrogów - spawnowanie, progresja, pauzy — time‑based waves

signal wave_started(wave_number: int)
signal wave_ended(wave_number: int)
signal all_waves_completed
signal game_over

# ---- Time‑based wave settings ----
@export var wave_base_duration: float = 25.0       # wave 1 duration
@export var wave_duration_per_level: float = 3.0    # +3s per wave
@export var spawn_interval_base: float = 0.9
@export var spawn_interval_min: float = 0.3
@export var spawn_interval_decay: float = 0.03       # per wave
@export var spawn_refill_threshold: int = 5           # refill queue when below this
@export var wave_pause_duration: float = 5.0          # pause between waves

@export var base_enemy_count: int = 8
@export var max_enemy_count: int = 50

var current_wave: int = 0
var enemies_in_wave: int = 0
var enemies_remaining: int = 0
var is_wave_active: bool = false
var wave_timer: float = 0.0          # time elapsed in current wave
var wave_max_time: float = 0.0       # max duration for current wave
var between_waves: bool = false
var between_waves_timer: float = 0.0
var reward_chests_pending: int = 0

# System rozłożonego spawnowania
var spawn_queue: Array[String] = []
var spawn_timer: float = 0.0
@export var spawn_interval: float = 1.0   # set dynamically each wave

var player_node: Node2D
var spawn_points: Array[Node2D] = []

var wave_ui: Label
var enemies_ui: Label
var timer_ui: Label

# Sceny wrogów
var enemy_scenes: Dictionary = {
	"worm": "res://scenes/Enemies/Worm.tscn",
	"phishing": "res://scenes/Enemies/Phishing.tscn",
	"sql": "res://scenes/Enemies/SQL.tscn",
	"trojan": "res://scenes/Enemies/Trojan.tscn",
	"ransomware": "res://scenes/Enemies/Ransomware.tscn",
	"spyware": "res://scenes/Enemies/Spyware.tscn",
	"bot": "res://scenes/Enemies/Bot.tscn",
	"apt_boss": "res://scenes/Enemies/APTBoss.tscn"
}

func _ready() -> void:
	add_to_group("WaveManager")
	# Znajdź węzły UI bezpiecznie
	if has_node("WaveUI"):
		wave_ui = $WaveUI
	if has_node("EnemiesUI"):
		enemies_ui = $EnemiesUI
	if has_node("TimerUI"):
		timer_ui = $TimerUI

	_find_player()
	_find_spawn_points()
	update_ui()

func register_extra_enemy() -> void:
	enemies_remaining += 1
	enemies_in_wave += 1
	update_ui()

func _process(delta: float) -> void:
	if not is_wave_active:
		return

	# Wave timer — ends wave when time runs out
	wave_timer += delta
	if wave_timer >= wave_max_time:
		end_wave()
		return

	# Refill spawn queue when running low
	if spawn_queue.size() < spawn_refill_threshold:
		_refill_spawn_queue(8)

	# Rozłożone spawnowanie w czasie
	if not spawn_queue.is_empty():
		spawn_timer -= delta
		if spawn_timer <= 0.0:
			# Oblicz ile wrogów zespawnować naraz (zwiększa się co 3 fale)
			var burst_size = _get_spawn_burst_size(current_wave)
			for i in range(burst_size):
				if not spawn_queue.is_empty():
					var enemy_type = spawn_queue.pop_front()
					_spawn_enemy(enemy_type)

			spawn_timer = spawn_interval

	update_timer_ui()

func _find_player() -> void:
	var players := get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player_node = players[0]

func _find_spawn_points() -> void:
	spawn_points.clear()
	var points := get_tree().get_nodes_in_group("SpawnPoints")

	for point in points:
		if point is Node2D:
			spawn_points.append(point)

	if spawn_points.is_empty():
		# Utwórz domyślne punkty spawnu
		_create_default_spawn_points()

func _create_default_spawn_points() -> void:
	var screen_size := get_viewport().get_visible_rect().size
	var corners := [
		Vector2(0, 0),
		Vector2(screen_size.x, 0),
		Vector2(0, screen_size.y),
		Vector2(screen_size.x, screen_size.y)
	]

	for corner in corners:
		var marker := Marker2D.new()
		marker.position = corner
		marker.add_to_group("SpawnPoints")
		get_tree().current_scene.add_child(marker)
		spawn_points.append(marker)

func start_game() -> void:
	var gd := get_node_or_null("/root/GameData")
	if gd:
		current_wave = gd.current_wave
	else:
		current_wave = 0
	start_next_wave()

func start_next_wave() -> void:
	current_wave += 1
	wave_max_time = wave_base_duration + float(current_wave - 1) * wave_duration_per_level
	wave_timer = 0.0
	is_wave_active = true
	between_waves = false
	between_waves_timer = 0.0
	spawn_timer = 0.0
	reward_chests_pending = 0
	spawn_queue.clear()

	var wave_config := _get_wave_config(current_wave)
	# Use at least 15 enemies in the initial queue
	var initial_count := maxi(15, wave_config.enemy_count)
	enemies_in_wave = initial_count + (1 if wave_config.has_boss else 0)
	enemies_remaining = enemies_in_wave

	# Oblicz interwał spawnu - przyspiesza z każdą falą
	spawn_interval = _get_spawn_interval(current_wave)

	_spawn_wave(wave_config, initial_count)
	wave_started.emit(current_wave)
	update_ui()

func _get_wave_config(wave: int) -> Dictionary:
	var config := {}
	config.enemy_count = _get_enemy_count_for_wave(wave)
	config.enemy_weights = _get_enemy_weights_for_wave(wave)

	# Co 5 fal: boss-checkpoint.
	if wave % 5 == 0:
		config.has_boss = true
		if wave == 5:
			config.boss_type = "giant_worm"
		elif wave == 10:
			config.boss_type = "giant_trojan"
		elif wave == 15:
			config.boss_type = "giant_ransomware"
		elif wave == 20:
			config.boss_type = "giant_spyware"
		elif wave == 25:
			config.boss_type = "giant_phishing"
		elif wave == 30:
			config.boss_type = "giant_sql"
		else:
			config.boss_type = "apt_boss"
	else:
		config.has_boss = false

	return config

func _spawn_wave(config: Dictionary, initial_count: int = 15) -> void:
	# Kolejkuj normalnych wrogów zamiast spawnować ich natychmiast
	var enemy_weights: Dictionary = config.get("enemy_weights", {"worm": 1.0})
	for i in range(initial_count):
		var enemy_type: String = _pick_weighted_enemy(enemy_weights)
		spawn_queue.append(enemy_type)

	# Dodaj bossa do kolejki jeśli wymagane
	if config.has_boss:
		if config.has("boss_type"):
			spawn_queue.append(config.boss_type)
		else:
			spawn_queue.append("apt_boss")

	# Gwarancja minimum 8 botów w każdej fali
	var bot_count := 0
	for etype in spawn_queue:
		if etype == "bot":
			bot_count += 1
	var missing_bots := maxi(0, 8 - bot_count)
	for i in range(missing_bots):
		spawn_queue.append("bot")
	if missing_bots > 0:
		enemies_in_wave += missing_bots
		enemies_remaining += missing_bots

## Refill spawn queue with `count` weighted-random enemies (called during wave)
func _refill_spawn_queue(count: int) -> void:
	var wave_config := _get_wave_config(current_wave)
	var enemy_weights: Dictionary = wave_config.get("enemy_weights", {"worm": 1.0})
	for i in range(count):
		var enemy_type: String = _pick_weighted_enemy(enemy_weights)
		spawn_queue.append(enemy_type)
	enemies_in_wave += count
	enemies_remaining += count

func _spawn_enemy(enemy_type: String) -> void:
	var is_giant_boss = false
	var actual_enemy_type = enemy_type

	if enemy_type.begins_with("giant_"):
		is_giant_boss = true
		actual_enemy_type = enemy_type.replace("giant_", "")

	var scene_path: String = str(enemy_scenes.get(actual_enemy_type, ""))
	if scene_path == "":
		push_warning("Brak sceny dla wroga: " + actual_enemy_type)
		return

	var scene := load(scene_path) as PackedScene
	if not scene:
		push_warning("Nie można załadować sceny: " + scene_path)
		return

	var enemy: Node2D = scene.instantiate()
	var drops_boss_reward := is_giant_boss or actual_enemy_type == "apt_boss"
	if drops_boss_reward:
		enemy.set_meta("drops_boss_reward_chest", true)

	var spawn_point: Node2D = spawn_points.pick_random()

	if spawn_point:
		enemy.global_position = spawn_point.global_position
	else:
		enemy.global_position = Vector2.ZERO

	if enemy.has_signal("died"):
		enemy.connect("died", _on_enemy_died.bind(enemy))

	# Dodaj do sceny - preferujemy nadrzędny węzeł MainGame
	var target_parent = get_parent()
	if not (target_parent is Node2D):
		target_parent = get_tree().current_scene
	if target_parent:
		target_parent.add_child(enemy)
		if enemy.has_method("scale_stats"):
			enemy.scale_stats(current_wave)
		if is_giant_boss and enemy.has_method("make_giant_boss"):
			enemy.make_giant_boss()
	else:
		push_warning("Cannot add enemy - no valid parent found")

func _get_enemy_count_for_wave(wave: int) -> int:
	var count := base_enemy_count + int(wave * 2.4) + int(wave / 5) * 3
	if wave % 5 == 0:
		count -= 3
	return clampi(count, 8, max_enemy_count)

func _get_spawn_interval(wave: int) -> float:
	return maxf(spawn_interval_min, spawn_interval_base - float(wave - 1) * spawn_interval_decay)

func _get_spawn_burst_size(wave: int) -> int:
	return clampi(1 + int(wave / 7), 1, 4)

func _get_enemy_weights_for_wave(wave: int) -> Dictionary:
	if wave <= 1:
		return {"worm": 0.75, "bot": 0.25}
	if wave == 2:
		return {"worm": 0.60, "trojan": 0.20, "bot": 0.20}
	if wave == 3:
		return {"worm": 0.47, "trojan": 0.28, "ransomware": 0.08, "bot": 0.17}
	if wave == 4:
		return {"worm": 0.30, "trojan": 0.34, "ransomware": 0.20, "bot": 0.16}
	if wave == 5:
		return {"worm": 0.39, "trojan": 0.30, "ransomware": 0.16, "bot": 0.15}
	if wave <= 7:
		return {"worm": 0.23, "trojan": 0.27, "ransomware": 0.22, "spyware": 0.13, "bot": 0.15}
	if wave <= 9:
		return {"worm": 0.12, "trojan": 0.20, "ransomware": 0.20, "spyware": 0.18, "phishing": 0.12, "bot": 0.18}
	if wave == 10:
		return {"trojan": 0.24, "ransomware": 0.21, "spyware": 0.19, "phishing": 0.13, "worm": 0.08, "bot": 0.15}
	if wave <= 12:
		return {"trojan": 0.16, "ransomware": 0.18, "spyware": 0.19, "phishing": 0.17, "sql": 0.10, "bot": 0.20}
	if wave <= 14:
		return {"trojan": 0.12, "ransomware": 0.16, "spyware": 0.18, "phishing": 0.18, "sql": 0.18, "bot": 0.18}
	if wave <= 19:
		return {"worm": 0.08, "trojan": 0.13, "ransomware": 0.17, "spyware": 0.17, "phishing": 0.15, "sql": 0.14, "bot": 0.16}
	if wave <= 24:
		return {"worm": 0.07, "trojan": 0.12, "ransomware": 0.15, "spyware": 0.17, "phishing": 0.15, "sql": 0.20, "bot": 0.14}
	return {"worm": 0.07, "trojan": 0.12, "ransomware": 0.15, "spyware": 0.16, "phishing": 0.18, "sql": 0.18, "bot": 0.14}

func _pick_weighted_enemy(weights: Dictionary) -> String:
	var total := 0.0
	for enemy_type in weights:
		total += float(weights[enemy_type])

	if total <= 0.0:
		return "worm"

	var roll := randf() * total
	var cursor := 0.0
	for enemy_type in weights:
		cursor += float(weights[enemy_type])
		if roll <= cursor:
			return str(enemy_type)
	return str(weights.keys()[0])

## Called when an enemy dies — only decrements counter, does NOT end the wave
func _on_enemy_died(enemy: Node2D = null) -> void:
	if enemy and enemy.get_meta("drops_boss_reward_chest", false):
		_spawn_boss_reward_chest(enemy.global_position)

	enemies_remaining = max(0, enemies_remaining - 1)
	update_ui()

func _spawn_boss_reward_chest(spawn_position: Vector2) -> void:
	var chest := Node2D.new()
	chest.name = "BossRewardChest"
	chest.set_script(BossRewardChestScript)
	chest.global_position = spawn_position
	if chest.has_method("setup"):
		chest.setup(current_wave)

	var target_parent = get_parent()
	if not (target_parent is Node2D):
		target_parent = get_tree().current_scene
	if target_parent:
		target_parent.call_deferred("add_child", chest)
		reward_chests_pending += 1
		if chest.has_signal("opened"):
			chest.opened.connect(_on_boss_reward_chest_opened)

func _on_boss_reward_chest_opened() -> void:
	reward_chests_pending = max(0, reward_chests_pending - 1)
	# No longer triggers end_wave — timer handles wave completion

func end_wave() -> void:
	if not is_wave_active:
		return

	is_wave_active = false
	wave_ended.emit(current_wave)
	update_ui()

# check_wave_completion removed — timer handles wave end now
func check_wave_completion() -> void:
	pass

func update_ui() -> void:
	if wave_ui:
		wave_ui.text = "FALA: %d" % current_wave
	if enemies_ui:
		enemies_ui.visible = false

func update_timer_ui() -> void:
	if timer_ui:
		timer_ui.visible = true
		var remaining: float = maxf(0.0, wave_max_time - wave_timer)
		timer_ui.text = "POZOSTAŁO: %.0fs" % remaining

func get_wave_progress() -> float:
	if wave_max_time <= 0.0:
		return 0.0
	return clampf(wave_timer / wave_max_time, 0.0, 1.0)

func get_total_progress() -> float:
	# Opcjonalnie: zwróć postęp całej gry
	return 0.0

# Wywoływane, gdy gra powinna się zakończyć
func trigger_game_over() -> void:
	game_over.emit()

# Wywoływane po przejściu wszystkich fal
func trigger_all_waves_completed() -> void:
	all_waves_completed.emit()
