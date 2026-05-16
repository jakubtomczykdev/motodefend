extends CharacterBody2D
## Shopkeeper – NPC otwierający sklep po interakcji.
## Nie przekazuje golda ręcznie – shop_screen.gd czyta go z GameData przez property getter.

## Ścieżka do sceny sklepu dla fallbacku (poza MainGame)
const SHOP_SCENE_PATH: String = "res://scenes/Shop.tscn"

@export var npc_name: String = "Automat ze Sprzedażą"

func _ready() -> void:
	var anim := find_child("AnimatedSprite2D", true, false) as AnimatedSprite2D
	if anim:
		anim.play("MashineAnimation")
	var interact_area := find_child("InteractArea", true, false) as Area2D
	if interact_area:
		interact_area.add_to_group("Interactable")

## Otwiera sklep. W main_game_controller gold sync odbywa się automatycznie
## przez shop_screen.gd property getter → GameData.gold.
func interact() -> void:
	var main: Node = get_tree().current_scene
	
	# Zapisz pozycję gracza przed wyjściem do standalone shopu
	var gd := get_node_or_null("/root/GameData")
	var player = get_tree().get_first_node_in_group("Player")
	if gd and player:
		gd.last_player_position = player.global_position
		gd.should_restore_position = true
		gd.return_scene = main.scene_file_path
	
	if main and main.has_method("_open_shop"):
		main._open_shop()
	else:
		# Fallback: ładuj scenę sklepu jako standalone
		get_tree().change_scene_to_file(SHOP_SCENE_PATH)
