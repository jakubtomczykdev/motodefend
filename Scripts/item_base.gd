extends Resource
class_name ItemBase

@export var item_name: String = "Nowy Przedmiot"
@export var item_type: String = ""
@export var description: String = ""
@export var icon: Texture2D
@export var rarity: String = "common"
@export var cost: int = 0
@export var stats: Dictionary = {}
@export var synergies: Array = []

# Przykładowe statystyki, które przedmiot może modyfikować
@export var damage_bonus: float = 0.0
@export var speed_bonus: float = 0.0
@export var health_bonus: int = 0

func get_rarity_color() -> Color:
	match rarity.to_lower():
		"common":
			return Color(0.7, 0.7, 0.7) # Gray
		"rare":
			return Color(0.2, 0.5, 1.0) # Blue
		"epic":
			return Color(0.6, 0.2, 0.8) # Purple
		"legendary":
			return Color(1.0, 0.8, 0.2) # Gold
		_:
			return Color(1.0, 1.0, 1.0) # White default
