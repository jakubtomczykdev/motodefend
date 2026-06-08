extends CanvasLayer

## Retro inventory panel opened with I. Shows player stats and owned items.

var _ui_font: Font
var _root: Control
var _stats_container: VBoxContainer
var _items_container: VBoxContainer
var _items_scroll: ScrollContainer
var _close_button: Button
var _refresh_timer: float = 0.0

func _ready() -> void:
	_ui_font = preload("res://Assets/fonts/VT323-Regular.ttf")
	_build_ui()
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if _is_toggle_event(event):
		_toggle_inventory()
		get_viewport().set_input_as_handled()
	elif visible and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_close_inventory()
		get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	if not visible:
		return
	_refresh_timer -= delta
	if _refresh_timer <= 0.0:
		_refresh_timer = 0.25
		_refresh_stats()

func _is_toggle_event(event: InputEvent) -> bool:
	return event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_I

func _toggle_inventory() -> void:
	visible = not visible
	get_tree().paused = visible
	if visible:
		_refresh_timer = 0.0
		_refresh_content()

func _close_inventory() -> void:
	visible = false
	get_tree().paused = false

func _build_ui() -> void:
	for child in get_children():
		child.queue_free()

	_root = Control.new()
	_root.name = "InventoryRoot"
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_root)

	var dim: ColorRect = ColorRect.new()
	dim.name = "DimBG"
	dim.color = Color(0.0, 0.0, 0.0, 0.62)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.add_child(dim)

	var panel: PanelContainer = PanelContainer.new()
	panel.name = "InventoryPanel"
	panel.custom_minimum_size = Vector2(1180, 720)
	panel.add_theme_stylebox_override("panel", _make_panel_style())
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -590
	panel.offset_top = -360
	panel.offset_right = 590
	panel.offset_bottom = 360
	_root.add_child(panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)

	var outer: VBoxContainer = VBoxContainer.new()
	outer.add_theme_constant_override("separation", 18)
	margin.add_child(outer)

	var header: HBoxContainer = HBoxContainer.new()
	header.add_theme_constant_override("separation", 18)
	outer.add_child(header)

	var title: Label = Label.new()
	title.text = "SYSTEM GRACZA"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_override("font", _ui_font)
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color(0.35, 0.94, 1.0))
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	title.add_theme_constant_override("shadow_offset_x", 3)
	title.add_theme_constant_override("shadow_offset_y", 3)
	header.add_child(title)

	_close_button = Button.new()
	_close_button.text = "I / ESC"
	_close_button.custom_minimum_size = Vector2(150, 46)
	_close_button.focus_mode = Control.FOCUS_NONE
	_close_button.add_theme_font_override("font", _ui_font)
	_close_button.add_theme_font_size_override("font_size", 30)
	_close_button.add_theme_stylebox_override("normal", _make_button_style(Color(0.04, 0.08, 0.11), Color(0.22, 0.8, 1.0)))
	_close_button.add_theme_stylebox_override("hover", _make_button_style(Color(0.08, 0.14, 0.18), Color(0.65, 0.95, 1.0)))
	_close_button.pressed.connect(_close_inventory)
	header.add_child(_close_button)

	var line: ColorRect = ColorRect.new()
	line.custom_minimum_size = Vector2(0, 3)
	line.color = Color(0.35, 0.94, 1.0, 0.75)
	outer.add_child(line)

	var columns: HBoxContainer = HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 24)
	outer.add_child(columns)

	_stats_container = VBoxContainer.new()
	_stats_container.custom_minimum_size = Vector2(430, 0)
	_stats_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_stats_container.add_theme_constant_override("separation", 7)
	columns.add_child(_wrap_section("STATYSTYKI", _stats_container, Vector2(460, 0)))

	_items_scroll = ScrollContainer.new()
	_items_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_items_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_items_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_items_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_items_scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	_items_container = VBoxContainer.new()
	_items_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_items_container.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_items_container.add_theme_constant_override("separation", 8)
	_items_scroll.add_child(_items_container)
	columns.add_child(_wrap_section("PRZEDMIOTY I BRONIE", _items_scroll, Vector2(620, 0)))

func _wrap_section(title_text: String, content: Control, min_size: Vector2) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = min_size
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _make_section_style())

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	margin.add_child(box)

	var label: Label = Label.new()
	label.text = title_text
	label.add_theme_font_override("font", _ui_font)
	label.add_theme_font_size_override("font_size", 34)
	label.add_theme_color_override("font_color", Color(0.35, 0.94, 1.0))
	box.add_child(label)
	box.add_child(content)
	return panel

