extends Control
## Ekran sklepu – osobna scena

var gold_label: Label
var items_container: VBoxContainer
var back_button: Button
var current_gold: int = 0

func _ready() -> void:
	gold_label = get_node_or_null("VBoxContainer/GoldLabel")
	items_container = get_node_or_null("VBoxContainer/ItemsContainer")
	back_button = get_node_or_null("VBoxContainer/BackButton")

	if back_button:
		back_button.pressed.connect(_on_back_pressed)

	var gd := get_node_or_null("/root/GameData")
	if gd:
		current_gold = gd.gold

	_update_gold_display()
	_create_placeholder_items()

func _update_gold_display() -> void:
	if gold_label:
		gold_label.text = "GOLD: %d" % current_gold

func _create_placeholder_items() -> void:
	var items := [
		{"name": "Procesor Mocy", "desc": "+25% obrażeń", "price": 50, "type": "damage"},
		{"name": "Szybka RAM", "desc": "+20% prędkości ataku", "price": 40, "type": "attack_speed"},
		{"name": "Dysk SSD", "desc": "+30% prędkości ruchu", "price": 35, "type": "move_speed"},
		{"name": "Firewall", "desc": "+50% max HP", "price": 60, "type": "max_health"},
	]

	for item_data in items:
		var btn := Button.new()
		btn.text = "%s - %d GOLD\n%s" % [item_data.name, item_data.price, item_data.desc]
		btn.custom_minimum_size = Vector2(0, 60)
		btn.pressed.connect(_on_item_bought.bind(item_data))
		if items_container:
			items_container.add_child(btn)

func _on_item_bought(item_data: Dictionary) -> void:
	if current_gold >= item_data.price:
		current_gold -= item_data.price
		_update_gold_display()
		var gd := get_node_or_null("/root/GameData")
		if gd:
			gd.gold = current_gold
		print("[Shop] Kupiono: %s za %d gold" % [item_data.name, item_data.price])
	else:
		print("[Shop] Za mało golda!")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/GameStartScreen.tscn")
