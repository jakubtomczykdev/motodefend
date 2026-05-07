extends Node
## Zarządza dostępnością i tworzeniem itemów

signal item_pool_updated

var all_items: Array[ItemBase] = []
var shop_items: Array[ItemBase] = []
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	_initialize_all_items()

func _initialize_all_items() -> void:
	all_items.clear()

	# Motorola items
	all_items.append(CrossPatchItem.new())
	all_items.append(PSTAItem.new())
	all_items.append(RadioAPXItem.new())
	all_items.append(CommandCentralItem.new())
	all_items.append(BodyCameraItem.new())
	all_items.append(SolutionHubItem.new())
	all_items.append(RaveItem.new())
	all_items.append(LPRIItem.new())
	all_items.append(PremierOneItem.new())
	all_items.append(VB400Item.new())
	all_items.append(FuntionItem.new())

func get_random_item(min_rarity: String = "common") -> ItemBase:
	var available_items: Array[ItemBase] = all_items.filter(func(item: ItemBase): return _is_rarity_at_least(item.rarity, min_rarity))

	if available_items.is_empty():
		return all_items.pick_random() as ItemBase

	return (available_items.pick_random() as ItemBase).duplicate()

func get_random_items(count: int, min_rarity: String = "common") -> Array[ItemBase]:
	var items: Array[ItemBase] = []

	for i in range(count):
		items.append(get_random_item(min_rarity))

	return items

func get_shop_items(count: int = 3, wave_number: int = 1) -> Array[ItemBase]:
	shop_items.clear()

	# Zwiększ szansę na lepsze itemy z kolejnymi falami
	var min_rarity: String = "common"

	if wave_number >= 5:
		if rng.randf() < 0.3:
			min_rarity = "rare"
	if wave_number >= 10:
		if rng.randf() < 0.5:
			min_rarity = "rare"
		elif rng.randf() < 0.2:
			min_rarity = "epic"
	if wave_number >= 15:
		if rng.randf() < 0.3:
			min_rarity = "epic"
		elif rng.randf() < 0.1:
			min_rarity = "legendary"

	for i in range(count):
		shop_items.append(get_random_item(min_rarity))

	item_pool_updated.emit()
	return shop_items

func get_items_by_type(item_type: String) -> Array[ItemBase]:
	return all_items.filter(func(item: ItemBase): return item.item_type == item_type)

func get_items_by_rarity(rarity: String) -> Array[ItemBase]:
	return all_items.filter(func(item: ItemBase): return item.rarity == rarity)

func _is_rarity_at_least(item_rarity: String, min_rarity: String) -> bool:
	var rarity_order: Array[String] = ["common", "rare", "epic", "legendary"]
	var item_index: int = rarity_order.find(item_rarity)
	var min_index: int = rarity_order.find(min_rarity)

	return item_index >= min_index

func create_item(item_name: String) -> ItemBase:
	for item: ItemBase in all_items:
		if item.item_name == item_name:
			return item.duplicate()

	return null