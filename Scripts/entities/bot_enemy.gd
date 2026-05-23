extends EnemyBase
## Bot — group-AI enemy. Gathers with nearby bots; attacks in swarms >=5.

const BOT_RADIUS: float = 200.0
const GROUP_BONUS_DAMAGE: int = 1
const MIN_GROUP_SIZE: int = 5

enum State { GATHERING, ATTACKING }
var current_state: State = State.GATHERING


func _ready() -> void:
	max_health = 15
	damage = 5
	move_speed = 135.0
	score_value = 8
	xp_value = 5
	super._ready()


func handle_ai(delta: float) -> void:
	if is_dead:
		return
	if not player:
		_handle_wander(delta)
		return

	var nearby_count := _count_nearby_bots()

	if nearby_count < MIN_GROUP_SIZE:
		current_state = State.GATHERING
		_ai_gathering()
	else:
		current_state = State.ATTACKING
		_ai_attacking()


func _count_nearby_bots() -> int:
	var count := 0
	var enemies := get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		if enemy == self or not is_instance_valid(enemy):
			continue
		if "bot" in enemy.name.to_lower():
			if global_position.distance_to(enemy.global_position) <= BOT_RADIUS:
				count += 1
	return count


func _ai_gathering() -> void:
	# Move toward nearest bot (with "bot" in name)
	var nearest_bot: Node2D = null
	var nearest_dist: float = INF
	var enemies := get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		if enemy == self or not is_instance_valid(enemy):
			continue
		if "bot" not in enemy.name.to_lower():
			continue
		var dist := global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest_bot = enemy

	if nearest_bot:
		var direction = (nearest_bot.global_position - global_position).normalized()
		velocity = direction * move_speed
		if sprite and "scale" in sprite:
			if direction.x > 0:
				sprite.scale.x = abs(sprite.scale.x)
			elif direction.x < 0:
				sprite.scale.x = -abs(sprite.scale.x)
	else:
		# No other bots — slow drift toward player
		if player and is_instance_valid(player):
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * (move_speed * 0.6)
			if sprite and "scale" in sprite:
				if direction.x > 0:
					sprite.scale.x = abs(sprite.scale.x)
				elif direction.x < 0:
					sprite.scale.x = -abs(sprite.scale.x)


func _ai_attacking() -> void:
	if not player or not is_instance_valid(player):
		return
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * move_speed
	if sprite and "scale" in sprite:
		if direction.x > 0:
			sprite.scale.x = abs(sprite.scale.x)
		elif direction.x < 0:
			sprite.scale.x = -abs(sprite.scale.x)


func attack() -> void:
	if not can_attack or players_in_attack_range.is_empty():
		return

	var target = players_in_attack_range[0]
	if not is_instance_valid(target) or not target.has_method("take_damage"):
		return

	# Damage scales with swarm: +1 per bot beyond MIN_GROUP_SIZE
	var nearby_count := _count_nearby_bots()
	var extra_bots := 0
	if nearby_count >= MIN_GROUP_SIZE:
		extra_bots = nearby_count - MIN_GROUP_SIZE
	var total_damage := damage + (extra_bots * GROUP_BONUS_DAMAGE)

	var kb_dir = (target.global_position - global_position).normalized()
	target.take_damage(total_damage, kb_dir * 300.0)
	can_attack = false
	attack_timer = attack_cooldown

	_play_attack_feedback()


func _play_attack_feedback() -> void:
	if not is_inside_tree():
		return

	var original_modulate = modulate
	modulate = Color.RED

	if sprite and "scale" in sprite:
		var original_scale = sprite.scale
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "modulate", original_modulate, 0.1)
		tween.tween_property(sprite, "scale", original_scale * 1.15, 0.05)
		tween.tween_property(sprite, "scale", original_scale, 0.05).set_delay(0.05)
	else:
		var tween := create_tween()
		tween.tween_property(self, "modulate", original_modulate, 0.1)
