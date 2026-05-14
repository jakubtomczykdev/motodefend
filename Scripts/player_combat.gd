extends CharacterBody2D
## System walki gracza - strzelanie, statystyki, interakcje

const WeaponManagerClass := preload("res://Scripts/combat/weapon_manager.gd")

signal health_changed(current_health: int, max_health: int)
signal died

@export var max_health: int = 100
@export var move_speed: float = 300.0
@export var attack_speed: float = 1.0 # shots per second
@export var damage: int = 10
@export var projectile_speed: float = 500.0
@export var attack_range: float = 400.0

# Nowe zmienne dla mechaniki uniku i walki
@export var dodge_speed: float = 800.0
@export var dodge_duration: float = 0.2
@export var dodge_cooldown: float = 0.6
@export var invulnerability_duration: float = 0.6

@export var crit_chance: float = 0.0
@export var crit_damage: float = 1.5
@export var pierce: int = 0

var current_health: int
var can_shoot: bool = true
var attack_cooldown: float = 0.0

var is_rolling: bool = false
var roll_timer: float = 0.0
var roll_cooldown_timer: float = 0.0
var roll_direction: Vector2 = Vector2.ZERO

var is_invulnerable: bool = false
var invulnerability_timer: float = 0.0
var knockback_velocity: Vector2 = Vector2.ZERO

var sprite: AnimatedSprite2D
var collision: CollisionShape2D
var interaction_area: Area2D
var interaction_prompt: Label
var muzzle: Marker2D # punkt wylotu pocisku

var projectile_scene: PackedScene = preload("res://scenes/Projectile.tscn")
var weapon_manager: Node

var _reticle: ColorRect

func _ready() -> void:
	# Znajdź węzły bezpiecznie
	if has_node("AnimatedSprite2D"):
		sprite = $AnimatedSprite2D
	if has_node("CollisionShape2D"):
		collision = $CollisionShape2D
	if has_node("InteractionArea"):
		interaction_area = $InteractionArea
	if has_node("InteractionPrompt"):
		interaction_prompt = $InteractionPrompt
	if has_node("Muzzle"):
		muzzle = $Muzzle

	current_health = max_health
	health_changed.emit(current_health, max_health)

	if not muzzle:
		# Utwórz muzzle jeśli nie istnieje
		muzzle = Marker2D.new()
		muzzle.name = "Muzzle"
		add_child(muzzle)
		muzzle.position = Vector2(20, 0)

	add_to_group("Player")

	# Inicjalizacja WeaponManager
	weapon_manager = WeaponManagerClass.new()
	weapon_manager.name = "WeaponManager"
	add_child(weapon_manager)

	# Podłącz sloty broni z drzewa sceny do menadżera
	var slot1 := get_node_or_null("WeaponSlot1") as Sprite2D
	var slot2 := get_node_or_null("WeaponSlot2") as Sprite2D

	if not slot1:
		slot1 = get_node_or_null("%WeaponSlot1") as Sprite2D
	if not slot2:
		slot2 = get_node_or_null("%WeaponSlot2") as Sprite2D

	if slot1 or slot2:
		weapon_manager.setup_slots(slot1, slot2)

	_reticle = ColorRect.new()
	_reticle.color = Color(1, 0.2, 0.2, 0.6)
	_reticle.size = Vector2(8, 8)
	_reticle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_reticle.z_index = 100
	add_child(_reticle)

func _process(delta: float) -> void:
	if _reticle:
		_reticle.global_position = get_global_mouse_position() - _reticle.size / 2
	
	handle_cooldown(delta)
	handle_invulnerability(delta)
	update_interaction_prompt()
	
	if weapon_manager and weapon_manager.has_method("update_drones"):
		weapon_manager.update_drones()
	
	if not is_rolling:
		handle_input(delta)
		if weapon_manager and weapon_manager.has_method("activate_all_weapons"):
			var target_pos := get_global_mouse_position()
			if Input.is_action_pressed("attack"):
				weapon_manager.activate_all_weapons(target_pos)
			else:
				# Obracaj broń nawet jeśli nie strzelamy
				if weapon_manager.has_method("rotate_weapon_slots"):
					weapon_manager.rotate_weapon_slots(target_pos)
			
			# Obracaj muzzle w stronę celu (zawsze, niezależnie od ataku)
			if muzzle:
				muzzle.look_at(target_pos)

func _physics_process(delta: float) -> void:
	if is_rolling:
		handle_roll(delta)
	else:
		handle_movement(delta)
	
	# Apply knockback
	if knockback_velocity.length() > 10.0:
		velocity += knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 800.0 * delta)
	else:
		knockback_velocity = Vector2.ZERO

	move_and_slide()
	_clamp_to_screen()
	update_animation()

