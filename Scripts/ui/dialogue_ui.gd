extends CanvasLayer
## Dialogue UI - Visual Novel style dialogue system

signal dialogue_finished

@onready var portrait: TextureRect = %Portrait
@onready var name_label: Label = %NameLabel
@onready var dialogue_label: RichTextLabel = %DialogueLabel
@onready var next_button: Button = %NextButton

var bestiary_scene = preload("res://scenes/BestiaryUI.tscn")
var dialogue_queue: Array[String] = []
var current_speaker_name: String = ""
var current_speaker_portrait: Texture2D = null

func _ready() -> void:
	visible = false

func start_dialogue(speaker_name: String, portrait_tex: Texture2D, lines: Array[String]) -> void:
	current_speaker_name = speaker_name
	current_speaker_portrait = portrait_tex
	dialogue_queue = lines.duplicate()
	
	name_label.text = current_speaker_name
	portrait.texture = current_speaker_portrait
	
	visible = true
	get_tree().paused = true
	_show_next_line()

func _show_next_line() -> void:
	if dialogue_queue.is_empty():
		_finish_dialogue()
		return
	
	var line = dialogue_queue.pop_front()
	dialogue_label.text = line
	
	if dialogue_queue.is_empty():
		next_button.text = "ZAKOŃCZ"
	else:
		next_button.text = "DALEJ >"

func _on_next_button_pressed() -> void:
	_show_next_line()

func _on_bestiary_button_pressed() -> void:
	var bestiary = bestiary_scene.instantiate()
	get_parent().add_child(bestiary)
	bestiary.open_bestiary()

func _finish_dialogue() -> void:
	visible = false
	get_tree().paused = false
	dialogue_finished.emit()
	queue_free()
