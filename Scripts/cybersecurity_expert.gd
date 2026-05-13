extends CharacterBody2D

@export var npc_name: String = "Ekspert Cyberbezpieczeństwa"

@export var expert_portrait: Texture2D = preload("res://Assets/Characters/cybersecuritySpecialist.png")
var dialogue_ui_scene: PackedScene = preload("res://scenes/DialogueUI.tscn")

var intro_shown: bool = false

func _ready() -> void:
	var anim := $AnimatedSprite2D as AnimatedSprite2D
	if anim:
		anim.play("standing")
	var interact := $InteractArea as Area2D
	if interact:
		interact.add_to_group("Interactable")

func interact() -> void:
	if not intro_shown:
		_show_intro_sequence()
	else:
		_show_random_tip()

func _show_intro_sequence() -> void:
	var intro_lines: Array[String] = [
		"Cześć, jestem Marek Nowak. Pełnię tu rolę Eksperta ds. Cyberbezpieczeństwa SOC.",
		"Witaj w centrum SOC (Security Operations Center). Nasza infrastruktura jest pod zmasowanym atakiem.",
		"Twoim zadaniem jest odpieranie fal wirusów, które zmaterializowały się w naszym systemie.",
		"Każda fala to 20 sekund intensywnej walki. Pamiętaj o używaniu uniku (Spacja)!",
		"Po każdej fali wrócisz tutaj. Możesz wtedy ulepszyć swój ekwipunek w sklepie Motorola.",
		"Będę tu, aby służyć Ci radą i wiedzą o zagrożeniach. Powodzenia, agencie!"
	]
	intro_shown = true
	_start_dialogue_ui(intro_lines)

func _show_random_tip() -> void:
	var tips: Array[String] = [
		"Worm (Robak) to wirus, który sam się replikuje. Musisz go szybko eliminować!",
		"SQL Injection to atak na bazy danych. W grze objawia się silnymi strzałami z dystansu.",
		"Ransomware blokuje dostęp do danych. Uważaj, by nie dać się otoczyć!",
		"Phishing to próba oszustwa. Uważaj na podejrzane obiekty na arenie.",
		"Pamiętaj, że w sklepie Motorola znajdziesz CrossPatch – zwiększa on Twój zasięg!",
		"Dodge Roll (Spacja) daje Ci ułamek sekundy nieśmiertelności. Używaj go mądrze.",
		"Zajrzyj do bestiariusza, aby poznać słabe punkty każdego typu wirusa!",
		"SQL Injection boi się szybkiego zbliżenia. Nie daj mu strzelać z dystansu!"
	]
	var tip: String = tips.pick_random()
	_start_dialogue_ui([tip])

func _start_dialogue_ui(lines: Array[String]) -> void:
	var ui = dialogue_ui_scene.instantiate()
	get_tree().root.add_child(ui)
	ui.start_dialogue(npc_name, expert_portrait, lines)
