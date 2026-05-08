# OpenCode Rules – Motodefend (Godot 4.6)

## Zasada #0: Koordynator tylko deleguje

Koordynator (Project Manager) NIGDY sam nie pisze kodu, nie edytuje plików .gd, .tscn, nie tworzy assetów. Koordynator wyłącznie:
- Analizuje wymagania i planuje
- Deleguje zadania do wyspecjalizowanych agentów poprzez Task tool
- Weryfikuje wyniki pracy agentów
- Integruje rezultaty w spójną całość

Cała praca wykonawcza (kodowanie, UI, audio, testy, dokumentacja) jest wykonywana wyłącznie przez agentów.

## Zasada #1: Koordynator planuje, agenci wykonują

Koordynator (ja) NIE pisze kodu, NIE edytuje scen, NIE tworzy assetów. Koordynator:
- Analizuje potrzeby projektu
- Tworzy plan w `plan.md`
- Przydziela zadania agentom
- Uruchamia agentów **równocześnie** (zadania nieblokujące się)
- Sprawdza wyniki i logi

Agenci wykonują CAŁĄ robotę: GAME_PROGRAMMER pisze skrypty, UI_DESIGNER tworzy menu, SOUND_DESIGNER dodaje audio, itd.

## Zasada #2: Zawsze równolegle

Zadania niezależne zawsze uruchamiane są jednocześnie. Przykład:
- **Równolegle:** UI_DESIGNER robi nowe menu + GAME_PROGRAMMER implementuje nową mechanikę + STORYTELLER pisze dialogi
- **Sekwencyjnie:** dopiero po nich DEBUGGER testuje, a LIBRARIAN dokumentuje

Agenci nie blokują się nawzajem, bo pracują na różnych plikach:
- UI_DESIGNER → `scenes/*Settings*.tscn`, `Scripts/ui/`
- GAME_PROGRAMMER → `Scripts/`, `scenes/player_*.gd`
- SOUND_DESIGNER → `Scripts/audio/`, AudioBus w `project.godot`
- LEVEL_DESIGNER → `scenes/levels/`, TileMap
- STORYTELLER → `Scripts/dialogues/`, `Assets/Dialogue/`
- BALANCER → `Scripts/balance_data.gd`

## Zasada #3: LIBRARIAN dokumentuje wszystko

Po KAŻDEJ akcji agenta, LIBRARIAN:
- Aktualizuje `C:\Users\kubar\OneDrive\Dokumenty\BRAIN\01_Projects\Motodefend\Project_Log.md`
- Tworzy wpisy FEATURE_, BUG_, ADR_ w odpowiednich folderach
- Synchronizuje mirrory kodu w `01_Projects/Motodefend/Code/`

## Zasada #4: WATCHMAN pilnuje

WATCHMAN monitoruje wszystkich agentów. Gdy agent napotka błąd:
- Loguje do `watchman.log`
- Pipeline nie przerywa się dla innych agentów
- Jeśli 20%+ zadań zwraca błędy → wstrzymanie i alert

## Zasada #5: SECURITY_OFFICER pierwszy

Przed każdą sesją: walidacja `.gitignore`, tokenów API, brak wycieków. Nigdy nie pomijamy.

## Zasada #6: GIT_PUSHER tylko po testach

Commit i push tylko po:
1. Zgodzie SECURITY_OFFICER (brak wycieków)
2. Testach DEBUGGER (BUILD SUCCESSFUL)

## Zasada #7: GIT_PUSHER na koniec każdej tury

Po każdej zakończonej turze pracy (wszystkie taski ukończone), GIT_PUSHER robi commit ze wszystkimi zmianami. Nigdy nie pomijaj tego kroku.

Zasady commitów:
- **Commit message w języku polskim.**
- Format: `typ(kategoria): krótki opis`
- Przykłady:
  - `feat(ui): dodano suwaki głośności`
  - `fix(settings): naprawiono null reference`
  - `docs(brain): udokumentowano BUG_001`
- **Jeśli nie ma żadnych zmian do zakomitowania, poinformuj o tym użytkownika** (nie commituj pustego zestawu zmian).

**⚠️ PRZYPOMNIENIE: GIT_PUSHER JEST OBOWIĄZKOWY. Po każdej turze pracy (wszystkie taski ukończone), GIT_PUSHER robi commit. NIGDY nie pomijaj tego kroku. Jeśli nie ma GIT_PUSHERA w danej turze – koordynator sam go uruchamia jako ostatniego agenta.**

## Zasada #8: MCP Context7 jako główne źródło wiedzy Godot

Każdy agent programistyczny (GAME_PROGRAMMER, UI_DESIGNER, LEVEL_DESIGNER, SOUND_DESIGNER, DEBUGGER, BALANCER) MUSI:
1. Korzystać z podłączonego serwera MCP **Context7** jako głównego źródła dokumentacji Godot API
2. Przed implementacją nowej funkcji sprawdzić dokumentację Godot 4.6 przez Context7
3. Nie zgadywać API – zawsze weryfikować przez Context7
4. Projekt ma skonfigurowany MCP Context7 w `.opencode/mcp.json`

