extends Control
## System edukacyjny - popupy z wyjaśnieniami ataków

signal education_completed

var educational_content: Dictionary = {
	"worm": {
		"title": "WORM - SAMOREPLIKUJĄCY SIĘ ZŁOŚLIWY KOD",
		"description": "Worm (robak) to rodzaj złośliwego oprogramowania, który potrafi samodzielnie się rozprzestrzeniać w sieciach komputerowych. W przeciwieństwie do zwykłych wirusów, nie wymaga on działania użytkownika, aby się zainfekować.",
		"impact": "Robaki mogą szybko zainfekować całe sieci, powodując przeciążenie systemów, kradzież danych i tworząc botnety do ataków DDoS.",
		"prevention": "Ochrona: regularne aktualizacje systemu, firewall, antywirus, ograniczenie uprawnień użytkowników.",
		"real_world": "Przykład: WannaCry (2017) - zainfekował ponad 200,000 komputerów w 150 krajach, blokując szpitale i firmy."
	},
	"trojan": {
		"title": "TROJAN - UKRYTY ZŁOŚLIWY PROGRAM",
		"description": "Trojan (koń trojański) to złośliwy program udający legalne oprogramowanie. Często rozpowszechniany przez fałszywe pliki do pobrania lub załączniki email.",
		"impact": "Trojany mogą stworzyć tylne drzwi (backdoor) dla hakerów, kraść hasła, rejestrować naciśnięcia klawiszy i kontrolować komputer ofiary.",
		"prevention": "Ochrona: pobieraj programy tylko z zaufanych źródeł, weryfikuj podpisy cyfrowe, używaj antywirusa.",
		"real_world": "Przykład: Emotet - jeden z najgroźniejszych bankowych trojanów, powodujący straty w miliardach dolarów."
	},
	"ransomware": {
		"title": "RANSOMWARE - SZYFROWANIE I BLOKADA DANYCH",
		"description": "Ransomware to rodzaj złośliwego oprogramowania, które szyfruje pliki ofiary i żąda okupu za ich odblokowanie. Często rozpowszechniany przez phishing i exploity.",
		"impact": "Ransomware może całkowicie zablokować dostęp do danych, paraliżując firmy, szpitale i instytucje rządowe. Często łączy się z kradzieżą danych.",
		"prevention": "Ochrona: regularne kopie zapasowe (offline), edukacja pracowników, patchowanie systemów, segmentacja sieci.",
		"real_world": "Przykład: Colonial Pipeline (2021) - atak sparaliżował największy rurociąg paliw w USA, powodując braki benzyny."
	},
	"spyware": {
		"title": "SPYWARE - SZPIEGOWANIE I KRADZIEŻ DANYCH",
		"description": "Spyware to złośliwe oprogramowanie, które potajemnie zbiera informacje o użytkowniku. Może rejestrować naciśnięcia klawiszy, robić zrzuty ekranu i śledzić aktywność.",
		"impact": "Spyware kradze hasła, dane finansowe, informacje osobiste i tajemnice firmowe. Może być wykorzystany do szantażu i kradzieży tożsamości.",
		"prevention": "Ochrona: firewall, antyspyware, ostrożność z pobieraniem, VPN, unikanie podejrzanych stron.",
		"real_world": "Przykład: Pegasus - zaawansowany spyware używany do inwigilacji dziennikarzy i aktywistów."
	},
	"apt_boss": {
		"title": "APT - ADVANCED PERSISTENT THREAT",
		"description": "APT (Advanced Persistent Threat) to zaawansowany, długotrwały atak przeprowadzany przez grupy hakerskie sponsorowane przez państwa. Charakteryzuje się wysokim stopniem zaawansowania i celowością.",
		"impact": "APT może działać miesiącami lub latami w systemie ofiary, kradnąc tajemnice państwowe, technologie i dane strategiczne. Często atakuje krytyczną infrastrukturę.",
		"prevention": "Ochrona: zaawansowany monitoring, threat hunting, segmentacja sieci, edukacja, współpraca z służbami.",
		"real_world": "Przykład: APT29 (Cozy Bear) - rosyjska grupa odpowiedzialna za ataki na rządy i organizacje na całym świecie."
	},
	"phishing": {
		"title": "PHISHING - WYŁUDZANIE DANYCH",
		"description": "Phishing to metoda oszustwa, w której przestępca podszywa się pod inną osobę lub instytucję w celu wyłudzenia poufnych informacji (np. haseł, danych kart płatniczych).",
		"impact": "Może prowadzić do kradzieży tożsamości, utraty pieniędzy i nieautoryzowanego dostępu do kont firmowych.",
		"prevention": "Ochrona: sprawdzaj adresy e-mail nadawców, nie klikaj w podejrzane linki, używaj uwierzytelniania dwuskładnikowego (2FA).",
		"real_world": "Przykład: Masowe kampanie SMS podszywające się pod firmy kurierskie lub banki."
	},
	"sql": {
		"title": "SQL INJECTION - WSTRZYKIWANIE KODU",
		"description": "SQL Injection to atak polegający na wstrzyknięciu złośliwego kodu SQL do zapytania bazy danych poprzez luki w aplikacjach (np. pola formularzy).",
		"impact": "Pozwala atakującym na odczytanie wrażliwych danych, ich modyfikację lub usunięcie, a czasem nawet na przejęcie pełnej kontroli nad serwerem bazy danych.",
		"prevention": "Ochrona: stosowanie zapytań parametrycznych, walidacja danych wejściowych, ograniczanie uprawnień bazy danych.",
		"real_world": "Przykład: Atak na vBulletin (2019), gdzie hakerzy uzyskali dostęp do danych milionów użytkowników."
	}
}

