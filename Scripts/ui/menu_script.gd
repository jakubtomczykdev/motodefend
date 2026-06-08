extends Control

const UI_FONT: Font = preload("res://Assets/fonts/VT323-Regular.ttf")

var _identity_overlay: Control
var _start_flow_locked: bool = false

func _ready() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if AudioManager.has_method("play_music"):
		AudioManager.play_music(AudioManager.MUSIC_LOBBY)

func _on_start_button_pressed() -> void:
	if _start_flow_locked:
		return

	get_tree().paused = false
	if AudioManager.has_method("play_sfx"):
		AudioManager.play_sfx("menu_click")

	var gd: Node = get_node_or_null("/root/GameData")
	if gd and not bool(gd.get("identity_trap_seen")):
		gd.set("identity_trap_seen", true)
		if gd.has_method("save_settings"):
			gd.call("save_settings")
		_show_identity_prompt()
		return

	_continue_to_start_hub()

func _on_settings_btn_pressed() -> void:
	if AudioManager.has_method("play_sfx"):
		AudioManager.play_sfx("menu_click")

	var gd: Node = get_node_or_null("/root/GameData")
	if gd:
		gd.set("return_scene", "res://scenes/ui/MainMenu.tscn")

	get_tree().change_scene_to_file("res://scenes/ui/Settings.tscn")

func _on_button_2_pressed() -> void:
	if AudioManager.has_method("play_sfx"):
		AudioManager.play_sfx("menu_click")

	get_tree().quit()

func _continue_to_start_hub() -> void:
	_start_flow_locked = true
	var gd: Node = get_node_or_null("/root/GameData")
	if gd:
		gd.set("play_menu_spawn_intro", true)
	get_tree().change_scene_to_file("res://scenes/world/GameStartScreen.tscn")

