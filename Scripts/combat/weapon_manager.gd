extends Node
## Zarządza broniami gracza – sloty, instancje, aktywacja

@export var max_weapons: int = 2

var weapons: Array[WeaponBase] = []
var weapon_slots: Array[Sprite2D] = []
var weapon_instances: Array[Node] = []
var player_ref: Node2D = null


func _ready() -> void:
	player_ref = get_parent()


## Dodaje broń do ekwipunku gracza
## Zwraca true jeśli dodanie się powiodło, false jeśli brak miejsca
func add_weapon(weapon: WeaponBase) -> bool:
	if weapons.size() >= max_weapons:
		return false

	weapons.append(weapon)

	var script: Script = _get_weapon_script(weapon.weapon_type)
	if not script:
		weapons.pop_back()
		return false

	var instance: Node = script.new()
	add_child(instance)

	if weapon.weapon_type == "drone":
		instance.initialize(player_ref, weapon)
	else:
		instance.initialize(weapon)

	weapon_instances.append(instance)
	update_weapon_sprites()
	return true


## Ładuje skrypt broni na podstawie weapon_type
func _get_weapon_script(weapon_type: String) -> Script:
	match weapon_type:
		"shockwave":
			return load("res://Scripts/combat/shockwave_weapon.gd")
		"drone":
			return load("res://Scripts/combat/drone_weapon.gd")
		"blaster":
			return load("res://Scripts/combat/blaster_weapon.gd")
		"sword":
			return load("res://Scripts/combat/sword_weapon.gd")
	return null


## Usuwa broń o podanym indeksie
func remove_weapon(index: int) -> void:
	if index < 0 or index >= weapon_instances.size():
		return

	if is_instance_valid(weapon_instances[index]):
		weapon_instances[index].queue_free()

	weapons.remove_at(index)
	weapon_instances.remove_at(index)
	update_weapon_sprites()


## Czy jest wolny slot na broń
func has_slot() -> bool:
	return weapons.size() < max_weapons


## Zwraca tablicę posiadanych broni
func get_weapons() -> Array[WeaponBase]:
	return weapons


## Zwraca liczbę posiadanych broni
func get_weapon_count() -> int:
	return weapons.size()


## Aktualizuje widoczność i ikony sprite'ów slotów broni
func update_weapon_sprites() -> void:
	for i: int in range(max_weapons):
		if i < weapon_slots.size() and weapon_slots[i] and i < weapons.size():
			weapon_slots[i].visible = true
			if weapons[i].icon:
				weapon_slots[i].texture = weapons[i].icon
		elif i < weapon_slots.size() and weapon_slots[i]:
			weapon_slots[i].visible = false


## Wołane co klatkę – aktywuje wszystkie gotowe bronie
## Bronie same pilnują cooldownu przez is_ready()
func activate_all_weapons(target_pos: Vector2 = Vector2.ZERO) -> void:
	for i: int in range(weapon_instances.size()):
		var instance: Node = weapon_instances[i]
		if not is_instance_valid(instance):
			continue

		if not instance.is_ready():
			continue

		var weapon_data: WeaponBase = weapons[i]
		match weapon_data.weapon_type:
			"shockwave":
				instance.activate(player_ref.global_position, weapon_data)
			"drone":
				pass  # Atakuje automatycznie w _physics_process
			"blaster":
				var target: Node2D = _find_closest_enemy()
				if target:
					instance.fire(player_ref.global_position, target, weapon_data)
			"sword":
				var direction: Vector2 = _get_aim_direction(target_pos)
				instance.swing(player_ref.global_position, direction, weapon_data)


## Wyznacza kierunek celowania – z target_pos, velocity gracza lub domyślnie w prawo
func _get_aim_direction(target_pos: Vector2) -> Vector2:
	if target_pos != Vector2.ZERO and player_ref:
		return (target_pos - player_ref.global_position).normalized()

	if player_ref and "velocity" in player_ref:
		var vel: Vector2 = player_ref.velocity
		if vel.length() > 0:
			return vel.normalized()

	return Vector2.RIGHT


## Znajduje najbliższego wroga w grupie "Enemies"
func _find_closest_enemy() -> Node2D:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("Enemies")
	var closest: Node2D = null
	var closest_dist: float = INF

	for enemy: Node in enemies:
		if enemy is Node2D:
			var dist: float = player_ref.global_position.distance_to(enemy.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest = enemy

	return closest


## Drony same się aktualizują w _physics_process – metoda do ewentualnych kontroli stanu
func update_drones() -> void:
	pass
