extends EnemyBase
## Spyware - keeps distance, shoots, and occasionally tags the player with a laser scan.

@export var shoot_cooldown: float = 4.8
@export var projectile_speed: float = 300.0
@export var scan_cooldown: float = 7.0

var shoot_timer: float = 0.0
var scan_timer: float = 0.0
var is_scanning: bool = false
var projectile_scene: PackedScene = preload("res://scenes/game/Projectile.tscn")

func _ready() -> void:
	max_health = 40
	move_speed = 80.0
	score_value = 20
	shoot_timer = randf_range(1.0, 4.0)
	scan_timer = randf_range(2.0, scan_cooldown)
	super._ready()

func handle_ai(delta: float) -> void:
	if is_scanning:
		velocity = Vector2.ZERO
		return

	if not player or not is_instance_valid(player):
		super.handle_ai(delta)
		return

	var distance := global_position.distance_to(player.global_position)
	if distance < 300.0:
		var direction := (global_position - player.global_position).normalized()
		velocity = direction * move_speed
	elif distance > 470.0:
		var direction := (player.global_position - global_position).normalized()
		velocity = direction * move_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, move_speed * delta)

	shoot_timer -= delta
	scan_timer -= delta
	if scan_timer <= 0.0 and distance < 620.0:
		_start_scan_shot()
		scan_timer = scan_cooldown * randf_range(0.85, 1.2)
	elif shoot_timer <= 0.0 and distance < 580.0:
		shoot()
		shoot_timer = shoot_cooldown * randf_range(0.85, 1.15)

	if sprite and "scale" in sprite:
		if velocity.x > 0:
			sprite.scale.x = abs(sprite.scale.x)
		elif velocity.x < 0:
			sprite.scale.x = -abs(sprite.scale.x)

func shoot() -> void:
	if not player or not is_instance_valid(player):
		return

	var direction := (player.global_position - global_position).normalized()
	var proj = projectile_scene.instantiate()

	proj.global_position = global_position
	proj.direction = direction
	proj.speed = projectile_speed
	proj.damage = damage
	proj.owner_node = self
	proj.add_to_group("EnemyProjectiles")
	get_tree().current_scene.add_child(proj)

	await get_tree().process_frame
	if is_instance_valid(proj):
		proj.collision_layer = 16
		proj.collision_mask = 4 | 1
		var p_sprite = proj.get_node_or_null("Sprite2D")
		if p_sprite:
			p_sprite.modulate = Color(1, 0.2, 0.2, 1)

func _start_scan_shot() -> void:
	if not player or not is_instance_valid(player):
		return

	is_scanning = true
	var aim_dir: Vector2 = (player.global_position - global_position).normalized()
	_spawn_line_warning(global_position, aim_dir, 720.0, 16.0, 0.7, Color(1.0, 0.05, 0.05, 0.38))
	modulate = Color(1.4, 0.55, 0.55)
	await get_tree().create_timer(0.7).timeout
	if is_dead:
		return

	if player and is_instance_valid(player) and player.has_method("take_damage"):
		var to_player: Vector2 = player.global_position - global_position
		var distance_along: float = to_player.dot(aim_dir)
		var perpendicular: float = abs(to_player.cross(aim_dir))
		if distance_along > 0.0 and distance_along < 720.0 and perpendicular < 28.0:
			player.take_damage(int(damage * 1.45), aim_dir * 320.0)

	modulate = Color.WHITE
	is_scanning = false
