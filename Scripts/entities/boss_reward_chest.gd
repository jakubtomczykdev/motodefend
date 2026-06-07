extends Node2D

signal opened

const WeaponItemsClass := preload("res://Scripts/entities/weapon_items.gd")
const UI_FONT := preload("res://Assets/fonts/VT323-Regular.ttf")
const BOSS_CHEST_TEXTURE := preload("res://Assets/boss_reward_chest_v2.png")

var wave_number: int = 1
var _opened: bool = false
var _is_rolling: bool = false
var _label: Label
var _reward_label: Label
var _roll_panel: PanelContainer
var _roll_name: Label
var _roll_rarity: Label
var _roll_icon: TextureRect
var _chest_sprite: Sprite2D
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

	if reward and _apply_reward(reward):
		_show_reward_text("ZDOBYTO: " + reward.item_name)
	else:
		_grant_fallback_gold()

	opened.emit()
	_play_open_effect()

func _build_visuals() -> void:
	_add_pixel_rect("ChestShadow", Vector2(-42, 22), Vector2(84, 12), Color(0.0, 0.0, 0.0, 0.42), 0)
	_add_pixel_rect("ChestBackGlow", Vector2(-43, -36), Vector2(86, 66), Color(0.0, 0.72, 0.92, 0.20), 0)

	_chest_sprite = Sprite2D.new()
	_chest_sprite.name = "ChestSprite"
	_chest_sprite.texture = BOSS_CHEST_TEXTURE
	_chest_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_chest_sprite.position = Vector2(0, -8)
	_chest_sprite.scale = Vector2(0.12, 0.12)
	_chest_sprite.z_index = 8
	add_child(_chest_sprite)

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
	if _chest_sprite:
		var sprite_tween := create_tween()
		sprite_tween.tween_property(_chest_sprite, "scale", Vector2(0.13, 0.105), 0.12)
		sprite_tween.parallel().tween_property(_chest_sprite, "modulate", Color(1.25, 1.45, 1.45, 1.0), 0.12)
		sprite_tween.tween_property(_chest_sprite, "scale", Vector2(0.12, 0.12), 0.16)
		sprite_tween.parallel().tween_property(_chest_sprite, "modulate", Color.WHITE, 0.16)

		var flash := ColorRect.new()
		flash.name = "ChestUnlockFlash"
		flash.color = Color(0.35, 0.95, 1.0, 0.5)
		flash.size = Vector2(76, 6)
		flash.pivot_offset = flash.size / 2.0
		flash.position = Vector2(-38, -7)
		flash.z_index = 12
		add_child(flash)
		var flash_tween := create_tween()
		flash_tween.tween_property(flash, "scale:x", 1.45, 0.16)
		flash_tween.parallel().tween_property(flash, "modulate:a", 0.0, 0.2)
		flash_tween.tween_callback(flash.queue_free)

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

	if reward and not pool.is_empty():
		await _play_cs_roll_strip(pool, reward)
	else:
		_roll_name.text = "+%d ZLOTA" % BalanceData.BOSS_FALLBACK_GOLD_REWARD
		_roll_rarity.text = "AWARYJNY DROP"
		_roll_rarity.add_theme_color_override("font_color", Color(1.0, 0.86, 0.28))
		await get_tree().create_timer(0.35).timeout

