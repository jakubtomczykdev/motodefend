extends CanvasLayer
## Panel broni w HUD – pokazuje 2 założone bronie z cooldownami

@onready var slot1_icon: TextureRect = %WeaponIcon1
@onready var slot1_name: Label = %WeaponName1
@onready var slot1_cooldown: ColorRect = %CooldownOverlay1
@onready var slot2_icon: TextureRect = %WeaponIcon2
@onready var slot2_name: Label = %WeaponName2
@onready var slot2_cooldown: ColorRect = %CooldownOverlay2

var weapon_manager: Node = null

func _ready() -> void:
	# Ukryj oba sloty na start
	slot1_icon.visible = false
	slot2_icon.visible = false
	slot1_cooldown.visible = false
	slot2_cooldown.visible = false
	
	# Znajdz WeaponManager gracza po 1 klatce
	await get_tree().process_frame
	_find_weapon_manager()

func _find_weapon_manager() -> void:
	var players := get_tree().get_nodes_in_group("Player")
	for p in players:
		var wm := p.get_node_or_null("WeaponManager")
		if wm:
			weapon_manager = wm
			break

func _process(_delta: float) -> void:
	if not weapon_manager:
		if Engine.get_process_frames() % 60 == 0:
			_find_weapon_manager()
		return
	
	var weapons: Array = weapon_manager.get_weapons()
	var instances: Array = weapon_manager.weapon_instances
	var active_idx: int = weapon_manager.get("active_weapon_index") if weapon_manager.get("active_weapon_index") != null else 0
	
	# Slot 1
	if weapons.size() >= 1:
		_update_slot(slot1_icon, slot1_name, slot1_cooldown, weapons[0], instances[0] if instances.size() > 0 else null)
		_set_slot_active(slot1_icon.get_parent().get_parent(), active_idx == 0)
	else:
		slot1_icon.visible = false
		slot1_cooldown.visible = false
		slot1_name.text = ""
	
	# Slot 2
	if weapons.size() >= 2:
		_update_slot(slot2_icon, slot2_name, slot2_cooldown, weapons[1], instances[1] if instances.size() > 1 else null)
		_set_slot_active(slot2_icon.get_parent().get_parent(), active_idx == 1)
	else:
		slot2_icon.visible = false
		slot2_cooldown.visible = false
		slot2_name.text = ""

func _update_slot(icon: TextureRect, name_label: Label, cooldown: ColorRect, weapon: WeaponBase, instance: Node) -> void:
	icon.visible = true
	name_label.text = weapon.get_display_name()
	
	if weapon.icon:
		icon.texture = weapon.icon
	
	# Cooldown overlay – odczytaj z instancji broni
	if instance and instance.has_method("is_ready") and instance.get("can_attack") != null:
		if instance.can_attack:
			cooldown.visible = false
		else:
			cooldown.visible = true
			var timer: float = instance.get("attack_timer") if instance.get("attack_timer") != null else 0.0
			var total: float = weapon.attack_speed
			var fraction := 1.0 - (timer / total) if total > 0 else 1.0
			cooldown.anchor_top = fraction
	else:
		cooldown.visible = false

func _set_slot_active(panel: Control, active: bool) -> void:
	if active:
		panel.modulate = Color(1.2, 1.2, 1.2, 1.0)
		# panel.scale = Vector2(1.05, 1.05) # Skalowanie może psuć layout w PanelContainer
	else:
		panel.modulate = Color(0.6, 0.6, 0.6, 0.7)
