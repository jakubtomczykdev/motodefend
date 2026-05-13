extends CharacterBody2D

@export var npc_name: String = "Automat ze Sprzedażą"

func _ready() -> void:
	var anim := find_child("AnimatedSprite2D", true, false) as AnimatedSprite2D
	if anim:
		anim.play("MashineAnimation")
	var interact := find_child("InteractArea", true, false) as Area2D
	if interact:
		interact.add_to_group("Interactable")

func interact() -> void:
	get_tree().change_scene_to_file("res://scenes/Shop.tscn")
