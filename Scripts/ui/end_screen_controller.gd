extends Control
## EndScreenController - cyber HUD styled game over / victory summary.

signal restart_requested
signal menu_requested

var screen_type: String = "game_over"
var final_score: int = 0
var waves_completed: int = 0
var items_collected: Array = []
var time_played: float = 0.0

var _ui_font: Font
var _bg: ColorRect
var _panel: PanelContainer
var _title_label: Label
var _subtitle_label: Label
var _stats_grid: GridContainer
var _diagnosis_label: Label
var _items_container: VBoxContainer
var _restart_button: Button
var _menu_button: Button

func _ready() -> void:
	_ui_font = preload("res://Assets/fonts/VT323-Regular.ttf")
	_build_ui()
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

func _build_ui() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

	mouse_filter = Control.MOUSE_FILTER_STOP

	_bg = ColorRect.new()
	_bg.name = "EndDimBG"
	_bg.color = Color(0.0, 0.008, 0.016, 0.82)
	_bg.mouse_filter = Control.MOUSE_FILTER_STOP
	_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_bg)
	_apply_matrix_background()

	var center := CenterContainer.new()
	center.name = "EndCenter"
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	_panel = PanelContainer.new()
	_panel.name = "EndPanel"
	_panel.custom_minimum_size = Vector2(1040, 680)
	center.add_child(_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 24)
	_panel.add_child(margin)

	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 14)
	margin.add_child(outer)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 18)
	outer.add_child(header)

	var header_text := VBoxContainer.new()
	header_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_text.add_theme_constant_override("separation", 2)
	header.add_child(header_text)

	_title_label = _make_label("", Color(1.0, 0.42, 0.44), 56, HORIZONTAL_ALIGNMENT_LEFT)
	_title_label.custom_minimum_size = Vector2(0, 64)
	header_text.add_child(_title_label)

	_subtitle_label = _make_label("", Color(0.78, 0.88, 0.94), 24, HORIZONTAL_ALIGNMENT_LEFT)
	header_text.add_child(_subtitle_label)

	var status_chip := Label.new()
	status_chip.name = "StatusChip"
	status_chip.text = "RAPORT KOŃCOWY"
	status_chip.custom_minimum_size = Vector2(190, 46)
	status_chip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_chip.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_chip.add_theme_font_override("font", _ui_font)
	status_chip.add_theme_font_size_override("font_size", 24)
	status_chip.add_theme_color_override("font_color", Color(0.35, 0.94, 1.0))
	status_chip.add_theme_stylebox_override("normal", _make_box_style(Color(0.018, 0.035, 0.052, 0.96), Color(0.22, 0.78, 0.98, 0.72), 2))
	header.add_child(status_chip)

	_add_line(outer, Color(0.18, 0.78, 0.98, 0.72))

	_stats_grid = GridContainer.new()
	_stats_grid.columns = 4
	_stats_grid.add_theme_constant_override("h_separation", 12)
	_stats_grid.add_theme_constant_override("v_separation", 10)
	outer.add_child(_stats_grid)

	var columns := HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 16)
	outer.add_child(columns)

	var diagnosis_panel := _make_section("DIAGNOZA SYSTEMU", Vector2(410, 0))
	columns.add_child(diagnosis_panel)
	_diagnosis_label = _make_label("", Color(0.78, 0.86, 0.92), 25, HORIZONTAL_ALIGNMENT_LEFT)
	_diagnosis_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_diagnosis_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_get_section_body(diagnosis_panel).add_child(_diagnosis_label)

	var items_panel := _make_section("ZEBRANE PRZEDMIOTY", Vector2(570, 0))
	items_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(items_panel)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_get_section_body(items_panel).add_child(scroll)

	_items_container = VBoxContainer.new()
	_items_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_items_container.add_theme_constant_override("separation", 8)
	scroll.add_child(_items_container)

	_add_line(outer, Color(0.18, 0.78, 0.98, 0.48))

	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 18)
	outer.add_child(buttons)

	_restart_button = _make_action_button("SPRÓBUJ PONOWNIE", Color(0.35, 0.94, 1.0))
	_restart_button.pressed.connect(_on_restart_pressed)
	buttons.add_child(_restart_button)

	_menu_button = _make_action_button("MENU GŁÓWNE", Color(0.78, 0.86, 0.94))
	_menu_button.pressed.connect(_on_menu_pressed)
	buttons.add_child(_menu_button)

