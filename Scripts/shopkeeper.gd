extends CharacterBody2D

@export var npc_name: String = "Automat ze Sprzedażą"
@export var shop_scene_path: String = "res://scenes/Shop.tscn"

var shop_open: bool = false

func _ready() -> void:
	$AnimatedSprite2D.play("MashineAnimation")
	$InteractArea.add_to_group("Interactable")

func interact() -> void:
	if shop_open:
		return
	_open_shop()

func _open_shop() -> void:
	shop_open = true
	var shop_scene := load(shop_scene_path) as PackedScene
	if not shop_scene:
		push_warning("[Shopkeeper] Nie można załadować sceny sklepu")
		return

	var shop: Control = shop_scene.instantiate()
	get_tree().current_scene.add_child(shop)

	if shop.has_signal("shop_closed"):
		shop.shop_closed.connect(_on_shop_closed)

	if shop.has_signal("refresh_requested"):
		shop.refresh_requested.connect(_on_shop_refresh.bind(shop))

	if shop.has_method("configure_shop"):
		var items := _create_placeholder_items()
		shop.configure_shop(items, _get_player_gold())
	elif shop.has_method("open_shop"):
		shop.open_shop([], null, null)

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

func _on_shop_closed() -> void:
	shop_open = false

func _get_player_gold() -> int:
	var gd := get_node_or_null("/root/GameData")
	if gd:
		return gd.gold
	return 100

func _on_shop_refresh(shop: Control) -> void:
	if shop.has_method("configure_shop"):
		var items := _create_placeholder_items()
		shop.configure_shop(items, _get_player_gold())