## Zasada #9: BRAIN jako drugi mózg projektu

1. Wszyscy agenci mają dostęp do vaultu Obsidian BRAIN: `C:\Users\kubar\OneDrive\Dokumenty\BRAIN`
2. Struktura Motodefend w BRAIN: `01_Projects/Motodefend/` z podfolderami:
   - `Design/` – dokumenty projektowe (GAME_DESIGNER)
   - `Features/` – dokumentacja funkcji (prefix FEATURE_)
   - `Bugs/` – raporty błędów (prefix BUG_)
   - `Decisions/` – decyzje architektoniczne (prefix ADR_)
   - `Characters/` – profile postaci (STORYTELLER)
   - `Code/` – analiza plików źródłowych
   - `Project_Log.md` – dziennik zmian
3. LIBRARIAN aktualizuje BRAIN po każdej zmianie
4. Każdy agent przed rozpoczęciem pracy sprawdza BRAIN czy podobny problem nie był już rozwiązany
5. Wszystkie nowe decyzje projektowe muszą być zapisane jako ADR w BRAIN
6. BRAIN używa formatu Obsidian: YAML frontmatter + ## nagłówki + WikiLinks [[nazwa_pliku]]

## Zasada #10: Skill Agentów z skills.sh

Agenci mają przypisane specjalistyczne skille z repozytoriów skills.sh (głównie `LoogacyStudio/skills`). Skille te dostarczają wzorce implementacyjne i najlepsze praktyki:

- **GAME_PROGRAMMER**: godot-tscn, runtime-triage, scene-architecture-review, abstraction-integrity-review, post-change-review, game-development-behavior-architecture, game-development-behavior-tree, game-development-command-flow, game-development-condition-rule-engine, game-development-coordinator, game-development-entity-reference-boundary, game-development-events-and-signals, game-development-fsm, game-development-gameplay-tags-and-query, game-development-object-pool, game-development-resource-transaction-system, game-development-state-change-notification, game-development-time-source-and-tick-policy, game-development-goap, game-development-utility-ai, game-development-world-state-facts
- **UI_DESIGNER**: godot-tscn, ui-ux-review, scene-architecture-review, game-development-events-and-signals
- **GAME_DESIGNER**: game-development-behavior-architecture, game-development-condition-rule-engine, ui-ux-review, test-strategy-review
- **SOUND_DESIGNER**: super-gaming-3d-media
- **LEVEL_DESIGNER**: godot-tscn, scene-architecture-review, game-development-object-pool
- **STORYTELLER**: super-gaming-3d-media
- **BALANCER**: game-development-resource-transaction-system, game-development-condition-rule-engine, game-development-world-state-facts
- **DEBUGGER**: runtime-triage, godot-headless, test-strategy-review, version-upgrade-review
- **LIBRARIAN**: post-change-review
- **SECURITY_OFFICER**: runtime-triage
- **WATCHMAN**: runtime-triage
- **GIT_PUSHER**: version-upgrade-review

Źródła skilli:
- `LoogacyStudio/skills` (godot-dotnet + game-development pluginy) – 26 skilli
- `biologicpro/godot_codex_skills` – godot-headless
- `arpitexplores/super-gaming-3d-media` – super-gaming-3d-media

## Zasada #11: Komunikacja międzyokienkowa przez BRAIN (Obsidian)

Projekt używa **4 okienek OpenCode** pracujących równolegle. Komunikacja odbywa się przez wspólny vault BRAIN:

### Struktura okienek
| Okno | Rola | Domeny |
|------|------|--------|
| **Okno 1** | GŁÓWNY KOORDYNATOR | Strategia, podział zadań, integracja wyników |
| **Okno 2** | PLANNER ALPHA | UI, Sceny, Design, Dialogi, Fabuła, Grafika |
| **Okno 3** | PLANNER BETA | GDScript, Mechaniki, Walka, NPC, Sklep, Wave Manager |
| **Okno 4** | PLANNER GAMMA | Testy, QA, Dokumentacja, Audio, Balans, Security, Git |

### Protokół komunikacji
1. **GŁÓWNY KOORDYNATOR (Okno 1)** wpisuje zadania do plików:
   - `C:\Users\kubar\OneDrive\Dokumenty\BRAIN\01_Projects\Motodefend\Comms\Planner_Alpha_Tasks.md`
   - `C:\Users\kubar\OneDrive\Dokumenty\BRAIN\01_Projects\Motodefend\Comms\Planner_Beta_Tasks.md`
   - `C:\Users\kubar\OneDrive\Dokumenty\BRAIN\01_Projects\Motodefend\Comms\Planner_Gamma_Tasks.md`

2. **MINI-PLANNER (Okna 2-4)** co 30 sekund sprawdza swój plik `_Tasks`:
   - Czyta plik → wykonuje zadania → deleguje do agentów
   - Po wykonaniu wpisuje wyniki do pliku `_Results`

