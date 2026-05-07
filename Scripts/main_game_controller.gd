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

var game_state: String = "menu" # menu, playing, paused, shop, education, game_over, victory
var score: int = 0
var gold: int = 100
var game_start_time: float = 0.0

# Ta linia teraz zadziała, bo mamy 'class_name ItemBase'
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

	_connect_signals()

	if shop_system: shop_system.visible = false
	if educational_system: educational_system.visible = false

	# Rozpocznij grę automatycznie po załadowaniu sceny
	start_game()

@export var max_game_time: float = 600.0 # 10 minut w sekundach
var game_elapsed_time: float = 0.0

func _process(delta: float) -> void:
	if game_state == "playing" and playtime_label:
		game_elapsed_time += delta
		var remaining: float = max_game_time - game_elapsed_time
		
		if remaining <= 0:
			remaining = 0
			playtime_label.text = "CZAS MINĄŁ!"
			_on_menu_requested()
			return
			
		var minutes: int = int(remaining) / 60
		var seconds: int = int(remaining) % 60
		playtime_label.text = "POZOSTAŁO: %02d:%02d" % [minutes, seconds]

func _connect_signals() -> void:
	if wave_manager:
		wave_manager.wave_started.connect(_on_wave_started)
		wave_manager.wave_ended.connect(_on_wave_ended)
		wave_manager.all_waves_completed.connect(_on_all_waves_completed)
		wave_manager.game_over.connect(_on_game_over)

	if player and player.has_signal("died"):
		player.died.connect(_on_player_died)
		player.health_changed.connect(_on_player_health_changed)

	if shop_system:
		shop_system.item_purchased.connect(_on_item_purchased)
		shop_system.shop_closed.connect(_on_shop_closed)

	if educational_system:
		educational_system.education_completed.connect(_on_education_completed)

	if end_screen:
		end_screen.restart_requested.connect(_on_restart_requested)
		end_screen.menu_requested.connect(_on_menu_requested)

func start_game() -> void:
	if build_system: build_system.clear_build()
	if shop_system: shop_system.add_gold(gold)
	if player and player.has_method("heal"):
		player.heal(player.max_health)
	
	score = 0
	gold = 100
	items_collected.clear()
	game_elapsed_time = 0.0

	if educational_system: 
		game_state = "education_intro"
		educational_system.show_intro()
	else:
		game_state = "playing"
		if wave_manager: wave_manager.start_game()
		
	game_started.emit()

func _on_education_completed() -> void:
	if game_state == "education_intro":
		game_state = "playing"
		get_tree().paused = false
		if wave_manager: wave_manager.start_game()
	elif game_state == "education":
		game_state = "playing"
		get_tree().paused = false

func _on_wave_started(wave_number: int) -> void:
	if educational_system:
		if wave_number == 1:
			game_state = "education"
			educational_system.show_education("worm")
		elif wave_number == 5:
			game_state = "education"
			educational_system.show_education("apt_boss")
		elif wave_number == 6:
			game_state = "education"
			educational_system.show_education("trojan")
		elif wave_number == 11:
			game_state = "education"
			educational_system.show_education("ransomware")
		elif wave_number == 16:
			game_state = "education"
			educational_system.show_education("spyware")

func _on_wave_ended(wave_number: int) -> void:
	var wave_gold := wave_number * 50
	gold += wave_gold
	if shop_system: shop_system.add_gold(wave_gold)
	score += wave_number * 100

	if wave_number < 20:
		_open_shop()

func _open_shop() -> void:
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
	items_collected.append(item)
	_update_player_stats()

func _update_player_stats() -> void:
	if player and build_system:
		player.damage = int(10 * build_system.get_stat("damage"))
		player.attack_speed = 1.0 * build_system.get_stat("attack_speed")
		player.move_speed = 300.0 * build_system.get_stat("move_speed")
		player.attack_range = 400.0 * build_system.get_stat("attack_range")
		player.max_health = int(100 * build_system.get_stat("max_health"))

func _on_all_waves_completed() -> void:
	game_state = "victory"
	victory.emit()
	show_victory()

func _on_game_over() -> void:
	game_state = "game_over"
	game_over.emit()
	show_game_over()

func _on_player_died() -> void:
	game_over.emit()

func _on_player_health_changed(_current: int, _max: int) -> void:
	pass

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
