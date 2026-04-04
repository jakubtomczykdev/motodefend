extends Control

# Ścieżki do scen (dostosowane do Twojego projektu)
@export var game_scene_path : String = "res://World.tscn" 
@export var settings_scene_path : String = "res://Settings.tscn"

# Używamy unikalnej nazwy (%), żeby Godot sam znalazł przycisk, 
# niezależnie od tego w ilu kontenerach jest schowany.
@onready var start_button: Button = %StartButton

func _ready():
	# Ustawia fokus na przycisku "Start" po włączeniu menu
	start_button.grab_focus()

# --- PRZYCISK: START ---
func _on_start_button_pressed():
	get_tree().change_scene_to_file(game_scene_path)

# --- PRZYCISK: USTAWIENIA ---
func _on_setting_btn_pressed() -> void:
	get_tree().change_scene_to_file(settings_scene_path)

# --- PRZYCISK: WYJŚCIE ---
func _on_button_2_pressed():
	get_tree().quit()


func _on_settings_btn_pressed() -> void:
	get_tree().change_scene_to_file(settings_scene_path)
