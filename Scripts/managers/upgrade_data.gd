# Refactored path
extends Node
## Definicje ulepszeń dostępnych przy awansie poziomu

class Upgrade:
	var id: String
	var name: String
	var description: String
	var stat_name: String
	var value: float
	var icon_path: String
	
	func _init(_id: String, _name: String, _desc: String, _stat: String, _val: float, _icon: String = ""):
		id = _id
		name = _name
		description = _desc
		stat_name = _stat
		value = _val
		icon_path = _icon

static func get_available_upgrades() -> Array[Upgrade]:
	return [
		Upgrade.new("hp_plus", "Zwiększenie HP", "Dodaje +20 do maksymalnego poziomu życia.", "max_health", 20.0),
		Upgrade.new("dmg_plus", "Większe Obrażenia", "Zwiększa zadawane obrażenia o 15%.", "damage", 0.15),
		Upgrade.new("spd_plus", "Szybszy Ruch", "Zwiększa szybkość poruszania się o 10%.", "move_speed", 0.10),
		Upgrade.new("atk_spd_plus", "Szybszy Atak", "Zwiększa częstotliwość ataków o 15%.", "attack_speed", 0.15),
		Upgrade.new("armor_plus", "Wzmocnienie Pancerza", "Dodaje +5 do pancerza.", "armor", 5.0),
		Upgrade.new("regen_plus", "Naprawa Systemu", "Zwiększa regenerację HP o 0.5/s.", "hp_regen", 0.5),
		Upgrade.new("crit_plus", "Algorytm Krytyczny", "Zwiększa szansę na trafienie krytyczne o 5%.", "crit_chance", 0.05),
		Upgrade.new("range_plus", "Zasięg Anten", "Zwiększa zasięg ataku o 20%.", "attack_range", 0.20)
	]

static func get_random_upgrades(count: int = 3) -> Array[Upgrade]:
	var all = get_available_upgrades()
	all.shuffle()
	return all.slice(0, count)