var current_enemy_type: String = ""
var is_paused: bool = false

var title_label: Label
var description_label: Label
var impact_label: Label
var prevention_label: Label
var real_world_label: Label
var continue_button: Button
var _ui_font: Font
var _previous_hud_visible: bool = true
var _previous_flow_visible: bool = true

func _ready() -> void:
	_ui_font = preload("res://Assets/fonts/VT323-Regular.ttf")
	# Nowe ścieżki po przebudowie układu
	var base_path = "MainContainer/Panel/MarginContainer/VBoxContainer/"
	
	if has_node(base_path + "TitleLabel"):
		title_label = get_node(base_path + "TitleLabel")
	
	var content_path = base_path + "ScrollContainer/ContentBox/"
	if has_node(content_path + "DescriptionLabel"):
		description_label = get_node(content_path + "DescriptionLabel")
	if has_node(content_path + "ImpactLabel"):
		impact_label = get_node(content_path + "ImpactLabel")
	if has_node(content_path + "PreventionLabel"):
		prevention_label = get_node(content_path + "PreventionLabel")
	if has_node(content_path + "RealWorldLabel"):
		real_world_label = get_node(content_path + "RealWorldLabel")
		
	if has_node(base_path + "ContinueButton"):
		continue_button = get_node(base_path + "ContinueButton")
		continue_button.pressed.connect(_on_continue_pressed)

	_setup_visual_style()
	visible = false

func _setup_visual_style() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

	var bg := get_node_or_null("ColorRect") as ColorRect
	if bg:
		bg.color = Color(0.015, 0.045, 0.075, 0.82)

	var panel := get_node_or_null("MainContainer/Panel") as Panel
	if panel:
		panel.custom_minimum_size = Vector2(980, 660)
		var panel_style := StyleBoxFlat.new()
		panel_style.bg_color = Color(0.015, 0.025, 0.04, 0.96)
		panel_style.border_color = Color(0.2, 0.82, 1.0, 0.75)
		panel_style.border_width_left = 3
		panel_style.border_width_top = 3
		panel_style.border_width_right = 3
		panel_style.border_width_bottom = 3
		panel_style.corner_radius_top_left = 5
		panel_style.corner_radius_top_right = 5
		panel_style.corner_radius_bottom_right = 5
		panel_style.corner_radius_bottom_left = 5
		panel_style.shadow_color = Color(0, 0, 0, 0.55)
		panel_style.shadow_size = 18
		panel.add_theme_stylebox_override("panel", panel_style)

	var margin := get_node_or_null("MainContainer/Panel/MarginContainer") as MarginContainer
	if margin:
		margin.add_theme_constant_override("margin_left", 34)
		margin.add_theme_constant_override("margin_top", 28)
		margin.add_theme_constant_override("margin_right", 34)
		margin.add_theme_constant_override("margin_bottom", 28)

	var box := get_node_or_null("MainContainer/Panel/MarginContainer/VBoxContainer") as VBoxContainer
	if box:
		box.add_theme_constant_override("separation", 14)

	_style_label(title_label, 39, Color(0.86, 0.98, 1.0), true)
	if title_label:
		title_label.custom_minimum_size = Vector2(0, 76)
		title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	for label in [description_label, impact_label, prevention_label, real_world_label]:
		_style_label(label, 23, Color(0.84, 0.9, 0.94), false)

	var scroll := get_node_or_null("MainContainer/Panel/MarginContainer/VBoxContainer/ScrollContainer") as ScrollContainer
	if scroll:
		scroll.custom_minimum_size = Vector2(0, 390)

	if continue_button:
		continue_button.custom_minimum_size = Vector2(380, 72)
		continue_button.add_theme_font_override("font", _ui_font)
		continue_button.add_theme_font_size_override("font_size", 32)
		continue_button.add_theme_color_override("font_color", Color(0.92, 0.98, 1.0))
		continue_button.add_theme_color_override("font_hover_color", Color(1, 1, 1))
		continue_button.add_theme_stylebox_override("normal", _make_button_style(Color(0.08, 0.11, 0.15, 0.98), Color(0.28, 0.82, 1.0, 0.9)))
		continue_button.add_theme_stylebox_override("hover", _make_button_style(Color(0.11, 0.16, 0.2, 1.0), Color(0.54, 0.94, 1.0, 1.0)))
		continue_button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.25, 0.82, 1.0, 1.0), Color(0.25, 0.82, 1.0, 1.0)))

