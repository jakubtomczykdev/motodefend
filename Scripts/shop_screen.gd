extends Control
## System sklepu Motorola - zaktualizowany pod design "Cyber-Kinetic"

signal item_purchased(item: ItemBase)
signal shop_closed
signal refresh_requested

## Cached GameData reference for the gold property getter/setter
var _game_data_ref = null

## SINGLE SOURCE OF TRUTH: gold reads/writes ONLY through GameData.gold
var gold: int:
	get:
		if _game_data_ref == null:
			_game_data_ref = get_node_or_null("/root/GameData")
		return _game_data_ref.gold if _game_data_ref else 100
	set(value):
		if _game_data_ref == null:
			_game_data_ref = get_node_or_null("/root/GameData")
		if _game_data_ref:
			_game_data_ref.gold = value

var shop_items: Array = []
var build_system: Node
var item_manager: Node

@onready var gold_label: Label = $TopBar/GoldLabel
@onready var items_container: Control = $MainArea/ItemsContainer # Cast to Control to be safe with HFlow/HBox
@onready var view_title: Label = $MainArea/ViewTitle
@onready var preview_icon: TextureRect = $MainArea/PreviewPanel/PreviewVBox/PreviewIcon
@onready var preview_name: Label = $MainArea/PreviewPanel/PreviewVBox/DetailsVBox/PreviewName
@onready var preview_rarity: Label = $MainArea/PreviewPanel/PreviewVBox/DetailsVBox/PreviewRarity
@onready var preview_description: Label = $MainArea/PreviewPanel/PreviewVBox/DetailsVBox/PreviewDescription
@onready var preview_cost: Label = $MainArea/PreviewPanel/PreviewVBox/DetailsVBox/PreviewCost
@onready var back_button: Button = $BottomBar/HBox/BackButton
@onready var reroll_button: Button = $BottomBar/HBox/RerollButton
@onready var inventory_button: Button = $BottomBar/HBox/InventoryButton
@onready var weapon_count_label: Label = $TopBar/WeaponCountLabel

var item_scene: PackedScene = preload("res://scenes/ShopItem.tscn")
var refresh_cost: int = 25
var showing_inventory: bool = false

func _ready() -> void:
	back_button.pressed.connect(_on_close_pressed)
	reroll_button.pressed.connect(_on_refresh_pressed)
	if inventory_button:
		inventory_button.pressed.connect(_toggle_inventory)
	_update_ui()
	_setup_retro_style()
	
	# Auto-populate with default weapons when shop loaded standalone
	await get_tree().process_frame
	if shop_items.is_empty():
		_refresh_shop_items()
	else:
		_populate_items()

func _setup_retro_style() -> void:
	var retro_font = preload("res://retropix.ttf")
	var theme = Theme.new()
	theme.default_font = retro_font
	theme.default_font_size = 20
	
	# Styl Panelu (dla TopBar, BottomBar, PreviewPanel)
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.05, 0.05, 0.1, 0.9)
	panel_style.border_width_left = 3
	panel_style.border_width_top = 3
	panel_style.border_width_right = 3
	panel_style.border_width_bottom = 3
	panel_style.border_color = Color(0.0, 0.8, 1.0) # Cyan
	panel_style.corner_radius_top_left = 2
	panel_style.corner_radius_top_right = 2
	panel_style.corner_radius_bottom_right = 2
	panel_style.corner_radius_bottom_left = 2
	
	# Styl Przycisku
	var btn_normal = StyleBoxFlat.new()
	btn_normal.bg_color = Color(0.1, 0.1, 0.2, 1.0)
	btn_normal.border_width_left = 2
	btn_normal.border_width_top = 2
	btn_normal.border_width_right = 2
	btn_normal.border_width_bottom = 2
	btn_normal.border_color = Color(0.0, 0.6, 0.8)
	
	var btn_hover = btn_normal.duplicate()
	btn_hover.bg_color = Color(0.2, 0.2, 0.4, 1.0)
	btn_hover.border_color = Color(0.0, 1.0, 1.0)
	
	theme.set_stylebox("panel", "Panel", panel_style)
	theme.set_stylebox("normal", "Button", btn_normal)
	theme.set_stylebox("hover", "Button", btn_hover)
	theme.set_stylebox("focus", "Button", btn_hover)
	
	self.theme = theme
	
	# Etykiety
	if view_title:
		view_title.add_theme_font_size_override("font_size", 32)
		view_title.add_theme_color_override("font_color", Color(0, 1, 1))
		
	# Tło Matrix
	var bg = get_node_or_null("Background")
	if bg:
		var matrix_shader = preload("res://matrix.gdshader")
		var shader_mat = ShaderMaterial.new()
		shader_mat.shader = matrix_shader
		shader_mat.set_shader_parameter("icon_tex", preload("res://icon_tex.png"))
		shader_mat.set_shader_parameter("speed", 0.08)
		shader_mat.set_shader_parameter("intensity", 0.3)
		bg.material = shader_mat
	
	# Stylizacja Preview Panel
	var preview_panel = get_node_or_null("MainArea/PreviewPanel")
	if preview_panel:
		preview_panel.add_theme_stylebox_override("panel", panel_style)

