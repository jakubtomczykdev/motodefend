extends Control
## EducationalSystem - pre-wave cyber lessons with artwork, attack flow, defense tips, and a short quiz.

signal education_completed

const IMAGE_BASE := "res://Assets/educational/"
const LESSON_STEPS := ["ROZPOZNANIE", "MECHANIZM ATAKU", "OBRONA W PRAKTYCE"]

var lesson_content: Dictionary = {
	"worm": {
		"title": "ROBAK SIECIOWY",
		"subtitle": "Samoreplikacja bez kliknięcia użytkownika",
		"image": IMAGE_BASE + "edu_worm.png",
		"accent": Color(0.42, 1.0, 0.62),
		"steps": [
			{
				"title": "Co widzisz w tej fali?",
				"body": "Robak rozprzestrzenia się samodzielnie przez sieć. Nie musi czekać, aż ktoś uruchomi załącznik - szuka podatnych urządzeń i kopiuje się dalej.",
				"bullets": ["cel: szybkie namnażanie", "wektor: luka w usłudze lub słaba konfiguracja", "efekt w grze: wielu szybkich przeciwników"]
			},
			{
				"title": "Jak działa atak?",
				"body": "Robak skanuje sąsiednie hosty, znajduje podatność, kopiuje swój kod i uruchamia kolejną instancję. Jedna infekcja może szybko zmienić się w epidemię.",
				"bullets": ["skanowanie hostów", "wykorzystanie podatności", "kopiowanie i dalsze skanowanie"]
			},
			{
				"title": "Jak się bronić?",
				"body": "Najważniejsze jest zmniejszenie liczby podatnych celów. Aktualizacje, segmentacja sieci i ograniczenie niepotrzebnych usług zatrzymują rozrost robaka.",
				"bullets": ["regularne aktualizacje", "firewall i segmentacja", "wyłączanie nieużywanych usług"]
			}
		],
		"quiz": {
			"question": "Które działanie najlepiej ogranicza rozprzestrzenianie robaka?",
			"answers": ["Segmentacja sieci i aktualizacje", "Otworzenie większej liczby portów", "Wyłączenie kopii zapasowych"],
			"correct": 0,
			"feedback": "Tak. Segmentacja ogranicza zasięg infekcji, a aktualizacje zamykają znane luki."
		}
	},
	"trojan": {
		"title": "TROJAN",
		"subtitle": "Legalnie wyglądający program z ukrytym ładunkiem",
		"image": IMAGE_BASE + "edu_trojan.png",
		"accent": Color(1.0, 0.72, 0.32),
		"steps": [
			{
				"title": "Co widzisz w tej fali?",
				"body": "Trojan udaje coś zaufanego: instalator, dokument, narzędzie lub aktualizację. Problem zaczyna się dopiero po uruchomieniu.",
				"bullets": ["maskowanie jako legalny plik", "uruchomienie przez użytkownika", "ukryta funkcja szkodliwa"]
			},
			{
				"title": "Jak działa atak?",
				"body": "Po uruchomieniu trojan może utworzyć backdoor, pobrać kolejne komponenty albo przechwytywać dane logowania. To nie jest tylko jeden plik - to wejście do systemu.",
				"bullets": ["fałszywy instalator", "backdoor", "kradzież haseł lub dalsza infekcja"]
			},
			{
				"title": "Jak się bronić?",
				"body": "Nie ufaj samemu wyglądowi pliku. Liczy się źródło, podpis cyfrowy, reputacja aplikacji i skanowanie przed uruchomieniem.",
				"bullets": ["pobieranie z oficjalnych źródeł", "weryfikacja podpisu", "EDR/antywirus i zasada najmniejszych uprawnień"]
			}
		],
		"quiz": {
			"question": "Co jest typowym sygnałem ryzyka trojana?",
			"answers": ["Instalator z nieznanego źródła", "Program z oficjalnego repozytorium", "Plik podpisany przez znanego wydawcę"],
			"correct": 0,
			"feedback": "Tak. Trojan najczęściej korzysta z zaufania do fałszywego lub podmienionego pliku."
		}
	},
	"ransomware": {
		"title": "RANSOMWARE",
		"subtitle": "Szyfrowanie danych i presja okupu",
		"image": IMAGE_BASE + "edu_ransomware.png",
		"accent": Color(1.0, 0.32, 0.38),
		"steps": [
			{
				"title": "Co widzisz w tej fali?",
				"body": "Ransomware blokuje dostęp do danych przez szyfrowanie plików. Atakujący żąda zapłaty, ale okup nie gwarantuje odzyskania systemu.",
				"bullets": ["szyfrowanie plików", "presja czasu", "ryzyko wycieku danych"]
			},
			{
				"title": "Jak działa atak?",
				"body": "Najpierw następuje wejście do sieci, potem rozpoznanie zasobów i dopiero na końcu masowe szyfrowanie. Dlatego szybkie wykrycie jest tak ważne.",
				"bullets": ["phishing lub luka", "ruch boczny w sieci", "szyfrowanie i żądanie okupu"]
			},
			{
				"title": "Jak się bronić?",
				"body": "Najsilniejsza obrona to kopie zapasowe offline, ćwiczone odtwarzanie danych, 2FA oraz blokowanie ruchu bocznego w sieci.",
				"bullets": ["backup offline", "test przywracania", "2FA i segmentacja"]
			}
		],
		"quiz": {
			"question": "Co najbardziej pomaga wrócić po ataku ransomware?",
			"answers": ["Sprawdzony backup offline", "Zapamiętanie hasła administratora", "Wyłączenie logów bezpieczeństwa"],
			"correct": 0,
			"feedback": "Tak. Backup offline i przetestowane odtwarzanie danych są kluczowe."
		}
	},
	"spyware": {
		"title": "SPYWARE / KEYLOGGER",
		"subtitle": "Ciche przechwytywanie danych",
		"image": IMAGE_BASE + "edu_spyware.png",
		"accent": Color(0.7, 0.55, 1.0),
		"steps": [
			{
				"title": "Co widzisz w tej fali?",
				"body": "Spyware nie musi niszczyć systemu. Jego celem jest obserwacja: hasła, zrzuty ekranu, kliknięcia, pliki i aktywność użytkownika.",
				"bullets": ["ukryte monitorowanie", "keylogging", "kradzież danych i prywatności"]
			},
			{
				"title": "Jak działa atak?",
				"body": "Po instalacji spyware działa w tle. Może wysyłać dane do serwera atakującego i próbować ukryć swój proces przed użytkownikiem.",
				"bullets": ["instalacja w tle", "zbieranie danych", "wysyłka do centrum sterowania"]
			},
			{
				"title": "Jak się bronić?",
				"body": "Pomaga ograniczenie uprawnień, aktualizacje, skanowanie antymalware i 2FA. Jeśli hasło wycieknie, drugi składnik nadal utrudnia przejęcie konta.",
				"bullets": ["2FA", "monitoring procesów", "nieinstalowanie podejrzanych dodatków"]
			}
		],
		"quiz": {
			"question": "Dlaczego 2FA pomaga przy spyware?",
			"answers": ["Samo hasło nie wystarcza do logowania", "Przyspiesza komputer", "Zastępuje aktualizacje systemu"],
			"correct": 0,
			"feedback": "Tak. Nawet przechwycone hasło nie daje pełnego dostępu bez drugiego składnika."
		}
	},
	"phishing": {
		"title": "PHISHING",
		"subtitle": "Podszywanie się pod zaufane źródło",
		"image": IMAGE_BASE + "edu_phishing.png",
		"accent": Color(1.0, 0.82, 0.28),
		"steps": [
			{
				"title": "Co widzisz w tej fali?",
				"body": "Phishing nie atakuje najpierw komputera, tylko decyzję człowieka. Fałszywa wiadomość ma skłonić do kliknięcia, pobrania pliku albo podania hasła.",
				"bullets": ["presja czasu", "podszycie pod bank, kuriera lub firmę", "link do fałszywej strony"]
			},
			{
				"title": "Jak działa atak?",
				"body": "Atakujący buduje wiarygodną przynętę, wysyła link lub załącznik, a potem przechwytuje dane albo instaluje malware.",
				"bullets": ["wiadomość-przynęta", "fałszywa strona logowania", "kradzież danych lub infekcja"]
			},
			{
				"title": "Jak się bronić?",
				"body": "Sprawdzaj nadawcę, domenę i sens prośby. Nie loguj się z linku w wiadomości - wpisz adres ręcznie lub użyj zapisanego skrótu.",
				"bullets": ["sprawdzenie domeny", "brak klikania w pilne linki", "zgłaszanie podejrzanych wiadomości"]
			}
		],
		"quiz": {
			"question": "Co zrobić z pilnym linkiem do logowania z SMS-a?",
			"answers": ["Wejść na stronę ręcznie lub przez zapisany skrót", "Kliknąć, jeśli logo wygląda dobrze", "Podać hasło i szybko zamknąć stronę"],
			"correct": 0,
			"feedback": "Tak. Ręczne wejście na znany adres omija fałszywy link."
		}
	},
	"sql": {
		"title": "SQL INJECTION",
		"subtitle": "Dane wejściowe zmieniają zapytanie do bazy",
		"image": IMAGE_BASE + "edu_sql.png",
		"accent": Color(0.45, 0.86, 1.0),
		"steps": [
			{
				"title": "Co widzisz w tej fali?",
				"body": "SQL Injection pojawia się, gdy aplikacja traktuje dane użytkownika jak część polecenia do bazy. Formularz staje się wtedy wejściem dla ataku.",
				"bullets": ["podatne pole formularza", "zmiana logiki zapytania", "dostęp do cudzych danych"]
			},
			{
				"title": "Jak działa atak?",
				"body": "Atakujący wprowadza specjalnie przygotowaną wartość. Jeśli kod skleja tekst zapytania ręcznie, baza może wykonać coś, czego programista nie planował.",
				"bullets": ["wejście użytkownika", "sklejone zapytanie", "odczyt, zmiana lub usunięcie danych"]
			},
			{
				"title": "Jak się bronić?",
				"body": "Najważniejsze są zapytania parametryzowane. Walidacja pomaga, ale nie zastępuje parametrów i ograniczonych uprawnień konta bazy.",
				"bullets": ["prepared statements", "walidacja wejścia", "minimalne uprawnienia bazy"]
			}
		],
		"quiz": {
			"question": "Najlepsza podstawowa ochrona przed SQL Injection to:",
			"answers": ["Zapytania parametryzowane", "Dłuższe hasło użytkownika", "Większy serwer bazy danych"],
			"correct": 0,
			"feedback": "Tak. Parametry oddzielają dane od kodu zapytania."
		}
	},
	"hijacking": {
		"title": "HIJACKING",
		"subtitle": "Przejecie sesji, polaczenia albo kontroli nad zasobem",
		"image": "res://Assets/Characters/data_hijacker.png",
		"accent": Color(1.0, 0.22, 0.18),
		"steps": [
			{
				"title": "Co widzisz w tej fali?",
				"body": "Hijacking oznacza przejecie czegos, co powinno nalezec do uzytkownika: sesji logowania, polaczenia, domeny, przegladarki albo konta. Atakujacy nie musi niszczyc systemu - wystarczy, ze podszyje sie pod legalny dostep.",
				"bullets": ["cel: przejecie kontroli", "wektor: skradziony token, cookie lub sesja", "efekt w grze: szybka szarza po oznaczonym torze"]
			},
			{
				"title": "Jak dziala atak?",
				"body": "Atakujacy najpierw zdobywa identyfikator sesji albo kieruje ruch przez falszywy punkt. Potem uzywa tego dostepu, zanim ofiara lub system zauwazy anomalie.",
				"bullets": ["kradziez tokenu lub cookie", "podszycie pod legalnego uzytkownika", "szybkie wykorzystanie dostepu"]
			},
			{
				"title": "Jak sie bronic?",
				"body": "Najwazniejsze sa MFA, krotki czas zycia sesji, ponowna autoryzacja dla wrazliwych akcji i wykrywanie nietypowego miejsca lub urzadzenia logowania.",
				"bullets": ["MFA i rotacja tokenow", "Secure/HttpOnly/SameSite cookies", "monitoring nietypowych sesji"]
			}
		],
		"quiz": {
			"question": "Co najlepiej ogranicza skutki session hijackingu?",
			"answers": ["MFA, krotkie sesje i wykrywanie anomalii", "Udostepnienie tokenu w URL", "Wylaczenie powiadomien o logowaniu"],
			"correct": 0,
			"feedback": "Tak. Nawet skradziona sesja ma wtedy mniejsza wartosc i latwiej wykryc naduzycie."
		}
	},
	"smurf_attack": {
		"title": "SMURF ATTACK",
		"subtitle": "Odbity flood pakietow, ktory zalewa cel ruchem",
		"image": "res://Assets/Characters/smurf_attack_boss.png",
		"accent": Color(0.12, 0.72, 1.0),
		"steps": [
			{
				"title": "Co widzisz w tej fali?",
				"body": "Smurf Attack to odmiana DDoS. Atakujacy wysyla pakiety ICMP z podrobionym adresem ofiary do sieci rozgloszeniowych. Wiele maszyn odpowiada wtedy ofierze naraz, wzmacniajac ruch.",
				"bullets": ["cel: zalanie ruchem", "wektor: spoofing adresu IP", "efekt w grze: boss rzuca packet-minionami"]
			},
			{
				"title": "Jak dziala atak?",
				"body": "Zamiast atakowac samemu, napastnik wykorzystuje cudza infrastrukture jako wzmacniacz. Ofiara dostaje odpowiedzi z wielu hostow, choc sama ich nie prosila.",
				"bullets": ["podrobiony adres zrodlowy", "broadcast albo zle filtrowana siec", "wiele odpowiedzi wraca do ofiary"]
			},
			{
				"title": "Jak sie bronic?",
				"body": "Najwazniejsze jest blokowanie directed broadcast, filtrowanie spoofingu na brzegach sieci i ochrona anty-DDoS, ktora odcina nietypowy flood zanim zapcha usluge.",
				"bullets": ["wylacz directed broadcast", "BCP38 / anti-spoofing", "rate limiting i scrubbing DDoS"]
			}
		],
		"quiz": {
			"question": "Co najlepiej ogranicza Smurf Attack?",
			"answers": ["Blokada spoofingu i directed broadcast", "Wylaczenie MFA", "Dluzsza nazwa uzytkownika"],
			"correct": 0,
			"feedback": "Tak. Bez spoofingu i wzmacniaczy broadcast atak traci najwazniejszy mechanizm."
		}
	},
	"firewall_overload": {
		"title": "FIREWALL OVERLOAD",
		"subtitle": "Przeciazenie ochrony przez zbyt duzy i zle filtrowany ruch",
		"image": "res://Assets/Characters/firewall_overload_boss.png",
		"accent": Color(1.0, 0.42, 0.08),
		"steps": [
			{
				"title": "Co widzisz w tej fali?",
				"body": "Firewall Overload zalewa punkt ochrony ruchem i wymusza decyzje: co przepuscic, co odciac i gdzie postawic granice. W grze boss zamyka przestrzen scianami firewall.",
				"bullets": ["cel: przeciazenie kontroli ruchu", "wektor: flood i bledne reguly", "efekt w grze: sciany i impuls obszarowy"]
			},
			{
				"title": "Jak dziala atak?",
				"body": "Napastnik generuje duzo polaczen albo pakietow, czesto z roznych zrodel. Slabe reguly, brak rate limitow i brak priorytetow sprawiaja, ze ochrona sama staje sie waskim gardlem.",
				"bullets": ["duzy wolumen ruchu", "brak filtrowania na brzegu", "przeciazenie firewalla lub uslugi"]
			},
			{
				"title": "Jak sie bronic?",
				"body": "Pomaga filtrowanie jak najblizej brzegu sieci, rate limiting, jasne reguly allowlist/denylist i monitoring anomalii zanim ruch dojdzie do krytycznych zasobow.",
				"bullets": ["rate limiting", "reguly minimalnego dostepu", "monitoring i ochrona DDoS"]
			}
		],
		"quiz": {
			"question": "Co najlepiej ogranicza przeciazenie firewalla?",
			"answers": ["Rate limiting i filtrowanie ruchu na brzegu", "Otwarcie wszystkich portow", "Wylaczenie monitoringu"],
			"correct": 0,
			"feedback": "Tak. Im wczesniej odfiltrujesz zly ruch, tym mniej obciaza on system obrony."
		}
	},
	"apt_boss": {
		"title": "APT",
		"subtitle": "Długotrwała i ukryta kampania ataku",
		"image": "",
		"accent": Color(1.0, 0.35, 0.72),
		"steps": [
			{
				"title": "Co widzisz w tej fali?",
				"body": "APT to nie pojedynczy wirus, tylko cierpliwa operacja. Atakujący próbuje utrzymać dostęp jak najdłużej i zbierać wartościowe dane.",
				"bullets": ["celowany atak", "długi czas obecności", "ukrywanie śladów"]
			},
			{
				"title": "Jak działa atak?",
				"body": "Najpierw jest wejście, potem rozpoznanie, eskalacja uprawnień i ruch boczny. APT wygrywa wtedy, gdy obrona patrzy tylko na pojedyncze alerty.",
				"bullets": ["initial access", "persistence", "lateral movement"]
			},
			{
				"title": "Jak się bronić?",
				"body": "Potrzebna jest obrona warstwowa: logi, monitoring, segmentacja, MFA, threat hunting i szybkie reagowanie na anomalie.",
				"bullets": ["monitoring i korelacja zdarzeń", "MFA", "segmentacja i threat hunting"]
			}
		],
		"quiz": {
			"question": "Co najlepiej pasuje do obrony przed APT?",
			"answers": ["Monitoring, MFA i segmentacja", "Jedno hasło administratora dla wszystkich", "Brak logów, żeby oszczędzić miejsce"],
			"correct": 0,
			"feedback": "Tak. APT wymaga obrony warstwowej, nie jednego zabezpieczenia."
		}
	},
	"intro": {
		"title": "TRENING CYBEROBRONY",
		"subtitle": "Krótka lekcja przed każdą falą",
		"image": "",
		"accent": Color(0.35, 0.94, 1.0),
		"steps": [
			{
				"title": "Jak czytać scenki?",
				"body": "Każda lekcja pokazuje jedno realne zagrożenie: czym jest, jak działa i jaka decyzja obronna ma największy sens.",
				"bullets": ["obraz zagrożenia", "mechanizm ataku", "praktyczna decyzja obronna"]
			},
			{
				"title": "Jak to łączy się z walką?",
				"body": "Wrogowie w grze reprezentują zachowania malware. Szybkie robaki uczą izolacji, ransomware uczy backupów, phishing uczy weryfikacji źródła.",
				"bullets": ["typ przeciwnika = typ ryzyka", "fale przypominają scenariusze ataku", "obrona w UI odpowiada obronie w realnym systemie"]
			},
			{
				"title": "Cel lekcji",
				"body": "Nie zapamiętuj definicji słowo w słowo. Zapamiętaj decyzję, którą można podjąć w realnym życiu.",
				"bullets": ["sprawdź źródło", "aktualizuj i segmentuj", "miej backup i MFA"]
			}
		],
		"quiz": {
			"question": "Co jest celem tych scenek?",
			"answers": ["Nauczyć decyzji obronnych", "Zatrzymać grę bez powodu", "Zastąpić walkę tekstem"],
			"correct": 0,
			"feedback": "Tak. Każda scenka ma zostawić jedną konkretną decyzję obronną."
		}
	},
	"unknown": {
		"title": "NIEZNANE ZAGROŻENIE",
		"subtitle": "Użyj zasad cyberhigieny",
		"image": "",
		"accent": Color(0.35, 0.94, 1.0),
		"steps": [
			{
				"title": "Co widzisz w tej fali?",
				"body": "Nie każde zagrożenie da się rozpoznać od razu. Wtedy liczą się podstawy: najmniejsze uprawnienia, aktualizacje i obserwacja anomalii.",
				"bullets": ["nietypowe zachowanie", "nieznany wektor", "brak pełnego obrazu"]
			},
			{
				"title": "Jak działa atak?",
				"body": "Atak może łączyć kilka technik. Dlatego jedna kontrola bezpieczeństwa nie wystarczy.",
				"bullets": ["wejście", "eskalacja", "utrzymanie dostępu"]
			},
			{
				"title": "Jak się bronić?",
				"body": "Zastosuj defense-in-depth: wiele prostych barier, które razem utrudniają atak.",
				"bullets": ["MFA", "aktualizacje", "monitoring i kopie zapasowe"]
			}
		],
		"quiz": {
			"question": "Co oznacza defense-in-depth?",
			"answers": ["Kilka warstw zabezpieczeń naraz", "Jedno bardzo mocne hasło", "Wyłączenie wszystkich alertów"],
			"correct": 0,
			"feedback": "Tak. Warstwy zabezpieczeń zmniejszają skutki błędu jednej kontroli."
		}
	}
}

