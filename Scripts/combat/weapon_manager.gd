extends Node
## Zarządza broniami gracza – sloty, instancje, aktywacja

@export var max_weapons: int = 6
@export var orbital_radius: float = 65.0
@export var orbit_speed: float = 0.5
@export var weapon_scale: float = 0.067

var weapons: Array[WeaponBase] = []
var weapon_slots: Array[Sprite2D] = []
var weapon_instances: Array[Node] = []
var player_ref: Node2D = null

var active_weapon_index: int = 0
var _current_orbit_angle: float = 0.0

func _ready() -> void:
	player_ref = get_parent()
	# Clear any existing slots and prepare for dynamic creation
	for child in get_children():
		if child is Sprite2D and child.name.begins_with("DynamicWeaponSlot"):
			child.queue_free()
	weapon_slots.clear()

func _process(delta: float) -> void:
	if not player_ref:
		return
		
	_current_orbit_angle += delta * orbit_speed
	_update_weapon_positions(delta)

## Podłącza sloty broni z zewnątrz (pozostawione dla kompatybilności, ale będziemy nimi sterować)
func setup_slots(slot1: Sprite2D, slot2: Sprite2D = null) -> void:
	# W nowym systemie wolimy dynamiczne sloty, ale jeśli dostaniemy zewnętrzne, dodamy je
	if slot1 and not weapon_slots.has(slot1):
		weapon_slots.append(slot1)
	if slot2 and not weapon_slots.has(slot2):
		weapon_slots.append(slot2)
	update_weapon_sprites()

func _get_or_create_slot(index: int) -> Sprite2D:
	# Jeśli mamy już slot na tym indeksie, zwróć go
	if index < weapon_slots.size() and is_instance_valid(weapon_slots[index]):
		return weapon_slots[index]
	
	# W przeciwnym razie stwórz nowy
	var new_slot = Sprite2D.new()
	new_slot.name = "DynamicWeaponSlot_%d" % index
	new_slot.z_index = 1
	add_child(new_slot)
	
	# Jeśli tablica jest mniejsza, wypełnij ją nullami
	while weapon_slots.size() <= index:
		weapon_slots.append(null)
	
	weapon_slots[index] = new_slot
	return new_slot

func _update_weapon_positions(delta: float) -> void:
	var count = weapons.size()
	if count == 0: return
	
	# WYMUSZENIE: Zawsze celuj w stronę myszki dla orientacji graficznej wszystkich slotów orbitalnych
	var target_pos = player_ref.get_global_mouse_position()
	
	var angle_step = (2.0 * PI) / count
	
	for i in range(count):
		var slot = _get_or_create_slot(i)
		if not slot: continue
		
		# Oblicz pozycję w orbicie
		var angle = i * angle_step + _current_orbit_angle
		var offset = Vector2(cos(angle), sin(angle)) * orbital_radius
		
		# Płynne przesuwanie do pozycji (lerp dla organicznego ruchu)
		slot.position = slot.position.lerp(offset, delta * 15.0)
		
		# Celowanie w stronę kursora (wymuszone śledzenie myszy)
		var aim_dir = (target_pos - slot.global_position).normalized()
		slot.rotation = aim_dir.angle()
		
		# Efekt "oddechu" (pulsowanie skali)
		var pulse = 1.0 + sin(Time.get_ticks_msec() * 0.005 + i) * 0.05
		var current_scale = weapon_scale * pulse
		
		slot.scale.x = current_scale
		if aim_dir.x < 0:
			slot.scale.y = -current_scale
		else:
			slot.scale.y = current_scale

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
	
	if weapon.item_type == "drone":
		# Drony powinny być w korzeniu sceny, by móc swobodnie latać
		if instance.get_parent() == null:
			get_tree().current_scene.add_child(instance)
		instance.initialize(player_ref, weapon)
	else:
		if instance.get_parent() == null:
			add_child(instance)
		instance.initialize(weapon, player_ref)

	weapon_instances.append(instance)
	
	# Automatycznie stwórz slot wizualny
	_get_or_create_slot(weapons.size() - 1)
	
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
		
	# Usuń też slot dynamiczny
	if index < weapon_slots.size() and is_instance_valid(weapon_slots[index]):
		weapon_slots[index].queue_free()
		weapon_slots.remove_at(index)

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
	for i: int in range(weapon_slots.size()):
		var slot = weapon_slots[i]
		if not is_instance_valid(slot): continue
		
		if i < weapons.size():
			slot.visible = true
			if weapons[i].icon:
				slot.texture = weapons[i].icon
			
			# Podświetlenie aktywnej broni
			if i == active_weapon_index:
				slot.modulate = Color(1.3, 1.3, 1.3, 1.0)
			else:
				slot.modulate = Color(1.0, 1.0, 1.0, 0.9)
		else:
			slot.visible = false

## Obraca sloty broni w kierunku celu (Legacy, teraz obsługiwane w _process)
func rotate_weapon_slots(_target_pos: Vector2) -> void:
	pass

## Wołane co klatkę – aktywuje wszystkie gotowe bronie
func activate_all_weapons(target_pos: Vector2 = Vector2.ZERO) -> void:
	# Jeśli target_pos to ZERO (fallback), użyj myszki
	if target_pos == Vector2.ZERO:
		target_pos = player_ref.get_global_mouse_position()

	for i: int in range(weapon_instances.size()):
		var instance: Node = weapon_instances[i]
		if not is_instance_valid(instance):
			continue

		var weapon_data: WeaponBase = weapons[i]
		
		# Drony są inteligentne – same szukają wrogów
		if weapon_data.item_type == "drone":
			if instance.has_method("update_drone"):
				instance.update_drone(target_pos)
			continue

		if not instance.is_ready():
			continue

		# Używamy globalnej pozycji slotu dla wylotu pocisku/ataku
		var slot = _get_or_create_slot(i)
		var attack_origin = slot.global_position if is_instance_valid(slot) else player_ref.global_position

		match weapon_data.item_type:
			"shockwave":
				var target_dir: Vector2 = (target_pos - attack_origin).normalized()
				instance.activate(attack_origin, weapon_data, target_dir)
			"blaster":
				# Przekazujemy attack_origin do blastera, żeby strzelał ze slotu
				if instance.has_method("fire_from_origin"):
					instance.fire_from_origin(player_ref, attack_origin, target_pos, weapon_data)
				else:
					instance.fire(player_ref, target_pos, weapon_data)
			"sword":
				var direction: Vector2 = (target_pos - attack_origin).normalized()
				instance.swing(player_ref, direction, weapon_data)

## Znajduje najbliższego wroga
func _find_closest_enemy(max_range: float = INF) -> Node2D:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("Enemies")
	var closest: Node2D = null
	var closest_dist: float = max_range
	for enemy: Node in enemies:
		if enemy is Node2D:
			# Ignoruj martwych wrogów jeśli mają taką właściwość
			if "is_dead" in enemy and enemy.is_dead:
				continue
				
			var dist: float = player_ref.global_position.distance_to(enemy.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest = enemy
	return closest
