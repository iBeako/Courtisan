extends Node

class_name Global

const MAX_CLIENT:int = 2 # 2, 3, 4, 5

# for tests
const LOOP_COUNT = 10 # 10, 8, 7, 6 (according client count)

const card_type_numbers = [4, 2, 2, 3, 4] # [idle, assassin, spy, guard, noble]

enum PlayZoneType {PLAYER, ENEMY, FAVOR, DISFAVOR}
const play_zone_type = ["player's domain", "enemy's domain", "queen's table in the light", "queen's table out of favor"]

enum CardType {NORMAL=0, NOBLE, SPY, GUARD, ASSASSIN}
const card_types = ["normal", "assassin", "spy", "guard", "noble"]

enum Family {BUTTERFLY=0, FROG, BIRD, BUNNY, DEER, FISH}
const families = ["Papillons", "Crapauds", "Rossignols", "Lièvres", "Cerfs", "Carpes"]

const white_missions = [
    "Vous devez posseder au moins 2 assassins",
    "Vous devez posseder au moins 3 nobles",
    "Vous devez posseder au moins 3 espions",
    "Vous devez posseder au moins 4 gardes",
    
    "Vous devez posseder moins de carpes que votre voision de gauche",
    "Vous devez posseder moins de crapauds que votre voision de gauche",
    "Vous devez posseder moins de cerfs que votre voision de gauche",
    "Vous devez posseder moins de rossignols que votre voision de gauche",
    "Vous devez posseder moins de papillons que votre voision de gauche",
    "Vous devez posseder moins de lièvres que votre voision de gauche",
]

const blue_missions = [
    "Les lièvres doivent être en disgrâce à la cours",
    "Les crapauds doivent être en disgrâce à la cours",
    "Les cerfs doivent être en disgrâce à la cours",
    "Les carpes doivent être en disgrâce à la cours",
    "Les papillons doivent être en disgrâce à la cours",
    "Les rossignols doivent être en disgrâce à la cours",

    "3 familles, au maximum, doivent être dans la lumière à la cours",
    "Une famille doit avoir au moins 5 cartes au-dessous du tapis de jeu",
    "Au moins 2 familles, doivent être en disgrace à la cours",
    "Au moins 1 cartes de chaque famille doit être au-dessous du tapis de jeu",
]
