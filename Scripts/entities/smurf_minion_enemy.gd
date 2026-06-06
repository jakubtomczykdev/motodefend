extends EnemyBase
## Small Smurf Attack packet minion. Can be thrown by the boss, then chases the player.

@export var launch_duration: float = 0.55
@export var impact_radius: float = 44.0
@export var impact_damage_multiplier: float = 1.35

var _launch_velocity: Vector2 = Vector2.ZERO
var _launch_timer: float = 0.0
var _has_impacted: bool = false

func _ready() -> void:
	max_health = 42
	damage = 9
	move_speed = 168.0
	attack_cooldown = 0.75
	knockback_resistance = 0.15
	score_value = 18
	xp_value = 12
	gold_reward = 10
	super._ready()

func launch_at(target_position: Vector2, launch_speed: float = 560.0) -> void:
	var direction := (target_position - global_position).normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	_launch_velocity = direction * launch_speed
	_launch_timer = launch_duration
	_has_impacted = false
	modulate = Color(0.55, 0.95, 1.0)

func handle_ai(delta: float) -> void:
	if is_dead:
		return
	if _launch_timer > 0.0:
		_launch_timer -= delta
		velocity = _launch_velocity
		_try_impact_player()
		if _launch_timer <= 0.0:
			modulate = Color.WHITE
		return
	super.handle_ai(delta)

func _try_impact_player() -> void:
	if _has_impacted or not player or not is_instance_valid(player):
		return
	if global_position.distance_to(player.global_position) > impact_radius:
		return
	if player.has_method("take_damage"):
		_has_impacted = true
		var direction := (player.global_position - global_position).normalized()
		if direction == Vector2.ZERO:
			direction = _launch_velocity.normalized()
		player.take_damage(int(damage * impact_damage_multiplier), direction * 460.0)
