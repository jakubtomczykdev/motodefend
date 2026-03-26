extends Control

# Ścieżka do głównej sceny gry
@export var game_scene_path : String = "res://scenes/World.tscn"
@onready var start_button: Button = $ButtonsContainer/StartButton
func _ready():
	start_button.grab_focus()

func _on_start_button_pressed():

	get_tree().change_scene_to_file(game_scene_path)

func _on_options_button_pressed():
	print("Otwieranie ustawień protokołów...")

func _on_exit_button_pressed():
	get_tree().quit()
