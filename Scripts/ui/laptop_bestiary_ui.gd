extends CanvasLayer
## LaptopBestiaryUI – Compact laptop-screen bestiary with cyber-threat entries.
## Used from the laptop object. Same data as bestiary_ui_logic.gd, smaller layout.
## Signal connections from .tscn:
##   - CloseBtn.pressed -> _on_close_button_pressed
##   - EnemyList.item_selected -> _on_enemy_list_item_selected

# --- Node references (unique_name_in_owner) ---
@onready var _enemy_list: ItemList = %EnemyList
@onready var _enemy_sprite: TextureRect = %EnemySprite
@onready var _enemy_name: Label = %EnemyName
@onready var _lore_label: RichTextLabel = %LoreLabel
@onready var _definition_label: RichTextLabel = %DefinitionLabel

# --- Scanline overlay (optional) ---
@onready var _screen_panel: Panel = $Control/ScreenContent

# --- Data ---
var _all_entries: Array[Dictionary] = []
var _scanline_offset: float = 0.0
var _scanline_enabled: bool = true
var _scanline_material: ShaderMaterial = null


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
			lore = "[color=#e0e4f0]W ciemnych zakamarkach cyberprzestrzeni ROBAK drąży tunele przez warstwy ochronne firewalli. To samoreplikujący się byt – wystarczy jeden, by w ciągu minut zaroiło się od nich całe spektrum sieci. Jego kod ewoluuje z każdym cyklem.[/color]",
			definition = "[color=#e0e4f0]Robak (worm) to typ złośliwego oprogramowania, które samodzielnie się replikuje i rozprzestrzenia przez sieci komputerowe, wykorzystując luki w zabezpieczeniach. Nie wymaga interakcji użytkownika. Może powodować przeciążenie sieci, kradzież danych lub instalację backdoorów.[/color]"
		},
		{
			name = "SPYWARE",
			texture_path = "res://Assets/Characters/spyware.png",
			category = "robactwo",
			hp = 25, speed = 5, attack = 3, wave = "1-4", type = "ROBACTWO",
			lore = "[color=#e0e4f0]Cichy obserwator w głębinach sieci – SPYWARE nie atakuje wprost. Prześlizguje się przez niedomknięte porty, kopiuje pakiety danych i wysyła je do swoich twórców. Jeśli nie zniszczysz go szybko, przeciwnik pozna Twoje słabe punkty.[/color]",
			definition = "[color=#e0e4f0]Spyware to oprogramowanie szpiegujące, które zbiera informacje o użytkowniku bez jego wiedzy. Monitoruje historię przeglądania, przechwytuje dane logowania, nagrywa naciśnięcia klawiszy (keylogging) oraz kradnie pliki. Często instaluje się jako dodatek do darmowego oprogramowania.[/color]"
		},
		{
			name = "ADWARE",
			texture_path = "res://Assets/Characters/bot_enemy.png",
			category = "robactwo",
			hp = 20, speed = 6, attack = 2, wave = "2-5", type = "ROBACTWO",
			lore = "[color=#e0e4f0]ADWARE to cyfrowy krzykacz – nie zabija, ale zagłusza. Zasypuje interfejs falą natrętnych reklam, spowalnia procesy i odwraca uwagę od prawdziwego zagrożenia. Podczas gdy Ty walczysz z jego spamem, cięższe wirusy przechodzą dalej.[/color]",
			definition = "[color=#e0e4f0]Adware to oprogramowanie wyświetlające niechciane reklamy (pop-upy, przekierowania). Choć często nie jest bezpośrednio szkodliwe, spowalnia system, narusza prywatność i może służyć jako wektor instalacji poważniejszego malware.[/color]"
		},
		{
			name = "TROJAN",
			texture_path = "res://Assets/Characters/Trojan.png",
			category = "zlosliwe",
			hp = 50, speed = 2, attack = 8, wave = "2-6", type = "ZŁOŚLIWE",
			lore = "[color=#e0e4f0]TROJAN to mistrz kamuflażu – przybiera postać legalnego oprogramowania, by po cichu otworzyć backdoor do systemu. Gdy przejdzie przez bramę, rozpętuje chaos. Nie daj się zwieść jego niewinnej fasadzie.[/color]",
			definition = "[color=#e0e4f0]Koń trojański (trojan) to malware podszywające się pod legalne oprogramowanie. Nie replikuje się samodzielnie. Jego celem jest kradzież danych, przejęcie kontroli nad systemem, instalacja ransomware lub utworzenie tylnych drzwi (backdoor).[/color]"
		},
		{
			name = "RANSOMWARE",
			texture_path = "res://Assets/Characters/Ransomware.png",
			category = "zlosliwe",
			hp = 40, speed = 1, attack = 10, wave = "3-7", type = "ZŁOŚLIWE",
			lore = "[color=#e0e4f0]RANSOMWARE nie bawi się w subtelności – szyfruje wszystko, co napotka, a za klucz żąda okupu w kryptowalucie. Gdy widzisz jego czerwoną sygnaturę, jest już za późno. Zniszcz go, zanim zaszyfruje całą bazę danych.[/color]",
			definition = "[color=#e0e4f0]Ransomware to malware blokujące dostęp do systemu lub szyfrujące pliki użytkownika, żądając okupu za odblokowanie. Płatność wymagana jest w kryptowalutach. Jedyną skuteczną obroną są regularne backupy offline – zapłacenie okupu nie gwarantuje odzyskania danych.[/color]"
		},
		{
			name = "KEYLOGGER (Phishing)",
			texture_path = "res://Assets/Characters/phishing_malware.png",
			category = "zlosliwe",
			hp = 15, speed = 7, attack = 4, wave = "2-5", type = "ZŁOŚLIWE",
			lore = "[color=#e0e4f0]KEYLOGGER to cyfrowy cień czający się nad klawiaturą. Każde naciśnięcie klawisza rejestrowane i wysyłane do atakującego. Niepozorny, szybki – zanim go zauważysz, przechwycił już Twoje kody dostępu do całego systemu.[/color]",
			definition = "[color=#e0e4f0]Keylogger to program lub urządzenie rejestrujące naciśnięcia klawiszy. Służy do kradzieży haseł, numerów kart kredytowych i innych poufnych danych. Ochrona obejmuje 2FA, klawiatury ekranowe i regularne skanowanie antywirusowe.[/color]"
		},
		{
			name = "DDoS",
			texture_path = "res://Assets/Characters/bot_enemy.png",
			category = "ataki_sieciowe",
			hp = 80, speed = 1, attack = 6, wave = "4-8", type = "ATAKI SIECIOWE",
			lore = "[color=#e0e4f0]DDoS nie próbuje się ukryć – to frontalny atak tysięcy zainfekowanych maszyn bombardujących serwer zapytaniami. Przytłacza infrastrukturę samą masą. Potrzebujesz najcięższych dział, by go powstrzymać.[/color]",
			definition = "[color=#e0e4f0]DDoS (Distributed Denial of Service) to rozproszony atak odmowy dostępu, w którym wiele przejętych systemów jednocześnie wysyła ogromną ilość zapytań do celu, przeciążając jego zasoby. Ochrona wymaga filtrowania ruchu, CDN-ów i rozwiązań anty-DDoS.[/color]"
		},
		{
			name = "SQL INJECTION",
			texture_path = "res://Assets/Characters/sql_injection.png",
			category = "ataki_sieciowe",
			hp = 35, speed = 4, attack = 12, wave = "3-7", type = "ATAKI SIECIOWE",
			lore = "[color=#e0e4f0]SQL INJECTION to chirurgicznie precyzyjny atak – wykorzystuje luki w zapytaniach bazodanowych. Wstrzykuje złośliwy kod prosto w serce bazy danych, skąd może wykradać, modyfikować lub niszczyć informacje.[/color]",
			definition = "[color=#e0e4f0]SQL Injection to technika ataku polegająca na wstrzyknięciu złośliwego kodu SQL w pola wejściowe, co pozwala na nieautoryzowany dostęp do bazy danych. Ochroną jest walidacja wejścia i używanie zapytań parametryzowanych (prepared statements).[/color]"
		},
		{
			name = "BOTNET",
			texture_path = "res://Assets/Characters/bot_enemy.png",
			category = "ataki_sieciowe",
			hp = 45, speed = 3, attack = 7, wave = "5-10", type = "ATAKI SIECIOWE",
			lore = "[color=#e0e4f0]BOTNET to armia zombi – setki przejętych urządzeń nieświadomie wykonujących rozkazy swojego pana. Każdy smartfon, router czy laptop może być żołnierzem. Uderza zmasowaną falą – pojedyncza jednostka jest słaba, ale działa w grupie.[/color]",
			definition = "[color=#e0e4f0]Botnet to sieć zainfekowanych urządzeń (botów) kontrolowanych zdalnie przez botmastera przez serwery C2. Wykorzystywany do spamu, ataków DDoS, kradzieży danych i miningu kryptowalut. Ochrona: monitoring ruchu i aktualizacje firmware.[/color]"
		},
		{
			name = "SMURF MINION",
			texture_path = "res://Assets/Characters/smurf_minion.png",
			category = "ataki_sieciowe",
			hp = 28, speed = 6, attack = 5, wave = "Boss", type = "ATAKI SIECIOWE",
			lore = "[color=#e0e4f0]SMURF MINION to mały pakiet-pocisk wyrzucany przez bossa Smurf Attack. Sam nie wygląda groźnie, ale kilka takich jednostek naraz potrafi rozciągnąć obronę i zmusić gracza do ruchu.[/color]",
			definition = "[color=#e0e4f0]W realnym ataku smurf pakiety są odbijane przez źle skonfigurowane sieci, wzmacniając ruch wracający do ofiary. Minion reprezentuje pojedynczy odbity pakiet dokładający presję do głównego ataku DDoS.[/color]"
		},
		{
			name = "DATA HIJACKER (BOSS)",
			texture_path = "res://Assets/Characters/data_hijacker.png",
			category = "bossy",
			hp = 680, speed = 3, attack = 30, wave = "5+", type = "BOSS",
			lore = "[color=#e0e4f0]DATA HIJACKER przejmuje tor walki jak skradzioną sesję: oznacza linię ataku, ładuje impuls i przebija się przez obronę szybką szarżą. Karze stanie w miejscu.[/color]",
			definition = "[color=#e0e4f0]Hijacking oznacza przejęcie sesji, tokenu, połączenia, domeny albo konta. Obrona opiera się na MFA, krótkich sesjach, rotacji tokenów i wykrywaniu nietypowego zachowania.[/color]"
		},
		{
			name = "SMURF ATTACK (BOSS)",
			texture_path = "res://Assets/Characters/smurf_attack_boss.png",
			category = "bossy",
			hp = 760, speed = 3, attack = 24, wave = "5+", type = "BOSS",
			lore = "[color=#e0e4f0]SMURF ATTACK zasypuje arenę pakietami-minionami i zmusza gracza do ciągłego czyszczenia przestrzeni. Walka jest testem kontroli tłumu i priorytetów celów.[/color]",
			definition = "[color=#e0e4f0]Smurf Attack to odmiana DDoS oparta o spoofing adresu IP i wzmacnianie ruchu przez sieci broadcast. Ograniczają go anti-spoofing, blokada directed broadcast, rate limiting i ochrona anty-DDoS.[/color]"
		},
		{
			name = "FIREWALL OVERLOAD (BOSS)",
			texture_path = "res://Assets/Characters/firewall_overload_boss.png",
			category = "bossy",
			hp = 840, speed = 2, attack = 24, wave = "5+", type = "BOSS",
			lore = "[color=#e0e4f0]FIREWALL OVERLOAD to ciężki cyber-rycerz w czarnym pancerzu, który zasłania się hex-tarczą i odcina sektory areny płonącymi ścianami firewall. Wolniejszy, ale brutalnie kontroluje przestrzeń.[/color]",
			definition = "[color=#e0e4f0]Firewall overload oznacza przeciążenie warstwy ochronnej zbyt dużym lub źle filtrowanym ruchem. Pomagają reguły minimalnego dostępu, filtrowanie na brzegu sieci, rate limiting i monitoring anomalii.[/color]"
		},
		{
			name = "APT (BOSS)",
			texture_path = "res://Assets/Characters/apt_boss.png",
			category = "bossy",
			hp = 200, speed = 1, attack = 20, wave = "10", type = "BOSS",
			lore = "[color=#e0e4f0]APT to nie wirus – to operacja. Zaawansowane, długotrwałe, finansowane przez państwa. Infiltruje system na miesiące, cierpliwie zbierając dane. Ostateczny boss: ogromne HP, druzgocący atak, zdolność adaptacji. Potrzebujesz pełnego arsenału.[/color]",
			definition = "[color=#e0e4f0]APT (Advanced Persistent Threat) to zaawansowane, długotrwałe zagrożenie – sponsorowana kampania cyberataku cechująca się wysokim poziomem technicznym i długotrwałą obecnością w sieci ofiary (miesiące/lata). Obrona wymaga Defense-in-Depth, ciągłego monitoringu (SOC) i threat huntingu.[/color]"
		},
		{
			name = "ROOTKIT (BOSS)",
			texture_path = "res://Assets/Characters/apt_boss.png",
			category = "bossy",
			hp = 150, speed = 2, attack = 15, wave = "8", type = "BOSS",
			lore = "[color=#e0e4f0]ROOTKIT to zło w najczystszej formie – nie widzisz go, ale jest wszędzie. Działa na poziomie jądra systemu, ukrywając się przed antywirusami. Tylko specjalistyczne skanery ujawnią jego pozycję. Drugi boss: mniej HP, ale szybszy i potrafi być niewidzialny.[/color]",
			definition = "[color=#e0e4f0]Rootkit to zestaw narzędzi ukrywających obecność malware poprzez modyfikację jądra systemu, sterowników lub bibliotek. Działa na niskim poziomie (często bootkit), co czyni go ekstremalnie trudnym do wykrycia. Usunięcie często wymaga formatowania dysku i reinstalacji systemu.[/color]"
		}
	]


