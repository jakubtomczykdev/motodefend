extends Node2D
## Zarządza atakiem falą uderzeniową – fala przemieszcza się w kierunku myszki

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

	# Tworzenie Area2D dla fali – mniejszy promień, porusza się do celu
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

	# Reset listy trafionych wrogów
	hit_enemies.clear()

	# Animacja ruchu w kierunku celu
	var end_pos := player_pos + target_dir * weapon_data.weapon_range
	var t := create_tween()
	t.tween_property(wave_area, "global_position", end_pos, 0.5)
	t.tween_callback(_on_wave_finished)

	# Cooldown
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


func _on_wave_finished() -> void:
	if wave_area and is_instance_valid(wave_area):
		wave_area.queue_free()
