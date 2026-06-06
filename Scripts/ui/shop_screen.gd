extends Control
## System sklepu Motorola - cyber/pixel shop z progresja tierow.

signal item_purchased(item: ItemBase)
signal shop_closed
signal refresh_requested

var _game_data_ref = null

var gold: int:
	get:
		if _game_data_ref == null:
			_game_data_ref = get_node_or_null("/root/GameData")
		return _game_data_ref.gold if _game_data_ref else BalanceData.STARTING_GOLD
	set(value):
		if _game_data_ref == null:
			_game_data_ref = get_node_or_null("/root/GameData")
		if _game_data_ref:
			_game_data_ref.gold = value

var shop_items: Array = []
var build_system: Node
var item_manager: Node
var item_scene: PackedScene = preload("res://scenes/ui/ShopItem.tscn")
var refresh_cost: int = BalanceData.BASE_REROLL_COST
var showing_inventory: bool = false
var current_wave_number: int = 1
var current_shop_tier: int = 1
var _opened_externally: bool = false
var rerolls_this_visit: int = 0
var _status_message: String = ""
var _status_is_error: bool = false
var _purchased_offer_item_keys: Dictionary = {}

@onready var gold_label: Label = $TopBar/GoldLabel
@onready var items_container: Control = $MainArea/ItemsContainer
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

func _ready() -> void:
	back_button.pressed.connect(_on_close_pressed)
	reroll_button.pressed.connect(_on_refresh_pressed)
	if inventory_button:
		inventory_button.pressed.connect(_toggle_inventory)
	_setup_retro_style()
	_update_ui()

	await get_tree().process_frame
	if _opened_externally:
		return
	if shop_items.is_empty():
		_sync_wave_from_gamedata()
		_refresh_shop_items()
	else:
		_populate_items()

func open_shop(available_items: Array[ItemBase], player_build: Node, manager: Node, wave_number: int = 1) -> void:
	_opened_externally = true
	shop_items = available_items
	_purchased_offer_item_keys.clear()
	build_system = player_build
	item_manager = manager
	current_wave_number = max(wave_number, 1)
	current_shop_tier = _get_shop_tier(current_wave_number)
	rerolls_this_visit = 0
	_set_status_message("")
	showing_inventory = false
	if shop_items.is_empty():
		_refresh_shop_items()
		_update_ui()
		visible = true
		return

	_refresh_view()
	_update_ui()
	visible = true

func _setup_retro_style() -> void:
	var ui_font = preload("res://Assets/fonts/VT323-Regular.ttf")
	var custom_theme = Theme.new()
	custom_theme.default_font = ui_font
	custom_theme.default_font_size = 24

	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.05, 0.05, 0.1, 0.9)
	panel_style.border_width_left = 3
	panel_style.border_width_top = 3
	panel_style.border_width_right = 3
	panel_style.border_width_bottom = 3
	panel_style.border_color = Color(0.0, 0.8, 1.0)
	panel_style.corner_radius_top_left = 2
	panel_style.corner_radius_top_right = 2
	panel_style.corner_radius_bottom_right = 2
	panel_style.corner_radius_bottom_left = 2

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

	custom_theme.set_stylebox("panel", "Panel", panel_style)
	custom_theme.set_stylebox("normal", "Button", btn_normal)
	custom_theme.set_stylebox("hover", "Button", btn_hover)
	custom_theme.set_stylebox("focus", "Button", btn_hover)
	self.theme = custom_theme

	if view_title:
		view_title.add_theme_font_size_override("font_size", 34)
		view_title.add_theme_color_override("font_color", Color(0, 1, 1))

	var bg = get_node_or_null("Background")
	if bg:
		var matrix_shader = preload("res://Assets/shaders/matrix.gdshader")
		var shader_mat = ShaderMaterial.new()
		shader_mat.shader = matrix_shader
		shader_mat.set_shader_parameter("icon_tex", preload("res://Assets/sprites/icon_tex.png"))
		shader_mat.set_shader_parameter("speed", 0.08)
		shader_mat.set_shader_parameter("intensity", 0.3)
		bg.material = shader_mat

	var preview_panel = get_node_or_null("MainArea/PreviewPanel")
	if preview_panel:
		preview_panel.add_theme_stylebox_override("panel", panel_style)

