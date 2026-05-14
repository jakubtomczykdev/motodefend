extends Panel
## Skrypt pojedynczego przedmiotu w sklepie - zaktualizowany pod nowy design

signal item_clicked(item: ItemBase)

@onready var icon_texture: TextureRect = $VBox/IconContainer/IconTexture
@onready var name_label: Label = $VBox/NameLabel
@onready var rarity_chip: Label = $VBox/RarityChip
@onready var description_label: Label = $VBox/DescriptionLabel
@onready var cost_label: Label = $VBox/CostBox/CostLabel
@onready var buy_button: Button = $VBox/BuyButton

var item_data: ItemBase
var is_inventory_mode: bool = false

func _ready() -> void:
	if buy_button:
		buy_button.pressed.connect(_on_buy_pressed)
	
	# Efekty najechania myszką
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func setup_item(item: ItemBase, current_gold: int) -> void:
	item_data = item
	name_label.text = item.item_name.to_upper()
	
	if is_inventory_mode:
		var sell_price = int(item.cost * 0.5)
		cost_label.text = str(sell_price)
	else:
		cost_label.text = str(item.cost)
	
	if description_label:
		description_label.text = item.description
	
	if item.icon:
		icon_texture.texture = item.icon
	
	_update_rarity_style(item.rarity)
	update_affordability(current_gold)

func _update_rarity_style(rarity: String) -> void:
	rarity_chip.text = rarity.to_upper()
	var color := Color(1, 1, 1)
	
	match rarity.to_lower():
		"common": color = Color(0.7, 0.7, 0.7) # Slate
		"uncommon": color = Color(0.3, 0.8, 0.5) # Teal
		"rare": color = Color(0, 0.6, 1.0) # Cyber Blue
		"epic": color = Color(0.6, 0.2, 0.9) # Purple
		"legendary": color = Color(1.0, 0.8, 0.0) # Gold
	
	rarity_chip.modulate = color
	
	# Apply glow to the panel border
	var style = get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	style.border_color = color
	style.border_color.a = 0.5
	add_theme_stylebox_override("panel", style)

func update_affordability(gold: int) -> void:
	if is_inventory_mode:
		buy_button.disabled = false
		buy_button.modulate = Color(1, 0.4, 0.4, 1.0)
		buy_button.text = "SPRZEDAJ"
		return

	if gold < item_data.cost:
		buy_button.disabled = true
		buy_button.modulate = Color(1, 1, 1, 0.5)
		buy_button.text = "Za mało złota"
	else:
		buy_button.disabled = false
		buy_button.modulate = Color(1, 1, 1, 1.0)
		buy_button.text = "Kup"

func set_as_inventory_item() -> void:
	is_inventory_mode = true
	if is_node_ready():
		buy_button.text = "SPRZEDAJ"
		buy_button.modulate = Color(1, 0.4, 0.4, 1.0)

func _on_buy_pressed() -> void:
	item_clicked.emit(item_data)

func _on_mouse_entered() -> void:
	# Subtle scale up and border highlight
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.02, 1.02), 0.1)
	
	var style = get_theme_stylebox("panel") as StyleBoxFlat
	style.bg_color.a = 1.0

func _on_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	
	var style = get_theme_stylebox("panel") as StyleBoxFlat
	style.bg_color.a = 0.9
