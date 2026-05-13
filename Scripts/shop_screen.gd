extends Control
## Ekran sklepu – 4 losowe bronie w kartach obok siebie + Reroll

const WeaponItemsClass := preload("res://Scripts/items/weapon_items.gd")

@onready var gold_label: Label = $TopBar/GoldLabel
@onready var items_container: HBoxContainer = $MainArea/ItemsContainer
@onready var back_button: Button = $BottomBar/BackButton
@onready var reroll_button: Button = $BottomBar/RerollButton
@onready var preview_icon: TextureRect = $MainArea/PreviewPanel/PreviewVBox/PreviewIcon
@onready var preview_name: Label = $MainArea/PreviewPanel/PreviewVBox/PreviewName
@onready var preview_rarity: Label = $MainArea/PreviewPanel/PreviewVBox/PreviewRarity
@onready var preview_desc: Label = $MainArea/PreviewPanel/PreviewVBox/PreviewDescription
@onready var preview_cost: Label = $MainArea/PreviewPanel/PreviewVBox/PreviewCost

var player_gold: int = 100
var all_weapons: Array[WeaponBase] = []
var shop_weapons: Array[WeaponBase] = []
var selected_weapon: WeaponBase = null
var buy_buttons: Array[Button] = []

const REROLL_COST: int = 25

var item_manager: Node = null
var build_system: Node = null
var shop_pool: Array = [] # Mix of WeaponBase and ItemBase

func _ready() -> void:
	var gd := get_node_or_null("/root/GameData")
	if gd:
		player_gold = gd.gold

	all_weapons = WeaponItemsClass.get_all_weapons()

	# Znajdź systemy w drzewie sceny (jeśli istnieją w MainGame)
	var main = get_tree().current_scene
	if main:
		item_manager = main.get_node_or_null("ItemManager")
		build_system = main.get_node_or_null("BuildSystem")

	back_button.pressed.connect(_on_back_pressed)
	reroll_button.pressed.connect(_on_reroll_pressed)

	_reroll_shop()

func _reroll_shop() -> void:
	for child in items_container.get_children():
		child.queue_free()
	buy_buttons.clear()

	shop_weapons.clear()
	# Grupuj bronie po typie, wybierz tylko 1 wersję (preferuj nowszą)
	var type_groups: Dictionary = {}
	for w: WeaponBase in all_weapons:
		if not type_groups.has(w.weapon_type):
			type_groups[w.weapon_type] = []
		type_groups[w.weapon_type].append(w)
	
	var pool: Array[WeaponBase] = []
	for weapon_type: String in type_groups.keys():
		var variants: Array = type_groups[weapon_type]
		if variants.size() == 1:
			pool.append(variants[0])
		else:
			# Wybierz wersję bez "old" prefixu (nowszą), fallback do pierwszej
			var chosen: WeaponBase = variants[0]
			for v in variants:
				if not v.is_old_variant:
					chosen = v
					break
			pool.append(chosen)
	
	# Wybierz 2 bronie i 2 itemy (lub 3 i 1)
	shop_pool.clear()
	
	pool.shuffle()
	for i in range(min(2, pool.size())):
		shop_pool.append(pool[i])
		
	if item_manager:
		var items: Array = item_manager.get_shop_items(2, 1) # 2 losowe itemy
		for it in items:
			shop_pool.append(it)
	
	shop_pool.shuffle()

	for i in range(shop_pool.size()):
		var item = shop_pool[i]
		var card := _create_item_card(item, i)
		items_container.add_child(card)

	_update_gold_label()
	_update_preview(null)

