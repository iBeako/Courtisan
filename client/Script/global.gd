extends Node

const MAX_CLIENT:int = 5 # 2, 3, 4, 5

# for tests
const LOOP_COUNT = 6 # 10, 8, 7, 6 (according client count)

var card_type_numbers = [4, 4, 2, 2, 3] # [idle, noble, spy, guard, assassin]

enum PlayZoneType {PLAYER, ENEMY, FAVOR, DISFAVOR}
var play_zone_type = ["player's domain", "enemy's domain", "queen's table in the light", "queen's table out of favor"]

enum CardType {NORMAL=0, NOBLE, SPY, GUARD, ASSASSIN}
var card_types = ["normal", "noble", "spy", "guard", "assassin"]

enum Family {BUTTERFLY=0, FROG, BIRD, BUNNY, DEER, FISH}
var families = ["Papillons", "Crapauds", "Rossignols", "Lièvres", "Cerfs", "Carpes"]
