extends CanvasLayer
## LaptopBestiaryUI – bestiariusz wyświetlany na ekranie laptopa (cyberpunk design)

@onready var enemy_list: ItemList = %EnemyList
@onready var enemy_sprite: TextureRect = %EnemySprite
@onready var enemy_name: Label = %EnemyName
@onready var lore_label: RichTextLabel = %LoreLabel
@onready var definition_label: RichTextLabel = %DefinitionLabel
@onready var scan_line: ColorRect = $Control/LaptopFrame/ScreenContainer/ScanLine

var enemies_data = [
	{
		"name": "Worm (Robak Sieciowy)",
		"lore": "[i]Segmentowany, wijący się stwór złożony z węzłów danych. Replikuje się w mgnieniu oka — każdy fragment jego ciała może odrodzić się jako nowy osobnik.[/i]\n\nNa arenie pojawia się w rojach, które szybko wymykają się spod kontroli.",
		"definition": "[color=#4ecdc4][b]OPIS ZAGROŻENIA[/b][/color]\nSamoreplikujący się program złośliwy, który rozprzestrzenia się bez udziału użytkownika, wykorzystując luki w protokołach sieciowych (np. SMB). W przeciwieństwie do wirusa, robak nie potrzebuje 'nosiciela' (pliku wykonywalnego).\n\n[color=#f1c40f][b]MERYTORYKA SOC[/b][/color]\n• [b]Wektor:[/b] Luki w usługach sieciowych, otwarte porty.\n• [b]Mechanizm:[/b] Skanowanie sieci i automatyczna infekcja.\n• [b]Obrona:[/b] Patching, firewalle, segmentacja sieci.\n\n[color=#e74c3c][b]DANE WYWIADOWCZE (GRA)[/b][/color]\nSzybki, pojawia się w grupach. Niszcz go priorytetowo, by uniknąć zalania areny.\n\n[color=#95a5a6][b]HISTORIA:[/b][/color] Morris Worm, Stuxnet.",
		"icon": preload("res://Assets/Characters/worm.png")
	},
	{
		"name": "Trojan (Koń Trojański)",
		"lore": "[i]Podstępny byt ukryty pod pozorem nieszkodliwego pakietu danych. Gdy już znajdzie się wewnątrz systemu, otwiera tylne furtki (Backdoors) dla kolejnych zagrożeń.[/i]",
		"definition": "[color=#4ecdc4][b]OPIS ZAGROŻENIA[/b][/color]\nOprogramowanie, które podszywa się pod użyteczne aplikacje, by skłonić użytkownika do jego uruchomienia. Kluczowy element infekcji wieloetapowych.\n\n[color=#f1c40f][b]MERYTORYKA SOC[/b][/color]\n• [b]Typy:[/b] RAT, Banker, Dropper.\n• [b]Zagrożenie:[/b] Utrata prywatności, kradzież haseł.\n• [b]Obrona:[/b] Zaufane źródła, skanowanie antywirusowe.\n\n[color=#e74c3c][b]DANE WYWIADOWCZE (GRA)[/b][/color]\nWytrzymały przeciwnik. Często maskuje się przed atakami obszarowymi.\n\n[color=#95a5a6][b]HISTORIA:[/b][/color] Emotet, Zeus.",
		"icon": preload("res://Assets/Characters/Trojan.png")
	},
	{
		"name": "Ransomware (Szyfrator)",
		"lore": "[i]Mroczna, ociężała postać bestii. Każdy jej krok przybliża cyfrową zagładę — gdy dopadnie ofiarę, zamyka jej dane w nieprzeniknionym szyfrze.[/i]",
		"definition": "[color=#4ecdc4][b]OPIS ZAGROŻENIA[/b][/color]\nZłośliwe oprogramowanie szyfrujące pliki użytkownika przy użyciu silnych algorytmów (np. AES-256). Żąda okupu za klucz deszyfrujący.\n\n[color=#f1c40f][b]MERYTORYKA SOC[/b][/color]\n• [b]Szyfrowanie:[/b] Hybrydowe (RSA + AES).\n• [b]Ewolucja:[/b] Double Extortion (szyfrowanie + kradzież).\n• [b]Obrona:[/b] Reguła 3-2-1 (Backup offline).\n\n[color=#e74c3c][b]DANE WYWIADOWCZE (GRA)[/b][/color]\nWolny, ale potężny. Unikaj kontaktu bezpośredniego za wszelką cenę.\n\n[color=#95a5a6][b]HISTORIA:[/b][/color] WannaCry, LockBit.",
		"icon": preload("res://Assets/Characters/Ransomware.png")
	},
	{
		"name": "SQL Injection",
		"lore": "[i]Widmowy byt utkany z linijek kodu. Wstrzykuje się w szczeliny systemu niczym igła, by wydobyć najgłębiej skrywane sekrety baz danych.[/i]",
		"definition": "[color=#4ecdc4][b]OPIS ZAGROŻENIA[/b][/color]\nAtak polegający na manipulacji zapytaniem SQL poprzez wprowadzenie złośliwego kodu do formularzy WWW.\n\n[color=#f1c40f][b]MERYTORYKA SOC[/b][/color]\n• [b]Przyczyna:[/b] Brak walidacji danych wejściowych.\n• [b]Skutki:[/b] Wycieki haseł, usuwanie baz danych.\n• [b]Obrona:[/b] Parametryzowane zapytania, WAF.\n\n[color=#e74c3c][b]DANE WYWIADOWCZE (GRA)[/b][/color]\nAtakuje z dystansu. Pociski omijają niektóre bariery.\n\n[color=#9b59b6][b]WSKAZÓWKA:[/b][/color] Nigdy nie ufaj danym od użytkownika.",
		"icon": preload("res://Assets/Characters/sql.png")
	},
	{
		"name": "Phishing (Wyłudzanie)",
		"lore": "[i]Sprytny oszust podrzuca sfałszowane pakiety. Porusza się zygzakiem i próbuje 'złowić' gracza na fałszywe powiadomienia.[/i]",
		"definition": "[color=#4ecdc4][b]OPIS ZAGROŻENIA[/b][/color]\nTechnika socjotechniczna polegająca na podszywaniu się pod zaufaną osobę lub instytucję w celu wyłudzenia haseł.\n\n[color=#f1c40f][b]MERYTORYKA SOC[/b][/color]\n• [b]Warianty:[/b] Smishing, Vishing, Spear Phishing.\n• [b]Zagrożenie:[/b] Kradzież tożsamości.\n• [b]Obrona:[/b] Weryfikacja nadawcy, 2FA (U2F).\n\n[color=#e74c3c][b]DANE WYWIADOWCZE (GRA)[/b][/color]\nSzybki i trudny do trafienia. Zadaje obrażenia 'mentalne'.\n\n[color=#9b59b6][b]PRZYKŁAD:[/b][/color] SMS o 'niedopłacie za paczkę'.",
		"icon": preload("res://Assets/Characters/phishing.png")
	},
	{
		"name": "Spyware (Szpieg)",
		"lore": "[i]Pajęczak śledzący każdy ruch. Nie atakuje bezpośrednio — zbiera informacje i przekazuje dane swoim mrocznym mocodawcom.[/i]",
		"definition": "[color=#4ecdc4][b]OPIS ZAGROŻENIA[/b][/color]\nOprogramowanie zbierające informacje o użytkowniku bez jego wiedzy (historia, hasła, lokalizacja).\n\n[color=#f1c40f][b]MERYTORYKA SOC[/b][/color]\n• [b]Keylogger:[/b] Przechwytuje każde naciśnięcie klawisza.\n• [b]Adware:[/b] Wyświetla niechciane reklamy.\n• [b]Obrona:[/b] Antyspyware, blokowanie skryptów.\n\n[color=#e74c3c][b]DANE WYWIADOWCZE (GRA)[/b][/color]\nNiewidoczny, dopóki nie podejdzie blisko. Wykrywaj go sensorami.\n\n[color=#95a5a6][b]HISTORIA:[/b][/color] Pegasus.",
		"icon": preload("res://Assets/Characters/phishing.png")
	},
	{
		"name": "APT (Zaawansowane Zagrożenie)",
		"lore": "[i]Kolos — ucieleśnienie cyberwojny. Skoordynowany atak całej armii hakerskiej, sponsorowanej przez wrogie państwa.[/i]",
		"definition": "[color=#4ecdc4][b]OPIS ZAGROŻENIA[/b][/color]\nDługotrwały, celowany proces ataku, w którym napastnik infiltruje sieć i pozostaje niewykryty, kradnąc strategiczne dane.\n\n[color=#f1c40f][b]MERYTORYKA SOC[/b][/color]\n• [b]Fazy:[/b] Rekonesans, Infiltracja, Eksfiltracja.\n• [b]Cechy:[/b] Wysoki budżet, Zero-Day, cierpliwość.\n• [b]Obrona:[/b] Systemy EDR/XDR, Zero Trust.\n\n[color=#e74c3c][b]DANE WYWIADOWCZE (GRA)[/b][/color]\nBOSS pojawia się co 5 fal. Posiada wiele faz ataku.\n\n[color=#95a5a6][b]HISTORIA:[/b][/color] Lazarus Group, Cozy Bear.",
		"icon": preload("res://Assets/Characters/esa.png")
	}
]

func _ready() -> void:
	visible = false
	_populate_list()
	if not enemies_data.is_empty():
		_display_enemy(0)
	_start_scan_animation()

func _populate_list() -> void:
	enemy_list.clear()
	for enemy in enemies_data:
		enemy_list.add_item(enemy.name)

func _display_enemy(index: int) -> void:
	var data = enemies_data[index]
	enemy_name.text = data.name
	lore_label.text = data.lore
	definition_label.text = data.definition
	enemy_sprite.texture = data.icon

func open_bestiary() -> void:
	visible = true
	get_tree().paused = true

func _on_enemy_list_item_selected(index: int) -> void:
	_display_enemy(index)

func _on_close_button_pressed() -> void:
	_cleanup_and_close()

func _cleanup_and_close() -> void:
	if scan_line:
		scan_line.visible = false
	visible = false
	get_tree().paused = false
	queue_free()

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		_cleanup_and_close()
		get_viewport().set_input_as_handled()

func _start_scan_animation() -> void:
	if not scan_line:
		return
	scan_line.visible = true
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(scan_line, "position:y", 0.0, 0.0)
	tween.tween_property(scan_line, "position:y", 570.0, 2.5)
