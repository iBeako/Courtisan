extends Node
class_name Mission

var player_white_missions = []
var player_blue_missions = []

enum Mission_type { WHITE = 0, BLUE }


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

var global = preload("res://Script/global.gd").new()

func _get_rand_missions() -> Array:
	var id_white_mission = randi() % white_missions.size()
	while player_white_missions.find(id_white_mission) != -1 :
		id_white_mission = randi() % white_missions.size()
	player_white_missions.append(id_white_mission)
	
	var id_blue_mission = randi() % blue_missions.size()
	while player_blue_missions.find(id_blue_mission) != -1 :
		id_blue_mission = randi() % blue_missions.size()
	player_blue_missions.append(id_blue_mission)

	return [id_white_mission, id_blue_mission]

func _get_mission_points(id_player: int, mission_type: Mission_type, id_mission: int, id_session : int) -> int :
	var mission_type_str = ""
	if mission_type == Mission_type.WHITE :
		mission_type_str = "white"
	elif mission_type == Mission_type.BLUE :
		mission_type_str = "blue"
	else :
		print("Mission does not exist")

	var function_name = "check_" + mission_type_str + "_mission_" + str(id_mission)
	
	if has_method(function_name):
		return call(function_name, id_player, id_session)
	else:
		printerr("Mission does not exist : ", function_name)
	return 0;
	
### ----------------------------------------------------------------------------------------------------------------------------------------------
### ----------------------------------------------------------------------------------------------------------------------------------------------
	
func _count_family_occurrence(_family: String, _id_player: int, id_session: int) -> int :
	return Network.session[id_session].players[_id_player][global.families.find(_family)].size()
	
func _count_card_type_occurrence(_card_type: int, _id_player: int, id_session: int) -> int :
	var count = 0
	for family in range(6):
		for card in Network.session[id_session].players[_id_player][family] :
			if card[0] == _card_type:
				count = count+1
	return count

## "Vous devez posseder au moins 2 assassins"
func check_white_mission_0(_id_player: int, id_session: int) -> int :
	var count = _count_card_type_occurrence(global.CardType.ASSASSIN ,_id_player, id_session)
	if count >= 2 :
		return 3
	return 0
	
## "Vous devez posseder au moins 3 nobles",
func check_white_mission_1(_id_player: int, id_session: int) -> int :
	var count = _count_card_type_occurrence(global.CardType.NOBLE ,_id_player, id_session)
	if count >= 3 :
		return 3
	return 0
	
## "Vous devez posseder au moins 3 espions"
func check_white_mission_2(_id_player: int, id_session: int) -> int :
	var count = _count_card_type_occurrence(global.CardType.SPY ,_id_player, id_session)
	if count >= 3 :
		return 3
	return 0
	
## "Vous devez posseder au moins 4 gardes"
func check_white_mission_3(_id_player: int, id_session: int) -> int :
	var count = _count_card_type_occurrence(global.CardType.GUARD ,_id_player, id_session)
	if count >= 4 :
		return 3
	return 0
	
## "Vous devez posseder moins de carpes que votre voision de gauche"
func check_white_mission_4(_id_player: int, id_session: int) -> int :
	var id_left_neighbor = (_id_player + 1) % Network.session[id_session].players.size()
	var count_neighbor = _count_family_occurrence("Carpes", id_left_neighbor, id_session)
	var count = _count_family_occurrence("Carpes", _id_player, id_session)
	if count < count_neighbor :
		return 3
	return 0
	
## "Vous devez posseder moins de crapauds que votre voision de gauche"
func check_white_mission_5(_id_player: int, id_session: int) -> int :
	var id_left_neighbor = (_id_player + 1) % Network.session[id_session].players.size()
	var count_neighbor = _count_family_occurrence("Crapauds", id_left_neighbor, id_session)
	var count = _count_family_occurrence("Crapauds", _id_player, id_session)
	if count < count_neighbor :
		return 3
	return 0
	
	
## "Vous devez posseder moins de cerfs que votre voision de gauche"
func check_white_mission_6(_id_player: int, id_session: int) -> int :
	var id_left_neighbor = (_id_player + 1) % Network.session[id_session].players.size()
	var count_neighbor = _count_family_occurrence("Cerfs", id_left_neighbor, id_session)
	var count = _count_family_occurrence("Cerfs", _id_player, id_session)
	if count < count_neighbor :
		return 3
	return 0
	
	
## "Vous devez posseder moins de rossignols que votre voision de gauche"
func check_white_mission_7(_id_player: int, id_session: int) -> int :
	var id_left_neighbor = (_id_player + 1) % Network.session[id_session].players.size()
	var count_neighbor = _count_family_occurrence("Rossignols", id_left_neighbor, id_session)
	var count = _count_family_occurrence("Rossignols", _id_player, id_session)
	if count < count_neighbor :
		return 3
	return 0
	
	
