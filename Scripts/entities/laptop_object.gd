extends Node2D
## LaptopBestiary – skrypt obiektu laptopa na planszy GameStartScreen
## Gracz podchodzi i naciska E → otwiera bestiariusz na ekranie laptopa

func _ready() -> void:
	var area := $InteractArea as Area2D
	if area:
		area.add_to_group("Interactable")

func get_interaction_text() -> String:
	return "[E] Otwórz bestiariusz"

func interact() -> void:
	AudioManager.play_sfx("interact_npc")
	var bestiary_scene := preload("res://scenes/ui/LaptopBestiaryUI.tscn")
	var ui := bestiary_scene.instantiate()
	get_tree().root.add_child(ui)
	ui.open_bestiary()
