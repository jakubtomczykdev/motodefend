extends Node
## Zarządza broniami gracza – sloty, instancje, aktywacja

@export var max_weapons: int = 2

var weapons: Array[WeaponBase] = []
var weapon_slots: Array[Sprite2D] = []
var weapon_instances: Array[Node] = []
var player_ref: Node2D = null

var active_weapon_index: int = 0

func _ready() -> void:
	player_ref = get_parent()
	_connect_weapon_slots()

## Podłącza sloty broni z zewnątrz (np. z player_combat)
func setup_slots(slot1: Sprite2D, slot2: Sprite2D = null) -> void:
	weapon_slots.clear()
	if slot1:
		weapon_slots.append(slot1)
	if slot2:
		weapon_slots.append(slot2)
	update_weapon_sprites()

func _connect_weapon_slots() -> void:
	if weapon_slots.size() > 0:
		return
	if not player_ref:
		return
	var s1 := player_ref.get_node_or_null("WeaponSlot1") as Sprite2D
	var s2 := player_ref.get_node_or_null("WeaponSlot2") as Sprite2D
	if not s1:
		s1 = player_ref.get_node_or_null("%WeaponSlot1") as Sprite2D
	if not s2:
		s2 = player_ref.get_node_or_null("%WeaponSlot2") as Sprite2D
	if s1:
		weapon_slots.append(s1)
	if s2:
		weapon_slots.append(s2)
	if weapon_slots.size() > 0:
		update_weapon_sprites()

func switch_weapon(next: bool = true) -> void:
	if weapons.size() <= 1:
		return
	
	if next:
		active_weapon_index = (active_weapon_index + 1) % weapons.size()
	else:
		active_weapon_index = (active_weapon_index - 1 + weapons.size()) % weapons.size()
	
	update_weapon_sprites()

func set_active_weapon(index: int) -> void:
	if index >= 0 and index < weapons.size():
		active_weapon_index = index
		update_weapon_sprites()

## Dodaje broń do ekwipunku gracza
func add_weapon(weapon: WeaponBase) -> bool:
	if weapons.size() >= max_weapons:
		return false

	weapons.append(weapon)

	var script: Script = _get_weapon_script(weapon.item_type)
	if not script:
		weapons.pop_back()
		return false

	var instance: Node = script.new()
	add_child(instance)

	if weapon.item_type == "drone":
		instance.initialize(player_ref, weapon)
	else:
		instance.initialize(weapon, player_ref)

	weapon_instances.append(instance)
	
	# Automatycznie ustaw nową broń jako aktywną, jeśli to pierwsza
	if weapons.size() == 1:
		active_weapon_index = 0
		
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
	
	if active_weapon_index >= weapons.size():
		active_weapon_index = max(0, weapons.size() - 1)
		
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
		if i < weapon_slots.size() and weapon_slots[i]:
			if i < weapons.size():
				weapon_slots[i].visible = true
				if weapons[i].icon:
					weapon_slots[i].texture = weapons[i].icon
				
				# Highlight active weapon
				if i == active_weapon_index:
					weapon_slots[i].modulate = Color(1.5, 1.5, 1.5, 1.0)
				else:
					weapon_slots[i].modulate = Color(0.6, 0.6, 0.6, 0.7)
			else:
				weapon_slots[i].visible = false

## Obraca sloty broni w kierunku celu (myszka / wróg)
func rotate_weapon_slots(target_pos: Vector2) -> void:
	if not player_ref:
		return
	var dir := (target_pos - player_ref.global_position).normalized()
	var angle := dir.angle()
	for i: int in range(weapon_slots.size()):
		var slot = weapon_slots[i]
		if slot.visible:
			slot.rotation = angle

## Wołane co klatkę – aktywuje wszystkie gotowe bronie
func activate_all_weapons(target_pos: Vector2 = Vector2.ZERO) -> void:
	rotate_weapon_slots(target_pos)
	
	for i: int in range(weapon_instances.size()):
		var instance: Node = weapon_instances[i]
		if not is_instance_valid(instance):
			continue

		var weapon_data: WeaponBase = weapons[i]
		
		# Drony są zawsze aktywne pasywnie (jeśli ich skrypt to wspiera)
		if weapon_data.item_type == "drone":
			if instance.has_method("update_drone"):
				instance.update_drone(target_pos)
			continue

		if not instance.is_ready():
			continue

		match weapon_data.item_type:
			"shockwave":
				var target_dir := _get_aim_direction(target_pos)
				instance.activate(player_ref.global_position, weapon_data, target_dir)
			"blaster":
				# Strzelaj prosto w stronę myszki (target_pos), bez auto-namierzania
				instance.fire(player_ref, target_pos, weapon_data)
			"sword":
				var direction: Vector2 = _get_aim_direction(target_pos)
				instance.swing(player_ref, direction, weapon_data)

## Wyznacza kierunek celowania
func _get_aim_direction(target_pos: Vector2) -> Vector2:
	if target_pos != Vector2.ZERO and player_ref:
		return (target_pos - player_ref.global_position).normalized()
	return Vector2.RIGHT

## Znajduje najbliższego wroga
func _find_closest_enemy(max_range: float = INF) -> Node2D:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("Enemies")
	var closest: Node2D = null
	var closest_dist: float = max_range
	for enemy: Node in enemies:
		if enemy is Node2D:
			var dist: float = player_ref.global_position.distance_to(enemy.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest = enemy
	return closest

func update_drones() -> void:
	pass
