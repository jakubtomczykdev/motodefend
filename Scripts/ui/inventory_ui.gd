extends CanvasLayer
## Menu ekwipunku – wybór aktywnej broni

@onready var panel: Panel = $Panel
@onready var items_container: VBoxContainer = $Panel/VBoxContainer/ItemsContainer
@onready var close_button: Button = $Panel/VBoxContainer/CloseButton
@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel

var weapon_manager: Node = null
var player_ref: Node = null

func _ready() -> void:
	visible = false
	if close_button:
		close_button.pressed.connect(hide_inventory)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_focus_next") or (event is InputEventKey and event.keycode == KEY_I and event.pressed):
		if visible:
			hide_inventory()
		else:
			show_inventory()
	if event.is_action_pressed("ui_cancel") and visible:
		hide_inventory()

func show_inventory() -> void:
	_find_player()
	if not weapon_manager:
		return
	visible = true
	_populate_items()
	get_tree().paused = true

func hide_inventory() -> void:
	visible = false
	get_tree().paused = false
	_clear_items()

func _find_player() -> void:
	if player_ref and is_instance_valid(player_ref):
		return
	var players := get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player_ref = players[0]
		weapon_manager = player_ref.get_node_or_null("WeaponManager")

func _clear_items() -> void:
	if not items_container:
		return
	for child in items_container.get_children():
		child.queue_free()

func _populate_items() -> void:
	_clear_items()
	if not weapon_manager:
		return
	
	var weapons: Array = weapon_manager.get_weapons()
	var active_idx: int = weapon_manager.get("active_weapon_index") if weapon_manager.get("active_weapon_index") != null else 0
	
	if weapons.is_empty():
		var empty_label := Label.new()
		empty_label.text = "Brak broni w ekwipunku"
		items_container.add_child(empty_label)
		return
	
	for i in range(weapons.size()):
		var weapon: WeaponBase = weapons[i]
		var row := HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		# Ikona
		var icon_rect := TextureRect.new()
		icon_rect.custom_minimum_size = Vector2(48, 48)
		icon_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		if weapon.icon:
			icon_rect.texture = weapon.icon
		row.add_child(icon_rect)
		
		# Nazwa
		var name_label := Label.new()
		name_label.text = weapon.get_display_name()
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.add_child(name_label)
		
		# Przycisk Wybierz
		var select_btn := Button.new()
		select_btn.text = "Wybierz" if i != active_idx else "Aktywna"
		select_btn.disabled = (i == active_idx)
		select_btn.pressed.connect(_on_weapon_selected.bind(i))
		row.add_child(select_btn)
		
		items_container.add_child(row)
		
		# Separator
		if i < weapons.size() - 1:
			var sep := HSeparator.new()
			items_container.add_child(sep)

func _on_weapon_selected(index: int) -> void:
	if weapon_manager and weapon_manager.has_method("set_active_weapon"):
		weapon_manager.set_active_weapon(index)
	_populate_items()
