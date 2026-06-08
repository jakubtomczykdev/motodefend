extends Control

signal answer_submitted(is_correct: bool)

@onready var _dim_bg: ColorRect = $DimBG
@onready var _panel: PanelContainer = $Center/Panel
@onready var _topic_label: Label = $Center/Panel/Margin/VBox/TopicLabel
@onready var _title_label: Label = $Center/Panel/Margin/VBox/TitleLabel
@onready var _rules_label: RichTextLabel = $Center/Panel/Margin/VBox/RulesLabel
@onready var _question_label: RichTextLabel = $Center/Panel/Margin/VBox/QuestionLabel
@onready var _answers_box: VBoxContainer = $Center/Panel/Margin/VBox/AnswersBox

var _ui_font: Font
var _correct_index: int = -1
var _locked: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ui_font = preload("res://Assets/fonts/VT323-Regular.ttf")
	_setup_style()
	visible = false

func show_question(topic_name: String, question_data: Dictionary) -> void:
	_locked = false
	_correct_index = int(question_data.get("correct", -1))
	visible = true
	modulate.a = 0.0

	_topic_label.text = "TEMAT FALI: %s" % topic_name.to_upper()
	_title_label.text = "o oł - wpadłeś w kłopoty..."
	_rules_label.text = "[center]Zneutralizowales przeciwnika z quizem. Gra stopuje zegar, a twoja decyzja zmienia tempo rundy.\n[color=#51ff9a]Dobra odpowiedz: -3s do konca fali[/color]   [color=#ff5d6c]Zla odpowiedz: +3s do konca fali[/color][/center]"
	_question_label.text = "[center]%s[/center]" % str(question_data.get("question", "Brak pytania."))

	for child in _answers_box.get_children():
		child.queue_free()

	var answers: Array = question_data.get("answers", [])
	for i in range(answers.size()):
		var button: Button = _make_answer_button(str(answers[i]), i)
		_answers_box.add_child(button)

	var tween: Tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate:a", 1.0, 0.12)

func _submit_answer(index: int) -> void:
	if _locked:
		return
	_locked = true

	var is_correct: bool = index == _correct_index
	for i in range(_answers_box.get_child_count()):
		var button: Button = _answers_box.get_child(i) as Button
		button.disabled = true
		if i == _correct_index:
			button.add_theme_stylebox_override("disabled", _make_box_style(Color(0.02, 0.22, 0.12, 1.0), Color(0.32, 1.0, 0.58, 1.0), 3))
		elif i == index:
			button.add_theme_stylebox_override("disabled", _make_box_style(Color(0.24, 0.04, 0.06, 1.0), Color(1.0, 0.28, 0.36, 1.0), 3))

	var tween: Tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_interval(0.65)
	tween.tween_property(self, "modulate:a", 0.0, 0.12)
	tween.tween_callback(func():
		visible = false
		answer_submitted.emit(is_correct)
	)

func _setup_style() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_dim_bg.color = Color(0.0, 0.006, 0.012, 0.84)

	_panel.custom_minimum_size = Vector2(900, 600)
	_panel.add_theme_stylebox_override("panel", _make_panel_style())

	_topic_label.add_theme_font_override("font", _ui_font)
	_topic_label.add_theme_font_size_override("font_size", 28)
	_topic_label.add_theme_color_override("font_color", Color(0.32, 0.95, 1.0))
	_topic_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	_title_label.add_theme_font_override("font", _ui_font)
	_title_label.add_theme_font_size_override("font_size", 46)
	_title_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.28))
	_title_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	_title_label.add_theme_constant_override("shadow_offset_x", 3)
	_title_label.add_theme_constant_override("shadow_offset_y", 3)
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	_style_rich_label(_rules_label, 27)
	_style_rich_label(_question_label, 34)
	_answers_box.add_theme_constant_override("separation", 12)

func _style_rich_label(label: RichTextLabel, font_size: int) -> void:
	label.bbcode_enabled = true
	label.fit_content = true
	label.scroll_active = false
	label.add_theme_font_override("normal_font", _ui_font)
	label.add_theme_font_size_override("normal_font_size", font_size)
	label.add_theme_color_override("default_color", Color(0.86, 0.94, 1.0))

func _make_answer_button(text_value: String, index: int) -> Button:
	var button: Button = Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(0, 70)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_override("font", _ui_font)
	button.add_theme_font_size_override("font_size", 28)
	button.add_theme_color_override("font_color", Color(0.9, 0.96, 1.0))
	button.add_theme_color_override("font_focus_color", Color.WHITE)
	button.add_theme_stylebox_override("normal", _make_box_style(Color(0.014, 0.028, 0.044, 0.98), Color(0.18, 0.68, 0.92, 0.75), 2))
	button.add_theme_stylebox_override("hover", _make_box_style(Color(0.028, 0.054, 0.08, 1.0), Color(0.38, 0.96, 1.0, 1.0), 3))
	button.add_theme_stylebox_override("pressed", _make_box_style(Color(0.006, 0.016, 0.026, 1.0), Color(0.1, 0.52, 0.78, 1.0), 3))
	button.add_theme_stylebox_override("focus", _make_box_style(Color(0.014, 0.028, 0.044, 0.98), Color(0.18, 0.68, 0.92, 0.75), 2))
	button.pressed.connect(_submit_answer.bind(index))
	return button

func _make_panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.006, 0.014, 0.025, 0.98)
	style.border_color = Color(0.2, 0.86, 1.0, 0.96)
	style.set_border_width_all(4)
	style.set_corner_radius_all(4)
	style.shadow_color = Color(0, 0, 0, 0.72)
	style.shadow_size = 24
	style.content_margin_left = 24
	style.content_margin_right = 24
	style.content_margin_top = 20
	style.content_margin_bottom = 20
	return style

func _make_box_style(bg: Color, border: Color, border_width: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(3)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style