# ============================================================
#  LIFECYCLE
# ============================================================
func _ready() -> void:
	_all_entries = _build_entries()
	_populate_list()
	_hide_details()
	visible = false

	_setup_scanline()
	_update_status_bar()


func _setup_scanline() -> void:
	if not _screen_panel:
		return
	_scanline_material = ShaderMaterial.new()
	var shader := Shader.new()
	shader.code = """shader_type canvas_item;
uniform float scanline_offset : hint_range(0, 1) = 0.0;

void fragment() {
	vec4 col = vec4(0.055, 0.095, 0.18, 1.0);
	float scanline = sin((UV.y * 600.0 + scanline_offset * 100.0) * 3.14159) * 0.025;
	col.rgb += scanline;
	float line = smoothstep(0.48, 0.52, fract(UV.y * 300.0 + scanline_offset));
	col.rgb = mix(col.rgb, vec3(0.12, 0.30, 0.36), line * 0.18);
	COLOR = col;
}"""
	_scanline_material.shader = shader
	_screen_panel.material = _scanline_material


func _process(delta: float) -> void:
	if not visible:
		return

	# Scanline overlay effect
	if _scanline_enabled and _screen_panel and _scanline_material:
		_scanline_offset += delta * 40.0
		if _scanline_offset > _screen_panel.size.y:
			_scanline_offset = 0.0
		_scanline_material.set_shader_parameter("scanline_offset", fmod(_scanline_offset / 600.0, 1.0))


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_close_button_pressed()


