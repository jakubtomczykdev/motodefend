extends RefCounted
class_name QuizData

const FALLBACK_TOPIC: String = "worm"

const TOPIC_LABELS: Dictionary = {
	"worm": "Robak sieciowy",
	"trojan": "Trojan",
	"ransomware": "Ransomware",
	"spyware": "Spyware / keylogger",
	"phishing": "Phishing",
	"sql": "SQL Injection",
	"bot": "Botnet",
	"hijacking": "Hijacking",
	"smurf_attack": "Smurf attack",
	"firewall_overload": "Firewall overload",
	"apt_boss": "APT"
}

const QUESTIONS: Dictionary = {
	"worm": [
		{"question": "Co najbardziej odroznia robaka od trojana?", "answers": ["Sam potrafi sie rozprzestrzeniac", "Zawsze szyfruje pliki", "Dziala tylko przez SMS"], "correct": 0},
		{"question": "Jaka obrona najmocniej ogranicza rozrost robaka?", "answers": ["Segmentacja sieci", "Jedno konto admina dla wszystkich", "Wylaczenie logow"], "correct": 0},
		{"question": "Dlaczego aktualizacje systemow sa wazne przy robakach?", "answers": ["Zamykaja znane podatnosci", "Zwiekszaja jasnosc monitora", "Usuwaja hasla uzytkownikow"], "correct": 0},
		{"question": "Co robak robi po znalezieniu podatnego hosta?", "answers": ["Kopiuje sie dalej", "Prosi o potwierdzenie w sklepie", "Tworzy kopie zapasowa"], "correct": 0},
		{"question": "Ktory sygnal moze wskazywac na robaka?", "answers": ["Nagly wzrost ruchu sieciowego", "Cichsza praca wentylatora", "Mniejsza liczba polaczen"], "correct": 0},
		{"question": "Co pomaga wykryc propagacje robaka?", "answers": ["Monitoring anomalii ruchu", "Wylaczenie alertow", "Jedno wspolne haslo"], "correct": 0},
		{"question": "Dlaczego niepotrzebne uslugi sa ryzykowne?", "answers": ["Moga byc kolejnym wektorem wejscia", "Blokuja kolor interfejsu", "Zawsze sa szyfrowane"], "correct": 0},
		{"question": "Co oznacza samoreplikacja?", "answers": ["Tworzenie kolejnych kopii siebie", "Reczne wpisanie hasla", "Zmiana tapety"], "correct": 0},
		{"question": "Ktora praktyka zmniejsza zasieg infekcji?", "answers": ["Oddzielenie segmentow sieci", "Otwieranie wszystkich portow", "Brak kopii zapasowych"], "correct": 0},
		{"question": "Co jest typowym celem robaka?", "answers": ["Szybkie rozprzestrzenienie", "Legalna aktualizacja BIOS", "Poprawa wydajnosci gry"], "correct": 0}
	],
	"trojan": [
		{"question": "Jak najczesciej trojan oszukuje uzytkownika?", "answers": ["Udaje zaufany plik lub program", "Zawsze atakuje bez pliku", "Dziala tylko na drukarkach"], "correct": 0},
		{"question": "Co jest dobrym nawykiem przed uruchomieniem instalatora?", "answers": ["Sprawdzenie zrodla i podpisu", "Wylaczenie antywirusa", "Udostepnienie hasla"], "correct": 0},
		{"question": "Co trojan moze utworzyc po uruchomieniu?", "answers": ["Backdoor", "Bezpieczna kopie offline", "Nowe MFA"], "correct": 0},
		{"question": "Dlaczego zasada najmniejszych uprawnien pomaga?", "answers": ["Ogranicza szkody po uruchomieniu", "Przyspiesza pobieranie", "Ukrywa logi"], "correct": 0},
		{"question": "Ktory plik jest najbardziej podejrzany?", "answers": ["Instalator z nieznanego linku", "Aplikacja z oficjalnego sklepu", "Podpisany sterownik producenta"], "correct": 0},
		{"question": "Co oznacza backdoor?", "answers": ["Ukryte wejscie do systemu", "Zapasowy monitor", "Kopia konfiguracji routera"], "correct": 0},
		{"question": "Co zmniejsza ryzyko trojana?", "answers": ["Pobieranie z oficjalnych zrodel", "Klikanie zalacznikow z presja czasu", "Uzywanie konta admina do wszystkiego"], "correct": 0},
		{"question": "Dlaczego reputacja aplikacji ma znaczenie?", "answers": ["Pomaga ocenic zaufanie do pliku", "Zastepuje backup", "Zwieksza obrazenia broni"], "correct": 0},
		{"question": "Co moze byc ladunkiem trojana?", "answers": ["Kradziez danych logowania", "Lepsze szyfrowanie dysku", "Aktualizacja sterownikow"], "correct": 0},
		{"question": "Jak ograniczyc skutki uruchomienia trojana?", "answers": ["EDR i ograniczone uprawnienia", "Brak monitoringu", "Jedno haslo wszedzie"], "correct": 0}
	],
	"ransomware": [
		{"question": "Co jest glownym celem ransomware?", "answers": ["Zablokowanie danych i wymuszenie okupu", "Samodzielne skanowanie bez konca", "Poprawa kopii zapasowych"], "correct": 0},
		{"question": "Najlepsza obrona przed utrata danych to:", "answers": ["Przetestowany backup offline", "Wylaczone logowanie", "Haslo na kartce przy monitorze"], "correct": 0},
		{"question": "Dlaczego placenie okupu jest ryzykowne?", "answers": ["Nie gwarantuje odzyskania danych", "Zawsze przyspiesza system", "Usuwa podatnosci"], "correct": 0},
		{"question": "Co pomaga zatrzymac ruch boczny ransomware?", "answers": ["Segmentacja i minimalne uprawnienia", "Jedno konto admina", "Brak MFA"], "correct": 0},
		{"question": "Co ransomware czesto robi przed szyfrowaniem?", "answers": ["Rozpoznaje zasoby w sieci", "Tworzy publiczny raport", "Instaluje aktualizacje"], "correct": 0},
		{"question": "Co oznacza backup offline?", "answers": ["Kopia odseparowana od atakowanej sieci", "Kopia na tym samym pulpicie", "Zrzut ekranu folderu"], "correct": 0},
		{"question": "Ktory sygnal jest alarmowy?", "answers": ["Masowa zmiana rozszerzen plikow", "Mniej procesow niz zwykle", "Nowa tapeta od producenta"], "correct": 0},
		{"question": "Jak MFA pomaga przy ransomware?", "answers": ["Utrudnia przejecie konta", "Zastepuje backup", "Szyfruje okup"], "correct": 0},
		{"question": "Co warto cwiczyc przed incydentem?", "answers": ["Odtwarzanie danych z backupu", "Ignorowanie alertow", "Kasowanie logow"], "correct": 0},
		{"question": "Co zmniejsza powierzchnie ataku?", "answers": ["Aktualizacje i blokowanie makr z internetu", "Otwieranie RDP dla wszystkich", "Brak filtrowania poczty"], "correct": 0}
	],
	"spyware": [
		{"question": "Jaki jest cel spyware?", "answers": ["Ciche zbieranie informacji", "Glosne szyfrowanie plikow", "Legalne przyspieszenie komputera"], "correct": 0},
		{"question": "Co moze robic keylogger?", "answers": ["Zapisywac wpisywane klawisze", "Naprawiac hasla", "Blokowac phishing automatycznie"], "correct": 0},
		{"question": "Dlaczego 2FA pomaga przy spyware?", "answers": ["Samo haslo nie wystarczy", "Usuwa malware z dysku", "Zwieksza RAM"], "correct": 0},
		{"question": "Ktory objaw pasuje do spyware?", "answers": ["Nieznany proces wysylajacy dane", "Brak ruchu sieciowego", "Wylaczony ekran"], "correct": 0},
		{"question": "Co ogranicza spyware?", "answers": ["Minimalne uprawnienia aplikacji", "Instalacja dodatkow z losowych stron", "Wylaczenie skanera"], "correct": 0},
		{"question": "Co spyware moze przechwytywac?", "answers": ["Hasla, zrzuty ekranu, pliki", "Tylko kolor pulpitu", "Tylko nazwe komputera"], "correct": 0},
		{"question": "Dobra reakcja po wykryciu spyware to:", "answers": ["Izolacja hosta i zmiana hasel", "Udostepnienie tokenow", "Kasowanie backupow"], "correct": 0},
		{"question": "Co pomaga wykryc spyware?", "answers": ["EDR i monitoring procesow", "Brak aktualizacji", "Ukrywanie rozszerzen plikow"], "correct": 0},
		{"question": "Dlaczego dodatki do przegladarki sa ryzykowne?", "answers": ["Moga miec dostep do stron i danych", "Zawsze sa podpisane przez bank", "Nie moga zbierac danych"], "correct": 0},
		{"question": "Co warto sprawdzac w uprawnieniach aplikacji?", "answers": ["Dostep do mikrofonu, ekranu i plikow", "Kolor ikony", "Rozmiar okna"], "correct": 0}
	],
	"phishing": [
		{"question": "Na co phishing atakuje w pierwszej kolejnosci?", "answers": ["Decyzje czlowieka", "Tylko firewall", "Tylko dysk twardy"], "correct": 0},
		{"question": "Co zrobic z pilnym linkiem do logowania?", "answers": ["Wejsc recznie na znany adres", "Kliknac, jesli logo wyglada dobrze", "Przeslac dalej wszystkim"], "correct": 0},
		{"question": "Ktory sygnal jest podejrzany?", "answers": ["Presja czasu i grozba blokady konta", "Znany adres wpisany recznie", "MFA z aplikacji"], "correct": 0},
		{"question": "Co trzeba sprawdzic w linku?", "answers": ["Domene", "Kolor przycisku", "Dlugosc maila"], "correct": 0},
		{"question": "Co jest typowa przyneta phishingowa?", "answers": ["Falszywa faktura lub paczka", "Oficjalna aktualizacja z panelu systemu", "Backup offline"], "correct": 0},
		{"question": "Dlaczego menedzer hasel pomaga?", "answers": ["Nie uzupelni hasla na zlej domenie", "Zastepuje antywirusa", "Usuwa spam"], "correct": 0},
		{"question": "Co zrobic z podejrzana wiadomoscia?", "answers": ["Zglosic i nie klikac", "Odpowiedziec haslem", "Pobrac zalacznik"], "correct": 0},
		{"question": "Czym jest spear phishing?", "answers": ["Phishing dopasowany do konkretnej osoby", "Atak tylko na drukarki", "Szyfrowanie kopii zapasowych"], "correct": 0},
		{"question": "Co moze byc celem phishingu?", "answers": ["Kradziez loginu lub tokenu", "Naprawa DNS", "Legalna segmentacja"], "correct": 0},
		{"question": "Ktora odpowiedz jest najbezpieczniejsza?", "answers": ["Zweryfikowac prosbe innym kanalem", "Kliknac natychmiast", "Wylaczyc MFA"], "correct": 0}
	],
	"sql": [
		{"question": "Czym jest SQL Injection?", "answers": ["Wstrzyknieciem danych zmieniajacych zapytanie", "Szyfrowaniem dysku", "Atakiem przez Bluetooth"], "correct": 0},
		{"question": "Najlepsza podstawowa ochrona przed SQLi to:", "answers": ["Zapytania parametryzowane", "Dluzej dzialajacy serwer", "Kolorowe formularze"], "correct": 0},
		{"question": "Dlaczego sklejanie SQL stringami jest ryzykowne?", "answers": ["Dane moga stac sie kodem zapytania", "Baza robi sie za szybka", "Usuwa indeksy automatycznie"], "correct": 0},
		{"question": "Co ogranicza skutki SQLi?", "answers": ["Minimalne uprawnienia konta bazy", "Konto root dla aplikacji", "Brak logow"], "correct": 0},
		{"question": "Czy walidacja zastepuje parametryzacje?", "answers": ["Nie, jest tylko dodatkowa warstwa", "Tak, zawsze", "Tylko w grach"], "correct": 0},
		{"question": "Co moze wyciec przez SQLi?", "answers": ["Dane uzytkownikow", "Tylko nazwa CSS", "Nic, to blad graficzny"], "correct": 0},
		{"question": "Co warto logowac przy podejrzeniu SQLi?", "answers": ["Nietypowe zapytania i bledy", "Hasla w plain text", "Tylko kolor UI"], "correct": 0},
		{"question": "Co oznacza prepared statement?", "answers": ["Oddzielenie kodu zapytania od danych", "Reczne skladanie stringa", "Kasowanie tabeli"], "correct": 0},
		{"question": "Ktora odpowiedz jest bezpieczna?", "answers": ["ORM lub zapytania parametryzowane", "Formatowanie SQL przez + user_input", "Wylaczenie escaping"], "correct": 0},
		{"question": "Dlaczego testy bezpieczenstwa formularzy sa wazne?", "answers": ["Wejscie uzytkownika bywa wektorem ataku", "Formularze nie lacza sie z baza", "SQLi dotyczy tylko grafiki"], "correct": 0}
	],
	"bot": [
		{"question": "Czym jest botnet?", "answers": ["Siecia przejetych urzadzen", "Jednym legalnym serwerem", "Kopia zapasowa"], "correct": 0},
		{"question": "Do czego botnet moze byc uzyty?", "answers": ["DDoS, spam, brute force", "Tylko do aktualizacji", "Do poprawy MFA"], "correct": 0},
		{"question": "Co ogranicza przejecie urzadzen IoT?", "answers": ["Zmiana domyslnych hasel", "Publiczne RDP", "Brak aktualizacji"], "correct": 0},
		{"question": "Co jest sygnalem infekcji botem?", "answers": ["Nieznany ruch wychodzacy", "Brak polaczen", "Wylaczona karta sieciowa"], "correct": 0},
		{"question": "Czym jest C2?", "answers": ["Command and Control", "Drugi monitor", "Kopia certyfikatu"], "correct": 0},
		{"question": "Jak bronic sie przed DDoS?", "answers": ["Filtrowanie, rate limiting, ochrona DDoS", "Wylaczenie logow", "Jedno haslo"], "correct": 0},
		{"question": "Dlaczego aktualizacje IoT sa wazne?", "answers": ["Zamykaja podatnosci firmware", "Usuwaja internet", "Blokuja backup"], "correct": 0},
		{"question": "Co robi bot po otrzymaniu komendy?", "answers": ["Wykonuje zadanie atakujacego", "Pyta admina o zgode", "Tworzy raport RODO"], "correct": 0},
		{"question": "Co pomaga wykryc botnet w sieci?", "answers": ["Analiza ruchu do znanych C2", "Brak DNS", "Kasowanie alertow"], "correct": 0},
		{"question": "Ktora praktyka jest zla?", "answers": ["Pozostawienie domyslnych hasel", "Segmentacja IoT", "Aktualizacja firmware"], "correct": 0}
	],
	"hijacking": [
		{"question": "Czym jest session hijacking?", "answers": ["Przejeciem sesji uzytkownika", "Legalnym resetem hasla", "Szyfrowaniem backupu"], "correct": 0},
		{"question": "Co ogranicza ryzyko kradziezy lub naduzycia cookie?", "answers": ["HttpOnly, Secure, SameSite", "Cookie w URL", "Brak wygasania sesji"], "correct": 0},
		{"question": "Dlaczego krotki czas zycia sesji pomaga?", "answers": ["Zmniejsza okno naduzycia", "Zwieksza uprawnienia", "Wylacza MFA"], "correct": 0},
		{"question": "Co jest podejrzane przy hijackingu?", "answers": ["Logowanie z nietypowego miejsca", "Staly adres i znane urzadzenie", "Poprawne MFA"], "correct": 0},
		{"question": "Co pomaga przy wrazliwych akcjach?", "answers": ["Ponowna autoryzacja", "Brak hasla", "Token w mailu"], "correct": 0},
		{"question": "Co moze zostac przejete?", "answers": ["Sesja, token lub konto", "Tylko tapeta", "Tylko nazwa pliku"], "correct": 0},
		{"question": "Jak reagowac na skradziony token?", "answers": ["Uniewaznic sesje i rotowac tokeny", "Udostepnic go dalej", "Wylaczyc alerty"], "correct": 0},
		{"question": "Dlaczego MFA pomaga?", "answers": ["Utrudnia pelne przejecie konta", "Zastepuje TLS", "Usuwa logi"], "correct": 0},
		{"question": "Co oznacza anomalia sesji?", "answers": ["Zachowanie inne niz typowe dla uzytkownika", "Poprawna aktualizacja", "Nowa skorka UI"], "correct": 0},
		{"question": "Czego unikac?", "answers": ["Tokenow w URL", "Rotacji sesji", "Bezpiecznych ciasteczek"], "correct": 0}
	],
	"smurf_attack": [
		{"question": "Czym jest smurf attack?", "answers": ["Odbity flood z podszytym adresem ofiary", "Atak na hasla SQL", "Legalny backup"], "correct": 0},
		{"question": "Co jest wykorzystywane w smurf attack?", "answers": ["Broadcast i spoofing IP", "Tylko phishing SMS", "Kamera internetowa"], "correct": 0},
		{"question": "Jak ograniczyc smurf attack?", "answers": ["Blokowac directed broadcast", "Otworzyc wszystkie broadcasty", "Wylaczyc monitoring"], "correct": 0},
		{"question": "Co oznacza spoofing?", "answers": ["Podszywanie sie pod inny adres", "Szyfrowanie pliku", "Przyspieszenie CPU"], "correct": 0},
		{"question": "Dlaczego rate limiting pomaga?", "answers": ["Ogranicza nadmiarowy ruch", "Zwieksza flood", "Usuwa backup"], "correct": 0},
		{"question": "Co widzi ofiara?", "answers": ["Zalew odpowiedziami z wielu hostow", "Jedno ciche logowanie", "Brak ruchu"], "correct": 0},
		{"question": "Co pomaga na brzegu sieci?", "answers": ["Filtrowanie antyspoofingowe", "Brak ACL", "Publiczne hasla"], "correct": 0},
		{"question": "Jaki to typ ataku?", "answers": ["DDoS przez odbicie", "Keylogger", "Trojan instalacyjny"], "correct": 0},
		{"question": "Co zmniejsza amplifikacje?", "answers": ["Konfiguracja routerow i hostow", "Zwiekszenie broadcastow", "Brak segmentacji"], "correct": 0},
		{"question": "Co monitorowac?", "answers": ["Nagly wzrost ICMP/ruchu odbitego", "Kolor ikon", "Temperature pokoju"], "correct": 0}
	],
	"firewall_overload": [
		{"question": "Co oznacza firewall overload?", "answers": ["Przeciazenie filtrowania ruchem", "Zawsze wylaczony firewall", "Haslo w bazie"], "correct": 0},
		{"question": "Co pomaga ograniczyc przeciazenie?", "answers": ["Rate limiting i filtrowanie na brzegu", "Otwieranie kazdego portu", "Brak alertow"], "correct": 0},
		{"question": "Dlaczego reguly minimalnego dostepu sa wazne?", "answers": ["Przepuszczaja tylko potrzebny ruch", "Pozwalaja na wszystko", "Zastepuja backup"], "correct": 0},
		{"question": "Co monitorowac przy przeciazeniu?", "answers": ["Wolumen i typ ruchu", "Kolor pulpitu", "Liczbe ikon"], "correct": 0},
		{"question": "Co moze byc skutkiem overloadu?", "answers": ["Opoznienia lub spadek ochrony", "Lepsze szyfrowanie", "Mniej ruchu"], "correct": 0},
		{"question": "Co pomaga przy DDoS na brzegu?", "answers": ["Scrubbing/ochrona DDoS", "Konto admina bez hasla", "Wylaczenie firewalli"], "correct": 0},
		{"question": "Dlaczego porzadek regul ma znaczenie?", "answers": ["Wplywa na skutecznosc i koszt filtrowania", "Zmienia tapete", "Nie ma znaczenia nigdy"], "correct": 0},
		{"question": "Co jest dobra praktyka?", "answers": ["Blokuj domyslnie, zezwalaj swiadomie", "Zezwalaj domyslnie na wszystko", "Nie dokumentuj regul"], "correct": 0},
		{"question": "Co wykrywa anomalie?", "answers": ["Monitoring i baseline ruchu", "Brak logowania", "Losowe reguly"], "correct": 0},
		{"question": "Co robic z nieuzywanymi portami?", "answers": ["Zamykac", "Otwierac publicznie", "Ignorowac"], "correct": 0}
	],
	"apt_boss": [
		{"question": "Czym wyroznia sie APT?", "answers": ["Dlugotrwaloscia i ukierunkowaniem", "Jednym przypadkowym kliknieciem bez celu", "Tylko spamem reklamowym"], "correct": 0},
		{"question": "Co pomaga wykrywac APT?", "answers": ["Korelacja logow i hunting", "Brak monitoringu", "Jedno haslo admina"], "correct": 0},
		{"question": "Co oznacza persistence?", "answers": ["Utrzymanie dostepu w systemie", "Legalne wylogowanie", "Backup offline"], "correct": 0},
		{"question": "Dlaczego segmentacja pomaga?", "answers": ["Utrudnia ruch boczny", "Ulatwia przejecie calej sieci", "Wylacza MFA"], "correct": 0},
		{"question": "Co jest celem APT?", "answers": ["Dane, dostep lub sabotaz", "Kolor UI", "Tylko dzwiek systemu"], "correct": 0},
		{"question": "Co ogranicza phishing jako wejscie APT?", "answers": ["Szkolenia, MFA i filtrowanie poczty", "Brak zgloszen", "Udostepnianie tokenow"], "correct": 0},
		{"question": "Co robic z nietypowym admin loginem?", "answers": ["Sprawdzic i eskalowac incydent", "Zignorowac", "Wylaczyc logi"], "correct": 0},
		{"question": "Co to jest lateral movement?", "answers": ["Przemieszczanie sie po sieci", "Zmiana monitora", "Usuwanie backupu zawsze"], "correct": 0},
		{"question": "Co pomaga po wykryciu APT?", "answers": ["Izolacja, analiza, rotacja sekretow", "Publiczne udostepnienie hasel", "Kasowanie dowodow"], "correct": 0},
		{"question": "Dlaczego least privilege jest wazne?", "answers": ["Ogranicza zasieg przejecia", "Daje wszystkim admina", "Zastepuje EDR"], "correct": 0}
	]
}

