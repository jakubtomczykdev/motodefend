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

const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(3840, 2160),
	Vector2i(2560, 1440),
	Vector2i(1920, 1080),
	Vector2i(1600, 900),
	Vector2i(1366, 768),
	Vector2i(1280, 720),
	Vector2i(1024, 576),
]

func _ready() -> void:
	# Zapewnij widoczność kursora myszy w menu
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Ustaw filtr myszy na korzeniu
	mouse_filter = Control.MOUSE_FILTER_STOP

	# Ustaw filtr IGNORE na tle, żeby nie blokowało kliknięć
	var bg := get_node_or_null("Background")
	if bg:
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_populate_resolutions()
	_load_current_settings()
	_connect_signals()
	back_button.grab_focus()

	if add_gold_btn:
		add_gold_btn.pressed.connect(_on_add_gold_pressed)
	_update_gold_display()

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
	if gd and gd.return_scene != "":
		var scene: String = gd.return_scene
		gd.return_scene = ""
		get_tree().change_scene_to_file(scene)
	else:
		get_tree().change_scene_to_file("res://MainMenu.tscn")

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
		if gold_input: gold_input.text = ""
		_update_gold_display()

func _update_gold_display() -> void:
	var gd := get_node_or_null("/root/GameData")
	if gd and current_gold_label:
		current_gold_label.text = "Gold: " + str(gd.gold)
