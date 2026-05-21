extends EnemyBase
## Spyware - dystansowy przeciwnik strzelający czerwonymi pociskami

@export var shoot_cooldown: float = 5.0
@export var projectile_speed: float = 300.0
var shoot_timer: float = 0.0
var projectile_scene: PackedScene = preload("res://scenes/game/Projectile.tscn")

func _ready() -> void:
	max_health = 40
	move_speed = 80.0
	score_value = 20
	detection_range = 600.0
	shoot_timer = randf_range(1.0, 5.0) # Losowy start by nie strzelały wszystkie naraz
	super._ready()

func _physics_process(delta: float) -> void:
	# Spyware próbuje utrzymać dystans
	if player and is_instance_valid(player):
		var distance = global_position.distance_to(player.global_position)
		if distance < 300:
			# Uciekaj
			var direction = (global_position - player.global_position).normalized()
			velocity = direction * move_speed
		elif distance > 450:
			# Podchodź
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * move_speed
		else:
			# Stój i celuj
			velocity = velocity.move_toward(Vector2.ZERO, move_speed * delta)
			
		shoot_timer -= delta
		if shoot_timer <= 0:
			shoot()
			shoot_timer = shoot_cooldown
			
	super._physics_process(delta)

func shoot() -> void:
	if not player or not is_instance_valid(player):
		return
		
	var direction = (player.global_position - global_position).normalized()
	var proj = projectile_scene.instantiate()
	
	proj.global_position = global_position
	proj.direction = direction
	proj.speed = projectile_speed
	proj.damage = damage
	proj.owner_node = self
	
	# Zmiana wyglądu na czerwony pocisk wroga
	get_tree().current_scene.add_child(proj)
	
	# Musimy poczekać klatkę aż _ready pocisku się wykona by zmienić kolor
	await get_tree().process_frame
	if is_instance_valid(proj):
		proj.collision_layer = 16 # Layer 5: Enemy Projectiles
		proj.collision_mask = 4 | 1 # Layer 3 (Player) | Layer 1 (Walls)
		var p_sprite = proj.get_node_or_null("Sprite2D")
		if p_sprite:
			p_sprite.modulate = Color(1, 0.2, 0.2, 1) # Czerwony
