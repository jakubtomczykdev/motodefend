extends Node2D

@onready var wave_label: Label = $WaveLabel if has_node("WaveLabel") else null
@onready var gold_label: Label = $CanvasLayer/GoldLabel if has_node("CanvasLayer") and $CanvasLayer.has_node("GoldLabel") else null

func _ready() -> void:
	_update_wave_display()
	_update_gold_display()

func _update_wave_display() -> void:
	var gd := get_node_or_null("/root/GameData")
	var wave := 1
	if gd:
		wave = gd.current_wave + 1
	
	if wave_label:
		wave_label.text = "FALA: %d" % wave

func _update_gold_display() -> void:
	var gd := get_node_or_null("/root/GameData")
	var gold := 0
	if gd:
		gold = gd.gold
	if gold_label:
		gold_label.text = "ZLOTO: %d" % gold

func _on_start_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainGame.tscn")

func _on_bestiary_button_pressed() -> void:
	var bestiary_scene = preload("res://scenes/BestiaryUI.tscn")
	var ui = bestiary_scene.instantiate()
	get_tree().root.add_child(ui)
	ui.open_bestiary()

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("ui_cancel") or 
		(event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed)):
		_toggle_pause()

func _toggle_pause() -> void:
	if get_tree().paused:
		_resume_pause()
	else:
		_show_pause()

func _show_pause() -> void:
	if has_node("PauseLayer"):
		return
	var pause_layer := CanvasLayer.new()
	pause_layer.name = "PauseLayer"
	pause_layer.layer = 100
	add_child(pause_layer)
	
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.5)
	bg.anchors_preset = Control.PRESET_FULL_RECT
	bg.mouse_filter = Control.MOUSE_FILTER_PASS
	pause_layer.add_child(bg)
	
	var settings_scene = load("res://scenes/Settings.tscn")
	var settings = settings_scene.instantiate()
	settings.name = "SettingsOverlay"
	settings.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_layer.add_child(settings)
	
	get_tree().paused = true

func _resume_pause() -> void:
	var pause_layer := get_node_or_null("PauseLayer") as CanvasLayer
	if pause_layer:
		pause_layer.queue_free()
	get_tree().paused = false