func _refresh_view() -> void:
	_clear_items()
	if showing_inventory:
		view_title.text = "TWOJE WYPOSAŻENIE"
		_populate_inventory()
		inventory_button.text = "Pokaż SKLEP"
	else:
		view_title.text = "DOSTĘPNA TECHNOLOGIA | SKLEP TIER %d | FALA %d" % [current_shop_tier, current_wave_number]
		_populate_items()
		inventory_button.text = "Moje EQ (%d/%d)" % [_get_current_build_count(), _get_max_build_slots()]

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
	if not shop_items.is_empty():
		_update_preview(shop_items[0])
	_update_item_states()

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
	if not gd:
		return

	var refund = int(item.cost * 0.5)
	var player = get_tree().get_first_node_in_group("Player")
	var sold := false
	if player and player.has_node("WeaponManager"):
		var p_weapons = player.get_weapons()
		for i in range(p_weapons.size()):
			if _items_match(p_weapons[i], item):
				player.get_node("WeaponManager").remove_weapon(i)
				sold = true
				break

	if not sold:
		_set_status_message("Nie można sprzedać tego przedmiotu.", true)
		return

	var all_weps = WeaponItems.get_all_weapons()
	for i in range(gd.pending_weapon_ids.size()):
		var wid = gd.pending_weapon_ids[i]
		if _items_match(all_weps[wid], item):
			gd.pending_weapon_ids.remove_at(i)
			break

	_remove_matching_item_from_array(gd.inventory, item)

	if build_system:
		var build_item := _find_matching_build_item(item)
		if build_item != null:
			build_system.remove_item(build_item)

	var main = get_tree().current_scene
	if main and "items_collected" in main:
		_remove_matching_item_from_array(main.items_collected, item)

	gold += refund
	if gd.has_method("record_gold_income"):
		gd.record_gold_income("sale_refund", refund, current_wave_number)
	AudioManager.play_sfx("buy_item")
	_set_status_message("Sprzedano: %s" % item.item_name)
	_refresh_view()
	_update_ui()

func _toggle_inventory() -> void:
	showing_inventory = !showing_inventory
	_refresh_view()
	AudioManager.play_sfx("menu_click")

func _update_preview(item: ItemBase) -> void:
	if item == null:
		return

	preview_name.text = item.item_name
	if item is WeaponBase:
		var weapon := item as WeaponBase
		preview_rarity.text = "Rzadkość: %s | LVL %s | Tier %d+" % [item.rarity.capitalize(), weapon.get_level_suffix(), weapon.min_shop_tier]
	else:
		preview_rarity.text = "Rzadkość: " + item.rarity.capitalize()
	preview_description.text = item.description

	if showing_inventory:
		preview_cost.text = "Wartość sprzedaży: " + str(int(item.cost * 0.5))
	else:
		preview_cost.text = "Koszt: " + str(item.cost)

	if item.icon:
		preview_icon.texture = item.icon

	var color := Color(1, 1, 1)
	match item.rarity.to_lower():
		"common": color = Color(0.7, 0.7, 0.7)
		"uncommon": color = Color(0.3, 0.8, 0.5)
		"rare": color = Color(0, 0.6, 1.0)
		"epic": color = Color(0.6, 0.2, 0.9)
		"legendary": color = Color(1.0, 0.8, 0.0)
	preview_rarity.modulate = color

