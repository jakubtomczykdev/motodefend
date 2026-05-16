extends EnemyBase
## Phishing - szybki, ale słaby wróg. Porusza się zygzakiem.

var zigzag_timer: float = 0.0
var zigzag_direction: int = 1

func _ready() -> void:
	max_health = 30
	move_speed = 150.0
	score_value = 15
	super._ready()

func handle_ai(delta: float) -> void:
	if not player:
		super.handle_ai(delta)
		return

	zigzag_timer -= delta
	if zigzag_timer <= 0:
		zigzag_timer = randf_range(0.3, 0.6)
		zigzag_direction *= -1

	var distance := global_position.distance_to(player.global_position)
	if distance < detection_range:
		var dir_to_player = (player.global_position - global_position).normalized()
		var side_dir = dir_to_player.rotated(PI/2) * zigzag_direction
		
		# Łączymy kierunek do gracza z ruchem na boki
		var final_dir = (dir_to_player + side_dir * 0.8).normalized()
		velocity = final_dir * move_speed
		
		if sprite and "scale" in sprite:
			if final_dir.x > 0:
				sprite.scale.x = abs(sprite.scale.x)
			elif final_dir.x < 0:
				sprite.scale.x = -abs(sprite.scale.x)
	else:
		_handle_wander(delta)
