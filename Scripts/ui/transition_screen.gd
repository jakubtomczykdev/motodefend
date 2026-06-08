extends Control

## TransitionScreen - polished cyber HUD shown between waves.

signal next_wave_requested
signal shop_requested
signal lobby_requested

var _ui_font: Font

var dim_bg: ColorRect
var panel: PanelContainer
var title_label: Label
var subtitle_label: Label
var score_value: Label
var reward_value: Label
var gold_value: Label
var preview_label: Label
var tier_label: Label
var next_button: Button
var shop_button: Button
var lobby_button: Button


func _ready() -> void:
	_ui_font = preload("res://Assets/fonts/VT323-Regular.ttf")
	_build_ui()
	visible = false
	next_button.pressed.connect(_on_next_pressed)
	shop_button.pressed.connect(_on_shop_pressed)
	lobby_button.pressed.connect(_on_lobby_pressed)


func show_transition(wave: int, score: int, gold: int, reward_gold: int = 0, next_wave: int = -1, next_preview: String = "") -> void:
	if not is_node_ready():
		await ready

	title_label.text = "FALA %d UKONCZONA" % wave
	subtitle_label.text = "SEGMENT OBRONY ZABEZPIECZONY"
	score_value.text = str(score)
	reward_value.text = "+%dG" % reward_gold
	gold_value.text = str(gold)

	var preview := next_preview
	if preview == "" and next_wave > 0:
		preview = "Fala %d" % next_wave
	var tier := _extract_tier_label(preview, next_wave, wave)
	preview_label.text = "NASTEPNA: %s" % _clean_preview_text(preview, tier) if preview != "" else "NASTEPNA: OCZEKIWANIE"
	tier_label.text = tier

	visible = true
	next_button.grab_focus()


func hide_transition() -> void:
	visible = false


func _build_ui() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

	mouse_filter = Control.MOUSE_FILTER_STOP

	dim_bg = ColorRect.new()
	dim_bg.name = "DimBackground"
	dim_bg.color = Color(0.0, 0.006, 0.012, 0.34)
	dim_bg.mouse_filter = Control.MOUSE_FILTER_STOP
	dim_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim_bg)

	var center := CenterContainer.new()
	center.name = "TransitionCenter"
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	panel = PanelContainer.new()
	panel.name = "TransitionPanel"
	panel.custom_minimum_size = Vector2(820, 430)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.24, 0.88, 1.0)))
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 22)
	panel.add_child(margin)

	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 14)
	margin.add_child(outer)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 16)
	outer.add_child(header)

	var header_text := VBoxContainer.new()
	header_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_text.add_theme_constant_override("separation", 0)
	header.add_child(header_text)

	title_label = _make_label("FALA UKONCZONA", Color(0.36, 0.96, 1.0), 42, HORIZONTAL_ALIGNMENT_LEFT)
	title_label.custom_minimum_size = Vector2(0, 48)
	header_text.add_child(title_label)

	subtitle_label = _make_label("SEGMENT OBRONY ZABEZPIECZONY", Color(0.70, 0.84, 0.92), 22, HORIZONTAL_ALIGNMENT_LEFT)
	header_text.add_child(subtitle_label)

	_add_line(outer, Color(0.20, 0.86, 1.0, 0.55))

	var stats := GridContainer.new()
	stats.columns = 3
	stats.add_theme_constant_override("h_separation", 12)
	stats.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer.add_child(stats)

	score_value = _add_stat_card(stats, "WYNIK", "0", Color(0.38, 0.96, 1.0))
	reward_value = _add_stat_card(stats, "NAGRODA", "+0G", Color(1.0, 0.82, 0.28))
	gold_value = _add_stat_card(stats, "ZLOTO", "0", Color(0.48, 1.0, 0.70))

	var preview_panel := PanelContainer.new()
	preview_panel.custom_minimum_size = Vector2(0, 70)
	preview_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview_panel.add_theme_stylebox_override("panel", _make_box_style(Color(0.012, 0.028, 0.044, 0.72), Color(0.14, 0.64, 0.84, 0.55), 1))
	outer.add_child(preview_panel)

	var preview_margin := MarginContainer.new()
	preview_margin.add_theme_constant_override("margin_left", 16)
	preview_margin.add_theme_constant_override("margin_top", 10)
	preview_margin.add_theme_constant_override("margin_right", 16)
	preview_margin.add_theme_constant_override("margin_bottom", 10)
	preview_panel.add_child(preview_margin)

	var preview_row := HBoxContainer.new()
	preview_row.add_theme_constant_override("separation", 14)
	preview_margin.add_child(preview_row)

	preview_label = _make_label("NASTEPNA: OCZEKIWANIE", Color(0.88, 0.96, 1.0), 27, HORIZONTAL_ALIGNMENT_LEFT)
	preview_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	preview_row.add_child(preview_label)

	tier_label = _make_label("TIER 1", Color(0.36, 0.96, 1.0), 24, HORIZONTAL_ALIGNMENT_CENTER)
	tier_label.custom_minimum_size = Vector2(108, 0)
	tier_label.add_theme_stylebox_override("normal", _make_box_style(Color(0.025, 0.052, 0.072, 0.72), Color(0.24, 0.88, 1.0, 0.62), 1))
	preview_row.add_child(tier_label)

	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 18)
	outer.add_child(buttons)

	next_button = _make_action_button("NASTEPNA\nFALA", Color(0.36, 0.96, 1.0))
	buttons.add_child(next_button)

	shop_button = _make_action_button("SKLEP", Color(1.0, 0.82, 0.28))
	buttons.add_child(shop_button)

	lobby_button = _make_action_button("LOBBY", Color(0.72, 0.84, 0.94))
	buttons.add_child(lobby_button)


