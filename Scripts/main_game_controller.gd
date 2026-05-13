extends Node2D
## Główny kontroler gry - integruje wszystkie systemy

const WeaponItemsClass := preload("res://Scripts/items/weapon_items.gd")

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
var enemies_label: Label

var game_state: String = "menu" # menu, playing, paused, shop, education, game_over, victory
var score: int = 0
var gold: int = 100
var _last_gold_display: int = -1
var game_start_time: float = 0.0

var items_collected: Array[ItemBase] = []

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
	enemies_label = get_node_or_null("HUD/EnemiesRemainingLabel")

	_connect_signals()

	if educational_system: educational_system.visible = false

	# Rozpocznij grę automatycznie po załadowaniu sceny
	start_game()

func _process(delta: float) -> void:
	if game_state == "playing":
		if playtime_label and wave_manager:
			playtime_label.text = "FALA: %d" % wave_manager.current_wave
		
		# Wywołaj efekty aktywne przedmiotów
		if player:
			for item in items_collected:
				if item.has_method("on_update"):
					item.on_update(delta, player)

	# Aktualizuj wyświetlanie golda (tylko gdy się zmieni)
	if gold_label and gold != _last_gold_display:
		gold_label.text = "ZLOTO: %d" % gold
		_last_gold_display = gold

	# Aktualizuj licznik wrogów
	if enemies_label and wave_manager:
		enemies_label.text = "WROGOWIE: %d/%d" % [wave_manager.enemies_remaining, wave_manager.enemies_in_wave]

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
	var gd := get_node_or_null("/root/GameData")
	print("[MainGame] start_game BEGIN")
	if build_system:
		print("[MainGame] build_system.clear_build()...")
		build_system.clear_build()
		print("[MainGame] build cleared OK")

	# Wczytaj gold i HP z GameData, jeśli istnieją – fallback do wartości domyślnych
	if gd and gd.gold > 0:
		gold = gd.gold
	else:
		gold = 300

	if shop_system: shop_system.add_gold(gold)

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
	if wave_manager:
		wave_manager.start_game()
		print("[MainGame] wave_manager.start_game() OK")

	# Equip permanent weapons and items from GameData
	if gd and player:
		# Restore Weapons
		if player.has_method("add_weapon"):
			await get_tree().process_frame
			var all_weapons: Array = WeaponItemsClass.get_all_weapons()
			for widx in gd.pending_weapon_ids:
				if widx < all_weapons.size():
					var wd: WeaponBase = all_weapons[widx]
					player.add_weapon(wd)
			# Wyczyść zapisane bronie aby nie duplikować przy kolejnej fali
			gd.pending_weapon_ids.clear()
		
		# Jeśli gracz nie ma broni, daj domyślną (Blaster)
		if player.get_weapon_count() == 0:
			var default_weapon: WeaponBase = WeaponItemsClass.Blaster.new()
			player.add_weapon(default_weapon)
		
		# Restore Items (Passives)
		for item in gd.inventory:
			if item is ItemBase:
				items_collected.append(item)
				if build_system:
					build_system.add_item(item)
		
		_update_player_stats()

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

	# Po każdej fali wróć do GameStartScreen (system jednej fali per sesja)
	get_tree().change_scene_to_file("res://scenes/GameStartScreen.tscn")

func _open_shop() -> void:
	# Sklep nie jest już otwierany automatycznie między falami.
	# Funkcja zachowana do ręcznego dostępu (np. NPC).
	game_state = "shop"
	var shop_items: Array[ItemBase] = []
	if item_manager and wave_manager:
		shop_items = item_manager.get_shop_items(3, wave_manager.current_wave)

	if shop_system:
		shop_system.open_shop(shop_items, build_system, item_manager)
		get_tree().paused = true

func _on_shop_closed() -> void:
	game_state = "playing"
	get_tree().paused = false
	if wave_manager:
		wave_manager.start_next_wave()

func _on_item_purchased(item: ItemBase) -> void:
	if not items_collected.has(item):
		items_collected.append(item)
	
	var gd := get_node_or_null("/root/GameData")
	if gd and not gd.inventory.has(item):
		gd.add_inventory_item(item)
		
	_update_player_stats()

func _update_player_stats() -> void:
	if player and build_system:
		# Podstawowe statystyki
		player.damage = int(10 * build_system.get_stat("damage"))
		player.attack_speed = 1.0 * build_system.get_stat("attack_speed")
		player.move_speed = 300.0 * build_system.get_stat("move_speed")
		player.attack_range = 400.0 * build_system.get_stat("attack_range")
		player.max_health = int(100 * build_system.get_stat("max_health"))
		
		# Dodatkowe statystyki z przedmiotów
		if "projectile_speed" in player:
			player.projectile_speed = 500.0 * build_system.get_stat("projectile_speed")
		if "crit_chance" in player:
			player.crit_chance = build_system.get_stat("crit_chance")
		if "crit_damage" in player:
			player.crit_damage = build_system.get_stat("crit_damage")
		if "pierce" in player:
			player.pierce = int(build_system.get_stat("pierce"))

func _on_all_waves_completed() -> void:
	game_state = "victory"
	victory.emit()
	show_victory()

func _on_game_over() -> void:
	game_state = "game_over"
	game_over.emit()
	show_game_over()

func _on_player_died() -> void:
	# Zapisz do GameData i wróć do GameStartScreen
	var gd := get_node_or_null("/root/GameData")
	if gd:
		gd.current_wave = wave_manager.current_wave if wave_manager else 0
	get_tree().change_scene_to_file("res://scenes/GameStartScreen.tscn")

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

func _create_weapon_from_id(weapon_id: String) -> WeaponBase:
	const WIC := preload("res://Scripts/items/weapon_items.gd")
	var all_weapons: Array = WIC.get_all_weapons()
	for w in all_weapons:
		if w.weapon_name == weapon_id:
			return w
	return null

func show_victory() -> void:
	if end_screen and wave_manager:
		var playtime := Time.get_unix_time_from_system() - game_start_time
		end_screen.show_victory(score, wave_manager.current_wave, items_collected, playtime)
		get_tree().paused = true

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("ui_cancel") or 
		(event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed)):
		_toggle_pause()

func _toggle_pause() -> void:
	if game_state == "game_over" or game_state == "victory":
		return
	
	if get_tree().paused:
		_resume_game()
	else:
		_pause_game()

func _pause_game() -> void:
	var pause_layer := CanvasLayer.new()
	pause_layer.name = "PauseLayer"
	pause_layer.layer = 100
	add_child(pause_layer)

	var bg := ColorRect.new()
	bg.name = "DimBG"
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

func _resume_game() -> void:
	var pause_layer := get_node_or_null("PauseLayer") as CanvasLayer
	if pause_layer:
		# Podmień return_scene w settingsach na nasz overlay
		var gd := get_node_or_null("/root/GameData")
		if gd:
			gd.return_scene = "__overlay__"
		pause_layer.queue_free()
	get_tree().paused = false
