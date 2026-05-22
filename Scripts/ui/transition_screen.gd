extends Control

## TransitionScreen - ekran przejscia miedzy falami.

signal next_wave_requested
signal shop_requested
signal lobby_requested

@onready var dim_bg: ColorRect = $ColorRect
@onready var panel: Panel = $Panel
@onready var vbox: VBoxContainer = $Panel/VBoxContainer
@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel
@onready var stats_label: Label = $Panel/VBoxContainer/StatsLabel
@onready var buttons_row: HBoxContainer = $Panel/VBoxContainer/HBoxContainer
@onready var next_button: Button = $Panel/VBoxContainer/HBoxContainer/NextButton
@onready var shop_button: Button = $Panel/VBoxContainer/HBoxContainer/ShopButton
@onready var lobby_button: Button = $Panel/VBoxContainer/HBoxContainer/LobbyButton

var _ui_font: Font

func _ready() -> void:
	_ui_font = preload("res://Assets/fonts/VT323-Regular.ttf")
	_setup_pixel_style()
	visible = false
	next_button.pressed.connect(_on_next_pressed)
	shop_button.pressed.connect(_on_shop_pressed)
	lobby_button.pressed.connect(_on_lobby_pressed)

func show_transition(wave: int, score: int, gold: int) -> void:
	if not is_node_ready():
		await ready
	if title_label:
		title_label.text = "FALA %d UKONCZONA" % wave
	if stats_label:
		stats_label.text = "WYNIK  %d\nZLOTO  %d" % [score, gold]
	visible = true
	if next_button:
		next_button.grab_focus()

func hide_transition() -> void:
	visible = false

func _on_next_pressed() -> void:
	AudioManager.play_sfx("menu_click")
	next_wave_requested.emit()

func _on_shop_pressed() -> void:
	AudioManager.play_sfx("menu_click")
	shop_requested.emit()

func _on_lobby_pressed() -> void:
	AudioManager.play_sfx("menu_click")
	lobby_requested.emit()

func _setup_pixel_style() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

	if dim_bg:
		dim_bg.color = Color(0.005, 0.01, 0.018, 0.76)

	if panel:
		panel.custom_minimum_size = Vector2(760, 420)
		panel.offset_left = -380.0
		panel.offset_top = -210.0
		panel.offset_right = 380.0
		panel.offset_bottom = 210.0
		panel.add_theme_stylebox_override("panel", _make_panel_style())

	if vbox:
		vbox.add_theme_constant_override("separation", 24)
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.offset_left = 34.0
		vbox.offset_top = 28.0
		vbox.offset_right = -34.0
		vbox.offset_bottom = -28.0

	if title_label:
		title_label.add_theme_font_override("font", _ui_font)
		title_label.add_theme_font_size_override("font_size", 43)
		title_label.add_theme_color_override("font_color", Color(0.36, 0.95, 1.0))
		title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
		title_label.add_theme_constant_override("shadow_offset_x", 3)
		title_label.add_theme_constant_override("shadow_offset_y", 3)
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	if stats_label:
		stats_label.custom_minimum_size = Vector2(0, 108)
		stats_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		stats_label.add_theme_font_override("font", _ui_font)
		stats_label.add_theme_font_size_override("font_size", 34)
		stats_label.add_theme_color_override("font_color", Color(0.86, 0.94, 1.0))
		stats_label.add_theme_stylebox_override("normal", _make_stats_box_style())

	if buttons_row:
		buttons_row.add_theme_constant_override("separation", 18)
		buttons_row.alignment = BoxContainer.ALIGNMENT_CENTER

	_style_action_button(next_button, "NASTEPNA\nFALA", Color(0.35, 0.94, 1.0))
	_style_action_button(shop_button, "SKLEP", Color(1.0, 0.82, 0.28))
	_style_action_button(lobby_button, "LOBBY", Color(0.72, 0.82, 0.92))

func _style_action_button(button: Button, text_value: String, accent: Color) -> void:
	if not button:
		return

	button.text = text_value
	button.custom_minimum_size = Vector2(205, 78)
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_override("font", _ui_font)
	button.add_theme_font_size_override("font_size", 25)
	button.add_theme_color_override("font_color", Color(0.9, 0.97, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.08, 0.12, 0.16))
	button.add_theme_color_override("font_focus_color", Color(1.0, 1.0, 1.0))
	button.add_theme_stylebox_override("normal", _make_button_style(Color(0.025, 0.045, 0.07, 0.96), accent, 2))
	button.add_theme_stylebox_override("hover", _make_button_style(Color(0.045, 0.075, 0.1, 1.0), accent.lightened(0.15), 3))
	button.add_theme_stylebox_override("pressed", _make_button_style(accent, accent, 3))
	button.add_theme_stylebox_override("focus", _make_button_style(Color(0.04, 0.085, 0.12, 1.0), Color(0.95, 0.98, 1.0), 3))

func _make_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.012, 0.022, 0.035, 0.97)
	style.border_color = Color(0.16, 0.72, 0.92, 0.92)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_right = 5
	style.corner_radius_bottom_left = 5
	style.shadow_color = Color(0, 0, 0, 0.55)
	style.shadow_size = 18
	return style

func _make_stats_box_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.025, 0.04, 0.06, 0.9)
	style.border_color = Color(0.15, 0.63, 0.82, 0.55)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	return style

func _make_button_style(bg: Color, border: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style
