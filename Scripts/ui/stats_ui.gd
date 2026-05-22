extends Control

## StatsUI - wyswietla szczegolowe statystyki gracza pod Tabem.

@onready var stats_container: VBoxContainer = %StatsContainer
@onready var panel: PanelContainer = $Panel
@onready var title_label: Label = $Panel/VBox/Title

var _ui_font: Font
var _refresh_timer: float = 0.0
var _dim_bg: ColorRect

func _ready() -> void:
	_ui_font = preload("res://Assets/fonts/VT323-Regular.ttf")
	_setup_visuals()
	visible = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_focus_next"):
		visible = !visible
		if visible:
			_refresh_timer = 0.0
			_update_stats()

	if visible:
		_refresh_timer -= delta
		if _refresh_timer <= 0.0:
			_refresh_timer = 0.25
			_update_stats()

func _update_stats() -> void:
	if not stats_container:
		return

	for child in stats_container.get_children():
		child.queue_free()

	var main = get_tree().current_scene
	var build_system = main.get_node_or_null("BuildSystem")
	if not build_system:
		return

	var gd = get_node_or_null("/root/GameData")
	var player = main.get_node_or_null("Player")

	_add_summary_row("POZIOM", str(gd.current_level) if gd else "-", Color(0.35, 0.94, 1.0))
	if gd:
		_add_summary_row("XP", "%d / %d" % [gd.experience, gd.experience_to_next_level], Color(0.75, 0.9, 1.0))
	if player and "current_health" in player:
		_add_summary_row("HP", "%d / %d" % [player.current_health, player.max_health], Color(1.0, 0.42, 0.42))

	_add_section_title("WALKA")
	_add_stat_row("Obrazenia", build_system.get_stat("damage"), "x%.2f", Color(1.0, 0.7, 0.35))
	_add_stat_row("Szybkosc ataku", build_system.get_stat("attack_speed"), "x%.2f", Color(0.65, 0.95, 1.0))
	_add_stat_row("Zasieg", build_system.get_stat("attack_range"), "x%.2f", Color(0.6, 0.8, 1.0))
	_add_stat_row("Krytyk", build_system.get_stat("crit_chance") * 100.0, "%.1f%%", Color(1.0, 0.9, 0.45))
	_add_stat_row("Sila krytyka", build_system.get_stat("crit_damage"), "x%.2f", Color(1.0, 0.78, 0.3))
	_add_stat_row("Przebicie", build_system.get_stat("pierce"), "%.0f", Color(0.95, 0.75, 1.0))
	_add_stat_row("Liczba pociskow", build_system.get_stat("projectile_count"), "%.0f", Color(0.62, 0.95, 1.0))
	_add_stat_row("Predkosc pociskow", build_system.get_stat("projectile_speed"), "x%.2f", Color(0.45, 0.78, 1.0))
	_add_stat_row("Obrazenia bossow", build_system.get_stat("boss_damage_bonus") * 100.0, "+%.0f%%", Color(1.0, 0.55, 0.55))

	_add_section_title("OBRONA I RUCH")
	_add_stat_row("Maksymalne HP", build_system.get_stat("max_health"), "%.0f", Color(1.0, 0.42, 0.42))
	_add_stat_row("Pancerz", build_system.get_stat("armor"), "%.0f", Color(0.7, 0.82, 0.92))
	_add_stat_row("Regeneracja", build_system.get_stat("hp_regen"), "%.1f/s", Color(0.42, 1.0, 0.62))
	_add_stat_row("Unik", build_system.get_stat("dodge_chance") * 100.0, "%.1f%%", Color(0.5, 1.0, 0.95))
	_add_stat_row("Redukcja cooldownu", build_system.get_stat("cooldown_reduction") * 100.0, "%.0f%%", Color(0.72, 0.86, 1.0))
	_add_stat_row("Predkosc ruchu", build_system.get_stat("move_speed"), "x%.2f", Color(0.55, 1.0, 0.9))

func _setup_visuals() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_dim_bg = ColorRect.new()
	_dim_bg.name = "StatsDimBG"
	_dim_bg.color = Color(0.0, 0.0, 0.0, 0.38)
	_dim_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dim_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_dim_bg)
	move_child(_dim_bg, 0)

	if panel:
		panel.custom_minimum_size = Vector2(620, 900)
		panel.add_theme_stylebox_override("panel", _make_panel_style())
	if title_label:
		title_label.text = "STATYSTYKI"
		title_label.add_theme_font_override("font", _ui_font)
		title_label.add_theme_font_size_override("font_size", 41)
		title_label.add_theme_color_override("font_color", Color(0.35, 0.94, 1.0))
		title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
		title_label.add_theme_constant_override("shadow_offset_x", 2)
		title_label.add_theme_constant_override("shadow_offset_y", 2)
	if stats_container:
		stats_container.add_theme_constant_override("separation", 6)

func _add_section_title(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", _ui_font)
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color(0.35, 0.94, 1.0))
	label.custom_minimum_size = Vector2(0, 28)
	label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	stats_container.add_child(label)

func _add_summary_row(label_text: String, value_text: String, accent: Color) -> void:
	var row := _add_row_shell(Color(0.04, 0.07, 0.1, 0.92), accent)
	var label := _make_cell_label(label_text, Color(0.72, 0.84, 0.92), 24, HORIZONTAL_ALIGNMENT_LEFT)
	var value := _make_cell_label(value_text, accent, 26, HORIZONTAL_ALIGNMENT_RIGHT)
	value.add_theme_font_override("font", _ui_font)
	row.add_child(label)
	row.add_child(value)

func _add_stat_row(label_text: String, value: float, format_string: String, accent: Color) -> void:
	var row := _add_row_shell(Color(0.025, 0.04, 0.06, 0.88), accent)
	var label := _make_cell_label(label_text, Color(0.78, 0.86, 0.92), 22, HORIZONTAL_ALIGNMENT_LEFT)
	var value_label := _make_cell_label(format_string % value, accent, 23, HORIZONTAL_ALIGNMENT_RIGHT)
	value_label.add_theme_font_override("font", _ui_font)
	row.add_child(label)
	row.add_child(value_label)

func _add_row_shell(bg: Color, border: Color) -> HBoxContainer:
	var panel_row := PanelContainer.new()
	panel_row.custom_minimum_size = Vector2(0, 36)
	panel_row.add_theme_stylebox_override("panel", _make_row_style(bg, border))
	stats_container.add_child(panel_row)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	panel_row.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	margin.add_child(row)
	return row

func _make_cell_label(text: String, color: Color, font_size: int, alignment: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = alignment
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func _make_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.012, 0.022, 0.035, 0.96)
	style.border_color = Color(0.16, 0.72, 0.92, 0.9)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_right = 6
	style.corner_radius_bottom_left = 6
	style.shadow_color = Color(0, 0, 0, 0.55)
	style.shadow_size = 18
	style.content_margin_left = 26
	style.content_margin_right = 26
	style.content_margin_top = 24
	style.content_margin_bottom = 24
	return style

func _make_row_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = Color(border.r, border.g, border.b, 0.42)
	style.border_width_left = 2
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	return style
