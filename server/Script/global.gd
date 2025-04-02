extends Node

class_name Global

const MAX_CLIENT:int = 2 # 2, 3, 4, 5

# for tests
const LOOP_COUNT = 10 # 10, 8, 7, 6 (according client count)

const card_type_numbers = [4, 2, 2, 3, 4] # [idle, assassin, spy, guard, noble]

enum PlayZoneType {PLAYER, ENEMY, FAVOR, DISFAVOR}
const play_zone_type = ["player's domain", "enemy's domain", "queen's table in the light", "queen's table out of favor"]

enum CardType {NORMAL=0, ASSASSIN, SPY, GUARD, NOBLE}
const card_types = ["normal", "assassin", "spy", "guard", "noble"]

enum Family {BUTTERFLY=0, FROG, BIRD, BUNNY, DEER, FISH}
const families = ["Papillons", "Crapauds", "Rossignols", "Lièvres", "Cerfs", "Carpes"]
