extends Control

const WeaponItemsClass := preload("res://Scripts/items/weapon_items.gd")

var all_weapons: Array[WeaponBase] = []

func _ready() -> void:
	print("[DEBUG] _ready() start")
	all_weapons = WeaponItemsClass.get_all_weapons()
	print("[DEBUG] all_weapons size: ", all_weapons.size())
	for w in all_weapons:
		print("[DEBUG] weapon: ", w.weapon_name)
	print("[DEBUG] _ready() end")
