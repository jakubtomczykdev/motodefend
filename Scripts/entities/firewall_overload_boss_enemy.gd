extends EnemyBase
## Firewall Overload boss. Controls space with firewall walls, flame volleys and pulse bursts.

const PROJECTILE_SCENE := preload("res://scenes/game/Projectile.tscn")

enum FirewallState { ORBITING, WALL_WINDUP, WALL_ACTIVE, FLAME_WINDUP, FLAME_BURST, PULSE_WINDUP, RECOVERING }

@export var desired_distance: float = 340.0
@export var firewall_cooldown: float = 4.1
@export var firewall_windup: float = 0.85
@export var firewall_duration: float = 1.9
@export var firewall_length: float = 720.0
@export var firewall_width: float = 72.0
@export var firewall_tick_interval: float = 0.48
@export var pulse_cooldown: float = 6.6
@export var pulse_windup: float = 1.05
@export var pulse_radius: float = 180.0
@export var flame_cooldown: float = 5.2
@export var flame_windup: float = 0.72
@export var flame_projectile_speed: float = 430.0
@export var flame_projectile_lifetime: float = 2.2
@export var flame_projectile_count: int = 5
@export var flame_projectile_interval: float = 0.13
@export var flame_spread_degrees: float = 12.0

var _state: FirewallState = FirewallState.ORBITING
var _state_timer: float = 0.0
var _firewall_timer: float = 1.6
var _pulse_timer: float = 3.2
var _flame_timer: float = 2.4
var _flames_left: int = 0
var _flame_shot_timer: float = 0.0
var _wall_tick_timer: float = 0.0
var _orbit_side: float = 1.0
var _wall_center: Vector2 = Vector2.ZERO
var _wall_direction: Vector2 = Vector2.RIGHT
var _wall_visual: ColorRect
var _pulse_warning: ColorRect
var _charge_visuals: Array[Node] = []
var _flame_texture: Texture2D

func _ready() -> void:
	max_health = 840
	damage = 24
	move_speed = 108.0
	attack_cooldown = 1.15
	knockback_resistance = 0.78
	score_value = 210
	xp_value = 95
	gold_reward = 165
	is_boss = true
	super._ready()
	set_meta("boss_name", "FIREWALL OVERLOAD")

func handle_ai(delta: float) -> void:
	if is_dead:
		return
	if not player or not is_instance_valid(player):
		super.handle_ai(delta)
		return

	match _state:
		FirewallState.ORBITING:
			_handle_orbit(delta)
		FirewallState.WALL_WINDUP:
			velocity = Vector2.ZERO
			_state_timer -= delta
			if _state_timer <= 0.0:
				_start_firewall_active()
		FirewallState.WALL_ACTIVE:
			velocity = Vector2.ZERO
			_state_timer -= delta
			_wall_tick_timer -= delta
			if _wall_tick_timer <= 0.0:
				_wall_tick_timer = firewall_tick_interval
				_damage_player_on_wall()
			if _state_timer <= 0.0:
				_start_recovery(0.55)
		FirewallState.FLAME_WINDUP:
			velocity = Vector2.ZERO
			_state_timer -= delta
			_spawn_charge_spark()
			if _state_timer <= 0.0:
				_start_flame_burst()
		FirewallState.FLAME_BURST:
			velocity = Vector2.ZERO
			_state_timer -= delta
			_flame_shot_timer -= delta
			if _flame_shot_timer <= 0.0 and _flames_left > 0:
				_fire_flame_projectile()
				_flames_left -= 1
				_flame_shot_timer = flame_projectile_interval
			if _state_timer <= 0.0 and _flames_left <= 0:
				_start_recovery(0.52)
		FirewallState.PULSE_WINDUP:
			velocity = Vector2.ZERO
			_state_timer -= delta
			if _state_timer <= 0.0:
				_finish_pulse()
		FirewallState.RECOVERING:
			velocity = Vector2.ZERO
			_state_timer -= delta
			if _state_timer <= 0.0:
				_state = FirewallState.ORBITING
				modulate = Color.WHITE

	if sprite and "scale" in sprite and player and is_instance_valid(player):
		if player.global_position.x > global_position.x:
			sprite.scale.x = abs(sprite.scale.x)
		else:
			sprite.scale.x = -abs(sprite.scale.x)

