extends Control
## Kontroler ekranów końcowych - Game Over / Victory

signal restart_requested
signal menu_requested

var screen_type: String = "game_over" # game_over, victory
var final_score: int = 0
var waves_completed: int = 0
var items_collected: Array = []
var time_played: float = 0.0

var title_label: Label
var score_label: Label
var waves_label: Label
var time_label: Label
var items_label: Label
var items_container: VBoxContainer
var restart_button: Button
var menu_button: Button

func _ready() -> void:
	# Znajdź węzły bezpiecznie
	if has_node("Panel/VBoxContainer/TitleLabel"):
		title_label = $Panel/VBoxContainer/TitleLabel
	if has_node("Panel/VBoxContainer/StatsContainer/ScoreLabel"):
		score_label = $Panel/VBoxContainer/StatsContainer/ScoreLabel
	if has_node("Panel/VBoxContainer/StatsContainer/WavesLabel"):
		waves_label = $Panel/VBoxContainer/StatsContainer/WavesLabel
	if has_node("Panel/VBoxContainer/StatsContainer/TimeLabel"):
		time_label = $Panel/VBoxContainer/StatsContainer/TimeLabel
	if has_node("Panel/VBoxContainer/StatsContainer/ItemsLabel"):
		items_label = $Panel/VBoxContainer/StatsContainer/ItemsLabel
	if has_node("Panel/VBoxContainer/ItemsContainer"):
		items_container = $Panel/VBoxContainer/ItemsContainer
	if has_node("Panel/VBoxContainer/ButtonContainer/RestartButton"):
		restart_button = $Panel/VBoxContainer/ButtonContainer/RestartButton
		restart_button.pressed.connect(_on_restart_pressed)
	if has_node("Panel/VBoxContainer/ButtonContainer/MenuButton"):
		menu_button = $Panel/VBoxContainer/ButtonContainer/MenuButton
		menu_button.pressed.connect(_on_menu_pressed)

	visible = false

func show_game_over(score: int, waves: int, items: Array, playtime: float) -> void:
	screen_type = "game_over"
	final_score = score
	waves_completed = waves
	items_collected = items
	time_played = playtime

	_setup_screen()
	visible = true

func show_victory(score: int, waves: int, items: Array, playtime: float) -> void:
	screen_type = "victory"
	final_score = score
	waves_completed = waves
	items_collected = items
	time_played = playtime

	_setup_screen()
	visible = true

func _setup_screen() -> void:
	# Ustaw tytuł
	if title_label:
		if screen_type == "game_over":
			title_label.text = "Przegrałeś"
			title_label.modulate = Color(0.9, 0.2, 0.2)
		else:
			title_label.text = "ZWYCIĘSTWO!"
			title_label.modulate = Color(0.278, 0.549, 0.749)

	# Ustaw statystyki
	if score_label:
		score_label.text = "WYNIK: %d" % final_score
	if waves_label:
		waves_label.text = "FALE: %d/20" % waves_completed
	if time_label:
		var minutes := int(time_played / 60.0)
		var seconds := int(time_played) % 60
		time_label.text = "CZAS: %d:%02d" % [minutes, seconds]
	if items_label:
		items_label.text = "ITEMY: %d/6" % items_collected.size()

	# Wyświetl zebrane itemy
	_display_items()

func _display_items() -> void:
	if not items_container:
		return

	# Wyczyść kontener
	for child: Node in items_container.get_children():
		child.queue_free()

	if items_collected.is_empty():
		var no_items_label: Label = Label.new()
		no_items_label.text = "Brak zebranych itemów"
		items_container.add_child(no_items_label)
		return

	for item: ItemBase in items_collected:
		var item_label: Label = Label.new()
		item_label.text = "• %s (%s)" % [item.item_name, item.rarity.capitalize()]
		item_label.modulate = item.get_rarity_color()
		items_container.add_child(item_label)

func _on_restart_pressed() -> void:
	visible = false
	restart_requested.emit()

func _on_menu_pressed() -> void:
	visible = false
	menu_requested.emit()