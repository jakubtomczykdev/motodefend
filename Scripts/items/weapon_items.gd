extends Resource
class_name WeaponItems

## Wszystkie bronie w grze – wewnętrzne klasy dziedziczące po WeaponBase

# Stare Radio – słaba fala uderzeniowa
class OldRadio extends WeaponBase:
	func _init():
		weapon_name = "Radio"
		weapon_type = "shockwave"
		description = "Stare radio – emituje falę uderzeniową (obrażenia obszarowe)"
		cost = 90
		rarity = "common"
		damage = 12.0
		attack_speed = 3.0
		weapon_range = 150.0
		is_old_variant = true
		icon = load("res://Assets/newAssets/oldRadio.png")

# Nowe Radio Motorola – potężna fala uderzeniowa
class NewRadio extends WeaponBase:
	func _init():
		weapon_name = "Radio Motorola"
		weapon_type = "shockwave"
		description = "Nowe radio Motorola – potężna fala uderzeniowa (obrażenia obszarowe)"
		cost = 250
		rarity = "epic"
		damage = 20.0
		attack_speed = 2.0
		weapon_range = 250.0
		is_old_variant = false
		icon = load("res://Assets/newAssets/newRadio.png")

# Stary Dron – wolno krąży i atakuje
class OldDrone extends WeaponBase:
	func _init():
		weapon_name = "Dron"
		weapon_type = "drone"
		description = "Stary dron – krąży wokół gracza i automatycznie atakuje"
		cost = 100
		rarity = "rare"
		damage = 8.0
		attack_speed = 2.0
		weapon_range = 300.0
		is_old_variant = true
		icon = load("res://Assets/newAssets/oldDrone.png")

# Dron Bojowy – szybki i śmiercionośny
class FightingDrone extends WeaponBase:
	func _init():
		weapon_name = "Dron Bojowy"
		weapon_type = "drone"
		description = "Dron bojowy – krąży wokół gracza i automatycznie atakuje (szybki fire rate)"
		cost = 300
		rarity = "legendary"
		damage = 12.0
		attack_speed = 1.2
		weapon_range = 400.0
		is_old_variant = false
		icon = load("res://Assets/newAssets/fightingDrone.png")

# Blaster – szybkie pociski energetyczne
class Blaster extends WeaponBase:
	func _init():
		weapon_name = "Blaster"
		weapon_type = "blaster"
		description = "Blaster – super szybka wiązka niebieskich kul w jednej linii"
		cost = 200
		rarity = "rare"
		damage = 2.0
		attack_speed = 0.05
		weapon_range = 500.0
		is_old_variant = false
		icon = load("res://Assets/newAssets/Blaster.png")

# Miecz – atak w zwarciu
class Sword extends WeaponBase:
	func _init():
		weapon_name = "Miecz"
		weapon_type = "sword"
		description = "Miecz – atak w zwarciu (wysokie DPS, ryzykowne użycie)"
		cost = 100
		rarity = "common"
		damage = 12.0
		attack_speed = 2.0
		weapon_range = 120.0
		is_old_variant = false
		icon = load("res://Assets/newAssets/sword.png")


static func get_all_weapons() -> Array[WeaponBase]:
	return [
		OldRadio.new(),
		NewRadio.new(),
		OldDrone.new(),
		FightingDrone.new(),
		Blaster.new(),
		Sword.new(),
	]