var quiz_variants: Dictionary = {
	"worm": [
		{
			"question": "Ktore dzialanie najlepiej ogranicza rozprzestrzenianie robaka?",
			"answers": ["Segmentacja sieci i aktualizacje", "Otworzenie wiekszej liczby portow", "Wylaczenie kopii zapasowych"],
			"correct": 0,
			"feedback": "Tak. Segmentacja ogranicza zasieg infekcji, a aktualizacje zamykaja znane luki."
		},
		{
			"question": "Dlaczego robaki sieciowe rozchodza sie tak szybko?",
			"answers": ["Same szukaja podatnych hostow", "Czekaja na restart komputera", "Dzialaja tylko po recznym skopiowaniu"],
			"correct": 0,
			"feedback": "Tak. Robak automatycznie skanuje siec i kopiuje sie na kolejne podatne urzadzenia."
		},
		{
			"question": "Co zmniejsza liczbe latwych celow dla robaka?",
			"answers": ["Wylaczanie nieuzywanych uslug", "Trzymanie wszystkich hostow w jednej podsieci", "Otwieranie dodatkowych portow"],
			"correct": 0,
			"feedback": "Tak. Mniej uslug i lepsza segmentacja oznaczaja mniej drog rozprzestrzeniania."
		}
	],
	"trojan": [
		{
			"question": "Co jest typowym sygnalem ryzyka trojana?",
			"answers": ["Instalator z nieznanego zrodla", "Program z oficjalnego repozytorium", "Plik podpisany przez znanego wydawce"],
			"correct": 0,
			"feedback": "Tak. Trojan najczesciej korzysta z zaufania do falszywego lub podmienionego pliku."
		},
		{
			"question": "Co sprawdzic przed uruchomieniem pobranego programu?",
			"answers": ["Zrodlo i podpis cyfrowy", "Kolor ikony", "Czy nazwa pliku jest krotka"],
			"correct": 0,
			"feedback": "Tak. Zrodlo, reputacja i podpis pomagaja odroznic legalny plik od pulapki."
		},
		{
			"question": "Dlaczego trojan jest grozny mimo legalnego wygladu?",
			"answers": ["Moze miec ukryty ladunek", "Zawsze przyspiesza system", "Dziala tylko bez internetu"],
			"correct": 0,
			"feedback": "Tak. Wyglad moze byc przyneta, a szkodliwa funkcja uruchamia sie w tle."
		}
	],
	"ransomware": [
		{
			"question": "Co najbardziej pomaga wrocic po ataku ransomware?",
			"answers": ["Sprawdzony backup offline", "Zapamietanie hasla administratora", "Wylaczenie logow bezpieczenstwa"],
			"correct": 0,
			"feedback": "Tak. Backup offline i przetestowane odtwarzanie danych sa kluczowe."
		},
		{
			"question": "Dlaczego backup trzeba testowac?",
			"answers": ["Zeby miec pewnosc, ze da sie go odtworzyc", "Zeby zajmowal wiecej miejsca", "Zeby usunac starsze alerty"],
			"correct": 0,
			"feedback": "Tak. Kopia, ktorej nie da sie przywrocic, nie uratuje systemu po szyfrowaniu."
		}
	],
	"spyware": [
		{
			"question": "Dlaczego 2FA pomaga przy spyware?",
			"answers": ["Samo haslo nie wystarcza do logowania", "Przyspiesza komputer", "Zastepuje aktualizacje systemu"],
			"correct": 0,
			"feedback": "Tak. Nawet przechwycone haslo nie daje pelnego dostepu bez drugiego skladnika."
		},
		{
			"question": "Co jest typowym celem spyware?",
			"answers": ["Ciche zbieranie danych", "Naprawa uszkodzonych plikow", "Zwiekszenie rozdzielczosci ekranu"],
			"correct": 0,
			"feedback": "Tak. Spyware dziala dyskretnie i probuje przechwytywac prywatne informacje."
		}
	],
	"phishing": [
		{
			"question": "Co zrobic z pilnym linkiem do logowania z SMS-a?",
			"answers": ["Wejsc na strone recznie lub przez zapisany skrot", "Kliknac, jesli logo wyglada dobrze", "Podac haslo i szybko zamknac strone"],
			"correct": 0,
			"feedback": "Tak. Reczne wejscie na znany adres omija falszywy link."
		},
		{
			"question": "Co najpierw sprawdzic w podejrzanej wiadomosci?",
			"answers": ["Nadawce, domene i sens prosby", "Czy ma duzo wykrzyknikow", "Czy przyszla rano"],
			"correct": 0,
			"feedback": "Tak. Adres, domena i kontekst czesto zdradzaja podszycie."
		}
	],
	"sql": [
		{
			"question": "Najlepsza podstawowa ochrona przed SQL Injection to:",
			"answers": ["Zapytania parametryzowane", "Dluzsze haslo uzytkownika", "Wiekszy serwer bazy danych"],
			"correct": 0,
			"feedback": "Tak. Parametry oddzielaja dane od kodu zapytania."
		},
		{
			"question": "Co jest ryzykowne przy budowaniu zapytan SQL?",
			"answers": ["Sklejanie tekstu zapytania z danymi uzytkownika", "Uzywanie parametrow", "Ograniczanie uprawnien konta bazy"],
			"correct": 0,
			"feedback": "Tak. Sklejanie tekstu pozwala danym zmienic znaczenie zapytania."
		}
	],
	"hijacking": [
		{
			"question": "Co najlepiej ogranicza skutki session hijackingu?",
			"answers": ["MFA, krotkie sesje i wykrywanie anomalii", "Udostepnienie tokenu w URL", "Wylaczenie powiadomien o logowaniu"],
			"correct": 0,
			"feedback": "Tak. Nawet skradziona sesja ma wtedy mniejsza wartosc i latwiej wykryc naduzycie."
		},
		{
			"question": "Co moze zostac przejete w session hijackingu?",
			"answers": ["Token lub cookie sesyjne", "Tapeta pulpitu", "Nazwa drukarki"],
			"correct": 0,
			"feedback": "Tak. Przejecie tokenu lub cookie moze pozwolic podszyc sie pod legalna sesje."
		}
	],
	"smurf_attack": [
		{
			"question": "Co najlepiej ogranicza Smurf Attack?",
			"answers": ["Blokada spoofingu i directed broadcast", "Wylaczenie MFA", "Dluzsza nazwa uzytkownika"],
			"correct": 0,
			"feedback": "Tak. Bez spoofingu i wzmacniaczy broadcast atak traci najwazniejszy mechanizm."
		},
		{
			"question": "Jaki mechanizm wzmacnia Smurf Attack?",
			"answers": ["Odpowiedzi wielu hostow na podrobiony adres ofiary", "Szyfrowanie kopii zapasowych", "Losowa zmiana hasla lokalnego"],
			"correct": 0,
			"feedback": "Tak. Atak wykorzystuje cudze odpowiedzi jako wzmacniacz ruchu."
		}
	],
	"firewall_overload": [
		{
			"question": "Co najlepiej ogranicza przeciazenie firewalla?",
			"answers": ["Rate limiting i filtrowanie ruchu na brzegu", "Otwarcie wszystkich portow", "Wylaczenie monitoringu"],
			"correct": 0,
			"feedback": "Tak. Im wczesniej odfiltrujesz zly ruch, tym mniej obciaza on system obrony."
		},
		{
			"question": "Co pomaga wykryc poczatek przeciazenia?",
			"answers": ["Monitoring anomalii ruchu", "Brak logow", "Jedna regula allow all"],
			"correct": 0,
			"feedback": "Tak. Monitoring pozwala zareagowac, zanim flood zablokuje usluge."
		}
	],
	"apt_boss": [
		{
			"question": "Co najlepiej pasuje do obrony przed APT?",
			"answers": ["Monitoring, MFA i segmentacja", "Jedno haslo administratora dla wszystkich", "Brak logow, zeby oszczedzic miejsce"],
			"correct": 0,
			"feedback": "Tak. APT wymaga obrony warstwowej, nie jednego zabezpieczenia."
		},
		{
			"question": "Co wyroznia kampanie APT?",
			"answers": ["Dlugotrwale i ukryte utrzymywanie dostepu", "Jednorazowy blad literowy", "Brak rozpoznania celu"],
			"correct": 0,
			"feedback": "Tak. APT probuje pozostac w srodowisku i stopniowo zdobywac dane."
		}
	],
	"intro": [
		{
			"question": "Co jest celem tych scenek?",
			"answers": ["Nauczyc decyzji obronnych", "Zatrzymac gre bez powodu", "Zastapic walke tekstem"],
			"correct": 0,
			"feedback": "Tak. Kazda scenka ma zostawic jedna konkretna decyzje obronna."
		},
		{
			"question": "Jak najlepiej traktowac lekcje przed fala?",
			"answers": ["Jako szybka wskazowke do realnej decyzji", "Jako losowy przerywnik bez znaczenia", "Jako zamiennik sterowania postacia"],
			"correct": 0,
			"feedback": "Tak. Lekcja ma laczyc zagrozenie z praktyczna reakcja."
		}
	],
	"unknown": [
		{
			"question": "Co oznacza defense-in-depth?",
			"answers": ["Kilka warstw zabezpieczen naraz", "Jedno bardzo mocne haslo", "Wylaczenie wszystkich alertow"],
			"correct": 0,
			"feedback": "Tak. Warstwy zabezpieczen zmniejszaja skutki bledu jednej kontroli."
		},
		{
			"question": "Co robic przy nieznanym zagrozeniu?",
			"answers": ["Stosowac podstawy: MFA, aktualizacje, monitoring i backup", "Ignorowac anomalie", "Dac wszystkim uprawnienia administratora"],
			"correct": 0,
			"feedback": "Tak. Przy braku pelnego obrazu najwazniejsze sa solidne podstawy obrony."
		}
	]
}

