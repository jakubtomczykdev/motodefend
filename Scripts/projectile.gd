extends Area2D

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

var homing_target: Node2D = null
var homing_strength: float = 0.0

var sprite: Sprite2D
var collision: CollisionShape2D

func _ready() -> void:
	if has_node("Sprite2D"):
		sprite = $Sprite2D
		if sprite and not sprite.texture:
			_generate_projectile_texture()
	if has_node("CollisionShape2D"):
		collision = $CollisionShape2D

	body_entered.connect(_on_body_entered)
	add_to_group("Projectiles")

func _generate_projectile_texture() -> void:
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for x in range(16):
		for y in range(16):
			var dx := x - 8
			var dy := y - 8
			if dx * dx + dy * dy < 36:
				img.set_pixel(x, y, Color(0.3, 0.8, 1, 1 - sqrt(dx*dx + dy*dy) / 8.0))
	var tex := ImageTexture.create_from_image(img)
	if sprite:
		sprite.texture = tex

func _physics_process(delta: float) -> void:
	if homing_target and is_instance_valid(homing_target):
		var target_dir := (homing_target.global_position - global_position).normalized()
		direction = direction.lerp(target_dir, homing_strength * delta).normalized()

	position += direction * speed * delta

	if direction.length() > 0:
		rotation = direction.angle()

	time_alive += delta
	if time_alive >= lifetime:
		_spawn_explosion(global_position)
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body == owner_node:
		return

	if body.is_in_group("Enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		_spawn_explosion(global_position)
		hit_target.emit(body)

		if not can_pierce or pierce_count >= max_pierce_count:
			queue_free()
		else:
			pierce_count += 1
	else:
		_spawn_explosion(global_position)
		queue_free()

func _spawn_explosion(pos: Vector2) -> void:
	for i in range(5):
		var spark := ColorRect.new()
		spark.size = Vector2(4 + randi() % 4, 4 + randi() % 4)
		spark.color = Color(0.3 + randf() * 0.5, 0.7 + randf() * 0.3, 1, 1)
		spark.global_position = pos + Vector2(randf_range(-6, 6), randf_range(-6, 6))
		var scene = get_tree().current_scene
		if scene:
			scene.add_child(spark)
		else:
			spark.queue_free()
			return
		var dir := Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		var st := create_tween()
		st.tween_property(spark, "global_position", spark.global_position + dir * 20, 0.15)
		st.parallel().tween_property(spark, "modulate:a", 0.0, 0.2)
		st.tween_callback(spark.queue_free)

func set_direction(new_direction: Vector2) -> void:
	direction = new_direction.normalized()
	if direction.length() > 0:
		rotation = direction.angle()