func _show_identity_prompt() -> void:
	if _identity_overlay:
		return

	_start_flow_locked = true
	_identity_overlay = _make_overlay(Color(0.0, 0.006, 0.012, 0.88))
	add_child(_identity_overlay)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_identity_overlay.add_child(center)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(760, 430)
	panel.add_theme_stylebox_override("panel", _make_box_style(Color(0.006, 0.014, 0.025, 0.98), Color(0.2, 0.86, 1.0, 0.95), 4))
	center.add_child(panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 30)
	margin.add_theme_constant_override("margin_top", 26)
	margin.add_theme_constant_override("margin_right", 30)
	margin.add_theme_constant_override("margin_bottom", 26)
	panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	margin.add_child(box)

	var title: Label = _make_label("Podaj nam swoje imie i nazwisko", 42, Color(0.72, 0.96, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(title)

	var hint: Label = _make_label("Krotka weryfikacja profilu gracza przed startem symulacji.", 27, Color(0.72, 0.82, 0.9), HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(hint)

	var input: LineEdit = LineEdit.new()
	input.placeholder_text = "np. Jan Kowalski"
	input.custom_minimum_size = Vector2(0, 66)
	input.caret_blink = true
	input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	input.add_theme_font_override("font", UI_FONT)
	input.add_theme_font_size_override("font_size", 32)
	input.add_theme_color_override("font_color", Color(0.9, 0.98, 1.0))
	input.add_theme_color_override("caret_color", Color(0.35, 1.0, 0.72))
	input.add_theme_stylebox_override("normal", _make_box_style(Color(0.012, 0.026, 0.04, 1.0), Color(0.24, 0.78, 1.0, 0.85), 2))
	input.add_theme_stylebox_override("focus", _make_box_style(Color(0.018, 0.038, 0.055, 1.0), Color(0.35, 1.0, 0.72, 1.0), 3))
	box.add_child(input)

	var note: Label = _make_label("Dane posluza do personalizacji raportu po misji.", 25, Color(1.0, 0.82, 0.34), HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(note)

	var spacer: Control = Control.new()
	spacer.custom_minimum_size = Vector2(0, 16)
	box.add_child(spacer)

	var buttons: HBoxContainer = HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 14)
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(buttons)

	var cancel_button: Button = _make_button("Anuluj", Color(0.08, 0.14, 0.18, 1.0), Color(0.34, 0.78, 1.0, 0.9))
	var next_button: Button = _make_button("Dalej", Color(0.10, 0.22, 0.15, 1.0), Color(0.42, 1.0, 0.62, 0.95))
	next_button.disabled = true
	buttons.add_child(cancel_button)
	buttons.add_child(next_button)

	input.text_changed.connect(_on_identity_input_changed.bind(next_button))
	input.text_submitted.connect(_on_identity_text_submitted.bind(input, next_button))
	cancel_button.pressed.connect(_on_identity_cancelled)
	next_button.pressed.connect(_on_identity_submitted.bind(input))
	input.grab_focus()

	_identity_overlay.modulate.a = 0.0
	panel.scale = Vector2(0.94, 0.94)
	var tween: Tween = create_tween()
	tween.parallel().tween_property(_identity_overlay, "modulate:a", 1.0, 0.16)
	tween.parallel().tween_property(panel, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_identity_input_changed(new_text: String, next_button: Button) -> void:
	next_button.disabled = new_text.strip_edges() == ""

func _on_identity_text_submitted(_new_text: String, input: LineEdit, next_button: Button) -> void:
	if not next_button.disabled:
		_on_identity_submitted(input)

func _on_identity_cancelled() -> void:
	if AudioManager.has_method("play_sfx"):
		AudioManager.play_sfx("menu_click")
	_continue_to_start_hub()

func _on_identity_submitted(input: LineEdit) -> void:
	var identity_name: String = input.text.strip_edges()
	if identity_name == "":
		return
	if AudioManager.has_method("play_sfx"):
		AudioManager.play_sfx("menu_click")
	_show_identity_cutscene(identity_name)

func _show_identity_cutscene(identity_name: String) -> void:
	if _identity_overlay:
		_identity_overlay.queue_free()

	_identity_overlay = _make_overlay(Color(0.012, 0.0, 0.006, 0.94))
	add_child(_identity_overlay)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_identity_overlay.add_child(center)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(900, 560)
	panel.add_theme_stylebox_override("panel", _make_box_style(Color(0.025, 0.006, 0.012, 0.98), Color(1.0, 0.24, 0.32, 0.95), 4))
	center.add_child(panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 34)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_right", 34)
	margin.add_theme_constant_override("margin_bottom", 30)
	panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	margin.add_child(box)

	var title: Label = _make_label("ALERT: DANE OSOBOWE PRZECHWYCONE", 43, Color(1.0, 0.32, 0.38), HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(title)

	var trace: Label = _make_label("formularz: " + _redact_identity_name(identity_name), 28, Color(1.0, 0.78, 0.34), HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(trace)

	var body: Label = _make_label("", 30, Color(0.9, 0.96, 1.0), HORIZONTAL_ALIGNMENT_LEFT)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size = Vector2(0, 270)
	box.add_child(body)

	var lesson: Label = _make_label("Wpisane dane nie zostaly zapisane. To byla symulacja pulapki.", 26, Color(0.42, 1.0, 0.72), HORIZONTAL_ALIGNMENT_CENTER)
	lesson.modulate.a = 0.0
	box.add_child(lesson)

	var continue_button: Button = _make_button("Rozumiem", Color(0.10, 0.20, 0.16, 1.0), Color(0.42, 1.0, 0.72, 0.95))
	continue_button.visible = false
	continue_button.pressed.connect(_continue_to_start_hub)
	box.add_child(continue_button)

	_identity_overlay.modulate.a = 0.0
	panel.scale = Vector2(1.04, 1.04)
	var intro: Tween = create_tween()
	intro.parallel().tween_property(_identity_overlay, "modulate:a", 1.0, 0.12)
	intro.parallel().tween_property(panel, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await intro.finished

	await _type_text(body, "To wygladalo jak zwykly formularz. Dla atakujacego imie i nazwisko to jednak punkt zaczepienia.\n\nTakie dane pomagaja dopasowac phishing: wiarygodny mail, podszycie sie pod szkole, firme albo pomoc techniczna, a czasem nawet proby odzyskania konta.\n\nZasada: gdy formularz nie wyjasnia po co potrzebuje danych, wybierz Anuluj i nie karm atakujacego informacjami.", 0.012)

	var reveal: Tween = create_tween()
	reveal.tween_property(lesson, "modulate:a", 1.0, 0.18)
	await reveal.finished
	continue_button.visible = true
	continue_button.grab_focus()

func _type_text(label: Label, text_value: String, delay: float) -> void:
	label.text = ""
	for i in range(text_value.length()):
		label.text += text_value.substr(i, 1)
		await get_tree().create_timer(delay).timeout

func _redact_identity_name(identity_name: String) -> String:
	var cleaned: String = identity_name.strip_edges()
	if cleaned == "":
		return "dane osobowe"
	var parts: PackedStringArray = cleaned.split(" ", false)
	if parts.size() <= 1:
		return parts[0].substr(0, 1) + "..."
	return parts[0].substr(0, 1) + "... " + parts[parts.size() - 1].substr(0, 1) + "..."

func _make_overlay(bg_color: Color) -> Control:
	var overlay: Control = Control.new()
	overlay.name = "IdentityTrapOverlay"
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP

	var bg: ColorRect = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = bg_color
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(bg)
	return overlay

func _make_label(text_value: String, font_size: int, color: Color, alignment: HorizontalAlignment) -> Label:
	var label: Label = Label.new()
	label.text = text_value
	label.add_theme_font_override("font", UI_FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.horizontal_alignment = alignment
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label

func _make_button(text_value: String, bg: Color, border: Color) -> Button:
	var button: Button = Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(220, 64)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_override("font", UI_FONT)
	button.add_theme_font_size_override("font_size", 31)
	button.add_theme_color_override("font_color", Color(0.9, 0.98, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.42, 0.5, 0.56))
	button.add_theme_stylebox_override("normal", _make_box_style(bg, border, 2))
	button.add_theme_stylebox_override("hover", _make_box_style(bg.lightened(0.08), border.lightened(0.12), 3))
	button.add_theme_stylebox_override("pressed", _make_box_style(bg.darkened(0.08), border, 3))
	button.add_theme_stylebox_override("disabled", _make_box_style(Color(0.025, 0.035, 0.045, 0.9), Color(0.18, 0.26, 0.32, 0.8), 2))
	return button

func _make_box_style(bg: Color, border: Color, border_width: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(4)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	return style
