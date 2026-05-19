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
@export var xp_value: int = 10
@export var is_wandering: bool = true
@export var is_boss: bool = false

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

var slowdown_timer: float = 0.0
var original_move_speed: float = 0.0

# Special Boss Attack variables
var boss_special_timer: float = 0.0
var boss_special_cooldown: float = 10.0
var enemy_type_name: String = ""

var base_sprite_scale: Vector2 = Vector2.ONE
var _health_bar: ProgressBar
var _health_bar_scale: float = 1.0
var is_dead: bool = false

func scale_stats(wave_number: int) -> void:
	var health_multiplier := 1.0 + (wave_number - 1) * 0.25
	var damage_multiplier := 1.0 + (wave_number - 1) * 0.15
	
	max_health = int(max_health * health_multiplier)
	current_health = max_health
	damage = int(damage * damage_multiplier)
	xp_value = int(xp_value * (1.0 + (wave_number - 1) * 0.1))
	
	if _health_bar:
		_health_bar.max_value = max_health
		_health_bar.value = current_health

func make_giant_boss() -> void:
	is_boss = true
	scale = Vector2(2.5, 2.5)
	max_health *= 5
	current_health = max_health
	damage *= 2
	score_value *= 5
	move_speed *= 0.8
	boss_special_timer = 5.0
	
	if _health_bar and is_instance_valid(_health_bar):
		_health_bar_scale = 1.0 / max(scale.x, 0.01)
		_health_bar.scale = Vector2(_health_bar_scale, _health_bar_scale)
		_health_bar.max_value = max_health
		_health_bar.value = current_health
		_update_health_bar_position()

func _ready() -> void:
	visible = true
	add_to_group("Enemies")
	enemy_type_name = name.to_lower()
	collision_layer = 2 
	collision_mask = 1 | 4
	
	if has_node("AnimatedSprite2D"):
		sprite = $AnimatedSprite2D
	elif has_node("Sprite2D"):
		sprite = $Sprite2D
	elif has_node("ColorRect"):
		sprite = $ColorRect
		
	if sprite and "scale" in sprite:
		base_sprite_scale = sprite.scale
		
	if has_node("CollisionShape2D"):
		collision = $CollisionShape2D
	if has_node("DetectionArea"):
		detection_area = $DetectionArea
		if detection_area:
			detection_area.collision_mask = 4
	if has_node("AttackArea"):
		attack_area = $AttackArea
		if attack_area:
			attack_area.collision_mask = 4

	current_health = max_health
	original_move_speed = move_speed
	_setup_health_bar()
	_find_player()
	_pick_new_wander_target()

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
	
	var style_fg := StyleBoxFlat.new()
	style_fg.bg_color = Color(0.149, 0.839, 0.275)
	style_fg.set_corner_radius_all(2)
	_health_bar.add_theme_stylebox_override("fill", style_fg)
	
	var style_bg := StyleBoxFlat.new()
	style_bg.bg_color = Color(0.2, 0.05, 0.05)
	style_bg.set_corner_radius_all(2)
	_health_bar.add_theme_stylebox_override("background", style_bg)
	
	_health_bar_scale = 1.0 / max(scale.x, 0.01)
	_health_bar.scale = Vector2(_health_bar_scale, _health_bar_scale)
	
	add_child(_health_bar)
	_update_health_bar_position()

func _physics_process(delta: float) -> void:
	if not player or not is_instance_valid(player):
		_find_player()

	handle_ai(delta)
	handle_attack_cooldown(delta)
	
	if is_boss:
		handle_boss_special(delta)
	
	if knockback_velocity.length() > 10.0:
		velocity += knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 500.0 * delta)
	else:
		knockback_velocity = Vector2.ZERO

	if slowdown_timer > 0:
		slowdown_timer -= delta
		if slowdown_timer <= 0:
			move_speed = original_move_speed
			modulate = Color.WHITE

	move_and_slide()
	
	if _health_bar and is_instance_valid(_health_bar):
		_update_health_bar_position()

