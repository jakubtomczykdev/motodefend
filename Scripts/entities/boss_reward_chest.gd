extends Node2D

signal opened

const WeaponItemsClass := preload("res://Scripts/entities/weapon_items.gd")
const UI_FONT := preload("res://Assets/fonts/VT323-Regular.ttf")

var wave_number: int = 1
var _opened: bool = false
var _is_rolling: bool = false
var _label: Label
var _reward_label: Label
var _roll_panel: PanelContainer
var _roll_name: Label
var _roll_rarity: Label
var _roll_icon: TextureRect
var _pulse_time: float = 0.0

func setup(p_wave_number: int) -> void:
	wave_number = max(p_wave_number, 1)

func _ready() -> void:
	add_to_group("Interactable")
	z_index = 20
	_build_visuals()

func _process(delta: float) -> void:
	if _opened:
		return
	_pulse_time += delta
	var pulse := 1.0 + sin(_pulse_time * 5.0) * 0.035
	scale = Vector2(pulse, pulse)

func get_interaction_text() -> String:
	return "OTWORZ SKRZYNKE BOSSA (E)"

func interact() -> void:
	if _opened or _is_rolling:
		return
	_opened = true
	_is_rolling = true
	remove_from_group("Interactable")
	scale = Vector2.ONE
	_open_with_roll_animation()

func _open_with_roll_animation() -> void:
	_open_chest_lid()
	var candidates := _get_reward_candidates()
	var reward: ItemBase = _pick_reward(candidates)
	if candidates.is_empty() and reward:
		candidates.append(reward)

	await _play_loot_roll(candidates, reward)

	if reward:
		_apply_reward(reward)
		_show_reward_text("ZDOBYTO: " + reward.item_name)
	else:
		_show_reward_text("ZDOBYTO: +150 ZLOTA")
		var gd := get_node_or_null("/root/GameData")
		if gd:
			gd.gold += 150

	opened.emit()
	_play_open_effect()

func _build_visuals() -> void:
	_add_pixel_rect("ChestShadow", Vector2(-42, 22), Vector2(84, 12), Color(0.0, 0.0, 0.0, 0.42), 0)
	_add_pixel_rect("ChestBackGlow", Vector2(-43, -36), Vector2(86, 66), Color(0.0, 0.72, 0.92, 0.20), 0)
	_add_pixel_rect("ChestOuter", Vector2(-36, -20), Vector2(72, 48), Color(0.02, 0.05, 0.08, 1.0), 1)
	_add_pixel_rect("ChestBody", Vector2(-31, -15), Vector2(62, 38), Color(0.08, 0.15, 0.22, 1.0), 2)
	_add_pixel_rect("ChestBodyHi", Vector2(-27, -11), Vector2(54, 8), Color(0.14, 0.28, 0.36, 1.0), 3)
	_add_pixel_rect("ChestBottom", Vector2(-31, 13), Vector2(62, 10), Color(0.02, 0.09, 0.13, 1.0), 3)
	_add_pixel_rect("ChestLidOuter", Vector2(-40, -36), Vector2(80, 24), Color(0.02, 0.05, 0.08, 1.0), 5)
	_add_pixel_rect("ChestLid", Vector2(-35, -32), Vector2(70, 16), Color(0.0, 0.78, 0.95, 1.0), 6)
	_add_pixel_rect("ChestLidHi", Vector2(-29, -28), Vector2(58, 4), Color(0.65, 0.97, 1.0, 1.0), 7)
	_add_pixel_rect("ChestStripeL", Vector2(-20, -15), Vector2(5, 38), Color(0.0, 0.72, 0.92, 1.0), 4)
	_add_pixel_rect("ChestStripeR", Vector2(15, -15), Vector2(5, 38), Color(0.0, 0.72, 0.92, 1.0), 4)
	_add_pixel_rect("ChestLockOuter", Vector2(-10, -12), Vector2(20, 22), Color(0.04, 0.03, 0.0, 1.0), 9)
	_add_pixel_rect("ChestLock", Vector2(-7, -8), Vector2(14, 15), Color(1.0, 0.82, 0.22, 1.0), 10)
	_add_pixel_rect("ChestLockCore", Vector2(-3, -2), Vector2(6, 6), Color(0.05, 0.08, 0.08, 1.0), 11)

	_label = Label.new()
	_label.text = "BOSS CACHE\n[E]"
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.add_theme_font_override("font", UI_FONT)
	_label.add_theme_font_size_override("font_size", 25)
	_label.add_theme_color_override("font_color", Color(0.75, 0.97, 1.0))
	_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	_label.add_theme_constant_override("shadow_offset_x", 2)
	_label.add_theme_constant_override("shadow_offset_y", 2)
	_label.position = Vector2(-78, -91)
	_label.size = Vector2(156, 54)
	add_child(_label)

	_reward_label = Label.new()
	_reward_label.visible = false
	_reward_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_reward_label.add_theme_font_override("font", UI_FONT)
	_reward_label.add_theme_font_size_override("font_size", 31)
	_reward_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.28))
	_reward_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	_reward_label.add_theme_constant_override("shadow_offset_x", 2)
	_reward_label.add_theme_constant_override("shadow_offset_y", 2)
	_reward_label.position = Vector2(-210, -128)
	_reward_label.size = Vector2(420, 46)
	_reward_label.z_index = 40
	add_child(_reward_label)

	_build_roll_panel()

