extends Node
## Zarządza dostępnością i tworzeniem itemów w sklepie.

signal item_pool_updated

const RARITY_ORDER: Array[String] = ["common", "rare", "epic", "legendary"]
const BACKPACK_EXPANSION_CHANCE := 0.18
const BACKPACK_EXPANSION_MIN_WAVE := 3

var all_items: Array[ItemBase] = []
var shop_items: Array[ItemBase] = []
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	_initialize_all_items()

func _initialize_all_items() -> void:
	all_items.clear()

	var fallback_icon = preload("res://Assets/sprites/icon.svg")

	var candidate_items: Array[ItemBase] = [
		MotorolaItems.CrossPatchItem.new(),
		MotorolaItems.PSTAItem.new(),
		MotorolaItems.RadioAPXItem.new(),
		MotorolaItems.CommandCentralItem.new(),
		MotorolaItems.BodyCameraItem.new(),
		MotorolaItems.SolutionHubItem.new(),
		MotorolaItems.RaveItem.new(),
		MotorolaItems.LPRIItem.new(),
		MotorolaItems.PremierOneItem.new(),
		MotorolaItems.VB400Item.new(),
		MotorolaItems.FuntionItem.new(),
		MotorolaItems.TacticalVestItem.new(),
	]

	for weapon in WeaponItems.get_all_weapons():
		candidate_items.append(weapon)

	for item in candidate_items:
		if item.icon == null:
			item.icon = fallback_icon
		all_items.append(item)

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
	if all_items.is_empty():
		_initialize_all_items()
	shop_items.clear()
	var shop_tier := get_shop_tier(wave_number)
	var backpack_slot := -1
	if count > 0 and wave_number >= BACKPACK_EXPANSION_MIN_WAVE and rng.randf() < BACKPACK_EXPANSION_CHANCE:
		backpack_slot = rng.randi_range(0, count - 1)

	for i in range(count):
		if i == backpack_slot:
			shop_items.append(MotorolaItems.BackpackExpansionItem.new())
		else:
			shop_items.append(_get_shop_roll(shop_tier))

	item_pool_updated.emit()
	return shop_items

func get_shop_tier(wave_number: int) -> int:
	if wave_number < 5:
		return 1
	return clampi(2 + int((wave_number - 5) / 5), 1, 5)

func get_shop_tier_label(wave_number: int) -> String:
	return "TIER %d" % get_shop_tier(wave_number)

func get_items_by_type(item_type: String) -> Array[ItemBase]:
	return all_items.filter(func(item: ItemBase): return item.item_type == item_type)

func get_items_by_rarity(rarity: String) -> Array[ItemBase]:
	return all_items.filter(func(item: ItemBase): return item.rarity == rarity)

func create_item(item_name: String) -> ItemBase:
	for item: ItemBase in all_items:
		if item.item_name == item_name:
			return item.duplicate()

	return null

func _get_shop_roll(shop_tier: int) -> ItemBase:
	var rarity := _roll_rarity_for_tier(shop_tier)
	var available_items := _get_available_shop_items(shop_tier, rarity)
	var fallback_attempts := 0

	while available_items.is_empty() and fallback_attempts < RARITY_ORDER.size():
		var rarity_index: int = maxi(RARITY_ORDER.find(rarity) - 1, 0)
		rarity = RARITY_ORDER[rarity_index]
		available_items = _get_available_shop_items(shop_tier, rarity)
		fallback_attempts += 1

	if available_items.is_empty():
		available_items = _get_available_shop_items(shop_tier, "common")

	if available_items.is_empty():
		return (all_items.pick_random() as ItemBase).duplicate()

	return (available_items.pick_random() as ItemBase).duplicate()

func _get_available_shop_items(shop_tier: int, rarity: String) -> Array[ItemBase]:
	return all_items.filter(func(item: ItemBase):
		if item.rarity != rarity:
			return false
		if item is WeaponBase:
			return (item as WeaponBase).min_shop_tier <= shop_tier
		return _passive_available_in_tier(item, shop_tier)
	)

func _passive_available_in_tier(item: ItemBase, shop_tier: int) -> bool:
	match item.rarity:
		"common":
			return true
		"rare":
			return shop_tier >= 2
		"epic":
			return shop_tier >= 2
		"legendary":
			return shop_tier >= 4
		_:
			return true

func _roll_rarity_for_tier(shop_tier: int) -> String:
	var weights := _get_rarity_weights(shop_tier)
	var total := 0.0
	for rarity in weights:
		total += float(weights[rarity])

	var roll := rng.randf() * total
	var cursor := 0.0
	for rarity in RARITY_ORDER:
		cursor += float(weights.get(rarity, 0.0))
		if roll <= cursor:
			return rarity
	return "common"

func _get_rarity_weights(shop_tier: int) -> Dictionary:
	match shop_tier:
		1:
			return {"common": 100.0, "rare": 0.0, "epic": 0.0, "legendary": 0.0}
		2:
			return {"common": 62.0, "rare": 30.0, "epic": 8.0, "legendary": 0.0}
		3:
			return {"common": 42.0, "rare": 38.0, "epic": 18.0, "legendary": 2.0}
		4:
			return {"common": 22.0, "rare": 38.0, "epic": 32.0, "legendary": 8.0}
		_:
			return {"common": 10.0, "rare": 35.0, "epic": 40.0, "legendary": 15.0}

func _is_rarity_at_least(item_rarity: String, min_rarity: String) -> bool:
	var item_index: int = RARITY_ORDER.find(item_rarity)
	var min_index: int = RARITY_ORDER.find(min_rarity)

	return item_index >= min_index
