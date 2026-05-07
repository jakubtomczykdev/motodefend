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
		"title": "SPYWARE - SZPIEGOWANIE I KRAŹDŹ DANYCH",
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

func _ready() -> void:
	# Znajdź węzły bezpiecznie
	if has_node("Panel/VBoxContainer/TitleLabel"):
		title_label = $Panel/VBoxContainer/TitleLabel
	if has_node("Panel/VBoxContainer/DescriptionLabel"):
		description_label = $Panel/VBoxContainer/DescriptionLabel
	if has_node("Panel/VBoxContainer/ImpactLabel"):
		impact_label = $Panel/VBoxContainer/ImpactLabel
	if has_node("Panel/VBoxContainer/PreventionLabel"):
		prevention_label = $Panel/VBoxContainer/PreventionLabel
	if has_node("Panel/VBoxContainer/RealWorldLabel"):
		real_world_label = $Panel/VBoxContainer/RealWorldLabel
	if has_node("Panel/VBoxContainer/ContinueButton"):
		continue_button = $Panel/VBoxContainer/ContinueButton
		continue_button.pressed.connect(_on_continue_pressed)

	visible = false

func show_education(enemy_type: String) -> void:
	current_enemy_type = enemy_type

	if not educational_content.has(enemy_type):
		education_completed.emit()
		return

	var content: Dictionary = educational_content[enemy_type] as Dictionary

	# Ustaw teksty
	if title_label:
		title_label.text = content["title"] as String
	if description_label:
		description_label.text = "OPIS:\n" + (content["description"] as String)
	if impact_label:
		impact_label.text = "WPŁYW:\n" + (content["impact"] as String)
	if prevention_label:
		prevention_label.text = "OCHRONA:\n" + (content["prevention"] as String)
	if real_world_label:
		real_world_label.text = "PRZYKŁAD Z RZECZYWISTOŚCI:\n" + (content["real_world"] as String)

	# Pauzuj grę
	is_paused = true
	get_tree().paused = true

	# Pokaż popup
	visible = true

func _on_continue_pressed() -> void:
	# Ukryj popup
	visible = false

	# Wznów grę
	is_paused = false
	get_tree().paused = false

	education_completed.emit()

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

	is_paused = true
	get_tree().paused = true
	visible = true

func show_wave_info(wave_number: int) -> void:
	var wave_info: Dictionary = _get_wave_info(wave_number)

	if title_label:
		title_label.text = "FALA %d" % wave_number
	if description_label:
		description_label.text = wave_info["description"] as String
	if impact_label:
		impact_label.text = wave_info["enemies"] as String
	if prevention_label:
		prevention_label.text = "Przygotuj się!"
	if real_world_label:
		real_world_label.text = ""

	is_paused = true
	get_tree().paused = true
	visible = true

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