func _on_item_clicked(item: ItemBase) -> void:
	if not _can_purchase_item(item):
		return

	var gd = get_node_or_null("/root/GameData")
	var player = get_tree().get_first_node_in_group("Player")
	var added_to_build := false
	var queued_for_hub := false

	if _is_backpack_expansion(item):
		if not _apply_backpack_expansion(gd):
			AudioManager.play_sfx("menu_click")
			_set_status_message("Nie udało się powiększyć plecaka.", true)
			return

		AudioManager.play_sfx("buy_item")
		gold -= item.cost
		if gd and gd.has_method("record_gold_spent"):
			gd.record_gold_spent("shop_purchase", item.cost, current_wave_number)

		_purchased_offer_item_keys[_get_item_key(item)] = true
		_set_status_message("Plecak powiększony: %d / %d slotów." % [_get_current_build_count(), _get_max_build_slots()])
		item_purchased.emit(item)
		_update_ui()
		_update_item_states()
		return

	if build_system:
		if not build_system.add_item(item):
			AudioManager.play_sfx("menu_click")
			_set_status_message("Build jest pełny. Sprzedaj coś przed zakupem.", true)
			return
		added_to_build = true

	if item is WeaponBase:
		if build_system == null and gd:
			_save_weapon_to_pending(item as WeaponBase, gd)
			queued_for_hub = true
		else:
			if not player or not player.has_method("add_weapon"):
				if added_to_build and build_system:
					build_system.remove_item(item)
				AudioManager.play_sfx("menu_click")
				_set_status_message("Nie udało się dodać broni do ekwipunku.", true)
				return
			if not player.add_weapon(item):
				if added_to_build and build_system:
					build_system.remove_item(item)
				AudioManager.play_sfx("menu_click")
				_set_status_message("Brak wolnego slotu na broń.", true)
				return
	elif build_system == null and gd:
		gd.add_inventory_item(item)

	AudioManager.play_sfx("buy_item")
	gold -= item.cost
	if gd and gd.has_method("record_gold_spent"):
		gd.record_gold_spent("shop_purchase", item.cost, current_wave_number)

	if queued_for_hub:
		_set_status_message("Kupiono: %s. Broń będzie dostępna od następnej fali." % item.item_name)
	else:
		_set_status_message("Kupiono: %s" % item.item_name)

	_purchased_offer_item_keys[_get_item_key(item)] = true
	item_purchased.emit(item)

	_update_ui()
	_update_item_states()

func _on_refresh_pressed() -> void:
	if gold < refresh_cost:
		AudioManager.play_sfx("menu_click")
		_set_status_message("Za mało złota na reroll.", true)
		return

	var gd = get_node_or_null("/root/GameData")
	var current_cost := refresh_cost
	AudioManager.play_sfx("menu_click")
	gold -= current_cost
	if gd and gd.has_method("record_gold_spent"):
		gd.record_gold_spent("reroll", current_cost, current_wave_number)
	rerolls_this_visit += 1
	_set_status_message("")
	_update_ui()
	refresh_requested.emit()
	_refresh_shop_items()

func _refresh_shop_items() -> void:
	_purchased_offer_item_keys.clear()
	current_shop_tier = _get_shop_tier(current_wave_number)
	if item_manager and item_manager.has_method("get_shop_items"):
		shop_items = item_manager.get_shop_items(4, current_wave_number)
	else:
		var weapons = WeaponItems.get_weapons_for_shop_tier(current_shop_tier)
		weapons.shuffle()
		shop_items.clear()
		var count = mini(4, weapons.size())
		for i in range(count):
			shop_items.append(weapons[i])

	showing_inventory = false
	_refresh_view()

func _get_current_build_count() -> int:
	if build_system:
		var build_items = build_system.get("items")
		if build_items is Array:
			return build_items.size()

	var gd = get_node_or_null("/root/GameData")
	if gd:
		return gd.inventory.size()
	return 0

func _get_max_build_slots() -> int:
	if build_system:
		var max_slots = build_system.get("max_item_slots")
		if max_slots != null:
			return int(max_slots)
	var gd = get_node_or_null("/root/GameData")
	if gd and gd.has_method("get_max_item_slots"):
		return int(gd.get_max_item_slots())
	return BalanceData.MAX_BUILD_SLOTS

func _get_current_weapon_count() -> int:
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("get_weapon_count"):
		return player.get_weapon_count()

	var gd = get_node_or_null("/root/GameData")
	if gd:
		return gd.pending_weapon_ids.size()
	return 0

func _get_max_weapon_slots() -> int:
	return BalanceData.MAX_WEAPON_SLOTS

func _can_purchase_item(item: ItemBase) -> bool:
	if _is_offer_item_purchased(item):
		AudioManager.play_sfx("menu_click")
		_set_status_message("Ten przedmiot zostal juz kupiony z tej oferty.", true)
		return false

	if gold < item.cost:
		AudioManager.play_sfx("menu_click")
		_set_status_message("Za mało złota na ten zakup.", true)
		return false

	if _is_backpack_expansion(item):
		_set_status_message("")
		return true

	if _get_current_build_count() >= _get_max_build_slots():
		AudioManager.play_sfx("menu_click")
		_set_status_message("Build jest pełny. Sprzedaj coś przed zakupem.", true)
		return false

	if item is WeaponBase and _get_current_weapon_count() >= _get_max_weapon_slots():
		AudioManager.play_sfx("menu_click")
		_set_status_message("Osiagnieto limit broni.", true)
		return false

	_set_status_message("")
	return true

