extends CharacterBody2D
## System walki gracza - strzelanie, statystyki, interakcje

signal health_changed(current_health: int, max_health: int)
signal died

@export var max_health: int = 100
@export var move_speed: float = 300.0
@export var attack_speed: float = 1.0 # shots per second
@export var damage: int = 10
@export var projectile_speed: float = 500.0
@export var attack_range: float = 400.0

var current_health: int
var can_shoot: bool = true
var attack_cooldown: float = 0.0

var sprite: AnimatedSprite2D
var collision: CollisionShape2D
var interaction_area: Area2D
var interaction_prompt: Label
var muzzle: Marker2D # punkt wylotu pocisku

var projectile_scene: PackedScene = preload("res://Scenes/Projectile.tscn")

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

func _process(delta: float) -> void:
	handle_input(delta)
	handle_cooldown(delta)
	update_interaction_prompt()

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	move_and_slide()
	update_animation()

func handle_input(delta: float) -> void:
	var direction := Vector2.ZERO

	if Input.is_action_pressed("walk_up"):
		direction.y -= 1
	if Input.is_action_pressed("walk_down"):
		direction.y += 1
	if Input.is_action_pressed("walk_left"):
		direction.x -= 1
	if Input.is_action_pressed("walk_right"):
		direction.x += 1

	velocity = direction.normalized() * move_speed

	# Strzelanie
	if Input.is_action_pressed("attack") and can_shoot:
		shoot()

func handle_movement(delta: float) -> void:
	# Ruch jest już w handle_input, tutaj można dodać physics
	pass

func handle_cooldown(delta: float) -> void:
	if not can_shoot:
		attack_cooldown -= delta
		if attack_cooldown <= 0:
			can_shoot = true

func shoot() -> void:
	if not can_shoot:
		return

	can_shoot = false
	attack_cooldown = 1.0 / attack_speed

	# Znajdź najbliższego wroga w zasięgu
	var target := find_closest_enemy()

	if target:
		# Strzelaj w kierunku wroga
		var direction := (target.global_position - global_position).normalized()
		fire_projectile(direction)
	else:
		# Strzelaj w kierunku myszy
		var mouse_pos := get_global_mouse_position()
		var direction := (mouse_pos - global_position).normalized()
		fire_projectile(direction)

func fire_projectile(direction: Vector2) -> void:
	var projectile: Area2D = projectile_scene.instantiate()

	if muzzle:
		projectile.global_position = muzzle.global_position
	else:
		projectile.global_position = global_position

	projectile.direction = direction
	projectile.speed = projectile_speed
	projectile.damage = damage
	projectile.owner_node = self

	get_tree().current_scene.add_child(projectile)

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

func take_damage(amount: int) -> void:
	current_health -= amount
	health_changed.emit(current_health, max_health)

	if current_health <= 0:
		die()

func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)

func die() -> void:
	died.emit()
	queue_free()

func update_animation() -> void:
	if not sprite:
		return

	if velocity.length() > 0:
		if velocity.x > 0:
			sprite.play("right")
		elif velocity.x < 0:
			sprite.play("left")
		else:
			if velocity.y > 0:
				sprite.play("front")
			else:
				sprite.play("right")
	else:
		sprite.stop()
		sprite.frame = 0

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
				break
