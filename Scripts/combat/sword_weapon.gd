extends Node2D
## Broń do walki wręcz – tworzy tymczasowy Area2D imitujący zamach mieczem

var current_weapon: WeaponBase
var can_attack: bool = true
var attack_timer: float = 0.0
var hit_enemies: Array = []

## Zapisuje dane broni i resetuje stan gotowości
func initialize(weapon_data: WeaponBase) -> void:
	current_weapon = weapon_data
	can_attack = true

## Tworzy tymczasowy obszar ataku (Area2D) przed graczem, zadaje obrażenia wrogom
func swing(player_pos: Vector2, direction: Vector2, weapon_data: WeaponBase) -> void:
	if not can_attack:
		return

	var swing_area: Area2D = Area2D.new()
	get_tree().root.add_child(swing_area)

	var am := get_node_or_null("/root/AudioManager")
	if am and am.has_method("play_sfx"):
		am.play_sfx("sword_slash")

	var sword_sprite := Sprite2D.new()
	var tex := load("res://Assets/newAssets/sword.png") as Texture2D
	if tex:
		sword_sprite.texture = tex
		sword_sprite.scale = Vector2(0.35, 0.35)
		swing_area.add_child(sword_sprite)

	var collision_shape: CollisionShape2D = CollisionShape2D.new()
	var rect_shape: RectangleShape2D = RectangleShape2D.new()
	rect_shape.size = Vector2(80, 40)
	collision_shape.shape = rect_shape
	swing_area.add_child(collision_shape)

	swing_area.global_position = player_pos + direction * 40
	swing_area.rotation = direction.angle()
	swing_area.collision_layer = 0
	swing_area.collision_mask = 0

	swing_area.body_entered.connect(_on_swing_body_entered.bind(weapon_data))

	hit_enemies.clear()

	# Usuń obszar ataku po 0.3s
	get_tree().create_timer(0.3).timeout.connect(swing_area.queue_free)

	can_attack = false
	attack_timer = weapon_data.attack_speed

func _on_swing_body_entered(body: Node2D, weapon_data: WeaponBase) -> void:
	if not body.is_in_group("Enemies"):
		return
	if hit_enemies.has(body):
		return

	hit_enemies.append(body)

	if body.has_method("take_damage"):
		body.take_damage(weapon_data.damage)

## Proces ramki – odmierza cooldown ataku
func _process(delta: float) -> void:
	if not can_attack:
		attack_timer -= delta
		if attack_timer <= 0.0:
			can_attack = true

## Zwraca true, gdy broń może wykonać atak
func is_ready() -> bool:
	return can_attack
