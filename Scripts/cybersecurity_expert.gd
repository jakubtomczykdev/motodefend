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

func _show_dialog(text: String) -> void:
	if dialog_label:
		dialog_label.text = text
		dialog_label.visible = true
		dialog_timer = 4.0
	else:
		# Fallback – wypisz do konsoli
		print("[%s]: %s" % [npc_name, text])
