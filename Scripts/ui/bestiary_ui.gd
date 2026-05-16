extends CanvasLayer
## Bestiary UI - Educational database of cyber threats

@onready var enemy_list: ItemList = %EnemyList
@onready var enemy_sprite: TextureRect = %EnemySprite
@onready var enemy_name: Label = %EnemyName
@onready var lore_label: RichTextLabel = %LoreLabel
@onready var definition_label: RichTextLabel = %DefinitionLabel

var enemies_data = [
	{
		"name": "Robak Sieciowy",
		"lore": "[i]Z głębi splątanych kabli podziemnych dzielnic wyłania się segmentowany stwór — żywa manifestacja złośliwego kodu. Jego ciało, utkane z migających pakietów danych, faluje w rytmie przeskanowanych portów. Każdy segment to autonomiczna jednostka zdolna do samodzielnej replikacji — odetnij jeden, a dwa nowe wypełzną z cienia. W slumsach Neo-Warszawy mówi się, że Robak nigdy nie śpi — tylko czeka, aż jakiś niezałatany port otworzy drzwi do następnego systemu.[/i]\n\nNa arenie pojawia się w rojach, które w kilka sekund potrafią zalać cały obszar — priorytet eliminacji absolutny.",
		"definition": "[color=#4ecdc4][b]OPIS ZAGROŻENIA[/b][/color]\nSamoreplikujący się program złośliwy, który rozprzestrzenia się autonomicznie przez sieć, wykorzystując luki w protokołach komunikacyjnych (SMB, RDP, HTTP). W odróżnieniu od wirusa nie wymaga pliku-nosiciela ani interakcji użytkownika — wystarczy podatny system w zasięgu.\n\n[color=#f1c40f][b]MERYTORYKA SOC[/b][/color]\n• [b]Wektor ataku:[/b] Niezałatane usługi sieciowe, otwarte porty (445, 3389).\n• [b]Mechanizm replikacji:[/b] Skanowanie podsieci → exploit → wgranie payloadu → restart cyklu.\n• [b]Wykrywanie:[/b] Anomalny ruch sieciowy (boczne skanowanie), gwałtowny wzrost SYN.\n• [b]Obrona:[/b] Segmentacja sieci, regularny patch management, IPS z sygnaturami robaków.\n\n[color=#e74c3c][b]DANE WYWIADOWCZE (GRA)[/b][/color]\nSzybki, pojawia się w grupach 3-6 osobników. Niszcz priorytetowo — po 30 sekundach każdy żywy robak tworzy kopię.\n\n[color=#95a5a6][b]HISTORIA:[/b][/color] Morris Worm (1988) — pierwszy robak, który sparaliżował 10% Internetu. Stuxnet (2010) — robak, który fizycznie zniszczył wirówki w Iranie.",
		"icon": preload("res://Assets/Characters/worm.png")
	},
	{
		"name": "Koń Trojański",
		"lore": "[i]W neonowym półmroku bazaru danych wygląda niegroźnie — zwykły plik, dar od nieznajomego. Ale pod błyszczącą powłoką legalnej aplikacji kryje się drapieżnik o wielu twarzach. Gdy już wpuścisz go za firewalla, odsłania swoje prawdziwe oblicze: otwiera backdoory w twojej obronie i wpuszcza kolejne zagrożenia niczym cichy zdrajca w szeregach korporacyjnego SOC-u. Weterani cyber-aren szepczą: nie ufaj niczemu, co świeci zbyt jasno.[/i]\n\nMistrz kamuflażu — przez pierwsze sekundy na arenie wygląda jak neutralny pakiet danych. Nie daj się zwieść.",
		"definition": "[color=#4ecdc4][b]OPIS ZAGROŻENIA[/b][/color]\nOprogramowanie podszywające się pod legalne aplikacje (łamacze haseł, keygeny, fałszywe aktualizacje). W przeciwieństwie do robaka nie replikuje się — polega na socjotechnice, by użytkownik sam je uruchomił. Stanowi pierwszą fazę wieloetapowych kampanii.\n\n[color=#f1c40f][b]MERYTORYKA SOC[/b][/color]\n• [b]Typy:[/b] RAT (zdalny dostęp), Banker (kradzież finansowa), Dropper (instaluje kolejne malware), Downloader (pobiera payload).\n• [b]Infrastruktura C2:[/b] Komunikacja z serwerem dowodzenia przez DNS-over-HTTPS (trudna do wykrycia).\n• [b]Obrona:[/b] Application Whitelisting, behavioralna analiza endpoint (EDR), piaskownice.\n\n[color=#e74c3c][b]DANE WYWIADOWCZE (GRA)[/b][/color]\nWytrzymały przeciwnik. Po 15 sekundach na arenie przyzywa posiłki (otwiera backdoor). Eliminuj, zanim to zrobi.\n\n[color=#95a5a6][b]HISTORIA:[/b][/color] Emotet (2014-2021) — król trojanów bankowych, rozbity przez Europol. Zeus — wykradł miliony dolarów z kont bankowych.",
		"icon": preload("res://Assets/Characters/Trojan.png")
	},
	{
		"name": "Szyfrator",
		"lore": "[i]Mroczny kolos wyłaniający się z mgły szyfrogramów — każdy jego krok to stukot wirujących dysków, na których dane zamieniają się w bezsensowną papkę AES-256. Nie zabija od razu. Najpierw paraliżuje system, potem wyświetla okrutne żądanie okupu migające czerwienią na każdym monitorze. Mówią, że w serwerowniach opuszczonych korpo-siedzib wciąż słychać echo jego szyfrującego algorytmu — ciche szzzzzzzz przemiału plików, które już nigdy nie wrócą do właścicieli.[/i]\n\nPowolny, ale niepowstrzymany — gdy dopadnie celu, tylko backup może cię uratować.",
		"definition": "[color=#4ecdc4][b]OPIS ZAGROŻENIA[/b][/color]\nZłośliwe oprogramowanie szyfrujące pliki użytkownika i żądające okupu (najczęściej w kryptowalutach) za klucz deszyfrujący. Współczesne warianty stosują podwójne wymuszenie: szyfrowanie + groźba wycieku skradzionych danych.\n\n[color=#f1c40f][b]MERYTORYKA SOC[/b][/color]\n• [b]Algorytmy:[/b] Hybrydowe — RSA-2048 do klucza sesji, AES-256 do szyfrowania plików.\n• [b]Ewolucja:[/b] Ransomware-as-a-Service (RaaS) — każdy może kupić gotowy zestaw. Triple Extortion: szyfrowanie + wyciek + DDoS.\n• [b]Obrona:[/b] Zasada 3-2-1 backupu (3 kopie, 2 media, 1 offline), MFA na wszystko, segmentacja.\n\n[color=#e74c3c][b]DANE WYWIADOWCZE (GRA)[/b][/color]\nWolny, ale potężny — jeden cios zabiera 30% HP. Priorytet na dystans — nie dopuszczaj do siebie.\n\n[color=#95a5a6][b]HISTORIA:[/b][/color] WannaCry (2017) — sparaliżował NHS w Wielkiej Brytanii. LockBit — najaktywniejszy gang RaaS, rozbity w operacji Cronos (2024).",
		"icon": preload("res://Assets/Characters/Ransomware.png")
	},
	{
		"name": "Zastrzyk SQL",
		"lore": "[i]Widmowa igła kodu sunąca przez warstwy aplikacji webowej — bezszelestna, precyzyjna, śmiercionośna. Nie potrzebuje brutalnej siły; wystarczy jeden nieprawidłowo zescape'owany apostrof w formularzu logowania, by wstrzyknąć się w głąb bazy danych. Na cyber-arenie pojawia się jako migocząca struktura zapytań, która przepala firewalle aplikacyjne niczym laser tnie blachę. Stare porzekadło białych hakerów głosi: 'Sanityzuj dane wejściowe, bo Zastrzyk SQL wypije twoją bazę do sucha'.[/i]\n\nAtakuje z dystansu — jego pociski omijają defensywne bariery fizyczne, trafiając prosto w logikę aplikacji.",
		"definition": "[color=#4ecdc4][b]OPIS ZAGROŻENIA[/b][/color]\nTechnika ataku polegająca na wstrzyknięciu złośliwego kodu SQL w pola formularzy, parametry URL lub nagłówki HTTP. Umożliwia odczyt, modyfikację lub usunięcie całej zawartości bazy danych.\n\n[color=#f1c40f][b]MERYTORYKA SOC[/b][/color]\n• [b]Przyczyny:[/b] Brak walidacji/parametryzacji zapytań, konkatenacja stringów w SQL.\n• [b]Typy ataku:[/b] Union-based, Blind (Boolean/Time-based), Error-based, Out-of-Band.\n• [b]Skutki:[/b] Wyciek haseł (często w plaintext lub MD5), kradzież PII, ransomware przez SQL.\n• [b]Obrona:[/b] Prepared Statements z bind parametrami, ORM, WAF, minimalizacja uprawnień DB.\n\n[color=#e74c3c][b]DANE WYWIADOWCZE (GRA)[/b][/color]\nAtakuje z dystansu. Jego pociski ignorują 50% pancerza. Unikaj długiego pozostawania w jego linii ostrzału.\n\n[color=#9b59b6][b]WSKAZÓWKA:[/b][/color] Nigdy nie ufaj danym wejściowym od użytkownika — sanityzuj wszystko, parametryzuj zawsze.",
		"icon": preload("res://Assets/Characters/sql.png")
	},
	{
		"name": "Wyłudzacz",
		"lore": "[i]Sprytny oszust z Neon District, który nie włamuje się — on po prostu prosi o klucze i dostaje je na tacy. Jego ciało to kolaż sfałszowanych ekranów logowania, a głos to idealna kopia prezesa twojej korporacji. Porusza się zygzakiem między serwerami pocztowymi, rozrzucając linki-pułapki. Na arenie pojawia się znikąd — jak fałszywy alert bezpieczeństwa, który zmusza cię do kliknięcia. Ofiary mówią: 'wyglądał dokładnie jak nasz bank'.[/i]\n\nNajszybszy z przeciwników. Jego ataki nie ranią ciała — uderzają w zaufanie, kradnąc twoją tożsamość bit po bicie.",
		"definition": "[color=#4ecdc4][b]OPIS ZAGROŻENIA[/b][/color]\nAtak socjotechniczny polegający na podszywaniu się pod zaufane podmioty (banki, urzędy, dostawców usług) w celu wyłudzenia danych logowania, numerów kart lub innych wrażliwych informacji od ofiary.\n\n[color=#f1c40f][b]MERYTORYKA SOC[/b][/color]\n• [b]Warianty:[/b] Spear Phishing (celowany), Whaling (na zarząd), Smishing (SMS), Vishing (telefon), Clone Phishing (kopia prawdziwego maila).\n• [b]Oznaki:[/b] Poczucie pilności, błędy gramatyczne, niezgodność adresu nadawcy, podejrzane załączniki.\n• [b]Obrona:[/b] DMARC/DKIM/SPF, FIDO2/U2F (hardware key), regularny training użytkowników.\n\n[color=#e74c3c][b]DANE WYWIADOWCZE (GRA)[/b][/color]\nNiezwykle szybki i nieprzewidywalny. Zadaje obrażenia 'socjotechniczne' — kumulują się przy każdym trafieniu.\n\n[color=#9b59b6][b]PRZYKŁAD:[/b][/color] SMS o niedopłacie za przesyłkę, fałszywy mail z HR o 'aktualizacji danych pracowniczych', telefon od 'Microsoft Support'.",
		"icon": preload("res://Assets/Characters/phishing.png")
	},
	{
		"name": "Szpieg",
		"lore": "[i]Pajęczak z głębokiego darknetu — nigdy nie atakuje pierwszy, tylko czai się w cieniu procesów systemowych i notuje każdy twój ruch. Jego sieć sensoryczna oplata pulpit ofiary, rejestrując naciśnięcia klawiszy, ruchy myszą, a nawet zrzuty ekranu. W slumsach Neo-Warszawy mówią: jeśli twoja kamera internetowa mignęła bez powodu, Szpieg już cię znalazł. Sprzeda twój profil behawioralny najwyżej licytującemu, zanim zdążysz powiedzieć 'GDPR'.[/i]\n\nNiewidoczny na radarze, dopóki nie podejdzie blisko. Używaj sensorów i skanerów, by go ujawnić.",
		"definition": "[color=#4ecdc4][b]OPIS ZAGROŻENIA[/b][/color]\nOprogramowanie szpiegujące, które działa w ukryciu, zbierając wrażliwe dane użytkownika: historię przeglądania, zapisane hasła, dane karty kredytowej, lokalizację GPS, nagrania z mikrofonu i kamery.\n\n[color=#f1c40f][b]MERYTORYKA SOC[/b][/color]\n• [b]Podtypy:[/b] Keylogger (rejestruje klawisze), Screen scraper (zrzuty ekranu), Tracking cookie (śledzenie behawioralne), Stalkerware (śledzenie ofiary przez partnera).\n• [b]Metody ukrywania:[/b] Rootkit + Spyware = prawie niewykrywalne. Wstrzykiwanie w legalne procesy (DLL injection).\n• [b]Obrona:[/b] Anty-spyware, blokada skryptów w przeglądarce, fizyczna zasłona kamery, czujność na anomalne zużycie baterii/danych.\n\n[color=#e74c3c][b]DANE WYWIADOWCZE (GRA)[/b][/color]\nNiewidoczny przez pierwsze 10 sekund na arenie. Używaj umiejętności skanowania, by go ujawnić i zniszczyć.\n\n[color=#95a5a6][b]HISTORIA:[/b][/color] Pegasus (NSO Group) — spyware zdolny do infekcji zero-klik przez iMessage. Używany do inwigilacji dziennikarzy i opozycjonistów na całym świecie.",
		"icon": preload("res://Assets/Characters/321.png")
	},
	{
		"name": "Zaawansowane Trwałe Zagrożenie",
		"lore": "[i]Kolos cybernetycznej wojny — żywa manifestacja operacji APT sponsorowanej przez wrogie supermocarstwo. Nie jest pojedynczym wirusem, lecz całą kampanią: od rekonesansu, przez spear-phishing, po wielomiesięczną infiltrację i powolną eksfiltrację terabajtów danych. Na arenie materializuje się jako tytaniczny byt otoczony rojem pomniejszych zagrożeń, którymi dowodzi z precyzją wojskowego sztabu. Mówi się, że gdy widzisz APT na horyzoncie, twoja sieć jest już skompromitowana od tygodni — teraz tylko walczysz o przetrwanie.[/i]\n\nBOSS areny. Pojawia się co 5 fal i posiada wiele faz ataku. Wymaga pełnej koordynacji defensywy.",
		"definition": "[color=#4ecdc4][b]OPIS ZAGROŻENIA[/b][/color]\nAdvanced Persistent Threat — długotrwała, wieloetapowa kampania cybernetyczna prowadzona przez zaawansowane grupy (często sponsorowane przez państwa). Celem nie jest szybki zysk, lecz strategiczne cele: szpiegostwo przemysłowe, kradzież własności intelektualnej, sabotaż infrastruktury krytycznej.\n\n[color=#f1c40f][b]MERYTORYKA SOC[/b][/color]\n• [b]Fazy ataku (Cyber Kill Chain):[/b] Rekonesans → Uzbrojenie → Dostarczenie → Eksploitacja → Instalacja → C2 → Działanie na celu.\n• [b]Cechy charakterystyczne:[/b] Użycie exploitów Zero-Day, minimalny footprint (living-off-the-land), customowe narzędzia, cierpliwość (miesiące, lata).\n• [b]Obrona:[/b] EDR/XDR + SIEM z korelacją, Zero Trust Architecture, threat hunting, deception technology (honeypoty).\n\n[color=#e74c3c][b]DANE WYWIADOWCZE (GRA)[/b][/color]\nBOSS — zdrowie 500% normy, 3 fazy walki. Faza 1: rekonesans (wysyła zwiadowców). Faza 2: infiltracja (przyzywa Trojany). Faza 3: eksfiltracja (zadaje obrażenia obszarowe).\n\n[color=#95a5a6][b]HISTORIA:[/b][/color] Lazarus Group (Korea Płn.) — odpowiedzialni za atak na Sony Pictures. Cozy Bear / APT29 (Rosja) — włamanie do DNC. Equation Group (USA) — najwyższy poziom zaawansowania.",
		"icon": preload("res://Assets/Characters/esa.png")
	},
	{
		"name": "Armia Botnet",
		"lore": "[i]Legion zniewolonych maszyn, które niegdyś były zwykłymi urządzeniami — lodówkami, routerami, kamerami IP. Teraz, sczepione w jeden potworny organizm przez złośliwe C2, maszerują w idealnej synchronizacji niczym cyfrowe zombie na rozkaz swojego pana. Każdy członek Armii Botnet to pojedynczy 'bot', ale razem tworzą lawinę, przed którą nie ma ucieczki. Operatorzy SOC-u szepczą o bota-netach wielkości milionów węzłów, zdolnych położyć całe domeny rządowe jednym rozkazem.[/i]\n\nRój przeciwników poruszających się w idealnej synchronizacji. Atakują falami — gdy myślisz, że pokonałeś pierwszy szereg, nadchodzi drugi.",
		"definition": "[color=#4ecdc4][b]OPIS ZAGROŻENIA[/b][/color]\nSieć przejętych urządzeń (komputery, IoT, serwery) kontrolowanych zdalnie przez operatora (bot-herder) za pośrednictwem serwerów Command & Control. Wykorzystywana do masowych ataków DDoS, rozsyłania spamu, cryptojackingu i kradzieży danych.\n\n[color=#f1c40f][b]MERYTORYKA SOC[/b][/color]\n• [b]Architektura:[/b] Klient-Serwer (centralne C2), P2P (zdecentralizowany, trudniejszy do rozbicia), Hybrydowa.\n• [b]Metody infekcji:[/b] Exploit Kity, phishing, brute-force na IoT (telnet/SSH z domyślnymi hasłami).\n• [b]Komunikacja C2:[/b] DNS tunneling, HTTP/HTTPS, IRC, Telegram API, social media.\n• [b]Obrona:[/b] Sinkholing domen C2, współpraca z dostawcami ISP, analiza NetFlow/IPFIX, blokowanie portów wychodzących.\n\n[color=#e74c3c][b]DANE WYWIADOWCZE (GRA)[/b][/color]\nPojawia się w falach po 8-12 botów. Każdy bot jest słaby, ale ich liczba przytłacza. Używaj broni obszarowej.\n\n[color=#95a5a6][b]HISTORIA:[/b][/color] Mirai (2016) — botnet IoT, który sparaliżował Dyn DNS (Twitter, Netflix, Spotify). Emotet — botnet-trojan rozbity w operacji międzynarodowej.",
		"icon": preload("res://Assets/Characters/mob.png")
	},
	{
		"name": "Władca Podziemia",
		"lore": "[i]Najgłębiej ukryty ze wszystkich zagrożeń — rezyduje w samym jądrze systemu, w Ring 0, poza zasięgiem nawet najnowszych skanerów antywirusowych. Władca Podziemia nie zostawia śladów w logach, nie wywołuje alertów, a jego obecność zdradza jedynie ledwie wyczuwalny spadek wydajności. Jest mistrzem cyfrowego tunelowania — gdy już raz zakorzeni się w twoim systemie, usunięcie go wymaga dosłownego formatowania dysku i reinstalacji od zera. W podziemnych kręgach hakerskich mówi się: 'rootkit nie włamuje się do systemu — rootkit staje się systemem'.[/i]\n\nNie atakuje bezpośrednio — wzmacnia wszystkie inne zagrożenia na arenie, czyniąc je niewidocznymi dla detektorów.",
		"definition": "[color=#4ecdc4][b]OPIS ZAGROŻENIA[/b][/color]\nZestaw narzędzi umożliwiających ukrycie obecności złośliwego oprogramowania w systemie poprzez modyfikację jego najniższych warstw: jądra systemu operacyjnego, sterowników, a nawet firmware'u (UEFI/BIOS).\n\n[color=#f1c40f][b]MERYTORYKA SOC[/b][/color]\n• [b]Poziomy działania:[/b] User-mode (podmiana API, hooking), Kernel-mode (modyfikacja sterowników, DKOM — Direct Kernel Object Manipulation), Bootkit (infekcja MBR/UEFI przed startem OS), Hypervisor (rootkit jako hypervisor pod systemem).\n• [b]Techniki maskowania:[/b] SSDT hooking, IRP hooking, filtrowanie komunikatów IOCTL, ukrywanie procesów/plików/kluczy rejestru.\n• [b]Obrona:[/b] Secure Boot + TPM, integrity checking (skróty plików systemowych), skanowanie offline (z czystego nośnika), Virtualization-Based Security.\n\n[color=#e74c3c][b]DANE WYWIADOWCZE (GRA)[/b][/color]\nNiewidoczny przez cały czas na arenie. Ujawnia się tylko przy ataku lub użyciu specjalnej umiejętności skanera głębokiego. Daje +30% maskowania wszystkim sojuszniczym jednostkom.\n\n[color=#95a5a6][b]HISTORIA:[/b][/color] Sony BMG Rootkit (2005) — rootkit w płytach CD z muzyką, skandal na skalę światową. LoJax (2018) — pierwszy rootkit UEFI użyty przez APT Sednit.",
		"icon": preload("res://Assets/Characters/dupa.png")
	},
	{
		"name": "Łowca Klawiszy",
		"lore": "[i]Niewidzialny drapieżnik, który nie potrzebuje wyrafinowanych exploitów — wystarczy mu strumień twoich własnych naciśnięć klawiszy. Czai się w procesie systemowym, niewidoczny dla zwykłego użytkownika, i skrupulatnie rejestruje każdą literę, każde hasło, każdy numer karty kredytowej. Na arenie materializuje się jako pulsująca linia kodu, która wysysa informacje z każdego trafionego celu. Stare hakerskie porzekadło głosi: 'Po co łamać szyfr, skoro można przechwycić klucz w locie?'[/i]\n\nAtakuje szybkimi seriami — każdy cios przechwytuje fragment twoich danych. Kumulatywny efekt może być katastrofalny.",
		"definition": "[color=#4ecdc4][b]OPIS ZAGROŻENIA[/b][/color]\nZłośliwe oprogramowanie lub sprzęt rejestrujący naciśnięcia klawiszy użytkownika. Stanowi często komponent większych kampanii (trojanów, spyware), ale bywa też używany samodzielnie do kradzieży haseł i danych finansowych.\n\n[color=#f1c40f][b]MERYTORYKA SOC[/b][/color]\n• [b]Typy:[/b] Software keylogger (hooking klawiatury w systemie), Hardware keylogger (fizyczne urządzenie USB/PS2 między klawiaturą a komputerem), Acoustic keylogger (analiza dźwięku klawiszy), Electromagnetic keylogger (przechwytywanie emisji EM z klawiatury).\n• [b]Kradzież:[/b] Hasła, numery kart, kody 2FA, prywatne wiadomości, dokumenty.\n• [b]Obrona:[/b] Menedżery haseł z autouzupełnianiem (brak wpisywania = brak keyloggera), klawiatury ekranowe (przeciw hardware), U2F klucze sprzętowe.\n\n[color=#e74c3c][b]DANE WYWIADOWCZE (GRA)[/b][/color]\nSzybki atak seriami 3-5 ciosów. Każdy cios nakłada debuff Wycieku Danych (-5% do maksymalnego HP, kumulatywnie).\n\n[color=#95a5a6][b]HISTORIA:[/b][/color] Olympic Destroyer (2018) — keylogger użyty podczas Zimowych Igrzysk Olimpijskich. HawkEye — komercyjny keylogger sprzedawany jako 'monitoring pracowniczy'.",
		"icon": preload("res://Assets/Characters/phishing.png")
	},
	{
		"name": "Szturmowiec DDoS",
		"lore": "[i]Gdy tysiące zhakowanych urządzeń jednocześnie otwiera połączenie z jednym celem, rodzi się Szturmowiec — tsunami pakietów danych, przed którym pękają nawet największe serwery. To nie jest subtelny atak; to cyfrowa nawałnica, która miażdży infrastrukturę samą swoją masą. Jego ciało to wir zapytań SYN, UDP i HTTP, a oddech to przeciążone łącza pękające pod naporem gigabitów śmieciowego ruchu. Na arenie sieciowej manifestuje się jako burza danych, w której nie widać pojedynczych przeciwników — tylko miażdżącą falę.[/i]\n\nAtakuje obszarowo — spowalnia całą twoją defensywę. Im dłużej pozostaje na arenie, tym więcej ruchu generuje.",
		"definition": "[color=#4ecdc4][b]OPIS ZAGROŻENIA[/b][/color]\nDistributed Denial of Service — skoordynowane zalewanie celu (serwera, usługi, sieci) ogromną ilością ruchu z wielu rozproszonych źródeł jednocześnie, co prowadzi do przeciążenia i niedostępności usługi dla prawowitych użytkowników.\n\n[color=#f1c40f][b]MERYTORYKA SOC[/b][/color]\n• [b]Typy ataku:[/b] Volumetryczny (zalewanie pasma — UDP flood, ICMP flood, DNS amplification), Protokolarny (wyczerpanie zasobów serwera — SYN flood, Ping of Death), Aplikacyjny (HTTP flood, Slowloris — męczy serwer powolnymi zapytaniami).\n• [b]Amplifikacja:[/b] Atakujący wysyła małe zapytanie do otwartego serwera DNS/NTP/Memcached, który odpowiada 50-500x większą odpowiedzią do ofiary (współczynnik amplifikacji).\n• [b]Obrona:[/b] CDN (Cloudflare, Akamai), scrubbing center, anycast, rate limiting, blackhole routing (ostateczność).\n\n[color=#e74c3c][b]DANE WYWIADOWCZE (GRA)[/b][/color]\nAtak obszarowy — spowalnia o 40% wszystkich sojuszników w promieniu. Nie ma ataku bezpośredniego, ale generuje 'lag' (opóźnienie akcji gracza).\n\n[color=#95a5a6][b]HISTORIA:[/b][/color] Atak na GitHub (2018) — 1.35 Tbps (Memcached amplification). Atak na Google (2017) — 2.54 Tbps. Operacja Power Hour (2023) — fala DDoS na ukraińską infrastrukturę.",
		"icon": preload("res://Assets/Characters/mob.png")
	}
]

func _ready() -> void:
	visible = false
	_populate_list()
	if not enemies_data.is_empty():
		_display_enemy(0)

func _populate_list() -> void:
	enemy_list.clear()
	for i in range(enemies_data.size()):
		var enemy = enemies_data[i]
		enemy_list.add_item(enemy.name, enemy.icon)
		if i % 2 == 0:
			enemy_list.set_item_custom_bg_color(i, Color(0.035, 0.05, 0.1, 1))
		else:
			enemy_list.set_item_custom_bg_color(i, Color(0.05, 0.065, 0.13, 1))

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
