extends ItemBase
class_name WeaponBase
## Broń dziedziczy po ItemBase (item_name, item_type, description, icon, rarity, cost, stats, etc.)
## Pola specyficzne dla broni:

@export var damage: float = 10.0
@export var attack_speed: float = 2.0  # cooldown w sekundach
@export var weapon_range: float = 100.0
@export var is_old_variant: bool = false  # dla "old" prefix

## Zwraca nazwę broni z odpowiednim prefixem
func get_display_name() -> String:
	if is_old_variant:
		return "Stary " + item_name
	return item_name
