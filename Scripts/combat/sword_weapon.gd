extends Node2D

var current_weapon: WeaponBase
var can_attack: bool = true
var attack_timer: float = 0.0
var hit_enemies: Array = []

func initialize(weapon_data: WeaponBase) -> void:
	current_weapon = weapon_data
	can_attack = true

func swing(player_pos: Vector2, direction: Vector2, weapon_data: WeaponBase) -> void:
	if not can_attack:
		return

	var swing_origin := player_pos + direction * 20
	var start_angle := direction.angle() - 1.2
	var end_angle := direction.angle() + 1.2
	var arc_length := 60.0

	var swing_area: Area2D = Area2D.new()
	get_tree().root.add_child(swing_area)
	swing_area.global_position = swing_origin
	swing_area.collision_layer = 0
	swing_area.collision_mask = 1

	var collision_shape: CollisionShape2D = CollisionShape2D.new()
	var rect_shape: RectangleShape2D = RectangleShape2D.new()
	rect_shape.size = Vector2(70, 36)
	collision_shape.shape = rect_shape
	swing_area.add_child(collision_shape)
	swing_area.body_entered.connect(_on_swing_body_entered.bind(weapon_data))
	hit_enemies.clear()

	var arc_tween := create_tween()
	arc_tween.set_parallel(true)

	# Wizualny łuk cięcia - 3 segmenty tworzące smugę
	for i in range(5):
		var seg := ColorRect.new()
		seg.size = Vector2(24, 6)
		seg.color = Color(0.8, 0.95, 1, 0.7 - i * 0.12)
		seg.global_position = swing_origin + direction * (12 + i * 10)
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
		sword_sprite.scale = Vector2(0.7, 0.7)
		sword_sprite.offset = Vector2(35, 0)
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
	flash_tween.tween_property(flash, "scale", Vector2(2, 0.5), 0.12)
	flash_tween.parallel().tween_property(flash, "modulate:a", 0.0, 0.12)
	flash_tween.tween_callback(flash.queue_free)

	# Animacja zamachu
	swing_area.rotation = start_angle
	var swing_tween := create_tween()
	swing_tween.tween_property(swing_area, "rotation", end_angle, 0.12)
	swing_tween.tween_callback(swing_area.queue_free)

	can_attack = false
	attack_timer = weapon_data.attack_speed

func _on_swing_body_entered(body: Node2D, weapon_data: WeaponBase) -> void:
	if not body.is_in_group("Enemies"):
		return
	if hit_enemies.has(body):
		return
	hit_enemies.append(body)
	if body.has_method("take_damage"):
		body.take_damage(weapon_data.damage)
	_spawn_impact(body)

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
