# Refactored path
extends Node2D
## Główny kontroler gry - integruje wszystkie systemy

const WeaponItemsClass := preload("res://Scripts/entities/weapon_items.gd")

signal game_started
signal game_over
signal victory
signal leveled_up(new_level: int)

var player: CharacterBody2D
var wave_manager: Node
var build_system: Node
var item_manager: Node
var shop_system: Control
var educational_system: Control
var transition_screen: Control
var end_screen: Control
var playtime_label: Label
var health_bar: ProgressBar
var hp_label: Label
var gold_label: Label
var enemies_label: Label
var level_label: Label
var xp_bar: ProgressBar
var level_up_ui: Control
var stats_ui: Control

var _shop_opened_mid_wave: bool = false
var _pending_level_ups: int = 0
var _previous_state: String = ""
var game_state: String = "menu" # menu, playing, paused, shop, education, game_over, victory, transition, leveling
var score: int = 0
## Cached GameData reference for the gold property getter/setter
var _game_data_ref = null

## SINGLE SOURCE OF TRUTH: gold reads/writes ONLY through GameData.gold
var gold: int:
	get:
		if _game_data_ref == null:
			_game_data_ref = get_node_or_null("/root/GameData")
		return _game_data_ref.gold if _game_data_ref else 100
	set(value):
		if _game_data_ref == null:
			_game_data_ref = get_node_or_null("/root/GameData")
		if _game_data_ref:
			_game_data_ref.gold = value

var _last_gold_display: int = -1
var game_start_time: float = 0.0

var items_collected: Array[ItemBase] = []

func gain_xp(amount: int) -> void:
	var gd = get_node_or_null("/root/GameData")
	if not gd: return
	
	gd.experience += amount
	print("[MainGame] Gained %d XP. Total: %d/%d" % [amount, gd.experience, gd.experience_to_next_level])
	
	while gd.experience >= gd.experience_to_next_level:
		gd.experience -= gd.experience_to_next_level
		gd.current_level += 1
		gd.experience_to_next_level = int(gd.experience_to_next_level * BalanceData.XP_GROWTH_FACTOR)
		_pending_level_ups += 1
	
	# Przetwarzaj kolejkę jeśli nie jesteśmy na ekranie końcowym lub w menu
	# Jeśli jesteśmy już w 'leveling', kolejka zostanie przetworzona po wyborze ulepszenia
	var forbidden_states = ["game_over", "victory", "menu", "leveling"]
	if _pending_level_ups > 0 and not (game_state in forbidden_states):
		_process_level_up_queue()

func _process_level_up_queue() -> void:
	if _pending_level_ups <= 0:
		if game_state == "leveling":
			game_state = _previous_state if _previous_state != "" else "playing"
			_previous_state = ""
			if game_state == "playing":
				get_tree().paused = false
		return

	var gd = get_node_or_null("/root/GameData")
	if not gd: return

	_pending_level_ups -= 1
	
	# Update player stats for the new level
	if build_system:
		build_system.recalculate_stats()
	_update_player_stats()
	
	# Heal player slightly on level up (20% max health)
	if player and player.has_method("heal"):
		player.heal(int(player.max_health * 0.2))
	
	leveled_up.emit(gd.current_level)
	_spawn_level_up_effect()
	
	# Pokaż wybór ulepszeń
	if level_up_ui:
		const UpgradeData = preload("res://Scripts/managers/upgrade_data.gd")
		var upgrades = UpgradeData.get_random_upgrades(3)
		
		if game_state != "leveling":
			_previous_state = game_state
		
		game_state = "leveling"
		level_up_ui.show_upgrades(upgrades)

