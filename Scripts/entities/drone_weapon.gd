extends CharacterBody2D

enum DroneState { PATROLLING, CHASING, SHOOTING, RETURNING }

var current_weapon: WeaponBase
var player_ref: Node2D
var state: DroneState = DroneState.PATROLLING
var attack_timer: float = 0.0
var target_pos: Vector2 = Vector2.ZERO
var current_target: Node2D = null

var _drone_sprite: Sprite2D
var move_speed: float = 180.0
var patrol_target: Vector2
var patrol_wait_timer: float = 0.0
var detection_range: float = 600.0 # Increased for mouse targeting
var shoot_range: float = 350.0   # Increased for mouse targeting
var return_range: float = 500.0
var projectile_scene: PackedScene = preload("res://scenes/game/Projectile.tscn")

func initialize(p_player_ref: Node2D, weapon_data: WeaponBase) -> void:
	player_ref = p_player_ref
	current_weapon = weapon_data

	_drone_sprite = Sprite2D.new()
	if weapon_data.icon:
		_drone_sprite.texture = weapon_data.icon
	else:
		var tex := load("res://Assets/newAssets/fightingDrone.png") as Texture2D
		if not tex:
			tex = load("res://Assets/newAssets/oldDrone.png") as Texture2D
		_drone_sprite.texture = tex
	_drone_sprite.scale = Vector2(0.10, 0.10)
	if _drone_sprite.get_parent() == null:
		add_child(_drone_sprite)

	# UNIQUE LOGIC: Fighting Drone is faster and more aggressive
	if "Bojowy" in weapon_data.item_name or weapon_data.rarity == "legendary":
		move_speed = 250.0
		detection_range = 800.0
		shoot_range = 450.0
		_drone_sprite.modulate = Color(1.2, 1.2, 1.2, 1.0) # Glow effect

	var collision_shape := CollisionShape2D.new()
	var circle_shape := CircleShape2D.new()
	circle_shape.radius = 10.0
	collision_shape.shape = circle_shape
	
	if collision_shape.get_parent() == null:
		add_child(collision_shape)
	collision_layer = 0
	collision_mask = 0

	global_position = player_ref.global_position + Vector2(randf_range(-100, 100), randf_range(-100, 100))
	_pick_patrol_target()

func _pick_patrol_target() -> void:
	var viewport := get_viewport_rect().size
	patrol_target = Vector2(
		randf_range(80, viewport.x - 80),
		randf_range(80, viewport.y - 80)
	)
	patrol_wait_timer = randf_range(0.5, 2.0)

func update_drone(_p_target_pos: Vector2) -> void:
	# Drones are now autonomous, but we keep the method for compatibility
	pass

func _physics_process(delta: float) -> void:
	if not is_inside_tree():
		return
	if not player_ref or not is_instance_valid(player_ref):
		queue_free()
		return

	# Auto-target nearest enemy
	_find_nearest_target()

	attack_timer -= delta

	match state:
		DroneState.PATROLLING:
			_process_patrol(delta)
		DroneState.CHASING:
			_process_chase(delta)
		DroneState.SHOOTING:
			_process_shoot(delta)
		DroneState.RETURNING:
			_process_return(delta)

	_check_transitions()

func _check_transitions() -> void:
	var dist_to_player := global_position.distance_to(player_ref.global_position)

	if dist_to_player > return_range:
		state = DroneState.RETURNING
		current_target = null
		return

	if is_instance_valid(current_target) and not current_target.get("is_dead"):
		var enemy_pos = current_target.global_position
		var dist_to_target := global_position.distance_to(enemy_pos)
		
		if dist_to_target <= shoot_range and attack_timer <= 0:
			state = DroneState.SHOOTING
			target_pos = enemy_pos
		elif dist_to_target < detection_range:
			state = DroneState.CHASING
			target_pos = enemy_pos
		else:
			state = DroneState.PATROLLING
			current_target = null
	else:
		state = DroneState.PATROLLING
		current_target = null

