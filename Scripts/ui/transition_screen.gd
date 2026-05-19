extends Control

signal next_wave_requested
signal lobby_requested
signal shop_requested

@onready var title_label = $Panel/VBoxContainer/TitleLabel
@onready var stats_label = $Panel/VBoxContainer/StatsLabel
@onready var next_button = $Panel/VBoxContainer/HBoxContainer/NextButton
@onready var shop_button = $Panel/VBoxContainer/HBoxContainer/ShopButton
@onready var lobby_button = $Panel/VBoxContainer/HBoxContainer/LobbyButton

func _ready():
	# Podstawowa stylizacja (pixel art style)
	visible = false
	next_button.pressed.connect(_on_next_pressed)
	shop_button.pressed.connect(_on_shop_pressed)
	lobby_button.pressed.connect(_on_lobby_pressed)
	
	_setup_retro_style()

func _setup_retro_style() -> void:
	var retro_font = preload("res://retropix.ttf")
	var theme = Theme.new()
	theme.default_font = retro_font
	theme.default_font_size = 24
	
	# Styl Panelu
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.02, 0.02, 0.05, 0.95)
	panel_style.border_width_left = 4
	panel_style.border_width_top = 4
	panel_style.border_width_right = 4
	panel_style.border_width_bottom = 4
	panel_style.border_color = Color(0.0, 1.0, 0.8) # Jasny turkus/cyan
	panel_style.shadow_color = Color(0, 0.5, 0.4, 0.3)
	panel_style.shadow_size = 10
	panel_style.corner_radius_top_left = 4
	panel_style.corner_radius_top_right = 4
	panel_style.corner_radius_bottom_right = 4
	panel_style.corner_radius_bottom_left = 4
	
	# Styl Przycisku - Normalny
	var btn_normal = StyleBoxFlat.new()
	btn_normal.bg_color = Color(0.1, 0.1, 0.2, 1.0)
	btn_normal.border_width_left = 2
	btn_normal.border_width_top = 2
	btn_normal.border_width_right = 2
	btn_normal.border_width_bottom = 2
	btn_normal.border_color = Color(0.0, 0.8, 0.6)
	btn_normal.content_margin_left = 20
	btn_normal.content_margin_right = 20
	
	# Styl Przycisku - Hover
	var btn_hover = btn_normal.duplicate()
	btn_hover.bg_color = Color(0.2, 0.2, 0.4, 1.0)
	btn_hover.border_color = Color(0.0, 1.0, 0.9)
	
	# Styl Przycisku - Pressed
	var btn_pressed = btn_normal.duplicate()
	btn_pressed.bg_color = Color(0.0, 0.5, 0.4, 1.0)
	btn_pressed.border_color = Color(1.0, 1.0, 1.0)
	
	theme.set_stylebox("panel", "Panel", panel_style)
	theme.set_stylebox("normal", "Button", btn_normal)
	theme.set_stylebox("hover", "Button", btn_hover)
	theme.set_stylebox("pressed", "Button", btn_pressed)
	theme.set_stylebox("focus", "Button", btn_hover) # Focus looks like hover
	
	self.theme = theme
	
	# Dodatkowe poprawki wizualne dla etykiet
	title_label.add_theme_font_size_override("font_size", 48)
	title_label.add_theme_color_override("font_color", Color(0.0, 1.0, 1.0))
	title_label.add_theme_color_override("font_outline_color", Color(0, 0.4, 0.4))
	title_label.add_theme_constant_override("outline_size", 8)
	
	stats_label.add_theme_font_size_override("font_size", 32)
	stats_label.add_theme_color_override("font_color", Color(0.8, 1.0, 0.9))
	
	# Panel w scenie to $Panel (Panel) - upewnijmy się że ma styl
	var panel_node = get_node_or_null("Panel")
	if panel_node:
		panel_node.add_theme_stylebox_override("panel", panel_style)
		
	# Dodaj efekt Matrix do tła
	var bg = get_node_or_null("ColorRect")
	if bg:
		var matrix_shader = preload("res://matrix.gdshader")
		var shader_mat = ShaderMaterial.new()
		shader_mat.shader = matrix_shader
		shader_mat.set_shader_parameter("icon_tex", preload("res://icon_tex.png"))
		shader_mat.set_shader_parameter("speed", 0.1)
		shader_mat.set_shader_parameter("intensity", 0.5)
		bg.material = shader_mat

func show_transition(wave_num: int, score: int, gold: int):
	title_label.text = "FALA %d UKOŃCZONA" % wave_num
	stats_label.text = "WYNIK: %d\nZŁOTO: %d" % [score, gold]
	
	visible = true
	# Animacja wejścia
	modulate.a = 0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	
	# Skupienie na przycisku dla obsługi pada/klawiatury
	next_button.grab_focus()

func hide_transition():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func(): visible = false)

func _on_next_pressed():
	AudioManager.play_sfx("menu_click")
	next_wave_requested.emit()

func _on_shop_pressed():
	AudioManager.play_sfx("menu_click")
	shop_requested.emit()

func _on_lobby_pressed():
	AudioManager.play_sfx("menu_click")
	lobby_requested.emit()
