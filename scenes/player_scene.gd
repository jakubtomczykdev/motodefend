extends CharacterBody2D

@export var speed = 150.0

@onready var _animated_sprite = $AnimatedSprite2D

func _physics_process(_delta):
	# Używamy Twoich nazw z Mapowania wejścia (Input Map)
	var direction = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	
	if direction != Vector2.ZERO:
		velocity = direction * speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)

	move_and_slide()
	
	update_animations(direction)

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