func _on_upgrade_selected(upgrade) -> void:
	if build_system:
		# Jeśli wartość < 1.0, traktuj jako mnożnik (np. 0.15 = +15%)
		# Jeśli >= 1.0, traktuj jako wartość płaską (np. 20.0 = +20 HP)
		if upgrade.value < 1.0:
			build_system.modify_stat(upgrade.stat_name, 1.0 + upgrade.value)
		else:
			build_system.add_stat(upgrade.stat_name, upgrade.value)
		
		build_system.recalculate_stats()
	
	_update_player_stats()
	
	# Po wyborze ulepszenia sprawdź czy są kolejne levele w kolejce
	if _pending_level_ups > 0:
		_process_level_up_queue()
	else:
		# Wracamy do poprzedniego stanu tylko jeśli nikt inny go nie zmienił w międzyczasie
		if game_state == "leveling":
			game_state = _previous_state if _previous_state != "" else "playing"
			_previous_state = ""
			
			# Odpauzuj tylko jeśli wróciliśmy do normalnej rozgrywki
			if game_state == "playing":
				get_tree().paused = false

func _spawn_level_up_effect() -> void:
	if not player: return
	
	var label := Label.new()
	label.text = "LEVEL UP!"
	label.add_theme_font_size_override("font_size", 48)
	label.add_theme_color_override("font_color", Color(0, 1, 1)) # Cyan
	label.global_position = player.global_position + Vector2(-100, -100)
	add_child(label)
	
	var tween = create_tween()
	tween.tween_property(label, "global_position:y", label.global_position.y - 100, 1.0)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(label.queue_free)

func _ready() -> void:
	# Znajdź węzły bezpiecznie
	player = get_node_or_null("Player")
	wave_manager = get_node_or_null("WaveManager")
	build_system = get_node_or_null("BuildSystem")
	item_manager = get_node_or_null("ItemManager")
	shop_system = get_node_or_null("ShopCanvasLayer/ShopScreen")
	educational_system = get_node_or_null("EducationalLayer/EducationalSystem")
	transition_screen = get_node_or_null("TransitionCanvasLayer/TransitionScreen")
	end_screen = get_node_or_null("EndScreenCanvasLayer/EndScreen")
	playtime_label = get_node_or_null("HUD/PlaytimeUI")
	health_bar = get_node_or_null("HUD/HealthBar")
	hp_label = get_node_or_null("HUD/HPLabel")
	gold_label = get_node_or_null("HUD/GoldLabel")
	enemies_label = get_node_or_null("HUD/EnemiesRemainingLabel")
	level_label = get_node_or_null("HUD/LevelLabel")
	xp_bar = get_node_or_null("HUD/XPBar")
	level_up_ui = get_node_or_null("LevelUpLayer/LevelUpUI")
	stats_ui = get_node_or_null("StatsLayer/StatsUI")

	_connect_signals()

	if educational_system: educational_system.visible = false
	if transition_screen: transition_screen.visible = false

	_setup_retro_hud()

	# Rozpocznij grę automatycznie po załadowaniu sceny
	start_game()