func _setup_screen() -> void:
	var is_game_over := screen_type == "game_over"
	var accent := Color(1.0, 0.32, 0.38) if is_game_over else Color(0.35, 0.94, 1.0)
	var soft_accent := Color(accent.r, accent.g, accent.b, 0.68)

	_panel.add_theme_stylebox_override("panel", _make_panel_style(accent))
	_title_label.text = "SYSTEM PRZEŁAMANY" if is_game_over else "SIEĆ OBRONIONA"
	_title_label.add_theme_color_override("font_color", accent)
	_subtitle_label.text = _get_failure_tip() if is_game_over else "Obrona zakończona powodzeniem. System zachował ciągłość działania."

	for child in _stats_grid.get_children():
		child.queue_free()

	var minutes := int(time_played / 60.0)
	var seconds := int(time_played) % 60
	_add_stat_card("WYNIK", str(final_score), Color(1.0, 0.82, 0.28))
	_add_stat_card("FALE", "%d / 20" % waves_completed, accent)
	_add_stat_card("CZAS", "%d:%02d" % [minutes, seconds], Color(0.78, 0.92, 1.0))
	_add_stat_card("PRZEDMIOTY", "%d" % items_collected.size(), Color(0.42, 1.0, 0.72))

	_diagnosis_label.text = _make_diagnosis_text(is_game_over)
	_display_items(soft_accent)

	_restart_button.text = "SPRÓBUJ PONOWNIE"
	_menu_button.text = "MENU GŁÓWNE"

func _add_stat_card(label_text: String, value_text: String, accent: Color) -> void:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 88)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _make_box_style(Color(0.018, 0.032, 0.05, 0.96), Color(accent.r, accent.g, accent.b, 0.58), 2))
	_stats_grid.add_child(card)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 10)
	card.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	margin.add_child(box)

	var label := _make_label(label_text, Color(0.68, 0.82, 0.9), 21, HORIZONTAL_ALIGNMENT_LEFT)
	box.add_child(label)

	var value := _make_label(value_text, accent, 34, HORIZONTAL_ALIGNMENT_LEFT)
	value.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	value.add_theme_constant_override("shadow_offset_x", 2)
	value.add_theme_constant_override("shadow_offset_y", 2)
	box.add_child(value)

func _display_items(accent: Color) -> void:
	if not _items_container:
		return

	for child in _items_container.get_children():
		child.queue_free()

	if items_collected.is_empty():
		var empty := _make_label("Brak zebranych przedmiotów. Priorytet: przetrwać dłużej i zebrać pierwszy stabilny build.", Color(0.72, 0.84, 0.92), 24, HORIZONTAL_ALIGNMENT_CENTER)
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty.custom_minimum_size = Vector2(0, 96)
		empty.add_theme_stylebox_override("normal", _make_box_style(Color(0.018, 0.032, 0.05, 0.82), accent, 1))
		_items_container.add_child(empty)
		return

	for item in items_collected:
		if item == null:
			continue
		var rarity_color: Color = item.get_rarity_color() if item.has_method("get_rarity_color") else accent
		var row := PanelContainer.new()
		row.custom_minimum_size = Vector2(0, 54)
		row.add_theme_stylebox_override("panel", _make_box_style(Color(0.018, 0.032, 0.05, 0.94), Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.56), 1))
		_items_container.add_child(row)

		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 12)
		margin.add_theme_constant_override("margin_right", 12)
		margin.add_theme_constant_override("margin_top", 6)
		margin.add_theme_constant_override("margin_bottom", 6)
		row.add_child(margin)

		var label := _make_label("%s  |  %s" % [str(item.item_name).to_upper(), str(item.rarity).to_upper()], rarity_color, 24, HORIZONTAL_ALIGNMENT_LEFT)
		margin.add_child(label)