func _add_stat_card(parent: Control, label_text: String, value_text: String, accent: Color) -> Label:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 96)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _make_box_style(Color(0.014, 0.028, 0.044, 0.74), Color(accent.r, accent.g, accent.b, 0.50), 1))
	parent.add_child(card)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 12)
	card.add_child(margin)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 4)
	margin.add_child(box)

	var label := _make_label(label_text, Color(0.68, 0.82, 0.90), 21, HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(label)

	var value := _make_label(value_text, accent, 37, HORIZONTAL_ALIGNMENT_CENTER)
	value.add_theme_constant_override("shadow_offset_x", 2)
	value.add_theme_constant_override("shadow_offset_y", 2)
	box.add_child(value)
	return value


func _make_action_button(text_value: String, accent: Color) -> Button:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(198, 62)
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_override("font", _ui_font)
	button.add_theme_font_size_override("font_size", 25)
	button.add_theme_color_override("font_color", Color(0.92, 0.98, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.02, 0.04, 0.06))
	button.add_theme_stylebox_override("normal", _make_button_style(Color(0.024, 0.044, 0.064, 0.76), Color(accent.r, accent.g, accent.b, 0.62), 1))
	button.add_theme_stylebox_override("hover", _make_button_style(Color(0.045, 0.085, 0.11, 0.92), Color(accent.r, accent.g, accent.b, 0.92), 2))
	button.add_theme_stylebox_override("pressed", _make_button_style(accent, accent, 3))
	button.add_theme_stylebox_override("focus", _make_button_style(Color(0.04, 0.08, 0.11, 0.90), Color(0.96, 0.99, 1.0), 2))
	return button


func _clean_preview_text(preview: String, tier: String) -> String:
	var text := preview.strip_edges()
	text = text.replace("Następna fala:", "")
	text = text.replace("Nastepna fala:", "")
	text = text.replace("NASTEPNA FALA:", "")
	text = text.strip_edges()
	if tier != "":
		text = text.replace("  |  " + tier, "")
		text = text.replace(tier + "  |  ", "")
		text = text.replace(tier, "")
	text = text.strip_edges()
	return text if text != "" else "OCZEKIWANIE"


func _extract_tier_label(preview: String, next_wave: int, wave: int) -> String:
	for part in preview.split("|"):
		var value := part.strip_edges().to_upper()
		if value.begins_with("TIER"):
			return value
	return "TIER %d" % max(1, int(ceil(float(max(next_wave, wave + 1)) / 5.0)))


func _make_label(text_value: String, color: Color, font_size: int, alignment: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = text_value
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = alignment
	label.add_theme_font_override("font", _ui_font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	return label


func _add_line(parent: VBoxContainer, color: Color) -> void:
	var line := ColorRect.new()
	line.custom_minimum_size = Vector2(0, 2)
	line.color = color
	parent.add_child(line)


func _make_panel_style(accent: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.006, 0.014, 0.024, 0.84)
	style.border_color = Color(accent.r, accent.g, accent.b, 0.70)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_right = 5
	style.corner_radius_bottom_left = 5
	style.shadow_color = Color(0, 0, 0, 0.45)
	style.shadow_size = 14
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


func _make_button_style(bg: Color, border: Color, border_width: int) -> StyleBoxFlat:
	var style := _make_box_style(bg, border, border_width)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style


func _on_next_pressed() -> void:
	AudioManager.play_sfx("menu_click")
	next_wave_requested.emit()


func _on_shop_pressed() -> void:
	AudioManager.play_sfx("menu_click")
	shop_requested.emit()


func _on_lobby_pressed() -> void:
	AudioManager.play_sfx("menu_click")
	lobby_requested.emit()