var current_enemy_type: String = ""
var current_wave_number: int = 0
var is_paused: bool = false

var _ui_font: Font
var _current_lesson: Dictionary = {}
var _current_quiz: Dictionary = {}
var _displayed_answers: Array = []
var _displayed_correct_index: int = 0
var _current_step: int = 0
var _quiz_answered: bool = false
var _previous_hud_visible: bool = true
var _previous_flow_visible: bool = true
var _recent_quiz_indices: Dictionary = {}

var _bg: ColorRect
var _panel: PanelContainer
var _title_label: Label
var _step_label: Label
var _subtitle_label: Label
var _art_panel: PanelContainer
var _art_texture: TextureRect
var _art_fallback: Label
var _lesson_heading: Label
var _lesson_body: Label
var _bullets_box: VBoxContainer
var _quiz_panel: PanelContainer
var _question_label: Label
var _answers_box: VBoxContainer
var _feedback_label: Label
var _progress_label: Label
var _continue_button: Button

func _ready() -> void:
	_ui_font = preload("res://Assets/fonts/VT323-Regular.ttf")
	_build_ui()
	visible = false

func _build_ui() -> void:
	_queue_free_children(self)

	mouse_filter = Control.MOUSE_FILTER_STOP

	_bg = ColorRect.new()
	_bg.name = "DimBG"
	_bg.color = Color(0.0, 0.01, 0.018, 0.78)
	_bg.mouse_filter = Control.MOUSE_FILTER_STOP
	_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_bg)

	var center := CenterContainer.new()
	center.name = "MainContainer"
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	_panel = PanelContainer.new()
	_panel.name = "LessonPanel"
	_panel.custom_minimum_size = Vector2(1100, 650)
	_panel.add_theme_stylebox_override("panel", _make_panel_style())
	center.add_child(_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 24)
	_panel.add_child(margin)

	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 14)
	margin.add_child(outer)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 16)
	outer.add_child(header)

	var header_text := VBoxContainer.new()
	header_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_text.add_theme_constant_override("separation", 2)
	header.add_child(header_text)

	_title_label = _make_label("", Color(0.35, 0.94, 1.0), 42, HORIZONTAL_ALIGNMENT_LEFT)
	_title_label.custom_minimum_size = Vector2(0, 48)
	header_text.add_child(_title_label)

	_subtitle_label = _make_label("", Color(0.76, 0.86, 0.92), 23, HORIZONTAL_ALIGNMENT_LEFT)
	header_text.add_child(_subtitle_label)

	_step_label = _make_label("", Color(0.9, 0.98, 1.0), 24, HORIZONTAL_ALIGNMENT_CENTER)
	_step_label.custom_minimum_size = Vector2(150, 48)
	_step_label.add_theme_stylebox_override("normal", _make_box_style(Color(0.018, 0.035, 0.052, 0.96), Color(0.22, 0.78, 0.98, 0.72), 2))
	header.add_child(_step_label)

	var top_line := ColorRect.new()
	top_line.custom_minimum_size = Vector2(0, 2)
	top_line.color = Color(0.18, 0.78, 0.98, 0.72)
	outer.add_child(top_line)

	var content := HBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 20)
	outer.add_child(content)

	_art_panel = PanelContainer.new()
	_art_panel.custom_minimum_size = Vector2(390, 390)
	_art_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_art_panel.add_theme_stylebox_override("panel", _make_box_style(Color(0.01, 0.02, 0.032, 0.96), Color(0.12, 0.56, 0.76, 0.82), 2))
	content.add_child(_art_panel)

	var art_margin := MarginContainer.new()
	art_margin.add_theme_constant_override("margin_left", 14)
	art_margin.add_theme_constant_override("margin_top", 14)
	art_margin.add_theme_constant_override("margin_right", 14)
	art_margin.add_theme_constant_override("margin_bottom", 14)
	_art_panel.add_child(art_margin)

	var art_stack := VBoxContainer.new()
	art_stack.add_theme_constant_override("separation", 10)
	art_margin.add_child(art_stack)

	_art_texture = TextureRect.new()
	_art_texture.custom_minimum_size = Vector2(360, 285)
	_art_texture.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_art_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art_stack.add_child(_art_texture)

	_art_fallback = _make_label("", Color(0.35, 0.94, 1.0), 30, HORIZONTAL_ALIGNMENT_CENTER)
	_art_fallback.custom_minimum_size = Vector2(0, 72)
	_art_fallback.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_art_fallback.add_theme_stylebox_override("normal", _make_box_style(Color(0.018, 0.035, 0.052, 0.96), Color(0.22, 0.78, 0.98, 0.72), 2))
	art_stack.add_child(_art_fallback)

	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 12)
	content.add_child(right)

	_lesson_heading = _make_label("", Color(0.92, 0.98, 1.0), 34, HORIZONTAL_ALIGNMENT_LEFT)
	_lesson_heading.custom_minimum_size = Vector2(0, 44)
	right.add_child(_lesson_heading)

	_lesson_body = _make_label("", Color(0.78, 0.86, 0.92), 25, HORIZONTAL_ALIGNMENT_LEFT)
	_lesson_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lesson_body.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	right.add_child(_lesson_body)

	_bullets_box = VBoxContainer.new()
	_bullets_box.add_theme_constant_override("separation", 6)
	right.add_child(_bullets_box)

	_quiz_panel = PanelContainer.new()
	_quiz_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_quiz_panel.add_theme_stylebox_override("panel", _make_box_style(Color(0.018, 0.032, 0.05, 0.94), Color(0.18, 0.78, 0.98, 0.72), 2))
	right.add_child(_quiz_panel)

	var quiz_margin := MarginContainer.new()
	quiz_margin.add_theme_constant_override("margin_left", 16)
	quiz_margin.add_theme_constant_override("margin_top", 14)
	quiz_margin.add_theme_constant_override("margin_right", 16)
	quiz_margin.add_theme_constant_override("margin_bottom", 14)
	_quiz_panel.add_child(quiz_margin)

	var quiz_box := VBoxContainer.new()
	quiz_box.add_theme_constant_override("separation", 9)
	quiz_margin.add_child(quiz_box)

	_question_label = _make_label("", Color(0.35, 0.94, 1.0), 25, HORIZONTAL_ALIGNMENT_LEFT)
	_question_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	quiz_box.add_child(_question_label)

	_answers_box = VBoxContainer.new()
	_answers_box.add_theme_constant_override("separation", 7)
	quiz_box.add_child(_answers_box)

	_feedback_label = _make_label("", Color(0.78, 0.86, 0.92), 22, HORIZONTAL_ALIGNMENT_LEFT)
	_feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	quiz_box.add_child(_feedback_label)

	var bottom_line := ColorRect.new()
	bottom_line.custom_minimum_size = Vector2(0, 2)
	bottom_line.color = Color(0.18, 0.78, 0.98, 0.55)
	outer.add_child(bottom_line)

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 14)
	outer.add_child(footer)

	_progress_label = _make_label("", Color(0.7, 0.86, 0.94), 22, HORIZONTAL_ALIGNMENT_LEFT)
	_progress_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(_progress_label)

	_continue_button = Button.new()
	_continue_button.custom_minimum_size = Vector2(270, 58)
	_continue_button.add_theme_font_override("font", _ui_font)
	_continue_button.add_theme_font_size_override("font_size", 29)
	_continue_button.add_theme_color_override("font_color", Color(0.92, 0.98, 1.0))
	_continue_button.add_theme_stylebox_override("normal", _make_button_style(Color(0.05, 0.08, 0.11, 0.96), Color(0.22, 0.78, 0.98, 0.85)))
	_continue_button.add_theme_stylebox_override("hover", _make_button_style(Color(0.08, 0.13, 0.16, 1.0), Color(0.5, 0.94, 1.0, 1.0)))
	_continue_button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.16, 0.45, 0.55, 1.0), Color(0.5, 0.94, 1.0, 1.0)))
	_continue_button.pressed.connect(_on_continue_pressed)
	footer.add_child(_continue_button)