func _setup_retro_hud() -> void:
	var hud = get_node_or_null("HUD")
	if not hud: return
	
	var retro_font = preload("res://Assets/fonts/retropix.ttf")
	var custom_theme = Theme.new()
	custom_theme.default_font = retro_font
	custom_theme.default_font_size = 24
	
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.05, 0.05, 0.08, 0.85)
	panel_style.border_width_left = 3
	panel_style.border_width_top = 3
	panel_style.border_width_right = 3
	panel_style.border_width_bottom = 3
	panel_style.border_color = Color(0.2, 0.8, 1.0, 0.8) # Cyberpunk cyan
	panel_style.corner_radius_top_left = 2
	panel_style.corner_radius_top_right = 2
	panel_style.corner_radius_bottom_right = 2
	panel_style.corner_radius_bottom_left = 2
	panel_style.content_margin_left = 15
	panel_style.content_margin_right = 15
	panel_style.content_margin_top = 10
	panel_style.content_margin_bottom = 10
	
	custom_theme.set_stylebox("panel", "PanelContainer", panel_style)
	
	# Usuń stare kontenery (różne warianty nazw)
	for old_name in ["RetroHUDContainer", "LeftHUD", "RightHUD"]:
		var old_node = hud.get_node_or_null(old_name)
		if old_node: old_node.queue_free()
	
	# --- LEWY KONTENER (Statystyki) ---
	var left_margin = MarginContainer.new()
	left_margin.name = "LeftHUD"
	left_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(left_margin)
	left_margin.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT, Control.PRESET_MODE_MINSIZE, 20)
	left_margin.grow_horizontal = Control.GROW_DIRECTION_END
	
	var left_panel = PanelContainer.new()
	left_panel.theme = custom_theme
	left_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	left_margin.add_child(left_panel)
	
	var left_vbox = VBoxContainer.new()
	left_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	left_panel.add_child(left_vbox)
	
	# --- PRAWY KONTENER (Fala/Wrogowie) ---
	var right_margin = MarginContainer.new()
	right_margin.name = "RightHUD"
	right_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(right_margin)
	right_margin.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 20)
	right_margin.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	
	var right_panel = PanelContainer.new()
	right_panel.theme = custom_theme
	right_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	right_margin.add_child(right_panel)
	
	var right_vbox = VBoxContainer.new()
	right_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	right_panel.add_child(right_vbox)
	
	# --- PRZYPISANIE ELEMENTÓW ---
	if hp_label and health_bar:
		if hp_label.get_parent(): hp_label.get_parent().remove_child(hp_label)
		if health_bar.get_parent(): health_bar.get_parent().remove_child(health_bar)
		var hp_box = HBoxContainer.new()
		hp_label.add_theme_font_override("font", retro_font)
		hp_label.add_theme_font_size_override("font_size", 20)
		hp_label.add_theme_color_override("font_color", Color(1, 0.4, 0.4))
		health_bar.custom_minimum_size = Vector2(200, 20)
		health_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var style_bg = StyleBoxFlat.new()
		style_bg.bg_color = Color(0.2, 0.1, 0.1)
		var style_fill = StyleBoxFlat.new()
		style_fill.bg_color = Color(0.8, 0.2, 0.2)
		health_bar.add_theme_stylebox_override("background", style_bg)
		health_bar.add_theme_stylebox_override("fill", style_fill)
		hp_box.add_child(hp_label)
		hp_box.add_child(health_bar)
		left_vbox.add_child(hp_box)
		
	if level_label and xp_bar:
		if level_label.get_parent(): level_label.get_parent().remove_child(level_label)
		if xp_bar.get_parent(): xp_bar.get_parent().remove_child(xp_bar)
		var xp_box = HBoxContainer.new()
		level_label.add_theme_font_override("font", retro_font)
		level_label.add_theme_font_size_override("font_size", 20)
		level_label.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
		xp_bar.custom_minimum_size = Vector2(200, 15)
		xp_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		xp_box.add_child(level_label)
		xp_box.add_child(xp_bar)
		left_vbox.add_child(xp_box)
		
	if gold_label:
		if gold_label.get_parent(): gold_label.get_parent().remove_child(gold_label)
		gold_label.add_theme_font_override("font", retro_font)
		gold_label.add_theme_font_size_override("font_size", 24)
		gold_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
		gold_label.add_theme_color_override("font_shadow_color", Color(0.3, 0.2, 0))
		gold_label.add_theme_constant_override("shadow_offset_x", 2)
		gold_label.add_theme_constant_override("shadow_offset_y", 2)
		left_vbox.add_child(gold_label)
		
	if playtime_label:
		if playtime_label.get_parent(): playtime_label.get_parent().remove_child(playtime_label)
		playtime_label.add_theme_font_override("font", retro_font)
		playtime_label.add_theme_font_size_override("font_size", 28)
		playtime_label.add_theme_color_override("font_color", Color(0.8, 1.0, 0.8))
		playtime_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		right_vbox.add_child(playtime_label)
		
	if enemies_label:
		if enemies_label.get_parent(): enemies_label.get_parent().remove_child(enemies_label)
		enemies_label.add_theme_font_override("font", retro_font)
		enemies_label.add_theme_font_size_override("font_size", 22)
		enemies_label.add_theme_color_override("font_color", Color(0.9, 0.5, 0.5))
		enemies_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		right_vbox.add_child(enemies_label)

