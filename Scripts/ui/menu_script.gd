extends Control

## MainMenu – Obsługuje główne menu gry.

func _ready() -> void:
	# Zapewnij widoczność kursora
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Graj muzykę lobby
	if AudioManager.has_method("play_music"):
		AudioManager.play_music(AudioManager.MUSIC_LOBBY)

func _on_start_button_pressed() -> void:
	if AudioManager.has_method("play_sfx"):
		AudioManager.play_sfx("menu_click")
	
	# Przejdź do huba startowego
	get_tree().change_scene_to_file("res://scenes/world/GameStartScreen.tscn")

func _on_settings_btn_pressed() -> void:
	if AudioManager.has_method("play_sfx"):
		AudioManager.play_sfx("menu_click")
	
	# Zapisz skąd przyszliśmy, żeby wrócić
	var gd = get_node_or_null("/root/GameData")
	if gd:
		gd.return_scene = "res://scenes/ui/MainMenu.tscn"
	
	get_tree().change_scene_to_file("res://scenes/ui/Settings.tscn")

func _on_button_2_pressed() -> void:
	if AudioManager.has_method("play_sfx"):
		AudioManager.play_sfx("menu_click")
	
	# Wyjdź z gry
	get_tree().quit()
