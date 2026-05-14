extends Node
## Scentralizowane dane balansu – wartości numeryczne dla całej gry

# ============ WEAPON BALANCE ============
# Wartości zsynchronizowane z weapon_items.gd

# OldRadio – fala uderzeniowa (AOE)
const OLDRADIO_DAMAGE: float = 45.0
const OLDRADIO_ATTACK_SPEED: float = 1.6
const OLDRADIO_RANGE: float = 150.0
const OLDRADIO_COST: int = 90
# DPS: 28.1 | Typ: obszarowy

# NewRadio – potężna fala uderzeniowa (AOE)
const NEWRADIO_DAMAGE: float = 80.0
const NEWRADIO_ATTACK_SPEED: float = 1.2
const NEWRADIO_RANGE: float = 320.0
const NEWRADIO_COST: int = 250
# DPS: 66.7 | Typ: obszarowy

# OldDrone – automatyczny dron
const OLDDRONE_DAMAGE: float = 30.0
const OLDDRONE_ATTACK_SPEED: float = 1.2
const OLDDRONE_RANGE: float = 300.0
const OLDDRONE_COST: int = 100
# DPS: 25.0 | Typ: pasywny

# FightingDrone – dron bojowy
const FIGHTINGDRONE_DAMAGE: float = 55.0
const FIGHTINGDRONE_ATTACK_SPEED: float = 0.8
const FIGHTINGDRONE_RANGE: float = 500.0
const FIGHTINGDRONE_COST: int = 300
# DPS: 68.8 | Typ: pasywny

# Blaster – pociski energetyczne (szybkostrzelny)
const BLASTER_DAMAGE: float = 120.0
const BLASTER_ATTACK_SPEED: float = 0.25
const BLASTER_RANGE: float = 500.0
const BLASTER_COST: int = 200
# DPS: 480.0 | Typ: dystansowy

# Sword – atak w zwarciu
const SWORD_DAMAGE: float = 75.0
const SWORD_ATTACK_SPEED: float = 0.7
const SWORD_RANGE: float = 260.0
const SWORD_COST: int = 100
# DPS: 107.1 | Typ: wręcz

# ============ GAME BALANCE ============

const STARTING_GOLD: int = 100
const REROLL_COST: int = 25
const WAVE_GOLD_REWARD: int = 10
const MAX_WEAPON_SLOTS: int = 2
const BASE_PLAYER_HP: int = 10
const HP_PER_WAVE: int = 9
