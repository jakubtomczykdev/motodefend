extends Resource
class_name WeaponItems

## Wszystkie bronie w grze – wewnętrzne klasy dziedziczące po WeaponBase

# Stare Radio – słaba fala uderzeniowa
class OldRadio extends WeaponBase:
	func _init():
		weapon_name = "Radio"
		weapon_type = "shockwave"
		description = "Stare radio – emituje słabą falę uderzeniową"
		cost = 150
		rarity = "common"
		damage = 10.0
		attack_speed = 4.0
		range = 150.0
		is_old_variant = true

# Nowe Radio Motorola – potężna fala uderzeniowa
class NewRadio extends WeaponBase:
	func _init():
		weapon_name = "Radio Motorola"
		weapon_type = "shockwave"
		description = "Nowe radio Motorola – potężna fala uderzeniowa"
		cost = 450
		rarity = "epic"
		damage = 25.0
		attack_speed = 3.0
		range = 250.0
		is_old_variant = false

# Stary Dron – wolno krąży i atakuje
class OldDrone extends WeaponBase:
	func _init():
		weapon_name = "Dron"
		weapon_type = "drone"
		description = "Stary dron – wolno krąży i atakuje"
		cost = 200
		rarity = "rare"
		damage = 8.0
		attack_speed = 5.0
		range = 300.0
		is_old_variant = true

# Dron Bojowy – szybki i śmiercionośny
class FightingDrone extends WeaponBase:
	func _init():
		weapon_name = "Dron Bojowy"
		weapon_type = "drone"
		description = "Dron bojowy – szybki i śmiercionośny"
		cost = 550
		rarity = "legendary"
		damage = 20.0
		attack_speed = 3.0
		range = 400.0
		is_old_variant = false

# Blaster – szybkie pociski energetyczne
class Blaster extends WeaponBase:
	func _init():
		weapon_name = "Blaster"
		weapon_type = "blaster"
		description = "Blaster – szybkie pociski energetyczne"
		cost = 300
		rarity = "rare"
		damage = 18.0
		attack_speed = 1.5
		range = 350.0
		is_old_variant = false

# Miecz – atak w zwarciu
class Sword extends WeaponBase:
	func _init():
		weapon_name = "Miecz"
		weapon_type = "sword"
		description = "Miecz – atak w zwarciu"
		cost = 120
		rarity = "common"
		damage = 15.0
		attack_speed = 1.0
		range = 80.0
		is_old_variant = false


static func get_all_weapons() -> Array[WeaponBase]:
	return [
		OldRadio.new(),
		NewRadio.new(),
		OldDrone.new(),
		FightingDrone.new(),
		Blaster.new(),
		Sword.new(),
	]
