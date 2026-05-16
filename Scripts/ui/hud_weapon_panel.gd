extends CanvasLayer
## Panel broni w HUD – pokazuje do 6 założonych broni z cooldownami

@onready var slots_container: HBoxContainer = $PanelContainer/HBoxContainer
@onready var panel_container: PanelContainer = $PanelContainer

var weapon_manager: Node = null
var weapon_slots_ui: Array = []

func _ready() -> void:
	# Ukryj panel na start, dopóki nie znajdziemy managera
	panel_container.visible = false
	
	# Znajdz WeaponManager gracza po 1 klatce
	await get_tree().process_frame
	_find_weapon_manager()
	
	# Zainicjalizuj istniejące sloty (jeśli są w scenie)
	for child in slots_container.get_children():
		if child is Panel:
			weapon_slots_ui.append(child)
			_setup_slot_signals(child, weapon_slots_ui.size() - 1)

func _setup_slot_signals(slot_panel: Panel, index: int) -> void:
	if not slot_panel.gui_input.is_connected(_on_slot_gui_input):
		slot_panel.gui_input.connect(_on_slot_gui_input.bind(index))
	slot_panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func _find_weapon_manager() -> void:
	var players := get_tree().get_nodes_in_group("Player")
	for p in players:
		var wm := p.get_node_or_null("WeaponManager")
		if wm:
			weapon_manager = wm
			panel_container.visible = true
			break

func _process(_delta: float) -> void:
	if not weapon_manager:
		if Engine.get_process_frames() % 60 == 0:
			_find_weapon_manager()
		return
	
	var weapons: Array = weapon_manager.get_weapons()
	var instances: Array = weapon_manager.weapon_instances
	var active_idx: int = weapon_manager.get("active_weapon_index") if weapon_manager.get("active_weapon_index") != null else 0
	
	# Dopasuj liczbę slotów UI do liczby broni (max 6)
	while weapon_slots_ui.size() < weapons.size() and weapon_slots_ui.size() < 6:
		_create_new_slot_ui()
	
	# Aktualizuj wszystkie sloty
	for i in range(weapon_slots_ui.size()):
		var slot_panel = weapon_slots_ui[i]
		if i < weapons.size():
			slot_panel.visible = true
			_update_slot_ui(slot_panel, weapons[i], instances[i] if i < instances.size() else null, i == active_idx)
		else:
			slot_panel.visible = false

func _create_new_slot_ui() -> void:
	# Klonujemy pierwszy dostępny slot lub tworzymy od zera
	var new_slot: Panel
	if weapon_slots_ui.size() > 0:
		new_slot = weapon_slots_ui[0].duplicate()
	else:
		# Fallback jeśli nie ma żadnego slotu w scenie
		new_slot = Panel.new()
		new_slot.custom_minimum_size = Vector2(100, 80)
		var vbox = VBoxContainer.new()
		vbox.name = "VBoxContainer"
		new_slot.add_child(vbox)
		var icon = TextureRect.new()
		icon.name = "WeaponIcon"
		vbox.add_child(icon)
		var cooldown = ColorRect.new()
		cooldown.name = "CooldownOverlay"
		vbox.add_child(cooldown)
		var name_lbl = Label.new()
		name_lbl.name = "WeaponName"
		vbox.add_child(name_lbl)

	slots_container.add_child(new_slot)
	weapon_slots_ui.append(new_slot)
	_setup_slot_signals(new_slot, weapon_slots_ui.size() - 1)

func _update_slot_ui(slot_panel: Panel, weapon: WeaponBase, instance: Node, is_active: bool) -> void:
	var icon: TextureRect = slot_panel.find_child("WeaponIcon*", true, false)
	var name_label: Label = slot_panel.find_child("WeaponName*", true, false)
	var cooldown: ColorRect = slot_panel.find_child("CooldownOverlay*", true, false)
	
	if icon:
		icon.visible = true
		icon.texture = weapon.icon
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(60, 60)
		
	if name_label:
		name_label.text = weapon.item_name
		name_label.add_theme_font_size_override("font_size", 10)
		
	if cooldown:
		if instance and instance.has_method("is_ready") and instance.get("can_attack") != null:
			if instance.can_attack:
				cooldown.visible = false
			else:
				cooldown.visible = true
				var timer: float = instance.get("attack_timer") if instance.get("attack_timer") != null else 0.0
				var total: float = weapon.attack_speed
				var fraction := 1.0 - (timer / total) if total > 0 else 1.0
				cooldown.anchor_top = fraction
				cooldown.color = Color(0, 0, 0, 0.6)
		else:
			cooldown.visible = false

	# Aktywny/nieaktywny wygląd
	if is_active:
		slot_panel.modulate = Color(1.2, 1.2, 1.2, 1.0)
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.1, 0.2, 0.3, 0.6)
		style.border_width_left = 2
		style.border_width_right = 2
		style.border_width_top = 2
		style.border_width_bottom = 2
		style.border_color = Color(0, 0.9, 1.0)
		slot_panel.add_theme_stylebox_override("panel", style)
	else:
		slot_panel.modulate = Color(0.7, 0.7, 0.7, 0.8)
		slot_panel.add_theme_stylebox_override("panel", null)

func _on_slot_gui_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if weapon_manager and weapon_manager.has_method("set_active_weapon"):
			weapon_manager.set_active_weapon(index)
