extends CanvasLayer
## BestiaryUI – Cyberpunk bestiary with 11 cyber-threat entries.
## Full-screen view with tab filtering, detailed lore and real IT definitions.
## Signal connections from .tscn:
##   - EnemyList.item_selected -> _on_enemy_list_item_selected
##   - CloseButton.pressed -> _on_close_button_pressed

# --- Node references (unique_name_in_owner) ---
@onready var _enemy_list: ItemList = %EnemyList
@onready var _enemy_sprite: TextureRect = %EnemySprite
@onready var _enemy_name: Label = %EnemyName
@onready var _lore_label: RichTextLabel = %LoreLabel
@onready var _definition_label: RichTextLabel = %DefinitionLabel

# --- Non-unique stat labels (accessed via $ paths) ---
@onready var _stat_hp: Label = $"Control/MainPanel/MainLayout/ContentArea/DetailsContainer/TopDetails/InfoColumn/StatsGrid/StatValueHP"
@onready var _stat_speed: Label = $"Control/MainPanel/MainLayout/ContentArea/DetailsContainer/TopDetails/InfoColumn/StatsGrid/StatValueSpeed"
@onready var _stat_attack: Label = $"Control/MainPanel/MainLayout/ContentArea/DetailsContainer/TopDetails/InfoColumn/StatsGrid/StatValueAttack"
@onready var _stat_wave: Label = $"Control/MainPanel/MainLayout/ContentArea/DetailsContainer/TopDetails/InfoColumn/StatsGrid/StatValueWave"
@onready var _stat_type: Label = $"Control/MainPanel/MainLayout/ContentArea/DetailsContainer/TopDetails/InfoColumn/StatsGrid/StatValueType"

# --- Tab references ---
@onready var _tab_all: Button = $"Control/MainPanel/MainLayout/CategoryTabs/TabAll"
@onready var _tab_worms: Button = $"Control/MainPanel/MainLayout/CategoryTabs/TabWorms"
@onready var _tab_malicious: Button = $"Control/MainPanel/MainLayout/CategoryTabs/TabMalicious"
@onready var _tab_network: Button = $"Control/MainPanel/MainLayout/CategoryTabs/TabNetwork"
@onready var _tab_bosses: Button = $"Control/MainPanel/MainLayout/CategoryTabs/TabBosses"

# --- Data ---
var _all_entries: Array[Dictionary] = []
var _filtered_indices: Array[int] = []  ## indices into _all_entries after filtering
var _current_filter: String = "all"


