extends Node
## Scentralizowane dane balansu – wartości numeryczne dla całej gry

# ============ WEAPON BALANCE ============
# Wartości zsynchronizowane z weapon_items.gd

# OldRadio – fala uderzeniowa (AOE)
const OLDRADIO_DAMAGE: float = 12.0
const OLDRADIO_ATTACK_SPEED: float = 3.0
const OLDRADIO_RANGE: float = 150.0
const OLDRADIO_COST: int = 90
# DPS: 4.0 | Typ: obszarowy

# NewRadio – potężna fala uderzeniowa (AOE)
const NEWRADIO_DAMAGE: float = 20.0
const NEWRADIO_ATTACK_SPEED: float = 2.0
const NEWRADIO_RANGE: float = 250.0
const NEWRADIO_COST: int = 250
# DPS: 10.0 | Typ: obszarowy

# OldDrone – automatyczny dron
const OLDDRONE_DAMAGE: float = 8.0
const OLDDRONE_ATTACK_SPEED: float = 2.0
const OLDDRONE_RANGE: float = 300.0
const OLDDRONE_COST: int = 100
# DPS: 4.0 | Typ: pasywny

# FightingDrone – dron bojowy
const FIGHTINGDRONE_DAMAGE: float = 12.0
const FIGHTINGDRONE_ATTACK_SPEED: float = 1.2
const FIGHTINGDRONE_RANGE: float = 400.0
const FIGHTINGDRONE_COST: int = 300
# DPS: 10.0 | Typ: pasywny

# Blaster – pociski energetyczne
const BLASTER_DAMAGE: float = 15.0
const BLASTER_ATTACK_SPEED: float = 1.5
const BLASTER_RANGE: float = 350.0
const BLASTER_COST: int = 200
# DPS: 10.0 | Typ: dystansowy

# Sword – atak w zwarciu
const SWORD_DAMAGE: float = 12.0
const SWORD_ATTACK_SPEED: float = 2.0
const SWORD_RANGE: float = 80.0
const SWORD_COST: int = 100
# DPS: 6.0 | Typ: wręcz

# ============ GAME BALANCE ============

const STARTING_GOLD: int = 100
const REROLL_COST: int = 25
const WAVE_GOLD_REWARD: int = 10
const MAX_WEAPON_SLOTS: int = 2
const BASE_PLAYER_HP: int = 10
const HP_PER_WAVE: int = 9
