extends Node
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

var card_stack = load("res://Script/stack.gd").new()
var current_player_id : int

### ----------------------------------------------------------------------------------------------------------------------------------------------
### ----------------------------------------------------------------------------------------------------------------------------------------------
### ----------------------------------------------------------------------------------------------------------------------------------------------
### ----------------------------------------------------------------------------------------------------------------------------------------------
## On creation of session
func init(id_session:int,_player_max: int,_name: String) -> void:
	self.session_id = id_session
	self.player_max = _player_max
	self.name = _name
	self.current_player_id = 0 # could be picked radomly or from connection order
	self.card_stack._set_card_number(player_max)
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
	print("Client '", _id_peer, "' registered as Player '", count_players, "' in session ", session_id)
	return count_players # id tab is 0 but id is 1

# PRECOND : Lobby must not be empty
func _remove_player(player_id) -> bool:
	clients_peer.erase(player_id)
	players.erase(player_id)
	return true # to fix

func display_session_status():
	print("==========================================================================")
	print("==========================================================================")
	print("SESSION STATUS :\n")
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
	print("==========================================================================")
	
func check_status() -> bool:
	return status
	
func check_game_start() -> bool :
	if clients_peer.size() == player_max :
		status = true
		return true
	return false
	
func load_game() -> bool :
	print("==========================================================================")
	print("==========================================================================")
	print("Game start")
	
	card_stack.generate_card()
	card_stack._set_card_stack()
	card_stack.print_stack_state()
	send_three_cards_to_each_player()
	return true
	
func distribute_three_cards(player_id:int) -> Dictionary:
	var cards_as_dict = {}
	if !card_stack._no_more_card_in_stack():
		var cards = card_stack._retrieve_three_cards()
		cards_as_dict = {
			"message_type":"hand",
			"first_card_family":cards[0][0],
			"first_card_type":cards[0][1],
			"second_card_family":cards[1][0],
			"second_card_type":cards[1][1],
			"third_card_family":cards[2][0],
			"third_card_type":cards[2][1]
		}
		players[player_id][6][0] = ([true, -1, cards[0]])
		players[player_id][6][1] = ([true, -1, cards[1]])
		players[player_id][6][2] = ([true, -1, cards[2]])
	return cards_as_dict
	
### ----------------------------------------------------------------------------------------------------------------------------------------------
### ----------------------------------------------------------------------------------------------------------------------------------------------
### ----------------------------------------------------------------------------------------------------------------------------------------------
### ----------------------------------------------------------------------------------------------------------------------------------------------
## On player's actions

# checking
func check_id_player_domain(id_player_domain: int) :
	return id_player_domain == -1
	#return (id_player_domain >= 0 and id_player_domain < players.size()) and id_player_domain != current_player_id
	#when more than 1 player
# Check player id regarding a session
func check_player_turn(player_id : int, _id_in_message: int) -> bool:
	return (player_id == _id_in_message) and (current_player_id == player_id)
	
func check_player_hand(_player_id: int, card_type: int, family: String) -> bool:
	var is_valid = false
	for card in players[_player_id][6] :
		is_valid = is_valid or card[0]
		if is_valid :
			if card_type == card[2][0] and card[2][1] == family and card_stack.check_card(card_type, family):
				return is_valid
	return is_valid
	
func check_player_area(_player_id: int, area: int) -> bool:
	var is_valid = true
	for card in players[_player_id][6] :
		is_valid = is_valid and ( card[1] != area )
	return is_valid
	
func place_card(_id_player: int, _area: int, _card_type: int, _family: String) -> bool:
	
	if _area == global.PlayZoneType.FAVOR or _area == global.PlayZoneType.DISFAVOR :
		var pos = 0 if _area == global.PlayZoneType.FAVOR else 1
		print("SERVER : Action saved as card placed at Queen's table ", global.play_zone_type[_area])
		queen_table[global.families.find(_family)][pos].append([_card_type, _family])
					
	elif _area == global.PlayZoneType.PLAYER:
		print("SERVER : Action saved as card placed in player's domain")
		players[_id_player][global.families.find(_family)].append([_card_type, _family])
				
	elif _area == global.PlayZoneType.ENEMY:
		print("SERVER : Action saved as card placed in enemy's domain ")
		players[_id_player][global.families.find(_family)].append([_card_type, _family])
	else :
		print("SERVER - Error : wrong area name")
	
	for card in players[_id_player][6] :
		if card[0] == true and _card_type == card[2][0] and card[2][1] == _family :
			card[0] = false # has been played
			card[1] = _area
			break
	
	# remove card from original stack to avoid cheat
	card_stack._retrieve_card(_card_type, _family)
	card_stack._one_card_played()
	
	# check player turn
	var still_current = false
	for card in players[_id_player][6] :
		still_current = still_current or card[0]
	if !still_current :
		if check_end_game() :
			display_session_status()
			var stat = get_stat()
			Network.send_message_to_lobby(session_id,stat)
		print("SERVER : Move to next player")
		var sender_id = clients_peer[current_player_id]
		send_three_cards_to_a_player(sender_id)
		display_session_status()
		var turn = {"message_type":"player_turn","id_player":current_player_id,"number_of_cards":card_stack._get_card_number()}
		print("turn :" ,turn["id_player"])
		Network.send_message_to_lobby(session_id,turn)
		current_player_id = (current_player_id + 1) % players.size()
		print("player %d turn" % current_player_id)
		print("\n")
		
	return true
	


func check_next_player(player_id) -> bool :
	return current_player_id != player_id
	
func get_card_points(_card_type: int, _family: String, _position: int = 1) -> int :
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
		], # 6 global.families for queen's table
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
	
	for i in range(global.families.size()) :
		var weight = -1 if stat[0][0][i] < abs(stat[0][1][i]) else 1
		for j in range(1, stat.size()) :
			stat[j][i] = stat[j][i] * weight
	
	var data_dict = {"message_type":"stat"}

	# Ajout des statuts spéciaux
	data_dict["favor"] = stat[0][0]
	data_dict["disfavor"] = stat[0][1]

	# Ajout des stat des joueurs
	for i in range(1, stat.size()):
		data_dict[str(i - 1)] = stat[i]
	print("Game stat",data_dict)
	return data_dict
	
func send_three_cards_to_each_player():
	for peer_id in clients_peer:
		send_three_cards_to_a_player(peer_id)
	
func send_three_cards_to_a_player(peer_id):
	var cards_as_dict = distribute_three_cards(clients_peer.find(peer_id))
	Network.send_message_to_peer.rpc_id(peer_id,cards_as_dict)

func check_end_game() -> bool:
	if card_stack._no_more_card_to_play() :
		print("---\nSERVER : ============ End game ============ \n---")
		status = false
		return true
	print("---\nSERVER : waiting for next action ...\n---")
	return false
