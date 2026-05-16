extends CanvasLayer
## Dialogue UI – Pokemon-style bottom dialog bar with typewriter effect

signal dialogue_finished

@onready var portrait: TextureRect = %Portrait
@onready var name_label: Label = %NameLabel
@onready var dialogue_label: RichTextLabel = %DialogueLabel
@onready var next_indicator: Label = %NextIndicator

var dialogue_queue: Array[String] = []
var current_speaker_name: String = ""
var current_speaker_portrait: Texture2D = null
var is_typing: bool = false
var full_current_text: String = ""
var typewriter_tween: Tween = null
const TYPE_SPEED: float = 0.02

func _ready() -> void:
	visible = false
	next_indicator.visible = false

func start_dialogue(speaker_name: String, portrait_tex: Texture2D, lines: Array[String]) -> void:
	current_speaker_name = speaker_name
	current_speaker_portrait = portrait_tex
	dialogue_queue = lines.duplicate()
	
	name_label.text = current_speaker_name
	if portrait_tex:
		portrait.texture = portrait_tex
		portrait.visible = true
	else:
		portrait.visible = false
	
	visible = true
	get_tree().paused = true
	_show_next_line()

func _show_next_line() -> void:
	if dialogue_queue.is_empty():
		_finish_dialogue()
		return
	
	if typewriter_tween and typewriter_tween.is_valid():
		typewriter_tween.kill()
	
	full_current_text = dialogue_queue.pop_front()
	is_typing = true
	next_indicator.visible = false
	dialogue_label.text = ""
	
	typewriter_tween = create_tween()
	var total_time = full_current_text.length() * TYPE_SPEED
	typewriter_tween.tween_method(_typewrite.bind(full_current_text), 0.0, 1.0, total_time)
	typewriter_tween.tween_callback(_on_typewriter_done)

func _typewrite(progress: float, full_text: String) -> void:
	dialogue_label.text = full_text.substr(0, int(full_text.length() * progress))

func _on_typewriter_done() -> void:
	is_typing = false
	dialogue_label.text = full_current_text
	next_indicator.visible = true
	var blink := create_tween()
	blink.set_loops()
	blink.tween_property(next_indicator, "modulate:a", 0.2, 0.5)
	blink.tween_property(next_indicator, "modulate:a", 1.0, 0.5)

func _advance() -> void:
	if is_typing:
		if typewriter_tween and typewriter_tween.is_valid():
			typewriter_tween.kill()
		dialogue_label.text = full_current_text
		_on_typewriter_done()
	else:
		_show_next_line()

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		_advance()
		get_viewport().set_input_as_handled()

func _finish_dialogue() -> void:
	if typewriter_tween and typewriter_tween.is_valid():
		typewriter_tween.kill()
	visible = false
	get_tree().paused = false
	dialogue_finished.emit()
	queue_free()
