extends Control
## System sklepu Motorola - zakup itemów i ulepszeń

signal item_purchased(item: ItemBase)
signal shop_closed

@export var starting_gold: int = 100

var current_gold: int
var shop_items: Array[ItemBase] = []
var build_system: Node
var item_manager: Node

var gold_label: Label
var items_container: VBoxContainer
var close_button: Button
var item_scene: PackedScene = preload("res://Scenes/ShopItem.tscn")

func _ready() -> void:
	# Znajdź węzły bezpiecznie
	if has_node("GoldLabel"):
		gold_label = $GoldLabel
	if has_node("ItemsContainer"):
		items_container = $ItemsContainer
	if has_node("CloseButton"):
		close_button = $CloseButton
		close_button.pressed.connect(_on_close_pressed)

	current_gold = starting_gold

func open_shop(available_items: Array[ItemBase], player_build: Node, manager: Node) -> void:
	shop_items = available_items
	build_system = player_build
	item_manager = manager

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

	for item: ItemBase in shop_items:
		var item_ui: Panel = item_scene.instantiate()
		item_ui.setup_item(item, current_gold)
		item_ui.item_clicked.connect(_on_item_clicked)
		items_container.add_child(item_ui)

func _on_item_clicked(item: ItemBase) -> void:
	if current_gold >= item.cost and build_system:
		current_gold -= item.cost
		build_system.add_item(item)
		item_purchased.emit(item)
		_update_gold_label()
		_update_item_states()

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

func add_gold(amount: int) -> void:
	current_gold += amount
	_update_gold_label()

func get_gold() -> int:
	return current_gold