func _find_nearest_target() -> void:
	var enemies = get_tree().get_nodes_in_group("Enemies")
	var closest_enemy = null
	var min_dist = detection_range
	
	for enemy in enemies:
		if is_instance_valid(enemy) and not enemy.get("is_dead"):
			var dist = global_position.distance_to(enemy.global_position)
			if dist < min_dist:
				min_dist = dist
				closest_enemy = enemy
	
	current_target = closest_enemy

func _process_patrol(delta: float) -> void:
	if patrol_wait_timer > 0:
		patrol_wait_timer -= delta
		velocity = velocity.move_toward(Vector2.ZERO, move_speed * delta)
		move_and_slide()
		return

	var dist := global_position.distance_to(patrol_target)
	if dist < 30:
		_pick_patrol_target()
		return

	var dir := (patrol_target - global_position).normalized()
	velocity = dir * move_speed * 0.6
	move_and_slide()

	if _drone_sprite:
		if dir.x > 0:
			_drone_sprite.scale.x = abs(_drone_sprite.scale.x)
		else:
			_drone_sprite.scale.x = -abs(_drone_sprite.scale.x)

func _process_chase(_delta: float) -> void:
	var dir := (target_pos - global_position).normalized()
	velocity = dir * move_speed
	move_and_slide()

	if _drone_sprite:
		_drone_sprite.modulate = Color(1, 0.6, 0.2, 1)
		if dir.x > 0:
			_drone_sprite.scale.x = abs(_drone_sprite.scale.x)
		else:
			_drone_sprite.scale.x = -abs(_drone_sprite.scale.x)
	
	if global_position.distance_to(target_pos) > shoot_range:
		velocity *= 1.3

func _process_shoot(delta: float) -> void:
	var dir := (target_pos - global_position).normalized()
	_fire_projectile(dir)

	var dist_to_target := global_position.distance_to(target_pos)
	if dist_to_target > shoot_range * 1.3:
		state = DroneState.CHASING
	else:
		velocity = velocity.move_toward(Vector2.ZERO, move_speed * delta * 0.5)
		move_and_slide()

	if _drone_sprite:
		_drone_sprite.modulate = Color(1, 0.3, 0.1, 1)
		if dir.x > 0:
			_drone_sprite.scale.x = abs(_drone_sprite.scale.x)
		else:
			_drone_sprite.scale.x = -abs(_drone_sprite.scale.x)

func _fire_projectile(direction: Vector2) -> void:
	if attack_timer > 0:
		return

	var proj: Area2D = projectile_scene.instantiate()
	proj.speed = 400
	
	# Mnożnik obrażeń z build systemu gracza
	var dmg_mult: float = 1.0
	if player_ref and "damage" in player_ref:
		dmg_mult = player_ref.damage / 10.0
	proj.damage = int(current_weapon.damage * dmg_mult)
	
	proj.direction = direction
	proj.global_position = global_position
	proj.owner_node = self
	get_tree().current_scene.add_child(proj)

	attack_timer = current_weapon.attack_speed
	AudioManager.play_sfx("drone_shoot")

	# Muzzle flash
	var flash := ColorRect.new()
	flash.size = Vector2(10, 10)
	flash.color = Color(1, 0.6, 0.1, 0.8)
	flash.global_position = global_position + direction * 15 - Vector2(5, 5)
	get_tree().current_scene.add_child(flash)
	var ft := create_tween()
	ft.tween_property(flash, "modulate:a", 0.0, 0.08)
	ft.tween_callback(flash.queue_free)

func _process_return(delta: float) -> void:
	if not player_ref or not is_instance_valid(player_ref):
		queue_free()
		return

	var dist := global_position.distance_to(player_ref.global_position)
	if dist < 80:
		state = DroneState.PATROLLING
		if _drone_sprite:
			_drone_sprite.modulate = Color(1, 1, 1, 1)
		return

	var dir := (player_ref.global_position - global_position).normalized()
	velocity = dir * move_speed * 1.3
	move_and_slide()

	if _drone_sprite:
		_drone_sprite.modulate = Color(1, 1, 1, 0.5)

func is_ready() -> bool:
	return attack_timer <= 0
