extends EnemyBase
## Ransomware - slow tank that locks space around the player.

@export var lockdown_cooldown: float = 5.5
@export var lockdown_radius: float = 145.0

var lockdown_timer: float = 0.0
var is_locking_down: bool = false

func _ready() -> void:
	max_health = 120
	move_speed = 90.0
	score_value = 30
	knockback_resistance = 0.5
	lockdown_timer = randf_range(1.5, lockdown_cooldown)
	super._ready()

func _physics_process(delta: float) -> void:
	if player and is_instance_valid(player):
		var distance := global_position.distance_to(player.global_position)
		if distance < 170.0:
			move_speed = 40.0
			modulate = Color(0.7, 0.7, 1.0)
			knockback_resistance = 0.9
			lockdown_timer -= delta
			if lockdown_timer <= 0.0 and not is_locking_down:
				_start_lockdown_pulse()
				lockdown_timer = lockdown_cooldown * randf_range(0.85, 1.2)
		else:
			move_speed = original_move_speed
			if not is_locking_down:
				modulate = Color.WHITE
			knockback_resistance = 0.5

	super._physics_process(delta)

func _start_lockdown_pulse() -> void:
	if is_dead:
		return

	is_locking_down = true
	velocity = Vector2.ZERO
	var warning := _spawn_area_warning(global_position, lockdown_radius, 0.8, Color(0.25, 0.45, 1.0, 0.30))
	modulate = Color(0.45, 0.6, 1.4)
	await get_tree().create_timer(0.8).timeout
	if is_dead:
		return

	_damage_player_in_radius(global_position, lockdown_radius, int(damage * 1.25), 430.0)
	var pulse_flash := _spawn_area_warning(global_position, lockdown_radius * 0.75, 0.25, Color(0.55, 0.85, 1.0, 0.45))
	if is_instance_valid(warning):
		warning.queue_free()
	await get_tree().create_timer(0.25).timeout
	if is_instance_valid(pulse_flash):
		pulse_flash.queue_free()
	await get_tree().create_timer(0.18).timeout
	if not is_dead:
		is_locking_down = false
		modulate = Color.WHITE
