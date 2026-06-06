extends Control

## Ekran ustawień z suwakami głośności, rozdzielczością i opcjami grafiki

@onready var master_slider: HSlider = %MasterSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SfxSlider
@onready var ui_slider: HSlider = %UiSlider

@onready var master_label: Label = %MasterLabel
@onready var music_label: Label = %MusicLabel
@onready var sfx_label: Label = %SfxLabel
@onready var ui_label: Label = %UiLabel

@onready var resolution_dropdown: OptionButton = %ResolutionDropdown
@onready var fullscreen_checkbox: CheckBox = %FullscreenCheckBox
@onready var vsync_checkbox: CheckBox = %VsyncCheckBox

@onready var gold_input: LineEdit = $CenterContainer/VBoxContainer/GoldSection/GoldInput
@onready var add_gold_btn: Button = $CenterContainer/VBoxContainer/GoldSection/AddGoldBtn
@onready var current_gold_label: Label = $CenterContainer/VBoxContainer/GoldSection/CurrentGoldLabel

@onready var apply_button: Button = %ApplyButton
@onready var reset_button: Button = %ResetButton
@onready var back_button: Button = %BackButton
@onready var content_box: VBoxContainer = $CenterContainer/VBoxContainer

const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(3840, 2160),
	Vector2i(2560, 1440),
	Vector2i(1920, 1080),
	Vector2i(1600, 900),
	Vector2i(1366, 768),
	Vector2i(1280, 720),
	Vector2i(1024, 576),
]

var _general_nodes: Array[Control] = []
var _controls_nodes: Array[Control] = []
var _general_tab_button: Button
var _controls_tab_button: Button

func _ready() -> void:
	# Zapewnij widoczność kursora myszy w menu
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Ustaw filtr myszy na korzeniu
	mouse_filter = Control.MOUSE_FILTER_STOP

	# Ustaw filtr IGNORE na tle, żeby nie blokowało kliknięć
	var bg := get_node_or_null("Background")
	if bg:
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_build_section_layout()
	_populate_resolutions()
	_load_current_settings()
	_connect_signals()
	_show_section("general")
	back_button.grab_focus()

	if add_gold_btn:
		add_gold_btn.pressed.connect(_on_add_gold_pressed)
	_update_gold_display()

func _build_section_layout() -> void:
	var center := $CenterContainer
	if not center or not content_box:
		return

	if content_box.get_parent() == center:
		center.remove_child(content_box)

		var layout := HBoxContainer.new()
		layout.name = "SettingsLayout"
		layout.custom_minimum_size = Vector2(1220, 0)
		layout.add_theme_constant_override("separation", 32)
		center.add_child(layout)

		var sidebar := VBoxContainer.new()
		sidebar.name = "SectionMenu"
		sidebar.custom_minimum_size = Vector2(250, 0)
		sidebar.add_theme_constant_override("separation", 14)
		layout.add_child(sidebar)

		var menu_title := Label.new()
		menu_title.text = "MENU"
		menu_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		menu_title.add_theme_font_override("font", preload("res://Assets/fonts/VT323-Regular.ttf"))
		menu_title.add_theme_font_size_override("font_size", 42)
		menu_title.add_theme_color_override("font_color", Color(0.35, 0.94, 1.0))
		sidebar.add_child(menu_title)

		_general_tab_button = _make_section_button("OGOLNE")
		_controls_tab_button = _make_section_button("STEROWANIE")
		sidebar.add_child(_general_tab_button)
		sidebar.add_child(_controls_tab_button)
		_general_tab_button.pressed.connect(_show_section.bind("general"))
		_controls_tab_button.pressed.connect(_show_section.bind("controls"))

		content_box.custom_minimum_size = Vector2(900, 0)
		content_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		layout.add_child(content_box)

	_collect_section_nodes()

func _collect_section_nodes() -> void:
	_general_nodes.clear()
	_controls_nodes.clear()

	for node_name in [
		"AudioLabel", "MasterRow", "MusicRow", "SfxRow", "UiRow",
		"HSeparator2", "VideoLabel", "ResolutionRow", "FullscreenRow",
		"VsyncRow", "HSeparator3", "GoldSection"
	]:
		var node := content_box.get_node_or_null(node_name) as Control
		if node:
			_general_nodes.append(node)

	for node_name in ["HSeparatorControls", "ControlsLabel", "ControlsGrid"]:
		var node := content_box.get_node_or_null(node_name) as Control
		if node:
			_controls_nodes.append(node)

