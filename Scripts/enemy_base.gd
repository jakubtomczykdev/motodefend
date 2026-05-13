extends CharacterBody2D
class_name EnemyBase
## Baza dla wszystkich wrogów - HP, damage, AI

signal died
signal damaged(amount: int)

@export var max_health: int = 50
@export var damage: int = 10
@export var move_speed: float = 100.0
@export var detection_range: float = 500.0
@export var attack_range: float = 50.0
@export var attack_cooldown: float = 1.0
@export var knockback_resistance: float = 0.0
@export var score_value: int = 10
@export var is_wandering: bool = true

var current_health: int
var can_attack: bool = true
var attack_timer: float = 0.0
var player: Node2D

var sprite: Node
var collision: CollisionShape2D
var detection_area: Area2D
var attack_area: Area2D

var wander_target: Vector2
var wander_timer: float = 0.0
var wander_interval: float = 4.0

var knockback_velocity: Vector2 = Vector2.ZERO
var players_in_attack_range: Array[Node2D] = []

var _health_bar: ProgressBar
var _health_bar_scale: float = 1.0

func _ready() -> void:
	# Upewnij się, że wróg jest widoczny
	visible = true
	
	# Znajdź węzły bezpiecznie
	if has_node("AnimatedSprite2D"):
		sprite = $AnimatedSprite2D
	elif has_node("Sprite2D"):
		sprite = $Sprite2D
	elif has_node("ColorRect"):
		sprite = $ColorRect
		
	if has_node("CollisionShape2D"):
		collision = $CollisionShape2D
	if has_node("DetectionArea"):
		detection_area = $DetectionArea
	if has_node("AttackArea"):
		attack_area = $AttackArea

	current_health = max_health
	add_to_group("Enemies")

	# Utwórz pasek zdrowia nad głową wroga
	_setup_health_bar()

	# Znajdź gracza
	_find_player()
	
	_pick_new_wander_target()

	# Połącz sygnały
	damaged.connect(_on_damaged)
	if detection_area:
		detection_area.body_entered.connect(_on_detection_area_body_entered)
	if attack_area:
		attack_area.body_entered.connect(_on_attack_area_body_entered)
		attack_area.body_exited.connect(_on_attack_area_body_exited)

func _setup_health_bar() -> void:
	_health_bar = ProgressBar.new()
	_health_bar.name = "HealthBar"
	_health_bar.max_value = max_health
	_health_bar.value = max_health
	_health_bar.custom_minimum_size = Vector2(30, 4)
	_health_bar.show_percentage = false
	_health_bar.modulate = Color(1, 1, 1, 0.9)
	
	# Styl: pasek z obwódką
	var style_fg := StyleBoxFlat.new()
	style_fg.bg_color = Color(0.149, 0.839, 0.275)
	style_fg.set_corner_radius_all(2)
	_health_bar.add_theme_stylebox_override("fill", style_fg)
	
	var style_bg := StyleBoxFlat.new()
	style_bg.bg_color = Color(0.2, 0.05, 0.05)
	style_bg.set_corner_radius_all(2)
	_health_bar.add_theme_stylebox_override("background", style_bg)
	
	# Skompensuj skalę rodzica, aby pasek był zawsze normalnej wielkości
	_health_bar_scale = 1.0 / max(scale.x, 0.01)
	_health_bar.scale = Vector2(_health_bar_scale, _health_bar_scale)
	
	add_child(_health_bar)
	_update_health_bar_position()

func _physics_process(delta: float) -> void:
	if not player or not is_instance_valid(player):
		_find_player()

	handle_ai(delta)
	handle_attack_cooldown(delta)
	
	# Apply knockback
	if knockback_velocity.length() > 10.0:
		velocity += knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 500.0 * delta)
	else:
		knockback_velocity = Vector2.ZERO

	move_and_slide()
	
	# Health bar podąża za wrogiem
	if _health_bar and is_instance_valid(_health_bar):
		_update_health_bar_position()

func _update_health_bar_position() -> void:
	if _health_bar and is_instance_valid(_health_bar):
		var bar_width := 40.0
		_health_bar.position = Vector2(-bar_width * _health_bar_scale / 2.0, -50.0 * _health_bar_scale)