const EXTRA_QUESTIONS: Dictionary = {
	"worm": [
		{"question": "Ktore dzialanie najlepiej ogranicza rozprzestrzenianie robaka?", "answers": ["Segmentacja sieci i aktualizacje", "Otworzenie wiekszej liczby portow", "Wylaczenie kopii zapasowych"], "correct": 0},
		{"question": "Co nalezy zrobic z hostem podejrzanym o infekcje robakiem?", "answers": ["Odizolowac go od sieci", "Dodac mu uprawnienia admina", "Przekazac pliki dalej"], "correct": 0},
		{"question": "Dlaczego robaki czesto atakuja wiele maszyn naraz?", "answers": ["Automatycznie szukaja kolejnych celow", "Wymagaja jednej recznej instalacji", "Dzialaja tylko offline"], "correct": 0},
		{"question": "Co zmniejsza powierzchnie ataku dla robaka?", "answers": ["Wylaczanie nieuzywanych uslug", "Publiczne wystawienie SMB", "Brak patchowania"], "correct": 0},
		{"question": "Jaki log moze pomoc przy analizie robaka?", "answers": ["Nietypowe polaczenia wychodzace", "Lista tapet pulpitu", "Jasnosc ekranu"], "correct": 0},
		{"question": "Ktory mechanizm moze zablokowac skanowanie robaka?", "answers": ["Reguly firewall i IPS", "Wspolne konto dla zespolu", "Wylaczone alerty"], "correct": 0},
		{"question": "Co oznacza atak zero-click?", "answers": ["Wykorzystanie bledu bez aktywnej akcji uzytkownika", "Klikniecie dwa razy w link", "Tylko blad graficzny"], "correct": 0},
		{"question": "Co robic po opanowaniu ogniska robaka?", "answers": ["Zalatac podatnosc i przywrocic systemy", "Przywrocic stary obraz bez patcha", "Usunac dokumentacje"], "correct": 0},
		{"question": "Dlaczego skanowanie portow bywa sygnalem robaka?", "answers": ["Robak szuka uslug do infekcji", "System sprawdza kolor ikon", "Backup wysyla tapety"], "correct": 0},
		{"question": "Ktora reakcja ogranicza dalsza propagacje?", "answers": ["Blokada ruchu miedzy segmentami", "Wlaczenie guest admin", "Udostepnienie hasel"], "correct": 0}
	],
	"trojan": [
		{"question": "Co jest typowa metoda wejscia trojana?", "answers": ["Podszycie sie pod przydatny program", "Legalny backup offline", "Aktualizacja z panelu producenta"], "correct": 0},
		{"question": "Ktory sygnal moze wskazywac na trojana?", "answers": ["Nowy proces z nieznanej lokalizacji", "Mniej ruchu niz zwykle", "Brak nowych plikow"], "correct": 0},
		{"question": "Jak ograniczyc szkody po uruchomieniu trojana?", "answers": ["Uruchamiac aplikacje bez admina", "Dawac stale uprawnienia root", "Kasowac logi"], "correct": 0},
		{"question": "Co sprawdzic przed pobraniem narzedzia?", "answers": ["Zrodlo, hash i podpis cyfrowy", "Tylko kolor przycisku download", "Liczbe reklam"], "correct": 0},
		{"question": "Co moze ukrywac trojan?", "answers": ["Zdalny dostep do systemu", "Legalne MFA", "Kopie zapasowa bez internetu"], "correct": 0},
		{"question": "Dlaczego sandbox pomaga w analizie trojana?", "answers": ["Pozwala obserwowac zachowanie w izolacji", "Daje malware pelne uprawnienia", "Usuwa wszystkie dowody"], "correct": 0},
		{"question": "Co jest bezpieczniejsza praktyka instalacji?", "answers": ["Pobieranie z oficjalnych kanalow", "Instalacja crackow", "Klikanie mirrorow z maila"], "correct": 0},
		{"question": "Co oznacza payload trojana?", "answers": ["Wlasciwe zlosliwe dzialanie", "Ikona programu", "Opis w sklepie"], "correct": 0},
		{"question": "Co warto monitorowac przy trojanach?", "answers": ["Autostart i nietypowe polaczenia", "Rozmiar tapety", "Kolor kursora"], "correct": 0},
		{"question": "Ktora odpowiedz jest najrozsadniejsza po wykryciu trojana?", "answers": ["Izolacja, analiza i rotacja hasel", "Ignorowanie alertu", "Udostepnienie pliku zespolowi"], "correct": 0}
	],
	"ransomware": [
		{"question": "Co najbardziej obniza ryzyko utraty danych po ransomware?", "answers": ["Regularny test odtwarzania backupu", "Backup na tym samym dysku", "Brak kopii historii"], "correct": 0},
		{"question": "Jaki sygnal moze wskazywac na start szyfrowania?", "answers": ["Nagla masowa modyfikacja plikow", "Brak aktywnosci dysku", "Mniej procesow"], "correct": 0},
		{"question": "Co ogranicza ruch boczny ransomware?", "answers": ["Segmentacja i blokada niepotrzebnych udzialow", "Jedno konto admina", "Publiczne SMB"], "correct": 0},
		{"question": "Dlaczego makra z internetu sa ryzykowne?", "answers": ["Moga uruchomic zlosliwy kod", "Zawsze poprawiaja arkusze", "Chronia przed phishingiem"], "correct": 0},
		{"question": "Co oznacza double extortion?", "answers": ["Szyfrowanie i grozba wycieku danych", "Dwa hasla do backupu", "Podwojna aktualizacja"], "correct": 0},
		{"question": "Jaka reakcja jest dobra przy wykryciu ransomware?", "answers": ["Odciac zainfekowane hosty od sieci", "Czekac az samo minie", "Dac wiecej uprawnien"], "correct": 0},
		{"question": "Co pomaga w dochodzeniu po ataku?", "answers": ["Zachowane logi i obrazy dyskow", "Kasowanie sladow", "Wylaczone SIEM"], "correct": 0},
		{"question": "Dlaczego RDP wystawione publicznie jest ryzykowne?", "answers": ["Moze byc wektorem wejscia", "Zastepuje VPN", "Blokuje brute force"], "correct": 0},
		{"question": "Co warto objac backupem?", "answers": ["Dane i krytyczne konfiguracje", "Tylko skroty pulpitu", "Same loga aplikacji"], "correct": 0},
		{"question": "Co jest lepsze niz placenie okupu?", "answers": ["Odtworzenie z pewnego backupu", "Wyslanie kolejnej zaplaty", "Wylaczenie antywirusa"], "correct": 0}
	],
	"spyware": [
		{"question": "Co spyware robi zwykle po cichu?", "answers": ["Zbiera i wysyla dane", "Naprawia podatnosci", "Tworzy backup offline"], "correct": 0},
		{"question": "Jakie uprawnienie aplikacji moze byc ryzykowne?", "answers": ["Dostep do ekranu i klawiatury", "Brak dostepu do sieci", "Tylko zmiana motywu"], "correct": 0},
		{"question": "Co ogranicza skutki keyloggera?", "answers": ["MFA i rotacja hasel", "Jedno haslo wszedzie", "Zapisywanie tokenow w notatniku"], "correct": 0},
		{"question": "Co moze wskazywac na spyware?", "answers": ["Nietypowy upload danych", "Brak procesu sieciowego", "Wiecej wolnego RAM"], "correct": 0},
		{"question": "Dlaczego dodatki przegladarki trzeba ograniczac?", "answers": ["Moga czytac dane na stronach", "Nie maja zadnych uprawnien", "Zawsze sa bezpieczne"], "correct": 0},
		{"question": "Co jest dobra praktyka prywatnosci?", "answers": ["Dawac aplikacjom minimalne uprawnienia", "Zezwalac na wszystko", "Ignorowac monity systemu"], "correct": 0},
		{"question": "Co moze przechwytywac spyware mobilny?", "answers": ["SMS, lokalizacje i kontakty", "Tylko poziom baterii", "Wylacznie tapete"], "correct": 0},
		{"question": "Jak reagowac po kradziezy hasel?", "answers": ["Zmienic hasla i uniewaznic sesje", "Czekac na kolejny alert", "Wylaczyc MFA"], "correct": 0},
		{"question": "Co pomaga wykryc podejrzany proces?", "answers": ["EDR i lista autostartu", "Brak logow", "Wspolne konto admina"], "correct": 0},
		{"question": "Co jest dobrym nawykiem instalacji aplikacji?", "answers": ["Sprawdzanie wydawcy i uprawnien", "Instalacja z reklam", "Akceptowanie kazdego promptu"], "correct": 0}
	],
	"phishing": [
		{"question": "Co jest najbezpieczniejsze przy mailu z linkiem do banku?", "answers": ["Wpisac adres banku recznie", "Kliknac link z maila", "Podac kod MFA w odpowiedzi"], "correct": 0},
		{"question": "Jaki element czesto buduje presje w phishingu?", "answers": ["Grozba blokady konta", "Spokojna weryfikacja", "Brak wezwania do akcji"], "correct": 0},
		{"question": "Co sprawdzic przy podejrzanej domenie?", "answers": ["Literowki i prawdziwy adres", "Kolor logo", "Godzine wyslania tylko"], "correct": 0},
		{"question": "Dlaczego MFA push fatigue jest grozne?", "answers": ["Uzytkownik moze zaakceptowac falszywy prompt", "Blokuje wszystkie logowania", "Zastepuje hasla"], "correct": 0},
		{"question": "Co zrobic z zalacznikiem od nieznanego nadawcy?", "answers": ["Nie otwierac i zglosic", "Uruchomic jako admin", "Przeslac dalej"], "correct": 0},
		{"question": "Czym jest vishing?", "answers": ["Phishing przez rozmowe glosowa", "Atak na drukarke", "Szyfrowanie plikow"], "correct": 0},
		{"question": "Co chroni przed wpisaniem hasla na zlej stronie?", "answers": ["Menedzer hasel i sprawdzanie domeny", "Zapamietanie hasla w mailu", "Wylaczenie TLS"], "correct": 0},
		{"question": "Co jest celem falszywej strony logowania?", "answers": ["Przechwycenie danych logowania", "Legalna aktualizacja", "Weryfikacja backupu"], "correct": 0},
		{"question": "Jak weryfikowac pilna prosbe od szefa?", "answers": ["Innym, znanym kanalem", "Odpowiedziec haslem", "Kliknac pierwszy link"], "correct": 0},
		{"question": "Co oznacza typosquatting?", "answers": ["Domena podobna do prawdziwej", "Legalna domena producenta", "Kopia offline"], "correct": 0}
	],
	"sql": [
		{"question": "Co oddziela dane od kodu zapytania SQL?", "answers": ["Parametryzacja zapytan", "Sklejanie stringow", "Komentarze w CSS"], "correct": 0},
		{"question": "Dlaczego konto bazy powinno miec minimalne uprawnienia?", "answers": ["Ogranicza skutki udanego SQLi", "Daje dostep do wszystkiego", "Usuwa potrzebe walidacji"], "correct": 0},
		{"question": "Co jest zlym wzorcem w formularzu logowania?", "answers": ["Budowanie SQL przez laczenie tekstu", "Prepared statement", "Walidacja wejscia"], "correct": 0},
		{"question": "Jak traktowac dane z requestu HTTP?", "answers": ["Jako niezaufane", "Jako zawsze bezpieczne", "Jako kod SQL"], "correct": 0},
		{"question": "Co moze ujawnic SQLi typu error-based?", "answers": ["Szczegoly bazy przez komunikaty bledow", "Kolor motywu", "Tylko ping serwera"], "correct": 0},
		{"question": "Co pomaga ograniczyc enumeracje danych?", "answers": ["Kontrola dostepu i limity", "Brak autoryzacji", "SELECT * dla kazdego"], "correct": 0},
		{"question": "Czym jest blind SQL injection?", "answers": ["Wnioskowanie z reakcji aplikacji", "Atak bez bazy danych", "Szyfrowanie backupu"], "correct": 0},
		{"question": "Co warto robic z bledami SQL w produkcji?", "answers": ["Logowac wewnetrznie, nie ujawniac detali", "Pokazywac pelne stack trace", "Wylaczyc logi"], "correct": 0},
		{"question": "Co jest dobra warstwa obrony obok parametryzacji?", "answers": ["Walidacja i WAF", "Brak testow", "Konto root aplikacji"], "correct": 0},
		{"question": "Co oznacza least privilege dla bazy?", "answers": ["Aplikacja ma tylko potrzebne prawa", "Kazdy ma admina", "Brak hasel"], "correct": 0}
	],
	"bot": [
		{"question": "Co laczy urzadzenia w botnecie?", "answers": ["Kontrola przez atakujacego", "Jedna legalna licencja", "Brak internetu"], "correct": 0},
		{"question": "Co moze byc celem komendy C2?", "answers": ["Start ataku DDoS", "Aktualizacja systemu zaufana", "Backup offline"], "correct": 0},
		{"question": "Dlaczego domyslne hasla IoT sa grozne?", "answers": ["Latwo przejac wiele urzadzen", "Blokuja malware", "Wlaczaja MFA"], "correct": 0},
		{"question": "Co jest dobra ochrona urzadzen IoT?", "answers": ["Segmentacja i zmiana hasel", "Publiczny panel admina", "Brak aktualizacji"], "correct": 0},
		{"question": "Jak botnet moze utrudniac wykrycie komunikacji C2?", "answers": ["Uzywa zmiennych domen lub wielu hostow C2", "Nie wykonuje polaczen sieciowych", "Dziala tylko w lokalnym notatniku"], "correct": 0},
		{"question": "Co oznacza sinkholing?", "answers": ["Przekierowanie ruchu C2 do kontrolowanego celu", "Wylaczenie backupu", "Dodanie kont admina"], "correct": 0},
		{"question": "Co wykrywa nietypowy botowy ruch?", "answers": ["Analiza DNS i NetFlow", "Kolor pulpitu", "Liczba ikon"], "correct": 0},
		{"question": "Jaka reakcja pomaga po infekcji botem?", "answers": ["Odciecie hosta i usuniecie malware", "Pozostawienie w sieci", "Udostepnienie tokenow"], "correct": 0},
		{"question": "Co ogranicza brute force z botnetu?", "answers": ["Rate limiting i MFA", "Brak limitow", "Jedno haslo"], "correct": 0},
		{"question": "Co jest typowa funkcja bota spamowego?", "answers": ["Masowa wysylka wiadomosci", "Skan kopii zapasowej", "Legalne podpisywanie plikow"], "correct": 0}
	],
	"hijacking": [
		{"question": "Co chroni cookie sesyjne przed kradzieza przez JavaScript?", "answers": ["Flaga HttpOnly", "Cookie w URL", "Brak wygasania"], "correct": 0},
		{"question": "Dlaczego TLS jest wazny dla sesji?", "answers": ["Chroni tokeny w transmisji", "Zastepuje autoryzacje", "Usuwa phishing"], "correct": 0},
		{"question": "Co zrobic po podejrzeniu przejecia sesji?", "answers": ["Uniewaznic sesje i wymusic ponowne logowanie", "Przedluzyc token", "Wylaczyc alert"], "correct": 0},
		{"question": "Co ogranicza ryzyko tokenow w przegladarce?", "answers": ["Krotkie zycie i bezpieczne przechowywanie", "Tokeny w query string", "Brak rotacji"], "correct": 0},
		{"question": "Jaki sygnal moze wskazywac na hijacking?", "answers": ["Zmiana kraju sesji bez MFA", "Znane urzadzenie", "Normalna godzina pracy"], "correct": 0},
		{"question": "Co oznacza session fixation?", "answers": ["Wymuszenie znanego identyfikatora sesji", "Legalny logout", "Zmiana hasla przez usera"], "correct": 0},
		{"question": "Co warto robic po logowaniu?", "answers": ["Rotowac identyfikator sesji", "Zachowac stary token", "Wysylac token w URL"], "correct": 0},
		{"question": "Dlaczego ponowna autoryzacja chroni wrazliwe akcje?", "answers": ["Utrudnia naduzycie przejetej sesji", "Przyspiesza atak", "Kasuje backup"], "correct": 0},
		{"question": "Co pomaga wykrywac przejecie konta?", "answers": ["Analiza anomalii logowania", "Brak logowania zdarzen", "Publiczne tokeny"], "correct": 0},
		{"question": "Co jest ryzykowne przy tokenach API?", "answers": ["Brak rotacji i zbyt szerokie uprawnienia", "Krotki czas zycia", "Zakres minimalny"], "correct": 0}
	],
	"smurf_attack": [
		{"question": "Dlaczego smurf attack jest atakiem odbitym?", "answers": ["Odpowiedzi trafiaja do podszytej ofiary", "Ofiara sama szyfruje pliki", "Atak wymaga keyloggera"], "correct": 0},
		{"question": "Co ogranicza podszywanie sie pod adresy IP?", "answers": ["Filtrowanie antyspoofingowe", "Publiczny broadcast", "Brak ACL"], "correct": 0},
		{"question": "Co nalezy zrobic z directed broadcast?", "answers": ["Zablokowac tam, gdzie nie jest potrzebny", "Wlaczyc publicznie", "Uzyc jako backup"], "correct": 0},
		{"question": "Jaki ruch jest czesto zwiazany ze smurf attack?", "answers": ["ICMP echo reply flood", "Zapytania SQL", "Makra Office"], "correct": 0},
		{"question": "Co oznacza amplifikacja?", "answers": ["Maly ruch generuje duzo odpowiedzi", "Zmniejszenie ruchu", "Szyfrowanie dysku"], "correct": 0},
		{"question": "Co moze zrobic operator sieci w czasie ataku?", "answers": ["Filtrowac i ograniczyc ruch na brzegu", "Otworzyc broadcasty", "Wylaczyc monitoring"], "correct": 0},
		{"question": "Dlaczego baseline ruchu pomaga?", "answers": ["Latwiej wykryc nagly flood", "Ukrywa alerty", "Daje wszystkim admina"], "correct": 0},
		{"question": "Co jest celem DDoS przez odbicie?", "answers": ["Przeciazenie lacza lub uslugi", "Kradziez hasla przez formularz", "Instalacja legalnej latki"], "correct": 0},
		{"question": "Co minimalizuje udzial twojej sieci w odbiciu?", "answers": ["Poprawna konfiguracja routerow i hostow", "Brak aktualizacji", "Publiczne broadcasty"], "correct": 0},
		{"question": "Co sprawdzic po smurf attack?", "answers": ["Reguly brzegowe i podatne segmenty", "Kolor tla", "Liste skrotow pulpitu"], "correct": 0}
	],
	"firewall_overload": [
		{"question": "Co najbardziej obciaza firewall podczas floodu?", "answers": ["Duzy wolumen pakietow i polaczen", "Mala liczba zdarzen", "Backup offline"], "correct": 0},
		{"question": "Jak zmniejszyc koszt przetwarzania ruchu?", "answers": ["Filtrowac wczesnie na brzegu", "Logowac wszystko bez limitu", "Przepuszczac kazdy port"], "correct": 0},
		{"question": "Dlaczego rate limiting jest pomocny?", "answers": ["Hamuje nadmiarowe zadania", "Zwieksza liczbe polaczen", "Usuwa reguly"], "correct": 0},
		{"question": "Co oznacza default deny?", "answers": ["Domyslnie blokuj, zezwalaj swiadomie", "Domyslnie wpuszczaj wszystko", "Brak firewalli"], "correct": 0},
		{"question": "Jaki alert jest wazny przy overloadzie?", "answers": ["Wzrost odrzuconych pakietow i CPU", "Zmiana tapety", "Brak ruchu"], "correct": 0},
		{"question": "Co pomaga w ochronie przed DDoS?", "answers": ["Scrubbing center lub usluga anty-DDoS", "Publiczne hasla", "Wylaczone logi"], "correct": 0},
		{"question": "Dlaczego porzadkowanie regul pomaga?", "answers": ["Skraca sciezke decyzji i zmniejsza bledy", "Zwieksza chaos", "Wylacza monitoring"], "correct": 0},
		{"question": "Co robic z nieznanym ruchem do zamknietej uslugi?", "answers": ["Blokowac i monitorowac", "Otworzyc port", "Ignorowac zawsze"], "correct": 0},
		{"question": "Co moze byc skutkiem pelnej kolejki polaczen?", "answers": ["Odmowa obslugi dla legalnych uzytkownikow", "Szybsze logowanie", "Mniej bledow"], "correct": 0},
		{"question": "Co powinien miec plan reakcji na overload?", "answers": ["Progi, eskalacje i reguly awaryjne", "Brak wlascicieli", "Usuwanie logow"], "correct": 0}
	],
	"apt_boss": [
		{"question": "Co odroznia APT od prostego malware?", "answers": ["Cierpliwosc, rozpoznanie i celowany atak", "Brak celu", "Tylko reklamy"], "correct": 0},
		{"question": "Co oznacza command and control w APT?", "answers": ["Kanal sterowania przejetymi systemami", "Panel legalnego backupu", "Baza z ikonami"], "correct": 0},
		{"question": "Dlaczego hunting jest wazny przy APT?", "answers": ["Szuka sladow, ktore nie wywolaly alertu", "Zastepuje logi", "Wylacza EDR"], "correct": 0},
		{"question": "Co ogranicza eskalacje uprawnien?", "answers": ["Least privilege i patchowanie", "Admin dla kazdego", "Brak MFA"], "correct": 0},
		{"question": "Co oznacza exfiltration?", "answers": ["Wyprowadzanie danych poza organizacje", "Aktualizacja systemu", "Zamkniecie portu"], "correct": 0},
		{"question": "Co jest dobra odpowiedzia na wykrycie persistence?", "answers": ["Izolacja, usuniecie persistence i rotacja sekretow", "Zostawic autostart", "Ukryc logi"], "correct": 0},
		{"question": "Dlaczego threat intelligence pomaga?", "answers": ["Laczy TTP z obserwowanymi zdarzeniami", "Daje wszystkim admina", "Kasuje podatnosci"], "correct": 0},
		{"question": "Co warto chronic przed APT szczegolnie mocno?", "answers": ["Konta uprzywilejowane i sekrety", "Tylko tapety", "Puste foldery"], "correct": 0},
		{"question": "Czym sa TTP?", "answers": ["Taktyki, techniki i procedury", "Trzy typy plikow", "Tryb testu pamieci"], "correct": 0},
		{"question": "Co pomaga po incydencie APT?", "answers": ["Lessons learned i wzmocnienie kontroli", "Brak dokumentacji", "Powrot do starych hasel"], "correct": 0}
	]
}

