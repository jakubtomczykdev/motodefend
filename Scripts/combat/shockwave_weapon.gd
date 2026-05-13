extends Node2D

var current_weapon: WeaponBase
var can_attack: bool = true
var attack_timer: float = 0.0
var hit_enemies: Array = []
var wave_area: Area2D

func initialize(weapon_data: WeaponBase) -> void:
	current_weapon = weapon_data
	can_attack = true

func is_ready() -> bool:
	return can_attack

func _process(delta: float) -> void:
	if not can_attack:
		attack_timer -= delta
		if attack_timer <= 0.0:
			can_attack = true

func activate(player_pos: Vector2, weapon_data: WeaponBase, target_dir: Vector2 = Vector2.RIGHT) -> void:
	if not can_attack:
		return

	current_weapon = weapon_data

	# Wizualna fala - ColorRect rozszerzająca się
	var wave_visual := ColorRect.new()
	wave_visual.size = Vector2(1, 1)
	
	# Motorola Cyan for New Radio, Default for Old
	var is_motorola := "Motorola" in weapon_data.weapon_name
	var wave_color := Color(0, 0.941, 1, 0.5) if is_motorola else Color(0.6, 0.7, 0.8, 0.4)
	
	wave_visual.color = wave_color
	wave_visual.global_position = player_pos
	wave_visual.rotation = target_dir.angle()
	get_tree().current_scene.add_child(wave_visual)

	var wave_tween := create_tween()
	wave_tween.tween_property(wave_visual, "size", Vector2(weapon_data.weapon_range, 60), 0.3)
	wave_tween.parallel().tween_property(wave_visual, "modulate:a", 0.0, 0.35)
	wave_tween.tween_callback(wave_visual.queue_free)

	# Drugi pierścień fali - efekt echo
	var wave_ring := ColorRect.new()
	wave_ring.size = Vector2(1, 1)
	wave_ring.color = Color(0.5, 0.9, 1, 0.2)
	wave_ring.global_position = player_pos
	wave_ring.rotation = target_dir.angle()
	get_tree().current_scene.add_child(wave_ring)

	var ring_tween := create_tween()
	ring_tween.tween_property(wave_ring, "size", Vector2(weapon_data.weapon_range * 0.8, 80), 0.25).set_delay(0.1)
	ring_tween.parallel().tween_property(wave_ring, "modulate:a", 0.0, 0.3).set_delay(0.1)
	ring_tween.tween_callback(wave_ring.queue_free).set_delay(0.35)

	# Area2D dla kolizji
	wave_area = Area2D.new()
	wave_area.collision_layer = 0
	wave_area.collision_mask = 1

	var collision_shape := CollisionShape2D.new()
	var circle_shape := CircleShape2D.new()
	circle_shape.radius = 40.0
	collision_shape.shape = circle_shape
	wave_area.add_child(collision_shape)

	wave_area.global_position = player_pos
	wave_area.body_entered.connect(_on_wave_body_entered.bind(weapon_data, wave_area))

	get_tree().current_scene.add_child(wave_area)

	hit_enemies.clear()

	var end_pos := player_pos + target_dir * weapon_data.weapon_range
	var t := create_tween()
	t.tween_property(wave_area, "global_position", end_pos, 0.5)
	t.tween_callback(_on_wave_finished)

	can_attack = false
	attack_timer = weapon_data.attack_speed

func _on_wave_body_entered(body: Node2D, weapon_data: WeaponBase, wave: Area2D) -> void:
	if not body.is_in_group("Enemies"):
		return
	if body in hit_enemies:
		return
	hit_enemies.append(body)

	if body.has_method("take_damage"):
		body.take_damage(weapon_data.damage)

	# UNIQUE LOGIC: New Motorola Radio slows down enemies
	if "Motorola" in weapon_data.weapon_name and body.has_method("apply_slowdown"):
		body.apply_slowdown(0.4, 2.0) # 60% slow for 2 seconds

	# Iskry przy trafieniu falą
	for i in range(2):
		var spark := ColorRect.new()
		spark.size = Vector2(5, 5)
		spark.color = Color(0, 0.8, 1, 0.8)
		spark.global_position = body.global_position + Vector2(randf_range(-8, 8), randf_range(-8, 8))
		get_tree().current_scene.add_child(spark)
		var spark_tween := create_tween()
		spark_tween.tween_property(spark, "modulate:a", 0.0, 0.2)
		spark_tween.tween_callback(spark.queue_free)

func _on_wave_finished() -> void:
	if wave_area and is_instance_valid(wave_area):
		wave_area.queue_free()
