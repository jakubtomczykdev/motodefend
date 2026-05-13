extends CharacterBody2D

@export var npc_name: String = "Marek Nowak - SOC Lead"

@export var expert_portrait: Texture2D = preload("res://Assets/Characters/cybersecuritySpecialist.png")
var dialogue_ui_scene: PackedScene = preload("res://scenes/DialogueUI.tscn")

var intro_shown: bool = false
var interaction_count: int = 0

func _ready() -> void:
	var anim := $AnimatedSprite2D as AnimatedSprite2D
	if anim:
		anim.play("standing")
	var interact := $InteractArea as Area2D
	if interact:
		interact.add_to_group("Interactable")

func interact() -> void:
	interaction_count += 1
	if not intro_shown:
		_show_intro_sequence()
	else:
		_show_advanced_logic()

func _show_intro_sequence() -> void:
	var intro_lines: Array[String] = [
		"Witaj w sercu SOC (Security Operations Center). Nazywam się Marek Nowak i dowodzę tym sektorem.",
		"Sytuacja jest krytyczna. Nasza sieć została spenetrowana przez wielopoziomowe zagrożenia.",
		"Jako Agent SOC musisz fizycznie zneutralizować te pakiety danych, zanim zainfekują główny węzeł.",
		"Każda fala to 20 sekund walki o przetrwanie naszych baz danych. Wykorzystaj Unik (Spacja), by omijać detekcję!",
		"Pamiętaj: po starciu odwiedź maszynę Motorola. Ich sprzęt to jedyna rzecz, która nadąża za tą skalą infekcji.",
		"Zabezpiecz wejścia. Ja zajmę się analizą behawioralną w tle. Powodzenia!"
	]
	intro_shown = true
	_start_dialogue_ui(intro_lines)

func _show_advanced_logic() -> void:
	# Wybieraj logikę na podstawie kontekstu (np. liczby interakcji)
	if interaction_count % 5 == 0:
		_show_story_lore()
	else:
		_show_dynamic_tip()

func _show_story_lore() -> void:
	var lore_bits: Array[String] = [
		"Czy wiesz, że ten atak wygląda na skoordynowaną operację grupy APT? To nie są amatorzy.",
		"Analizuję nagłówki tych pakietów... Ktoś próbuje wyciągnąć nasze klucze deszyfrujące.",
		"Motorola dostarczyła nam nowe drony bojowe. Podobno ich firmware jest odporny na próby przejęcia.",
		"Ten system to labirynt. Jeśli padnie serwer główny, całe miasto straci łączność."
	]
	_start_dialogue_ui([lore_bits.pick_random()])

func _show_dynamic_tip() -> void:
	var tips: Array[String] = [
		"Ransomware to nie żart. Stosuj zasadę 3-2-1 dla swoich danych: 3 kopie, 2 nośniki, 1 offline.",
		"Widzisz te Wormy? One nie potrzebują Twojej zgody na replikację. Tnij je szybko, zanim skolonizują sieć!",
		"Phishing zawsze uderza w najsłabsze ogniwo – emocje. W grze porusza się tak, by Cię zmylić. Zachowaj zimną krew.",
		"SQL Injection to klasyczny błąd braku walidacji inputu. W grze przebija się przez proste osłony – miej to na uwadze.",
		"Zaktualizuj swój 'Firewall' w sklepie. Każdy punkt statystyk to dodatkowa warstwa Defense-in-Depth.",
		"Zaglądaj do Bestiariusza. Wiedza to najpotężniejszy exploit przeciwko wirusom.",
		"Jeśli poczujesz, że tracisz kontrolę, użyj Dodge Roll. To Twój osobisty system IPS (Intrusion Prevention System).",
		"Spyware zbiera dane w cieniu. Jeśli go nie widzisz, on na pewno widzi Ciebie. Skanuj arenę uważnie!"
	]
	var tip: String = tips.pick_random()
	_start_dialogue_ui(["[PORADA SOC]: " + tip])

func _start_dialogue_ui(lines: Array[String]) -> void:
	var ui = dialogue_ui_scene.instantiate()
	get_tree().root.add_child(ui)
	ui.start_dialogue(npc_name, expert_portrait, lines)
