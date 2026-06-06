extends Node2D
## GameStartHub – ekran startowego huba.
## Wyświetla falę i złoto z GameData. Obsługuje start gry, bestiariusz i pauzę.

@onready var wave_label: Label = $WaveLabel if has_node("WaveLabel") else null
@onready var gold_label: Label = $CanvasLayer/GoldLabel if has_node("CanvasLayer") and $CanvasLayer.has_node("GoldLabel") else null
@onready var player: Node2D = $Player if has_node("Player") else null

func _ready() -> void:
	get_tree().paused = false
	_update_wave_display()
	_update_gold_display()
	AudioManager.play_music(AudioManager.MUSIC_LOBBY)
	var gd := get_node_or_null("/root/GameData")
	if gd and gd.play_menu_spawn_intro:
		gd.play_menu_spawn_intro = false
		call_deferred("_play_menu_spawn_intro")

func _process(_delta: float) -> void:
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
		gold_label.text = "ZŁOTO: %d" % gold

func _on_start_game_button_pressed() -> void:
	get_tree().paused = false
	AudioManager.play_sfx("menu_click")
	get_tree().change_scene_to_file("res://scenes/game/MainGame.tscn")

func _play_menu_spawn_intro() -> void:
	if not player:
		return

	var original_visible: bool = player.visible
	var original_process: bool = player.is_processing()
	var original_physics_process: bool = player.is_physics_processing()
	player.visible = false
	player.set_process(false)
	player.set_physics_process(false)

	var layer: CanvasLayer = _create_spawn_intro_overlay()
	var spawn_position: Vector2 = player.global_position
	await _play_spawn_code_rain(spawn_position)
	await get_tree().create_timer(0.12).timeout

	player.visible = original_visible
	player.modulate = Color(0.35, 1.0, 1.0, 0.0)
	player.scale = Vector2(0.65, 0.65)
	_spawn_intro_flash(spawn_position)

	var tween: Tween = create_tween()
	tween.tween_property(player, "modulate:a", 1.0, 0.25)
	tween.parallel().tween_property(player, "scale", Vector2(1.08, 0.94), 0.18)
	tween.tween_property(player, "scale", Vector2.ONE, 0.16)
	tween.parallel().tween_property(player, "modulate", Color.WHITE, 0.16)
	await tween.finished

	player.set_process(original_process)
	player.set_physics_process(original_physics_process)

	if is_instance_valid(layer):
		var root: CanvasItem = layer.get_child(0) as CanvasItem
		var fade: Tween = create_tween()
		if root:
			fade.tween_property(root, "modulate:a", 0.0, 0.3)
		fade.tween_callback(layer.queue_free)
		await fade.finished

func _create_spawn_intro_overlay() -> CanvasLayer:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.name = "MenuSpawnIntroLayer"
	layer.layer = 30
	add_child(layer)

	var root: Control = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(root)

	var bg: ColorRect = ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 0.24)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)

	var font: Font = preload("res://Assets/fonts/VT323-Regular.ttf")
	var status: Label = Label.new()
	status.text = "AVATAR.EXE"
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.add_theme_font_override("font", font)
	status.add_theme_font_size_override("font_size", 42)
	status.add_theme_color_override("font_color", Color(0.45, 1.0, 0.92, 0.88))
	status.set_anchors_preset(Control.PRESET_CENTER_TOP)
	status.offset_left = -140
	status.offset_top = 48
	status.offset_right = 140
	status.offset_bottom = 100
	root.add_child(status)

	var blink: Tween = create_tween()
	blink.set_loops(6)
	blink.tween_property(status, "modulate:a", 0.42, 0.18)
	blink.tween_property(status, "modulate:a", 1.0, 0.18)
	return layer

