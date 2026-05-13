extends CanvasLayer
## Bestiary UI - Educational database of cyber threats

@onready var enemy_list: ItemList = %EnemyList
@onready var enemy_sprite: TextureRect = %EnemySprite
@onready var enemy_name: Label = %EnemyName
@onready var lore_label: RichTextLabel = %LoreLabel
@onready var definition_label: RichTextLabel = %DefinitionLabel

var enemies_data = [
	{
		"name": "Worm (Robak)",
		"lore": "Segmentowany, wijący się stwór złożony z węzłów danych. Replikuje się w mgnieniu oka — każdy fragment jego ciała może odrodzić się jako nowy osobnik. Na arenie pojawia się w rojach, które szybko wymykają się spod kontroli, jeśli nie zostaną powstrzymane na czas.",
		"definition": "Samoreplikujący się program złośliwy, który rozprzestrzenia się bez udziału użytkownika, wykorzystując luki w systemach operacyjnych i protokołach sieciowych. W przeciwieństwie do wirusa nie potrzebuje pliku-żywiciela — sam w sobie jest kompletnym zagrożeniem.\n\n[b]W grze:[/b] Szybki, pojawia się w grupach. Po pewnym czasie dzieli się na dwa osobniki. Niszcz go szybko, zanim zaleje arenę!\n\n[b]Słabość:[/b] Niskie HP, podatny na obrażenia obszarowe.\n\n[b]Przykłady:[/b] Morris Worm (1988), ILOVEYOU (2000), Stuxnet (2010), WannaCry (2017).",
		"icon": preload("res://Assets/Characters/worm.png")
	},
	{
		"name": "Trojan",
		"lore": "Podstępny byt ukryty pod pozorem nieszkodliwego pakietu danych. Gdy już znajdzie się wewnątrz systemu, otwiera tylne furtki dla kolejnych zagrożeń. Jego pikselowa zbroja czyni go odporniejszym niż zwykłe robaki.",
		"definition": "Złośliwe oprogramowanie maskujące się jako legalna aplikacja. Po uruchomieniu przez niczego nieswiadomego użytkownika instaluje w systemie backdoor, keylogger lub RAT (Remote Access Trojan), dając hakerom pełną kontrolę nad maszyną.\n\n[b]W grze:[/b] Silniejszy od worma, średnia prędkość. Atakuje w zwarciu, zadając wysokie obrażenia.\n\n[b]Słabość:[/b] Powolny, łatwy do wyczerpania unikami.\n\n[b]Przykłady:[/b] Zeus (2007), Emotet (2014), Gh0st RAT, AsyncRAT.",
		"icon": preload("res://Assets/Characters/mob.png")
	},
	{
		"name": "Ransomware",
		"lore": "Mroczna, ociężała postać skutej łańcuchami bestii. Każdy jej krok przybliża cyfrową zagładę — gdy dopadnie ofiarę, zamyka jej dane w nieprzeniknionym szyfrze i żąda okupu. Jego obecność na polu bitwy zmusza do natychmiastowej reakcji.",
		"definition": "Oprogramowanie szantażujące, które szyfruje pliki ofiary i żąda zapłaty (zwykle w kryptowalutach) za klucz deszyfrujący. Ataki ransomware paraliżują całe organizacje — szpitale tracą dostęp do kart pacjentów, firmy do baz danych, urzędy do dokumentacji.\n\n[b]W grze:[/b] Wolny, ale bardzo wytrzymały. Zadaje ogromne obrażenia w zwarciu. Priorytetowy cel!\n\n[b]Słabość:[/b] Bardzo wolny, łatwo go kitingować.\n\n[b]Przykłady:[/b] WannaCry (2017, 200k+ ofiar w 150 krajach), Petya/NotPetya (2017), REvil/Sodinokibi, Colonial Pipeline (2021).",
		"icon": preload("res://Assets/Characters/worm.png")
	},
	{
		"name": "SQL Injection",
		"lore": "Widmowy, fluorescencyjny byt utkany z linijek kodu. Wstrzykuje się w szczeliny systemu niczym igła — jedno precyzyjne uderzenie wystarczy, by wydobyć najgłębiej skrywane sekrety bazy danych.",
		"definition": "Technika ataku polegająca na wstrzyknięciu złośliwych zapytań SQL do pól formularzy lub parametrów URL na stronach WWW. Atakujący może odczytać, zmodyfikować lub usunąć całą zawartość bazy danych, a w skrajnych przypadkach przejąć kontrolę nad serwerem.\n\n[b]W grze:[/b] Strzelec dystansowy — atakuje pociskami danych z daleka. Utrzymuj dystans i unikaj jego linii ognia!\n\n[b]Słabość:[/b] Niskie HP, bezradny w zwarciu.\n\n[b]Zabezpieczenie:[/b] Zapytania parametryzowane (Prepared Statements), walidacja inputu, ORM.\n\n[b]Przykład:[/b] Atak na vBulletin (2019) — wykradziono dane milionów użytkowników poprzez SQL Injection w systemie forum.",
		"icon": preload("res://Assets/Characters/sql.png")
	},
	{
		"name": "Phishing",
		"lore": "Sprytny, szybki oszust, który podrzuca sfałszowane pakiety w nadziei, że ktoś da się złapać na haczyk. Porusza się zygzakiem, unikając pocisków, i atakuje znienacka. Każdy jego udany atak wysysa dane ofiary.",
		"definition": "Metoda ataku socjotechnicznego, w której przestępca podszywa się pod zaufaną osobę lub instytucję, aby wyłudzić poufne informacje. Phishing to najczęstszy wektor ataku — odpowiada za ponad 90% incydentów bezpieczeństwa.\n\n[b]W grze:[/b] Szybki, unika pocisków. Atakuje i natychmiast zmienia pozycję. Trudny do trafienia!\n\n[b]Słabość:[/b] Niskie HP, niskie obrażenia.\n\n[b]Kanały:[/b] E-mail (phishing), SMS (smishing), telefon (vishing), media społecznościowe (social media phishing).\n\n[b]Przykład:[/b] Masowe kampanie SMS podszywające się pod firmy kurierskie, banki, PIT-y podatkowe.",
		"icon": preload("res://Assets/Characters/phishing.png")
	},
	{
		"name": "Spyware (Szpieg)",
		"lore": "Pajęczak z kamerami zamiast oczu, czający się w cieniu. Nie atakuje bezpośrednio — zbiera informacje, śledzi każdy ruch i przekazuje dane swoim mrocznym mocodawcom. Im dłużej pozostaje niezauważony, tym więcej tajemnic wykradnie.",
		"definition": "Oprogramowanie szpiegowskie instalowane potajemnie na urządzeniu ofiary. Rejestruje naciśnięcia klawiszy (keylogging), robi zrzuty ekranu, śledzi aktywność przeglądarki i lokalizację GPS. Działa w tle, często przez miesiące, zanim zostanie wykryte.\n\n[b]W grze:[/b] Średnia prędkość, unika bezpośredniej konfrontacji. Z czasem jego ataki stają się silniejsze — im dłużej żyje, tym więcej \"danych\" zebrał.\n\n[b]Słabość:[/b] Niskie HP w początkowej fazie. Zabij go szybko!\n\n[b]Przykłady:[/b] Pegasus (zaawansowany spyware używany do inwigilacji dziennikarzy i aktywistów), FinFisher, DarkHotel.",
		"icon": preload("res://Assets/Characters/worm.png")
	},
	{
		"name": "APT Boss (Zaawansowane Zagrożenie)",
		"lore": "Kolos — ucieleśnienie cyberwojny. Ten gigantyczny byt to skoordynowany atak całej armii hakerskiej, sponsorowanej przez wrogie państwo. Każda jego część działa jak osobny system: generuje fale słabszych wrogów, stawia bariery i atakuje z wszystkich stron jednocześnie.",
		"definition": "Advanced Persistent Threat (APT) — zaawansowane, długotrwałe zagrożenie cybernetyczne przeprowadzane przez wyspecjalizowane grupy hakerskie, często sponsorowane przez państwa. APT charakteryzuje się cierpliwością i precyzją — atak może trwać miesiącami, a jego celem są strategiczne dane, infrastruktura krytyczna i tajemnice państwowe.\n\n[b]W grze:[/b] BOSS pojawia się co 5 fal. Ma bardzo dużo HP, generuje słabsze wrogowie, atakuje na wiele sposobów. Wymaga pełnego wykorzystania wszystkich dostępnych broni i uników!\n\n[b]Strategia:[/b] Używaj uników (Spacja) do omijania jego ataków i skup ogień na jego rdzeniu. Nie daj się otoczyć przez pomniejszych wrogów, których przywołuje.\n\n[b]Przykłady:[/b] APT29 (Cozy Bear — rosyjska grupa atakująca rządy i organizacje), APT38 (Lazarus Group — północnokoreańska grupa odpowiedzialna za ataki finansowe), Equation Group (powiązana z NSA).",
		"icon": preload("res://Assets/Characters/worm.png")
	}
]

func _ready() -> void:
	visible = false
	_populate_list()
	if not enemies_data.is_empty():
		_display_enemy(0)

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
	visible = false
	get_tree().paused = false
	# Nie usuwamy sceny, jeśli jest dodana na stałe, 
	# ale tutaj prawdopodobnie będziemy ją instancjonować.
	queue_free()