func _add_pixel_rect(name_value: String, pos: Vector2, size_value: Vector2, color: Color, z: int) -> ColorRect:
	var rect := ColorRect.new()
	rect.name = name_value
	rect.position = pos
	rect.size = size_value
	rect.color = color
	rect.z_index = z
	add_child(rect)
	return rect

func _build_roll_panel() -> void:
	_roll_panel = PanelContainer.new()
	_roll_panel.visible = false
	_roll_panel.position = Vector2(-190, -188)
	_roll_panel.size = Vector2(380, 92)
	_roll_panel.z_index = 35
	_roll_panel.add_theme_stylebox_override("panel", _make_panel_style())
	add_child(_roll_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	_roll_panel.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	margin.add_child(row)

	var icon_box := PanelContainer.new()
	icon_box.custom_minimum_size = Vector2(68, 68)
	icon_box.add_theme_stylebox_override("panel", _make_box_style(Color(0.02, 0.04, 0.06, 1.0), Color(0.35, 0.94, 1.0)))
	row.add_child(icon_box)

	_roll_icon = TextureRect.new()
	_roll_icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_roll_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_box.add_child(_roll_icon)

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.add_theme_constant_override("separation", 0)
	row.add_child(text_box)

	var title := Label.new()
	title.text = "LOSOWANIE NAGRODY"
	title.add_theme_font_override("font", UI_FONT)
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(0.62, 0.92, 1.0))
	text_box.add_child(title)

	_roll_name = Label.new()
	_roll_name.text = "..."
	_roll_name.add_theme_font_override("font", UI_FONT)
	_roll_name.add_theme_font_size_override("font_size", 31)
	_roll_name.add_theme_color_override("font_color", Color.WHITE)
	_roll_name.clip_text = true
	text_box.add_child(_roll_name)

	_roll_rarity = Label.new()
	_roll_rarity.text = "SCANNING..."
	_roll_rarity.add_theme_font_override("font", UI_FONT)
	_roll_rarity.add_theme_font_size_override("font_size", 22)
	_roll_rarity.add_theme_color_override("font_color", Color(1.0, 0.86, 0.28))
	text_box.add_child(_roll_rarity)

func _open_chest_lid() -> void:
	if _label:
		_label.visible = false
	var lid := get_node_or_null("ChestLid")
	var lid_outer := get_node_or_null("ChestLidOuter")
	var lid_hi := get_node_or_null("ChestLidHi")
	for node in [lid, lid_outer, lid_hi]:
		if node and node is ColorRect:
			var rect := node as ColorRect
			var tween := create_tween()
			tween.tween_property(rect, "position:y", rect.position.y - 18.0, 0.18)
			tween.parallel().tween_property(rect, "rotation", -0.18, 0.18)

func _play_loot_roll(candidates: Array[ItemBase], reward: ItemBase) -> void:
	_roll_panel.visible = true
	_roll_panel.modulate.a = 0.0
	var show_tween := create_tween()
	show_tween.tween_property(_roll_panel, "modulate:a", 1.0, 0.15)
	await show_tween.finished

	var pool: Array[ItemBase] = candidates.duplicate()
	if pool.is_empty() and reward:
		pool.append(reward)

	var steps := 18
	for i in range(steps):
		var item: ItemBase = reward
		if not pool.is_empty():
			item = pool[i % pool.size()]
		_set_roll_display(item, i == steps - 1)
		_roll_panel.position.x = -190 + (-4 if i % 2 == 0 else 4)
		await get_tree().create_timer(0.035 + float(i) * 0.008).timeout

	if reward:
		_set_roll_display(reward, true)
		_roll_panel.position.x = -190
		var flash := create_tween()
		flash.tween_property(_roll_panel, "scale", Vector2(1.08, 1.08), 0.12)
		flash.tween_property(_roll_panel, "scale", Vector2.ONE, 0.16)
		await flash.finished
	else:
		_roll_name.text = "+150 ZLOTA"
		_roll_rarity.text = "AWARYJNY DROP"
		_roll_rarity.add_theme_color_override("font_color", Color(1.0, 0.86, 0.28))
		await get_tree().create_timer(0.35).timeout

func _set_roll_display(item: ItemBase, final_pick: bool = false) -> void:
	if item == null:
		return
	var rarity_color := item.get_rarity_color() if item.has_method("get_rarity_color") else Color(0.75, 0.84, 0.9)
	_roll_name.text = item.item_name.to_upper()
	_roll_name.add_theme_color_override("font_color", rarity_color if final_pick else Color(0.88, 0.95, 1.0))
	_roll_rarity.text = ("WYGRANA: " if final_pick else "MOZLIWY DROP: ") + item.rarity.to_upper()
	_roll_rarity.add_theme_color_override("font_color", rarity_color)
	if "icon" in item:
		_roll_icon.texture = item.icon

