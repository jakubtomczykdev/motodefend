extends CharacterBody2D
## System walki gracza - strzelanie, statystyki, interakcje

signal health_changed(current_health: int, max_health: int)
signal died

@export var max_health: int = 100
@export var move_speed: float = 300.0
@export var attack_speed: float = 4.0 # shots per second
@export var damage: int = 10
@export var projectile_speed: float = 700.0
@export var attack_range: float = 900.0

# Bazowe statystyki (zapisane w _ready, używane przez build_system)
var base_max_health: int
var base_move_speed: float
var base_attack_speed: float
var base_damage: int
var base_projectile_speed: float
var base_attack_range: float

var current_health: int
var can_shoot: bool = true
var attack_cooldown: float = 0.0

var sprite: AnimatedSprite2D
var collision: CollisionShape2D
var interaction_area: Area2D
var interaction_prompt: Label
var muzzle: Marker2D # punkt wylotu pocisku

var projectile_scene: PackedScene = preload("res://scenes/Projectile.tscn")

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

	# Zapisz bazowe statystyki dla build_system
	base_max_health = max_health
	base_move_speed = move_speed
	base_attack_speed = attack_speed
	base_damage = damage
	base_projectile_speed = projectile_speed
	base_attack_range = attack_range

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
	_clamp_to_screen()
	update_animation()

func handle_input(_delta: float) -> void:
	# Blokuj strzelanie i ruch bojowy poza sceną MainGame (hub, menu)
	var current_scene := get_tree().current_scene
	var in_combat: bool = current_scene != null and current_scene.scene_file_path == "res://scenes/MainGame.tscn"

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

	# Strzelanie – tylko w scenie walki
	if in_combat and Input.is_action_pressed("attack") and can_shoot:
		shoot()

func handle_movement(_delta: float) -> void:
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
	var projectile = projectile_scene.instantiate()

	# Spawn pocisku ZAWSZE przed graczem w kierunku strzału.
	# Offset 130 px zapewnia, że pocisk nie spawnuje się wewnątrz
	# hitboxa gracza (gracz ma ~110 px promienia bounding box).
	projectile.global_position = global_position + direction * 130.0

	projectile.direction = direction
	projectile.speed = projectile_speed
	projectile.damage = damage
	projectile.owner_node = self

	get_tree().current_scene.add_child(projectile)

	# Efekt flash przy lufie
	_flash_muzzle()

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

func _clamp_to_screen() -> void:
	var screen_size := get_viewport_rect().size
	global_position.x = clamp(global_position.x, 30, screen_size.x - 30)
	global_position.y = clamp(global_position.y, 30, screen_size.y - 30)

func _flash_muzzle() -> void:
	if not muzzle:
		return
	var flash := Sprite2D.new()
	var gt := GradientTexture2D.new()
	gt.width = 16
	gt.height = 16
	var grad := Gradient.new()
	grad.colors = PackedColorArray([Color(1, 0.9, 0.5, 0.9), Color(1, 0.6, 0.2, 0)])
	gt.gradient = grad
	flash.texture = gt
	muzzle.add_child(flash)
	flash.position = Vector2.ZERO
	var tween := create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, 0.08)
	tween.tween_callback(flash.queue_free)

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
