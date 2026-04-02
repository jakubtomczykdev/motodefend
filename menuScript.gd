extends Control

# Ścieżki do scen (zwróć uwagę, czy na pewno Start ma prowadzić do "scenes/Settings.tscn")
@export var game_scene_path : String = "res://scenes/Settings.tscn" 
@export var settings_scene_path : String = "res://Settings.tscn"

@onready var start_button: Button = $ButtonsContainer/StartButton

func _ready():
	start_button.grab_focus()

func _on_start_button_pressed():
	get_tree().change_scene_to_file(game_scene_path)

func _on_exit_button_pressed():
	get_tree().quit()

# Tutaj podłączony jest Twój nowy przycisk "settingsBtn"
func _on_settings_btn_pressed() -> void:
	# Zamieniliśmy "pass" na zmianę sceny, używając Twojej zmiennej z góry!
	get_tree().change_scene_to_file(settings_scene_path)
