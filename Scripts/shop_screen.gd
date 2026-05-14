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
@onready var items_container: HFlowContainer = $MainArea/ItemsContainer
@onready var preview_icon: TextureRect = $MainArea/PreviewPanel/PreviewVBox/PreviewIcon
@onready var preview_name: Label = $MainArea/PreviewPanel/PreviewVBox/PreviewName
@onready var preview_rarity: Label = $MainArea/PreviewPanel/PreviewVBox/PreviewRarity
@onready var preview_description: Label = $MainArea/PreviewPanel/PreviewVBox/PreviewDescription
@onready var preview_cost: Label = $MainArea/PreviewPanel/PreviewVBox/PreviewCost
@onready var back_button: Button = $BottomBar/HBox/BackButton
@onready var reroll_button: Button = $BottomBar/HBox/RerollButton

var item_scene: PackedScene = preload("res://scenes/ShopItem.tscn")
var refresh_cost: int = 25

func _ready() -> void:
	back_button.pressed.connect(_on_close_pressed)
	reroll_button.pressed.connect(_on_refresh_pressed)
	_update_gold_label()
	# Auto-populate with default weapons when shop loaded standalone
	await get_tree().process_frame
	if shop_items.is_empty():
		var weapons = WeaponItems.get_all_weapons()
		if not weapons.is_empty():
			weapons.shuffle()
			var count = mini(4, weapons.size())
			for i in range(count):
				shop_items.append(weapons[i])
			_populate_items()

func open_shop(available_items: Array[ItemBase], player_build: Node, manager: Node) -> void:
	shop_items = available_items
	build_system = player_build
	item_manager = manager

	_clear_items()
	_populate_items()
	_update_gold_label()

	visible = true

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

func _update_preview(item: ItemBase) -> void:
	preview_name.text = item.item_name
	preview_rarity.text = "Rzadkość: " + item.rarity.capitalize()
	preview_description.text = item.description
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
		gold -= item.cost
		item_purchased.emit(item)
		_update_gold_label()
		_update_item_states()

		if build_system:
			build_system.add_item(item)
		else:
			var gd = get_node_or_null("/root/GameData")
			if gd:
				gd.add_inventory_item(item)
				# Also register weapon for combat restoration via pending_weapon_ids
				if item is WeaponBase:
					var all_weps = WeaponItems.get_all_weapons()
					for i in range(all_weps.size()):
						if all_weps[i].item_name == item.item_name and all_weps[i].item_type == item.item_type:
							if not gd.pending_weapon_ids.has(i):
								gd.pending_weapon_ids.append(i)
							break

func _on_refresh_pressed() -> void:
	if gold >= refresh_cost:
		gold -= refresh_cost
		_update_gold_label()
		refresh_requested.emit()
		if item_manager and item_manager.has_method("get_shop_items") and build_system:
			var new_items = item_manager.get_shop_items(4, 1)
			open_shop(new_items, build_system, item_manager)
		else:
			# Standalone fallback - shuffle and repopulate
			_clear_items()
			var weapons = WeaponItems.get_all_weapons()
			weapons.shuffle()
			shop_items.clear()
			var count = mini(4, weapons.size())
			for i in range(count):
				shop_items.append(weapons[i])
			_populate_items()

func _update_item_states() -> void:
	for child in items_container.get_children():
		if child.has_method("update_affordability"):
			child.update_affordability(gold)

func _update_gold_label() -> void:
	gold_label.text = "ZLOTO: %d" % gold

func _on_close_pressed() -> void:
	if get_parent() == get_tree().root:
		# Standalone mode - return to hub
		get_tree().change_scene_to_file("res://scenes/GameStartScreen.tscn")
	else:
		# Child mode (inside MainGame) - just hide
		visible = false
		shop_closed.emit()

func add_gold(amount: int) -> void:
	gold += amount
	_update_gold_label()

func set_gold(amount: int) -> void:
	gold = amount
	_update_gold_label()

func get_gold() -> int:
	return gold