func _process(delta: float) -> void:
	var hud = get_node_or_null("HUD")
	if hud:
		hud.visible = (game_state == "playing")

	if game_state == "playing":
		if playtime_label and wave_manager:
			playtime_label.text = "FALA: %d - %02d:%02d" % [wave_manager.current_wave, int(wave_manager.wave_elapsed) / 60, int(wave_manager.wave_elapsed) % 60]
		
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
	
	# Aktualizuj Level i XP
	var gd = get_node_or_null("/root/GameData")
	if gd:
		if level_label:
			level_label.text = "POZIOM: %d" % gd.current_level
		if xp_bar:
			xp_bar.max_value = gd.experience_to_next_level
			xp_bar.value = gd.experience

func _connect_signals() -> void:
	if wave_manager:
		if not wave_manager.wave_started.is_connected(_on_wave_started):
			wave_manager.wave_started.connect(_on_wave_started)
		if not wave_manager.wave_ended.is_connected(_on_wave_ended):
			wave_manager.wave_ended.connect(_on_wave_ended)
		if not wave_manager.all_waves_completed.is_connected(_on_all_waves_completed):
			wave_manager.all_waves_completed.connect(_on_all_waves_completed)
		if not wave_manager.game_over.is_connected(_on_game_over):
			wave_manager.game_over.connect(_on_game_over)

	if player:
		if player.has_signal("died") and not player.died.is_connected(_on_player_died):
			player.died.connect(_on_player_died)
		if player.has_signal("health_changed") and not player.health_changed.is_connected(_on_player_health_changed):
			player.health_changed.connect(_on_player_health_changed)

	if educational_system:
		if not educational_system.education_completed.is_connected(_on_education_completed):
			educational_system.education_completed.connect(_on_education_completed)

	if end_screen:
		if not end_screen.restart_requested.is_connected(_on_restart_requested):
			end_screen.restart_requested.connect(_on_restart_requested)
		if not end_screen.menu_requested.is_connected(_on_menu_requested):
			end_screen.menu_requested.connect(_on_menu_requested)
	
	if shop_system:
		if shop_system.has_signal("item_purchased") and not shop_system.item_purchased.is_connected(_on_item_purchased):
			shop_system.item_purchased.connect(_on_item_purchased)
		if shop_system.has_signal("shop_closed") and not shop_system.shop_closed.is_connected(_on_shop_closed):
			shop_system.shop_closed.connect(_on_shop_closed)

	if transition_screen:
		if not transition_screen.next_wave_requested.is_connected(_on_next_wave_requested):
			transition_screen.next_wave_requested.connect(_on_next_wave_requested)
		if transition_screen.has_signal("shop_requested") and not transition_screen.shop_requested.is_connected(_on_shop_requested):
			transition_screen.shop_requested.connect(_on_shop_requested)
		if not transition_screen.lobby_requested.is_connected(_on_lobby_requested):
			transition_screen.lobby_requested.connect(_on_lobby_requested)
	
	if level_up_ui:
		if not level_up_ui.upgrade_selected.is_connected(_on_upgrade_selected):
			level_up_ui.upgrade_selected.connect(_on_upgrade_selected)