func _make_section_button(text_value: String) -> Button:
	var button := Button.new()
	button.text = text_value
	button.toggle_mode = true
	button.custom_minimum_size = Vector2(230, 62)
	button.add_theme_font_override("font", preload("res://Assets/fonts/VT323-Regular.ttf"))
	button.add_theme_font_size_override("font_size", 36)
	button.add_theme_stylebox_override("normal", _make_tab_style(Color(0.018, 0.032, 0.05), Color(0.10, 0.55, 0.75)))
	button.add_theme_stylebox_override("hover", _make_tab_style(Color(0.035, 0.07, 0.10), Color(0.35, 0.94, 1.0)))
	button.add_theme_stylebox_override("pressed", _make_tab_style(Color(0.06, 0.14, 0.18), Color(1.0, 0.82, 0.28)))
	return button

func _make_tab_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	return style

func _show_section(section: String) -> void:
	var show_general := section == "general"

	for node in _general_nodes:
		node.visible = show_general
	for node in _controls_nodes:
		node.visible = not show_general

	if _general_tab_button:
		_general_tab_button.button_pressed = show_general
	if _controls_tab_button:
		_controls_tab_button.button_pressed = not show_general

func _populate_resolutions() -> void:
	resolution_dropdown.clear()
	for res: Vector2i in RESOLUTIONS:
		resolution_dropdown.add_item("%dx%d" % [res.x, res.y])

func _load_current_settings() -> void:
	var gd := get_node_or_null("/root/GameData")
	if gd == null:
		return

	master_slider.value = gd.master_volume * 100
	music_slider.value = gd.music_volume * 100
	sfx_slider.value = gd.sfx_volume * 100
	ui_slider.value = gd.ui_volume * 100

	var idx := _find_resolution_index(gd.resolution)
	resolution_dropdown.selected = idx

	fullscreen_checkbox.button_pressed = gd.fullscreen
	vsync_checkbox.button_pressed = gd.vsync

	_update_labels()

func _connect_signals() -> void:
	master_slider.value_changed.connect(_on_slider_changed)
	music_slider.value_changed.connect(_on_slider_changed)
	sfx_slider.value_changed.connect(_on_slider_changed)
	ui_slider.value_changed.connect(_on_slider_changed)

	apply_button.pressed.connect(_on_apply_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	back_button.pressed.connect(_on_back_pressed)

func _find_resolution_index(target: Vector2i) -> int:
	for i: int in RESOLUTIONS.size():
		if RESOLUTIONS[i] == target:
			return i
	return RESOLUTIONS.find(Vector2i(1920, 1080))

func _on_slider_changed(_value: float) -> void:
	_update_labels()

func _update_labels() -> void:
	master_label.text = "%d%%" % int(master_slider.value)
	music_label.text = "%d%%" % int(music_slider.value)
	sfx_label.text = "%d%%" % int(sfx_slider.value)
	ui_label.text = "%d%%" % int(ui_slider.value)

func _on_apply_pressed() -> void:
	var gd := get_node_or_null("/root/GameData")
	if gd == null:
		return

	gd.master_volume = master_slider.value / 100.0
	gd.music_volume = music_slider.value / 100.0
	gd.sfx_volume = sfx_slider.value / 100.0
	gd.ui_volume = ui_slider.value / 100.0

	gd.resolution = RESOLUTIONS[resolution_dropdown.selected]
	gd.fullscreen = fullscreen_checkbox.button_pressed
	gd.vsync = vsync_checkbox.button_pressed

	gd.save_settings()
	gd.apply_video_settings()

	var am := get_node_or_null("/root/AudioManager")
	if am:
		am.refresh_volumes()


func _on_reset_pressed() -> void:
	var gd := get_node_or_null("/root/GameData")
	if gd == null:
		return

	gd.reset_to_defaults()

	var am := get_node_or_null("/root/AudioManager")
	if am:
		am.refresh_volumes()

	_load_current_settings()

func _on_back_pressed() -> void:
	if name == "SettingsOverlay":
		get_tree().paused = false
		get_parent().queue_free() # Usuwa PauseLayer
		return

	var gd := get_node_or_null("/root/GameData")
	if gd:
		var target_scene = gd.return_scene
		gd.return_scene = ""
		if target_scene == "" or target_scene.begins_with("__") or not ResourceLoader.exists(target_scene):
			target_scene = "res://scenes/ui/MainMenu.tscn"
		get_tree().change_scene_to_file(target_scene)
	else:
		get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

func _on_add_gold_pressed() -> void:
	var amount_str := gold_input.text.strip_edges() if gold_input else "9999"
	if amount_str.is_empty():
		amount_str = "9999"
	var amount := int(amount_str)
	if amount <= 0:
		amount = 9999
	var gd := get_node_or_null("/root/GameData")
	if gd:
		gd.gold += amount
		print("[Settings] Dodano %d golda. Stan: %d" % [amount, gd.gold])
		if gold_input: gold_input.text = ""
		_update_gold_display()

func _update_gold_display() -> void:
	var gd := get_node_or_null("/root/GameData")
	if gd and current_gold_label:
		current_gold_label.text = "ZŁOTO: %d" % gd.gold
