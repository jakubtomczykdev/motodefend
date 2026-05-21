extends CharacterBody2D

@export var npc_name: String = "Marek Nowak - SOC Lead"

@export var expert_portrait: Texture2D = preload("res://Assets/Characters/cybersecuritySpecialist.png")
var dialogue_ui_scene: PackedScene = preload("res://scenes/ui/DialogueUI.tscn")

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
	AudioManager.play_sfx("interact_npc")
	interaction_count += 1
	if not intro_shown:
		_show_intro_sequence()
	else:
		_show_advanced_logic()

func _show_intro_sequence() -> void:
	var intro_lines: Array[String] = [
		"Piotr? . . . Słyszysz mnie? . . . Synchronizacja Twojej świadomości zakończona. . . Witaj w jadrze Motodefend.",
		"Wiem, że to przejście było brutalne. . . Ale nie było czasu na procedury. . . Z sekundy na sekundę cały system Motoroli po prostu oszalał.",
		"Nikt nie przewidział, że ten autonomiczny kod zawiedzie w ułamku sekundy. . . Musieliśmy Cię tam wgrać natychmiast, by ratować co się da.",
		"To, co teraz widzisz. . . Te potwory. . . To zniekształcone błędy logiczne, które materializują się w Twoim umyśle.",
		"Pamiętaj. . . Teraz Ty jesteś sercem systemu. . . Jeśli Twoja cyfrowa postać padnie, Twoja świadomość zgaśnie razem z nią. . . Nie mamy żadnej kopii zapasowej.",
		"Używaj sprzętu Motoroli, który udało mi się przesłać do Twojego interfejsu. . . To Twoja jedyna szansa na przetrwanie fali infekcji.",
		"Ruszaj przed siebie. . . Będę monitorował Twój stan z poziomu SOC. . . Nie pozwól im przejąć węzła, Piotr. . . Powodzenia."
	]
	intro_shown = true
	_start_dialogue_ui(intro_lines)

func _show_advanced_logic() -> void:
	if interaction_count % 5 == 0:
		_show_story_lore()
	else:
		_show_dynamic_tip()

func _show_story_lore() -> void:
	var lore_bits: Array[String] = [
		"Czy wiesz, że ten atak wygląda na skoordynowaną operację grupy APT? To nie są amatorzy.",
		"Analizuję nagłówki tych pakietów... Ktoś próbuje wyciągnąć nasze klucze deszyfrujące.",
		"Motorola dostarczyła nam nowe drony bojowe. Podobno ich firmware jest odporny na próby przejęcia.",
		"Ten system to labirynt. Jeśli padnie serwer główny, całe miasto straci łączność.",
		"Odebrałem zaszyfrowaną transmisję z sektora 7. Ktoś testuje nasze zapory. Bądź czujny.",
		"Właśnie dostałem raport — w darknecie pojawiły się oferty sprzedaży dostępu do naszej infrastruktury. Ktoś nas namierzył."
	]
	_start_dialogue_ui([lore_bits.pick_random()])

func _show_dynamic_tip() -> void:
	var tips = _get_all_tips()
	var tip: String = tips.pick_random()
	_start_dialogue_ui(["[PORADA SOC]: " + tip])