func _style_label(label: Label, font_size: int, color: Color, is_title: bool) -> void:
	if not label:
		return
	label.add_theme_font_override("font", _ui_font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.82))
	label.add_theme_constant_override("shadow_offset_x", 2 if is_title else 1)
	label.add_theme_constant_override("shadow_offset_y", 2 if is_title else 1)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _make_button_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	return style

func show_education(enemy_type: String) -> void:
	current_enemy_type = enemy_type

	if not educational_content.has(enemy_type):
		education_completed.emit()
		return

	var content: Dictionary = educational_content[enemy_type]

	# Ustaw teksty
	if title_label:
		title_label.text = str(content.get("title", ""))
	if description_label:
		description_label.text = "OPIS:\n" + str(content.get("description", ""))
	if impact_label:
		impact_label.text = "WPŁYW:\n" + str(content.get("impact", ""))
	if prevention_label:
		prevention_label.text = "OCHRONA:\n" + str(content.get("prevention", ""))
	if real_world_label:
		real_world_label.text = "PRZYKŁAD Z RZECZYWISTOŚCI:\n" + str(content.get("real_world", ""))
	
	if continue_button:
		continue_button.text = "KONTYNUUJ"

	# Pauzuj grę
	is_paused = true
	_set_combat_ui_visible(false)
	get_tree().paused = true

	# Pokaż popup
	visible = true

func _on_continue_pressed() -> void:
	# Ukryj popup
	visible = false

	# Wznów grę
	is_paused = false
	_restore_combat_ui()
	get_tree().paused = false

	education_completed.emit()

func _set_combat_ui_visible(is_visible: bool) -> void:
	var main := get_tree().current_scene
	if not main:
		return
	var hud := main.get_node_or_null("HUD") as CanvasLayer
	if hud:
		_previous_hud_visible = hud.visible
		hud.visible = is_visible
	var flow := main.get_node_or_null("FlowLayer") as CanvasLayer
	if flow:
		_previous_flow_visible = flow.visible
		flow.visible = is_visible

func _restore_combat_ui() -> void:
	var main := get_tree().current_scene
	if not main:
		return
	var hud := main.get_node_or_null("HUD") as CanvasLayer
	if hud:
		hud.visible = _previous_hud_visible
	var flow := main.get_node_or_null("FlowLayer") as CanvasLayer
	if flow:
		flow.visible = _previous_flow_visible

func show_intro() -> void:
	# Pokaż intro gry
	if title_label:
		title_label.text = "MOTODEFEND - CYBERBEZPIECZEŃSTWO W PRAKTYCE"
	if description_label:
		description_label.text = "Jesteś programistą bezpieczeństwa w Katowicach. Wirusy materializują się w realnym świecie jako agresywne pixelowe stwory. Twoim zadaniem jest ochrona miasta przed cyberatakami."
	if impact_label:
		impact_label.text = "Każdy wróg reprezentuje realne zagrożenie cybernetyczne."
	if prevention_label:
		prevention_label.text = "Walcz z wrogami, ucz się mechanizmów ataków i buduj systemy obrony!"
	if real_world_label:
		real_world_label.text = "Współpracuj z ekspertami i sprzętem Motorola Solutions."
	
	if continue_button:
		continue_button.text = "ROZPOCZNIJ GRĘ"

	is_paused = true
	_set_combat_ui_visible(false)
	get_tree().paused = true
	visible = true