# ============================================================
#  ENTRY DATA
# ============================================================
func _build_entries() -> Array[Dictionary]:
	return [
		{
			name = "ROBAK (Worm)",
			texture_path = "res://Assets/Characters/worm.png",
			category = "robactwo",
			hp = 30, speed = 3, attack = 5, wave = "1-3", type = "ROBACTWO",
			lore = "[color=#d0fff5]W ciemnych zakamarkach cyberprzestrzeni ROBAK drąży tunele przez warstwy ochronne firewalli. To samoreplikujący się byt – wystarczy jeden, by w ciągu minut zaroiło się od nich całe spektrum sieci. Jego kod ewoluuje z każdym cyklem, ucząc się omijać kolejne zapory. W grze Motodefend spotkasz go w pierwszych falach – jest szybki, liczny i nieprzewidywalny, ale pojedynczy osobnik nie stanowi dużego zagrożenia.[/color]",
			definition = "[color=#e8e8f0]Robak (worm) to typ złośliwego oprogramowania, które samodzielnie się replikuje i rozprzestrzenia przez sieci komputerowe, wykorzystując luki w zabezpieczeniach systemów. W przeciwieństwie do wirusów, nie wymaga dołączania do istniejącego pliku ani interakcji użytkownika. Robaki mogą powodować przeciążenie sieci, kradzież danych lub instalację backdoorów.[/color]"
		},
		{
			name = "SPYWARE",
			texture_path = "res://Assets/Characters/spyware.png",
			category = "robactwo",
			hp = 25, speed = 5, attack = 3, wave = "1-4", type = "ROBACTWO",
			lore = "[color=#d0fff5]Cichy obserwator w głębinach sieci – SPYWARE nie atakuje wprost. Prześlizguje się przez niedomknięte porty, kopiuje pakiety danych i wysyła je do swoich twórców. Jego obecność zdradza tylko nieznaczne spowolnienie łącza. W świecie Motodefend to jednostka szpiegowska – jeśli nie zniszczysz jej szybko, przeciwnik pozna słabe punkty Twojej obrony.[/color]",
			definition = "[color=#e8e8f0]Spyware to oprogramowanie szpiegujące, które zbiera informacje o użytkowniku bez jego wiedzy i zgody. Może monitorować historię przeglądania, przechwytywać dane logowania, nagrywać naciśnięcia klawiszy (keylogging) oraz kraść pliki. Spyware często instaluje się jako dodatek do darmowego oprogramowania (bundleware) lub przez zainfekowane strony WWW.[/color]"
		},
		{
			name = "ADWARE",
			texture_path = "res://Assets/Characters/bot_enemy.png",
			category = "robactwo",
			hp = 20, speed = 6, attack = 2, wave = "2-5", type = "ROBACTWO",
			lore = "[color=#d0fff5]ADWARE to cyfrowy krzykacz – nie zabija, ale zagłusza. Zasypuje interfejs falą natrętnych reklam, spowalnia procesy i odwraca uwagę od prawdziwego zagrożenia. W Motodefend działa jak jednostka wsparcia – podczas gdy Ty walczysz z jego reklamowym spamem, cięższe wirusy przechodzą dalej. Ignorujesz go na własną odpowiedzialność.[/color]",
			definition = "[color=#e8e8f0]Adware (advertising-supported software) to oprogramowanie wyświetlające niechciane reklamy, najczęściej w postaci wyskakujących okien (pop-upów) lub przekierowań w przeglądarce. Choć często nie jest bezpośrednio szkodliwe, może spowalniać system, naruszać prywatność użytkownika oraz służyć jako wektor instalacji poważniejszego malware. Niektóre adware śledzi aktywność użytkownika, by profilować reklamy.[/color]"
		},
		{
			name = "TROJAN",
			texture_path = "res://Assets/Characters/Trojan.png",
			category = "zlosliwe",
			hp = 50, speed = 2, attack = 8, wave = "2-6", type = "ZŁOŚLIWE",
			lore = "[color=#ffaa00]TROJAN to mistrz kamuflażu – przybiera postać legalnego oprogramowania, by po cichu otworzyć backdoor do systemu. Jego nazwa nie jest przypadkowa: tak jak koń trojański, kryje w sobie niszczycielski ładunek. W Motodefend pojawia się znienacka – na pierwszy rzut oka wygląda jak zwykły plik systemowy, ale gdy przejdzie przez bramę, rozpętuje piekło.[/color]",
			definition = "[color=#e8e8f0]Koń trojański (trojan) to rodzaj malware, który podszywa się pod legalne oprogramowanie, by skłonić użytkownika do jego instalacji. W przeciwieństwie do wirusów i robaków, trojany nie replikują się samodzielnie. Ich celem jest najczęściej kradzież danych, przejęcie kontroli nad systemem, instalacja ransomware lub utworzenie tylnych drzwi (backdoor) dla dalszych ataków.[/color]"
		},
		{
			name = "RANSOMWARE",
			texture_path = "res://Assets/Characters/Ransomware.png",
			category = "zlosliwe",
			hp = 40, speed = 1, attack = 10, wave = "3-7", type = "ZŁOŚLIWE",
			lore = "[color=#ffaa00]RANSOMWARE nie bawi się w subtelności – szyfruje wszystko, co napotka, a za klucz żąda okupu w kryptowalucie. Gdy widzisz jego czerwoną sygnaturę na swoich plikach, jest już za późno. W Motodefend to jeden z najgroźniejszych przeciwników – wolny, ale każdy jego cios to szyfrowanie kolejnego sektora pamięci. Zniszcz go, zanim zaszyfruje całą bazę.[/color]",
			definition = "[color=#e8e8f0]Ransomware to rodzaj złośliwego oprogramowania, które blokuje dostęp do systemu lub szyfruje pliki użytkownika, żądając okupu za ich odblokowanie. Najczęściej rozprzestrzenia się przez phishingowe załączniki, zainfekowane strony lub exploity. Płatność zazwyczaj wymagana jest w kryptowalutach. Nawet po zapłaceniu okupu nie ma gwarancji odzyskania danych – jedyną skuteczną obroną są regularne backupy offline.[/color]"
		},
		{
			name = "KEYLOGGER (Phishing)",
			texture_path = "res://Assets/Characters/phishing_malware.png",
			category = "zlosliwe",
			hp = 15, speed = 7, attack = 4, wave = "2-5", type = "ZŁOŚLIWE",
			lore = "[color=#ffaa00]KEYLOGGER to cyfrowy cień czający się nad klawiaturą. Każde naciśnięcie klawisza, każdy znak – wszystko rejestrowane i wysyłane do atakującego. W Motodefend jest niepozorny i szybki – zanim go zauważysz, przechwycił już Twoje kody dostępu. Poluj na niego priorytetowo, bo informacja to najcenniejsza waluta cyberprzestrzeni.[/color]",
			definition = "[color=#e8e8f0]Keylogger to program lub urządzenie sprzętowe rejestrujące naciśnięcia klawiszy na komputerze ofiary. Wyróżniamy keyloggery programowe (instalowane przez malware) oraz sprzętowe (fizyczne urządzenia podpinane do portu USB lub PS/2). Służą do kradzieży haseł, numerów kart kredytowych, treści prywatnych wiadomości i innych poufnych danych. Ochrona obejmuje używanie 2FA, klawiatur ekranowych oraz regularne skanowanie antywirusowe.[/color]"
		},
		{
			name = "DDoS",
			texture_path = "res://Assets/Characters/bot_enemy.png",
			category = "ataki_sieciowe",
			hp = 80, speed = 1, attack = 6, wave = "4-8", type = "ATAKI SIECIOWE",
			lore = "[color=#00ccff]DDoS nie próbuje się ukryć – to frontalny atak tysięcy zainfekowanych maszyn, które jednocześnie bombardują serwer zapytaniami. Przytłacza infrastrukturę samą masą. W Motodefend działa jak boss – pojawia się w późniejszych falach z ogromnym HP i miażdży wszystko na swojej drodze. Żeby go powstrzymać, potrzebujesz najcięższych dział.[/color]",
			definition = "[color=#e8e8f0]DDoS (Distributed Denial of Service) to rozproszony atak odmowy dostępu, w którym wiele przejętych systemów (często tworzących botnet) jednocześnie wysyła ogromną ilość zapytań do celu, przeciążając jego zasoby i uniemożliwiając normalne funkcjonowanie. Ataki DDoS mogą być warstwą sieciową (zalewanie pasma) lub aplikacyjną (wyczerpywanie zasobów serwera). Ochrona wymaga filtrowania ruchu, CDN-ów i specjalizowanych rozwiązań anty-DDoS.[/color]"
		},
		{
			name = "SQL INJECTION",
			texture_path = "res://Assets/Characters/sql_injection.png",
			category = "ataki_sieciowe",
			hp = 35, speed = 4, attack = 12, wave = "3-7", type = "ATAKI SIECIOWE",
			lore = "[color=#00ccff]SQL INJECTION to chirurgicznie precyzyjny atak – zamiast siły używa luk w zapytaniach bazodanowych. Wstrzykuje złośliwy kod prosto w serce bazy danych, skąd może wykradać, modyfikować lub niszczyć informacje. W Motodefend uderza z dystansu z niszczycielską siłą – jego ataki ignorują część pancerza, bo trafiają w logikę, nie w hardware.[/color]",
			definition = "[color=#e8e8f0]SQL Injection to technika ataku na aplikacje internetowe polegająca na wstrzyknięciu złośliwego kodu SQL w pola wejściowe (formularze, parametry URL), co pozwala na nieautoryzowany dostęp do bazy danych. Skuteczny atak może umożliwić kradzież, modyfikację lub usunięcie danych, a nawet przejęcie kontroli nad serwerem. Ochroną jest walidacja wejścia, używanie zapytań parametryzowanych (prepared statements) oraz stosowanie zasady najmniejszych uprawnień.[/color]"
		},
		{
			name = "BOTNET",
			texture_path = "res://Assets/Characters/bot_enemy.png",
			category = "ataki_sieciowe",
			hp = 45, speed = 3, attack = 7, wave = "5-10", type = "ATAKI SIECIOWE",
			lore = "[color=#00ccff]BOTNET to armia zombi – setki przejętych urządzeń, które nieświadomie wykonują rozkazy swojego pana. Każdy smartfon, router czy laptop może stać się żołnierzem w tej cyfrowej armii. W Motodefend Botnet uderza zmasowaną falą – pojedyncza jednostka jest słaba, ale działa w grupie. Zaatakuj komturię (C2), by rozproszyć rój.[/color]",
			definition = "[color=#e8e8f0]Botnet to sieć zainfekowanych urządzeń (botów) kontrolowanych zdalnie przez atakującego (botmastera) za pośrednictwem serwerów dowodzenia C2 (Command & Control). Botnety wykorzystywane są do rozsyłania spamu, ataków DDoS, kradzieży danych, miningu kryptowalut oraz rozprzestrzeniania dalszego malware. Wykrycie botnetu jest trudne, ponieważ zainfekowane urządzenia działają pozornie normalnie – ochrona obejmuje monitoring ruchu sieciowego i regularne aktualizacje firmware.[/color]"
		},
		{
			name = "APT (BOSS)",
			texture_path = "res://Assets/Characters/apt_boss.png",
			category = "bossy",
			hp = 200, speed = 1, attack = 20, wave = "10", type = "BOSS",
			lore = "[color=#ff0044]APT to nie wirus – to operacja. Zaawansowane, długotrwałe, finansowane przez państwa lub organizacje przestępcze. APT nie włamuje się na chwilę – on infiltruje system na miesiące, cierpliwie zbierając dane wywiadowcze. W Motodefend to ostateczny boss: ogromne HP, druzgocący atak i zdolność adaptacji. Pokonanie go wymaga pełnego arsenału i perfekcyjnej strategii.[/color]",
			definition = "[color=#e8e8f0]APT (Advanced Persistent Threat) to zaawansowane, długotrwałe zagrożenie – zazwyczaj sponsorowana przez państwo lub zorganizowaną grupę przestępczą kampania cyberataku. Cechuje się wysokim stopniem zaawansowania technicznego, długotrwałą obecnością w zaatakowanej sieci (często miesiące lub lata) oraz konkretnym celem (szpiegostwo przemysłowe, kradzież własności intelektualnej, sabotaż). Obrona przed APT wymaga wielowarstwowego podejścia Defense-in-Depth, ciągłego monitoringu (SOC) i threat huntingu.[/color]"
		},
		{
			name = "ROOTKIT (BOSS)",
			texture_path = "res://Assets/Characters/apt_boss.png",
			category = "bossy",
			hp = 150, speed = 2, attack = 15, wave = "8", type = "BOSS",
			lore = "[color=#ff0044]ROOTKIT to zło w najczystszej formie – nie widzisz go, nie wykrywasz, ale on jest wszędzie. Działa na poziomie jądra systemu, ukrywając swoją obecność przed antywirusami i administratorem. W Motodefend to drugi boss: ma mniej HP niż APT, ale jest szybszy i potrafi stać się niewidzialny. Tylko specjalistyczne skanery (lub odpowiedni upgrade) ujawnią jego pozycję.[/color]",
			definition = "[color=#e8e8f0]Rootkit to zestaw narzędzi umożliwiających atakującemu ukrycie obecności złośliwego oprogramowania na zainfekowanym systemie poprzez modyfikację jądra systemu operacyjnego, sterowników lub bibliotek. Rootkity działają na niskim poziomie, często przed załadowaniem systemu (bootkity), co czyni je ekstremalnie trudnymi do wykrycia i usunięcia. Usunięcie rootkitu często wymaga formatowania dysku i reinstalacji systemu od zera (clean install).[/color]"
		}
	]


