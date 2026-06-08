extends Control

## LevelUpUI - obsługuje wybór ulepszeń po awansie poziomu.

signal upgrade_selected(upgrade)

@onready var cards_container: HBoxContainer = %CardsContainer
@onready var dim_bg: ColorRect = $DimBG
@onready var layout_box: VBoxContainer = $VBox
@onready var title_label: Label = $VBox/Title

var _ui_font: Font
var _card_normal: StyleBoxFlat
var _card_hover: StyleBoxFlat
var _card_pressed: StyleBoxFlat
var _card_focus: StyleBoxFlat

func _ready() -> void:
	_ui_font = preload("res://Assets/fonts/VT323-Regular.ttf")
	_setup_static_layout()
	visible = false

func show_upgrades(upgrades: Array) -> void:
	visible = true
	get_tree().paused = true

	for child in cards_container.get_children():
		child.queue_free()

	var gd = get_node_or_null("/root/GameData")
	var level_text := "POZIOM %d" % gd.current_level if gd else "NOWY POZIOM"
	title_label.text = "%s  |  WYBIERZ PRZEDMIOT" % level_text

	for i in range(upgrades.size()):
		cards_container.add_child(_create_upgrade_card(upgrades[i], i + 1))

	if cards_container.get_child_count() > 0:
		cards_container.get_child(0).grab_focus()

func _on_upgrade_pressed(upgrade) -> void:
	visible = false
	upgrade_selected.emit(upgrade)

func _setup_static_layout() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	if dim_bg:
		dim_bg.color = Color(0.0, 0.008, 0.016, 0.78)
	if layout_box:
		layout_box.custom_minimum_size = Vector2(1160, 560)
		layout_box.offset_left = -580.0
		layout_box.offset_top = -290.0
		layout_box.offset_right = 580.0
		layout_box.offset_bottom = 290.0
		layout_box.add_theme_constant_override("separation", 20)
	if title_label:
		title_label.add_theme_font_override("font", _ui_font)
		title_label.add_theme_font_size_override("font_size", 38)
		title_label.add_theme_color_override("font_color", Color(0.38, 0.95, 1.0))
		title_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.8))
		title_label.add_theme_constant_override("shadow_offset_x", 3)
		title_label.add_theme_constant_override("shadow_offset_y", 3)
		title_label.custom_minimum_size = Vector2(0, 58)
		title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		title_label.add_theme_stylebox_override("normal", _make_label_box(Color(0.01, 0.025, 0.04, 0.86), Color(0.18, 0.78, 0.98, 0.7), 2))
	if cards_container:
		cards_container.add_theme_constant_override("separation", 22)
		cards_container.alignment = BoxContainer.ALIGNMENT_CENTER

	_card_normal = _make_card_style(Color(0.012, 0.022, 0.035, 0.97), Color(0.18, 0.78, 0.98, 0.72), 2)
	_card_hover = _make_card_style(Color(0.025, 0.045, 0.065, 0.99), Color(0.44, 0.95, 1.0, 0.96), 3)
	_card_pressed = _make_card_style(Color(0.006, 0.015, 0.026, 1.0), Color(0.12, 0.58, 0.82, 0.92), 3)
	_card_focus = _make_card_style(Color(0.025, 0.052, 0.075, 1.0), Color(0.9, 0.98, 1.0, 1.0), 3)

