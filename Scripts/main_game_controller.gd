extends Node2D
## Główny kontroler gry - integruje wszystkie systemy

signal game_started
signal game_over
signal victory

var player: CharacterBody2D
var wave_manager: Node
var build_system: Node
var item_manager: Node
var shop_system: Control
var educational_system: Control
var end_screen: Control
var playtime_label: Label
var health_bar: ProgressBar
var hp_label: Label
var gold_label: Label

var game_state: String = "menu" # menu, playing, paused, shop, education, game_over, victory
var score: int = 0
var gold: int = 100
var game_start_time: float = 0.0

# Globalny timer 10-minutowy został usunięty – fale mają własne timery w WaveManager

var items_collected: Array[ItemBase] = []
var wave_break_overlay: CanvasLayer = null

func _ready() -> void:
	# Znajdź węzły bezpiecznie
	player = get_node_or_null("Player")
	wave_manager = get_node_or_null("WaveManager")
	build_system = get_node_or_null("BuildSystem")
	item_manager = get_node_or_null("ItemManager")
	shop_system = get_node_or_null("ShopSystem")
	educational_system = get_node_or_null("EducationalLayer/EducationalSystem")
	end_screen = get_node_or_null("EndScreen")
	playtime_label = get_node_or_null("HUD/PlaytimeUI")
	health_bar = get_node_or_null("HUD/HealthBar")
	hp_label = get_node_or_null("HUD/HPLabel")
	gold_label = get_node_or_null("HUD/GoldLabel")

	_connect_signals()

	if educational_system: educational_system.visible = false

	# Rozpocznij grę automatycznie po załadowaniu sceny
	start_game()

func _process(delta: float) -> void:
	if game_state == "playing" and playtime_label and wave_manager:
		playtime_label.text = "FALA: %d" % wave_manager.current_wave

	# Aktualizuj wyświetlanie golda
	if gold_label:
		gold_label.text = "ZLOTO: %d" % gold

	# Aktualizuj pasek życia gracza
	if health_bar and player:
		health_bar.max_value = player.max_health
		health_bar.value = player.current_health
		if hp_label:
			hp_label.text = "HP: %d/%d" % [player.current_health, player.max_health]

func _connect_signals() -> void:
	if wave_manager:
		wave_manager.wave_started.connect(_on_wave_started)
		wave_manager.wave_ended.connect(_on_wave_ended)
		wave_manager.all_waves_completed.connect(_on_all_waves_completed)
		wave_manager.game_over.connect(_on_game_over)

	if player and player.has_signal("died"):
		player.died.connect(_on_player_died)
		player.health_changed.connect(_on_player_health_changed)

	if educational_system:
		educational_system.education_completed.connect(_on_education_completed)

	if end_screen:
		end_screen.restart_requested.connect(_on_restart_requested)
		end_screen.menu_requested.connect(_on_menu_requested)

func start_game() -> void:
	print("[MainGame] start_game BEGIN")
	if build_system:
		print("[MainGame] build_system.clear_build()...")
		build_system.clear_build()
		print("[MainGame] build cleared OK")

	# Wczytaj gold i HP z GameData, jeśli istnieją – fallback do wartości domyślnych
	var gd := get_node_or_null("/root/GameData")
	if gd and gd.gold > 0:
		gold = gd.gold
	else:
		gold = 100
	if shop_system:
		shop_system.add_gold(gold)

	if shop_system and shop_system.has_signal("shop_closed"):
		if not shop_system.shop_closed.is_connected(_on_shop_closed):
			shop_system.shop_closed.connect(_on_shop_closed)
	if shop_system and shop_system.has_signal("item_purchased"):
		if not shop_system.item_purchased.is_connected(_on_item_purchased):
			shop_system.item_purchased.connect(_on_item_purchased)

	if player:
		if player.has_method("heal"):
			player.heal(player.max_health)

		if gd and gd.player_max_hp > 0 and gd.player_hp > 0:
			player.max_health = gd.player_max_hp
			player.current_health = gd.player_hp
		elif wave_manager:
			var wave_hp: int = 9 + wave_manager.current_wave
			print("[MainGame] setting HP=%d for wave %d" % [wave_hp, wave_manager.current_wave])
			player.max_health = wave_hp
			player.current_health = wave_hp
		player.health_changed.emit(player.current_health, player.max_health)

	score = 0
	items_collected.clear()

	# System edukacyjny tymczasowo wyłączony – przechodzimy od razu do gry
	print("[MainGame] starting wave manager...")
	game_state = "playing"
	game_start_time = Time.get_unix_time_from_system()
	if wave_manager:
		wave_manager.start_game()
		print("[MainGame] wave_manager.start_game() OK")

	game_started.emit()
	print("[MainGame] start_game END")

func _on_education_completed() -> void:
	if game_state == "education_intro":
		game_state = "playing"
		get_tree().paused = false
		if wave_manager: wave_manager.start_game()
	elif game_state == "education":
		game_state = "playing"
		get_tree().paused = false

func _on_wave_started(wave_number: int) -> void:
	# Nie pauzujemy gry – timer fali leci niezależnie
	pass

func _on_wave_ended(wave_number: int) -> void:
	gold += 10
	if shop_system: shop_system.add_gold(10)
	score += wave_number * 100

	# Zapisz progresję w GameData (persystencja między sesjami)
	var gd := get_node_or_null("/root/GameData")
	if gd:
		gd.current_wave = wave_number
		gd.gold = gold
		gd.score = score

	# Pokaż ekran pauzy między falami zamiast zmieniać scenę
	_show_wave_break_overlay()

