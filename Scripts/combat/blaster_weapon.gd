extends Node2D

var current_weapon: WeaponBase
var can_attack: bool = true
var attack_timer: float = 0.0
var projectile_scene: PackedScene = preload("res://scenes/Projectile.tscn")

func initialize(weapon_data: WeaponBase) -> void:
	current_weapon = weapon_data
	can_attack = true

func fire(player_pos: Vector2, target_pos: Vector2, weapon_data: WeaponBase) -> void:
	if not can_attack:
		return

	var direction := (target_pos - player_pos).normalized()

	var projectile: Area2D = projectile_scene.instantiate()
	projectile.speed = 600
	projectile.damage = int(weapon_data.damage)
	projectile.direction = direction
	projectile.global_position = player_pos
	
	# UNIQUE LOGIC: Slight homing for Blaster
	var target := find_closest_enemy(player_pos)
	if target:
		projectile.homing_target = target
		projectile.homing_strength = 2.0 # Gentle tracking
	
	get_tree().current_scene.add_child(projectile)

	# Muzzle flash - rozbłysk u wylotu lufy
	var flash := ColorRect.new()
	flash.color = Color(0.3, 0.9, 1, 0.9)
	flash.size = Vector2(16, 16)
	flash.global_position = player_pos + direction * 20 - Vector2(8, 8)
	get_tree().current_scene.add_child(flash)
	var flash_tween := create_tween()
	flash_tween.tween_property(flash, "size", Vector2(4, 4), 0.08)
	flash_tween.parallel().tween_property(flash, "modulate:a", 0.0, 0.1)
	flash_tween.tween_callback(flash.queue_free)

	# Drugi, większy rozbłysk
	var flash2 := ColorRect.new()
	flash2.color = Color(0.6, 0.95, 1, 0.5)
	flash2.size = Vector2(28, 28)
	flash2.global_position = player_pos + direction * 15 - Vector2(14, 14)
	get_tree().current_scene.add_child(flash2)
	var flash2_tween := create_tween()
	flash2_tween.tween_property(flash2, "size", Vector2(8, 8), 0.12)
	flash2_tween.parallel().tween_property(flash2, "modulate:a", 0.0, 0.12)
	flash2_tween.tween_callback(flash2.queue_free)

	can_attack = false
	attack_timer = weapon_data.attack_speed

func find_closest_enemy(from_pos: Vector2) -> Node2D:
	if not current_weapon:
		return null

	var max_range := current_weapon.weapon_range
	var enemies: Array[Node] = get_tree().get_nodes_in_group("Enemies")
	var closest_enemy: Node2D = null
	var closest_distance := max_range

	for enemy: Node in enemies:
		if enemy is Node2D:
			var distance := from_pos.distance_to(enemy.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_enemy = enemy

	return closest_enemy

func _process(delta: float) -> void:
	if not can_attack:
		attack_timer -= delta
		if attack_timer <= 0.0:
			can_attack = true

func is_ready() -> bool:
	return can_attack