func open_shop(available_items: Array[ItemBase], player_build: Node, manager: Node) -> void:
	shop_items = available_items
	build_system = player_build
	item_manager = manager
	showing_inventory = false

	_refresh_view()
	_update_ui()

	visible = true

func _refresh_view() -> void:
	_clear_items()
	if showing_inventory:
		view_title.text = "TWOJE WYPOSAŻENIE"
		_populate_inventory()
		inventory_button.text = "Pokaż SKLEP"
	else:
		view_title.text = "DOSTĘPNA TECHNOLOGIA"
		_populate_items()
		inventory_button.text = "Moje EQ (%d/6)" % _get_current_weapon_count()

func _clear_items() -> void:
	for child in items_container.get_children():
		child.queue_free()

func _populate_items() -> void:
	for item in shop_items:
		var item_ui = item_scene.instantiate()
		items_container.add_child(item_ui)
		item_ui.setup_item(item, gold)
		item_ui.item_clicked.connect(_on_item_clicked)
		item_ui.mouse_entered.connect(_update_preview.bind(item))

func _populate_inventory() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	var owned_items = []
	
	if player and player.has_method("get_weapons"):
		owned_items = player.get_weapons()
	else:
		var gd = get_node_or_null("/root/GameData")
		if gd:
			var all_weps = WeaponItems.get_all_weapons()
			for wid in gd.pending_weapon_ids:
				if wid < all_weps.size():
					owned_items.append(all_weps[wid])

	for item in owned_items:
		var item_ui = item_scene.instantiate()
		items_container.add_child(item_ui)
		item_ui.set_as_inventory_item()
		item_ui.setup_item(item, gold)
		item_ui.item_clicked.connect(_on_inventory_item_sold)
		item_ui.mouse_entered.connect(_update_preview.bind(item))

func _on_inventory_item_sold(item: ItemBase) -> void:
	var gd = get_node_or_null("/root/GameData")
	if not gd: return
	
	var refund = int(item.cost * 0.5)
	
	# Usuń z gracza
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_node("WeaponManager"):
		var p_weapons = player.get_weapons()
		for i in range(p_weapons.size()):
			if p_weapons[i].item_name == item.item_name:
				player.get_node("WeaponManager").remove_weapon(i)
				break
	
	# Usuń z GameData
	var all_weps = WeaponItems.get_all_weapons()
	for i in range(gd.pending_weapon_ids.size()):
		var wid = gd.pending_weapon_ids[i]
		if all_weps[wid].item_name == item.item_name:
			gd.pending_weapon_ids.remove_at(i)
			break
			
	gold += refund
	AudioManager.play_sfx("buy_item")
	_refresh_view()
	_update_ui()

func _toggle_inventory() -> void:
	showing_inventory = !showing_inventory
	_refresh_view()
	AudioManager.play_sfx("menu_click")

