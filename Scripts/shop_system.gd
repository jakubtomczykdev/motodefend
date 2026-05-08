extends Control
## System sklepu Motorola - zakup itemów i ulepszeń

signal item_purchased(item: ItemBase)
signal shop_closed
signal refresh_requested

@export var starting_gold: int = 100

var current_gold: int
var shop_items: Array = []
var build_system: Node
var item_manager: Node

var gold_label: Label
var items_container: VBoxContainer
var close_button: Button
var shopkeeper_image: TextureRect
var item_scene: PackedScene = preload("res://scenes/ShopItem.tscn")

var refresh_button: Button
var refresh_cost: int = 10
var refresh_cost_increment: int = 5

func _ready() -> void:
	if has_node("VBoxContainer/GoldLabel"):
		gold_label = $VBoxContainer/GoldLabel
	if has_node("VBoxContainer/ScrollContainer/ItemsContainer"):
		items_container = $VBoxContainer/ScrollContainer/ItemsContainer
	if has_node("VBoxContainer/CloseButton"):
		close_button = $VBoxContainer/CloseButton
		close_button.pressed.connect(_on_close_pressed)
	if has_node("VBoxContainer/HeaderBox/ShopkeeperImage"):
		shopkeeper_image = $VBoxContainer/HeaderBox/ShopkeeperImage
		shopkeeper_image.texture = load("res://Assets/Characters/MotoMachineSelling.png")

	current_gold = starting_gold

func open_shop(available_items: Array[ItemBase], player_build: Node, manager: Node) -> void:
	shop_items = available_items
	build_system = player_build
	item_manager = manager

	_clear_items()
	_populate_items()
	_update_gold_label()

	visible = true

## Konfiguruje sklep w trybie standalone (hub) – używa GameData do persystencji
func configure_shop(items: Array, starting_gold: int) -> void:
	shop_items = items
	current_gold = starting_gold

	refresh_cost = 10
	_setup_refresh_button()
	_clear_items()
	_populate_items()
	_update_gold_label()
	visible = true

func close_shop() -> void:
	visible = false
	shop_closed.emit()

func _clear_items() -> void:
	if items_container:
		for child in items_container.get_children():
			child.queue_free()

func _populate_items() -> void:
	if not items_container:
		return

	for item in shop_items:
		var item_ui: Panel = item_scene.instantiate()
		item_ui.setup_item(item, current_gold)
		item_ui.item_clicked.connect(_on_item_clicked)
		items_container.add_child(item_ui)

func _refresh_display() -> void:
	if items_container:
		for child in items_container.get_children():
			child.queue_free()

	for item in shop_items:
		var item_ui := item_scene.instantiate()
		items_container.add_child(item_ui)
		if item_ui.has_method("setup_item"):
			item_ui.setup_item(item, current_gold)
		item_ui.item_clicked.connect(_on_item_purchased)

func _setup_refresh_button() -> void:
	if has_node("VBoxContainer/RefreshButton"):
		refresh_button = $VBoxContainer/RefreshButton
		refresh_button.pressed.connect(_on_refresh_pressed)
		_update_refresh_button_text()

func _on_refresh_pressed() -> void:
	if current_gold < refresh_cost:
		return
	current_gold -= refresh_cost
	refresh_cost += refresh_cost_increment
	_update_gold_label()
	_update_refresh_button_text()
	# Powiadom shopkeepera aby wygenerował nowe itemy
	refresh_requested.emit()
	_update_item_states()

func _update_refresh_button_text() -> void:
	if refresh_button:
		refresh_button.text = "ODŚWIEŻ (%d gold)" % refresh_cost

func _generate_random_items() -> Array:
	var items: Array = []
	var types := ["damage", "attack_speed", "move_speed", "max_health"]
	types.shuffle()

	for i in range(4):
		var item := ItemBase.new()
		item.item_name = "Ulepszenie " + str(i + 1)
		item.item_type = types[i]
		item.cost = 30 + randi() % 50
		items.append(item)

	return items

func _on_item_clicked(item: ItemBase) -> void:
	if current_gold >= item.cost:
		current_gold -= item.cost
		item_purchased.emit(item)
		_update_gold_label()
		_update_item_states()

		# W trybie standalone – zapisz do GameData
		if build_system:
			build_system.add_item(item)
		else:
			var gd := get_node_or_null("/root/GameData")
			if gd and gd.has_method("add_inventory_item"):
				gd.add_inventory_item(item)

func _on_item_purchased(item: ItemBase) -> void:
	if current_gold >= item.cost:
		current_gold -= item.cost
		_update_gold_label()
		item_purchased.emit(item)

func update_gold_display() -> void:
	if gold_label:
		gold_label.text = "ZŁOTO: %d" % current_gold

func _update_item_states() -> void:
	if items_container:
		for child: Node in items_container.get_children():
			if child.has_method("update_affordability"):
				child.call("update_affordability", current_gold)

func _update_gold_label() -> void:
	if gold_label:
		gold_label.text = "ZŁOTO: %d" % current_gold

func _on_close_pressed() -> void:
	close_shop()
	queue_free()

func add_gold(amount: int) -> void:
	current_gold += amount
	_update_gold_label()

func get_gold() -> int:
	return current_gold
