extends EnemyBase
## Smurf Attack boss. Throws packet minions at the player and spawns them into the arena.

const SMURF_MINION_SCENE := preload("res://scenes/Enemies/SmurfMinion.tscn")

@export var throw_cooldown: float = 3.0
@export var throw_windup: float = 0.65
@export var minion_launch_speed: float = 650.0
@export var max_active_minions: int = 8
@export var retreat_distance: float = 380.0
@export var wall_probe_distance: float = 86.0

var _throw_timer: float = 1.2
var _windup_timer: float = 0.0
var _is_throwing: bool = false

func _ready() -> void:
	max_health = 760
	damage = 24
	move_speed = 142.0
	attack_cooldown = 1.05
	knockback_resistance = 0.7
	score_value = 180
	xp_value = 82
	gold_reward = 140
	is_boss = true
	super._ready()
	set_meta("boss_name", "SMURF ATTACK")

func handle_ai(delta: float) -> void:
	if is_dead:
		return
	if not player or not is_instance_valid(player):
		super.handle_ai(delta)
		return

	if _is_throwing:
		velocity = Vector2.ZERO
		_windup_timer -= delta
		if _windup_timer <= 0.0:
			_finish_throw()
		return

	_throw_timer -= delta
	if _throw_timer <= 0.0 and _get_active_minion_count() < max_active_minions:
		_start_throw()
		return

	var away := (global_position - player.global_position).normalized()
	var distance := global_position.distance_to(player.global_position)
	if distance < retreat_distance and away != Vector2.ZERO:
		velocity = _get_retreat_velocity(away)
	else:
		var strafe := (player.global_position - global_position).normalized().orthogonal()
		velocity = strafe * move_speed * 0.55

	if sprite and "scale" in sprite and velocity.length() > 1.0:
		if player.global_position.x > global_position.x:
			sprite.scale.x = abs(sprite.scale.x)
		else:
			sprite.scale.x = -abs(sprite.scale.x)

func _get_retreat_velocity(away: Vector2) -> Vector2:
	var best_direction := away
	var best_score := -INF
	var candidates := [
		away,
		away.rotated(PI * 0.28),
		away.rotated(-PI * 0.28),
		away.orthogonal(),
		-away.orthogonal()
	]

	for candidate in candidates:
		var direction: Vector2 = candidate.normalized()
		if direction == Vector2.ZERO:
			continue
		if test_move(global_transform, direction * wall_probe_distance):
			continue
		var predicted_position := global_position + direction * wall_probe_distance
		var score := predicted_position.distance_to(player.global_position)
		if direction.dot(away) > 0.45:
			score += 120.0
		if score > best_score:
			best_score = score
			best_direction = direction

	return best_direction * move_speed

func _start_throw() -> void:
	_is_throwing = true
	_windup_timer = throw_windup
	modulate = Color(0.5, 0.9, 1.0)
	if player and is_instance_valid(player):
		var direction := (player.global_position - global_position).normalized()
		if direction == Vector2.ZERO:
			direction = Vector2.RIGHT
		_spawn_line_warning(global_position, direction, 520.0, 48.0, throw_windup, Color(0.1, 0.7, 1.0, 0.32))

func _finish_throw() -> void:
	_is_throwing = false
	modulate = Color.WHITE
	_throw_timer = throw_cooldown * randf_range(0.85, 1.2)
	_spawn_thrown_minion()

func _spawn_thrown_minion() -> void:
	if not player or not is_instance_valid(player):
		return
	var minion := SMURF_MINION_SCENE.instantiate() as Node2D
	if minion == null:
		return
	var direction := (player.global_position - global_position).normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	minion.global_position = global_position + direction * 58.0 + Vector2(0, -18)
	var target_parent := get_parent()
	if target_parent == null:
		target_parent = get_tree().current_scene
	target_parent.add_child(minion)
	if minion.has_method("scale_stats"):
		minion.scale_stats(current_wave_number)
	if minion.has_method("launch_at"):
		minion.launch_at(player.global_position, minion_launch_speed)

func _get_active_minion_count() -> int:
	var count := 0
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		if enemy and str(enemy.name).begins_with("SmurfMinion"):
			count += 1
	return count

func die() -> void:
	_clear_owned_minions()
	super.die()

func _clear_owned_minions() -> void:
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		if enemy and enemy != self and str(enemy.name).begins_with("SmurfMinion"):
			enemy.queue_free()