func _refresh_content() -> void:
	_refresh_stats()
	_refresh_items()

func _refresh_stats() -> void:
	for child in _stats_container.get_children():
		child.queue_free()

	var main: Node = get_tree().current_scene
	var build_system: Node = main.get_node_or_null("BuildSystem") if main else null
	var player: Node = main.get_node_or_null("Player") if main else null
	var gd: Node = get_node_or_null("/root/GameData")
	if not build_system:
		_add_empty_row(_stats_container, "BRAK DANYCH STATYSTYK")
		return

	_add_summary_row("POZIOM", str(gd.current_level) if gd else "-", Color(0.35, 0.94, 1.0))
	if gd:
		_add_summary_row("XP", "%d / %d" % [gd.experience, gd.experience_to_next_level], Color(0.75, 0.9, 1.0))
	if player and "current_health" in player:
		_add_summary_row("HP", "%d / %d" % [player.current_health, player.max_health], Color(1.0, 0.45, 0.45))

	_add_stat_row("OBRAZENIA", build_system.get_stat("damage"), "x%.2f", Color(1.0, 0.7, 0.35))
	_add_stat_row("SZYBKOSC ATAKU", build_system.get_stat("attack_speed"), "x%.2f", Color(0.65, 0.95, 1.0))
	_add_stat_row("ZASIEG", build_system.get_stat("attack_range"), "x%.2f", Color(0.62, 0.8, 1.0))
	_add_stat_row("KRYTYK", build_system.get_stat("crit_chance") * 100.0, "%.1f%%", Color(1.0, 0.9, 0.45))
	_add_stat_row("PANCERZ", build_system.get_stat("armor"), "%.0f", Color(0.75, 0.86, 0.95))
	_add_stat_row("REGENERACJA", build_system.get_stat("hp_regen"), "%.1f/s", Color(0.42, 1.0, 0.62))
	_add_stat_row("UNIK", build_system.get_stat("dodge_chance") * 100.0, "%.1f%%", Color(0.5, 1.0, 0.95))
	_add_stat_row("PREDKOSC", build_system.get_stat("move_speed"), "x%.2f", Color(0.55, 1.0, 0.9))

func _refresh_items() -> void:
	for child in _items_container.get_children():
		child.queue_free()

	var weapons: Array = _collect_active_weapons()
	var items: Array = _collect_passive_items()
	if weapons.is_empty() and items.is_empty():
		_add_empty_row(_items_container, "BRAK ITEMOW I BRONI")
		return

	_add_inventory_section_title("AKTYWNE BRONIE")
	if weapons.is_empty():
		_add_empty_row(_items_container, "BRAK BRONI")
	else:
		for weapon in weapons:
			_add_item_card(weapon)

	_add_inventory_section_title("PRZEDMIOTY")
	if items.is_empty():
		_add_empty_row(_items_container, "BRAK ITEMOW")
	else:
		for item in items:
			_add_item_card(item)

func _collect_active_weapons() -> Array:
	var result: Array = []
	var player: Node = get_tree().get_first_node_in_group("Player")
	if player == null:
		var main: Node = get_tree().current_scene
		player = main.get_node_or_null("Player") if main else null
	if player and player.has_method("get_weapons"):
		for weapon in player.get_weapons():
			if weapon != null:
				result.append(weapon)
	return result

func _collect_passive_items() -> Array:
	var result: Array = []
	var gd: Node = get_node_or_null("/root/GameData")
	if gd and "inventory" in gd:
		for item in gd.inventory:
			if item != null and not (item is WeaponBase):
				result.append(item)
	return result

func _collect_inventory_entries() -> Array:
	var result: Array = []
	for weapon in _collect_active_weapons():
		result.append(weapon)
	for item in _collect_passive_items():
		result.append(item)
	return result

func _add_inventory_section_title(text: String) -> void:
	var label: Label = _make_label(text, Color(0.35, 0.94, 1.0), 26, HORIZONTAL_ALIGNMENT_LEFT)
	label.custom_minimum_size = Vector2(0, 34)
	_items_container.add_child(label)

func _add_summary_row(label_text: String, value_text: String, accent: Color) -> void:
	_add_text_row(_stats_container, label_text, value_text, accent, 29)

