extends Resource
## Itemy oparte na produktach Motorola Solutions

# CrossPatch - łączy zespoły terenowe, zwiększa zasięg ataku
class_name CrossPatchItem extends ItemBase

func _init():
	item_name = "CrossPatch"
	item_type = "communication"
	description = "Łączy zespoły terenowe, zwiększając zasięg ataku."
	rarity = "rare"
	cost = 150
	stats = {
		"attack_range": 0.3,
		"projectile_speed": 0.1
	}
	synergies = ["radio", "command"]

# PSTA - analityka wideo wykrywająca anomalie, poprawia percepcję zagrożeń
class_name PSTAItem extends ItemBase

func _init():
	item_name = "PSTA"
	item_type = "analytics"
	description = "Analityka wideo wykrywająca anomalie, poprawia percepcję zagrożeń."
	rarity = "epic"
	cost = 300
	stats = {
		"crit_chance": 0.15,
		"crit_damage": 0.3,
		"attack_speed": 0.1
	}
	synergies = ["command", "detection"]

# Radio APX - komunikacja w kryzysie, daje bonus do szybkości reakcji
class_name RadioAPXItem extends ItemBase

func _init():
	item_name = "Radio APX"
	item_type = "radio"
	description = "Komunikacja w kryzysie, daje bonus do szybkości reakcji."
	rarity = "common"
	cost = 100
	stats = {
		"attack_speed": 0.2,
		"move_speed": 0.15
	}
	synergies = ["communication", "command"]

# CommandCentral - centralne zarządzanie danymi, spowalnia fale wrogów
class_name CommandCentralItem extends ItemBase

func _init():
	item_name = "CommandCentral"
	item_type = "command"
	description = "Centralne zarządzanie danymi, spowalnia fale wrogów."
	rarity = "legendary"
	cost = 500
	stats = {
		"damage": 0.25,
		"attack_speed": 0.15,
		"max_health": 0.2
	}
	synergies = ["communication", "radio", "analytics"]

# BodyCamera - kamera na body, zwiększa widoczność i zasięg
class_name BodyCameraItem extends ItemBase

func _init():
	item_name = "BodyCamera"
	item_type = "detection"
	description = "Kamera na body, zwiększa widoczność i zasięg detekcji."
	rarity = "rare"
	cost = 200
	stats = {
		"attack_range": 0.2,
		"crit_chance": 0.1
	}
	synergies = ["analytics", "communication"]

# SolutionHub - centralny hub łączący wszystkie systemy
class_name SolutionHubItem extends ItemBase

func _init():
	item_name = "SolutionHub"
	item_type = "hub"
	description = "Centralny hub łączący wszystkie systemy Motorola."
	rarity = "legendary"
	cost = 600
	stats = {
		"damage": 0.3,
		"attack_speed": 0.2,
		"move_speed": 0.2,
		"max_health": 0.3
	}
	synergies = ["communication", "radio", "command", "analytics", "detection"]

# Rave - zaawansowany system łączności
class_name RaveItem extends ItemBase

func _init():
	item_name = "RAVE"
	item_type = "communication"
	description = "Zaawansowany system łączności wideo i audio."
	rarity = "epic"
	cost = 350
	stats = {
		"attack_speed": 0.25,
		"projectile_speed": 0.2,
		"crit_chance": 0.1
	}
	synergies = ["radio", "hub"]

# LPR - rozpoznawanie tablic rejestracyjnych
class_name LPRIItem extends ItemBase

func _init():
	item_name = "LPR"
	item_type = "analytics"
	description = "Automatyczne rozpoznawanie tablic rejestracyjnych."
	rarity = "rare"
	cost = 180
	stats = {
		"damage": 0.2,
		"crit_chance": 0.15
	}
	synergies = ["detection", "command"]

# PremierOne - system CAD
class_name PremierOneItem extends ItemBase

func _init():
	item_name = "PremierOne"
	item_type = "command"
	description = "Zaawansowany system CAD dla służb ratunkowych."
	rarity = "epic"
	cost = 400
	stats = {
		"damage": 0.2,
		"attack_speed": 0.15,
		"max_health": 0.25
	}
	synergies = ["hub", "analytics"]

# VB400 - bodycam
class_name VB400Item extends ItemBase

func _init():
	item_name = "VB400"
	item_type = "detection"
	description = "Wodoodporna kamera body."
	rarity = "common"
	cost = 120
	stats = {
		"move_speed": 0.1,
		"attack_range": 0.15
	}
	synergies = ["analytics", "radio"]

# Funtion - platforma komunikacyjna
class_name FuntionItem extends ItemBase

func _init():
	item_name = "Funtion"
	item_type = "communication"
	description = "Platforma komunikacyjna dla służb publicznych."
	rarity = "rare"
	cost = 220
	stats = {
		"attack_speed": 0.2,
		"crit_damage": 0.2
	}
	synergies = ["radio", "command"]