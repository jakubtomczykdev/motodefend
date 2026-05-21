extends Control

## TransitionScreen – Ekran przejścia między falami.

signal next_wave_requested
signal shop_requested
signal lobby_requested

@onready var stats_label: Label = $Panel/VBoxContainer/StatsLabel
@onready var next_button: Button = $Panel/VBoxContainer/HBoxContainer/NextButton
@onready var shop_button: Button = $Panel/VBoxContainer/HBoxContainer/ShopButton
@onready var lobby_button: Button = $Panel/VBoxContainer/HBoxContainer/LobbyButton

func _ready() -> void:
	visible = false
	next_button.pressed.connect(_on_next_pressed)
	shop_button.pressed.connect(_on_shop_pressed)
	lobby_button.pressed.connect(_on_lobby_pressed)

func show_transition(wave: int, score: int, gold: int) -> void:
	if stats_label:
		stats_label.text = "FALA %d UKOŃCZONA\n\nWYNIK: %d\nZŁOTO: %d" % [wave, score, gold]
	visible = true
	next_button.grab_focus()

func hide_transition() -> void:
	visible = false

func _on_next_pressed() -> void:
	AudioManager.play_sfx("menu_click")
	next_wave_requested.emit()

func _on_shop_pressed() -> void:
	AudioManager.play_sfx("menu_click")
	shop_requested.emit()

func _on_lobby_pressed() -> void:
	AudioManager.play_sfx("menu_click")
	lobby_requested.emit()
