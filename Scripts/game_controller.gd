extends Node2D
## Główny kontroler gry - zarządza stanem gry

@onready var wave_manager: Node = $WaveManager
@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	# Połącz sygnały
	if wave_manager:
		wave_manager.wave_started.connect(_on_wave_started)
		wave_manager.wave_ended.connect(_on_wave_ended)
		wave_manager.all_waves_completed.connect(_on_all_waves_completed)

	if player:
		player.died.connect(_on_player_died)

func _on_wave_started(wave_number: int) -> void:
	print("Fala %d rozpoczęta!" % wave_number)

func _on_wave_ended(wave_number: int) -> void:
	print("Fala %d zakończona!" % wave_number)

func _on_all_waves_completed() -> void:
	print("Gratulacje! Wszystkie fale ukończone!")
	# Pokaż ekran zwycięstwa

func _on_player_died() -> void:
	print("Gracz zginął!")
	# Pokaż ekran game over