# ============================================================
#  PUBLIC API (called by laptop_object.gd)
# ============================================================
func open_bestiary() -> void:
	visible = true
	if _enemy_list.item_count > 0:
		_enemy_list.select(0)
		_on_enemy_list_item_selected(0)
	_update_status_bar()


# ============================================================
#  LIST POPULATION
# ============================================================
func _populate_list() -> void:
	_enemy_list.clear()

	for entry in _all_entries:
		var icon: Texture2D = _load_icon(entry.texture_path)
		var idx: int = _enemy_list.add_item(entry.name, icon, true)
		# Alternating row colors
		if idx % 2 == 0:
			_enemy_list.set_item_custom_bg_color(idx, Color(0.06, 0.11, 0.22, 0.85))
		else:
			_enemy_list.set_item_custom_bg_color(idx, Color(0.08, 0.15, 0.28, 0.85))


# ============================================================
#  ITEM SELECTION
# ============================================================
func _on_enemy_list_item_selected(index: int) -> void:
	if index < 0 or index >= _all_entries.size():
		return

	var entry: Dictionary = _all_entries[index]
	_show_entry_details(entry)


func _show_entry_details(entry: Dictionary) -> void:
	# Sprite
	_enemy_sprite.texture = _load_texture(entry.texture_path)

	# Name
	_enemy_name.text = entry.name

	# Lore
	_lore_label.text = String(entry.lore).replace("#e0e4f0", "#f4fbff")

	# Definition
	_definition_label.text = String(entry.definition).replace("#e0e4f0", "#f4fbff")

	_update_status_bar()