func _create_upgrade_card(upgrade, index: int) -> Button:
	var accent := _get_stat_accent(upgrade.stat_name)
	var card := Button.new()
	card.text = ""
	card.custom_minimum_size = Vector2(340, 390)
	card.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	card.focus_mode = Control.FOCUS_ALL
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.add_theme_stylebox_override("normal", _make_card_style(Color(0.012, 0.022, 0.035, 0.97), Color(accent.r, accent.g, accent.b, 0.64), 2))
	card.add_theme_stylebox_override("hover", _make_card_style(Color(0.025, 0.045, 0.065, 0.99), Color(accent.r, accent.g, accent.b, 0.96), 3))
	card.add_theme_stylebox_override("pressed", _make_card_style(Color(0.006, 0.015, 0.026, 1.0), Color(accent.r, accent.g, accent.b, 0.84), 3))
	card.add_theme_stylebox_override("focus", _make_card_style(Color(0.025, 0.052, 0.075, 1.0), Color(0.9, 0.98, 1.0, 1.0), 3))
	card.pressed.connect(_on_upgrade_pressed.bind(upgrade))

	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_bottom", 20)
	card.add_child(margin)

	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 11)
	margin.add_child(box)

	var header := HBoxContainer.new()
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_theme_constant_override("separation", 10)
	box.add_child(header)

	var slot := Label.new()
	slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.text = "0%d" % index
	slot.custom_minimum_size = Vector2(48, 34)
	slot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	slot.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	slot.add_theme_font_override("font", _ui_font)
	slot.add_theme_font_size_override("font_size", 24)
	slot.add_theme_color_override("font_color", accent)
	slot.add_theme_stylebox_override("normal", _make_label_box(Color(0.018, 0.035, 0.052, 0.95), accent, 1))
	header.add_child(slot)

	var type_label := Label.new()
	type_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	type_label.text = _get_stat_display_name(upgrade.stat_name).to_upper()
	type_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	type_label.add_theme_font_override("font", _ui_font)
	type_label.add_theme_font_size_override("font_size", 20)
	type_label.add_theme_color_override("font_color", Color(0.68, 0.86, 0.94))
	type_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(type_label)

	var name_label := Label.new()
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.text = upgrade.name
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.add_theme_font_override("font", _ui_font)
	name_label.add_theme_font_size_override("font_size", 31)
	name_label.add_theme_color_override("font_color", Color(0.94, 0.99, 1.0))
	name_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.88))
	name_label.add_theme_constant_override("shadow_offset_x", 2)
	name_label.add_theme_constant_override("shadow_offset_y", 2)
	box.add_child(name_label)

	var line := ColorRect.new()
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.custom_minimum_size = Vector2(0, 2)
	line.color = Color(accent.r, accent.g, accent.b, 0.62)
	box.add_child(line)

	var desc := Label.new()
	desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desc.text = upgrade.description
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	desc.add_theme_font_override("font", _ui_font)
	desc.add_theme_font_size_override("font_size", 23)
	desc.add_theme_color_override("font_color", Color(0.76, 0.84, 0.9))
	box.add_child(desc)

	var effect := Label.new()
	effect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effect.text = _format_upgrade_value(upgrade)
	effect.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	effect.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	effect.custom_minimum_size = Vector2(0, 48)
	effect.add_theme_font_override("font", _ui_font)
	effect.add_theme_font_size_override("font_size", 27)
	effect.add_theme_color_override("font_color", accent)
	effect.add_theme_stylebox_override("normal", _make_label_box(Color(0.018, 0.035, 0.052, 0.96), accent, 2))
	box.add_child(effect)

	return card

func _get_stat_accent(stat_name: String) -> Color:
	match stat_name:
		"max_health":
			return Color(1.0, 0.42, 0.44)
		"damage":
			return Color(1.0, 0.72, 0.32)
		"move_speed":
			return Color(0.42, 1.0, 0.86)
		"attack_speed":
			return Color(0.45, 0.86, 1.0)
		"armor":
			return Color(0.74, 0.86, 0.96)
		"hp_regen":
			return Color(0.42, 1.0, 0.62)
		"crit_chance":
			return Color(1.0, 0.86, 0.28)
		"attack_range":
			return Color(0.55, 0.72, 1.0)
		_:
			return Color(0.35, 0.94, 1.0)

func _format_upgrade_value(upgrade) -> String:
	if upgrade.stat_name == "hp_regen":
		return "+%.1f/s %s" % [upgrade.value, _get_stat_display_name(upgrade.stat_name)]
	if upgrade.stat_name in ["crit_chance", "dodge_chance", "cooldown_reduction"]:
		return "+%d%% %s" % [roundi(upgrade.value * 100.0), _get_stat_display_name(upgrade.stat_name)]
	if upgrade.value < 1.0:
		return "+%d%% %s" % [roundi(upgrade.value * 100.0), _get_stat_display_name(upgrade.stat_name)]
	return "+%s %s" % [_format_number(upgrade.value), _get_stat_display_name(upgrade.stat_name)]

func _format_number(value: float) -> String:
	if is_equal_approx(value, roundf(value)):
		return str(int(value))
	return "%.1f" % value

func _get_stat_display_name(stat_name: String) -> String:
	match stat_name:
		"max_health":
			return "HP"
		"damage":
			return "obrazenia"
		"move_speed":
			return "ruch"
		"attack_speed":
			return "szybkosc ataku"
		"armor":
			return "pancerz"
		"hp_regen":
			return "regeneracja"
		"crit_chance":
			return "krytyk"
		"attack_range":
			return "zasieg"
		_:
			return stat_name.replace("_", " ")

func _make_card_style(bg: Color, border: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_right = 6
	style.corner_radius_bottom_left = 6
	style.shadow_color = Color(0, 0, 0, 0.45)
	style.shadow_size = 12
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 18
	style.content_margin_bottom = 18
	return style

func _make_label_box(bg: Color, border: Color, border_width: int) -> StyleBoxFlat:
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
