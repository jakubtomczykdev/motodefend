extends Resource
class_name ItemBase

@export var item_name: String = "Nowy Przedmiot"
@export var description: String = ""
@export var icon: Texture2D
@export var price: int = 0

# Przykładowe statystyki, które przedmiot może modyfikować
@export var damage_bonus: float = 0.0
@export var speed_bonus: float = 0.0
@export var health_bonus: int = 0