func start_game() -> void:
	var gd := get_node_or_null("/root/GameData")
	print("[MainGame] start_game BEGIN")
	if build_system:
		print("[MainGame] build_system.clear_build()...")
		build_system.clear_build()
		print("[MainGame] build cleared OK")

	# Jeśli GameData nie ma złota (świeża gra) – ustaw domyślne 300 przez setter
	if gd and gd.gold <= 0:
		gold = 300

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
	AudioManager.play_music(AudioManager.MUSIC_BATTLE)
	
	# Jeśli to nowa gra (fala 0/1), zresetuj poziom i XP
	if gd and (gd.current_wave == 0 or wave_manager and wave_manager.current_wave == 0):
		gd.current_level = 1
		gd.experience = 0
		gd.experience_to_next_level = BalanceData.STARTING_XP_REQUIREMENT
		if build_system:
			build_system.recalculate_stats()

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
		
		# Jeśli gracz nie ma broni, daj losową domyślną
		if player.get_weapon_count() == 0:
			var all_weps = WeaponItemsClass.get_all_weapons()
			if all_weps.size() > 0:
				var rng = RandomNumberGenerator.new()
				rng.randomize()
				var default_weapon: WeaponBase = all_weps[rng.randi_range(0, all_weps.size() - 1)]
				player.add_weapon(default_weapon)
		
		# Restore Items (Passives)
		for item in gd.inventory:
			if item is ItemBase:
				items_collected.append(item)
				if build_system:
					build_system.add_item(item)
		
		_update_player_stats()

	game_start_time = Time.get_unix_time_from_system()
	game_started.emit()
	print("[MainGame] start_game END")

func _on_education_completed() -> void:
	if game_state == "education_intro":
		game_state = "playing"
		get_tree().paused = false
		if wave_manager: wave_manager.start_game()
	elif game_state == "education_pre_wave":
		game_state = "playing"
		get_tree().paused = false
		if wave_manager:
			wave_manager.start_next_wave()
	elif game_state == "education":
		game_state = "playing"
		get_tree().paused = false

func _on_wave_started(_wave_number: int) -> void:
	# Nie pauzujemy gry – timer fali leci niezależnie
	pass

func _on_wave_ended(wave_number: int) -> void:
	if game_state != "playing" and game_state != "leveling":
		return

	var gd := get_node_or_null("/root/GameData")
	if gd:
		gd.gold += 10
	score += wave_number * 100

	# Zapisz progresję w GameData
	if gd:
		gd.current_wave = wave_number
		gd.score = score
	
	# Zapisz bronie gracza do GameData przed zmianą sceny
	_save_weapons_to_gamedata(gd)

	# Cleanup lingering animations and projectiles
	_cleanup_battlefield()

	game_state = "transition"
	get_tree().paused = true
	
	if transition_screen:
		transition_screen.show_transition(wave_number, score, gold)

func _on_next_wave_requested() -> void:
	if transition_screen:
		transition_screen.hide_transition()
	
	# Przywróć widoczność broni
	if player and player.weapon_manager:
		if player.weapon_manager.has_method("update_weapon_sprites"):
			player.weapon_manager.update_weapon_sprites()
	
	# Zamiast od razu startować falę - pokaż ekran edukacyjny
	game_state = "education_pre_wave"
	if educational_system and wave_manager:
		educational_system.show_pre_wave_education(wave_manager.current_wave + 1)
	else:
		# Fallback jeśli brak systemu edukacyjnego
		get_tree().paused = false
		game_state = "playing"
		if wave_manager:
			wave_manager.start_next_wave()

func _on_shop_requested() -> void:
	if transition_screen:
		transition_screen.hide_transition()
	_open_shop(false)

func _on_lobby_requested() -> void:
	get_tree().paused = false
	call_deferred("_transition_to_hub")

func _cleanup_battlefield() -> void:
	# Usuń wszystkie pociski
	var projectiles = get_tree().get_nodes_in_group("Projectiles")
	for p in projectiles:
		if is_instance_valid(p):
			p.queue_free()
	
	# Zatrzymaj animacje wrogów i usuń pozostałych wrogów (na wszelki wypadek)
	var enemies = get_tree().get_nodes_in_group("Enemies")
	for e in enemies:
		if is_instance_valid(e):
			e.queue_free()
	
	# Usuń tymczasowe efekty wizualne (np. ColorRecty używane jako iskry/fale)
	# Szukamy ich w scenie głównej - zwykle są dodawane bezpośrednio do current_scene
	for child in get_tree().current_scene.get_children():
		if child is ColorRect and not child.name == "DimBG": # Nie usuwamy tła pauzy
			# Sprawdź czy to nie jest element UI (HUD jest w CanvasLayer, więc ColorRecty w MainGame to efekty)
			child.queue_free()
		elif child is Area2D and ("wave" in child.name.to_lower() or "swing" in child.name.to_lower()):
			child.queue_free()