func _add_stat_row(label_text: String, value: float, format_string: String, accent: Color) -> void:
	_add_text_row(_stats_container, label_text, format_string % value, accent, 25)

func _add_text_row(parent: VBoxContainer, left_text: String, right_text: String, accent: Color, font_size: int) -> void:
	var row_panel: PanelContainer = PanelContainer.new()
	row_panel.custom_minimum_size = Vector2(0, 38)
	row_panel.add_theme_stylebox_override("panel", _make_row_style(Color(0.025, 0.04, 0.06, 0.92), accent))
	parent.add_child(row_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	row_panel.add_child(margin)

	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	margin.add_child(row)

	var left: Label = _make_label(left_text, Color(0.78, 0.86, 0.92), font_size, HORIZONTAL_ALIGNMENT_LEFT)
	var right: Label = _make_label(right_text, accent, font_size + 1, HORIZONTAL_ALIGNMENT_RIGHT)
	row.add_child(left)
	row.add_child(right)

func _add_item_card(item) -> void:
	var accent: Color = item.get_rarity_color() if item and item.has_method("get_rarity_color") else Color(0.75, 0.84, 0.9)
	var card: PanelContainer = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 92)
	card.add_theme_stylebox_override("panel", _make_row_style(Color(0.018, 0.034, 0.05, 0.94), accent))
	_items_container.add_child(card)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	card.add_child(margin)

	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	margin.add_child(row)

	var icon_bg: PanelContainer = PanelContainer.new()
	icon_bg.custom_minimum_size = Vector2(64, 64)
	icon_bg.add_theme_stylebox_override("panel", _make_row_style(Color(0.02, 0.04, 0.06, 1.0), accent))
	row.add_child(icon_bg)

	var icon: TextureRect = TextureRect.new()
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if item and "icon" in item:
		icon.texture = item.icon
	icon_bg.add_child(icon)

	var text_box: VBoxContainer = VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.add_theme_constant_override("separation", 2)
	row.add_child(text_box)

	var name: Label = _make_label(_get_item_title(item), accent, 29, HORIZONTAL_ALIGNMENT_LEFT)
	text_box.add_child(name)

	var desc: Label = Label.new()
	desc.text = item.description if item and "description" in item else ""
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_font_override("font", _ui_font)
	desc.add_theme_font_size_override("font_size", 21)
	desc.add_theme_color_override("font_color", Color(0.74, 0.82, 0.88))
	text_box.add_child(desc)

	var meta: Label = _make_label(_get_item_meta(item), Color(0.55, 0.95, 1.0), 20, HORIZONTAL_ALIGNMENT_LEFT)
	text_box.add_child(meta)

func _get_item_title(item) -> String:
	if item == null or not "item_name" in item:
		return "NIEZNANY ITEM"
	return str(item.item_name).to_upper()

func _get_item_meta(item) -> String:
	if item == null:
		return ""
	var rarity: String = str(item.rarity).to_upper() if "rarity" in item else "COMMON"
	if item is WeaponBase:
		var weapon: WeaponBase = item as WeaponBase
		return "%s  |  LVL %d  |  DMG %.0f" % [rarity, weapon.weapon_level, weapon.damage]
	return rarity

func _add_empty_row(parent: VBoxContainer, text: String) -> void:
	var label: Label = _make_label(text, Color(0.7, 0.84, 0.9), 28, HORIZONTAL_ALIGNMENT_CENTER)
	label.custom_minimum_size = Vector2(0, 60)
	parent.add_child(label)

func _make_label(text: String, color: Color, font_size: int, alignment: HorizontalAlignment) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = alignment
	label.add_theme_font_override("font", _ui_font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func _make_panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.01, 0.02, 0.032, 0.98)
	style.border_color = Color(0.18, 0.78, 0.98, 0.95)
	style.border_width_left = 4
	style.border_width_top = 4
	style.border_width_right = 4
	style.border_width_bottom = 4
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_right = 6
	style.corner_radius_bottom_left = 6
	style.shadow_color = Color(0, 0, 0, 0.7)
	style.shadow_size = 22
	return style

func _make_section_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.018, 0.032, 0.05, 0.96)
	style.border_color = Color(0.10, 0.55, 0.75, 0.85)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	return style

func _make_button_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = _make_row_style(bg, border)
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	return style

func _make_row_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = Color(border.r, border.g, border.b, 0.58)
	style.border_width_left = 2
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_right = 3
	style.corner_radius_bottom_left = 3
	return style