func _create_item_card(weapon: WeaponBase, weapon_index: int) -> Panel:
	var card := Panel.new()
	card.custom_minimum_size = Vector2(220, 320)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color(0.075, 0.106, 0.180, 0.9)
	card_style.border_width_left = 1
	card_style.border_width_right = 1
	card_style.border_width_top = 1
	card_style.border_width_bottom = 1
	card_style.border_color = Color(0.267, 0.278, 0.306)
	card_style.set_corner_radius_all(6)
	card.add_theme_stylebox_override("panel", card_style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	# Użyj kotwic zamiast flag, aby wypełnić Panel
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 10)
	vbox.mouse_filter = Control.MOUSE_FILTER_PASS
	card.add_child(vbox)

	# Ikona broni – wymuszony rozmiar 180x180
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(180, 180)
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if weapon.icon:
		icon.texture = weapon.icon
	vbox.add_child(icon)

	# Separator
	var sep := HSeparator.new()
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(sep)

	# Nazwa broni
	var name_lbl := Label.new()
	name_lbl.text = weapon.get_display_name()
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 16)
	name_lbl.add_theme_color_override("font_color", Color(0.855, 0.886, 0.992))
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(name_lbl)

	# Krótki opis
	var desc_lbl := Label.new()
	desc_lbl.text = weapon.description
	desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_lbl.add_theme_font_size_override("font_size", 11)
	desc_lbl.add_theme_color_override("font_color", Color(0.6, 0.65, 0.75))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.custom_minimum_size = Vector2(0, 32)
	desc_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(desc_lbl)

	# Cena
	var cost_lbl := Label.new()
	cost_lbl.text = "%d G" % weapon.cost
	cost_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_lbl.add_theme_font_size_override("font_size", 18)
	cost_lbl.add_theme_color_override("font_color", Color(0, 0.941, 1))
	cost_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(cost_lbl)

	# Przycisk KUP
	var buy_btn := Button.new()
	buy_btn.text = "KUP"
	buy_btn.custom_minimum_size = Vector2(0, 40)
	buy_btn.add_theme_font_size_override("font_size", 16)
	buy_btn.add_theme_color_override("font_color", Color.WHITE)
	buy_btn.mouse_filter = Control.MOUSE_FILTER_STOP

	var buy_style := StyleBoxFlat.new()
	buy_style.bg_color = Color(0, 0.941, 1, 0.25)
	buy_style.border_width_left = 1
	buy_style.border_width_right = 1
	buy_style.border_width_top = 1
	buy_style.border_width_bottom = 1
	buy_style.border_color = Color(0, 0.941, 1)
	buy_style.set_corner_radius_all(4)
	buy_btn.add_theme_stylebox_override("normal", buy_style)

	buy_btn.pressed.connect(_on_buy_pressed.bind(weapon, buy_btn, weapon_index))
	vbox.add_child(buy_btn)
	buy_buttons.append(buy_btn)

	# Kliknięcie karty = podgląd
	card.gui_input.connect(_on_card_clicked.bind(weapon))

	return card

func _on_card_clicked(event: InputEvent, item: Resource) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_update_preview(item)

func _update_preview(item: Resource) -> void:
	selected_weapon = item
	if not item:
		preview_icon.texture = null
		preview_name.text = "Wybierz przedmiot"
		preview_rarity.text = ""
		preview_desc.text = ""
		preview_cost.text = ""
		return

	if item.get("icon"):
		preview_icon.texture = item.get("icon")
	
	if item.has_method("get_display_name"):
		preview_name.text = item.call("get_display_name")
	else:
		preview_name.text = item.get("item_name")
		
	preview_rarity.text = item.get("rarity").capitalize()
	preview_rarity.add_theme_color_override("font_color", item.call("get_rarity_color"))
	
	if item is WeaponBase:
		preview_desc.text = item.description + "\n\nStatystyki:\n- Obrażenia: %0.1f\n- Szybkość: %0.2f s\n- Zasięg: %0.0f" % [item.damage, item.attack_speed, item.weapon_range]
	else:
		var stats_text := ""
		var stats_dict = item.get("stats")
		if stats_dict:
			stats_text = "\n\nPremie:\n"
			for sname in stats_dict:
				stats_text += "- %s: +%d%%\n" % [sname.capitalize(), int(stats_dict[sname] * 100)]
		preview_desc.text = item.description + stats_text
		
	preview_cost.text = "Koszt: %d G" % item.get("cost")

func _on_buy_pressed(item: Resource, button: Button, item_index: int) -> void:
	if player_gold < item.get("cost"):
		return

	player_gold -= item.get("cost")
	_update_gold_label()

	var gd := get_node_or_null("/root/GameData")
	if gd:
		gd.gold = player_gold
		
		if item is WeaponBase:
			var full_index := all_weapons.find(item)
			if full_index >= 0:
				gd.pending_weapon_ids.append(full_index)
		elif item is ItemBase:
			# Dodaj do buildu (jeśli jesteśmy w MainGame)
			if build_system:
				build_system.add_item(item)
			# Poinformuj MainGameController o nowym itemie
			var main = get_tree().current_scene
			if main and main.has_method("_on_item_purchased"):
				main.call("_on_item_purchased", item)

	button.disabled = true
	button.text = "KUPIONE"
	
	_update_preview(item)

func _on_reroll_pressed() -> void:
	if player_gold < REROLL_COST:
		return

	player_gold -= REROLL_COST
	var gd := get_node_or_null("/root/GameData")
	if gd:
		gd.gold = player_gold

	_reroll_shop()

func _update_gold_label() -> void:
	gold_label.text = "GOLD: %d" % player_gold

func _on_back_pressed() -> void:
	var gd := get_node_or_null("/root/GameData")
	if gd:
		gd.gold = player_gold
	get_tree().change_scene_to_file("res://scenes/GameStartScreen.tscn")
