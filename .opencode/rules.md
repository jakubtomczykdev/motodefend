# OpenCode Rules – Motodefend (Godot 4.6)

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

## Podsumowanie workflow

```
1. Koordynator tworzy plan (plan.md)
2. SECURITY_OFFICER robi boot check
3. Równoległa faza agentów:
   ├── GAME_PROGRAMMER → implementuje skrypty .gd
   ├── UI_DESIGNER → tworzy sceny UI .tscn
   ├── SOUND_DESIGNER → dodaje audio
   ├── STORYTELLER → pisze dialogi
   ├── LEVEL_DESIGNER → buduje poziomy
   └── BALANCER → aktualizuje statystyki
4. DEBUGGER testuje wszystkie zmiany
5. LIBRARIAN dokumentuje w BRAIN
6. GIT_PUSHER commituje i wypycha (zawsze, obowiązkowo)
7. WATCHMAN monitoruje cały proces
```

## Agenci i ich pliki

| Agent | Plik |
|-------|------|
| GAME_DESIGNER | `.opencode/game_designer.md` |
| GAME_PROGRAMMER | `.opencode/game_programmer.md` |
| UI_DESIGNER | `.opencode/ui_designer.md` |
| SOUND_DESIGNER | `.opencode/sound_designer.md` |
| LEVEL_DESIGNER | `.opencode/level_designer.md` |
| STORYTELLER | `.opencode/storyteller.md` |
| DEBUGGER | `.opencode/debugger.md` |
| LIBRARIAN | `.opencode/librarian.md` |
| SECURITY_OFFICER | `.opencode/security_officer.md` |
| WATCHMAN | `.opencode/watchman.md` |
| GIT_PUSHER | `.opencode/git_pusher.md` |
| BALANCER | `.opencode/balancer.md` |
