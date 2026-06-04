extends Resource
class_name MotorolaItems

## Itemy oparte na produktach Motorola Solutions

# CrossPatch - łączy zespoły terenowe, zwiększa zasięg ataku
class CrossPatchItem extends ItemBase:
	func _init():
		item_name = "CrossPatch"
		item_type = "communication"
		description = "Łączy zespoły terenowe. Co 5s wysyła impuls odpychający wrogów."
		rarity = "rare"
		cost = 150
		icon = preload("res://Assets/items/cross_patch.png")
		stats = {
			"attack_range": 0.2,
			"projectile_speed": 0.1
		}
		synergies = ["radio", "command"]

	func on_update(delta: float, player: Node2D) -> void:
		super.on_update(delta, player)
		if current_cooldown <= 0:
			current_cooldown = 5.0
			_emit_pulse(player)

	func _emit_pulse(player: Node2D) -> void:
		var enemies = player.get_tree().get_nodes_in_group("Enemies")
		for enemy in enemies:
			if enemy is Node2D:
				var dist = player.global_position.distance_to(enemy.global_position)
				if dist < 200.0:
					var dir = (enemy.global_position - player.global_position).normalized()
					if enemy.has_method("take_damage"):
						enemy.take_damage(0, dir * 400.0)

# PSTA - analityka wideo wykrywająca anomalie
class PSTAItem extends ItemBase:
	func _init():
		item_name = "PSTA"
		item_type = "analytics"
		description = "Analityka wideo. Zwiększa szansę na unik o 10%."
		rarity = "epic"
		cost = 300
		icon = preload("res://Assets/items/psta.png")
		stats = {
			"crit_chance": 0.15,
			"attack_speed": 0.1,
			"dodge_chance": 0.1
		}

# Radio APX - komunikacja w kryzysie
class RadioAPXItem extends ItemBase:
	func _init():
		item_name = "Radio APX"
		item_type = "radio"
		description = "Komunikacja w kryzysie. Skraca cooldown uniku o 20%."
		rarity = "common"
		cost = 100
		icon = preload("res://Assets/items/radio_apx.png")
		stats = {
			"attack_speed": 0.1,
			"move_speed": 0.1,
			"cooldown_reduction": 0.2
		}

# CommandCentral - centralne zarządzanie danymi
class CommandCentralItem extends ItemBase:
	func _init():
		item_name = "CommandCentral"
		item_type = "command"
		description = "Centralne zarządzanie. Co 10s leczy 5 HP."
		rarity = "legendary"
		cost = 500
		icon = preload("res://Assets/items/command_central.png")
		stats = {
			"damage": 0.2,
			"max_health": 0.2
		}

	func on_update(delta: float, player: Node2D) -> void:
		super.on_update(delta, player)
		if current_cooldown <= 0:
			current_cooldown = 10.0
			if player.has_method("heal"):
				player.heal(5)

# BodyCamera - kamera na body
class BodyCameraItem extends ItemBase:
	func _init():
		item_name = "BodyCamera"
		item_type = "detection"
		description = "Kamera na body. Zwiększa obrażenia przeciwko bossom o 20%."
		rarity = "rare"
		cost = 200
		icon = preload("res://Assets/items/body_camera.png")
		stats = {
			"attack_range": 0.15,
			"crit_chance": 0.05,
			"boss_damage_bonus": 0.2
		}

# SolutionHub - centralny hub łączący wszystkie systemy
class SolutionHubItem extends ItemBase:
	func _init():
		item_name = "SolutionHub"
		item_type = "hub"
		description = "Centralny hub. Co 8s razi najbliższego wroga piorunem danych."
		rarity = "legendary"
		cost = 600
		icon = preload("res://Assets/items/solution_hub.png")
		stats = {
			"damage": 0.2,
			"attack_speed": 0.15,
			"move_speed": 0.1
		}

	func on_update(delta: float, player: Node2D) -> void:
		super.on_update(delta, player)
		if current_cooldown <= 0:
			current_cooldown = 8.0
			_zap_enemy(player)

	func _zap_enemy(player: Node2D) -> void:
		var enemies = player.get_tree().get_nodes_in_group("Enemies")
		var closest = null
		var min_dist = 400.0
		for enemy in enemies:
			if enemy is Node2D:
				var d = player.global_position.distance_to(enemy.global_position)
				if d < min_dist:
					min_dist = d
					closest = enemy
		if closest and closest.has_method("take_damage"):
			closest.take_damage(25, (closest.global_position - player.global_position).normalized() * 100.0)

# Rave - zaawansowany system łączności
class RaveItem extends ItemBase:
	func _init():
		item_name = "RAVE"
		item_type = "communication"
		description = "System łączności. Zwiększa prędkość pocisków o 30%."
		rarity = "epic"
		cost = 350
		icon = preload("res://Assets/items/rave.png")
		stats = {
			"attack_speed": 0.15,
			"projectile_speed": 0.3
		}

# LPR - rozpoznawanie tablic rejestracyjnych
class LPRIItem extends ItemBase:
	func _init():
		item_name = "LPR"
		item_type = "analytics"
		description = "Rozpoznawanie tablic. Zwiększa szansę na krytyka o 15%."
		rarity = "rare"
		cost = 180
		icon = preload("res://Assets/items/lpr.png")
		stats = {
			"damage": 0.1,
			"crit_chance": 0.15
		}

# PremierOne - system CAD
class PremierOneItem extends ItemBase:
	func _init():
		item_name = "PremierOne"
		item_type = "command"
		description = "System CAD. Zwiększa pancerz o 15 i max HP o 30%."
		rarity = "epic"
		cost = 400
		icon = preload("res://Assets/items/premier_one.png")
		stats = {
			"max_health": 0.3,
			"armor": 15
		}

# TacticalVest - kamizelka taktyczna Motorola
class TacticalVestItem extends ItemBase:
	func _init():
		item_name = "Kamizelka Taktyczna"
		item_type = "protection"
		description = "Zwiększa pancerz o 10 i regenerację HP o 1/s."
		rarity = "rare"
		cost = 250
		icon = preload("res://Assets/items/tactical_vest.png")
		stats = {
			"armor": 10,
			"hp_regen": 1.0
		}

# VB400 - bodycam
class VB400Item extends ItemBase:
	func _init():
		item_name = "VB400"
		item_type = "detection"
		description = "Wodoodporna kamera. Zwiększa szybkość ruchu o 15%."
		rarity = "common"
		cost = 120
		icon = preload("res://Assets/items/vb400.png")
		stats = {
			"move_speed": 0.15
		}

# Funtion - platforma komunikacyjna
class FuntionItem extends ItemBase:
	func _init():
		item_name = "Funtion"
		item_type = "communication"
		description = "Platforma komunikacyjna. Zwiększa attack speed o 20%."
		rarity = "rare"
		cost = 220
		icon = preload("res://Assets/items/funtion.png")
		stats = {
			"attack_speed": 0.2
		}