func handle_boss_special(delta: float) -> void:
	boss_special_timer -= delta
	if boss_special_timer <= 0:
		execute_special_attack()
		boss_special_timer = boss_special_cooldown

func execute_special_attack() -> void:
	if is_dead: return
	if "worm" in enemy_type_name:
		_special_attack_projectile_ring()
	elif "trojan" in enemy_type_name or "ransomware" in enemy_type_name:
		_special_attack_aoe_blast()
	else:
		_special_attack_projectile_ring()

func _special_attack_projectile_ring() -> void:
	var projectile_scene = load("res://scenes/Projectile.tscn")
	if not projectile_scene: return
	var count = 12
	for i in range(count):
		var angle = (PI * 2 / count) * i
		var dir = Vector2(cos(angle), sin(angle))
		var p = projectile_scene.instantiate()
		p.global_position = global_position
		p.direction = dir
		p.damage = int(damage * 0.5)
		p.speed = 300.0
		p.collision_mask = 1
		p.add_to_group("EnemyProjectiles")
		get_tree().current_scene.add_child(p)

func _special_attack_aoe_blast() -> void:
	var warning = ColorRect.new()
	warning.color = Color(1, 0, 0, 0.3)
	warning.size = Vector2(400, 400)
	warning.pivot_offset = warning.size / 2
	warning.global_position = global_position - warning.pivot_offset
	get_tree().current_scene.add_child(warning)
	var tween = create_tween()
	tween.tween_property(warning, "scale", Vector2(0.1, 0.1), 0.0)
	tween.tween_property(warning, "scale", Vector2(1.0, 1.0), 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func():
		if player and is_instance_valid(player):
			var dist = global_position.distance_to(player.global_position)
			if dist < 200.0:
				var kb = (player.global_position - global_position).normalized() * 500.0
				player.take_damage(int(damage * 1.5), kb)
		warning.queue_free()
	).set_delay(1.0)

func _update_health_bar_position() -> void:
	if _health_bar and is_instance_valid(_health_bar):
		var bar_width := 40.0
		_health_bar.position = Vector2(-bar_width * _health_bar_scale / 2.0, -50.0 * _health_bar_scale)

func update_health_bar() -> void:
	if _health_bar and is_instance_valid(_health_bar):
		_health_bar.max_value = max_health
		_health_bar.value = current_health
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

func _on_damaged(_amount: int) -> void:
	_spawn_hit_effect()
	update_health_bar()

func _spawn_hit_effect() -> void:
	if not is_inside_tree(): return
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
	if players.size() > 0: player = players[0]

func handle_ai(delta: float) -> void:
	if not player:
		_handle_wander(delta)
		return
	var distance := global_position.distance_to(player.global_position)
	if distance < detection_range:
		var direction := (player.global_position - global_position).normalized()
		velocity = direction * move_speed
		if sprite and "scale" in sprite:
			if direction.x > 0: sprite.scale.x = abs(sprite.scale.x)
			elif direction.x < 0: sprite.scale.x = -abs(sprite.scale.x)
	elif is_wandering:
		_handle_wander(delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, move_speed * delta)

func _handle_wander(delta: float) -> void:
	wander_timer -= delta
	if wander_timer <= 0 or global_position.distance_to(wander_target) < 20:
		_pick_new_wander_target()
	var direction := (wander_target - global_position).normalized()
	velocity = direction * (move_speed * 0.6)
	if sprite and "scale" in sprite:
		if velocity.x > 0: sprite.scale.x = abs(sprite.scale.x)
		elif velocity.x < 0: sprite.scale.x = -abs(sprite.scale.x)

func _pick_new_wander_target() -> void:
	var viewport_size := get_viewport_rect().size
	wander_target = Vector2(randf_range(0, viewport_size.x), randf_range(0, viewport_size.y))
	wander_timer = wander_interval

func handle_attack_cooldown(delta: float) -> void:
	if not can_attack:
		attack_timer -= delta
		if attack_timer <= 0: can_attack = true
	if can_attack and not players_in_attack_range.is_empty():
		attack()

