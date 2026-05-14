extends Area2D

func _ready() -> void:
	add_to_group("Interactable")

func get_interaction_text() -> String:
	return "[E] Zacznij grę"

func interact() -> void:
	get_tree().change_scene_to_file("res://scenes/MainGame.tscn")
