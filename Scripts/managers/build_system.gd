extends Node
## System buildów - zarządza statystykami i itemami gracza

signal stat_changed(stat_name: String, new_value: float)
signal item_added(item: ItemBase)
signal item_removed(item: ItemBase)

@export var max_item_slots: int = BalanceData.MAX_BUILD_SLOTS

var player_stats: Dictionary = {
	"damage": 1.0,
	"attack_speed": 1.0,
	"move_speed": 1.0,
	"attack_range": 1.0,
	"max_health": 100.0,
	"armor": 0.0,
	"hp_regen": 0.0,
	"crit_chance": 0.0,
	"crit_damage": 1.5,
	"pierce": 0,
	"projectile_count": 1,
	"projectile_speed": 1.0,
	"dodge_chance": 0.0,
	"cooldown_reduction": 0.0,
	"boss_damage_bonus": 0.0
}

var items: Array[ItemBase] = []
var base_stats: Dictionary = player_stats.duplicate()

func _ready() -> void:
	_initialize_base_stats()
	sync_max_item_slots_from_game_data()

func _initialize_base_stats() -> void:
	base_stats["damage"] = BalanceData.BASE_PLAYER_DAMAGE
	base_stats["attack_speed"] = BalanceData.BASE_PLAYER_ATTACK_SPEED
	base_stats["move_speed"] = 1.0 # Multiplier
	base_stats["attack_range"] = 1.0 # Multiplier
	base_stats["max_health"] = float(BalanceData.BASE_PLAYER_HP)
	base_stats["armor"] = float(BalanceData.BASE_PLAYER_ARMOR)
	base_stats["hp_regen"] = BalanceData.BASE_PLAYER_REGEN
	
	player_stats = base_stats.duplicate()

func sync_max_item_slots_from_game_data() -> void:
	var gd = get_node_or_null("/root/GameData")
	if gd and gd.has_method("get_max_item_slots"):
		max_item_slots = int(gd.get_max_item_slots())
	else:
		max_item_slots = BalanceData.MAX_BUILD_SLOTS

func add_item(item: ItemBase) -> bool:
	items.append(item)
	item.apply_effects(self)
	item_added.emit(item)
	recalculate_stats()

	return true

func remove_item(item: ItemBase) -> bool:
	if not items.has(item):
		return false

	item.remove_effects(self)
	items.erase(item)
	item_removed.emit(item)
	recalculate_stats()

	return true

func has_item_type(item_type: String) -> int:
	var count := 0
	for item in items:
		if item.item_type == item_type:
			count += 1
	return count

func get_stat(stat_name: String) -> float:
	return player_stats.get(stat_name, 0.0)

func set_base_stat(stat_name: String, value: float) -> void:
	base_stats[stat_name] = value
	recalculate_stats()

func modify_stat(stat_name: String, multiplier: float) -> void:
	player_stats[stat_name] *= multiplier
	stat_changed.emit(stat_name, player_stats[stat_name])

func add_stat(stat_name: String, value: float) -> void:
	player_stats[stat_name] += value
	stat_changed.emit(stat_name, player_stats[stat_name])

func apply_level_upgrade(stat_name: String, value: float) -> void:
	var gd = get_node_or_null("/root/GameData")
	if gd and gd.has_method("add_level_upgrade"):
		gd.add_level_upgrade(stat_name, value)
	recalculate_stats()

func recalculate_stats() -> void:
	# Reset do bazowych wartości
	player_stats = base_stats.duplicate()

	# Zastosuj bonusy z poziomu
	var gd = get_node_or_null("/root/GameData")
	if gd:
		var level_factor = gd.current_level - 1
		player_stats["max_health"] += level_factor * BalanceData.LEVEL_HP_BONUS
		player_stats["damage"] += level_factor * BalanceData.LEVEL_DAMAGE_BONUS
		player_stats["move_speed"] += level_factor * BalanceData.LEVEL_SPEED_BONUS
		player_stats["armor"] += level_factor * BalanceData.LEVEL_ARMOR_BONUS

		if "level_upgrade_flat_bonuses" in gd:
			for stat_name: String in gd.level_upgrade_flat_bonuses:
				player_stats[stat_name] = float(player_stats.get(stat_name, 0.0)) + float(gd.level_upgrade_flat_bonuses[stat_name])

		if "level_upgrade_multiplier_bonuses" in gd:
			for stat_name: String in gd.level_upgrade_multiplier_bonuses:
				player_stats[stat_name] = float(player_stats.get(stat_name, 0.0)) * float(gd.level_upgrade_multiplier_bonuses[stat_name])

	# Zastosuj efekty wszystkich itemów
	for item: ItemBase in items:
		item.apply_effects(self)

	# Emituj sygnały dla wszystkich statystyk
	for stat_name: String in player_stats:
		stat_changed.emit(stat_name, player_stats[stat_name])

func clear_build() -> void:
	for item: ItemBase in items.duplicate():
		remove_item(item)

	recalculate_stats()
