extends Control
## UI statystyk postaci pod klawiszem TAB

@onready var stats_container: VBoxContainer = %StatsContainer
var build_system: Node = null

func _ready() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_focus_next") or (event is InputEventKey and event.keycode == KEY_TAB and event.pressed):
		if visible:
			hide_stats()
		else:
			show_stats()
	
	if visible and event.is_action_pressed("ui_cancel"):
		hide_stats()

func show_stats() -> void:
	if not build_system:
		var main = get_tree().current_scene
		build_system = main.get_node_or_null("BuildSystem")
	
	if not build_system: return
	
	_update_stats_display()
	visible = true
	get_tree().paused = true

func hide_stats() -> void:
	visible = false
	get_tree().paused = false

func _update_stats_display() -> void:
	# Wyczyść stare
	for child in stats_container.get_children():
		child.queue_free()
	
	var stats = build_system.player_stats
	
	# Sformatowane nazwy i ikony (uproszczone)
	var stat_names = {
		"damage": "OBRAŻENIA",
		"attack_speed": "PRĘDKOŚĆ ATAKU",
		"move_speed": "SZYBKOŚĆ RUCHU",
		"max_health": "MAX HP",
		"armor": "PANCERZ",
		"hp_regen": "REGENERACJA",
		"crit_chance": "SZANSA KRYT.",
		"attack_range": "ZASIĘG"
	}
	
	for key in stat_names.keys():
		if stats.has(key):
			var row = HBoxContainer.new()
			row.add_theme_constant_override("separation", 50)
			
			var name_label = Label.new()
			name_label.text = stat_names[key]
			name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			name_label.add_theme_font_size_override("font_size", 24)
			row.add_child(name_label)
			
			var val_label = Label.new()
			var val = stats[key]
			if key in ["damage", "attack_speed", "move_speed", "attack_range"]:
				val_label.text = "x%.2f" % val
			elif key == "crit_chance":
				val_label.text = "%d%%" % int(val * 100)
			else:
				val_label.text = "%.1f" % val
				
			val_label.add_theme_font_size_override("font_size", 24)
			val_label.add_theme_color_override("font_color", Color(0, 1, 1))
			row.add_child(val_label)
			
			stats_container.add_child(row)
