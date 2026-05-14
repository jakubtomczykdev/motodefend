extends Node
## Zarządza falami wrogów - spawnowanie, progresja, pauzy

signal wave_started(wave_number: int)
signal wave_ended(wave_number: int)
signal all_waves_completed
signal game_over

@export var wave_duration: float = 30.0
@export var base_enemy_count: int = 10
@export var enemy_count_multiplier: float = 1.25

var current_wave: int = 0
var enemies_in_wave: int = 0
var enemies_remaining: int = 0
var is_wave_active: bool = false
var wave_elapsed: float = 0.0

# System rozłożonego spawnowania
var spawn_queue: Array[String] = []
var spawn_timer: float = 0.0
@export var spawn_interval: float = 1.0 # Czas między spawnem kolejnych wrogów

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
	if is_wave_active:
		wave_elapsed += delta
		update_timer_ui()

		# Rozłożone spawnowanie w czasie
		if not spawn_queue.is_empty():
			spawn_timer -= delta
			if spawn_timer <= 0:
				# Oblicz ile wrogów zespawnować naraz (zwiększa się co 3 fale)
				var burst_size = 1 + int(current_wave / 4)
				for i in range(burst_size):
					if not spawn_queue.is_empty():
						var enemy_type = spawn_queue.pop_front()
						_spawn_enemy(enemy_type)
				
				spawn_timer = spawn_interval

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
	var gd := get_node_or_null("/root/GameData")
	if gd:
		current_wave = gd.current_wave
	else:
		current_wave = 0
	start_next_wave()

func start_next_wave() -> void:
	current_wave += 1
	is_wave_active = true
	wave_elapsed = 0.0
	spawn_timer = 0.0
	spawn_queue.clear()

	var wave_config := _get_wave_config(current_wave)
	enemies_in_wave = wave_config.enemy_count
	enemies_remaining = enemies_in_wave
	
	# Oblicz interwał spawnu - przyspiesza z każdą falą
	spawn_interval = max(0.2, 1.5 - (current_wave * 0.05))

	_spawn_wave(wave_config)
	wave_started.emit(current_wave)
	update_ui()

func _get_wave_config(wave: int) -> Dictionary:
	var config := {}

	# Oblicz liczbę wrogów
	config.enemy_count = int(base_enemy_count * pow(enemy_count_multiplier, wave - 1))

	# Określ typy wrogów - TYLKO TYPY Z FINALNYMI GRAFIKAMI DLA DEMO
	config.enemy_types = ["worm", "trojan", "ransomware"]

	# Co 5 fal: Boss (używa esa.png, więc jest OK)
	if wave % 5 == 0:
		config.has_boss = true
	else:
		config.has_boss = false

	return config

func _spawn_wave(config: Dictionary) -> void:
	# Kolejkuj normalnych wrogów zamiast spawnować ich natychmiast
	for i in range(config.enemy_count):
		var enemy_type: String = config.enemy_types.pick_random()
		spawn_queue.append(enemy_type)

	# Dodaj bossa do kolejki jeśli wymagane
	if config.has_boss:
		spawn_queue.append("apt_boss")

func _spawn_enemy(enemy_type: String) -> void:
	var scene_path: String = str(enemy_scenes.get(enemy_type, ""))
	if scene_path == "":
		push_warning("Brak sceny dla wroga: " + enemy_type)
		return

	var scene := load(scene_path) as PackedScene
	if not scene:
		push_warning("Nie można załadować sceny: " + scene_path)
		return

	var enemy: Node2D = scene.instantiate()
	
	if enemy.has_method("scale_stats"):
		enemy.scale_stats(current_wave)

	var spawn_point: Node2D = spawn_points.pick_random()

	if spawn_point:
		enemy.global_position = spawn_point.global_position
	else:
		enemy.global_position = Vector2.ZERO

	if enemy.has_signal("died"):
		enemy.connect("died", _on_enemy_died)
	
	# Dodaj do sceny - preferujemy nadrzędny węzeł MainGame
	var target_parent = get_parent()
	if not (target_parent is Node2D):
		target_parent = get_tree().current_scene
	if target_parent:
		target_parent.add_child(enemy)
	else:
		push_warning("Cannot add enemy - no valid parent found")

func _on_enemy_died() -> void:
	enemies_remaining = max(0, enemies_remaining - 1)
	update_ui()

	if spawn_queue.is_empty() and enemies_remaining <= 0:
		end_wave()

func end_wave() -> void:
	if not is_wave_active:
		return

	is_wave_active = false

	update_ui()
	wave_ended.emit(current_wave)

func check_wave_completion() -> void:
	if not is_wave_active:
		return
	# Fala kończy się tylko gdy kolejka jest pusta I wszyscy wrogowie nie żyją
	if spawn_queue.is_empty() and enemies_remaining <= 0:
		end_wave()

func update_ui() -> void:
	if wave_ui:
		wave_ui.text = "FALA: %d" % current_wave

	if enemies_ui:
		enemies_ui.text = "WRÓGÓW: %d" % enemies_remaining

func update_timer_ui() -> void:
	if timer_ui:
		timer_ui.visible = false
		# var remaining: float = maxf(0.0, wave_duration - wave_elapsed)
		# timer_ui.text = "POZOSTAŁO: %.1fs" % remaining

func get_wave_progress() -> float:
	if enemies_in_wave == 0:
		return 0.0

	return float(enemies_in_wave - enemies_remaining) / float(enemies_in_wave)

func get_total_progress() -> float:
	# Opcjonalnie: zwróć postęp całej gry
	return 0.0

# Wywoływane, gdy gra powinna się zakończyć
func trigger_game_over() -> void:
	game_over.emit()

# Wywoływane po przejściu wszystkich fal
func trigger_all_waves_completed() -> void:
	all_waves_completed.emit()