func _get_all_tips() -> Array[String]:
	var tips: Array[String] = []

	# === BEZPIECZNE HASŁA ===
	tips.append("[BEZPIECZNE HASŁA]: Hasło powinno mieć minimum 12 znaków — im dłuższe, tym trudniejsze do złamania brute-force.")
	tips.append("[BEZPIECZNE HASŁA]: Nie używaj tego samego hasła do wielu serwisów. Wyciek z jednej strony oznacza włam na wszystkie konta.")
	tips.append("[BEZPIECZNE HASŁA]: Używaj menedżera haseł (np. Bitwarden, 1Password). To sejf na Twoje dane logowania.")
	tips.append("[BEZPIECZNE HASŁA]: Hasło 'admin123', 'password' albo 'qwerty' to jak zostawienie kluczy pod wycieraczką. Pierwsze hasło, które sprawdzi atakujący.")
	tips.append("[BEZPIECZNE HASŁA]: Nie zapisuj haseł na karteczkach przyklejonych do monitora. Serio, to się ciągle zdarza nawet w firmach.")
	tips.append("[BEZPIECZNE HASŁA]: Twórz hasła jako frazy — np. 'MojPiesAzorLubiSpacerPoLesie!' jest łatwe do zapamiętania i trudne do złamania.")
	tips.append("[BEZPIECZNE HASŁA]: Zmieniaj hasła natychmiast jeśli usługa, z której korzystasz, zgłosiła wyciek danych.")
	tips.append("[BEZPIECZNE HASŁA]: Nie podawaj nikomu swoich haseł przez telefon ani email. SOC czy bank NIGDY nie prosi o hasło.")
	tips.append("[BEZPIECZNE HASŁA]: Sprawdzaj czy Twoje hasła wyciekły na stronie haveibeenpwned.com — to podstawowe narzędzie SOC.")
	tips.append("[BEZPIECZNE HASŁA]: Hasła zawierające datę urodzenia, imię psa lub nazwę ulicy są pierwszym celem ataku słownikowego.")

	# === 2FA / MFA ===
	tips.append("[2FA / MFA]: Zawsze włączaj uwierzytelnianie dwuskładnikowe (2FA). Samo hasło to za mało — potrzeba drugiego czynnika.")
	tips.append("[2FA / MFA]: Używaj aplikacji autentykacyjnych (Google Authenticator, Authy) zamiast kodów SMS. SMS-y można przechwycić przez SIM swapping.")
	tips.append("[2FA / MFA]: Klucze sprzętowe U2F (np. YubiKey) to najbezpieczniejsza forma drugiego składnika — fizyczny klucz, którego nikt nie sklonuje.")
	tips.append("[2FA / MFA]: Zapisz kody zapasowe 2FA w bezpiecznym miejscu offline. Bez nich możesz stracić dostęp do konta.")
	tips.append("[2FA / MFA]: Nawet z 2FA zachowaj czujność. Zaawansowane ataki phishingowe potrafią przechwycić kody jednorazowe w czasie rzeczywistym.")
	tips.append("[2FA / MFA]: Jeśli serwis oferuje 2FA — włącz je NATYCHMIAST. Każdy dzień bez drugiego składnika to ryzyko.")
	tips.append("[2FA / MFA]: Nie udostępniaj nikomu kodów 2FA. 'Pracownik banku' który prosi o kod SMS to oszust — bank nigdy o to nie prosi.")

	# === PHISHING I SOCJOTECHNIKA ===
	tips.append("[PHISHING]: Zawsze sprawdzaj adres nadawcy emaila. 'bank@twojbank.com' to nie to samo co 'bank@twojbank.xyz'.")
	tips.append("[PHISHING]: Nie klikaj w linki w podejrzanych mailach. Najedź kursorem na link, by zobaczyć dokąd naprawdę prowadzi.")
	tips.append("[PHISHING]: SMS o niedopłacie za paczkę to klasyczny smishing. Sprawdź status przesyłki bezpośrednio na stronie przewoźnika.")
	tips.append("[PHISHING]: Telefon od 'Microsoftu' że masz wirusa? To vishing — oszustwo głosowe. Microsoft nie dzwoni do użytkowników.")
	tips.append("[PHISHING]: Atakujący często tworzą poczucie pilności: 'Twoje konto zostanie zablokowane za 24h!'. Zachowaj spokój i zweryfikuj.")
	tips.append("[PHISHING]: Spear phishing to atak celowany — mail wygląda jak od Twojego szefa. Zawsze potwierdź nietypową prośbę przez inny kanał.")
	tips.append("[PHISHING]: Nie otwieraj załączników od nieznanych nadawców. Plik .docx może zawierać makra, a .pdf exploita.")
	tips.append("[PHISHING]: Sprawdzaj certyfikat SSL strony przed podaniem danych. Kłódka przy adresie to minimum, nie gwarancja bezpieczeństwa.")
	tips.append("[PHISHING]: Phishing ewoluuje — deepfake audio i wideo potrafią udawać głos Twojego przełożonego. Weryfikuj przez drugi kanał.")
	tips.append("[PHISHING]: Jeśli 'znajomy' na Facebooku prosi o pieniądze — zadzwoń do niego. Konto mogło zostać przejęte.")
	tips.append("[PHISHING]: Nie podawaj haseł przez formularze w mailach. Żaden legalny serwis nie prosi o hasło emailem.")
	tips.append("[PHISHING]: Ataki BEC (Business Email Compromise) to miliardowe straty. Jeden fałszywy mail od 'prezesa' i firma przelewa miliony.")

	# === AKTUALIZACJE I PATCHING ===
	tips.append("[AKTUALIZACJE]: Aktualizuj system operacyjny i aplikacje regularnie. Każda niezałatana luka to otwarte drzwi dla atakującego.")
	tips.append("[AKTUALIZACJE]: Ataki Zero-Day wykorzystują luki nieznane producentowi. Jedyna obrona: szybkie łatanie po wydaniu poprawki.")
	tips.append("[AKTUALIZACJE]: Włącz automatyczne aktualizacje systemu. Lepiej stracić 5 minut na restart niż wszystkie dane na ransomware.")
	tips.append("[AKTUALIZACJE]: Nie ignoruj powiadomień o aktualizacjach. Każde 'przypomnij później' to kolejny dzień z otwartą luką.")
	tips.append("[AKTUALIZACJE]: Aktualizuj nie tylko system, ale też router, drukarkę, telewizor. Każde urządzenie w sieci to potencjalny wektor ataku.")
	tips.append("[AKTUALIZACJE]: Firemne stacje robocze bez aktualizacji to najczęstsza przyczyna incydentów ransomware w małych firmach.")
	tips.append("[AKTUALIZACJE]: Sprawdzaj, czy producent Twojego sprzętu nadal publikuje łatki. Niewspierane urządzenia odłącz od internetu.")

	# === BEZPIECZNE PRZEGLĄDANIE INTERNETU ===
	tips.append("[PRZEGLĄDANIE]: Zawsze sprawdzaj czy strona używa HTTPS (kłódka w pasku adresu). HTTP przesyła dane czystym tekstem.")
	tips.append("[PRZEGLĄDANIE]: Zainstaluj bloker reklam (uBlock Origin). Reklamy to częsty wektor malware (malvertising).")
	tips.append("[PRZEGLĄDANIE]: Tryb incognito NIE chroni Twojej prywatności. Ukrywa tylko historię przed współużytkownikami komputera, nie przed stronami.")
	tips.append("[PRZEGLĄDANIE]: VPN szyfruje Twój ruch, ale nie czyni Cię anonimowym. Zaufany dostawca VPN nie prowadzi logów — sprawdź politykę.")
	tips.append("[PRZEGLĄDANIE]: Nie pobieraj pirackiego oprogramowania. Cracki i keygeny to najpopularniejszy nośnik trojanów.")
	tips.append("[PRZEGLĄDANIE]: Wyłącz zapamiętywanie haseł w przeglądarce na współdzielonych komputerach. Używaj trybu gościa.")
	tips.append("[PRZEGLĄDANIE]: Rozszerzenia przeglądarki mają dostęp do Twoich danych. Instaluj tylko zaufane, sprawdzone dodatki.")

	# === PUBLICZNE WiFi ===
	tips.append("[PUBLICZNE WiFi]: Nie loguj się do banku ani nie rób zakupów na publicznym WiFi. Otwarta sieć to raj dla ataków MITM.")
	tips.append("[PUBLICZNE WiFi]: Zawsze używaj VPN na publicznym WiFi. Szyfruje cały Twój ruch, nawet jeśli sieć jest niezabezpieczona.")
	tips.append("[PUBLICZNE WiFi]: Atakujący mogą postawić fałszywy hotspot o nazwie 'Hotel_WiFi_Free' obok prawdziwego. Zawsze pytaj obsługę o nazwę sieci.")
	tips.append("[PUBLICZNE WiFi]: Wyłącz automatyczne łączenie z sieciami WiFi w telefonie. Twój telefon może połączyć się ze złośliwym hotspotem bez Twojej wiedzy.")
	tips.append("[PUBLICZNE WiFi]: Jeśli musisz użyć publicznego WiFi, ogranicz się do przeglądania. Nie loguj się na konta email ani social media bez VPN.")
	tips.append("[PUBLICZNE WiFi]: Na lotnisku, w hotelu, w kawiarni — wszędzie tam atakujący może podsłuchiwać ruch. VPN to Twoja tarcza.")

	# === BACKUPY ===
	tips.append("[BACKUPY]: Zasada 3-2-1: 3 kopie danych, na 2 różnych nośnikach, 1 kopia poza lokalizacją (offsite). To standard SOC.")
	tips.append("[BACKUPY]: Backup offline (odłączony od sieci) jest odporny na ransomware. Jeśli dysk backupowy jest podłączony — wirus też go zaszyfruje.")
	tips.append("[BACKUPY]: Regularnie testuj odtwarzanie z backupów. Backup którego nie da się odtworzyć to tylko złudzenie bezpieczeństwa.")
	tips.append("[BACKUPY]: Automatyzuj backupy, ale sprawdzaj logi. 'Ustaw i zapomnij' często kończy się 'ustaw i zapomniałeś, że nie działa'.")
	tips.append("[BACKUPY]: Najważniejsze dane (dokumenty, zdjęcia, klucze szyfrujące) trzymaj w co najmniej dwóch fizycznych lokalizacjach.")
	tips.append("[BACKUPY]: Chmura to nie backup — to synchronizacja. Ransomware zaszyfruje pliki, a chmura 'zsynchronizuje' zaszyfrowane wersje.")
	tips.append("[BACKUPY]: Rób backup przed każdą większą aktualizacją systemu. Jeśli coś pójdzie nie tak, zawsze możesz wrócić.")

	# === SOCIAL MEDIA I PRYWATNOŚĆ ===
	tips.append("[SOCIAL MEDIA]: Oversharing to kopalnia danych dla atakujących. Zdjęcie z wakacji = 'nie ma mnie w domu'. Bilet lotniczy = numer rezerwacji.")
	tips.append("[SOCIAL MEDIA]: Sprawdź ustawienia prywatności na każdym portalu. Domyślne ustawienia zwykle upubliczniają więcej niż myślisz.")
	tips.append("[SOCIAL MEDIA]: Zdjęcia ze smartfona zawierają metadane EXIF — lokalizację GPS, datę, model telefonu. Wyłącz geotagowanie.")
	tips.append("[SOCIAL MEDIA]: Atakujący potrafią zrekonstruować Twój rozkład dnia z samych postów. Nie publikuj w czasie rzeczywistym swojej lokalizacji.")
	tips.append("[SOCIAL MEDIA]: 'Quiz o Twoim pierwszym zwierzaku' to zbieranie odpowiedzi na pytania kontrolne do kont bankowych. Nie odpowiadaj.")
	tips.append("[SOCIAL MEDIA]: Nie akceptuj zaproszeń od nieznajomych. Fałszywe profile to podstawa socjotechniki i spear phishingu.")
	tips.append("[SOCIAL MEDIA]: Usuń stare konta, z których nie korzystasz. Każde nieaktywne konto to potencjalny wektor wycieku danych.")
	tips.append("[SOCIAL MEDIA]: Pamiętaj: internet nie zapomina. To co opublikujesz, może być użyte przeciwko Tobie za 10 lat.")

	# === BEZPIECZEŃSTWO URZĄDZEŃ ===
	tips.append("[URZĄDZENIA]: Zawsze blokuj ekran — telefonu, laptopa, tabletu. PIN, hasło lub biometria. Kradzież odblokowanego urządzenia to katastrofa.")
	tips.append("[URZĄDZENIA]: Włącz szyfrowanie dysku (BitLocker na Windows, FileVault na Mac). Bez niego złodziej odczyta wszystkie Twoje dane.")
	tips.append("[URZĄDZENIA]: Antywirus to nie magiczna tarcza — to ostatnia linia obrony. Zdrowy rozsądek i aktualizacje są ważniejsze.")
	tips.append("[URZĄDZENIA]: Sprawdzaj uprawnienia aplikacji mobilnych. Aplikacja latarka NIE potrzebuje dostępu do kontaktów i lokalizacji.")
	tips.append("[URZĄDZENIA]: Nie podłączaj znalezionych pendrive'ów do komputera. To klasyczny wektor ataku — 'zgubiony' pendrive na parkingu.")
	tips.append("[URZĄDZENIA]: Wyłącz Bluetooth gdy nie używasz. Ataki BlueBorne pozwalają przejąć urządzenie przez Bluetooth bez Twojej interakcji.")
	tips.append("[URZĄDZENIA]: Regularnie restartuj router domowy. Niektóre malware (np. VPNFilter) działa tylko w pamięci i restart je usuwa.")

	# === DZIECI W SIECI ===
	tips.append("[DZIECI W SIECI]: Rozmawiaj z dziećmi o zagrożeniach online. Otwarta komunikacja jest skuteczniejsza niż same blokady techniczne.")
	tips.append("[DZIECI W SIECI]: Skonfiguruj kontrolę rodzicielską — nie jako szpiegowanie, ale jako narzędzie ochrony przed nieodpowiednimi treściami.")
	tips.append("[DZIECI W SIECI]: Naucz dzieci zasady: nigdy nie podawaj prawdziwego imienia, adresu ani szkoły obcym w internecie.")
	tips.append("[DZIECI W SIECI]: Cyberprzemoc jest realna. Naucz dziecko, by zgłaszało każdy przypadek nękania — Tobie lub zaufanemu nauczycielowi.")
	tips.append("[DZIECI W SIECI]: Ustal zasady czasu ekranowego. Nie chodzi tylko o bezpieczeństwo — zdrowie psychiczne też jest ważne.")
	tips.append("[DZIECI W SIECI]: Sprawdzaj w co grają Twoje dzieci. Nie każda gra z czatem głosowym jest bezpieczna dla 8-latka.")
	tips.append("[DZIECI W SIECI]: Bądź wzorem. Jeśli Ty scrollujesz telefon przy obiedzie, dziecko będzie robić to samo. Higiena cyfrowa zaczyna się od rodziców.")

	# === Z GRY DO ŻYCIA (oryginalne porady) ===
	tips.append("[Z GRY DO ŻYCIA]: Ransomware to nie żart. Stosuj zasadę 3-2-1 dla swoich danych: 3 kopie, 2 nośniki, 1 offline.")
	tips.append("[Z GRY DO ŻYCIA]: Widzisz te Wormy? One nie potrzebują Twojej zgody na replikację. Tnij je szybko, zanim skolonizują sieć!")
	tips.append("[Z GRY DO ŻYCIA]: Phishing zawsze uderza w najsłabsze ogniwo – emocje. W grze porusza się tak, by Cię zmylić. Zachowaj zimną krew.")
	tips.append("[Z GRY DO ŻYCIA]: SQL Injection to klasyczny błąd braku walidacji inputu. W grze przebija się przez proste osłony – miej to na uwadze.")
	tips.append("[Z GRY DO ŻYCIA]: Zaktualizuj swój 'Firewall' w sklepie. Każdy punkt statystyk to dodatkowa warstwa Defense-in-Depth.")
	tips.append("[Z GRY DO ŻYCIA]: Zaglądaj do Bestiariusza na laptopie. Wiedza to najpotężniejszy exploit przeciwko wirusom.")
	tips.append("[Z GRY DO ŻYCIA]: Jeśli poczujesz, że tracisz kontrolę, użyj Dodge Roll. To Twój osobisty system IPS (Intrusion Prevention System).")
	tips.append("[Z GRY DO ŻYCIA]: Spyware zbiera dane w cieniu. Jeśli go nie widzisz, on na pewno widzi Ciebie. Skanuj arenę uważnie!")

	return tips

func _start_dialogue_ui(lines: Array[String]) -> void:
	var ui = dialogue_ui_scene.instantiate()
	get_tree().root.add_child(ui)
	ui.start_dialogue(npc_name, expert_portrait, lines)
