# AGENTS.md – Motodefend (Godot 4)

## Stack i wersje
- **Engine:** Godot 4.6 (GL Compatibility)
- **Język:** GDScript
- **Platforma docelowa:** Windows / Desktop
- **Input:** klawiatura (WASD / strzałki + E)

## Struktura projektu
```
scenes/           – sceny (.tscn): poziomy, postaci, UI
Scripts/          – logika (.gd) dla NPC, obiektów interaktywnych
Assets/           – grafiki, dźwięki, czcionki
menuScript.gd     – logika głównego menu
project.godot     – konfiguracja projektu i Input Map
```

## Konwencje nazewnictwa
- **Sceny:** `PascalCase.tscn` (np. `GameStartScreen.tscn`, `playerScene.tscn`)
- **Skrypty:** `snake_case.gd` (np. `player_scene.gd`, `shopkeeper.gd`)
- **Węzły w scenie:** `PascalCase` (np. `InteractionArea`, `CollisionShape2D`, `AnimatedSprite2D`)
- **Syngały:** `snake_case` w GDScript
- **Grupy:** `PascalCase` (np. `Interactable`)
- **Actions w Input Map:** `snake_case` (np. `walk_left`, `walk_up`, `interact`)

## Style guide GDScript
- Używaj **tabulatorów** do wcięć (tak jak w istniejących plikach).
- Każda klasa dziedziczy jawnie: `extends CharacterBody2D` / `extends Area2D` itp.
- Eksportowane zmienne używają `@export` z typem: `@export var speed: float = 150.0`.
- `@onready` dla referencji do węzłów-dzieci.
- Komentarze po polsku, jeśli projekt jest polskojęzyczny.
- Zawsze dodawaj typy do parametrów funkcji i zwracanych wartości, jeśli to możliwe.

## System interakcji (obowiązujący w całym projekcie)
1. **Gracz** ma `Area2D` o nazwie `InteractionArea`:
   - `collision_layer = 0`
   - `collision_mask = 2` (maska dla obiektów interaktywnych)
2. **Obiekty interaktywne** (NPC, automaty, drzwi) mają `Area2D` o nazwie `InteractArea`:
   - `collision_layer = 2`
   - `collision_mask = 0`
   - Dodane do grupy: `Interactable` (`add_to_group("Interactable")`)
3. **Klawisz interakcji:** `interact` (domyślnie **E**), zdefiniowany w `project.godot`.
4. **Prompt:** Gracz wyświetla `Label` `[E] Interakcja`, gdy `current_interactable != null`.
5. **Metoda interakcji:** Każdy obiekt interaktywny implementuje funkcję `interact()`.

## Tworzenie nowych obiektów interaktywnych
Kopiuj wzorzec z `shopkeeper.gd` / `cybersecurity_expert.gd`:
```gdscript
extends CharacterBody2D  # lub StaticBody2D / Node2D

@export var npc_name: String = "Nazwa Obiektu"

func _ready() -> void:
    $AnimatedSprite2D.play("default_animation")
    $InteractArea.add_to_group("Interactable")

func interact() -> void:
    print("Interakcja z: " + npc_name)
    # TODO: otwórz dialog / sklep / animację
```

## Warstwy kolizji ( Collision Layers )
- **Layer 1:** świat / teren (TileMap, ściany)
- **Layer 2:** obiekty interaktywne (InteractArea)
- Reszta do ustalenia w razie potrzeby.

## UI i teksty
- Interfejs gry jest po polsku.
- Używaj czytelnych czcionek (domyślnie systemowa lub załączona w `Assets/`).
- Prompt interakcji: `[E] Interakcja` (można zmienić na konkretną akcję, np. `[E] Rozmowa`).

## Agenci (OpenCode)
Projekt używa systemu **12 agentów** zdefiniowanych w `.opencode/`. Każdy agent ma wyspecjalizowaną rolę:

| Agent | Plik | Rola |
|-------|------|------|
| GAME_DESIGNER | `.opencode/game_designer.md` | Projekt mechanik, specyfikacje |
| GAME_PROGRAMMER | `.opencode/game_programmer.md` | GDScript, implementacja mechanik |
| UI_DESIGNER | `.opencode/ui_designer.md` | Interfejs, HUD, menu |
| SOUND_DESIGNER | `.opencode/sound_designer.md` | Audio, muzyka, SFX |
| LEVEL_DESIGNER | `.opencode/level_designer.md` | Poziomy, TileMap, NPC |
| STORYTELLER | `.opencode/storyteller.md` | Fabuła, dialogi, lore |
| DEBUGGER | `.opencode/debugger.md` | QA, testy, błędy |
| LIBRARIAN | `.opencode/librarian.md` | Dokumentacja w BRAIN |
| SECURITY_OFFICER | `.opencode/security_officer.md` | .env, .gitignore, tokeny |
| WATCHMAN | `.opencode/watchman.md` | Supervisor agentów |
| GIT_PUSHER | `.opencode/git_pusher.md` | Commity, push |
| BALANCER | `.opencode/balancer.md` | Balans statystyk, ekonomia |

**Zasady pracy:** Zobacz `.opencode/rules.md` – koordynator planuje, agenci wykonują równocześnie, LIBRARIAN dokumentuje w BRAIN.

## MCP (OpenCode)
Projekt korzysta z MCP. Konfiguracja serwerów MCP znajduje się w `.opencode/mcp.json` (lokalnie) lub w globalnych ustawieniach OpenCode.
Aktualnie skonfigurowany jest serwer **Context7** (dokumentacja Godot / API).

## Autoloady
- `GlobalVars` – globalne zmienne gry
- `GameData` – persystencja ustawień (ConfigFile) + dane gry
- `AudioManager` – zarządzanie dźwiękiem (Music, SFX, UI buses)

## Struktura Scripts/
```
Scripts/
  audio/
    audio_manager.gd     – AudioManager (autoload)
  combat/               – system walki
  dialogue/             – system dialogów
  enemies/              – AI przeciwników
  items/                – przedmioty, ekwipunek
  quests/               – system questów
  shop/                 – sklep
  ui/                   – skrypty UI (menu, ustawienia, HUD)
  game_data.gd          – GameData (autoload)
  balance_data.gd       – dane balansu (autoload, TODO)
```

## Debug i testowanie
- Uruchom scenę `GameStartScreen.tscn` jako główną dla testów gameplay.
- Sprawdzaj output w panelu **Output** Godot (szczególnie `print()` z `interact()`).
- Upewnij się, że `InteractArea` obiektu i `InteractionArea` gracza nachodzą na siebie fizycznie.
- Plany rozwoju w `plan.md`.

---
*Ostatnia aktualizacja: 2026-05-07*