func _play_spawn_code_rain(spawn_position: Vector2) -> void:
	var colors: Array[Color] = [Color(0.35, 0.94, 1.0), Color(1.0, 0.86, 0.28), Color(0.55, 1.0, 0.72), Color(0.95, 0.98, 1.0)]
	var fragments: Array[String] = ["01", "10", "RUN", "SYNC", "0x", "AI", "CPU", "LOAD"]
	var font: Font = preload("res://Assets/fonts/VT323-Regular.ttf")

	for stream_index in range(14):
		var stream: Label = Label.new()
		stream.text = _make_spawn_code_stream(stream_index)
		stream.add_theme_font_override("font", font)
		stream.add_theme_font_size_override("font_size", 29)
		stream.add_theme_color_override("font_color", colors[stream_index % colors.size()])
		stream.modulate.a = 0.78
		stream.z_index = 80
		stream.global_position = spawn_position + Vector2(randf_range(-460.0, 460.0), randf_range(-720.0, -440.0))
		add_child(stream)

		var stream_target: Vector2 = spawn_position + Vector2(randf_range(-38.0, 38.0), randf_range(-88.0, -18.0))
		var stream_tween: Tween = create_tween()
		stream_tween.tween_property(stream, "global_position", stream_target, 0.78 + float(stream_index % 5) * 0.045).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		stream_tween.parallel().tween_property(stream, "modulate:a", 0.0, 0.28).set_delay(0.62)
		stream_tween.tween_callback(stream.queue_free)

	for i in range(52):
		var bit: Label = Label.new()
		bit.text = fragments[i % fragments.size()]
		bit.add_theme_font_override("font", font)
		bit.add_theme_font_size_override("font_size", 25 + (i % 4) * 2)
		bit.add_theme_color_override("font_color", colors[i % colors.size()])
		bit.modulate.a = 0.9
		bit.z_index = 90
		bit.global_position = spawn_position + Vector2(randf_range(-420.0, 420.0), randf_range(-760.0, -360.0))
		add_child(bit)

		var target_offset: Vector2 = Vector2(randf_range(-20.0, 20.0), randf_range(-58.0, 18.0))
		var tween: Tween = create_tween()
		tween.tween_property(bit, "global_position", spawn_position + target_offset, 0.58 + float(i % 9) * 0.038).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.parallel().tween_property(bit, "scale", Vector2(0.35, 0.35), 0.22).set_delay(0.56)
		tween.parallel().tween_property(bit, "modulate:a", 0.0, 0.2).set_delay(0.62)
		tween.tween_callback(bit.queue_free)

	for scan_index in range(7):
		var scan: ColorRect = ColorRect.new()
		scan.color = Color(0.9, 1.0, 1.0, 0.32)
		scan.size = Vector2(90.0 - scan_index * 6.0, 3.0)
		scan.pivot_offset = scan.size / 2.0
		scan.global_position = spawn_position + Vector2(-scan.size.x / 2.0, -72.0 + scan_index * 18.0)
		scan.z_index = 92
		add_child(scan)
		var scan_tween: Tween = create_tween()
		scan_tween.tween_property(scan, "scale:x", 0.2, 0.34).set_delay(0.5 + scan_index * 0.035)
		scan_tween.parallel().tween_property(scan, "modulate:a", 0.0, 0.34).set_delay(0.5 + scan_index * 0.035)
		scan_tween.tween_callback(scan.queue_free)

	await get_tree().create_timer(1.1).timeout

func _make_spawn_code_stream(seed: int) -> String:
	var stream: String = ""
	for row in range(6):
		var value: int = (seed * 17 + row * 11) % 255
		stream += "%02X%s\n" % [value, "01" if row % 2 == 0 else "10"]
	return stream.strip_edges()

func _spawn_intro_flash(spawn_position: Vector2) -> void:
	for i in range(4):
		var ring: ColorRect = ColorRect.new()
		ring.color = Color(0.35, 0.94, 1.0, 0.38 - i * 0.06)
		ring.size = Vector2(36 + i * 24, 4)
		ring.pivot_offset = ring.size / 2.0
		ring.global_position = spawn_position - ring.pivot_offset + Vector2(0, -8 + i * 8)
		ring.z_index = 86
		add_child(ring)
		var tween: Tween = create_tween()
		tween.tween_property(ring, "scale:x", 2.2, 0.35)
		tween.parallel().tween_property(ring, "modulate:a", 0.0, 0.35)
		tween.tween_callback(ring.queue_free)

func _on_bestiary_button_pressed() -> void:
	AudioManager.play_sfx("menu_click")
	var bestiary_scene = preload("res://scenes/ui/BestiaryUI.tscn")
	var ui = bestiary_scene.instantiate()
	get_tree().root.add_child(ui)
	ui.open_bestiary()

func _open_shop() -> void:
	if has_node("ShopCanvasLayer"):
		return
	var shop_layer = CanvasLayer.new()
	shop_layer.name = "ShopCanvasLayer"
	shop_layer.layer = 50
	add_child(shop_layer)
	
	var shop_scene = load("res://scenes/ui/Shop.tscn")
	var shop = shop_scene.instantiate()
	shop.name = "ShopScreen"
	shop_layer.add_child(shop)
	
	# Pobierz przedmioty dla sklepu (4 losowe dla huba)
	var item_manager = get_node_or_null("ItemManager")
	if not item_manager:
		item_manager = get_node_or_null("/root/ItemManager")
	var items: Array[ItemBase] = []
	var gd := get_node_or_null("/root/GameData")
	var shop_wave := 1
	if gd:
		shop_wave = max(gd.current_wave + 1, 1)
	if item_manager:
		items = item_manager.get_shop_items(4, shop_wave)
	
	# Otwórz sklep - przekaż null dla build_system w hubie (shop_screen obsłuży to przez GameData)
	if shop.has_method("open_shop"):
		shop.open_shop(items, null, item_manager, shop_wave)
	
	shop.shop_closed.connect(_on_shop_closed)
	get_tree().paused = true

func _on_shop_closed() -> void:
	get_tree().paused = false
	if has_node("ShopCanvasLayer"):
		get_node("ShopCanvasLayer").queue_free()

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
	
	var settings_scene = load("res://scenes/ui/Settings.tscn")
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