func _get_failure_tip() -> String:
	if waves_completed <= 2:
		return "Obrona padła wcześnie. Skup się na ruchu, unikaniu kontaktu i szybkim zbieraniu pierwszych przedmiotów."
	if waves_completed <= 5:
		return "Sieć została przeciążona w środkowej fazie. Wzmocnij obrażenia i kontroluj dystans od hostów."
	if items_collected.size() < 2:
		return "Za mało przedmiotów w buildzie. W kolejnej próbie priorytetem są stabilne ulepszenia i ekonomia."
	return "Atak przełamał końcową obronę. Sprawdź balans obrażeń, pancerza i regeneracji przed kolejną próbą."

func _make_diagnosis_text(is_game_over: bool) -> String:
	if not is_game_over:
		return "Rdzeń obronny utrzymał działanie. Zebrane przedmioty zachowały ciągłość systemu, a fale zostały odparte."

	var lines := [
		"Status: naruszenie integralności obrony.",
		_get_failure_tip(),
		"Rekomendacja: po restarcie sprawdź statystyki pod TAB i dobierz przedmioty pod typ fali."
	]
	var text := ""
	for line in lines:
		if text != "":
			text += "\n\n"
		text += line
	return text

func _make_section(title_text: String, min_size: Vector2) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = min_size
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _make_box_style(Color(0.012, 0.024, 0.038, 0.94), Color(0.10, 0.55, 0.75, 0.78), 2))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 14)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.name = "SectionBody"
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	var title := _make_label(title_text, Color(0.35, 0.94, 1.0), 29, HORIZONTAL_ALIGNMENT_LEFT)
	box.add_child(title)
	return panel

func _get_section_body(panel: PanelContainer) -> VBoxContainer:
	var margin := panel.get_child(0) as MarginContainer
	return margin.get_child(0) as VBoxContainer

func _make_action_button(text: String, accent: Color) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(245, 56)
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_override("font", _ui_font)
	button.add_theme_font_size_override("font_size", 27)
	button.add_theme_color_override("font_color", Color(0.92, 0.98, 1.0))
	button.add_theme_stylebox_override("normal", _make_button_style(Color(0.04, 0.07, 0.10, 0.96), Color(accent.r, accent.g, accent.b, 0.72)))
	button.add_theme_stylebox_override("hover", _make_button_style(Color(0.07, 0.12, 0.16, 1.0), Color(accent.r, accent.g, accent.b, 1.0)))
	button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.10, 0.20, 0.25, 1.0), Color(accent.r, accent.g, accent.b, 1.0)))
	return button

func _add_line(parent: VBoxContainer, color: Color) -> void:
	var line := ColorRect.new()
	line.custom_minimum_size = Vector2(0, 2)
	line.color = color
	parent.add_child(line)

func _make_label(text: String, color: Color, font_size: int, alignment: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = alignment
	label.add_theme_font_override("font", _ui_font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.82))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	return label

func _make_panel_style(accent: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.008, 0.016, 0.028, 0.98)
	style.border_color = Color(accent.r, accent.g, accent.b, 0.86)
	style.border_width_left = 4
	style.border_width_top = 4
	style.border_width_right = 4
	style.border_width_bottom = 4
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_right = 6
	style.corner_radius_bottom_left = 6
	style.shadow_color = Color(0, 0, 0, 0.72)
	style.shadow_size = 24
	return style

func _make_box_style(bg: Color, border: Color, border_width: int) -> StyleBoxFlat:
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
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

func _make_button_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := _make_box_style(bg, border, 2)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

func _apply_matrix_background() -> void:
	if not _bg:
		return
	var matrix_shader = preload("res://Assets/shaders/matrix.gdshader")
	var shader_mat = ShaderMaterial.new()
	shader_mat.shader = matrix_shader
	shader_mat.set_shader_parameter("icon_tex", preload("res://Assets/sprites/icon_tex.png"))
	shader_mat.set_shader_parameter("speed", 0.035)
	shader_mat.set_shader_parameter("intensity", 0.24)
	_bg.material = shader_mat

func _on_restart_pressed() -> void:
	visible = false
	restart_requested.emit()

func _on_menu_pressed() -> void:
	visible = false
	menu_requested.emit()