func show_education(enemy_type: String) -> void:
	_show_lesson(enemy_type, 0)

func show_intro() -> void:
	_show_lesson("intro", 0)

func show_wave_info(wave_number: int) -> void:
	show_pre_wave_education(wave_number)

func show_pre_wave_education(wave_number: int) -> void:
	_show_lesson(_resolve_enemy_type_for_wave(wave_number), wave_number)

func _resolve_enemy_type_for_wave(wave_number: int) -> String:
	var wave_manager := get_tree().get_first_node_in_group("WaveManager")
	if wave_manager and wave_manager.has_method("get_education_type_for_wave"):
		var boss_lesson := str(wave_manager.get_education_type_for_wave(wave_number))
		if boss_lesson != "":
			return boss_lesson
	return _get_enemy_type_for_wave(wave_number)

func _show_lesson(enemy_type: String, wave_number: int) -> void:
	current_enemy_type = enemy_type
	current_wave_number = wave_number
	_current_lesson = lesson_content.get(enemy_type, lesson_content["unknown"])
	_current_quiz = _pick_quiz_for_lesson(enemy_type)
	_displayed_answers.clear()
	_displayed_correct_index = 0
	_current_step = 0
	_quiz_answered = false

	_set_combat_ui_visible(false)
	is_paused = true
	get_tree().paused = true
	visible = true
	_show_current_step()

