extends Node2D

var current_weapon: WeaponBase
var can_attack: bool = true
var attack_timer: float = 0.0
var projectile_scene: PackedScene = preload("res://scenes/game/Projectile.tscn")
var player_ref: Node2D = null

var is_bursting: bool = false
var burst_count: int = 0
var max_burst: int = 3
var burst_delay: float = 0.08

func initialize(weapon_data: WeaponBase, p_player_ref: Node2D = null) -> void:
	current_weapon = weapon_data
	player_ref = p_player_ref
	can_attack = true

func fire(player: Node2D, target_pos: Vector2, weapon_data: WeaponBase) -> void:
	if not can_attack or is_bursting:
		return

	player_ref = player
	_start_burst(target_pos, weapon_data)

func _start_burst(target_pos: Vector2, weapon_data: WeaponBase) -> void:
	is_bursting = true
	burst_count = 0
	
	# Mnożnik prędkości ataku z build systemu gracza
	var cooldown_mult: float = 1.0
	if player_ref and "attack_speed" in player_ref:
		cooldown_mult = 1.0 / max(player_ref.attack_speed, 0.1)

	can_attack = false
	attack_timer = weapon_data.attack_speed * cooldown_mult
	
	_fire_burst_shot(target_pos, weapon_data)

func _fire_burst_shot(target_pos: Vector2, weapon_data: WeaponBase) -> void:
	if not is_instance_valid(player_ref):
		is_bursting = false
		return

	var spawn_pos: Vector2
	if player_ref.has_node("Muzzle"):
		spawn_pos = player_ref.get_node("Muzzle").global_position
	else:
		spawn_pos = player_ref.global_position + (target_pos - player_ref.global_position).normalized() * 25.0

	var dmg_mult: float = 1.0
	if "damage" in player_ref:
		dmg_mult = player_ref.damage / 10.0

	var base_direction := (target_pos - spawn_pos).normalized()
	var projectile_total := 1
	if "projectile_count" in player_ref:
		projectile_total = maxi(1, int(player_ref.projectile_count))

	for shot_index in range(projectile_total):
		var direction := base_direction.rotated(_get_spread_angle(shot_index, projectile_total) + randf_range(-0.03, 0.03))
		var projectile: Area2D = projectile_scene.instantiate()
		projectile.speed = player_ref.projectile_speed if "projectile_speed" in player_ref else 900
		projectile.damage = _roll_damage(int(weapon_data.damage * dmg_mult * 0.45))
		if "pierce" in player_ref and player_ref.pierce > 0:
			projectile.can_pierce = true
			projectile.max_pierce_count = int(player_ref.pierce)
		projectile.direction = direction
		projectile.global_position = spawn_pos
		projectile.owner_node = player_ref

		var sprite: Sprite2D = projectile.get_node_or_null("Sprite2D")
		if sprite:
			sprite.scale = Vector2(3.5, 1.5)
			sprite.modulate = Color(0.2, 0.9, 1.0, 1.0)

		get_tree().current_scene.add_child(projectile)
		_spawn_muzzle_flash(spawn_pos, direction)
	
	AudioManager.play_sfx("blaster_shot", 0.15)
	
	burst_count += 1
	if burst_count < max_burst:
		get_tree().create_timer(burst_delay).timeout.connect(_fire_burst_shot.bind(target_pos, weapon_data))
	else:
		is_bursting = false
func _spawn_muzzle_flash(pos: Vector2, direction: Vector2) -> void:
	# Tech-flash
	var flash := ColorRect.new()
	flash.size = Vector2(20, 20)
	flash.color = Color(0.1, 0.8, 1.0, 0.8)
	flash.global_position = pos - flash.size / 2
	flash.rotation = direction.angle()
	get_tree().current_scene.add_child(flash)

	var tween := create_tween()
	tween.tween_property(flash, "scale", Vector2(3, 0.5), 0.05)
	tween.parallel().tween_property(flash, "modulate:a", 0.0, 0.1)
	tween.tween_callback(flash.queue_free)

func _process(delta: float) -> void:
	if not can_attack and not is_bursting:
		attack_timer -= delta
		if attack_timer <= 0.0:
			can_attack = true

func is_ready() -> bool:
	return can_attack and not is_bursting

func _roll_damage(base_damage: int) -> int:
	if player_ref and "crit_chance" in player_ref and randf() < player_ref.crit_chance:
		var crit_mult: float = player_ref.crit_damage if "crit_damage" in player_ref else 1.5
		return int(base_damage * crit_mult)
	return base_damage

func _get_spread_angle(index: int, total: int) -> float:
	if total <= 1:
		return 0.0
	var spread: float = minf(0.35, 0.08 * float(total - 1))
	return lerpf(-spread, spread, float(index) / float(total - 1))