static var _unused_question_indices: Dictionary = {}
static var _last_correct_index_by_topic: Dictionary = {}

static func get_topic_label(topic: String) -> String:
	return str(TOPIC_LABELS.get(topic, TOPIC_LABELS[FALLBACK_TOPIC]))

static func get_random_question(topic: String, rng: RandomNumberGenerator) -> Dictionary:
	var resolved_topic: String = topic if QUESTIONS.has(topic) else FALLBACK_TOPIC
	var pool: Array = _get_question_pool(resolved_topic)
	if pool.is_empty():
		pool = _get_question_pool(FALLBACK_TOPIC)
	if pool.is_empty():
		return {"question": "Brak pytania.", "answers": ["Kontynuuj", "Pomin", "Zamknij"], "correct": 0}

	var unused: Array = (_unused_question_indices.get(resolved_topic, []) as Array).duplicate()
	for i in range(unused.size() - 1, -1, -1):
		if int(unused[i]) >= pool.size():
			unused.remove_at(i)
	if unused.is_empty():
		for i in range(pool.size()):
			unused.append(i)

	var unused_slot: int = rng.randi_range(0, unused.size() - 1)
	var question_index: int = int(unused[unused_slot])
	unused.remove_at(unused_slot)
	_unused_question_indices[resolved_topic] = unused

	var question: Dictionary = (pool[question_index] as Dictionary).duplicate(true)
	return _shuffle_answers(question, resolved_topic, rng)

