extends EnemyBase
## Phishing - szybki, ale słaby wróg. Porusza się zygzakiem.

var zigzag_timer: float = 0.0
var zigzag_direction: int = 1

@export var shoot_cooldown: float = 2.0
@export var shoot_range: float = 400.0
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
	if distance < detection_range:
		var dir_to_player = (player.global_position - global_position).normalized()
		
		# Phishing próbuje trzymać dystans, ale poruszać się zygzakiem
		var final_dir: Vector2
		if distance < 250: # Za blisko, wycofaj się trochę lub stój
			final_dir = (dir_to_player.rotated(PI/2) * zigzag_direction).normalized()
		else:
			var side_dir = dir_to_player.rotated(PI/2) * zigzag_direction
			final_dir = (dir_to_player + side_dir * 0.8).normalized()
			
		velocity = final_dir * move_speed
		
		# Shooting logic
		shoot_timer -= delta
		if shoot_timer <= 0 and distance < shoot_range:
			_shoot()
			shoot_timer = shoot_cooldown * randf_range(0.8, 1.2)
		
		if sprite and "scale" in sprite:
			if velocity.x > 0:
				sprite.scale.x = abs(sprite.scale.x)
			elif velocity.x < 0:
				sprite.scale.x = -abs(sprite.scale.x)
	else:
		_handle_wander(delta)

func _shoot() -> void:
	if not player: return
	
	var projectile_scene = load("res://scenes/Projectile.tscn")
	if not projectile_scene: return
	
	var p = projectile_scene.instantiate()
	p.global_position = global_position
	p.direction = (player.global_position - global_position).normalized()
	p.damage = damage
	p.speed = 400.0
	p.collision_mask = 1 | 4 # Walls | Player
	p.add_to_group("EnemyProjectiles")
	get_tree().current_scene.add_child(p)