func _show_wave_break_overlay() -> void:
	game_state = "wave_break"
	get_tree().paused = true

	if wave_break_overlay:
		wave_break_overlay.queue_free()
		wave_break_overlay = null

	wave_break_overlay = CanvasLayer.new()
	wave_break_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	wave_break_overlay.layer = 5
	add_child(wave_break_overlay)

	var screen_size := get_viewport().get_visible_rect().size
	var panel := Panel.new()
	panel.custom_minimum_size = Vector2(500, 350)
	panel.size = Vector2(500, 350)
	panel.position = Vector2((screen_size.x - 500) / 2, (screen_size.y - 350) / 2)
	wave_break_overlay.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.size = Vector2(500, 350)
	vbox.position = Vector2(0, 0)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Fala %d ukończona!" % (wave_manager.current_wave if wave_manager else 0)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	vbox.add_child(title)

	var stats := Label.new()
	stats.text = "Złoto: %d | Wynik: %d" % [gold, score]
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats.add_theme_font_size_override("font_size", 20)
	vbox.add_child(stats)

	var next_btn := Button.new()
	next_btn.text = "Następna fala"
	next_btn.custom_minimum_size = Vector2(240, 50)
	next_btn.pressed.connect(_on_wave_break_next_wave)
	vbox.add_child(next_btn)

	var shop_btn := Button.new()
	shop_btn.text = "Sklep"
	shop_btn.custom_minimum_size = Vector2(240, 50)
	shop_btn.pressed.connect(_on_wave_break_shop)
	vbox.add_child(shop_btn)

	var hub_btn := Button.new()
	hub_btn.text = "Powrót do bazy"
	hub_btn.custom_minimum_size = Vector2(240, 50)
	hub_btn.pressed.connect(_on_wave_break_hub)
	vbox.add_child(hub_btn)

func _on_wave_break_next_wave() -> void:
	get_tree().paused = false
	if wave_break_overlay:
		wave_break_overlay.queue_free()
		wave_break_overlay = null
	game_state = "playing"
	if wave_manager:
		wave_manager.start_next_wave()

func _on_wave_break_shop() -> void:
	get_tree().paused = false
	if wave_break_overlay:
		wave_break_overlay.queue_free()
		wave_break_overlay = null
	_open_shop()

func _on_wave_break_hub() -> void:
	get_tree().paused = false
	if wave_break_overlay:
		wave_break_overlay.queue_free()
		wave_break_overlay = null
	get_tree().change_scene_to_file("res://scenes/GameStartScreen.tscn")

func _open_shop() -> void:
	# Sklep otwierany z ekranu pauzy między falami
	game_state = "shop"
	if shop_system and shop_system.has_method("open_shop"):
		shop_system.open_shop(gold)
		get_tree().paused = true

func _on_shop_closed() -> void:
	game_state = "playing"
	get_tree().paused = false
	if shop_system:
		gold = shop_system.player_gold
	if wave_manager:
		wave_manager.start_next_wave()

func _on_item_purchased(item: ItemBase) -> void:
	items_collected.append(item)
	if shop_system:
		gold = shop_system.player_gold
	if build_system:
		build_system.add_item(item)
	_update_player_stats()

func _update_player_stats() -> void:
	if player and build_system:
		var old_max_hp: int = player.max_health
		player.damage = int(player.base_damage * build_system.get_stat("damage"))
		player.attack_speed = player.base_attack_speed * build_system.get_stat("attack_speed")
		player.move_speed = player.base_move_speed * build_system.get_stat("move_speed")
		player.attack_range = player.base_attack_range * build_system.get_stat("attack_range")
		player.max_health = int(player.base_max_health * build_system.get_stat("max_health"))
		# Zachowaj proporcje HP przy zmianie max_health
		if old_max_hp > 0 and player.max_health != old_max_hp:
			var ratio: float = float(player.current_health) / float(old_max_hp)
			player.current_health = clampi(int(player.max_health * ratio), 1, player.max_health)
			player.health_changed.emit(player.current_health, player.max_health)

func _on_all_waves_completed() -> void:
	game_state = "victory"
	victory.emit()
	show_victory()

func _on_game_over() -> void:
	game_state = "game_over"
	game_over.emit()
	show_game_over()

func _on_player_died() -> void:
	# Zapisz do GameData i pokaż ekran Game Over
	var gd := get_node_or_null("/root/GameData")
	if gd:
		gd.current_wave = wave_manager.current_wave if wave_manager else 0
		gd.gold = gold
		gd.score = score
	game_state = "game_over"
	show_game_over()

func _on_player_health_changed(_current: int, _max: int) -> void:
	var gd := get_node_or_null("/root/GameData")
	if gd:
		gd.player_hp = _current
		gd.player_max_hp = _max

func _on_restart_requested() -> void:
	get_tree().reload_current_scene()

func _on_menu_requested() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn")

func show_game_over() -> void:
	if end_screen and wave_manager:
		var playtime := Time.get_unix_time_from_system() - game_start_time
		end_screen.show_game_over(score, wave_manager.current_wave, items_collected, playtime)
		get_tree().paused = true

func show_victory() -> void:
	if end_screen and wave_manager:
		var playtime := Time.get_unix_time_from_system() - game_start_time
		end_screen.show_victory(score, wave_manager.current_wave, items_collected, playtime)
		get_tree().paused = true
