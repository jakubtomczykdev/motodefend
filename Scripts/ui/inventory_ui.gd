extends CanvasLayer

## InventoryUI – Obsługuje wyświetlanie przedmiotów gracza.

@onready var items_container: VBoxContainer = $Panel/VBoxContainer/ItemsContainer
@onready var close_button: Button = $Panel/VBoxContainer/CloseButton

func _ready() -> void:
	visible = false
	close_button.pressed.connect(_on_close_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_focus_next") or (event is InputEventKey and event.keycode == KEY_I and event.pressed):
		_toggle_inventory()

func _toggle_inventory() -> void:
	visible = !visible
	if visible:
		_update_inventory()
		get_tree().paused = true
	else:
		get_tree().paused = false

func _update_inventory() -> void:
	# Wyczyść stare
	for child in items_container.get_children():
		child.queue_free()
	
	var gd = get_node_or_null("/root/GameData")
	if not gd: return
	
	for item in gd.inventory:
		var label = Label.new()
		label.text = "• " + item.item_name
		if item.has_method("get_rarity_color"):
			label.modulate = item.get_rarity_color()
		items_container.add_child(label)

func _on_close_pressed() -> void:
	visible = false
	get_tree().paused = false
