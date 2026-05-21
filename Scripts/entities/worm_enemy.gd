extends EnemyBase
## Specyficzna logika dla Worma - rozmnażanie się

@export var split_chance: float = 0.1
@export var split_timer_max: float = 12.0
var split_timer: float = 0.0
var wave_time: float = 0.0

func _ready() -> void:
	super._ready()
	split_timer = split_timer_max * randf_range(0.8, 1.2)
	wave_time = randf() * PI * 2

func handle_ai(delta: float) -> void:
	if not player:
		super.handle_ai(delta)
		return

	var distance := global_position.distance_to(player.global_position)
	if distance < detection_range:
		wave_time += delta * 5.0
		var dir_to_player = (player.global_position - global_position).normalized()
		var side_offset = dir_to_player.rotated(PI/2) * sin(wave_time) * 0.7
		
		velocity = (dir_to_player + side_offset).normalized() * move_speed
		
		if sprite and "scale" in sprite:
			if velocity.x > 0:
				sprite.scale.x = abs(sprite.scale.x)
			elif velocity.x < 0:
				sprite.scale.x = -abs(sprite.scale.x)
	else:
		_handle_wander(delta)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	split_timer -= delta
	if split_timer <= 0:
		_try_split()
		split_timer = split_timer_max * randf_range(0.8, 1.2)

func _try_split() -> void:
	# Losowa szansa na podział
	if randf() > split_chance:
		return
	
	# Sprawdź limit wrogów
	var enemies := get_tree().get_nodes_in_group("Enemies")
	if enemies.size() > 50:
		return
		
	# Zamiast duplicate(), lepiej załadować scenę fali lub stworzyć nową instancję tej samej klasy
	# ale najbezpieczniej dla logiki gry jest zrespawnować nową czystą instancję
	var scene_path = "res://scenes/Enemies/Worm.tscn"
	var worm_scene = load(scene_path)
	if not worm_scene: return

	var new_worm = worm_scene.instantiate()
	new_worm.global_position = global_position + Vector2(randf_range(-50, 50), randf_range(-50, 50))
	
	get_parent().add_child(new_worm)
	
	# Powiadom WaveManager o nowym wrogu
	var wave_managers = get_tree().get_nodes_in_group("WaveManager")
	for wm in wave_managers:
		if wm.has_method("register_extra_enemy"):
			wm.register_extra_enemy()
		# Bardzo ważne: podłącz sygnał died nowej instancji do WaveManagera
		if new_worm.has_signal("died") and wm.has_method("_on_enemy_died"):
			new_worm.died.connect(wm._on_enemy_died)
