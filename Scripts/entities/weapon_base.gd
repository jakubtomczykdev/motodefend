# Refactored path
extends ItemBase
class_name WeaponBase
## Broń dziedziczy po ItemBase (item_name, item_type, description, icon, rarity, cost, stats, etc.)
## Pola specyficzne dla broni:

@export var damage: float = 10.0
@export var attack_speed: float = 2.0  # cooldown w sekundach
@export var weapon_range: float = 100.0
@export var is_old_variant: bool = false  # dla "old" prefix
@export var weapon_level: int = 1
@export var min_shop_tier: int = 1
@export var base_weapon_id: String = ""

## Zwraca nazwę broni z odpowiednim prefixem
func get_display_name() -> String:
	if is_old_variant:
		return "Stary " + item_name
	return item_name

func get_level_suffix() -> String:
	match weapon_level:
		1:
			return "I"
		2:
			return "II"
		3:
			return "III"
		4:
			return "IV"
		_:
			return str(weapon_level)
