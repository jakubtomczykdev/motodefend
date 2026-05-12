extends Control
const WeaponItemsClass := preload("res://Scripts/items/weapon_items.gd")
const ShopItemScene := preload("res://scenes/ShopItem.tscn")
## Ekran sklepu jako osobna scena – 4 itemy, gold, przycisk POWRÓT

@onready var gold_label: Label = $VBoxContainer/GoldLabel
@onready var items_container: VBoxContainer = $VBoxContainer/ScrollContainer/ItemsContainer
@onready var back_button: Button = $VBoxContainer/BackButton

var player_gold: int = 100

func _ready() -> void:
	var gd := get_node_or_null("/root/GameData")
	if gd:
		player_gold = gd.gold

	_setup_items()
	_update_gold_label()
	back_button.pressed.connect(_on_back_pressed)

func _setup_items() -> void:
	var weapons := WeaponItemsClass.get_all_weapons()
	for weapon in weapons:
		var item_instance := ShopItemScene.instantiate()
		setup_weapon_item(item_instance, weapon)
		items_container.add_child(item_instance)

func setup_weapon_item(item_node: Node, weapon: WeaponBase) -> void:
	if item_node.has_node("HBoxContainer/IconTexture"):
		var icon_tex: TextureRect = item_node.get_node("HBoxContainer/IconTexture")
		if weapon.icon:
			icon_tex.texture = weapon.icon
	if item_node.has_node("HBoxContainer/VBoxContainer/NameLabel"):
		var name_lbl: Label = item_node.get_node("HBoxContainer/VBoxContainer/NameLabel")
		name_lbl.text = weapon.get_display_name()
	if item_node.has_node("HBoxContainer/VBoxContainer/DescriptionLabel"):
		var desc_lbl: Label = item_node.get_node("HBoxContainer/VBoxContainer/DescriptionLabel")
		desc_lbl.text = weapon.description
	if item_node.has_node("HBoxContainer/VBoxContainer/HBoxContainer2/CostLabel"):
		var cost_lbl: Label = item_node.get_node("HBoxContainer/VBoxContainer/HBoxContainer2/CostLabel")
		cost_lbl.text = "Koszt: %d G" % weapon.cost
	if item_node.has_node("HBoxContainer/VBoxContainer/HBoxContainer2/RarityLabel"):
		var rarity_lbl: Label = item_node.get_node("HBoxContainer/VBoxContainer/HBoxContainer2/RarityLabel")
		rarity_lbl.text = weapon.rarity.capitalize()
		rarity_lbl.modulate = weapon.get_rarity_color()
	if item_node.has_node("HBoxContainer/BuyButton"):
		var buy_btn: Button = item_node.get_node("HBoxContainer/BuyButton")
		buy_btn.pressed.connect(_on_weapon_bought.bind(weapon, buy_btn))

func _on_weapon_bought(weapon: WeaponBase, button: Button) -> void:
	if player_gold < weapon.cost:
		return

	player_gold -= weapon.cost
	_update_gold_label()

	var gd := get_node_or_null("/root/GameData")
	if gd:
		gd.gold = player_gold
		if not gd.has("pending_weapons"):
			gd.pending_weapons = []
		gd.pending_weapons.append(weapon.duplicate())

	button.disabled = true
	button.text = "KUPIONE"

func _update_gold_label() -> void:
	gold_label.text = "GOLD: %d" % player_gold

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/GameStartScreen.tscn")