func _show_current_step() -> void:
	if _current_lesson.is_empty():
		return

	var accent: Color = _current_lesson.get("accent", Color(0.35, 0.94, 1.0))
	var steps: Array = _current_lesson.get("steps", [])
	if steps.is_empty():
		return
	_current_step = clampi(_current_step, 0, steps.size() - 1)
	var step: Dictionary = steps[_current_step]

	var wave_prefix := "FALA %d - " % current_wave_number if current_wave_number > 0 else ""
	_title_label.text = wave_prefix + str(_current_lesson.get("title", "LEKCJA"))
	_subtitle_label.text = str(_current_lesson.get("subtitle", ""))
	_step_label.text = "%d / %d" % [_current_step + 1, steps.size()]
	_lesson_heading.text = "%s: %s" % [LESSON_STEPS[min(_current_step, LESSON_STEPS.size() - 1)], str(step.get("title", ""))]
	_lesson_body.text = str(step.get("body", ""))
	_progress_label.text = "Lekcja przed falą: zapamiętaj jedną decyzję obronną i zastosuj ją w walce."

	_refresh_art(accent)
	_refresh_bullets(step.get("bullets", []), accent)
	_refresh_quiz(accent)

	_continue_button.disabled = false
	if _current_step < steps.size() - 1:
		_continue_button.text = "DALEJ"
	elif not _current_quiz.is_empty() and not _quiz_answered:
		_continue_button.text = "ODPOWIEDZ NA PYTANIE"
		_continue_button.disabled = true
	else:
		_continue_button.text = "START FALI"