func show_wave_info(wave_number: int) -> void:
	var wave_info: Dictionary = _get_wave_info(wave_number)

	if title_label:
		title_label.text = "FALA %d" % wave_number
	if description_label:
		description_label.text = str(wave_info.get("description", ""))
	if impact_label:
		impact_label.text = str(wave_info.get("enemies", ""))
	if prevention_label:
		prevention_label.text = "Przygotuj się!"
	if real_world_label:
		real_world_label.text = ""

	is_paused = true
	_set_combat_ui_visible(false)
	get_tree().paused = true
	visible = true

func show_pre_wave_education(wave_number: int) -> void:
	var content: Dictionary = _get_pre_wave_content(wave_number)

	if title_label:
		title_label.text = str(content.get("title", "NADCHODZĄCE ZAGROŻENIE"))
	if description_label:
		description_label.text = "CO CIĘ CZEKA:\n" + str(content.get("description", ""))
	if impact_label:
		impact_label.text = "DLACZEGO TO NIEBEZPIECZNE:\n" + str(content.get("impact", ""))
	if prevention_label:
		prevention_label.text = "JAK SIĘ Z TYM UPORAĆ:\n" + str(content.get("prevention", ""))
	if real_world_label:
		real_world_label.text = "PRZYKŁAD Z RZECZYWISTOŚCI:\n" + str(content.get("real_world", ""))

	if continue_button:
		continue_button.text = "PRZYGOTUJ SIĘ DO OBRONY"

	is_paused = true
	_set_combat_ui_visible(false)
	get_tree().paused = true
	visible = true

func _get_pre_wave_content(wave: int) -> Dictionary:
	var enemy_type := _get_enemy_type_for_wave(wave)
	if educational_content.has(enemy_type):
		var base: Dictionary = educational_content[enemy_type].duplicate()
		base["title"] = "FALA %d - %s" % [wave, base["title"]]
		base["description"] = "Nadchodząca fala przynosi nowe zagrożenie!\n\n" + base["description"]
		return base
	return {
		"title": "FALA %d - NIEZNANE ZAGROŻENIE" % wave,
		"description": "Nadchodząca fala przynosi nieznane zagrożenia cybernetyczne. Bądź czujny i przygotuj się na wszystko!",
		"impact": "Nieznane zagrożenia mogą wykorzystywać luki zero-day i nieprzetestowane wektory ataku.",
		"prevention": "Zachowaj ostrożność, używaj wielowarstwowej ochrony i regularnie aktualizuj systemy.",
		"real_world": "Ataki zero-day są jednymi z najgroźniejszych, ponieważ nie ma jeszcze patchy na odkryte luki."
	}

func _get_enemy_type_for_wave(wave: int) -> String:
	if wave == 1 or wave == 2:
		return "worm"
	elif wave == 3 or wave == 4:
		return "trojan"
	elif wave % 5 == 0:
		return "apt_boss"
	elif wave == 6 or wave == 7:
		return "ransomware"
	elif wave == 8 or wave == 9:
		return "spyware"
	elif wave == 11 or wave == 12:
		return "phishing"
	elif wave >= 13:
		return "sql"
	else:
		return "worm"

func _get_wave_info(wave: int) -> Dictionary:
	if wave == 1:
		return {
			"description": "Pierwsza fala ataku! Proste robaki zaczynają się pojawiać.",
			"enemies": "Wormy (Robaki)"
		}
	elif wave == 5:
		return {
			"description": "Boss alert! Zaawansowany persistent threat atakuje.",
			"enemies": "APT Boss"
		}
	elif wave == 6:
		return {
			"description": "Nowe zagrożenie! Trojany dołączają do ataku.",
			"enemies": "Wormy + Trojany"
		}
	elif wave == 10:
		return {
			"description": "Kolejny boss! Atak nasila się.",
			"enemies": "Wszystkie typy + APT Boss"
		}
	else:
		return {
			"description": "Kolejna fala ataku cybernetycznego.",
			"enemies": "Wrogowie cybernetyczni"
		}
