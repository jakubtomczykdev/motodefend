extends Control
## System sklepu Motorola - zaktualizowany pod design "Cyber-Kinetic"
## UWAGA: Ten plik zastępuje stary shop_system.gd aby zachować kompatybilność scen.

signal item_purchased(item: ItemBase)
signal shop_closed
signal refresh_requested

@export var starting_gold: int = 100

var current_gold: int
var shop_items: Array = []
var build_system: Node
var item_manager: Node

@onready var gold_label: Label = get_node_or_null("TopBar/GoldLabel")
@onready var items_container: HFlowContainer = get_node_or_null("MainArea/ItemsContainer")
@onready var preview_icon: TextureRect = get_node_or_null("MainArea/PreviewPanel/PreviewVBox/PreviewIcon")
@onready var preview_name: Label = get_node_or_null("MainArea/PreviewPanel/PreviewVBox/PreviewName")
@onready var preview_rarity: Label = get_node_or_null("MainArea/PreviewPanel/PreviewVBox/PreviewRarity")
@onready var preview_description: Label = get_node_or_null("MainArea/PreviewPanel/PreviewVBox/PreviewDescription")
@onready var preview_cost: Label = get_node_or_null("MainArea/PreviewPanel/PreviewVBox/PreviewCost")
@onready var back_button: Button = get_node_or_null("BottomBar/HBox/BackButton")
@onready var reroll_button: Button = get_node_or_null("BottomBar/HBox/RerollButton")

var item_scene: PackedScene = preload("res://scenes/ShopItem.tscn")
var refresh_cost: int = 25

func _ready() -> void:
	if back_button: back_button.pressed.connect(_on_close_pressed)
	if reroll_button: reroll_button.pressed.connect(_on_refresh_pressed)
	
	current_gold = starting_gold
	_update_gold_label()

func open_shop(available_items: Array[ItemBase], player_build: Node, manager: Node) -> void:
	shop_items = available_items
	build_system = player_build
	item_manager = manager

	_clear_items()
	_populate_items()
	_update_gold_label()

	visible = true

func _clear_items() -> void:
	if items_container:
		for child in items_container.get_children():
			child.queue_free()

func _populate_items() -> void:
	if not items_container: return
	
	for item in shop_items:
		var item_ui = item_scene.instantiate()
		items_container.add_child(item_ui)
		item_ui.setup_item(item, current_gold)
		item_ui.item_clicked.connect(_on_item_clicked)
		item_ui.mouse_entered.connect(_update_preview.bind(item))

func _update_preview(item: ItemBase) -> void:
	if preview_name: preview_name.text = item.item_name.to_upper()
	if preview_rarity: preview_rarity.text = "LEVEL_ID: " + item.rarity.to_upper()
	if preview_description: preview_description.text = item.description
	if preview_cost: preview_cost.text = "REQ_CREDITS: " + str(item.cost)
	
	if item.icon and preview_icon:
		preview_icon.texture = item.icon
	
	# Colorize rarity in preview
	if preview_rarity:
		var color := Color(1, 1, 1)
		match item.rarity.to_lower():
			"common": color = Color(0.7, 0.7, 0.7)
			"uncommon": color = Color(0.3, 0.8, 0.5)
			"rare": color = Color(0, 0.6, 1.0)
			"epic": color = Color(0.6, 0.2, 0.9)
			"legendary": color = Color(1.0, 0.8, 0.0)
		preview_rarity.modulate = color

func _on_item_clicked(item: ItemBase) -> void:
	if current_gold >= item.cost:
		current_gold -= item.cost
		item_purchased.emit(item)
		_update_gold_label()
		_update_item_states()

		if build_system:
			build_system.add_item(item)
		else:
			var gd = get_node_or_null("/root/GameData")
			if gd: gd.add_inventory_item(item)

func _on_refresh_pressed() -> void:
	if current_gold >= refresh_cost:
		current_gold -= refresh_cost
		_update_gold_label()
		refresh_requested.emit()
		
		if item_manager and build_system:
			var new_items = item_manager.get_shop_items(4, 1)
			open_shop(new_items, build_system, item_manager)

func _update_item_states() -> void:
	if items_container:
		for child in items_container.get_children():
			if child.has_method("update_affordability"):
				child.update_affordability(current_gold)

func _update_gold_label() -> void:
	if gold_label:
		gold_label.text = "CREDITS: " + str(current_gold)

func _on_close_pressed() -> void:
	visible = false
	shop_closed.emit()

func add_gold(amount: int) -> void:
	current_gold += amount
	_update_gold_label()

func get_gold() -> int:
	return current_gold
