extends Node
## Zarządza falami wrogów - spawnowanie, progresja, pauzy

signal wave_started(wave_number: int)
signal wave_ended(wave_number: int)
signal all_waves_completed
signal game_over

@export var time_between_waves: float = 10.0
@export var base_enemy_count: int = 5
@export var enemy_count_multiplier: float = 1.2

var current_wave: int = 0
var enemies_in_wave: int = 0
var enemies_remaining: int = 0
var is_wave_active: bool = false
var is_between_waves: bool = false
var wave_timer: float = 0.0

var player_node: Node2D
var spawn_points: Array[Node2D] = []

var wave_ui: Label
var enemies_ui: Label
var timer_ui: Label

# Sceny wrogów
var enemy_scenes: Dictionary = {
	"worm": "res://Scenes/Enemies/Worm.tscn",
	"trojan": "res://Scenes/Enemies/Trojan.tscn",
	"ransomware": "res://Scenes/Enemies/Ransomware.tscn",
	"spyware": "res://Scenes/Enemies/Spyware.tscn",
	"apt_boss": "res://Scenes/Enemies/APTBoss.tscn"
}

func _ready() -> void:
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

func _process(delta: float) -> void:
	if is_between_waves:
		wave_timer -= delta
		update_timer_ui()

		if wave_timer <= 0:
			start_next_wave()

	if is_wave_active:
		check_wave_completion()

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
	current_wave = 0
	start_next_wave()

func start_next_wave() -> void:
	current_wave += 1
	is_wave_active = true
	is_between_waves = false

	var wave_config := _get_wave_config(current_wave)
	enemies_in_wave = wave_config.enemy_count
	enemies_remaining = enemies_in_wave

	_spawn_wave(wave_config)
	wave_started.emit(current_wave)
	update_ui()

func _get_wave_config(wave: int) -> Dictionary:
	var config := {}

	# Oblicz liczbę wrogów
	config.enemy_count = int(base_enemy_count * pow(enemy_count_multiplier, wave - 1))

	# Określ typy wrogów
	config.enemy_types = []

	# Waves 1-5: tylko Worm
	if wave <= 5:
		config.enemy_types.append("worm")

	# Waves 6-10: Worm + Trojan
	elif wave <= 10:
		config.enemy_types.append("worm")
		config.enemy_types.append("trojan")

	# Waves 11-15: Worm + Trojan + Ransomware
	elif wave <= 15:
		config.enemy_types.append("worm")
		config.enemy_types.append("trojan")
		config.enemy_types.append("ransomware")

	# Waves 16+: wszystkie podstawowe typy
	else:
		config.enemy_types.append("worm")
		config.enemy_types.append("trojan")
		config.enemy_types.append("ransomware")
		config.enemy_types.append("spyware")

	# Co 5 fal: Boss
	if wave % 5 == 0:
		config.has_boss = true
	else:
		config.has_boss = false

	return config

func _spawn_wave(config: Dictionary) -> void:
	# Spawnuj normalnych wrogów
	var boss_spawned := false

	for i in range(config.enemy_count):
		var enemy_type: String = config.enemy_types.pick_random()
		_spawn_enemy(enemy_type)

	# Dodaj bossa jeśli wymagane
	if config.has_boss:
		_spawn_enemy("apt_boss")
		boss_spawned = true

func _spawn_enemy(enemy_type: String) -> void:
	var scene_path: String = enemy_scenes.get(enemy_type) as String
	if not scene_path:
		push_warning("Brak sceny dla wroga: " + enemy_type)
		return

	var scene := load(scene_path) as PackedScene
	if not scene:
		push_warning("Nie można załadować sceny: " + scene_path)
		return

	var enemy: Node2D = scene.instantiate()
	var spawn_point: Node2D = spawn_points.pick_random()

	if spawn_point:
		enemy.global_position = spawn_point.global_position
	else:
		enemy.global_position = Vector2.ZERO

	enemy.connect("died", _on_enemy_died)
	get_tree().current_scene.add_child(enemy)

func _on_enemy_died() -> void:
	enemies_remaining -= 1
	update_ui()

	if enemies_remaining <= 0:
		end_wave()

func end_wave() -> void:
	is_wave_active = false
	is_between_waves = true
	wave_timer = time_between_waves

	wave_ended.emit(current_wave)
	update_ui()

func check_wave_completion() -> void:
	if enemies_remaining <= 0:
		end_wave()

func update_ui() -> void:
	if wave_ui:
		wave_ui.text = "FALA: %d" % current_wave

	if enemies_ui:
		enemies_ui.text = "WRÓGÓW: %d" % enemies_remaining

func update_timer_ui() -> void:
	if timer_ui:
		timer_ui.text = "NASTĘPNA FALA: %.1f" % wave_timer

func get_wave_progress() -> float:
	if enemies_in_wave == 0:
		return 0.0

	return float(enemies_in_wave - enemies_remaining) / float(enemies_in_wave)

func get_total_progress() -> float:
	# Opcjonalnie: zwróć postęp całej gry
	return 0.0
