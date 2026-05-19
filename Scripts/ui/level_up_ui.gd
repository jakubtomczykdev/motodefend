extends Control
## UI wyboru ulepszeń po awansie poziomu

signal upgrade_selected(upgrade)

@onready var cards_container: HBoxContainer = %CardsContainer
var upgrade_card_scene: PackedScene = null # Będziemy tworzyć dynamicznie dla prostoty prototypu

func _ready() -> void:
	visible = false

func show_upgrades(upgrades: Array) -> void:
	# Wyczyść stare karty
	for child in cards_container.get_children():
		child.queue_free()
	
	# Stwórz nowe karty
	for upgrade in upgrades:
		var card = _create_card(upgrade)
		cards_container.add_child(card)
	
	visible = true
	get_tree().paused = true

func _create_card(upgrade) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(300, 450)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.1, 0.95)
	style.border_width_left = 4
	style.border_width_top = 4
	style.border_width_right = 4
	style.border_width_bottom = 4
	style.border_color = Color(0.2, 0.8, 1.0)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_right = 10
	style.corner_radius_bottom_left = 10
	panel.add_theme_stylebox_override("panel", style)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	margin.add_child(vbox)
	
	# Tytuł
	var title = Label.new()
	title.text = upgrade.name
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0, 1, 1))
	vbox.add_child(title)
	
	# Separator
	var sep = HSeparator.new()
	vbox.add_child(sep)
	
	# Opis
	var desc = Label.new()
	desc.text = upgrade.description
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	desc.add_theme_font_size_override("font_size", 20)
	vbox.add_child(desc)
	
	# Przycisk wyboru
	var btn = Button.new()
	btn.text = "WYBIERZ"
	btn.custom_minimum_size = Vector2(0, 60)
	btn.pressed.connect(_on_card_pressed.bind(upgrade))
	
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.1, 0.3, 0.5)
	btn_style.border_width_bottom = 4
	btn_style.border_color = Color(0, 1, 1)
	btn.add_theme_stylebox_override("normal", btn_style)
	
	vbox.add_child(btn)
	
	return panel

func _on_card_pressed(upgrade) -> void:
	visible = false
	get_tree().paused = false
	upgrade_selected.emit(upgrade)
