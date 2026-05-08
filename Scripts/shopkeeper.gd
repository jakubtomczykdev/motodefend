extends CharacterBody2D

@export var npc_name: String = "Automat ze Sprzedażą"

func _ready() -> void:
	$AnimatedSprite2D.play("MashineAnimation")
	$InteractArea.add_to_group("Interactable")

func interact() -> void:
	get_tree().change_scene_to_file("res://scenes/Shop.tscn")
