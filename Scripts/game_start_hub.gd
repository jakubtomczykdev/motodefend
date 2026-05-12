extends Node2D

@onready var wave_label: Label = $WaveLabel if has_node("WaveLabel") else null
@onready var gold_label: Label = $CanvasLayer/GoldLabel if has_node("CanvasLayer") and $CanvasLayer.has_node("GoldLabel") else null

func _ready() -> void:
	_update_wave_display()
	_update_gold_display()
	if not wave_label:
		_create_wave_label()
	if not gold_label:
		_create_gold_label()

func _create_wave_label() -> void:
	wave_label = Label.new()
	wave_label.name = "WaveLabel"
	wave_label.position = Vector2(20, 20)
	wave_label.add_theme_font_size_override("font_size", 28)
	wave_label.add_theme_color_override("font_color", Color(0.816, 1.0, 1.0))
	add_child(wave_label)
	_update_wave_display()

func _update_wave_display() -> void:
	var gd := get_node_or_null("/root/GameData")
	var wave := 1
	if gd:
		wave = gd.current_wave + 1
	
	if wave_label:
		wave_label.text = "FALA: %d" % wave

func _create_gold_label() -> void:
	gold_label = Label.new()
	gold_label.name = "GoldLabel"
	gold_label.position = Vector2(20, 55)
	gold_label.add_theme_font_size_override("font_size", 24)
	gold_label.add_theme_color_override("font_color", Color(1, 0.84, 0))
	add_child(gold_label)
	_update_gold_display()

func _update_gold_display() -> void:
	var gd := get_node_or_null("/root/GameData")
	var gold := 0
	if gd:
		gold = gd.gold
	if gold_label:
		gold_label.text = "ZLOTO: %d" % gold

func _on_start_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainGame.tscn")

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("ui_cancel") or 
		(event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed)):
		var gd := get_node_or_null("/root/GameData")
		if gd:
			gd.return_scene = "res://scenes/GameStartScreen.tscn"
		get_tree().change_scene_to_file("res://scenes/Settings.tscn")
