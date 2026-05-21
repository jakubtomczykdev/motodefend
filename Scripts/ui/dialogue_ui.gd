extends CanvasLayer
## DialogueUI – Cyberpunk dialogue system with typewriter effect.
## Displays speaker name, character-by-character text reveal, and portrait.
## Connected signals: none in .tscn (input-driven via _unhandled_input).

signal dialogue_finished

# --- Node references ---
@onready var _name_label: Label = %NameLabel
@onready var _dialogue_label: RichTextLabel = %DialogueLabel
@onready var _next_indicator: Label = %NextIndicator
@onready var _dialog_box: Panel = $Control/DialogBox
@onready var _portrait_sprite: Sprite2D = $CybersecuritySpecialist

# --- State ---
var _lines: Array[String] = []
var _current_line_index: int = 0
var _full_text: String = ""
var _revealed_count: int = 0
var _is_typing: bool = false
var _typing_timer: float = 0.0
var _chars_per_second: float = 50.0  ## Typing speed
var _blink_timer: float = 0.0
var _blink_visible: bool = true
var _portrait_texture: Texture2D = null
var _speaker_name: String = ""


func _ready() -> void:
	# Initially hidden
	hide_all()
	# Ensure we process unhandled input for click/key advancement
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(delta: float) -> void:
	if not visible:
		return

	# Typewriter effect
	if _is_typing:
		_typing_timer += delta
		var chars_to_reveal: int = int(_typing_timer * _chars_per_second)
		if chars_to_reveal > 0:
			_typing_timer = 0.0
			_revealed_count = mini(_revealed_count + chars_to_reveal, _full_text.length())
			_update_displayed_text()
			if _revealed_count >= _full_text.length():
				_finish_typing()

	# NextIndicator blink when text is fully revealed
	if not _is_typing and _next_indicator.visible:
		_blink_timer += delta
		if _blink_timer >= 0.5:
			_blink_timer = 0.0
			_blink_visible = not _blink_visible
			_next_indicator.modulate.a = 1.0 if _blink_visible else 0.2


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		get_viewport().set_input_as_handled()
		_advance_dialogue()


func hide_all() -> void:
	visible = false
	if _dialog_box:
		_dialog_box.visible = false
	if _next_indicator:
		_next_indicator.visible = false
	if _portrait_sprite:
		_portrait_sprite.visible = false
	_is_typing = false


## Called by npc_expert.gd with multiple lines and portrait
func start_dialogue(speaker_name: String, portrait: Texture2D, lines: Array[String]) -> void:
	hide_all()
	_speaker_name = speaker_name
	_portrait_texture = portrait
	_lines = lines.duplicate()
	_current_line_index = 0

	# Show UI
	visible = true
	if _dialog_box:
		_dialog_box.visible = true
	if _portrait_sprite:
		_portrait_sprite.visible = true
		if _portrait_texture:
			_portrait_sprite.texture = _portrait_texture

	if _name_label:
		_name_label.text = _speaker_name

	_show_current_line()


## Simple single-line dialogue (compatibility fallback)
func show_dialogue(speaker_name: String, text: String) -> void:
	start_dialogue(speaker_name, null, [text])


func _show_current_line() -> void:
	if _current_line_index >= _lines.size():
		_on_dialogue_complete()
		return

	_full_text = _lines[_current_line_index]
	_revealed_count = 0
	_typing_timer = 0.0
	_is_typing = true
	_next_indicator.visible = false
	_dialogue_label.text = ""


func _update_displayed_text() -> void:
	var visible_text: String = _full_text.left(_revealed_count)
	# Use bbcode color for the revealed portion, rest invisible via alpha
	_dialogue_label.text = "[color=#e8e8f0]" + visible_text + "[/color]"


func _finish_typing() -> void:
	_is_typing = false
	_revealed_count = _full_text.length()
	# Show complete text
	_dialogue_label.text = "[color=#e8e8f0]" + _full_text + "[/color]"
	_next_indicator.visible = true
	_blink_timer = 0.0
	_blink_visible = true
	_next_indicator.modulate.a = 1.0


func _advance_dialogue() -> void:
	if _is_typing:
		# Skip typewriter, show full text immediately
		_finish_typing()
		return

	# Move to next line
	_current_line_index += 1
	_show_current_line()


func _on_dialogue_complete() -> void:
	hide_all()
	dialogue_finished.emit()