# ============================================================
#  LIFECYCLE
# ============================================================
func _ready() -> void:
	_all_entries = _build_entries()
	_hide_details()
	_connect_tabs()
	_apply_filter("all")
	visible = false


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_close_button_pressed()


# ============================================================
#  PUBLIC API
# ============================================================
func show_bestiary() -> void:
	visible = true
	_apply_filter("all")
	if _enemy_list.item_count > 0:
		_enemy_list.select(0)
		_on_enemy_list_item_selected(0)


# ============================================================
#  TAB FILTERING
# ============================================================
func _connect_tabs() -> void:
	_tab_all.pressed.connect(func(): _apply_filter("all"))
	_tab_worms.pressed.connect(func(): _apply_filter("robactwo"))
	_tab_malicious.pressed.connect(func(): _apply_filter("zlosliwe"))
	_tab_network.pressed.connect(func(): _apply_filter("ataki_sieciowe"))
	_tab_bosses.pressed.connect(func(): _apply_filter("bossy"))


func _apply_filter(category: String) -> void:
	_current_filter = category
	_filtered_indices.clear()
	_enemy_list.clear()
	_hide_details()

	for i in range(_all_entries.size()):
		if category == "all" or _all_entries[i].category == category:
			_filtered_indices.append(i)

	for idx in _filtered_indices:
		var entry: Dictionary = _all_entries[idx]
		var icon: Texture2D = _load_icon(entry.texture_path)
		var item_idx: int = _enemy_list.add_item(entry.name, icon, true)
		# Alternating row colors
		if item_idx % 2 == 0:
			_enemy_list.set_item_custom_bg_color(item_idx, Color(0.06, 0.08, 0.14, 0.4))
		else:
			_enemy_list.set_item_custom_bg_color(item_idx, Color(0.09, 0.12, 0.18, 0.3))

	# Update tab visual states
	_update_tab_states()


