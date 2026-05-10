extends CharacterBody2D
## Pocisk - podstawa wszystkich ataków dystansowych
## Używa CharacterBody2D + RayCast2D dla 100% niezawodnej detekcji kolizji

signal hit_target(target: Node2D)

@export var speed: float = 500.0
@export var damage: int = 10
@export var lifetime: float = 3.0
@export var can_pierce: bool = false
@export var max_pierce_count: int = 0

var direction: Vector2 = Vector2.RIGHT
var owner_node: CollisionObject2D
var pierce_count: int = 0
var time_alive: float = 0.0

var sprite: Sprite2D
var raycast: RayCast2D
var hit_bodies: Array[Node2D] = []

func _ready() -> void:
	# Znajdź węzły
	if has_node("Sprite2D"):
		sprite = $Sprite2D
		var gradient := Gradient.new()
		gradient.colors = PackedColorArray([Color.YELLOW, Color.ORANGE_RED])
		var gradient_texture := GradientTexture2D.new()
		gradient_texture.gradient = gradient
		gradient_texture.width = 24
		gradient_texture.height = 8
		gradient_texture.fill_from = Vector2(0, 0.5)
		gradient_texture.fill_to = Vector2(1, 0.5)
		sprite.texture = gradient_texture
		sprite.scale = Vector2(1, 1)
	if has_node("RayCast2D"):
		raycast = $RayCast2D
		raycast.collision_mask = 1
		# Wyklucz właściciela jeśli już ustawiony
		if owner_node:
			raycast.add_exception(owner_node)

	# Warstwy kolizji: pocisk na layer 4 (dedykowany dla projectile),
	# wykrywa layer 1 (enemies + player)
	collision_layer = 4
	collision_mask = 1
	
	add_to_group("Projectiles")

func _physics_process(delta: float) -> void:
	# 1. RayCast sprawdza co jest na trasie przed pociskiem
	#    (zapobiega przeskakiwaniu przez wrogów przy wysokich prędkościach)
	if raycast:
		raycast.target_position = direction * speed * delta * 1.5
		raycast.force_raycast_update()
		if raycast.is_colliding():
			var body := raycast.get_collider() as Node2D
			if body and body != owner_node and not body in hit_bodies:
				_process_hit(body)
				if is_queued_for_deletion():
					return

	# 2. Ruch + natychmiastowa detekcja przez move_and_collide
	velocity = direction * speed
	var col := move_and_collide(velocity * delta)
	if col:
		var body := col.get_collider() as Node2D
		if body and body != owner_node and not body in hit_bodies:
			_process_hit(body)
			if is_queued_for_deletion():
				return
		else:
			# Uderzenie w ścianę / przeszkodę – zniszcz
			queue_free()
			return

	# Obrót w kierunku ruchu
	if direction.length() > 0:
		rotation = direction.angle()

	# Czas życia
	time_alive += delta
	if time_alive >= lifetime:
		queue_free()

func _process_hit(body: Node2D) -> void:
	hit_bodies.append(body)

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
