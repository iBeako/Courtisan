extends Node

var card_types = ["normal", "noble", "spy", "guard", "assassin"]
var families = ["butterfly", "frog", "bird", "bunny", "deer", "fish"]
	
## Fields of class

# to enhance with the beta version with dynamic lobby
var status = false # if a session has started or not yet
var session_id : int # if several session is running
var player_max : int

var clients_peer = [] # table of all clients_peer
var players = [] # size of player_max
var queen_table = [
	[[], []], # PAPILLON
	[[], []], # CRAPAUD
	[[], []], # ROSSIGNOL
	[[], []], # LIEVRE
	[[], []], # CERF
	[[], []], # CARPE
	["SPECIFIC CARD"], # SPIES
]

var card_stack = load("res://server/processing/stack.gd").new()

var current_player_id : int

### ----------------------------------------------------------------------------------------------------------------------------------------------
### ----------------------------------------------------------------------------------------------------------------------------------------------
### ----------------------------------------------------------------------------------------------------------------------------------------------
### ----------------------------------------------------------------------------------------------------------------------------------------------
## On creation of session
func _init(_player_max: int = 2) -> void:
	self.session_id = 12345
	self.player_max = _player_max
	self.current_player_id = 0 # could be picked radomly or from connection order
	card_stack._set_card_number(_player_max)
	print("Initilization of a new session success")
	card_stack.print_stack_state()
### ----------------------------------------------------------------------------------------------------------------------------------------------
### ----------------------------------------------------------------------------------------------------------------------------------------------
### ----------------------------------------------------------------------------------------------------------------------------------------------
### ----------------------------------------------------------------------------------------------------------------------------------------------
## On player's connections
func _add_player(_id_peer) -> int:
	var count_players = players.size()
	players.append( [
		[], # PAPILLON
		[], # CRAPAUD
		[], # ROSSIGNOL
		[], # LIEVRE
		[], # CERF
		[], # CARPE
		[[], [], []], # current cards in hands
	] )
	clients_peer.append(_id_peer)
	print("Client '", _id_peer, "' registered as Player ", count_players)
	return count_players # id tab is 0 but id is 1

# PRECOND : Lobby must not be empty
func _remove_player(player_id) -> bool:
	clients_peer.erase(player_id)
	players.erase(player_id)
	return true # to fix

func display_session_status():
	print("--------------------------")
	print("Session status :\n")
	print("	Session id : ", session_id)
	print("	Player max : ", player_max)
	print("	All connected peers : ", clients_peer)
	print("\n")
	
	print("Card stack count : ", card_stack._get_card_number())
	
	print("\n")
	print("	Queen's table : <in the light>, <out of favor>")
	print("		Papillon : ↑", queen_table[0][0],", ↓", queen_table[0][1])
	print("		Crapaud : ↑", queen_table[1][0],", ↓", queen_table[1][1])
	print("		Rossignol : ↑", queen_table[2][0],", ↓", queen_table[2][1])
	print("		Lievre : ↑", queen_table[3][0],", ↓", queen_table[3][1])
	print("		Cerf : ↑", queen_table[4][0],", ↓", queen_table[4][1])
	print("		Carpe : ↑", queen_table[5][0],", ↓", queen_table[5][1])
	print("		Spies : 0 spies")
		
	print("\n")
	print("Player status :\n")
	for i in range(players.size()):
		print("Player ", i, " =>")
		print("	Hand :")
		print("		First card : ", players[i][6][0], "")
		print("		Second card : ", players[i][6][1], "")
		print("		Third card : ", players[i][6][2], "\n")
		print("	Collection in domain :")
		print("		Papillon : ", players[i][0])
		print("		Crapaud : ", players[i][1])
		print("		Rossignol : ", players[i][2])
		print("		Lievre : ", players[i][3])
		print("		Cerf : ", players[i][4])
		print("		Carpe : ", players[i][5])
	print("--------------------------")
	
func check_status() -> bool:
	return status
	
func check_game_start() -> bool :
	if clients_peer.size() == player_max :
		status = true
		return true
	return false
	
func load_game() -> bool :
	# Need API server and Database
	print("-----------------------------")
	print("-----------------------------")
	print("Game start")
	
	card_stack.generate_card()
	card_stack._set_card_stack()
	card_stack.print_stack_state()
	
	return true
	
