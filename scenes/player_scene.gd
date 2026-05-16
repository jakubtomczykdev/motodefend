extends CharacterBody2D

@export var speed = 150.0

@onready var _animated_sprite = $AnimatedSprite2D
@onready var interaction_area = $InteractionArea
@onready var interaction_prompt = $InteractionPrompt

var current_interactable = null

# Zmienne dla systemu kroków
var _step_timer: float = 0.0
var _step_interval: float = 0.35 # Czas między krokami (sekundy)
var _use_step1: bool = true

func _ready():
	add_to_group("Player")
	interaction_area.area_entered.connect(_on_interaction_area_area_entered)
	interaction_area.area_exited.connect(_on_interaction_area_area_exited)
	interaction_prompt.visible = false

func _physics_process(_delta):
	# Używamy Twoich nazw z Mapowania wejścia (Input Map)
	var direction = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	
	if direction != Vector2.ZERO:
		velocity = direction * speed
		_handle_footsteps(_delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)
		_step_timer = 0.0 # Resetuj przy zatrzymaniu

	move_and_slide()
	_clamp_to_screen()
	
	update_animations(direction)
	
	if Input.is_action_just_pressed("interact") and current_interactable != null:
		print("[DEBUG] E pressed, current_interactable=", current_interactable)
		print("[DEBUG] Trying interact() on ", current_interactable, " has_method=", current_interactable.has_method("interact"))
		if current_interactable.has_method("interact"):
			current_interactable.interact()
		elif current_interactable.get_parent() and current_interactable.get_parent().has_method("interact"):
			current_interactable.get_parent().interact()

# Ograniczenie gracza do ekranu 1920×1080 z 30px marginesem
func _clamp_to_screen() -> void:
	global_position.x = clamp(global_position.x, 30, 1890)
	global_position.y = clamp(global_position.y, 30, 1050)

func _handle_footsteps(delta: float) -> void:
	_step_timer -= delta
	if _step_timer <= 0:
		var sfx_name := "step1" if _use_step1 else "step2"
		AudioManager.play_sfx(sfx_name, 0.05)
		_use_step1 = !_use_step1
		
		# Dostosuj interwał do prędkości (lobby speed jest zwykle stałe 150)
		var speed_factor := velocity.length() / 300.0
		_step_timer = _step_interval / max(speed_factor, 0.5)

func update_animations(direction):
	if direction.length() > 0:
		var dir = direction.normalized()
		
		if dir.y < -0.5: # Góra
			if dir.x > 0.5:
				_animated_sprite.play("back-right")
			elif dir.x < -0.5:
				_animated_sprite.play("back-left")
			else:
				_animated_sprite.play("back")
		elif dir.y > 0.5: # Dół
			if dir.x > 0.5:
				_animated_sprite.play("front-right")
			elif dir.x < -0.5:
				_animated_sprite.play("front-left")
			else:
				_animated_sprite.play("front")
		else: # Poziomo
			if dir.x > 0:
				_animated_sprite.play("right")
			elif dir.x < 0:
				_animated_sprite.play("left")
	else:
		_animated_sprite.stop()
		_animated_sprite.frame = 0

func _on_interaction_area_area_entered(area):
	print("[DEBUG] area_entered: ", area.name, " parent: ", area.get_parent().name)
	if area.is_in_group("Interactable"):
		current_interactable = area
		var prompt_text = "[E] Interakcja"
		if area.has_method("get_interaction_text"):
			prompt_text = area.get_interaction_text()
		elif area.get_parent() and area.get_parent().has_method("get_interaction_text"):
			prompt_text = area.get_parent().get_interaction_text()
		
		interaction_prompt.text = prompt_text
		interaction_prompt.visible = true

func _on_interaction_area_area_exited(area):
	if area == current_interactable:
		current_interactable = null
		interaction_prompt.visible = false
