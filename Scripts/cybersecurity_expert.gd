extends CharacterBody2D

@export var npc_name: String = "Ekspert Cyberbezpieczeństwa"

func _ready() -> void:
	# Ten znak dolara '$' pozwala dostać się do węzła-dziecka.
	# Jeśli nazwałeś węzeł animacji inaczej, zmień "AnimatedSprite2D" na swoją nazwę.
	$AnimatedSprite2D.play("standing")
	$InteractArea.add_to_group("Interactable")

## Rozpoczyna grę. Intro edukacyjne wyświetli się automatycznie
## po załadowaniu MainGame (main_game_controller.start_game() → show_intro()).
func interact() -> void:
	get_tree().change_scene_to_file("res://scenes/MainGame.tscn")
