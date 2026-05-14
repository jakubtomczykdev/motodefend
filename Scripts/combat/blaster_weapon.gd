extends Node2D

var current_weapon: WeaponBase
var can_attack: bool = true
var attack_timer: float = 0.0
var projectile_scene: PackedScene = preload("res://scenes/Projectile.tscn")
var player_ref: Node2D = null

func initialize(weapon_data: WeaponBase, p_player_ref: Node2D = null) -> void:
	current_weapon = weapon_data
	player_ref = p_player_ref
	can_attack = true

func fire(player: Node2D, target_pos: Vector2, weapon_data: WeaponBase) -> void:
	if not can_attack:
		return

	var spawn_pos: Vector2
	if player_ref and player_ref.has_node("Muzzle"):
		spawn_pos = player_ref.get_node("Muzzle").global_position
	else:
		spawn_pos = player.global_position + (target_pos - player.global_position).normalized() * 25.0

	var direction := (target_pos - spawn_pos).normalized()

	var projectile: Area2D = projectile_scene.instantiate()
	projectile.speed = 800
	
	# Mnożnik obrażeń z build systemu gracza
	var dmg_mult: float = 1.0
	if player_ref and "damage" in player_ref:
		dmg_mult = player_ref.damage / 10.0
	projectile.damage = int(weapon_data.damage * dmg_mult)
	
	projectile.direction = direction
	projectile.global_position = spawn_pos
	projectile.owner_node = player

	# Wizualizacja pocisku – ustawiamy skalę i kolor na Sprite2D
	var sprite: Sprite2D = projectile.get_node_or_null("Sprite2D")
	if sprite:
		sprite.scale = Vector2(4.0, 4.0)
		sprite.modulate = Color(0.2, 0.95, 1.0, 1.0)

	get_tree().current_scene.add_child(projectile)

	# Efekt muzzle flash
	_spawn_muzzle_flash(spawn_pos, direction)

	# Mnożnik prędkości ataku z build systemu gracza
	var cooldown_mult: float = 1.0
	if player_ref and "attack_speed" in player_ref:
		cooldown_mult = 1.0 / max(player_ref.attack_speed, 0.1)

	can_attack = false
	AudioManager.play_sfx("blaster_shot")
	attack_timer = weapon_data.attack_speed * cooldown_mult

func _spawn_muzzle_flash(pos: Vector2, direction: Vector2) -> void:
	# Main flash - bigger
	var flash := ColorRect.new()
	flash.size = Vector2(30, 30)
	flash.color = Color(0.4, 0.95, 1.0, 0.9)
	flash.global_position = pos - flash.size / 2
	flash.rotation = direction.angle()
	get_tree().current_scene.add_child(flash)

	var tween := create_tween()
	tween.tween_property(flash, "size", Vector2(60, 15), 0.06)  # Expand horizontally
	tween.parallel().tween_property(flash, "modulate:a", 0.0, 0.12)
	tween.tween_callback(flash.queue_free)

	# Secondary ring flash
	var ring := ColorRect.new()
	ring.size = Vector2(8, 8)
	ring.color = Color(1, 1, 1, 0.7)
	ring.global_position = pos - ring.size / 2
	get_tree().current_scene.add_child(ring)
	var rt := create_tween()
	rt.tween_property(ring, "size", Vector2(40, 40), 0.08)
	rt.parallel().tween_property(ring, "modulate:a", 0.0, 0.1)
	rt.tween_callback(ring.queue_free)

func _process(delta: float) -> void:
	if not can_attack:
		attack_timer -= delta
		if attack_timer <= 0.0:
			can_attack = true

func is_ready() -> bool:
	return can_attack
