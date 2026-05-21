# Refactored path
extends Resource
class_name WeaponItems

## Wszystkie bronie w grze – wewnętrzne klasy dziedziczące po WeaponBase

# Stare Radio – słaba fala uderzeniowa
class OldRadio extends WeaponBase:
	func _init():
		item_name = "Radio"
		item_type = "shockwave"
		description = "Stare radio emituje falę uderzeniową (obrażenia obszarowe)"
		cost = BalanceData.OLDRADIO_COST
		rarity = "common"
		damage = BalanceData.OLDRADIO_DAMAGE
		attack_speed = BalanceData.OLDRADIO_ATTACK_SPEED
		weapon_range = BalanceData.OLDRADIO_RANGE
		is_old_variant = true
		icon = load("res://Assets/newAssets/oldRadio.png")

# Nowe Radio Motorola potężna fala uderzeniowa
class NewRadio extends WeaponBase:
	func _init():
		item_name = "Radio Motorola"
		item_type = "shockwave"
		description = "Nowe radio Motorola potężna fala uderzeniowa (obrażenia obszarowe)"
		cost = BalanceData.NEWRADIO_COST
		rarity = "epic"
		damage = BalanceData.NEWRADIO_DAMAGE
		attack_speed = BalanceData.NEWRADIO_ATTACK_SPEED
		weapon_range = BalanceData.NEWRADIO_RANGE
		is_old_variant = false
		icon = load("res://Assets/newAssets/newRadio.png")

# Stary Dron wolno krąży i atakuje
class OldDrone extends WeaponBase:
	func _init():
		item_name = "Dron"
		item_type = "drone"
		description = "Stary dron krąży wokół gracza i automatycznie atakuje"
		cost = BalanceData.OLDDRONE_COST
		rarity = "rare"
		damage = BalanceData.OLDDRONE_DAMAGE
		attack_speed = BalanceData.OLDDRONE_ATTACK_SPEED
		weapon_range = BalanceData.OLDDRONE_RANGE
		is_old_variant = true
		icon = load("res://Assets/newAssets/oldDrone.png")

# Dron Bojowy szybki i śmiercionośny
class FightingDrone extends WeaponBase:
	func _init():
		item_name = "Dron Bojowy"
		item_type = "drone"
		description = "Dron bojowy krąży wokół gracza i automatycznie atakuje (szybki fire rate)"
		cost = BalanceData.FIGHTINGDRONE_COST
		rarity = "legendary"
		damage = BalanceData.FIGHTINGDRONE_DAMAGE
		attack_speed = BalanceData.FIGHTINGDRONE_ATTACK_SPEED
		weapon_range = BalanceData.FIGHTINGDRONE_RANGE
		is_old_variant = false
		icon = load("res://Assets/newAssets/fightingDrone.png")

# Blaster pojedynczy, potężny pocisk energii
class Blaster extends WeaponBase:
	func _init():
		item_name = "Blaster"
		item_type = "blaster"
		description = "Blaster Motorola - wysyła serię szybkich pakietów danych"
		cost = BalanceData.BLASTER_COST
		rarity = "rare"
		damage = BalanceData.BLASTER_DAMAGE
		attack_speed = BalanceData.BLASTER_ATTACK_SPEED
		weapon_range = BalanceData.BLASTER_RANGE
		is_old_variant = false
		icon = load("res://Assets/newAssets/Blaster.png")

# Miecz atak w zwarciu
class Sword extends WeaponBase:
	func _init():
		item_name = "Miecz"
		item_type = "sword"
		description = "Miecz - potężne cięcia (wysokie DPS, ryzykowne użycie)"
		cost = BalanceData.SWORD_COST
		rarity = "common"
		damage = BalanceData.SWORD_DAMAGE
		attack_speed = BalanceData.SWORD_ATTACK_SPEED
		weapon_range = BalanceData.SWORD_RANGE
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