func handle_boss_special(_delta: float) -> void:
	pass

func _handle_orbit(delta: float) -> void:
	_firewall_timer -= delta
	_pulse_timer -= delta
	_flame_timer -= delta

	var distance := global_position.distance_to(player.global_position)
	if _pulse_timer <= 0.0 and distance <= pulse_radius + 130.0:
		_start_pulse()
		return
	if _flame_timer <= 0.0 and distance <= 820.0:
		_start_flame_windup()
		return
	if _firewall_timer <= 0.0:
		_start_firewall_windup()
		return

	var to_player := player.global_position - global_position
	var direction := to_player.normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	var tangent := direction.orthogonal() * _orbit_side
	var radial := Vector2.ZERO
	if distance > desired_distance + 70.0:
		radial = direction * 0.75
	elif distance < desired_distance - 90.0:
		radial = -direction * 0.9

	var move_direction := (tangent * 0.72 + radial).normalized()
	if move_direction == Vector2.ZERO:
		move_direction = tangent
	velocity = move_direction * move_speed

func _start_firewall_windup() -> void:
	_state = FirewallState.WALL_WINDUP
	_state_timer = firewall_windup
	_wall_tick_timer = 0.0
	_orbit_side *= -1.0
	modulate = Color(1.0, 0.64, 0.18)

	var to_player := (player.global_position - global_position).normalized()
	if to_player == Vector2.ZERO:
		to_player = Vector2.RIGHT
	_wall_direction = to_player.orthogonal().normalized()
	_wall_center = player.global_position + to_player * randf_range(-42.0, 42.0)
	var start := _wall_center - _wall_direction * (firewall_length * 0.5)
	_spawn_line_warning(start, _wall_direction, firewall_length, firewall_width, firewall_windup, Color(1.0, 0.48, 0.04, 0.36))

func _start_firewall_active() -> void:
	_state = FirewallState.WALL_ACTIVE
	_state_timer = firewall_duration
	_wall_tick_timer = 0.08
	modulate = Color(1.0, 0.28, 0.08)
	_clear_wall_visual()

	_wall_visual = ColorRect.new()
	_wall_visual.name = "FirewallOverloadWall"
	_wall_visual.color = Color(1.0, 0.22, 0.03, 0.42)
	_wall_visual.size = Vector2(firewall_length, firewall_width)
	_wall_visual.pivot_offset = Vector2(firewall_length * 0.5, firewall_width * 0.5)
	_wall_visual.global_position = _wall_center
	_wall_visual.rotation = _wall_direction.angle()
	_wall_visual.z_index = 2
	get_tree().current_scene.add_child(_wall_visual)

	var tween := get_tree().create_tween()
	tween.bind_node(_wall_visual)
	tween.set_loops()
	tween.tween_property(_wall_visual, "modulate:a", 0.78, 0.16)
	tween.tween_property(_wall_visual, "modulate:a", 0.34, 0.16)

func _damage_player_on_wall() -> void:
	if not player or not is_instance_valid(player) or not player.has_method("take_damage"):
		return
	var start := _wall_center - _wall_direction * (firewall_length * 0.5)
	var end := _wall_center + _wall_direction * (firewall_length * 0.5)
	if _distance_to_segment(player.global_position, start, end) > firewall_width * 0.58:
		return
	var knockback_dir := (player.global_position - _wall_center).normalized()
	if knockback_dir == Vector2.ZERO:
		knockback_dir = _wall_direction.orthogonal()
	player.take_damage(int(damage * 0.72), knockback_dir * 430.0)

func _start_pulse() -> void:
	_state = FirewallState.PULSE_WINDUP
	_state_timer = pulse_windup
	_pulse_timer = pulse_cooldown * randf_range(0.9, 1.15)
	modulate = Color(0.35, 1.0, 0.9)
	_clear_pulse_warning()
	_pulse_warning = _spawn_area_warning(global_position, pulse_radius, pulse_windup, Color(0.1, 0.95, 0.85, 0.28))
	var tween := create_tween()
	tween.bind_node(_pulse_warning)
	tween.tween_property(_pulse_warning, "scale", Vector2(0.12, 0.12), 0.0)
	tween.tween_property(_pulse_warning, "scale", Vector2(1.0, 1.0), pulse_windup).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _finish_pulse() -> void:
	_damage_player_in_radius(global_position, pulse_radius, int(damage * 1.35), 620.0)
	_spawn_pulse_flash()
	_clear_pulse_warning()
	_start_recovery(0.7)

