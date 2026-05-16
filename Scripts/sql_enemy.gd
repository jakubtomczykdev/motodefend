extends EnemyBase
## SQL Injection - powolny, ale silny wróg. Atakuje doskokiem.

var lunge_timer: float = 3.0
var is_lunging: bool = false

func _ready() -> void:
	max_health = 100
	damage = 25
	move_speed = 70.0
	score_value = 25
	super._ready()

func handle_ai(delta: float) -> void:
	if not player or is_lunging:
		return

	lunge_timer -= delta
	if lunge_timer <= 0:
		var distance = global_position.distance_to(player.global_position)
		if distance < 300:
			_start_lunge()
			lunge_timer = randf_range(4.0, 6.0)
			return

	super.handle_ai(delta)

func _start_lunge() -> void:
	if not player: return
	is_lunging = true
	var dir = (player.global_position - global_position).normalized()
	velocity = dir * move_speed * 4.0
	
	# Efekt wizualny doskoku
	modulate = Color(2, 0.5, 0.5)
	
	await get_tree().create_timer(0.4).timeout
	is_lunging = false
	modulate = Color.WHITE
	velocity = Vector2.ZERO
