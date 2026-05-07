extends Area2D
## Pocisk - podstawa wszystkich ataków dystansowych

signal hit_target(target: Node2D)

@export var speed: float = 500.0
@export var damage: int = 10
@export var lifetime: float = 3.0
@export var can_pierce: bool = false
@export var max_pierce_count: int = 0

var direction: Vector2 = Vector2.RIGHT
var owner_node: Node2D
var pierce_count: int = 0
var time_alive: float = 0.0

var sprite: Sprite2D
var collision: CollisionShape2D

func _ready() -> void:
	# Znajdź węzły bezpiecznie
	if has_node("Sprite2D"):
		sprite = $Sprite2D
	if has_node("CollisionShape2D"):
		collision = $CollisionShape2D

	body_entered.connect(_on_body_entered)
	add_to_group("Projectiles")

func _physics_process(delta: float) -> void:
	# Ruch pocisku
	position += direction * speed * delta

	# Obrót w kierunku ruchu
	if direction.length() > 0:
		rotation = direction.angle()

	# Czas życia
	time_alive += delta
	if time_alive >= lifetime:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body == owner_node:
		return

	if body.is_in_group("Enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		hit_target.emit(body)

		if not can_pierce or pierce_count >= max_pierce_count:
			queue_free()
		else:
			pierce_count += 1
	else:
		# Zniszcz się po uderzeniu w przeszkodę
		queue_free()

func set_direction(new_direction: Vector2) -> void:
	direction = new_direction.normalized()
	if direction.length() > 0:
		rotation = direction.angle()