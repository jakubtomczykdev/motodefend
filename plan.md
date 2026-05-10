# plan.md — Motodefend: Plan Rozwoju Gry

> **Projekt:** Motodefend (Godot 4.6, GL Compatibility)  
> **Data rozpoczęcia:** 2026-05-07  
> **Vault BRAIN:** `C:\Users\kubar\OneDrive\Dokumenty\BRAIN\01_Projects\Motodefend\`

---

## Stan obecny (v0.1)

| Element | Status |
|---------|--------|
| Główne menu (MainMenu.tscn) | ✅ Działa |
| Ekran ustawień (Settings.tscn) | ⚠️ Podstawowy – tylko 3 puste przyciski (Grafika, Muzyka, Sterowanie) |
| Ustawienia grafiki (GraphicsSettings.tscn) | ❌ Prawie pusty – tylko nagłówek |
| System interakcji | ✅ Działa (NPC: shopkeeper, cybersecurity_expert) |
| Gracz (playerScene.tscn) | ✅ Podstawowy ruch WASD + animacje |
| Świat gry (World.tscn) | ⚠️ Podstawowy TileMap |
| Audio | ❌ Brak |
| System zapisu ustawień | ❌ Brak |
| System walki | ❌ Brak |
| System dialogów | ❌ Brak |

---

## Faza 1 – Fundamenty UI (PRIORYTET: TERAZ)

### 1.1 Rozbudowany Ekran Ustawień
**Agent:** UI_DESIGNER + GAME_PROGRAMMER  
**Pliki:** `scenes/Settings.tscn`, `Scripts/ui/settings_menu.gd`

- [ ] Dodanie slidera głośności Master
- [ ] Dodanie slidera głośności Muzyki
- [ ] Dodanie slidera głośności SFX
- [ ] Dropdown rozdzielczości ekranu (1920x1080, 1600x900, 1366x768, 1280x720)
- [ ] Checkbox pełnego ekranu (Window Mode / Fullscreen)
- [ ] Checkbox V-Sync
- [ ] Przycisk "Zastosuj" i "Przywróć domyślne"
- [ ] Zapis do ConfigFile (persystencja)

### 1.2 AudioManager (Autoload)
**Agent:** SOUND_DESIGNER  
**Pliki:** `Scripts/audio/audio_manager.gd`

- [ ] Autoload `AudioManager` z bus Master, Music, SFX, UI
- [ ] Metody: `play_music(track)`, `play_sfx(sound)`, `set_volume(bus, value)`
- [ ] Przechowywanie ustawień głośności w ConfigFile
- [ ] Fade-in / fade-out muzyki

### 1.3 Global GameData (Autoload)
**Agent:** GAME_PROGRAMMER  
**Pliki:** `Scripts/game_data.gd`

- [ ] Autoload `GameData` z globalnymi stałymi i configiem
- [ ] Przechowuje: rozdzielczość, fullscreen, vsync, volumes
- [ ] Metody zapisu/odczytu `save_settings()`, `load_settings()`

### 1.4 Ekran Grafiki – Uzupełnienie
**Agent:** UI_DESIGNER  
**Pliki:** `scenes/GraphicsSettings.tscn`, `Scripts/ui/graphics_settings.gd`

- [ ] Dropdown jakości grafiki: Niska / Średnia / Wysoka
- [ ] Checkbox: Efekty cząsteczkowe (particles)
- [ ] Checkbox: Cienie (shadows)
- [ ] Checkbox: Screen shake
- [ ] Podgląd zmian (preview FPS?)

### 1.5 Ekran Sterowania
**Agent:** UI_DESIGNER + GAME_PROGRAMMER  
**Pliki:** `scenes/ControlsSettings.tscn`, `Scripts/ui/controls_settings.gd`

- [ ] Nowa scena "Sterowanie"
- [ ] Wyświetlenie aktualnych klawiszy (odczyt z Input Map)
- [ ] Możliwość rebindowania klawiszy (kliknij → naciśnij nowy klawisz)
- [ ] Presety: WASD, Strzałki
- [ ] Przywróć domyślne

---

## Faza 2 – System Walki

### 2.1 System Obrażeń i HP
**Agent:** GAME_PROGRAMMER + BALANCER  
**Pliki:** `Scripts/combat/health.gd`, `Scripts/combat/damage.gd`

- [ ] Komponent `Health` (Node, attachable): hp, max_hp, is_dead, take_damage(), heal()
- [ ] Komponent `DamageDealer` (Node): damage, knockback, attack_range
- [ ] Sygnały: `died`, `damage_taken`, `healed`
- [ ] HealthBar nad przeciwnikami (ProgressBar)

### 2.2 Gracz – Strzelanie
**Agent:** GAME_PROGRAMMER  
**Pliki:** `scenes/player_scene.gd` (rozszerzenie), `Scripts/combat/projectile.gd`

- [ ] Kliknięcie LPM → strzał pocisku w kierunku myszy
- [ ] Pocisk: prędkość, obrażenia, zasięg, penetracja
- [ ] Cooldown między strzałami (attack_speed)
- [ ] Amunicja? (do ustalenia z GAME_DESIGNER)

### 2.3 Przeciwnicy – Podstawowy AI
**Agent:** GAME_PROGRAMMER  
**Pliki:** `Scripts/enemies/enemy_base.gd`, `Scripts/enemies/chaser.gd`

- [ ] `EnemyBase`: rozszerza CharacterBody2D, ma Health + DamageDealer
- [ ] `Chaser`: goni gracza gdy w zasięgu, atakuje w kontakcie
- [ ] `Shooter`: strzela w gracza z dystansu, utrzymuje odległość
- [ ] Patrol: porusza się między waypointami gdy gracz daleko

---

## Faza 3 – System Dialogów i Questów

### 3.1 Dialog System
**Agent:** GAME_PROGRAMMER + STORYTELLER  
**Pliki:** `Scripts/dialogue/dialogue_manager.gd`, `Scripts/dialogue/dialogue_box.gd`

- [ ] `DialogueManager` (Node): przyjmuje DialogueResource, wyświetla tekst + opcje
- [ ] `DialogueBox`: UI panel z tekstem NPC, awatarem, przyciskami wyboru
- [ ] Import dialogów z JSON/Resource

### 3.2 Quest System
**Agent:** GAME_PROGRAMMER  
**Pliki:** `Scripts/quests/quest_manager.gd`, `Scripts/quests/quest.gd`

- [ ] `QuestManager` (Autoload): śledzi aktywne questy
- [ ] Quest: nazwa, opis, cele (kill X, collect Y, talk to Z), nagroda
- [ ] Quest log w UI (dostępny z HUD)
- [ ] Trigger questowy: `interact()` z NPC może dać questa

---

## Faza 4 – Sklep i Ekonomia

### 4.1 System Sklepu
**Agent:** UI_DESIGNER + GAME_PROGRAMMER  
**Pliki:** `Scripts/shop/shop_manager.gd`, `Scripts/ui/shop_ui.gd`, `scenes/ShopUI.tscn`

- [ ] `ShopManager` (Node): lista itemów na sprzedaż, ceny
- [ ] `ShopUI`: panel z siatką itemów, opisem, przyciskiem kupna
- [ ] Waluta: gold (zdobywany z przeciwników)

### 4.2 Przedmioty i Ekwipunek
**Agent:** GAME_PROGRAMMER  
**Pliki:** `Scripts/items/item.gd`, `Scripts/items/inventory.gd`

- [ ] `Item` (Resource): nazwa, opis, typ (broń, pancerz, consumable), efekty
- [ ] `Inventory` (Node na graczu): slots, add_item(), remove_item(), use_item()
- [ ] UI ekwipunku (osobny ekran)

---

## Faza 5 – Poziomy i Świat

### 5.1 Wiele Poziomów
**Agent:** LEVEL_DESIGNER  
**Pliki:** `scenes/levels/Level_01.tscn`, `Level_02.tscn`, itd.

- [ ] Level_01: Hub / Miasto (NPC, sklep, bezpieczna strefa)
- [ ] Level_02: Strefa przemysłowa (wrogowie, itemy)
- [ ] Level_03: Kryjówka bossa

### 5.2 System Fal (Wave System)
**Agent:** GAME_PROGRAMMER  
**Pliki:** `Scripts/combat/wave_manager.gd`

- [ ] Spawnowanie fal przeciwników
- [ ] Eskalacja trudności z czasem
- [ ] Przerwy między falami (sklep? heal?)

---

## Faza 6 – Polerowanie i Release

### 6.1 Audio – dźwięki i muzyka
**Agent:** SOUND_DESIGNER  
- [ ] Muzyka tła dla każdego poziomu
- [ ] SFX: strzały, kroki, eksplozje, interakcje UI, śmierć
- [ ] Ambience (wiatr, maszyny)

### 6.2 Efekty wizualne
**Agent:** GAME_PROGRAMMER + UI_DESIGNER  
- [ ] Efekty cząsteczkowe: strzały, eksplozje, heal
- [ ] Screen shake na obrażenia
- [ ] Flash na trafienie

### 6.3 Ekrany: Pauza, Game Over, Victory
**Agent:** UI_DESIGNER  
- [ ] PauseMenu: Kontynuuj, Ustawienia, Wyjdź do menu
- [ ] GameOver: statystyki, przycisk restartu
- [ ] Victory: czas, wynik, statystyki

### 6.4 Export i build
**Agent:** GAME_PROGRAMMER  
- [ ] Eksport Windows .exe
- [ ] Test na czystym systemie

---

## Proponowane dodatkowe funkcje (kolejność do ustalenia)

| Funkcja | Priorytet | Agent |
|---------|-----------|-------|
| System zapisu stanu gry (save/load) | Wysoki | GAME_PROGRAMMER |
| Minimapa w rogu ekranu | Średni | UI_DESIGNER |
| Osiągnięcia / Achievementy | Niski | GAME_PROGRAMMER |
| System dnia i nocy (shader) | Niski | GAME_PROGRAMMER |
| Multiplayer lokalny (split-screen) | Bardzo niski | GAME_PROGRAMMER |
| Tablica wyników (leaderboard) | Niski | GAME_PROGRAMMER |
| Tryb fotograficzny | Niski | UI_DESIGNER |
| Integracja z gamepad (już częściowo w InputMap) | Średni | GAME_PROGRAMMER |
| Tryb survival (nieskończone fale) | Średni | GAME_DESIGNER |
| Samouczek / Tutorial | Wysoki | STORYTELLER + LEVEL_DESIGNER |

---

## Metryki sukcesu (cele)

- [ ] 3 grywalne poziomy
- [ ] Minimum 3 typy przeciwników
- [ ] Minimum 5 broni / itemów w sklepie
- [ ] Minimum 2 questy
- [ ] W pełni działający system ustawień (audio, grafika, sterowanie)
- [ ] Stabilne 60 FPS na średnim PC
- [ ] Brak crashy w standardowym przejściu

---

*Plan aktualizowany przez koordynatora. Zadania z `[ ]` są do zrobienia, `[x]` zrobione.*
