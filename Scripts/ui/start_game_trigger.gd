extends Area2D

## StartGameTrigger – Obsługuje interakcję z obiektem startującym grę.

func get_interaction_text() -> String:
	return "START GRY (E)"

func interact() -> void:
	get_tree().paused = false
	if AudioManager.has_method("play_sfx"):
		AudioManager.play_sfx("menu_click")
	
	# Zatrzymaj muzykę lobby przed wejściem do gry (lub AudioManager sam przełączy)
	get_tree().change_scene_to_file("res://scenes/game/MainGame.tscn")