func update_health_bar() -> void:
	if _health_bar and is_instance_valid(_health_bar):
		_health_bar.max_value = max_health
		_health_bar.value = current_health
		# Zmień kolor paska w zależności od HP
		var style_fg := StyleBoxFlat.new()
		style_fg.set_corner_radius_all(2)
		var ratio := float(current_health) / float(max_health)
		if ratio > 0.6:
			style_fg.bg_color = Color(0.149, 0.839, 0.275)
		elif ratio > 0.3:
			style_fg.bg_color = Color(0.839, 0.686, 0.149)
		else:
			style_fg.bg_color = Color(0.839, 0.149, 0.149)
		_health_bar.add_theme_stylebox_override("fill", style_fg)

func _on_damaged(amount: int) -> void:
	_spawn_hit_effect()
	update_health_bar()

func _spawn_hit_effect() -> void:
	# Stwórz efekt trafienia - małe kolorowe prostokąty rozlatujące się
	for i in range(4):
		var spark := ColorRect.new()
		spark.size = Vector2(4, 4)
		spark.color = Color(0.5 + randf() * 0.5, 0.8, 0.3, 1.0)
		spark.global_position = global_position + Vector2(randf_range(-8, 8), randf_range(-8, 8))
		get_tree().current_scene.add_child(spark)
		
		var target := spark.global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
		var tween := create_tween()
		tween.tween_property(spark, "global_position", target, 0.2)
		tween.parallel().tween_property(spark, "modulate:a", 0.0, 0.25)
		tween.tween_callback(spark.queue_free)

func _find_player() -> void:
	var players := get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]

func handle_ai(delta: float) -> void:
	if not player:
		_handle_wander(delta)
		return

	var distance := global_position.distance_to(player.global_position)

	if distance < detection_range:
		# Podążaj za graczem
		var direction := (player.global_position - global_position).normalized()
		velocity = direction * move_speed

		# Obróć sprite w kierunku gracza
		if sprite and "scale" in sprite:
			if direction.x > 0:
				sprite.scale.x = abs(sprite.scale.x)
			elif direction.x < 0:
				sprite.scale.x = -abs(sprite.scale.x)
	elif is_wandering:
		_handle_wander(delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, move_speed * delta)

func _handle_wander(delta: float) -> void:
	wander_timer -= delta
	if wander_timer <= 0 or global_position.distance_to(wander_target) < 20:
		_pick_new_wander_target()
	
	var direction := (wander_target - global_position).normalized()
	velocity = direction * (move_speed * 0.6) # Wolniej podczas błądzenia
	
	if sprite and "scale" in sprite:
		if velocity.x > 0:
			sprite.scale.x = abs(sprite.scale.x)
		elif velocity.x < 0:
			sprite.scale.x = -abs(sprite.scale.x)

func _pick_new_wander_target() -> void:
	var viewport_size := get_viewport_rect().size
	wander_target = Vector2(
		randf_range(0, viewport_size.x),
		randf_range(0, viewport_size.y)
	)
	wander_timer = wander_interval

func handle_attack_cooldown(delta: float) -> void:
	if not can_attack:
		attack_timer -= delta
		if attack_timer <= 0:
			can_attack = true
	
	if can_attack and not players_in_attack_range.is_empty():
		attack()

func attack() -> void:
	if not can_attack or players_in_attack_range.is_empty():
		return
	
	var target = players_in_attack_range[0]
	if is_instance_valid(target) and target.has_method("take_damage"):
		var kb_dir = (target.global_position - global_position).normalized()
		target.take_damage(damage, kb_dir * 300.0)

	can_attack = false
	attack_timer = attack_cooldown

func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO) -> void:
	current_health -= amount
	damaged.emit(amount)
	
	if knockback != Vector2.ZERO:
		knockback_velocity = knockback * (1.0 - knockback_resistance)

	update_health_bar()

	if current_health <= 0:
		die()

func die() -> void:
	var gd := get_node_or_null("/root/GameData")
	if gd:
		gd.gold += score_value

	if _health_bar and is_instance_valid(_health_bar):
		_health_bar.queue_free()

	died.emit()
	queue_free()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if not players_in_attack_range.has(body):
			players_in_attack_range.append(body)
		attack()

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		players_in_attack_range.erase(body)