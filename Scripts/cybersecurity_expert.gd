extends CharacterBody2D

@export var npc_name: String = "Ekspert Cyberbezpieczeństwa"

# --- Patrol AI ---
@export var patrol_radius: float = 150.0
@export var walk_speed: float = 60.0
@export var idle_time_min: float = 2.0
@export var idle_time_max: float = 5.0

@export var dialog_lines: Array[String] = [
	"Witaj w centrum cyberbezpieczeństwa!",
	"Naszym zadaniem jest ochrona sieci przed atakami.",
	"Uważaj na wirusy – potrafią być bardzo niebezpieczne.",
	"Jeśli potrzebujesz pomocy, zawsze możesz do mnie wrócić."
]

enum State { IDLE, WALKING }

var patrol_origin: Vector2
var target_position: Vector2
var current_state: State = State.IDLE
var idle_timer: float = 0.0
var current_dialog_index: int = -1
var dialog_timer: float = 0.0
var dialog_label: Label = null
var intro_shown: bool = false

var dialog_panel: Panel = null
var dialog_text_label: Label = null
var dialog_typewriter_timer: Timer = null
var dialog_target_text: String = ""
var dialog_displayed_chars: int = 0

func _ready() -> void:
	$AnimatedSprite2D.play("standing")
	$InteractArea.add_to_group("Interactable")

	patrol_origin = global_position
	idle_timer = randf_range(idle_time_min, idle_time_max)

	# Znajdź referencję do Label dialogu (będzie dodany w .tscn)
	dialog_label = get_node_or_null("DialogLabel")
	if dialog_label:
		dialog_label.visible = false

func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			_handle_idle(delta)
		State.WALKING:
			_handle_walking(delta)

	move_and_slide()

	# Ukryj dialog po upływie czasu
	if dialog_label and dialog_label.visible:
		dialog_timer -= delta
		if dialog_timer <= 0.0:
			dialog_label.visible = false

	# Ukryj panel dialogowy po zakończeniu typewritera i upływie czasu
	if dialog_panel and dialog_panel.visible and (not dialog_typewriter_timer or dialog_typewriter_timer.is_stopped()):
		dialog_timer -= delta
		if dialog_timer <= 0.0:
			_hide_dialog()

func _handle_idle(delta: float) -> void:
	velocity = Vector2.ZERO
	idle_timer -= delta

	if idle_timer <= 0.0:
		_pick_new_target()
		current_state = State.WALKING

func _handle_walking(_delta: float) -> void:
	var direction := (target_position - global_position).normalized()
	var distance := global_position.distance_to(target_position)

	if distance < 10.0:
		# Dotarliśmy do celu
		velocity = Vector2.ZERO
		current_state = State.IDLE
		idle_timer = randf_range(idle_time_min, idle_time_max)
	else:
		velocity = direction * walk_speed

func _pick_new_target() -> void:
	var random_offset := Vector2(
		randf_range(-patrol_radius, patrol_radius),
		randf_range(-patrol_radius * 0.3, patrol_radius * 0.3)
	)
	target_position = patrol_origin + random_offset

func interact() -> void:
	if not intro_shown:
		_show_intro_sequence()
	else:
		_show_random_tip()

func _show_intro_sequence() -> void:
	var intro_lines: Array[String] = [
		"Jestem Marek Nowak, Ekspert Cyberbezpieczeństwa SOC.",
		"Witaj w naszej centrali. Nasza sieć jest pod ciągłym atakiem.",
		"Twoim zadaniem jest odpieranie fal hakerów i wirusów.",
		"Każda fala to 20 sekund – wyeliminuj wszystkich wrogów!",
		"Po każdej fali wrócisz tu, do centrali. Kolejne fale będą trudniejsze.",
		"Korzystaj ze sklepu (automat po lewej) by ulepszyć swój ekwipunek.",
		"Powodzenia, agent! Nasza sieć na Ciebie liczy."
	]
	intro_shown = true
	current_dialog_index = 0
	_show_dialog(intro_lines[current_dialog_index])

func _show_random_tip() -> void:
	var tips: Array[String] = [
		"Kolejne fale są coraz trudniejsze – ulepszaj broń w sklepie!",
		"Wormy potrafią się rozmnażać – eliminuj je szybko.",
		"Bossowie pojawiają się co 5 fal – bądź przygotowany.",
		"SQL Injection zadaje dużo obrażeń – trzymaj dystans.",
		"Kupuj ulepszenia pancerza – każde HP się liczy.",
		"Trojan to szybki przeciwnik – celuj precyzyjnie."
	]
	var tip: String = tips[current_dialog_index % tips.size()]
	current_dialog_index += 1
	_show_dialog(tip)

func _ensure_dialog_panel() -> void:
	if dialog_panel:
		return
	var canvas := CanvasLayer.new()
	canvas.name = "DialogCanvas"
	canvas.layer = 10
	add_child(canvas)

	dialog_panel = Panel.new()
	dialog_panel.name = "DialogPanel"
	dialog_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	dialog_panel.offset_top = -200
	dialog_panel.offset_bottom = -30
	dialog_panel.offset_left = 60
	dialog_panel.offset_right = -60
	canvas.add_child(dialog_panel)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 8)
	dialog_panel.add_child(vbox)

	var name_label := Label.new()
	name_label.name = "NameLabel"
	name_label.text = npc_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	name_label.add_theme_font_size_override("font_size", 22)
	name_label.add_theme_color_override("font_color", Color.CYAN)
	vbox.add_child(name_label)

	dialog_text_label = Label.new()
	dialog_text_label.name = "DialogTextLabel"
	dialog_text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	dialog_text_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	dialog_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialog_text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dialog_text_label.add_theme_font_size_override("font_size", 20)
	vbox.add_child(dialog_text_label)

	dialog_typewriter_timer = Timer.new()
	dialog_typewriter_timer.name = "TypewriterTimer"
	dialog_typewriter_timer.wait_time = 0.03
	dialog_typewriter_timer.one_shot = false
	dialog_typewriter_timer.timeout.connect(_on_typewriter_tick)
	canvas.add_child(dialog_typewriter_timer)

func _show_dialog(text: String) -> void:
	_ensure_dialog_panel()
	dialog_target_text = text
	dialog_displayed_chars = 0
	if dialog_text_label:
		dialog_text_label.text = ""
	if dialog_panel:
		dialog_panel.visible = true
	if dialog_typewriter_timer:
		dialog_typewriter_timer.start()

func _on_typewriter_tick() -> void:
	if not dialog_text_label:
		return
	dialog_displayed_chars += 1
	dialog_text_label.text = dialog_target_text.substr(0, dialog_displayed_chars)
	if dialog_displayed_chars >= dialog_target_text.length():
		dialog_typewriter_timer.stop()
		dialog_timer = clampf(2.0 + dialog_target_text.length() * 0.08, 3.0, 10.0)

func _hide_dialog() -> void:
	if dialog_panel:
		dialog_panel.visible = false
	if dialog_label:
		dialog_label.visible = false
