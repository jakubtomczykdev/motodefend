# Refactored path
extends Resource
class_name WeaponItems

## Wszystkie bronie w sklepie. Każda linia ma poziom i minimalny tier sklepu.

static func _make_weapon(
	p_name: String,
	p_type: String,
	p_base_id: String,
	p_level: int,
	p_min_tier: int,
	p_rarity: String,
	p_cost: int,
	p_damage: float,
	p_attack_speed: float,
	p_range: float,
	p_icon: Texture2D,
	p_description: String,
	p_is_old: bool = false
) -> WeaponBase:
	var weapon := WeaponBase.new()
	weapon.item_name = "%s %s" % [p_name, _roman(p_level)]
	weapon.item_type = p_type
	weapon.base_weapon_id = p_base_id
	weapon.weapon_level = p_level
	weapon.min_shop_tier = p_min_tier
	weapon.rarity = p_rarity
	weapon.cost = p_cost
	weapon.damage = p_damage
	weapon.attack_speed = p_attack_speed
	weapon.weapon_range = p_range
	weapon.icon = p_icon
	weapon.description = p_description
	weapon.is_old_variant = p_is_old
	return weapon

static func _roman(level: int) -> String:
	match level:
		1:
			return "I"
		2:
			return "II"
		3:
			return "III"
		4:
			return "IV"
		_:
			return str(level)

static func get_all_weapons() -> Array[WeaponBase]:
	var old_radio := load("res://Assets/newAssets/oldRadio.png") as Texture2D
	var new_radio := load("res://Assets/newAssets/newRadio.png") as Texture2D
	var old_drone := load("res://Assets/newAssets/oldDrone.png") as Texture2D
	var fighting_drone := load("res://Assets/newAssets/fightingDrone.png") as Texture2D
	var blaster := load("res://Assets/newAssets/Blaster.png") as Texture2D
	var sword := load("res://Assets/newAssets/sword.png") as Texture2D

	return [
		_make_weapon(
			"Radio", "shockwave", "radio", 1, 1, "common", 90,
			42.0, 1.65, 145.0, old_radio,
			"Podstawowa fala obszarowa. Tania i dobra na pierwsze infekcje.", true
		),
		_make_weapon(
			"Radio Motorola", "shockwave", "radio", 2, 2, "rare", 170,
			62.0, 1.35, 230.0, new_radio,
			"Mocniejsza fala o wiekszym zasiegu. Stabilny upgrade do kontroli tlumu."
		),
		_make_weapon(
			"Radio Motorola", "shockwave", "radio", 3, 4, "epic", 300,
			86.0, 1.1, 330.0, new_radio,
			"Zaawansowana fala Motorola. Spowalnia wrogow i czysci wieksze grupy."
		),

		_make_weapon(
			"Dron", "drone", "drone", 1, 1, "common", 105,
			26.0, 1.35, 280.0, old_drone,
			"Autonomiczny dron patrolowy. Slabszy, ale dziala bez celowania.", true
		),
		_make_weapon(
			"Dron Patrolowy", "drone", "drone", 2, 2, "rare", 190,
			40.0, 1.0, 390.0, old_drone,
			"Szybszy dron z lepszym zasiegiem i czestszym ostrzalem."
		),
		_make_weapon(
			"Dron Bojowy", "drone", "drone", 3, 4, "legendary", 360,
			58.0, 0.72, 520.0, fighting_drone,
			"Elitarny dron bojowy. Agresywnie namierza cele i zadaje wysokie obrazenia."
		),

		_make_weapon(
			"Blaster", "blaster", "blaster", 1, 1, "common", 115,
			48.0, 0.75, 420.0, blaster,
			"Seria szybkich pakietow danych. Dobry startowy wybor dystansowy."
		),
		_make_weapon(
			"Blaster Motorola", "blaster", "blaster", 2, 3, "rare", 220,
			72.0, 0.52, 540.0, blaster,
			"Szybsza i mocniejsza seria. Lepiej skaluje sie z obrazeniami gracza."
		),
		_make_weapon(
			"Blaster Motorola", "blaster", "blaster", 3, 5, "epic", 340,
			98.0, 0.38, 650.0, blaster,
			"Wysokowydajny blaster do poznych fal. Bardzo szybki burst."
		),

		_make_weapon(
			"Miecz", "sword", "sword", 1, 1, "common", 100,
			62.0, 0.82, 210.0, sword,
			"Ryzykowna bron w zwarciu. Wysokie obrazenia za bliski dystans."
		),
		_make_weapon(
			"Miecz Taktyczny", "sword", "sword", 2, 3, "rare", 205,
			86.0, 0.64, 270.0, sword,
			"Szerszy zamach i lepszy cooldown. Dobra bron do agresywnego stylu."
		),
		_make_weapon(
			"Miecz Energetyczny", "sword", "sword", 3, 5, "epic", 330,
			118.0, 0.48, 340.0, sword,
			"Pozny wariant miecza. Bardzo mocne ciosy i dluzszy zasieg."
		),
	]

static func get_weapons_for_shop_tier(shop_tier: int) -> Array[WeaponBase]:
	return get_all_weapons().filter(func(weapon: WeaponBase): return weapon.min_shop_tier <= shop_tier)