func attack() -> void:
	if not can_attack or players_in_attack_range.is_empty(): return
	var target = players_in_attack_range[0]
	if is_instance_valid(target) and target.has_method("take_damage"):
		var kb_dir = (target.global_position - global_position).normalized()
		target.take_damage(damage, kb_dir * 300.0)
	can_attack = false
	attack_timer = attack_cooldown

func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO) -> void:
	if is_dead: return
	var final_damage := amount
	if is_boss:
		var main_node = get_tree().current_scene
		var build_system = main_node.get_node_or_null("BuildSystem")
		if build_system:
			var bonus: float = build_system.get_stat("boss_damage_bonus")
			final_damage = int(amount * (1.0 + bonus))
	current_health -= final_damage
	damaged.emit(final_damage)
	_spawn_damage_number(final_damage)
	if knockback != Vector2.ZERO:
		knockback_velocity = knockback * (1.0 - knockback_resistance)
	update_health_bar()
	if current_health <= 0: die()

func die() -> void:
	if is_dead: return
	is_dead = true
	AudioManager.play_sfx("enemy_death", 0.1, -15.0)
	var gd := get_node_or_null("/root/GameData")
	if gd: gd.gold += score_value
	var main_game = get_tree().current_scene
	if main_game and main_game.has_method("gain_xp"):
		main_game.gain_xp(xp_value)
	_spawn_gold_number(score_value)
	if _health_bar and is_instance_valid(_health_bar):
		_health_bar.queue_free()
	died.emit()
	queue_free()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): player = body

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if not players_in_attack_range.has(body): players_in_attack_range.append(body)
		attack()

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"): players_in_attack_range.erase(body)

func apply_slowdown(multiplier: float, duration: float) -> void:
	move_speed = original_move_speed * multiplier
	slowdown_timer = duration
	modulate = Color(0.5, 0.8, 1.0, 1.0)

func _spawn_damage_number(amount: int) -> void:
	if not is_inside_tree(): return
	var label := Label.new()
	label.text = str(amount)
	label.z_index = 5
	label.add_theme_font_size_override("font_size", 16 + int(amount / 10.0))
	label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	var shadow := Label.new()
	shadow.text = str(amount)
	shadow.add_theme_font_size_override("font_size", 16 + int(amount / 10.0))
	shadow.add_theme_color_override("font_color", Color(0, 0, 0, 0.7))
	shadow.position = Vector2(1, 1)
	label.add_child(shadow)
	label.global_position = global_position + Vector2(randf_range(-20, 20), -40)
	get_tree().current_scene.add_child(label)
	var tween := get_tree().create_tween()
	tween.bind_node(label)
	tween.set_parallel(true)
	tween.tween_property(label, "global_position:y", label.global_position.y - 50, 0.6)
	tween.tween_property(label, "modulate:a", 0.0, 0.5).set_delay(0.2)
	tween.chain().tween_callback(label.queue_free)

func _spawn_gold_number(amount: int) -> void:
	if not is_inside_tree() or amount <= 0: return
	var label := Label.new()
	label.text = "+" + str(amount) + "g"
	label.z_index = 4
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color(1, 0.84, 0, 1))
	var shadow := Label.new()
	shadow.text = "+" + str(amount) + "g"
	shadow.add_theme_font_size_override("font_size", 20)
	shadow.add_theme_color_override("font_color", Color(0, 0, 0, 0.7))
	shadow.position = Vector2(1, 1)
	label.add_child(shadow)
	label.global_position = global_position + Vector2(0, -60)
	get_tree().current_scene.call_deferred("add_child", label)
	var tween := get_tree().create_tween()
	tween.bind_node(label)
	tween.set_parallel(true)
	tween.tween_property(label, "global_position:y", label.global_position.y - 60, 0.8)
	tween.tween_property(label, "modulate:a", 0.0, 0.8).set_delay(0.4)
	tween.chain().tween_callback(label.queue_free)