func _update_preview(item: ItemBase) -> void:
	if item == null: return
	preview_name.text = item.item_name
	preview_rarity.text = "Rzadkość: " + item.rarity.capitalize()
	preview_description.text = item.description
	
	if showing_inventory:
		preview_cost.text = "Wartość sprzedaży: " + str(int(item.cost * 0.5))
	else:
		preview_cost.text = "Koszt: " + str(item.cost)
	
	if item.icon:
		preview_icon.texture = item.icon
	
	# Colorize rarity in preview
	var color := Color(1, 1, 1)
	match item.rarity.to_lower():
		"common": color = Color(0.7, 0.7, 0.7)
		"uncommon": color = Color(0.3, 0.8, 0.5)
		"rare": color = Color(0, 0.6, 1.0)
		"epic": color = Color(0.6, 0.2, 0.9)
		"legendary": color = Color(1.0, 0.8, 0.0)
	preview_rarity.modulate = color

func _on_item_clicked(item: ItemBase) -> void:
	if gold >= item.cost:
		# Check weapon limit
		if item is WeaponBase:
			var weapon_count = _get_current_weapon_count()
			if weapon_count >= 6:
				AudioManager.play_sfx("menu_click")
				return

		AudioManager.play_sfx("buy_item")
		gold -= item.cost
		item_purchased.emit(item)
		
		if build_system:
			build_system.add_item(item)
		else:
			var gd = get_node_or_null("/root/GameData")
			if gd:
				gd.add_inventory_item(item)
				if item is WeaponBase:
					var all_weps = WeaponItems.get_all_weapons()
					for i in range(all_weps.size()):
						var candidate = all_weps[i]
						if candidate != null and candidate.item_name == item.item_name and candidate.item_type == item.item_type:
							gd.pending_weapon_ids.append(i)
							break
		
		var player = get_tree().get_first_node_in_group("Player")
		if player and item is WeaponBase and player.has_method("add_weapon"):
			player.add_weapon(item)

		_update_ui()
		_update_item_states()

func _on_refresh_pressed() -> void:
	if gold >= refresh_cost:
		AudioManager.play_sfx("menu_click")
		gold -= refresh_cost
		_update_ui()
		refresh_requested.emit()
		_refresh_shop_items()

func _refresh_shop_items() -> void:
	if item_manager and item_manager.has_method("get_shop_items") and build_system:
		shop_items = item_manager.get_shop_items(4, 1)
	else:
		var weapons = WeaponItems.get_all_weapons()
		weapons.shuffle()
		shop_items.clear()
		var count = mini(4, weapons.size())
		for i in range(count):
			shop_items.append(weapons[i])
	
	showing_inventory = false
	_refresh_view()

func _get_current_weapon_count() -> int:
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("get_weapon_count"):
		return player.get_weapon_count()
	
	var gd = get_node_or_null("/root/GameData")
	if gd:
		return gd.pending_weapon_ids.size()
	return 0

func _update_item_states() -> void:
	for child in items_container.get_children():
		if child.has_method("update_affordability"):
			child.update_affordability(gold)

func _update_ui() -> void:
	gold_label.text = "ZLOTO: %d" % gold
	if weapon_count_label:
		var count = _get_current_weapon_count()
		weapon_count_label.text = "BRONIE: %d / 6" % count
		if count >= 6: weapon_count_label.modulate = Color(1, 0.4, 0.4)
		else: weapon_count_label.modulate = Color(0.7, 0.8, 1.0)
	
	if inventory_button:
		var count = _get_current_weapon_count()
		if not showing_inventory:
			inventory_button.text = "Moje EQ (%d/6)" % count

func _on_close_pressed() -> void:
	AudioManager.play_sfx("menu_click")
	if get_parent() == get_tree().root:
		get_tree().change_scene_to_file("res://scenes/GameStartScreen.tscn")
	else:
		visible = false
		shop_closed.emit()

func add_gold(amount: int) -> void:
	gold += amount
	_update_ui()

func set_gold(amount: int) -> void:
	gold = amount
	_update_ui()

func get_gold() -> int:
	return gold