func _transition_to_hub() -> void:
	# Final safety check
	if not is_inside_tree():
		return
	get_tree().change_scene_to_file("res://scenes/world/GameStartScreen.tscn")

func _save_weapons_to_gamedata(gd) -> void:
	if not gd or not player:
		return
	if not player.has_method("get_weapons"):
		return
	var current_weapons: Array = player.get_weapons()
	if current_weapons.is_empty():
		return
	
	const WIC := preload("res://Scripts/entities/weapon_items.gd")
	var all_weapons: Array[WeaponBase] = WIC.get_all_weapons()
	gd.pending_weapon_ids.clear()
	
	for weapon in current_weapons:
		if weapon == null: continue
		for i in range(all_weapons.size()):
			var candidate = all_weapons[i]
			if candidate == null: continue
			if candidate.item_name == weapon.item_name and candidate.item_type == weapon.item_type:
				gd.pending_weapon_ids.append(i)
				break

func _open_shop(is_mid_wave: bool = false) -> void:
	if game_state == "shop": return
	
	_shop_opened_mid_wave = is_mid_wave
	game_state = "shop"
	
	var shop_items: Array[ItemBase] = []
	if item_manager and wave_manager:
		# Pobierz 4 przedmioty dla nowego układu HFlow
		shop_items = item_manager.get_shop_items(4, wave_manager.current_wave)

	if shop_system:
		get_tree().paused = true
		if shop_system.has_method("open_shop"):
			shop_system.open_shop(shop_items, build_system, item_manager)
		else:
			shop_system.visible = true

func _on_shop_closed() -> void:
	# Małe opóźnienie dla synchronizacji systemów
	await get_tree().process_frame
	
	if _shop_opened_mid_wave:
		game_state = "playing"
		get_tree().paused = false
		_shop_opened_mid_wave = false
	else:
		# Zamiast odpalać od razu falę, przechodzimy przez standardowy przepływ z edukacją i rozpoczęciem kolejnej fali
		_on_next_wave_requested()

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
		player.max_health = int(build_system.get_stat("max_health")) # Use flat value now
		
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
	game_state = "game_over"
	if wave_manager:
		wave_manager.is_wave_active = false
	show_game_over()
	return

func _on_player_health_changed(_current: int, _max: int) -> void:
	var gd := get_node_or_null("/root/GameData")
	if gd:
		gd.player_hp = _current
		gd.player_max_hp = _max

func _restart_from_wave_one() -> void:
	# Wyczyść wrogów
	var enemies := get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	
	# Reset fali do 0 (start_next_wave doda +1 -> fala 1)
	if wave_manager:
		wave_manager.current_wave = 0
		wave_manager.enemies_in_wave = 0
		wave_manager.enemies_remaining = 0
	
	# Przywróć gracza
	if player:
		player.current_health = player.max_health
		player.health_changed.emit(player.current_health, player.max_health)
	# Reset pozycji gracza na środek
	player.global_position = Vector2(960, 540)
	
	# Reset złota do wartości początkowej (setter zapisze do GameData)
	gold = 300
	
	# Ukryj ekran końcowy
	if end_screen:
		end_screen.visible = false
	
	get_tree().paused = false
	game_state = "playing"
	
	# Reset poziomu i XP
	var gd = get_node_or_null("/root/GameData")
	if gd:
		gd.current_level = 1
		gd.experience = 0
		gd.experience_to_next_level = BalanceData.STARTING_XP_REQUIREMENT
		if build_system:
			build_system.recalculate_stats()
		_update_player_stats()

	# Rozpocznij falę 1
	if wave_manager:
		wave_manager.start_next_wave()
	
	# Zresetuj czas gry
	game_start_time = Time.get_unix_time_from_system()

func _on_restart_requested() -> void:
	_restart_from_wave_one()

func _on_menu_requested() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

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

	var settings_scene = load("res://scenes/ui/Settings.tscn")
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