func distribute_three_cards(player_id:int) -> Dictionary:
	var cards = card_stack._retrieve_three_cards()
	var cards_as_dict = {
		"message_type":"hand",
		"first_card_family":cards[0][0],
		"first_card_type":cards[0][1],
		"second_card_family":cards[1][0],
		"second_card_type":cards[1][1],
		"third_card_family":cards[2][0],
		"third_card_type":cards[2][1]
	}
	players[player_id][6][0] = ([true, "area", cards[0]])
	players[player_id][6][1] = ([true, "area", cards[1]])
	players[player_id][6][2] = ([true, "area", cards[2]])
	return cards_as_dict
	
### ----------------------------------------------------------------------------------------------------------------------------------------------
### ----------------------------------------------------------------------------------------------------------------------------------------------
### ----------------------------------------------------------------------------------------------------------------------------------------------
### ----------------------------------------------------------------------------------------------------------------------------------------------
## On player's actions

# check 
func check_id_player_domain(id_player_domain: int) :
	return id_player_domain < players.size() and id_player_domain != current_player_id

# Check player id regarding a session
func check_player_turn(player_id : int, _id_in_message: int) -> bool:
	return (player_id == _id_in_message) and (current_player_id == player_id)
	
func check_player_hand(_player_id: int, card_type: String, family: String) -> bool:
	var is_valid = false
	for card in players[_player_id][6] :
		is_valid = is_valid or card[0]
		if is_valid :
			if card_type == card[2][0] and card[2][1] == family and card_stack.check_card(card_type, family):
				return is_valid
	return is_valid
	
func check_player_area(_player_id: int, area: String) -> bool:
	var is_valid = true
	for card in players[_player_id][6] :
		is_valid = is_valid and ( card[1] != area )
	return is_valid
	
func place_card(_id_player: int, _area: String, _card_type: String, _family: String, _position: int = 0, _id_player_domain: int = -1) -> bool:
	var pos = 0 if _position == 1 else 1
	
	if _area == "queen_table":
		print("SERVER : Action saved as card palced in Queen table at ", _position)
		queen_table[families.find(_family)][pos].append([_card_type, _family])
					
	elif _area == "our_domain":
		print("SERVER : Action saved as card palced in Own domain")
		players[_id_player][families.find(_family)].append([_card_type, _family])
				
	elif _area == "domain":
		print("SERVER : Action saved as card palced in Adversary domain ", _id_player_domain)
		players[_id_player_domain][families.find(_family)].append([_card_type, _family])
	else :
		print("SERVER - Error : wrong area name")
	
	for card in players[_id_player][6] :
		if _card_type == card[2][0] and card[2][1] == _family :
			card[0] = false # has been played
			card[1] = _area
	
	card_stack._retrieve_card(_card_type, _family)
	
	var still_current = false
	for card in players[_id_player][6] :
		still_current = still_current or card[0]
	if !still_current :
		print("SERVER : Move to next player")
		current_player_id = (current_player_id + 1) % players.size()
	
	return true
	
func check_next_player(player_id) -> bool :
	return current_player_id != player_id
	
func get_card_points(_card_type: String, _family: String, _position: int = 1) -> int :
	var points = 0
	match _card_type:
		"normal":
			points = 1
		"noble":
			points = 2
		"spy":
			points = 1
		"guard":
			points = 1
		"assassin":
			points = 1
		_:
			points = 0
	points = points * _position
	return points
	
func get_collection_points(_collection: Array, _position: int = 1) -> int :
	var points = 0
	for card in _collection :
		points = points + get_card_points(card[0], card[1], _position)
	return points
	
func get_stat() -> Dictionary :
	var stat = [
		# Card already played in game
		[
			[], # in light
			[] # out of favor
		], # 6 families for queen's table
		# append stat for each player
	]
	
	for i in range(6) : 
		stat[0][0].append(get_collection_points(queen_table[i][0])) # in light
		stat[0][1].append(get_collection_points(queen_table[i][1], -1)) # out of favor
	
	for player in players :
		var col = []
		for j in range(6) :
			col.append(get_collection_points(player[j]))
		stat.append(col)
			
	var data_dict = {"message_type":"stat"}

	# Ajout des statuts spéciaux
	data_dict["in_the_light"] = stat[0][0]
	data_dict["out_of_favor"] = stat[0][1]

	# Ajout des stat des joueurs
	for i in range(1, stat.size()):
		data_dict["player_" + str(i - 1)] = stat[i]
	print("Game stat",data_dict)
	return data_dict
	
func check_end_game() -> bool:
	if card_stack._get_card_number() == 0 :
		print("SERVER : End game ============> ")
		status = false
		return true
	print("\nSERVER : wait for next move ...\n")
	return false