func _hide_details() -> void:
	_enemy_sprite.texture = null
	_enemy_name.text = " "
	_lore_label.text = ""
	_definition_label.text = ""


# ============================================================
#  CLOSE
# ============================================================
func _on_close_button_pressed() -> void:
	visible = false


# ============================================================
#  STATUS BAR
# ============================================================
func _update_status_bar() -> void:
	var status_label: Label = get_node_or_null("Control/ScreenContent/StatusBar/StatusText") as Label
	if status_label:
		status_label.text = "WPISÓW: %d | OSTATNIA AKTUALIZACJA: %s" % [_all_entries.size(), _get_sys_time()]


func _get_sys_time() -> String:
	var dt: Dictionary = Time.get_datetime_dict_from_system()
	return "%04d-%02d-%02d %02d:%02d:%02d" % [dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second]


# ============================================================
#  ASSET HELPERS
# ============================================================
func _load_icon(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var tex: Texture2D = load(path) as Texture2D
		if tex:
			return tex
	return _create_placeholder_icon()


func _load_texture(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var tex: Texture2D = load(path) as Texture2D
		if tex:
			return tex
	return null


func _create_placeholder_icon() -> Texture2D:
	var img := Image.create(20, 20, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.2, 0.9, 0.85, 1.0))
	return ImageTexture.create_from_image(img)