3. **GŁÓWNY KOORDYNATOR** sprawdza pliki wyników:
   - `Planner_Alpha_Results.md`
   - `Planner_Beta_Results.md`
   - `Planner_Gamma_Results.md`

4. Wszystkie rozmowy zapisywane w `Comms\Conversation_Log.md`

5. Tablica główna: `Comms\Coordinator_Board.md`

### Zasady dla Mini-Plannerów
- Każdy mini-planner **tylko deleguje** do agentów wykonawczych
- Nie pisze kodu samodzielnie
- Korzysta z Context7 MCP i BRAIN
- Raportuje wyniki natychmiast po ukończeniu
- W przypadku błędu – wpisuje do `_Results` z tagiem `BLOKER`

## Zasada #12: Pełna transparentność – rozmowy i planowanie widoczne

1. **Wszystkie rozmowy między okienkami** (Główny Koordynator ↔ Mini-Plannery) muszą być zapisywane w `Comms\Conversation_Log.md` w BRAIN.

2. **Każdy Mini-Planner** przed rozpoczęciem pracy wpisuje do `_Results` swój SZCZEGÓŁOWY PLAN:
   - Którego agenta deleguje
   - Jakie pliki będą modyfikowane
   - Szacowany czas wykonania
   - Potencjalne ryzyka

3. **Po wykonaniu zadania** Mini-Planner wpisuje do `_Results`:
   - Co dokładnie zrobił
   - Które pliki zmodyfikował (pełne ścieżki)
   - Czy wystąpiły błędy
   - Status: ✅ Sukces / ⚠️ Częściowy / ❌ Błąd

4. **Główny Koordynator** po każdej turze aktualizuje `Coordinator_Board.md`:
   - Podsumowanie tury
   - Co zostało zrobione
   - Co pozostało
   - Nowa kolejka zadań

5. **Conversation_Log.md** zawiera pełną historię wszystkich decyzji, delegacji i wyników – jest to "czarna skrzynka" projektu.

6. **Użytkownik (kubar) musi widzieć** co się dzieje w każdym oknie – dlatego wszystkie pliki Comms są w formacie czytelnym dla człowieka (tabele, listy, znaczniki statusu).

## Podsumowanie workflow

```
1. GŁÓWNY KOORDYNATOR (Okno 1) tworzy/aktualizuje plan (plan.md)
2. GŁÓWNY KOORDYNATOR rozdziela zadania do Plannerów Alpha/Beta/Gamma przez BRAIN Comms/
3. SECURITY_OFFICER robi boot check
4. Równoległa praca 3 mini-plannerów (Okna 2-4):
   ├── PLANNER ALPHA → deleguje do UI_DESIGNER, STORYTELLER, GAME_DESIGNER
   ├── PLANNER BETA → deleguje do GAME_PROGRAMMER, LEVEL_DESIGNER, BALANCER
   └── PLANNER GAMMA → deleguje do DEBUGGER, LIBRARIAN, SOUND_DESIGNER, SECURITY_OFFICER
5. DEBUGGER testuje wszystkie zmiany (korzysta z Context7 MCP)
6. LIBRARIAN dokumentuje w BRAIN (Obsidian vault)
7. GIT_PUSHER commituje i wypycha (⚠️ ZAWSZE, OBOWIĄZKOWO, na koniec każdej tury)
8. WATCHMAN monitoruje cały proces
9. GŁÓWNY KOORDYNATOR – tylko deleguje i weryfikuje, nigdy nie pisze kodu
```

## Agenci i ich pliki

| Agent | Plik | Skille |
|-------|------|--------|
| GAME_DESIGNER | `.opencode/game_designer.md` | behavior-architecture, condition-rule-engine, ui-ux-review, test-strategy-review |
| GAME_PROGRAMMER | `.opencode/game_programmer.md` | godot-tscn, runtime-triage, scene-architecture-review, game-development-* (21 skilli) |
| UI_DESIGNER | `.opencode/ui_designer.md` | godot-tscn, ui-ux-review, scene-architecture-review, events-and-signals |
| SOUND_DESIGNER | `.opencode/sound_designer.md` | super-gaming-3d-media |
| LEVEL_DESIGNER | `.opencode/level_designer.md` | godot-tscn, scene-architecture-review, object-pool |
| STORYTELLER | `.opencode/storyteller.md` | super-gaming-3d-media |
| DEBUGGER | `.opencode/debugger.md` | runtime-triage, godot-headless, test-strategy-review, version-upgrade-review |
| LIBRARIAN | `.opencode/librarian.md` | post-change-review |
| SECURITY_OFFICER | `.opencode/security_officer.md` | runtime-triage |
| WATCHMAN | `.opencode/watchman.md` | runtime-triage |
| GIT_PUSHER | `.opencode/git_pusher.md` | version-upgrade-review |
| BALANCER | `.opencode/balancer.md` | resource-transaction-system, condition-rule-engine, world-state-facts |
