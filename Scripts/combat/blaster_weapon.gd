extends Node2D

var current_weapon: WeaponBase
var can_attack: bool = true
var attack_timer: float = 0.0
var projectile_scene: PackedScene = preload("res://scenes/Projectile.tscn")

func initialize(weapon_data: WeaponBase) -> void:
	current_weapon = weapon_data
	can_attack = true

func fire(player: Node2D, target_pos: Vector2, weapon_data: WeaponBase) -> void:
	if not can_attack:
		return

	var player_pos = player.global_position
	
	# Celuj DOKŁADNIE tam, gdzie jest myszka (target_pos)
	var direction := (target_pos - player_pos).normalized()

	# Strzelaj jedną kulą, ale bardzo szybko i w idealnej linii
	var projectile: Area2D = projectile_scene.instantiate()
	projectile.speed = 1700 # Jeszcze szybciej dla lepszej "strugi"
	projectile.damage = int(weapon_data.damage)
	projectile.direction = direction
	projectile.global_position = player_pos + direction * 25
	projectile.owner_node = player
	
	# Wizualizacja: Grubsza i dłuższa struga energetyczna
	projectile.scale = Vector2(1.2, 0.8) 
	projectile.modulate = Color(0, 0.9, 1.0, 3.0) # Ekstremalnie jasny błękit (neon)
	
	# BRAK NAMIERZANIA (Homing usunięty na żądanie)
	
	get_tree().current_scene.add_child(projectile)

	can_attack = false
	attack_timer = weapon_data.attack_speed

func _process(delta: float) -> void:
	if not can_attack:
		attack_timer -= delta
		if attack_timer <= 0.0:
			can_attack = true

func is_ready() -> bool:
	return can_attack
