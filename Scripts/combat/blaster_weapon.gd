extends Node2D

var current_weapon: WeaponBase
var can_attack: bool = true
var attack_timer: float = 0.0
var projectile_scene: PackedScene = preload("res://scenes/Projectile.tscn")
var player_ref: Node2D = null

# Burst state
var is_bursting: bool = false
var burst_shots_left: int = 0
var burst_timer: float = 0.0
var current_burst_target: Vector2 = Vector2.ZERO
var current_burst_origin: Vector2 = Vector2.ZERO

const MAX_BURST: int = 3
const BURST_DELAY: float = 0.08

func initialize(weapon_data: WeaponBase, p_player_ref: Node2D = null) -> void:
	current_weapon = weapon_data
	player_ref = p_player_ref
	can_attack = true
	is_bursting = false

func fire(player: Node2D, target_pos: Vector2, weapon_data: WeaponBase) -> void:
	fire_from_origin(player, player.global_position, target_pos, weapon_data)

func fire_from_origin(player: Node2D, origin_pos: Vector2, target_pos: Vector2, weapon_data: WeaponBase) -> void:
	if not can_attack or is_bursting:
		return

	player_ref = player
	current_weapon = weapon_data
	current_burst_target = target_pos
	current_burst_origin = origin_pos
	
	_start_burst_sequence()

func _start_burst_sequence() -> void:
	is_bursting = true
	burst_shots_left = MAX_BURST
	burst_timer = 0.0 # Fire first shot immediately
	
	can_attack = false
	
	# Mnożnik prędkości ataku
	var cooldown_mult: float = 1.0
	if player_ref and "attack_speed" in player_ref:
		cooldown_mult = 1.0 / max(player_ref.attack_speed, 0.1)
	
	attack_timer = current_weapon.attack_speed * cooldown_mult

func _process(delta: float) -> void:
	if is_bursting:
		burst_timer -= delta
		if burst_timer <= 0.0:
			_fire_single_shot()
			burst_timer = BURST_DELAY
			burst_shots_left -= 1
			if burst_shots_left <= 0:
				is_bursting = false
	elif not can_attack:
		attack_timer -= delta
		if attack_timer <= 0.0:
			can_attack = true

func _fire_single_shot() -> void:
	if not is_instance_valid(player_ref):
		is_bursting = false
		return

	# Ustal pozycję startową
	var spawn_pos = current_burst_origin
	if spawn_pos == player_ref.global_position and player_ref.has_node("Muzzle"):
		spawn_pos = player_ref.get_node("Muzzle").global_position

	var direction: Vector2 = (current_burst_target - spawn_pos).normalized()
	# Dodaj lekki rozrzut (spread)
	direction = direction.rotated(randf_range(-0.04, 0.04))

	var projectile: Area2D = projectile_scene.instantiate()
	projectile.speed = 1100.0 # Bardzo szybki pocisk "danych"
	
	var dmg_mult: float = 1.0
	if "damage" in player_ref:
		dmg_mult = player_ref.damage / 10.0
	
	projectile.damage = int(current_weapon.damage * dmg_mult * 0.5)
	projectile.direction = direction
	projectile.global_position = spawn_pos
	projectile.owner_node = player_ref

	# Ustaw wizualia i HITBOXY
	var sprite: Sprite2D = projectile.get_node_or_null("Sprite2D")
	var col_shape: CollisionShape2D = projectile.get_node_or_null("CollisionShape2D")
	
	if sprite:
		sprite.scale = Vector2(4.0, 1.5)
		sprite.modulate = Color(0.2, 0.9, 1.0, 1.0)
	
	# DOPASUJ HITBOX do wydłużonego kształtu pocisku
	if col_shape:
		# Używamy CapsuleShape2D dla podłużnych pocisków
		var capsule = CapsuleShape2D.new()
		capsule.radius = 4.0 
		capsule.height = 24.0 # More precise
		col_shape.shape = capsule
		col_shape.rotation = PI/2 # Horizontally aligned with sprite

	get_tree().current_scene.add_child(projectile)
	_spawn_muzzle_flash(spawn_pos, direction)
	
	# Recoil effect
	if player_ref is CharacterBody2D and "knockback_velocity" in player_ref:
		player_ref.knockback_velocity -= direction * 30.0

	AudioManager.play_sfx("blaster_shot", 0.1)

func _spawn_muzzle_flash(pos: Vector2, direction: Vector2) -> void:
	var flash := ColorRect.new()
	flash.size = Vector2(25, 25)
	flash.color = Color(0.1, 0.8, 1.0, 0.8)
	flash.global_position = pos - flash.size / 2
	flash.rotation = direction.angle()
	get_tree().current_scene.add_child(flash)

	var tween := create_tween()
	tween.tween_property(flash, "scale", Vector2(3.5, 0.3), 0.05)
	tween.parallel().tween_property(flash, "modulate:a", 0.0, 0.08)
	tween.tween_callback(flash.queue_free)

func is_ready() -> bool:
	return can_attack and not is_bursting