func _spawn_pulse_flash() -> void:
	var flash := ColorRect.new()
	flash.name = "FirewallOverloadPulse"
	flash.color = Color(0.25, 1.0, 0.86, 0.3)
	flash.size = Vector2(pulse_radius * 2.0, pulse_radius * 2.0)
	flash.pivot_offset = flash.size * 0.5
	flash.global_position = global_position - flash.pivot_offset
	flash.z_index = 3
	get_tree().current_scene.add_child(flash)
	var tween := get_tree().create_tween()
	tween.bind_node(flash)
	tween.tween_property(flash, "scale", Vector2(1.25, 1.25), 0.18)
	tween.parallel().tween_property(flash, "modulate:a", 0.0, 0.2)
	tween.tween_callback(flash.queue_free)

func _start_flame_windup() -> void:
	_state = FirewallState.FLAME_WINDUP
	_state_timer = flame_windup
	_flame_timer = flame_cooldown * randf_range(0.9, 1.18)
	modulate = Color(1.0, 0.46, 0.12)
	_spawn_flame_charge()
	if player and is_instance_valid(player):
		var base_dir := (player.global_position - global_position).normalized()
		if base_dir == Vector2.ZERO:
			base_dir = Vector2.RIGHT
		for angle in [-flame_spread_degrees, 0.0, flame_spread_degrees]:
			_spawn_line_warning(global_position, base_dir.rotated(deg_to_rad(angle)), 520.0, 34.0, flame_windup, Color(1.0, 0.34, 0.02, 0.27))

func _start_flame_burst() -> void:
	_state = FirewallState.FLAME_BURST
	_state_timer = flame_projectile_interval * float(flame_projectile_count) + 0.24
	_flames_left = flame_projectile_count
	_flame_shot_timer = 0.0
	modulate = Color(1.0, 0.22, 0.04)
	_clear_charge_visuals()

func _fire_flame_projectile() -> void:
	if not player or not is_instance_valid(player):
		return
	var direction := (player.global_position - global_position).normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	var spread_index := float(_flames_left) - float(flame_projectile_count + 1) * 0.5
	direction = direction.rotated(deg_to_rad(spread_index * flame_spread_degrees * 0.42))
	var spawn_position := global_position + direction * 62.0 + Vector2(0, -18)

	var projectile := PROJECTILE_SCENE.instantiate() as Area2D
	if projectile == null:
		return
	projectile.global_position = spawn_position
	projectile.set("direction", direction)
	projectile.set("speed", flame_projectile_speed)
	projectile.set("damage", int(damage * 0.82))
	projectile.set("lifetime", flame_projectile_lifetime)
	projectile.set("owner_node", self)
	projectile.add_to_group("EnemyProjectiles")

	var target_parent := get_parent()
	if target_parent == null:
		target_parent = get_tree().current_scene
	target_parent.add_child(projectile)
	projectile.collision_mask = 1

	var sprite_node := projectile.get_node_or_null("Sprite2D") as Sprite2D
	if sprite_node:
		sprite_node.texture = _get_flame_texture()
		sprite_node.scale = Vector2(1.55, 1.05)
		sprite_node.modulate = Color(1.0, 0.48, 0.08, 1.0)
	var collision_node := projectile.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_node:
		var shape := CircleShape2D.new()
		shape.radius = 16.0
		collision_node.shape = shape

	_spawn_flame_muzzle_flash(spawn_position, direction)

func _spawn_flame_charge() -> void:
	_clear_charge_visuals()
	for i in range(3):
		var ring := ColorRect.new()
		ring.name = "FirewallFlameCharge"
		ring.color = Color(1.0, 0.26 + i * 0.12, 0.02, 0.24)
		ring.size = Vector2(52.0 + i * 22.0, 52.0 + i * 22.0)
		ring.pivot_offset = ring.size * 0.5
		ring.global_position = global_position - ring.pivot_offset + Vector2(0, -12)
		ring.z_index = 3
		get_tree().current_scene.add_child(ring)
		_charge_visuals.append(ring)
		var tween := get_tree().create_tween()
		tween.bind_node(ring)
		tween.tween_property(ring, "scale", Vector2(1.55, 1.55), flame_windup)
		tween.parallel().tween_property(ring, "modulate:a", 0.0, flame_windup)

