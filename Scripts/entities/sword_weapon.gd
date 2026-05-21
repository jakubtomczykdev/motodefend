extends Node2D

var current_weapon: WeaponBase
var can_attack: bool = true
var attack_timer: float = 0.0
var current_swing_area: Area2D = null
var hit_enemies: Array = []
var player_ref: Node2D = null
var _swing_dmg_mult: float = 1.0

func _apply_screen_shake(intensity: float = 6.0) -> void:
	if not is_inside_tree():
		return
	var viewport := get_viewport()
	if not viewport:
		return
	var camera := viewport.get_camera_2d()
	if not camera:
		return
	var orig_pos := camera.position
	var tween := create_tween()
	tween.set_loops(3)
	tween.tween_property(camera, "position", orig_pos + Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity)), 0.03)
	tween.tween_property(camera, "position", orig_pos, 0.03)

func initialize(weapon_data: WeaponBase, p_player_ref: Node2D = null) -> void:
	current_weapon = weapon_data
	player_ref = p_player_ref
	can_attack = true

func swing(player_body: CharacterBody2D, direction: Vector2, weapon_data: WeaponBase) -> void:
	if not can_attack:
		return

	# Mnożniki z build systemu (player_ref.damage / 10.0, attack_speed / 1.0)
	var dmg_mult: float = 1.0
	var cooldown_mult: float = 1.0
	if player_ref and "damage" in player_ref and "attack_speed" in player_ref:
		dmg_mult = player_ref.damage / 10.0
		cooldown_mult = 1.0 / max(player_ref.attack_speed, 0.1)
	_swing_dmg_mult = dmg_mult

	var swing_origin := player_body.global_position + direction * 20
	var start_angle := direction.angle() - 1.2
	var end_angle := direction.angle() + 1.2
	var arc_length := 60.0

	if current_swing_area:
		current_swing_area.queue_free()

	var swing_area: Area2D = Area2D.new()
	get_tree().current_scene.add_child(swing_area)
	current_swing_area = swing_area
	swing_area.global_position = swing_origin
	swing_area.collision_layer = 8 # Projectiles
	swing_area.collision_mask = 2 # Enemies

	var collision_shape: CollisionShape2D = CollisionShape2D.new()
	var rect_shape: RectangleShape2D = RectangleShape2D.new()
	rect_shape.size = Vector2(weapon_data.weapon_range, 80) # Szybsze wyłapywanie
	collision_shape.shape = rect_shape
	collision_shape.position = Vector2(weapon_data.weapon_range / 2, 0)
	swing_area.add_child(collision_shape)
	hit_enemies.clear()

	# Connect signals for immediate detection
	swing_area.body_entered.connect(_on_swing_body_entered.bind(weapon_data))
	swing_area.area_entered.connect(_on_swing_body_entered.bind(weapon_data))

	# Wizualny łuk cięcia - 8 segmentów tworzących dłuższą smugę
	for i in range(8):
		var seg := ColorRect.new()
		seg.size = Vector2(24, 6)
		seg.color = Color(0.8, 0.95, 1, 0.7 - i * 0.12)
		seg.global_position = swing_origin + direction * (10 + i * 14)
		seg.rotation = direction.angle()
		get_tree().root.add_child(seg)
		var seg_tween := create_tween()
		seg_tween.tween_property(seg, "modulate:a", 0.0, 0.2 + i * 0.03)
		seg_tween.tween_callback(seg.queue_free)

	# Główny sprite miecza
	var sword_sprite := Sprite2D.new()
	var tex := load("res://Assets/newAssets/sword.png") as Texture2D
	if tex:
		sword_sprite.texture = tex
		sword_sprite.scale = Vector2(0.04, 0.04)
		sword_sprite.offset = Vector2(50, 0)
		sword_sprite.modulate = Color(0.7, 0.85, 1, 1)
	swing_area.add_child(sword_sprite)

	# Błysk przed cięciem
	var flash := ColorRect.new()
	flash.size = Vector2(30, 30)
	flash.color = Color(0.8, 0.95, 1, 0.5)
	flash.global_position = swing_origin
	flash.rotation = start_angle
	get_tree().root.add_child(flash)
	var flash_tween := create_tween()
	flash_tween.tween_property(flash, "scale", Vector2(0.2, 0.05), 0.12)
	flash_tween.parallel().tween_property(flash, "modulate:a", 0.0, 0.12)
	flash_tween.tween_callback(flash.queue_free)

	# Animacja zamachu
	swing_area.rotation = start_angle
	var swing_tween := create_tween()
	swing_tween.tween_property(swing_area, "rotation", end_angle, 0.12)
	swing_tween.tween_callback(func():
		if current_swing_area == swing_area:
			current_swing_area = null
		swing_area.queue_free()
	)

	can_attack = false
	AudioManager.play_sfx("sword_swing")

	# Lunge (doskok) - dodaj pęd graczowi w stronę ataku
	if player_body:
		player_body.velocity += direction * 600.0

	attack_timer = weapon_data.attack_speed * cooldown_mult

func _on_swing_body_entered(target: Node2D, weapon_data: WeaponBase) -> void:
	var enemy = target
	if not enemy.is_in_group("Enemies"):
		if enemy.get_parent() and enemy.get_parent().is_in_group("Enemies"):
			enemy = enemy.get_parent()
		else:
			return

	if hit_enemies.has(enemy):
		return
	hit_enemies.append(enemy)

	if enemy.has_method("take_damage"):
		enemy.take_damage(int(weapon_data.damage * _swing_dmg_mult))
	
	_apply_screen_shake(8.0)
	_spawn_impact(enemy)

func _spawn_impact(target: Node2D) -> void:
	if not is_instance_valid(target):
		return
	for i in range(5):
		var spark := ColorRect.new()
		spark.size = Vector2(5 + randi() % 4, 5 + randi() % 4)
		spark.color = Color(0.9 + randf() * 0.1, 0.7 + randf() * 0.3, 0.2, 1)
		spark.global_position = target.global_position + Vector2(randf_range(-8, 8), randf_range(-8, 8))
		get_tree().current_scene.add_child(spark)
		var dir := Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		var st := create_tween()
		st.tween_property(spark, "global_position", spark.global_position + dir * 35, 0.2)
		st.parallel().tween_property(spark, "modulate:a", 0.0, 0.25)
		st.tween_callback(spark.queue_free)

func _process(delta: float) -> void:
	if not can_attack:
		attack_timer -= delta
		if attack_timer <= 0.0:
			can_attack = true

func is_ready() -> bool:
	return can_attack
