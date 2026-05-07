extends CharacterBody2D
## Baza dla wszystkich wrogów - HP, damage, AI

signal died
signal damaged(amount: int)

@export var max_health: int = 50
@export var damage: int = 10
@export var move_speed: float = 100.0
@export var detection_range: float = 500.0
@export var attack_range: float = 50.0
@export var attack_cooldown: float = 1.0
@export var score_value: int = 10

var current_health: int
var can_attack: bool = true
var attack_timer: float = 0.0
var player: Node2D

var sprite: AnimatedSprite2D
var collision: CollisionShape2D
var detection_area: Area2D
var attack_area: Area2D

func _ready() -> void:
	# Znajdź węzły bezpiecznie
	if has_node("AnimatedSprite2D"):
		sprite = $AnimatedSprite2D
	if has_node("CollisionShape2D"):
		collision = $CollisionShape2D
	if has_node("DetectionArea"):
		detection_area = $DetectionArea
	if has_node("AttackArea"):
		attack_area = $AttackArea

	current_health = max_health
	add_to_group("Enemies")

	# Znajdź gracza
	var players := get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]

	# Połącz sygnały
	if detection_area:
		detection_area.body_entered.connect(_on_detection_area_body_entered)
	if attack_area:
		attack_area.body_entered.connect(_on_attack_area_body_entered)

func _physics_process(delta: float) -> void:
	if not player:
		_find_player()

	if player and is_instance_valid(player):
		handle_ai(delta)
		handle_attack_cooldown(delta)

	move_and_slide()

func _find_player() -> void:
	var players := get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]

func handle_ai(delta: float) -> void:
	if not player:
		return

	var distance := global_position.distance_to(player.global_position)

	if distance < detection_range:
		# Podążaj za graczem
		var direction := (player.global_position - global_position).normalized()
		velocity = direction * move_speed

		# Obróć sprite w kierunku gracza
		if sprite:
			if direction.x > 0:
				sprite.flip_h = false
			elif direction.x < 0:
				sprite.flip_h = true
	else:
		velocity = Vector2.ZERO

func handle_attack_cooldown(delta: float) -> void:
	if not can_attack:
		attack_timer -= delta
		if attack_timer <= 0:
			can_attack = true

func attack() -> void:
	if not can_attack or not player:
		return

	if player.has_method("take_damage"):
		player.take_damage(damage)

	can_attack = false
	attack_timer = attack_cooldown

func take_damage(amount: int) -> void:
	current_health -= amount
	damaged.emit(amount)

	if current_health <= 0:
		die()

func die() -> void:
	died.emit()
	queue_free()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		attack()