func _spawn_charge_spark() -> void:
	if randf() > 0.45:
		return
	var spark := ColorRect.new()
	spark.size = Vector2(randf_range(4.0, 8.0), randf_range(4.0, 8.0))
	spark.color = Color(1.0, randf_range(0.28, 0.78), 0.02, 0.86)
	spark.global_position = global_position + Vector2(randf_range(-48.0, 48.0), randf_range(-48.0, 18.0))
	spark.z_index = 5
	get_tree().current_scene.add_child(spark)
	var tween := get_tree().create_tween()
	tween.bind_node(spark)
	tween.tween_property(spark, "global_position", spark.global_position + Vector2(randf_range(-24.0, 24.0), randf_range(-34.0, -8.0)), 0.22)
	tween.parallel().tween_property(spark, "modulate:a", 0.0, 0.22)
	tween.tween_callback(spark.queue_free)

func _spawn_flame_muzzle_flash(spawn_position: Vector2, direction: Vector2) -> void:
	for i in range(5):
		var ember := ColorRect.new()
		ember.size = Vector2(randf_range(5.0, 12.0), randf_range(3.0, 8.0))
		ember.color = Color(1.0, randf_range(0.22, 0.76), 0.02, 0.9)
		ember.global_position = spawn_position + Vector2(randf_range(-8.0, 8.0), randf_range(-8.0, 8.0))
		ember.rotation = direction.angle()
		ember.z_index = 6
		get_tree().current_scene.add_child(ember)
		var target := ember.global_position + direction.rotated(randf_range(-0.55, 0.55)) * randf_range(28.0, 62.0)
		var tween := get_tree().create_tween()
		tween.bind_node(ember)
		tween.tween_property(ember, "global_position", target, 0.2)
		tween.parallel().tween_property(ember, "modulate:a", 0.0, 0.22)
		tween.tween_callback(ember.queue_free)

func _get_flame_texture() -> Texture2D:
	if _flame_texture:
		return _flame_texture
	var img: Image = Image.create(34, 18, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for x in range(34):
		for y in range(18):
			var center_y: float = 9.0 + sin(float(x) * 0.45) * 2.0
			var distance: float = absf(float(y) - center_y)
			var radius: float = lerpf(8.5, 2.0, float(x) / 33.0)
			if distance <= radius:
				var heat: float = 1.0 - distance / maxf(radius, 0.01)
				var alpha: float = heat * (1.0 - float(x) / 42.0)
				var color := Color(1.0, lerpf(0.16, 0.92, heat), 0.02, alpha)
				if x < 9 and distance < radius * 0.36:
					color = Color(1.0, 0.95, 0.42, alpha)
				img.set_pixel(x, y, color)
	_flame_texture = ImageTexture.create_from_image(img)
	return _flame_texture

func _start_recovery(duration: float) -> void:
	_state = FirewallState.RECOVERING
	_state_timer = duration
	_firewall_timer = firewall_cooldown * randf_range(0.86, 1.2)
	modulate = Color(0.72, 0.9, 1.0)
	_clear_wall_visual()

func _distance_to_segment(point: Vector2, start: Vector2, end: Vector2) -> float:
	var segment := end - start
	var length_sq := segment.length_squared()
	if length_sq <= 0.001:
		return point.distance_to(start)
	var t := clampf((point - start).dot(segment) / length_sq, 0.0, 1.0)
	return point.distance_to(start + segment * t)

func die() -> void:
	_clear_wall_visual()
	_clear_pulse_warning()
	_clear_charge_visuals()
	super.die()

func _clear_wall_visual() -> void:
	if _wall_visual and is_instance_valid(_wall_visual):
		_wall_visual.queue_free()
	_wall_visual = null

func _clear_pulse_warning() -> void:
	if _pulse_warning and is_instance_valid(_pulse_warning):
		_pulse_warning.queue_free()
	_pulse_warning = null

func _clear_charge_visuals() -> void:
	for visual in _charge_visuals:
		if visual and is_instance_valid(visual):
			visual.queue_free()
	_charge_visuals.clear()
