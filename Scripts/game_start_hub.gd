extends Node2D

@onready var wave_label: Label = $WaveLabel if has_node("WaveLabel") else null

func _ready() -> void:
	_update_wave_display()
	# Jeśli nie ma WaveLabel w scenie, utwórz go dynamicznie
	if not wave_label:
		_create_wave_label()

func _create_wave_label() -> void:
	wave_label = Label.new()
	wave_label.name = "WaveLabel"
	wave_label.position = Vector2(20, 20)
	wave_label.add_theme_font_size_override("font_size", 28)
	wave_label.add_theme_color_override("font_color", Color(0.816, 1.0, 1.0))  # cyan
	add_child(wave_label)
	_update_wave_display()

func _update_wave_display() -> void:
	var gd := get_node_or_null("/root/GameData")
	var wave := 1
	if gd:
		wave = gd.current_wave + 1  # Następna fala do rozegrania
	
	if wave_label:
		wave_label.text = "FALA: %d" % wave

func _on_start_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainGame.tscn")
