extends EnemyBase
## Data Hijacker - wave 5 boss. Telegraphs a hijack lane, then rushes the player.

enum HijackerState { STALKING, WINDUP, DASHING, RECOVERING }

@export var dash_cooldown: float = 3.2
@export var dash_windup: float = 0.85
@export var dash_duration: float = 0.62
@export var dash_speed: float = 980.0
@export var dash_range: float = 760.0
@export var dash_width: float = 96.0

var _state: HijackerState = HijackerState.STALKING
var _dash_timer: float = 2.2
var _state_timer: float = 0.0
var _dash_direction: Vector2 = Vector2.RIGHT
var _dash_hit_done: bool = false
var _telegraph: ColorRect

func _ready() -> void:
	max_health = 680
	damage = 30
	move_speed = 132.0
	attack_cooldown = 0.9
	knockback_resistance = 0.65
	score_value = 150
	xp_value = 70
	gold_reward = 120
	is_boss = true
	super._ready()
	set_meta("boss_name", "DATA HIJACKER")

func handle_ai(delta: float) -> void:
	if is_dead:
		return
	if not player or not is_instance_valid(player):
		super.handle_ai(delta)
		return

	match _state:
		HijackerState.STALKING:
			_dash_timer -= delta
			var distance := global_position.distance_to(player.global_position)
			if _dash_timer <= 0.0 and distance <= dash_range:
				_start_dash_windup()
				return
			super.handle_ai(delta)
		HijackerState.WINDUP:
			velocity = Vector2.ZERO
			_state_timer -= delta
			_update_telegraph()
			if _state_timer <= 0.0:
				_start_dash()
		HijackerState.DASHING:
			_state_timer -= delta
			velocity = _dash_direction * dash_speed
			_try_dash_hit()
			if _state_timer <= 0.0:
				_start_recovery()
		HijackerState.RECOVERING:
			_state_timer -= delta
			velocity = Vector2.ZERO
			if _state_timer <= 0.0:
				_state = HijackerState.STALKING
				_dash_timer = dash_cooldown * randf_range(0.85, 1.15)
				modulate = Color.WHITE

	if sprite and "scale" in sprite and velocity.length() > 1.0:
		if velocity.x > 0:
			sprite.scale.x = abs(sprite.scale.x)
		elif velocity.x < 0:
			sprite.scale.x = -abs(sprite.scale.x)

func _start_dash_windup() -> void:
	_state = HijackerState.WINDUP
	_state_timer = dash_windup
	_dash_hit_done = false
	_dash_direction = (player.global_position - global_position).normalized()
	if _dash_direction == Vector2.ZERO:
		_dash_direction = Vector2.RIGHT
	modulate = Color(1.0, 0.82, 0.35)
	_spawn_telegraph()

func _spawn_telegraph() -> void:
	_clear_telegraph()
	_telegraph = ColorRect.new()
	_telegraph.name = "HijackDashTelegraph"
	_telegraph.size = Vector2(dash_range, dash_width)
	_telegraph.pivot_offset = Vector2(0.0, dash_width * 0.5)
	_telegraph.global_position = global_position
	_telegraph.rotation = _dash_direction.angle()
	_telegraph.color = Color(1.0, 0.85, 0.1, 0.24)
	_telegraph.z_index = 2
	get_tree().current_scene.add_child(_telegraph)

func _update_telegraph() -> void:
	if not _telegraph or not is_instance_valid(_telegraph):
		return
	var progress := 1.0 - clampf(_state_timer / dash_windup, 0.0, 1.0)
	_telegraph.global_position = global_position
	_telegraph.rotation = _dash_direction.angle()
	_telegraph.color = Color(1.0, lerpf(0.82, 0.05, progress), 0.02, lerpf(0.24, 0.68, progress))

func _start_dash() -> void:
	_state = HijackerState.DASHING
	_state_timer = dash_duration
	modulate = Color(1.0, 0.18, 0.12)
	_clear_telegraph()

func _start_recovery() -> void:
	_state = HijackerState.RECOVERING
	_state_timer = 0.45
	velocity = Vector2.ZERO
	modulate = Color(0.65, 0.95, 1.0)

func _try_dash_hit() -> void:
	if _dash_hit_done or not player or not is_instance_valid(player):
		return
	if global_position.distance_to(player.global_position) > 98.0:
		return
	if player.has_method("take_damage"):
		_dash_hit_done = true
		player.take_damage(int(damage * 1.75), _dash_direction * 820.0)

func attack() -> void:
	if _state == HijackerState.DASHING:
		_try_dash_hit()
		return
	super.attack()

func die() -> void:
	_clear_telegraph()
	super.die()

func _clear_telegraph() -> void:
	if _telegraph and is_instance_valid(_telegraph):
		_telegraph.queue_free()
	_telegraph = null
