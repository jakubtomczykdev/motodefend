extends EnemyBase
## SQL Injection - powolny, ale silny wróg

func _ready() -> void:
	max_health = 100
	damage = 25
	move_speed = 70.0
	score_value = 25
	super._ready()
