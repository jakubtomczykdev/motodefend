extends Resource
class_name WeaponBase

@export var weapon_name: String = "Nowa Broń"
@export var weapon_type: String = ""  # shockwave, drone, blaster, sword
@export var description: String = ""
@export var icon: CompressedTexture2D
@export var cost: int = 0
@export var rarity: String = "common"  # common, rare, epic, legendary
@export var damage: float = 10.0
@export var attack_speed: float = 2.0  # cooldown w sekundach
@export var range: float = 100.0
@export var stats: Dictionary = {}  # dodatkowe modyfikatory (jak w ItemBase)
@export var is_old_variant: bool = false  # dla "old" prefix

func get_rarity_color() -> Color:
	match rarity.to_lower():
		"common":
			return Color(0.7, 0.7, 0.7) # Gray
		"rare":
			return Color(0.2, 0.5, 1.0) # Blue
		"epic":
			return Color(0.306, 0.804, 0.769) # Motorola Cyan
		"legendary":
			return Color(0.4, 0.65, 0.85) # Motorola Blue (lighter)
		_:
			return Color(1.0, 1.0, 1.0) # White default

## Zwraca nazwę broni z odpowiednim prefixem
func get_display_name() -> String:
	if is_old_variant:
		return "Stary " + weapon_name
	return weapon_name
