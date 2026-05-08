extends CharacterBody2D

@export var npc_name: String = "Automat ze Sprzedażą"

func _ready() -> void:
	# Ten znak dolara '$' pozwala dostać się do węzła-dziecka.
	# Jeśli nazwałeś węzeł animacji inaczej, zmień "AnimatedSprite2D" na swoją nazwę.
	$AnimatedSprite2D.play("MashineAnimation")
	$InteractArea.add_to_group("Interactable")

func interact() -> void:
	# Rozpoczynamy grę (system sklepu dostępny w trakcie rozgrywki)
	get_tree().change_scene_to_file("res://scenes/MainGame.tscn")
