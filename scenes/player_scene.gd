extends CharacterBody2D

@export var speed = 150.0

@onready var _animated_sprite = $AnimatedSprite2D
@onready var interaction_area = $InteractionArea
@onready var interaction_prompt = $InteractionPrompt

var current_interactable = null

func _ready():
	interaction_area.area_entered.connect(_on_interaction_area_area_entered)
	interaction_area.area_exited.connect(_on_interaction_area_area_exited)
	interaction_prompt.visible = false

func _physics_process(_delta):
	# Używamy Twoich nazw z Mapowania wejścia (Input Map)
	var direction = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	
	if direction != Vector2.ZERO:
		velocity = direction * speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)

	move_and_slide()
	
	update_animations(direction)
	
	if Input.is_action_just_pressed("interact") and current_interactable != null:
		if current_interactable.has_method("interact"):
			current_interactable.interact()
		elif current_interactable.get_parent().has_method("interact"):
			current_interactable.get_parent().interact()

func update_animations(direction):
	if direction.x > 0:
		_animated_sprite.play("right")
	elif direction.x < 0:
		_animated_sprite.play("left")
	elif direction.y != 0:
		# Przy ruchu góra/dół postać używa animacji "right"
		_animated_sprite.play("right")
	else:
		# Gdy stoi, używa animacji "front"
		_animated_sprite.play("front")

func _on_interaction_area_area_entered(area):
	if area.is_in_group("Interactable"):
		current_interactable = area
		interaction_prompt.visible = true

func _on_interaction_area_area_exited(area):
	if area == current_interactable:
		current_interactable = null
		interaction_prompt.visible = false
