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
	title_label.text = "%s  |  WYBIERZ MODUL" % level_text

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
		dim_bg.color = Color(0.005, 0.01, 0.018, 0.86)
	if layout_box:
		layout_box.custom_minimum_size = Vector2(1180, 620)
		layout_box.offset_left = -620.0
		layout_box.offset_top = -330.0
		layout_box.offset_right = 620.0
		layout_box.offset_bottom = 330.0
		layout_box.add_theme_constant_override("separation", 28)
	if title_label:
		title_label.add_theme_font_override("font", _ui_font)
		title_label.add_theme_font_size_override("font_size", 41)
		title_label.add_theme_color_override("font_color", Color(0.38, 0.95, 1.0))
		title_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.8))
		title_label.add_theme_constant_override("shadow_offset_x", 3)
		title_label.add_theme_constant_override("shadow_offset_y", 3)
	if cards_container:
		cards_container.add_theme_constant_override("separation", 26)
		cards_container.alignment = BoxContainer.ALIGNMENT_CENTER

	_card_normal = _make_card_style(Color(0.025, 0.045, 0.075, 0.96), Color(0.12, 0.62, 0.82, 0.7), 2)
	_card_hover = _make_card_style(Color(0.035, 0.075, 0.105, 0.98), Color(0.28, 0.9, 1.0, 0.95), 3)
	_card_pressed = _make_card_style(Color(0.01, 0.025, 0.045, 1.0), Color(0.1, 0.5, 0.75, 0.9), 3)
	_card_focus = _make_card_style(Color(0.04, 0.085, 0.12, 1.0), Color(0.9, 0.95, 1.0, 1.0), 3)

func _create_upgrade_card(upgrade, index: int) -> Button:
	var card := Button.new()
	card.text = ""
	card.custom_minimum_size = Vector2(330, 420)
	card.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	card.focus_mode = Control.FOCUS_ALL
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.add_theme_stylebox_override("normal", _card_normal)
	card.add_theme_stylebox_override("hover", _card_hover)
	card.add_theme_stylebox_override("pressed", _card_pressed)
	card.add_theme_stylebox_override("focus", _card_focus)
	card.pressed.connect(_on_upgrade_pressed.bind(upgrade))

	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 22)
	card.add_child(margin)

	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 14)
	margin.add_child(box)

	var header := HBoxContainer.new()
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_theme_constant_override("separation", 10)
	box.add_child(header)

	var slot := Label.new()
	slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.text = "0%d" % index
	slot.custom_minimum_size = Vector2(54, 42)
	slot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	slot.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	slot.add_theme_font_override("font", _ui_font)
	slot.add_theme_font_size_override("font_size", 26)
	slot.add_theme_color_override("font_color", Color(0.03, 0.08, 0.12))
	slot.add_theme_stylebox_override("normal", _make_label_box(Color(0.35, 0.94, 1.0), Color.TRANSPARENT, 0))
	header.add_child(slot)

	var type_label := Label.new()
	type_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	type_label.text = _get_stat_display_name(upgrade.stat_name).to_upper()
	type_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	type_label.add_theme_font_override("font", _ui_font)
	type_label.add_theme_font_size_override("font_size", 22)
	type_label.add_theme_color_override("font_color", Color(0.65, 0.9, 1.0))
	type_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(type_label)

	var name_label := Label.new()
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.text = upgrade.name
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.add_theme_font_override("font", _ui_font)
	name_label.add_theme_font_size_override("font_size", 34)
	name_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	box.add_child(name_label)

	var line := ColorRect.new()
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.custom_minimum_size = Vector2(0, 2)
	line.color = Color(0.2, 0.85, 1.0, 0.65)
	box.add_child(line)

	var desc := Label.new()
	desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desc.text = upgrade.description
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	desc.add_theme_font_size_override("font_size", 24)
	desc.add_theme_color_override("font_color", Color(0.78, 0.86, 0.92))
	box.add_child(desc)

	var effect := Label.new()
	effect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effect.text = _format_upgrade_value(upgrade)
	effect.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	effect.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	effect.custom_minimum_size = Vector2(0, 54)
	effect.add_theme_font_override("font", _ui_font)
	effect.add_theme_font_size_override("font_size", 29)
	effect.add_theme_color_override("font_color", Color(0.02, 0.08, 0.1))
	effect.add_theme_stylebox_override("normal", _make_label_box(Color(0.35, 0.94, 1.0), Color(0.35, 0.94, 1.0), 1))
	box.add_child(effect)

	return card

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
