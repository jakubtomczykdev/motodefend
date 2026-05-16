extends EnemyBase
## Ransomware - blokuje drogę i staje się twardy gdy jest blisko

func _ready() -> void:
	max_health = 120
	move_speed = 90.0
	score_value = 30
	knockback_resistance = 0.5
	super._ready()

func _physics_process(delta: float) -> void:
	if player and is_instance_valid(player):
		var distance = global_position.distance_to(player.global_position)
		if distance < 150:
			# Staje się ciężki i wolny
			move_speed = 40.0
			modulate = Color(0.7, 0.7, 1.0) # Niebieskawy odcień (kłódka)
			knockback_resistance = 0.9
		else:
			move_speed = 90.0
			modulate = Color.WHITE
			knockback_resistance = 0.5
			
	super._physics_process(delta)