static func _get_question_pool(topic: String) -> Array:
	var pool: Array = []
	if QUESTIONS.has(topic):
		var base_pool: Array = QUESTIONS[topic] as Array
		pool.append_array(base_pool)
	if EXTRA_QUESTIONS.has(topic):
		var extra_pool: Array = EXTRA_QUESTIONS[topic] as Array
		pool.append_array(extra_pool)
	return pool

static func _shuffle_answers(question: Dictionary, topic: String, rng: RandomNumberGenerator) -> Dictionary:
	var answers: Array = (question.get("answers", []) as Array).duplicate()
	var correct_index: int = int(question.get("correct", 0))
	if answers.size() <= 1:
		return question

	var entries: Array[Dictionary] = []
	for i in range(answers.size()):
		entries.append({"text": str(answers[i]), "is_correct": i == correct_index})

	for i in range(entries.size() - 1, 0, -1):
		var swap_index: int = rng.randi_range(0, i)
		var current_entry: Dictionary = entries[i]
		entries[i] = entries[swap_index]
		entries[swap_index] = current_entry

	var shuffled_answers: Array[String] = []
	var new_correct_index: int = 0
	for i in range(entries.size()):
		var entry: Dictionary = entries[i]
		shuffled_answers.append(str(entry["text"]))
		if bool(entry["is_correct"]):
			new_correct_index = i

	var forbidden_index: int = int(_last_correct_index_by_topic.get(topic, correct_index))
	if shuffled_answers.size() > 1 and new_correct_index == forbidden_index:
		var forced_swap_index: int = (new_correct_index + rng.randi_range(1, shuffled_answers.size() - 1)) % shuffled_answers.size()
		var forced_swap_text: String = shuffled_answers[new_correct_index]
		shuffled_answers[new_correct_index] = shuffled_answers[forced_swap_index]
		shuffled_answers[forced_swap_index] = forced_swap_text
		new_correct_index = forced_swap_index

	_last_correct_index_by_topic[topic] = new_correct_index
	question["answers"] = shuffled_answers
	question["correct"] = new_correct_index
	return question
