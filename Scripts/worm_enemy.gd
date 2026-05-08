extends EnemyBase
## Specyficzna logika dla Worma - rozmnażanie się

@export var split_chance: float = 0.2
@export var split_timer_max: float = 8.0
var split_timer: float = 0.0

func _ready() -> void:
	super._ready()
	split_timer = split_timer_max * randf_range(0.8, 1.2)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	split_timer -= delta
	if split_timer <= 0:
		_try_split()
		split_timer = split_timer_max * randf_range(0.8, 1.2)

func _try_split() -> void:
	# Sprawdź limit wrogów (opcjonalnie, by nie zapchać pamięci)
	var enemies := get_tree().get_nodes_in_group("Enemies")
	if enemies.size() > 50:
		return
		
	# Stwórz kopię
	var new_worm := duplicate()
	# Resetuj stan kopii
	new_worm.current_health = max_health
	new_worm.global_position = global_position + Vector2(randf_range(-50, 50), randf_range(-50, 50))
	
	get_parent().add_child(new_worm)
	
	# Powiadom WaveManager o nowym wrogu, jeśli to możliwe
	var wave_managers := get_tree().get_nodes_in_group("WaveManager")
	for wm in wave_managers:
		if wm.has_method("register_extra_enemy"):
			wm.register_extra_enemy()