func _play_cs_roll_strip(pool: Array[ItemBase], reward: ItemBase) -> void:
	for child in _roll_panel.get_children():
		child.queue_free()

	_roll_panel.position = Vector2(-260, -210)
	_roll_panel.size = Vector2(520, 122)
	_roll_panel.scale = Vector2.ONE

	var root := Control.new()
	root.clip_contents = true
	root.custom_minimum_size = Vector2(520, 122)
	_roll_panel.add_child(root)

	var title := Label.new()
	title.text = "OTWIERANIE CACHE | LOSOWANIE NAGRODY"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", UI_FONT)
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(0.62, 0.92, 1.0))
	title.position = Vector2(0, 4)
	title.size = Vector2(520, 24)
	root.add_child(title)

	var viewport := Control.new()
	viewport.clip_contents = true
	viewport.position = Vector2(16, 32)
	viewport.size = Vector2(488, 76)
	root.add_child(viewport)

	var track := HBoxContainer.new()
	track.add_theme_constant_override("separation", 8)
	track.position = Vector2(250, 0)
	viewport.add_child(track)

	var sequence: Array[ItemBase] = []
	var roll_count := 25
	for i in range(roll_count - 1):
		sequence.append(pool.pick_random())
	sequence.append(reward)

	for item in sequence:
		track.add_child(_make_roll_card(item, _items_match(item, reward)))

	var selector := ColorRect.new()
	selector.color = Color(1.0, 0.86, 0.28, 0.95)
	selector.position = Vector2(257, 30)
	selector.size = Vector2(3, 82)
	root.add_child(selector)

	var card_width := 86.0
	var final_center_x := float(sequence.size() - 1) * card_width + card_width * 0.5
	var target_x := 244.0 - final_center_x
	var roll_tween := create_tween()
	roll_tween.tween_property(track, "position:x", target_x, 2.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await roll_tween.finished

	var flash := create_tween()
	flash.tween_property(_roll_panel, "scale", Vector2(1.06, 1.06), 0.12)
	flash.tween_property(_roll_panel, "scale", Vector2.ONE, 0.16)
	await flash.finished

func _make_roll_card(item: ItemBase, is_reward: bool = false) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(78, 74)
	var border := item.get_rarity_color() if item and item.has_method("get_rarity_color") else Color(0.35, 0.94, 1.0)
	card.add_theme_stylebox_override("panel", _make_box_style(Color(0.02, 0.04, 0.06, 0.96), border if is_reward else border.darkened(0.25)))

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 1)
	card.add_child(box)

	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(42, 38)
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if item and "icon" in item:
		icon.texture = item.icon
	box.add_child(icon)

	var name := Label.new()
	name.text = item.item_name.to_upper() if item else "???"
	name.clip_text = true
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name.add_theme_font_override("font", UI_FONT)
	name.add_theme_font_size_override("font_size", 14)
	name.add_theme_color_override("font_color", border if is_reward else Color(0.86, 0.94, 1.0))
	name.custom_minimum_size = Vector2(70, 18)
	box.add_child(name)
	return card

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
		if weapon_count >= BalanceData.MAX_WEAPON_SLOTS:
			return false
		return weapon.min_shop_tier <= min(shop_tier + 1, 5)
	return true

func _apply_reward(item: ItemBase) -> bool:
	var main = get_tree().current_scene
	var player = get_tree().get_first_node_in_group("Player")
	var build_system = main.get_node_or_null("BuildSystem")
	var gd = get_node_or_null("/root/GameData")
	var added_to_build := false

	if build_system:
		if not build_system.add_item(item):
			return false
		added_to_build = true

	if item is WeaponBase:
		if not player or not player.has_method("add_weapon"):
			if added_to_build and build_system:
				build_system.remove_item(item)
			return false
		if not player.add_weapon(item as WeaponBase):
			if added_to_build and build_system:
				build_system.remove_item(item)
			return false
		_save_weapon_to_gamedata(item as WeaponBase, gd)
		_record_reward_item(item, main, gd)
	else:
		_record_reward_item(item, main, gd)

	if main and main.has_method("_update_player_stats"):
		main._update_player_stats()
	return true

func _grant_fallback_gold() -> void:
	var amount := BalanceData.BOSS_FALLBACK_GOLD_REWARD
	_show_reward_text("ZDOBYTO: +%d ZLOTA" % amount)
	var gd := get_node_or_null("/root/GameData")
	if gd:
		gd.gold += amount
		if gd.has_method("record_gold_income"):
			gd.record_gold_income("boss_fallback", amount, wave_number)

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

func _get_current_build_count(build_system, gd) -> int:
	if build_system:
		var build_items = build_system.get("items")
		if build_items is Array:
			return build_items.size()
	if gd:
		return gd.inventory.size()
	return 0

func _get_max_build_slots(build_system) -> int:
	if build_system:
		var max_slots = build_system.get("max_item_slots")
		if max_slots != null:
			return int(max_slots)
	return BalanceData.MAX_BUILD_SLOTS

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

func _items_match(left: ItemBase, right: ItemBase) -> bool:
	if left == null or right == null:
		return false
	return left.item_name == right.item_name and left.item_type == right.item_type

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
		elif child is Sprite2D:
			var sprite := child as Sprite2D
			var sprite_tween := create_tween()
			sprite_tween.tween_property(sprite, "modulate:a", 0.0, 0.45).set_delay(0.2)

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
