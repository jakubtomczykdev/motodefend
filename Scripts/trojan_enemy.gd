extends EnemyBase
## Trojan - szarżuje na gracza gdy go zobaczy

var is_charging: bool = false
var charge_cooldown: float = 0.0

func _ready() -> void:
	max_health = 80
	move_speed = 110.0
	score_value = 25
	super._ready()

func handle_ai(delta: float) -> void:
	if not player or is_charging:
		return
		
	charge_cooldown -= delta
	var distance = global_position.distance_to(player.global_position)
	
	if charge_cooldown <= 0 and distance < 400 and distance > 100:
		_start_charge()
		return
		
	super.handle_ai(delta)

func _start_charge() -> void:
	if not player: return
	is_charging = true
	var dir = (player.global_position - global_position).normalized()
	
	# Efekt przygotowania
	velocity = Vector2.ZERO
	modulate = Color(1, 1, 0) # Żółty - ostrzeżenie
	await get_tree().create_timer(0.5).timeout
	
	# Szarża
	modulate = Color(1, 0.5, 0) # Pomarańczowy - szarża
	velocity = dir * move_speed * 3.5
	await get_tree().create_timer(0.8).timeout
	
	is_charging = false
	modulate = Color.WHITE
	charge_cooldown = 3.0