func _save_weapon_to_pending(weapon: WeaponBase, gd) -> void:
	if not gd:
		return

	var all_weps = WeaponItems.get_all_weapons()
	for i in range(all_weps.size()):
		var candidate = all_weps[i]
		if candidate != null and _items_match(candidate, weapon):
			gd.pending_weapon_ids.append(i)
			break

func _find_matching_build_item(item: ItemBase) -> ItemBase:
	if not build_system:
		return null

	var build_items = build_system.get("items")
	if build_items is Array:
		for owned_item in build_items:
			if owned_item is ItemBase and _items_match(owned_item, item):
				return owned_item
	return null

func _remove_matching_item_from_array(items: Array, item: ItemBase) -> void:
	for i in range(items.size()):
		var owned_item = items[i]
		if owned_item is ItemBase and _items_match(owned_item, item):
			items.remove_at(i)
			return

func _items_match(left: ItemBase, right: ItemBase) -> bool:
	if left == null or right == null:
		return false
	return left.item_name == right.item_name and left.item_type == right.item_type

func _is_backpack_expansion(item: ItemBase) -> bool:
	return item != null and item.item_type == "backpack_upgrade"

func _apply_backpack_expansion(gd) -> bool:
	var new_limit := _get_max_build_slots() + 1
	if gd:
		if gd.has_method("add_max_item_slots_bonus"):
			new_limit = int(gd.add_max_item_slots_bonus(1))
		else:
			return false

	if build_system:
		if build_system.has_method("sync_max_item_slots_from_game_data"):
			build_system.sync_max_item_slots_from_game_data()
		else:
			build_system.set("max_item_slots", new_limit)

	return gd != null or build_system != null

func _get_item_key(item: ItemBase) -> String:
	if item == null:
		return ""
	return "%s|%s" % [item.item_type, item.item_name]

func _is_offer_item_purchased(item: ItemBase) -> bool:
	return _purchased_offer_item_keys.has(_get_item_key(item))

func _set_status_message(message: String, is_error: bool = false) -> void:
	_status_message = message
	_status_is_error = is_error

func _update_item_states() -> void:
	for child in items_container.get_children():
		if child.has_method("set_sold_out"):
			child.set_sold_out(_is_offer_item_purchased(child.item_data))
		if child.has_method("update_affordability"):
			child.update_affordability(gold)

func _update_ui() -> void:
	current_shop_tier = _get_shop_tier(current_wave_number)
	refresh_cost = BalanceData.get_reroll_cost(current_wave_number, current_shop_tier, rerolls_this_visit)
	gold_label.text = "ZŁOTO: %d" % gold
	if reroll_button:
		reroll_button.text = "Reroll (%dG)" % refresh_cost
	if weapon_count_label:
		var build_count = _get_current_build_count()
		var weapon_count = _get_current_weapon_count()
		weapon_count_label.text = "TIER %d   BUILD: %d / %d   BRONIE: %d / %d" % [
			current_shop_tier,
			build_count,
			_get_max_build_slots(),
			weapon_count,
			_get_max_weapon_slots()
		]
		if _status_message != "":
			weapon_count_label.text += "   |   " + _status_message
		if _status_is_error or build_count >= _get_max_build_slots():
			weapon_count_label.modulate = Color(1, 0.4, 0.4)
		else:
			weapon_count_label.modulate = Color(0.7, 0.8, 1.0)

	if inventory_button:
		var count = _get_current_build_count()
		if not showing_inventory:
			inventory_button.text = "Moje EQ (%d/%d)" % [count, _get_max_build_slots()]

func _on_close_pressed() -> void:
	AudioManager.play_sfx("menu_click")
	if get_parent() == get_tree().root:
		get_tree().change_scene_to_file("res://scenes/world/GameStartScreen.tscn")
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

func _sync_wave_from_gamedata() -> void:
	var gd = get_node_or_null("/root/GameData")
	if gd:
		current_wave_number = max(int(gd.current_wave) + 1, 1)
	current_shop_tier = _get_shop_tier(current_wave_number)

func _get_shop_tier(wave_number: int) -> int:
	if item_manager and item_manager.has_method("get_shop_tier"):
		return item_manager.get_shop_tier(wave_number)
	if wave_number < 5:
		return 1
	return clampi(2 + int((wave_number - 5) / 5), 1, 5)
