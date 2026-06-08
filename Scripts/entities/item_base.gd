# Refactored path
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

var current_cooldown: float = 0.0

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

## Stosuje efekty przedmiotu na buildzie gracza
func apply_effects(build: Node) -> void:
	for stat_name: String in stats:
		var value: float = float(stats[stat_name])
		if build.has_method("add_stat"):
			build.add_stat(stat_name, _resolve_stat_value(build, stat_name, value))

## Usuwa efekty przedmiotu z buildu gracza
func remove_effects(build: Node) -> void:
	for stat_name: String in stats:
		var value: float = float(stats[stat_name])
		if build.has_method("add_stat"):
			build.add_stat(stat_name, -_resolve_stat_value(build, stat_name, value))

func _resolve_stat_value(build: Node, stat_name: String, value: float) -> float:
	if stat_name == "max_health" and absf(value) > 0.0 and absf(value) < 1.0 and build.has_method("get_stat"):
		return build.get_stat("max_health") * value
	return value

## Metoda wywoływana co klatkę dla aktywnych efektów przedmiotów
func on_update(delta: float, player: Node2D) -> void:
	if current_cooldown > 0:
		current_cooldown -= delta