func handle_input(_delta: float) -> void:
	var direction := Vector2.ZERO

	if Input.is_action_pressed("walk_up"):
		direction.y -= 1
	if Input.is_action_pressed("walk_down"):
		direction.y += 1
	if Input.is_action_pressed("walk_left"):
		direction.x -= 1
	if Input.is_action_pressed("walk_right"):
		direction.x += 1

	if direction != Vector2.ZERO:
		roll_direction = direction.normalized()
		velocity = roll_direction * move_speed
	else:
		velocity = Vector2.ZERO

	# Unik (Dodge Roll)
	if Input.is_action_just_pressed("interact") and current_interactable_in_range():
		interact()
	elif Input.is_action_just_pressed("ui_accept") or Input.is_key_pressed(KEY_SPACE):
		start_roll()

	# Zmiana broni (Weapon Swap)
	if Input.is_action_just_pressed("ui_up") or Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP):
		if weapon_manager and weapon_manager.has_method("switch_weapon"):
			weapon_manager.switch_weapon(false)
	elif Input.is_action_just_pressed("ui_down") or Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN):
		if weapon_manager and weapon_manager.has_method("switch_weapon"):
			weapon_manager.switch_weapon(true)
	
	if Input.is_key_pressed(KEY_1):
		if weapon_manager and weapon_manager.has_method("set_active_weapon"):
			weapon_manager.set_active_weapon(0)
	elif Input.is_key_pressed(KEY_2):
		if weapon_manager and weapon_manager.has_method("set_active_weapon"):
			weapon_manager.set_active_weapon(1)

	# Ataki są obsługiwane przez WeaponManager w _process

func current_interactable_in_range() -> bool:
	var interactables: Array[Node] = get_tree().get_nodes_in_group("Interactable")
	for interactable: Node in interactables:
		if interaction_area and interactable != interaction_area and interactable is Node2D:
			var distance := global_position.distance_to((interactable as Node2D).global_position)
			if distance < 100.0:
				return true
	return false

func start_roll() -> void:
	if is_rolling or roll_cooldown_timer > 0:
		return
	
	is_rolling = true
	roll_timer = dodge_duration
	
	# Apply cooldown reduction
	var cd_reduction: float = 0.0
	var main_node = get_tree().current_scene
	var build_system = main_node.get_node_or_null("BuildSystem")
	if build_system:
		cd_reduction = build_system.get_stat("cooldown_reduction")
	
	roll_cooldown_timer = dodge_cooldown * (1.0 - cd_reduction)
	set_invulnerable(dodge_duration)
	
	# Jeśli gracz nie trzyma kierunku, roll w stronę myszy
	if velocity == Vector2.ZERO:
		roll_direction = (get_global_mouse_position() - global_position).normalized()
	else:
		roll_direction = velocity.normalized()
	
	velocity = roll_direction * dodge_speed

func handle_roll(delta: float) -> void:
	roll_timer -= delta
	velocity = roll_direction * dodge_speed
	
	if roll_timer <= 0:
		is_rolling = false

func handle_movement(_delta: float) -> void:
	# Ruch jest obsługiwany w handle_input
	pass

func handle_cooldown(delta: float) -> void:
	if not can_shoot:
		attack_cooldown -= delta
		if attack_cooldown <= 0:
			can_shoot = true
	
	if roll_cooldown_timer > 0:
		roll_cooldown_timer -= delta

func handle_invulnerability(delta: float) -> void:
	if is_invulnerable:
		invulnerability_timer -= delta
		
		# Efekt wizualny migania
		if sprite:
			sprite.modulate.a = 0.5 if Engine.get_frames_drawn() % 4 < 2 else 1.0
			
		if invulnerability_timer <= 0:
			is_invulnerable = false
			if sprite:
				sprite.modulate.a = 1.0

func set_invulnerable(duration: float) -> void:
	is_invulnerable = true
	invulnerability_timer = max(invulnerability_timer, duration)


func fire_projectile(direction: Vector2) -> void:
	var projectile: Area2D = projectile_scene.instantiate()

	if muzzle:
		projectile.global_position = muzzle.global_position
	else:
		projectile.global_position = global_position

	projectile.direction = direction
	projectile.speed = projectile_speed
	
	# Critical Hit Logic
	var is_crit := randf() < crit_chance
	var final_damage := damage
	if is_crit:
		final_damage = int(damage * crit_damage)
		_spawn_crit_effect(projectile.global_position)

	projectile.damage = final_damage
	
	# Pierce Logic
	if pierce > 0:
		projectile.can_pierce = true
		projectile.max_pierce_count = pierce
		
	projectile.owner_node = self
	get_tree().current_scene.add_child(projectile)

