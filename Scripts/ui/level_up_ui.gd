extends Control

## LevelUpUI – Obsługuje wybór ulepszeń po awansie poziomu.

signal upgrade_selected(upgrade)

@onready var cards_container: HBoxContainer = %CardsContainer

func _ready() -> void:
	visible = false

func show_upgrades(upgrades: Array) -> void:
	visible = true
	get_tree().paused = true
	
	# Wyczyść poprzednie karty
	for child in cards_container.get_children():
		child.queue_free()
	
	for upgrade in upgrades:
		var btn = Button.new()
		btn.text = upgrade.name + "\n\n" + upgrade.description
		btn.custom_minimum_size = Vector2(250, 350)
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.pressed.connect(_on_upgrade_pressed.bind(upgrade))
		cards_container.add_child(btn)
	
	# Focus na pierwszy przycisk dla obsługi padem/klawiaturą
	if cards_container.get_child_count() > 0:
		cards_container.get_child(0).grab_focus()

func _on_upgrade_pressed(upgrade) -> void:
	visible = false
	upgrade_selected.emit(upgrade)
	# Odpauzowanie następuje w MainGameController po przetworzeniu sygnału
