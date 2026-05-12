extends Control
## Ekran sklepu – roguelike arena-survivor UI
## Lewo: podgląd itemu | Prawo: lista kart | Góra: tytuł + gold | Dół: POWRÓT

const WeaponItemsClass := preload("res://Scripts/items/weapon_items.gd")

@onready var gold_label: Label = $TopBar/GoldLabel
@onready var items_container: VBoxContainer = $MainArea/ItemsScroll/ItemsContainer
@onready var back_button: Button = $BottomBar/BackButton

# Preview nodes
@onready var preview_icon: TextureRect = $MainArea/PreviewPanel/PreviewVBox/PreviewIcon
@onready var preview_name: Label = $MainArea/PreviewPanel/PreviewVBox/PreviewName
@onready var preview_rarity: Label = $MainArea/PreviewPanel/PreviewVBox/PreviewRarity
@onready var preview_desc: Label = $MainArea/PreviewPanel/PreviewVBox/PreviewDescription
@onready var preview_cost: Label = $MainArea/PreviewPanel/PreviewVBox/PreviewCost

var player_gold: int = 100
var weapon_items: Array[WeaponBase] = []
var selected_weapon: WeaponBase = null
var buy_buttons: Array[Button] = []

func _ready() -> void:
	var gd := get_node_or_null("/root/GameData")
	if gd:
		player_gold = gd.gold

	weapon_items = WeaponItemsClass.get_all_weapons()
	_setup_items()
	_update_gold_label()
	_update_preview(null)
	back_button.pressed.connect(_on_back_pressed)

func _setup_items() -> void:
	for weapon in weapon_items:
		var card := _create_item_card(weapon)
		items_container.add_child(card)

func _create_item_card(weapon: WeaponBase) -> Panel:
	var card := Panel.new()
	card.layout_mode = 2

	var hbox := HBoxContainer.new()
	hbox.layout_mode = 2
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.add_theme_constant_override("separation", 10)
	card.add_child(hbox)

	# Icon (left part of card)
	var icon := TextureRect.new()
	icon.layout_mode = 2
	icon.custom_minimum_size = Vector2(80, 80)
	icon.expand_mode = 0
	icon.stretch_mode = 5
	if weapon.icon:
		icon.texture = weapon.icon
	hbox.add_child(icon)

	# Info (middle)
	var info_vbox := VBoxContainer.new()
	info_vbox.layout_mode = 2
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var name_lbl := Label.new()
	name_lbl.text = weapon.get_display_name()
	name_lbl.add_theme_font_size_override("font_size", 18)
	info_vbox.add_child(name_lbl)

	var desc_lbl := Label.new()
	desc_lbl.text = weapon.description
	desc_lbl.add_theme_font_size_override("font_size", 13)
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_vbox.add_child(desc_lbl)

	var cost_lbl := Label.new()
	cost_lbl.text = "Koszt: %d G" % weapon.cost
	cost_lbl.add_theme_font_size_override("font_size", 16)
	cost_lbl.add_theme_color_override("font_color", Color(1, 0.84, 0))
	info_vbox.add_child(cost_lbl)

	hbox.add_child(info_vbox)

	# Buy button (right)
	var buy_btn := Button.new()
	buy_btn.text = "KUP"
	buy_btn.custom_minimum_size = Vector2(80, 0)
	buy_btn.add_theme_font_size_override("font_size", 18)
	buy_btn.pressed.connect(_on_buy_pressed.bind(weapon, buy_btn))
	hbox.add_child(buy_btn)
	buy_buttons.append(buy_btn)

	# Click on entire card selects the weapon for preview
	card.gui_input.connect(_on_card_clicked.bind(weapon))
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	return card

func _on_card_clicked(event: InputEvent, weapon: WeaponBase) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_update_preview(weapon)

func _update_preview(weapon: WeaponBase) -> void:
	selected_weapon = weapon
	if not weapon:
		preview_icon.texture = null
		preview_name.text = "Wybierz przedmiot"
		preview_rarity.text = ""
		preview_desc.text = ""
		preview_cost.text = ""
		return

	if weapon.icon:
		preview_icon.texture = weapon.icon
	preview_name.text = weapon.get_display_name()
	preview_rarity.text = weapon.rarity.capitalize()
	preview_rarity.add_theme_color_override("font_color", weapon.get_rarity_color())
	preview_desc.text = weapon.description
	preview_cost.text = "Koszt: %d G" % weapon.cost
	preview_cost.add_theme_color_override("font_color", Color(1, 0.84, 0))

func _on_buy_pressed(weapon: WeaponBase, button: Button) -> void:
	if player_gold < weapon.cost:
		return

	player_gold -= weapon.cost
	_update_gold_label()

	var gd := get_node_or_null("/root/GameData")
	if gd:
		gd.gold = player_gold
		if not gd.has("pending_weapon_ids"):
			gd.pending_weapon_ids = []
		gd.pending_weapon_ids.append(weapon.weapon_name)

	button.disabled = true
	button.text = "KUPIONE"

func _update_gold_label() -> void:
	gold_label.text = "GOLD: %d" % player_gold

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/GameStartScreen.tscn")
