extends Control
## Ekran sklepu jako osobna scena – 4 itemy, gold, przycisk POWRÓT

@onready var gold_label: Label = $VBoxContainer/GoldLabel
@onready var items_container: VBoxContainer = $VBoxContainer/ItemsContainer
@onready var back_button: Button = $VBoxContainer/BackButton

var player_gold: int = 100
var shop_items: Array = []

func _ready() -> void:
	# Wczytaj gold z GameData
	var gd := get_node_or_null("/root/GameData")
	if gd:
		player_gold = gd.gold

	_setup_items()
	_update_gold_label()
	back_button.pressed.connect(_on_back_pressed)

func _setup_items() -> void:
	shop_items = _create_placeholder_items()
	for item in shop_items:
		_create_item_button(item)

func _create_placeholder_items() -> Array:
	var items: Array = []

	var item1 := ItemBase.new()
	item1.item_name = "Procesor Mocy"
	item1.item_type = "damage"
	item1.description = "Zwiększa obrażenia o 25%"
	item1.cost = 50
	item1.stats = {"damage": 0.25}
	items.append(item1)

	var item2 := ItemBase.new()
	item2.item_name = "Szybka Pamięć RAM"
	item2.item_type = "attack_speed"
	item2.description = "Zwiększa prędkość ataku o 20%"
	item2.cost = 40
	item2.stats = {"attack_speed": 0.20}
	items.append(item2)

	var item3 := ItemBase.new()
	item3.item_name = "Dysk SSD"
	item3.item_type = "move_speed"
	item3.description = "Zwiększa prędkość ruchu o 30%"
	item3.cost = 35
	item3.stats = {"move_speed": 0.30}
	items.append(item3)

	var item4 := ItemBase.new()
	item4.item_name = "Firewall"
	item4.item_type = "max_health"
	item4.description = "Zwiększa maksymalne HP o 50%"
	item4.cost = 60
	item4.stats = {"max_health": 0.50}
	items.append(item4)

	return items

func _create_item_button(item: ItemBase) -> void:
	var btn := Button.new()
	btn.text = "%s – %d GOLD" % [item.item_name, item.cost]
	btn.custom_minimum_size = Vector2(0, 50)
	btn.pressed.connect(_on_item_bought.bind(item))
	items_container.add_child(btn)

func _on_item_bought(item: ItemBase) -> void:
	if player_gold < item.cost:
		return

	player_gold -= item.cost
	_update_gold_label()

	# Zapisz do GameData
	var gd := get_node_or_null("/root/GameData")
	if gd:
		gd.gold = player_gold
		if gd.has_method("add_inventory_item"):
			gd.add_inventory_item(item)

	# Wyłącz przycisk po zakupie (jednorazowy zakup)
	var sender := get_viewport().gui_get_focus_owner()
	if sender is Button:
		sender.disabled = true
		sender.text = "%s – KUPIONE" % item.item_name

func _update_gold_label() -> void:
	gold_label.text = "GOLD: %d" % player_gold

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/GameStartScreen.tscn")
