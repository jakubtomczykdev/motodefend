extends Area2D

signal hit_target(target: Node2D)

@export var speed: float = 500.0
@export var damage: int = 10
@export var lifetime: float = 3.0
@export var can_pierce: bool = false
@export var max_pierce_count: int = 0

var direction: Vector2 = Vector2.RIGHT
var owner_node: Node2D
var pierce_count: int = 0
var time_alive: float = 0.0
var hit_bodies: Array[Node] = []

var homing_target: Node2D = null
var homing_strength: float = 0.0

var sprite: Sprite2D
var collision: CollisionShape2D

func _ready() -> void:
	# Standardize collision layers: Layer 4 = Projectiles
	collision_layer = 8 
	collision_mask = 2 | 1 # Enemies | Walls

	if has_node("Sprite2D"):
		sprite = $Sprite2D
		if sprite and not sprite.texture:
			_generate_projectile_texture()
	if has_node("CollisionShape2D"):
		collision = $CollisionShape2D

	body_entered.connect(_on_body_entered)
	z_index = 10
	add_to_group("Projectiles")

func _generate_projectile_texture() -> void:
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for x in range(16):
		for y in range(16):
			var dx := x - 8
			var dy := y - 8
			if dx * dx + dy * dy < 36:
				img.set_pixel(x, y, Color(0.3, 0.8, 1, 1 - sqrt(dx*dx + dy*dy) / 8.0))
	var tex := ImageTexture.create_from_image(img)
	if sprite:
		sprite.texture = tex

func _physics_process(delta: float) -> void:
	if homing_target and is_instance_valid(homing_target):
		var target_dir := (homing_target.global_position - global_position).normalized()
		direction = direction.lerp(target_dir, homing_strength * delta).normalized()

	var movement := direction * speed * delta
	
	# RAYCAST COLLISION (dla bardzo szybkich pocisków - zapobiega przelatywaniu przez sprite)
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(global_position, global_position + movement)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	# Wykluczamy siebie i właściciela
	var exclude := [self]
	if owner_node:
		exclude.append(owner_node)
	query.exclude = exclude
	
	var result := space_state.intersect_ray(query)
	if result:
		_handle_collision(result.collider)
		# Nawet jeśli trafiliśmy, przesuwamy pocisk do miejsca trafienia przed queue_free
		global_position = result.position
		return

	global_position += movement

	if direction.length() > 0:
		rotation = direction.angle()

	time_alive += delta
	if time_alive >= lifetime:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	_handle_collision(body)

func _handle_collision(collider: Node) -> void:
	if not is_instance_valid(collider) or collider == owner_node:
		return

	# Zapobiegaj podwójnemu trafieniu tego samego obiektu
	if hit_bodies.has(collider):
		return
	hit_bodies.append(collider)

	# Szukamy właściwego obiektu do zadania obrażeń (ciało wroga lub jego rodzic/dziecko)
	var target_body = collider
	
	# Jeśli trafiliśmy w coś, co nie jest w grupie wrogów, sprawdźmy rodzica (np. Area2D -> CharacterBody2D)
	if not target_body.is_in_group("Enemies"):
		if target_body.get_parent() and target_body.get_parent().is_in_group("Enemies"):
			target_body = target_body.get_parent()
	
	if target_body.is_in_group("Enemies"):
		if target_body.get("is_dead") == true:
			return
			
		if target_body.has_method("take_damage"):
			target_body.take_damage(damage)
		
		hit_target.emit(target_body)

		if not can_pierce or pierce_count >= max_pierce_count:
			queue_free()
		else:
			pierce_count += 1
	elif target_body.is_in_group("Player"):
		if target_body.has_method("take_damage"):
			var kb_dir = direction
			target_body.take_damage(damage, kb_dir * 100.0)
		queue_free()
	elif collider is StaticBody2D or collider is TileMap or (collider is PhysicsBody2D and collider.collision_layer & 1):
		# Ściana
		queue_free()
	# Inne Area2D (np. pociski) ignorujemy

func set_direction(new_direction: Vector2) -> void:
	direction = new_direction.normalized()
	if direction.length() > 0:
		rotation = direction.angle()