func _refresh_art(accent: Color) -> void:
	var image_path := str(_current_lesson.get("image", ""))
	var texture: Texture2D = null
	if image_path != "" and ResourceLoader.exists(image_path):
		texture = load(image_path) as Texture2D

	_art_texture.texture = texture
	_art_texture.visible = texture != null
	_art_fallback.visible = texture == null
	_art_fallback.text = "SCENA\n" + str(_current_lesson.get("title", "EDU")).to_upper()
	_art_fallback.add_theme_color_override("font_color", accent)
	_art_fallback.add_theme_stylebox_override("normal", _make_box_style(Color(0.018, 0.035, 0.052, 0.96), accent, 2))
	_art_panel.add_theme_stylebox_override("panel", _make_box_style(Color(0.01, 0.02, 0.032, 0.96), Color(accent.r, accent.g, accent.b, 0.7), 2))

func _refresh_bullets(bullets: Array, accent: Color) -> void:
	_queue_free_children(_bullets_box)

	for bullet in bullets:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 9)
		_bullets_box.add_child(row)

		var marker := ColorRect.new()
		marker.custom_minimum_size = Vector2(8, 28)
		marker.color = accent
		row.add_child(marker)

		var label := _make_label(str(bullet), Color(0.82, 0.9, 0.95), 23, HORIZONTAL_ALIGNMENT_LEFT)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(label)