func _spawn_crit_effect(pos: Vector2) -> void:
	var label := Label.new()
	label.text = "KRYTYK!"
	label.modulate = Color(1, 0.8, 0, 1) # Gold
	label.add_theme_font_size_override("font_size", 20)
	label.global_position = pos + Vector2(-30, -40)
	get_tree().current_scene.add_child(label)
	
	var tween := create_tween()
	tween.tween_property(label, "scale", Vector2(1.5, 1.5), 0.1)
	tween.tween_property(label, "global_position:y", label.global_position.y - 60, 0.4)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(label.queue_free)

func find_closest_enemy() -> Node2D:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("Enemies")
	var closest_enemy: Node2D = null
	var closest_distance := attack_range

	for enemy: Node in enemies:
		if enemy is Node2D:
			var distance := global_position.distance_to(enemy.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_enemy = enemy

	return closest_enemy

func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO) -> void:
	if is_invulnerable:
		return

	# Dodge Chance
	var main_node = get_tree().current_scene
	var build_system = main_node.get_node_or_null("BuildSystem")
	if build_system:
		var dodge: float = build_system.get_stat("dodge_chance")
		if randf() < dodge:
			_spawn_dodge_label()
			return

	current_health -= amount
	health_changed.emit(current_health, max_health)
	
	if knockback != Vector2.ZERO:
		knockback_velocity = knockback
	
	set_invulnerable(invulnerability_duration)

	if current_health <= 0:
		die()

func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)

func die() -> void:
	died.emit()
	queue_free()

func _spawn_dodge_label() -> void:
	var label := Label.new()
	label.text = "UNIK!"
	label.modulate = Color(0, 1, 1) # Cyan
	label.global_position = global_position + Vector2(-20, -50)
	get_tree().current_scene.add_child(label)
	
	var tween := create_tween()
	tween.tween_property(label, "global_position:y", label.global_position.y - 40, 0.5)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.6)
	tween.tween_callback(label.queue_free)

func update_animation() -> void:
	if not sprite:
		return

	if is_rolling:
		sprite.play("right" if roll_direction.x >= 0 else "left")
		return

	if velocity.length() > 0:
		var dir = velocity.normalized()
		
		if dir.y < -0.5: # Ruch w górę
			if dir.x > 0.5:
				sprite.play("back-right")
			elif dir.x < -0.5:
				sprite.play("back-left")
			else:
				sprite.play("back")
		elif dir.y > 0.5: # Ruch w dół
			if dir.x > 0.5:
				sprite.play("front-right")
			elif dir.x < -0.5:
				sprite.play("front-left")
			else:
				sprite.play("front")
		else: # Ruch poziomy
			if dir.x > 0:
				sprite.play("right")
			elif dir.x < 0:
				sprite.play("left")
	else:
		sprite.stop()
		# Opcjonalnie: ustaw klatkę spoczynkową (idle) zależnie od ostatniego kierunku
		# Na razie zatrzymujemy na bieżącej klatce lub zerujemy
		sprite.frame = 0

func _clamp_to_screen() -> void:
	global_position.x = clamp(global_position.x, 30, 1890)
	global_position.y = clamp(global_position.y, 30, 1050)

func update_interaction_prompt() -> void:
	var interactables: Array[Node] = get_tree().get_nodes_in_group("Interactable")
	var can_interact := false

	for interactable: Node in interactables:
		if interaction_area and interactable != interaction_area and interactable is Node2D:
			var distance := global_position.distance_to((interactable as Node2D).global_position)
			if distance < 100.0:
				can_interact = true
				break

	if interaction_prompt:
		interaction_prompt.visible = can_interact

func interact() -> void:
	var interactables: Array[Node] = get_tree().get_nodes_in_group("Interactable")

	for interactable: Node in interactables:
		if interaction_area and interactable != interaction_area and interactable is Node2D:
			var distance := global_position.distance_to((interactable as Node2D).global_position)
			if distance < 100.0:
				if interactable.has_method("interact"):
					interactable.call("interact")
				elif interactable.get_parent() and interactable.get_parent().has_method("interact"):
					interactable.get_parent().interact()
				break

func add_weapon(weapon: WeaponBase) -> bool:
	if weapon_manager and weapon_manager.has_method("add_weapon"):
		var result: bool = weapon_manager.add_weapon(weapon)
		print("[DEBUG] player_combat.add_weapon called for ", weapon.item_name, " result=", result)
		return result
	return false

func get_weapon_count() -> int:
	if weapon_manager and weapon_manager.has_method("get_weapon_count"):
		return weapon_manager.get_weapon_count()
	return 0

func get_weapons() -> Array:
	if weapon_manager and weapon_manager.has_method("get_weapons"):
		return weapon_manager.get_weapons()
	return []
