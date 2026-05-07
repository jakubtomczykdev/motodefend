extends CharacterBody2D

@export var npc_name: String = "Automat ze Sprzedażą"

func _ready() -> void:
	# Ten znak dolara '$' pozwala dostać się do węzła-dziecka.
	# Jeśli nazwałeś węzeł animacji inaczej, zmień "AnimatedSprite2D" na swoją nazwę.
	$AnimatedSprite2D.play("MashineAnimation")
	$InteractArea.add_to_group("Interactable")

func interact():
	print("Interakcja z: " + npc_name)
	# Tutaj można dodać otwarcie sklepu, dialog lub inne akcje.