func _refresh_quiz(accent: Color) -> void:
	_queue_free_children(_answers_box)
	_feedback_label.text = ""
	_feedback_label.add_theme_color_override("font_color", Color(0.78, 0.86, 0.92))

	var quiz: Dictionary = _current_quiz
	var show_quiz := _current_step >= 2 and not quiz.is_empty()
	_quiz_panel.visible = show_quiz
	if not show_quiz:
		return

	_question_label.text = "DECYZJA: " + str(quiz.get("question", ""))
	_prepare_displayed_answers(quiz)
	for i in range(_displayed_answers.size()):
		var answer := Button.new()
		answer.text = str(_displayed_answers[i])
		answer.custom_minimum_size = Vector2(0, 42)
		answer.focus_mode = Control.FOCUS_ALL
		answer.add_theme_font_override("font", _ui_font)
		answer.add_theme_font_size_override("font_size", 23)
		answer.add_theme_color_override("font_color", Color(0.9, 0.98, 1.0))
		answer.add_theme_stylebox_override("normal", _make_button_style(Color(0.035, 0.055, 0.075, 0.96), Color(accent.r, accent.g, accent.b, 0.55)))
		answer.add_theme_stylebox_override("hover", _make_button_style(Color(0.06, 0.09, 0.12, 1.0), Color(accent.r, accent.g, accent.b, 0.95)))
		answer.add_theme_stylebox_override("pressed", _make_button_style(Color(0.10, 0.18, 0.22, 1.0), Color(accent.r, accent.g, accent.b, 1.0)))
		answer.pressed.connect(_on_answer_pressed.bind(i))
		_answers_box.add_child(answer)

