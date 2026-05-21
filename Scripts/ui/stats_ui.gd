extends Control

## StatsUI – Wyświetla szczegółowe statystyki gracza.

@onready var stats_container: VBoxContainer = %StatsContainer

func _ready() -> void:
	visible = false

func _process(_delta: float) -> void:
	# Przełączanie widoczności statystyk (np. pod Tab)
	if Input.is_action_just_pressed("ui_focus_next"): # Tab domyślnie
		visible = !visible
		if visible:
			_update_stats()

func _update_stats() -> void:
	if not stats_container: return
	
	# Wyczyść poprzednie
	for child in stats_container.get_children():
		child.queue_free()
	
	var main = get_tree().current_scene
	var build_system = main.get_node_or_null("BuildSystem")
	if not build_system: return
	
	var stats = ["damage", "attack_speed", "move_speed", "max_health", "armor", "hp_regen", "crit_chance", "attack_range"]
	
	for stat_name in stats:
		var val = build_system.get_stat(stat_name)
		var label = Label.new()
		
		# Formatowanie wyświetlania
		var display_val = str(val)
		if stat_name in ["damage", "attack_speed", "move_speed", "attack_range"]:
			display_val = "x%.2f" % val
		elif stat_name in ["crit_chance"]:
			display_val = "%.1f%%" % (val * 100.0)
			
		label.text = stat_name.capitalize().replace("_", " ") + ": " + display_val
		stats_container.add_child(label)