func _get_reward_candidates() -> Array[ItemBase]:
	var item_manager = get_tree().current_scene.get_node_or_null("ItemManager")
	if item_manager and "all_items" in item_manager and item_manager.all_items.is_empty() and item_manager.has_method("get_shop_items"):
		item_manager.get_shop_items(1, wave_number)

	var shop_tier := _get_shop_tier(item_manager)
	var candidates: Array[ItemBase] = []
	var min_rarity_index := _get_min_rarity_index_for_wave(wave_number)
	var player = get_tree().get_first_node_in_group("Player")
	var weapon_count: int = player.get_weapon_count() if player and player.has_method("get_weapon_count") else 0

	if item_manager and "all_items" in item_manager:
		for item: ItemBase in item_manager.all_items:
			if _is_good_reward(item, shop_tier, min_rarity_index, weapon_count):
				candidates.append(item)

	if candidates.is_empty():
		for weapon: WeaponBase in WeaponItemsClass.get_weapons_for_shop_tier(min(shop_tier + 1, 5)):
			if _is_good_reward(weapon, shop_tier, min_rarity_index, weapon_count):
				candidates.append(weapon)

	candidates.shuffle()
	return candidates.slice(0, 10)

func _pick_reward(candidates: Array[ItemBase]) -> ItemBase:
	if candidates.is_empty():
		return null
	var reward: ItemBase = candidates.pick_random()
	return reward.duplicate() as ItemBase

func _get_shop_tier(item_manager) -> int:
	if item_manager and item_manager.has_method("get_shop_tier"):
		return item_manager.get_shop_tier(wave_number)
	if wave_number >= 5:
		return clampi(2 + int((wave_number - 5) / 5), 1, 5)
	return 1

func _roll_reward() -> ItemBase:
	return _pick_reward(_get_reward_candidates())

func _is_good_reward(item: ItemBase, shop_tier: int, min_rarity_index: int, weapon_count: int) -> bool:
	if item == null:
		return false
	if _rarity_index(item.rarity) < min_rarity_index:
		return false
	if item is WeaponBase:
		var weapon := item as WeaponBase
		if weapon_count >= 6:
			return false
		return weapon.min_shop_tier <= min(shop_tier + 1, 5)
	return true

func _apply_reward(item: ItemBase) -> void:
	var main = get_tree().current_scene
	var player = get_tree().get_first_node_in_group("Player")
	var build_system = main.get_node_or_null("BuildSystem")
	var gd = get_node_or_null("/root/GameData")

	if item is WeaponBase and player and player.has_method("add_weapon"):
		if player.add_weapon(item as WeaponBase):
			_save_weapon_to_gamedata(item as WeaponBase, gd)
			_record_reward_item(item, main, gd)
	else:
		if build_system:
			build_system.add_item(item)
		_record_reward_item(item, main, gd)

	if main and main.has_method("_update_player_stats"):
		main._update_player_stats()

func _save_weapon_to_gamedata(weapon: WeaponBase, gd) -> void:
	if not gd:
		return
	var all_weapons := WeaponItemsClass.get_all_weapons()
	for i in range(all_weapons.size()):
		var candidate := all_weapons[i]
		if candidate.item_name == weapon.item_name and candidate.item_type == weapon.item_type:
			if not gd.pending_weapon_ids.has(i):
				gd.pending_weapon_ids.append(i)
			break

func _record_reward_item(item: ItemBase, main: Node, gd) -> void:
	if main and "items_collected" in main and not main.items_collected.has(item):
		main.items_collected.append(item)
	if gd and not gd.inventory.has(item):
		gd.add_inventory_item(item)

func _get_min_rarity_index_for_wave(wave: int) -> int:
	if wave >= 20:
		return _rarity_index("epic")
	return _rarity_index("rare")

func _rarity_index(rarity: String) -> int:
	match rarity.to_lower():
		"common":
			return 0
		"rare":
			return 1
		"epic":
			return 2
		"legendary":
			return 3
		_:
			return 0

func _show_reward_text(text_value: String) -> void:
	if _reward_label:
		_reward_label.text = text_value
		_reward_label.visible = true

func _play_open_effect() -> void:
	for child in get_children():
		if child is ColorRect:
			var rect := child as ColorRect
			var tween := create_tween()
			tween.tween_property(rect, "modulate:a", 0.0, 0.45)

	var label_tween := create_tween()
	label_tween.tween_property(_reward_label, "position:y", _reward_label.position.y - 35.0, 0.9)
	label_tween.parallel().tween_property(_reward_label, "modulate:a", 0.0, 0.9).set_delay(0.35)
	if _roll_panel:
		label_tween.parallel().tween_property(_roll_panel, "modulate:a", 0.0, 0.5).set_delay(0.25)
	label_tween.tween_callback(queue_free)

func _make_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.01, 0.02, 0.032, 0.98)
	style.border_color = Color(0.18, 0.78, 0.98, 0.95)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.shadow_color = Color(0, 0, 0, 0.65)
	style.shadow_size = 12
	return style

func _make_box_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_right = 3
	style.corner_radius_bottom_left = 3
	return style
