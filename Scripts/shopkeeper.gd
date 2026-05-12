extends CharacterBody2D

@export var npc_name: String = "Automat ze Sprzedażą"

func _ready() -> void:
	$AnimatedSprite2D.play("MashineAnimation")
	$InteractArea.add_to_group("Interactable")
	print("[DEBUG] Shopkeeper _ready, InteractArea group=", $InteractArea.is_in_group("Interactable"))

func interact() -> void:
	print("[DEBUG] Shopkeeper.interact() called, loading Shop.tscn...")
	print("[DEBUG] About to change scene to Shop.tscn")
	get_tree().change_scene_to_file("res://scenes/Shop.tscn")
	print("Shop.tscn załadowany")
