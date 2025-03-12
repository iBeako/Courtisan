extends Node

## Fields of class

# to enhance with the beta version with dynamic lobby
var status = false # if a session has started or not yet
var session_id : int # if several session is running
var player_max : int

var clients_peer = [] # table of all clients_peer
var players = [] # size of player_max
var queens_table = [
	["SPECIFIC CARD"], # SPIES
	[0, 0], # PAPILLON
	[0, 0], # CRAPAUD
	[0, 0], # ROSSIGNOL
	[0, 0], # LIEVRE
	[0, 0], # CERF
	[0, 0], # CARPE
]

var card_stack = [0]

var card_played = [
	0, # card count in the stack
	
	# Card already played in game
	[0, 0, 0, 0, 0], # PAPILLON [idle, noble, guard, spy, assassin]
	[0, 0, 0, 0, 0], # CRAPAUD
	[0, 0, 0, 0, 0], # ROSSIGNOL
	[0, 0, 0, 0, 0], # LIEVRE
	[0, 0, 0, 0, 0], # CERF
	[0, 0, 0, 0, 0], # CARPE
]
var current_player_id : int

### ----------------------------------------------------------------------------------------------------------------------------------------------
### ----------------------------------------------------------------------------------------------------------------------------------------------
### ----------------------------------------------------------------------------------------------------------------------------------------------
### ----------------------------------------------------------------------------------------------------------------------------------------------
## On creation of session
func _init(_player_max: int = 5) -> void:
	self.session_id = 12345
	self.player_max = _player_max
	self.current_player_id = 1 # could be picked radomly or from connection order
	set_card_stack()
	print("Initilization of a new session success")
	
func set_card_stack() -> void:
	if player_max == 2 :
		card_stack[0] = 60
	elif player_max == 3 :
		card_stack[0] = 72
	elif player_max == 4 :
		card_stack[0] = 83
	elif player_max == 5 :
		card_stack[0] = 90
	else :
		print("Error : number of players invalid")
		
### ----------------------------------------------------------------------------------------------------------------------------------------------
### ----------------------------------------------------------------------------------------------------------------------------------------------
### ----------------------------------------------------------------------------------------------------------------------------------------------
### ----------------------------------------------------------------------------------------------------------------------------------------------
## On player's connections
func _add_player(_id_peer) -> int:
	var count_players = players.size()
	players.append( [
		[], # current cards in hands
		0, # PAPILLON
		0, # CRAPAUD
		0, # ROSSIGNOL
		0, # LIEVRE
		0, # CERF
		0 # CARPE
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
	print("	Queen's table : <in the light>, <out of favor>")
	print("		Spies : 0 spies")
	print("		Papillon : ↑", queens_table[1][0],", ↓", queens_table[1][1])
	print("		Crapaud : ↑", queens_table[2][0],", ↓", queens_table[2][1])
	print("		Rossignol : ↑", queens_table[3][0],", ↓", queens_table[3][1])
	print("		Lievre : ↑", queens_table[4][0],", ↓", queens_table[4][1])
	print("		Cerf : ↑", queens_table[5][0],", ↓", queens_table[5][1])
	print("		Carpe : ↑", queens_table[6][0],", ↓", queens_table[6][1])
		
	print("\n")
	print("Player status :\n")
	for i in range(players.size()):
		print("Player ", i+1, " =>")
		print("	Hand :")
		print("		First card : ", players[i][0][0], "")
		print("		Second card : ", players[i][0][1], "")
		print("		Third card : ", players[i][0][2], "\n")
		print("	Collection in domain :")
		print("		Papillon : ", players[i][1])
		print("		Crapaud : ", players[i][2])
		print("		Rossignol : ", players[i][3])
		print("		Lievre : ", players[i][4])
		print("		Cerf : ", players[i][5])
		print("		Carpe : ", players[i][6])
	print("--------------------------")
	
func check_status() -> bool:
	return status
	
func check_game_start() -> bool :
	if clients_peer.size() == player_max:
		self.status = true
		return load_game()
	return false
	
func load_game() -> bool :
	# Need API server and Database
	print("-----------------------------")
	print("-----------------------------")
	print("Game start")
	print("Get all cards ( ", card_stack[0] ," random cards ) from `API server` data")
	for i in range(card_stack[0]) :
		card_stack.append(["family", "type"])
	print(card_stack)
	print("sharing three cards for each player from `card_stack`")
	print("Keep card infromation (the three cards) for each player")
	for player in players:
		player[0].append([false, "area", ["card_type", "family"]])
		player[0].append([false, "area", ["card_type", "family"]])
		player[0].append([false, "area", ["card_type", "family"]])
	display_session_status()
	return true
	
### ----------------------------------------------------------------------------------------------------------------------------------------------
### ----------------------------------------------------------------------------------------------------------------------------------------------
### ----------------------------------------------------------------------------------------------------------------------------------------------
### ----------------------------------------------------------------------------------------------------------------------------------------------
## On player's actions
# Check player id regarding a session
func check_player_turn(_id_peer : int, _id_in_message: int) -> bool:
	var is_valid = true
	
	var id_client = clients_peer.find(_id_peer)
	
	#if it's a player in the current session (AUTOMATICLY true due to webSocket connection)
	is_valid = is_valid and (id_client != -1)
	
	#if it's the current player
	is_valid = is_valid and (id_client == _id_in_message)
	
	return is_valid
	
func check_player_hand(_player_id: int, card_type: String, family: String) -> bool:
	var is_valid = false
	for card in players[_player_id][0] :
		is_valid = is_valid or ( card[0] == false )
		if is_valid == true and card_type == card[2][0] and card[2][1] == family :
			return is_valid
	return is_valid
	
func check_player_area(_player_id: int, area: String) -> bool:
	var is_valid = true
	for card in players[_player_id][0] :
		is_valid = is_valid and ( card[1] != area )
	return is_valid
	
func place_card(_player_id: int, area: String, card_type: String, family: String, position: int = 0, id_player_domain: int = -1) -> bool:
		
	if area == "queen_table":
		print("Queen table at ", position)
		var pos = 0
		if position == -1 :
			pos = 1
		match family:
			"butterfly":
				queens_table[1][pos] += position
			"frog":
				queens_table[2][pos] += position
			"bird":
				queens_table[3][pos] += position
			"bunny":
				queens_table[4][pos] += position
			"deer":
				queens_table[5][pos] += position
			"fish":
				queens_table[6][pos] += position
			_:
				print("Error : family unkown")
					
	elif area == "our_domain":
		print("Own domain")
		match family:
			"butterfly":
				players[_player_id][1] += 1
			"frog":
				players[_player_id][2] += 1
			"bird":
				players[_player_id][3] += 1
			"bunny":
				players[_player_id][4] += 1
			"deer":
				players[_player_id][5] += 1
			"fish":
				players[_player_id][6] += 1
			_:
				print("Error : family unkown")
	elif area == "domain":
		print("Adversary domain: ", id_player_domain)
		match family:
			"butterfly":
				players[id_player_domain][1] += 1
			"frog":
				players[id_player_domain][2] += 1
			"bird":
				players[id_player_domain][3] += 1
			"bunny":
				players[id_player_domain][4] += 1
			"deer":
				players[id_player_domain][5] += 1
			"fish":
				players[id_player_domain][6] += 1
			_:
				print("Error : family unkown")
	
	for card in players[_player_id][0] :
		if card_type == card[2][0] and card[2][1] == family :
			card[0] = true # has been placed
	return true
	
func check_end_game() -> bool:
	return card_stack[0] == 0
