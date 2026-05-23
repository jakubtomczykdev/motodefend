extends EnemyBase
## SQL Injection - slow bruiser with a warned lunge and injection burst.

var lunge_timer: float = 3.0
var is_lunging: bool = false
var lunge_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	max_health = 100
	damage = 25
	move_speed = 70.0
	score_value = 25
	super._ready()

func handle_ai(delta: float) -> void:
	if not player or is_lunging:
		return

	lunge_timer -= delta
	if lunge_timer <= 0.0:
		var distance := global_position.distance_to(player.global_position)
		if distance < 330.0:
			_start_lunge()
			lunge_timer = randf_range(4.0, 6.0)
			return

	super.handle_ai(delta)

func _start_lunge() -> void:
	if not player:
		return

	is_lunging = true
	lunge_direction = (player.global_position - global_position).normalized()
	velocity = Vector2.ZERO
	modulate = Color(1.4, 0.75, 0.45)
	_spawn_line_warning(global_position, lunge_direction, 300.0, 46.0, 0.35, Color(1.0, 0.25, 0.1, 0.30))
	await get_tree().create_timer(0.35).timeout
	if is_dead:
		return

	velocity = lunge_direction * move_speed * 4.2
	modulate = Color(2.0, 0.5, 0.5)
	await get_tree().create_timer(0.42).timeout
	if is_dead:
		return

	velocity = Vector2.ZERO
	_spawn_injection_burst()
	await get_tree().create_timer(0.18).timeout
	if not is_dead:
		is_lunging = false
		modulate = Color.WHITE

func _spawn_injection_burst() -> void:
	var warning := _spawn_area_warning(global_position, 92.0, 0.22, Color(1.0, 0.25, 0.1, 0.34))
	_damage_player_in_radius(global_position, 92.0, int(damage * 1.2), 360.0)
	await get_tree().create_timer(0.22).timeout
	if is_instance_valid(warning):
		warning.queue_free()
