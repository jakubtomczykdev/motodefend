extends Node2D
## Zarządza atakiem falą uderzeniową - ekspandujący pierścień obrażeń

var current_weapon: WeaponBase
var can_attack: bool = true
var attack_timer: float = 0.0
var hit_enemies: Array = []
var shockwave_area: Area2D
var tween: Tween

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

func activate(player_pos: Vector2, weapon_data: WeaponBase) -> void:
	if not can_attack:
		return

	current_weapon = weapon_data

	# Tworzenie Area2D dla fali uderzeniowej
	shockwave_area = Area2D.new()
	shockwave_area.collision_layer = 0
	shockwave_area.collision_mask = 1

	var collision_shape := CollisionShape2D.new()
	var circle_shape := CircleShape2D.new()
	circle_shape.radius = weapon_data.range
	collision_shape.shape = circle_shape
	shockwave_area.add_child(collision_shape)

	shockwave_area.global_position = player_pos
	shockwave_area.scale = Vector2.ZERO
	shockwave_area.body_entered.connect(_on_shockwave_body_entered)

	get_tree().current_scene.add_child(shockwave_area)

	# Reset listy trafionych wrogów
	hit_enemies.clear()

	# Animacja skalowania 0 → 1 w 0.5 sekundy
	tween = create_tween()
	tween.tween_property(shockwave_area, "scale", Vector2.ONE, 0.5)
	tween.tween_callback(_on_shockwave_finished)

	# Cooldown
	can_attack = false
	attack_timer = weapon_data.attack_speed

func _on_shockwave_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Enemies"):
		return

	# Każdy wróg dostaje obrażenia tylko raz na aktywację
	if hit_enemies.has(body):
		return

	hit_enemies.append(body)

	if body.has_method("take_damage"):
		body.take_damage(int(current_weapon.damage))

func _on_shockwave_finished() -> void:
	if shockwave_area and is_instance_valid(shockwave_area):
		shockwave_area.queue_free()
