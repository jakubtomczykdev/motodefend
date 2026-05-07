extends "res://Scripts/enemy_base.gd"
## Phishing - szybki, ale słaby wróg

func _ready() -> void:
	max_health = 30
	move_speed = 150.0
	score_value = 15
	super._ready()
