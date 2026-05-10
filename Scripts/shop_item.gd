extends Panel
## UI pojedynczego itemu w sklepie

signal item_clicked(item: ItemBase)

var item_data: ItemBase
var current_gold: int

var icon_texture: TextureRect
var name_label: Label
var description_label: Label
var cost_label: Label
var rarity_label: Label
var buy_button: Button

func _ready() -> void:
	# Znajdź węzły bezpiecznie
	if has_node("HBoxContainer/IconTexture"):
		icon_texture = $HBoxContainer/IconTexture
	if has_node("HBoxContainer/VBoxContainer/NameLabel"):
		name_label = $HBoxContainer/VBoxContainer/NameLabel
	if has_node("HBoxContainer/VBoxContainer/DescriptionLabel"):
		description_label = $HBoxContainer/VBoxContainer/DescriptionLabel
	if has_node("HBoxContainer/VBoxContainer/HBoxContainer2/CostLabel"):
		cost_label = $HBoxContainer/VBoxContainer/HBoxContainer2/CostLabel
	if has_node("HBoxContainer/VBoxContainer/HBoxContainer2/RarityLabel"):
		rarity_label = $HBoxContainer/VBoxContainer/HBoxContainer2/RarityLabel
	if has_node("HBoxContainer/BuyButton"):
		buy_button = $HBoxContainer/BuyButton
		buy_button.pressed.connect(_on_buy_button_pressed)

func setup_item(item: ItemBase, gold: int) -> void:
	item_data = item
	current_gold = gold

	# Ustaw dane itemu
	if name_label:
		name_label.text = item_data.item_name
	if description_label:
		description_label.text = item_data.description
	if cost_label:
		cost_label.text = "Koszt: %d" % item_data.cost
	if rarity_label:
		rarity_label.text = item_data.rarity.capitalize()
		# Ustaw kolor rzadkości
		var rarity_color := item_data.get_rarity_color()
		rarity_label.modulate = rarity_color

	# Ustaw ikonę jeśli dostępna
	if item_data.icon and icon_texture:
		icon_texture.texture = item_data.icon

	# Ustaw przycisk
	update_affordability(gold)

func update_affordability(gold: int) -> void:
	current_gold = gold

	if buy_button:
		if current_gold >= item_data.cost:
			buy_button.disabled = false
			buy_button.text = "Kup"
		else:
			buy_button.disabled = true
			buy_button.text = "Brak złota"

func _on_buy_button_pressed() -> void:
	if current_gold >= item_data.cost:
		item_clicked.emit(item_data)