func _on_answer_pressed(answer_index: int) -> void:
	var quiz: Dictionary = _current_quiz
	var correct := _displayed_correct_index
	_quiz_answered = true

	for i in range(_answers_box.get_child_count()):
		var button := _answers_box.get_child(i) as Button
		if button:
			button.disabled = true

	if answer_index == correct:
		_feedback_label.add_theme_color_override("font_color", Color(0.42, 1.0, 0.62))
		_feedback_label.text = str(quiz.get("feedback", "Dobra decyzja."))
	else:
		_feedback_label.add_theme_color_override("font_color", Color(1.0, 0.55, 0.45))
		var correct_text := str(_displayed_answers[correct]) if correct >= 0 and correct < _displayed_answers.size() else "poprawna odpowiedz"
		_feedback_label.text = "Lepsza decyzja: %s. %s" % [correct_text, str(quiz.get("feedback", ""))]

	_continue_button.disabled = false
	_continue_button.text = "START FALI"

func _on_continue_pressed() -> void:
	var steps: Array = _current_lesson.get("steps", [])
	if _current_step < steps.size() - 1:
		_current_step += 1
		_quiz_answered = false
		_show_current_step()
		return

	visible = false
	is_paused = false
	_restore_combat_ui()
	get_tree().paused = false
	education_completed.emit()

func _pick_quiz_for_lesson(enemy_type: String) -> Dictionary:
	var key := enemy_type if quiz_variants.has(enemy_type) else "unknown"
	var variants: Array = quiz_variants.get(key, [])
	if variants.is_empty():
		var fallback: Dictionary = _current_lesson.get("quiz", {})
		return fallback.duplicate(true)

	var recent: Array = _recent_quiz_indices.get(key, [])
	if recent.size() >= variants.size():
		recent.clear()

	var available: Array[int] = []
	for i in range(variants.size()):
		if not recent.has(i):
			available.append(i)

	var picked_index := int(available.pick_random()) if not available.is_empty() else randi() % variants.size()
	recent.append(picked_index)
	_recent_quiz_indices[key] = recent
	return (variants[picked_index] as Dictionary).duplicate(true)

func _prepare_displayed_answers(quiz: Dictionary) -> void:
	_displayed_answers.clear()
	_displayed_correct_index = 0

	var answers: Array = quiz.get("answers", [])
	var correct := int(quiz.get("correct", 0))
	if answers.is_empty():
		return

	var order: Array[int] = []
	for i in range(answers.size()):
		order.append(i)
	order.shuffle()

	for display_index in range(order.size()):
		var source_index := int(order[display_index])
		_displayed_answers.append(answers[source_index])
		if source_index == correct:
			_displayed_correct_index = display_index

func _queue_free_children(parent: Node) -> void:
	if not is_instance_valid(parent):
		return
	for child in parent.get_children():
		if is_instance_valid(child):
			parent.remove_child(child)
			child.queue_free()

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

func _get_enemy_type_for_wave(wave: int) -> String:
	if wave == 1 or wave == 2:
		return "worm"
	if wave == 3 or wave == 4:
		return "trojan"
	if wave % 5 == 0:
		return "apt_boss"
	if wave == 6 or wave == 7:
		return "ransomware"
	if wave == 8 or wave == 9:
		return "spyware"
	if wave == 11 or wave == 12:
		return "phishing"
	if wave >= 13:
		return "sql"
	return "unknown"

func _get_pre_wave_content(wave: int) -> Dictionary:
	var enemy_type := _get_enemy_type_for_wave(wave)
	return lesson_content.get(enemy_type, lesson_content["unknown"])

func _make_label(text: String, color: Color, font_size: int, alignment: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = alignment
	label.add_theme_font_override("font", _ui_font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.82))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	return label

func _make_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.01, 0.02, 0.032, 0.98)
	style.border_color = Color(0.18, 0.78, 0.98, 0.95)
	style.border_width_left = 4
	style.border_width_top = 4
	style.border_width_right = 4
	style.border_width_bottom = 4
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_right = 5
	style.corner_radius_bottom_left = 5
	style.shadow_color = Color(0, 0, 0, 0.68)
	style.shadow_size = 22
	return style

func _make_box_style(bg: Color, border: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

func _make_button_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := _make_box_style(bg, border, 2)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style
