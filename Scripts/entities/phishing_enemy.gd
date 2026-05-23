extends EnemyBase
## Phishing - fast skirmisher that moves in zigzags and fires bait volleys.

var zigzag_timer: float = 0.0
var zigzag_direction: int = 1

@export var shoot_cooldown: float = 2.2
@export var shoot_range: float = 430.0
var shoot_timer: float = 0.0

func _ready() -> void:
	max_health = 30
	move_speed = 150.0
	score_value = 15
	super._ready()
	shoot_timer = randf_range(0.5, 1.5)

func handle_ai(delta: float) -> void:
	if not player:
		super.handle_ai(delta)
		return

	zigzag_timer -= delta
	if zigzag_timer <= 0:
		zigzag_timer = randf_range(0.3, 0.6)
		zigzag_direction *= -1

	var distance := global_position.distance_to(player.global_position)
	var dir_to_player := (player.global_position - global_position).normalized()
	var final_dir: Vector2
	if distance < 250.0:
		final_dir = (dir_to_player.rotated(PI / 2.0) * zigzag_direction).normalized()
	else:
		var side_dir := dir_to_player.rotated(PI / 2.0) * zigzag_direction
		final_dir = (dir_to_player + side_dir * 0.8).normalized()

	velocity = final_dir * move_speed

	shoot_timer -= delta
	if shoot_timer <= 0.0 and distance < shoot_range:
		_shoot_bait_fan()
		shoot_timer = shoot_cooldown * randf_range(0.85, 1.25)

	if sprite and "scale" in sprite:
		if velocity.x > 0:
			sprite.scale.x = abs(sprite.scale.x)
		elif velocity.x < 0:
			sprite.scale.x = -abs(sprite.scale.x)

func _shoot_bait_fan() -> void:
	if not player or not is_instance_valid(player):
		return

	var base_dir := (player.global_position - global_position).normalized()
	_spawn_line_warning(global_position, base_dir, 260.0, 18.0, 0.22, Color(0.95, 0.25, 1.0, 0.22))

	for angle_offset in [-0.22, 0.0, 0.22]:
		_spawn_enemy_projectile(base_dir.rotated(angle_offset), int(damage * 0.65), 440.0, Color(1.0, 0.25, 1.0, 1.0))

func _spawn_enemy_projectile(direction: Vector2, hit_damage: int, speed: float, color: Color) -> void:
	var projectile_scene = load("res://scenes/game/Projectile.tscn")
	if not projectile_scene:
		return

	var p = projectile_scene.instantiate()
	p.global_position = global_position
	p.direction = direction.normalized()
	p.damage = hit_damage
	p.speed = speed
	p.owner_node = self
	p.add_to_group("EnemyProjectiles")
	get_tree().current_scene.add_child(p)

	await get_tree().process_frame
	if is_instance_valid(p):
		p.collision_layer = 16
		p.collision_mask = 4 | 1
		var p_sprite = p.get_node_or_null("Sprite2D")
		if p_sprite:
			p_sprite.modulate = color