## "Vous devez posseder moins de papillons que votre voision de gauche"
func check_white_mission_8(_id_player: int, id_session: int) -> int :
	var id_left_neighbor = (_id_player + 1) % Network.session[id_session].players.size()
	var count_neighbor = _count_family_occurrence("Papillons", id_left_neighbor, id_session)
	var count = _count_family_occurrence("Papillons", _id_player, id_session)
	if count < count_neighbor :
		return 3
	return 0
	
	
## "Vous devez posseder moins de lièvres que votre voision de gauche"
func check_white_mission_9(_id_player: int, id_session: int) -> int :
	var id_left_neighbor = (_id_player + 1) % Network.session[id_session].players.size()
	var count_neighbor = _count_family_occurrence("Lièvres", id_left_neighbor, id_session)
	var count = _count_family_occurrence("Lièvres", _id_player, id_session)
	if count < count_neighbor :
		return 3
	return 0
	
	
### ----------------------------------------------------------------------------------------------------------------------------------------------
### ----------------------------------------------------------------------------------------------------------------------------------------------
## Blue missions

# 1 if in favor
# 0 if in disfavor
# -1 if no card
func _is_in_favor(family: String, _id_player: int, id_session: int) -> int:
	var stat = Network.session[id_session].get_stat()
	var favor_value = stat[0][0][global.families.find(family)]
	var disfavor_value = stat[0][1][global.families.find(family)] 
	if favor_value != 0 or disfavor_value != 0 :
		if favor_value > abs(disfavor_value) :
			return 1
		else :
			return 0
	return -1
	
### ----------------------------------------------------------------------------------------------------------------------------------------------
### ----------------------------------------------------------------------------------------------------------------------------------------------
	
## "Les lièvres doivent être en disgrâce à la cours"
func check_blue_mission_0(_id_player: int, id_session: int) -> int :
	if _is_in_favor("Lièvres", _id_player, id_session) == 0:
		return 3
	return 0
	
## "Les crapauds doivent être en disgrâce à la cours"
func check_blue_mission_1(_id_player: int, id_session: int) -> int :
	if _is_in_favor("Crapauds", _id_player, id_session) == 0:
		return 3
	return 0
	
## "Les cerfs doivent être en disgrâce à la cours"
func check_blue_mission_2(_id_player: int, id_session: int) -> int :
	if _is_in_favor("Cerfs", _id_player, id_session) == 0:
		return 3
	return 0
	
## "Les carpes doivent être en disgrâce à la cours"
func check_blue_mission_3(_id_player: int, id_session: int) -> int :
	if _is_in_favor("Carpes", _id_player, id_session) == 0:
		return 3
	return 0
	
## "Les papillons doivent être en disgrâce à la cours"
func check_blue_mission_4(_id_player: int, id_session: int) -> int :
	if _is_in_favor("Papillons", _id_player, id_session) == 0:
		return 3
	return 0
	
## "Les rossignols doivent être en disgrâce à la cours"
func check_blue_mission_5(_id_player: int, id_session: int) -> int :
	if _is_in_favor("Rossignols", _id_player, id_session) == 0:
		return 3
	return 0
	
## "3 familles, au maximum, doivent être dans la lumière à la cours"
func check_blue_mission_6(_id_player: int, id_session: int) -> int :
	var count = 0
	for family in range(6) :
		if _is_in_favor( global.families[family], _id_player, id_session) == 1:
			count = count+1
	if count <= 3 :
		return 3
	return 0
	
## "Une famille doit avoir au moins 5 cartes au-dessous du tapis de jeu"
func check_blue_mission_7(_id_player: int, id_session: int) -> int :
	for family in range(6):
		var count_favor = Network.session[id_session].queen_table[family][0].size()
		var count_disfavor = Network.session[id_session].queen_table[family][1].size()
		var count = count_disfavor + count_favor
		if count >= 5 :
			return 3
	return 0
	
## "Au moins 2 familles, doivent être en disgrace à la cours"
func check_blue_mission_8(_id_player: int, id_session: int) -> int :
	var count = 0
	for family in range(6):
		if _is_in_favor( global.families[family], _id_player, id_session) == 0:
			count = count+1
	if count >= 2 :
		return 3
	return 0
	
## "Au moins 1 cartes de chaque famille doit être au-dessous du tapis de jeu"
func check_blue_mission_9(_id_player: int, id_session: int) -> int :
	for family in range(6):
		var count_favor = Network.session[id_session].queen_table[family][0].size()
		var count_disfavor = Network.session[id_session].queen_table[family][1].size()
		var count = count_disfavor + count_favor
		if count == 0 :
			return 0
	return 3
	
