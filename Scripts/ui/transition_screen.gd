extends Control

signal next_wave_requested
signal lobby_requested

@onready var title_label = $Panel/VBoxContainer/TitleLabel
@onready var stats_label = $Panel/VBoxContainer/StatsLabel
@onready var next_button = $Panel/VBoxContainer/HBoxContainer/NextButton
@onready var lobby_button = $Panel/VBoxContainer/HBoxContainer/LobbyButton

func _ready():
	# Podstawowa stylizacja (pixel art style)
	visible = false
	next_button.pressed.connect(_on_next_pressed)
	lobby_button.pressed.connect(_on_lobby_pressed)

func show_transition(wave_num: int, score: int, gold: int):
	title_label.text = "FALA %d UKOŃCZONA" % wave_num
	stats_label.text = "WYNIK: %d\nZŁOTO: %d" % [score, gold]
	
	visible = true
	# Animacja wejścia
	modulate.a = 0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	
	# Skupienie na przycisku dla obsługi pada/klawiatury
	next_button.grab_focus()

func hide_transition():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func(): visible = false)

func _on_next_pressed():
	AudioManager.play_sfx("menu_click")
	next_wave_requested.emit()

func _on_lobby_pressed():
	AudioManager.play_sfx("menu_click")
	lobby_requested.emit()
