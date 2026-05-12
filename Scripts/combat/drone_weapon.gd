extends CharacterBody2D
## Dron autonomiczny – krąży wokół gracza i atakuje pobliskich wrogów

enum DroneState { ORBITING, ATTACKING, RETURNING }

var current_weapon: WeaponBase
var player_ref: Node2D
var orbit_angle: float = 0.0
var orbit_radius: float = 120.0
var attack_timer: float = 0.0
var state: DroneState = DroneState.ORBITING
var target_enemy: Node2D
var attack_elapsed: float = 0.0
var return_elapsed: float = 0.0
var attack_start_pos: Vector2

func initialize(p_player_ref: Node2D, weapon_data: WeaponBase) -> void:
	player_ref = p_player_ref
	current_weapon = weapon_data

	# Placeholder sprite – kwadrat 16×16 w kolorze cyjan (do zastąpienia teksturą)
	var placeholder_image := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	placeholder_image.fill(Color.WHITE)
	var placeholder_texture := ImageTexture.create_from_image(placeholder_image)

	var sprite := Sprite2D.new()
	sprite.name = "DroneSprite"
	sprite.texture = placeholder_texture
	sprite.modulate = Color.CYAN
	add_child(sprite)

	# Kolizja – okrąg o promieniu 10
	var collision_shape := CollisionShape2D.new()
	collision_shape.name = "CollisionShape2D"
	var circle_shape := CircleShape2D.new()
	circle_shape.radius = 10.0
	collision_shape.shape = circle_shape
	add_child(collision_shape)

	# Dron nie koliduje z niczym – pozycja sterowana manualnie
	collision_layer = 0
	collision_mask = 0

	# Startowa pozycja przy graczu
	global_position = player_ref.global_position

	# Dodaj do głównej sceny
	get_tree().current_scene.add_child(self)

func _physics_process(delta: float) -> void:
	# Gracz nie żyje – zniszcz drona
	if not player_ref or not is_instance_valid(player_ref):
		queue_free()
		return

	match state:
		DroneState.ORBITING:
			_update_orbit(delta)
			_update_attack_timer(delta)
		DroneState.ATTACKING:
			_process_attack(delta)
		DroneState.RETURNING:
			_process_return(delta)

func _update_orbit(delta: float) -> void:
	orbit_angle += 2.0 * delta
	var offset := Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_radius
	global_position = player_ref.global_position + offset

func _update_attack_timer(delta: float) -> void:
	if attack_timer > 0.0:
		attack_timer -= delta
		return

	var enemy := _find_closest_enemy()
	if enemy:
		_start_attack(enemy)
	else:
		attack_timer = current_weapon.attack_speed

func _find_closest_enemy() -> Node2D:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("Enemies")
	var closest: Node2D = null
	var closest_dist := current_weapon.weapon_range

	for enemy: Node in enemies:
		if enemy is Node2D:
			var dist := global_position.distance_to(enemy.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest = enemy

	return closest

func _start_attack(enemy: Node2D) -> void:
	target_enemy = enemy
	attack_elapsed = 0.0
	attack_start_pos = global_position
	state = DroneState.ATTACKING

func _process_attack(delta: float) -> void:
	attack_elapsed += delta

	# Wróg zginął w trakcie lotu – wróć na orbitę
	if not target_enemy or not is_instance_valid(target_enemy):
		_start_return()
		return

	var t := attack_elapsed / 1.0
	if t >= 1.0:
		# Dotarł do wroga – zadaj obrażenia
		if target_enemy.has_method("take_damage"):
			target_enemy.take_damage(current_weapon.damage)
		_start_return()
		return

	# Lerp pozycji w kierunku wroga
	global_position = attack_start_pos.lerp(target_enemy.global_position, t)

func _start_return() -> void:
	return_elapsed = 0.0
	state = DroneState.RETURNING

func _process_return(delta: float) -> void:
	return_elapsed += delta

	var t := return_elapsed / 0.5
	if t >= 1.0:
		# Synchronizuj kąt orbity z aktualną pozycją, aby kontynuować płynnie
		orbit_angle = (global_position - player_ref.global_position).angle()
		state = DroneState.ORBITING
		attack_timer = current_weapon.attack_speed
		return

	# Lerp na pozycję orbity
	var target_pos := player_ref.global_position + Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_radius
	global_position = global_position.lerp(target_pos, t)

func is_ready() -> bool:
	return state == DroneState.ORBITING and attack_timer <= 0.0
