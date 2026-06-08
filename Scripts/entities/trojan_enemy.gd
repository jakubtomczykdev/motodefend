extends EnemyBase
## Trojan - charges in a telegraphed line and hits hard on contact.

var is_charging: bool = false
var charge_cooldown: float = 0.0
var charge_direction: Vector2 = Vector2.ZERO
var charge_hit_done: bool = false

func _ready() -> void:
	max_health = 80
	move_speed = 110.0
	score_value = 25
	super._ready()

func handle_ai(delta: float) -> void:
	if not player or is_charging:
		return

	charge_cooldown -= delta
	var distance := global_position.distance_to(player.global_position)

	if charge_cooldown <= 0 and distance < 440.0 and distance > 105.0:
		_start_charge()
		return

	super.handle_ai(delta)

func _start_charge() -> void:
	if not player:
		return

	is_charging = true
	charge_hit_done = false
	charge_direction = (player.global_position - global_position).normalized()

	velocity = Vector2.ZERO
	modulate = Color(1.0, 1.0, 0.15)
	_spawn_line_warning(global_position, charge_direction, 430.0, 34.0, 0.5, Color(1.0, 0.84, 0.1, 0.34))
	await get_tree().create_timer(0.5).timeout
	if is_dead:
		return

	modulate = Color(1.0, 0.5, 0.0)
	velocity = charge_direction * move_speed * 3.8
	await get_tree().create_timer(0.8).timeout
	if is_dead:
		return

	is_charging = false
	modulate = Color.WHITE
	charge_cooldown = 3.0

func attack() -> void:
	if is_charging and not charge_hit_done:
		charge_hit_done = true
		var target = players_in_attack_range[0] if not players_in_attack_range.is_empty() else player
		if is_instance_valid(target) and target.has_method("take_damage"):
			var kb_dir := charge_direction
			if kb_dir == Vector2.ZERO:
				kb_dir = (target.global_position - global_position).normalized()
			target.take_damage(int(damage * 1.6), kb_dir * 520.0)
		can_attack = false
		attack_timer = attack_cooldown
		return

	super.attack()