func _update_tab_states() -> void:
	var active_color := Color(0.0, 1.0, 0.533, 0.9)
	var inactive_color := Color(0.498, 0.549, 0.553, 1)
	var boss_active_color := Color(1.0, 0.843, 0.0, 1.0)

	_tab_all.modulate = active_color if _current_filter == "all" else inactive_color
	_tab_worms.modulate = active_color if _current_filter == "robactwo" else inactive_color
	_tab_malicious.modulate = active_color if _current_filter == "zlosliwe" else inactive_color
	_tab_network.modulate = active_color if _current_filter == "ataki_sieciowe" else inactive_color
	_tab_bosses.modulate = boss_active_color if _current_filter == "bossy" else inactive_color


# ============================================================
#  ITEM SELECTION
# ============================================================
func _on_enemy_list_item_selected(index: int) -> void:
	if index < 0 or index >= _filtered_indices.size():
		return

	var entry_idx: int = _filtered_indices[index]
	var entry: Dictionary = _all_entries[entry_idx]
	_show_entry_details(entry)


func _show_entry_details(entry: Dictionary) -> void:
	# Sprite
	_enemy_sprite.texture = _load_texture(entry.texture_path)

	# Name
	_enemy_name.text = entry.name

	# Lore (bbcode)
	_lore_label.text = entry.lore

	# Definition (bbcode)
	_definition_label.text = entry.definition

	# Stats
	_stat_hp.text = str(entry.hp)
	_stat_speed.text = str(entry.speed)
	_stat_attack.text = str(entry.attack)
	_stat_wave.text = str(entry.wave)
	_stat_type.text = str(entry.type)


func _hide_details() -> void:
	_enemy_sprite.texture = null
	_enemy_name.text = "Nazwa Wirusa"
	_lore_label.text = "Opis fabularny wirusa w swiecie gry..."
	_definition_label.text = "Realna definicja zagrozenia IT..."
	_stat_hp.text = "---"
	_stat_speed.text = "---"
	_stat_attack.text = "---"
	_stat_wave.text = "---"
	_stat_type.text = "---"


# ============================================================
#  CLOSE
# ============================================================
func _on_close_button_pressed() -> void:
	visible = false


# ============================================================
#  ASSET HELPERS
# ============================================================
func _load_icon(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var tex: Texture2D = load(path) as Texture2D
		if tex:
			return tex
	# Fallback: generate a small colored placeholder
	return _create_placeholder_icon()


func _load_texture(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var tex: Texture2D = load(path) as Texture2D
		if tex:
			return tex
	return null


func _create_placeholder_icon() -> Texture2D:
	var img := Image.create(20, 20, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.0, 0.941, 1.0, 1.0))
	return ImageTexture.create_from_image(img)
