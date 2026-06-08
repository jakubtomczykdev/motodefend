extends CanvasLayer

## HUDWeaponPanel – Obsługuje wyświetlanie aktualnie posiadanych broni na HUD.

@onready var weapon_icon1: TextureRect = %WeaponIcon1
@onready var cooldown_overlay1: ColorRect = %CooldownOverlay1
@onready var weapon_name1: Label = %WeaponName1
@onready var weapon_icon2: TextureRect = %WeaponIcon2
@onready var cooldown_overlay2: ColorRect = %CooldownOverlay2
@onready var weapon_name2: Label = %WeaponName2
@onready var panel_container: PanelContainer = $PanelContainer

func _ready() -> void:
	if panel_container:
		panel_container.visible = false

func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("get_weapons"):
		var weapons = player.get_weapons()
		_update_display(weapons)

func _update_display(weapons: Array) -> void:
	if not panel_container: return
	
	panel_container.visible = !weapons.is_empty()
	
	# Slot 1
	if weapons.size() >= 1:
		var w1 = weapons[0]
		if weapon_icon1: weapon_icon1.texture = w1.icon
		if weapon_name1: weapon_name1.text = w1.item_name
		if cooldown_overlay1:
			# Proste wyświetlanie cooldownu jeśli broń go ma
			if "current_cooldown" in w1 and "attack_speed" in w1:
				var progress = w1.current_cooldown / w1.attack_speed
				cooldown_overlay1.custom_minimum_size.y = progress * 80
	else:
		if weapon_icon1: weapon_icon1.texture = null
		if weapon_name1: weapon_name1.text = ""

	# Slot 2
	if weapons.size() >= 2:
		var w2 = weapons[1]
		if weapon_icon2: weapon_icon2.texture = w2.icon
		if weapon_name2: weapon_name2.text = w2.item_name
		if cooldown_overlay2:
			if "current_cooldown" in w2 and "attack_speed" in w2:
				var progress = w2.current_cooldown / w2.attack_speed
				cooldown_overlay2.custom_minimum_size.y = progress * 80
	else:
		if weapon_icon2: weapon_icon2.texture = null
		if weapon_name2: weapon_name2.text = ""
