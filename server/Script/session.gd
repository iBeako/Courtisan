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
	[[], []], # SPIES
]

var mission = load("res://Script/mission.gd").new()
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
		[], # seventh element is spies
		[[], [], []], # current cards in hands
		[] # nineth element is missions
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
	print("		Spies : ", queen_table[6])
		
	print("\n")
	print("Player status :\n")
	for i in range(players.size()):
		print("Player ", i, " =>")
		print("	Hand :")
		print("		First card : ", players[i][7][0], "")
		print("		Second card : ", players[i][7][1], "")
		print("		Third card : ", players[i][7][2], "\n")
		print("	Collection in domain :")
		print("		Papillon : ", players[i][0])
		print("		Crapaud : ", players[i][1])
		print("		Rossignol : ", players[i][2])
		print("		Lievre : ", players[i][3])
		print("		Cerf : ", players[i][4])
		print("		Carpe : ", players[i][5])
		print("		Spies : ", players[i][6])
		
		print("		White mission #", players[i][8][0]," : ", mission.white_missions[players[i][8][0]])
		print("		Blue mission #", players[i][8][1]," : ", mission.blue_missions[players[i][8][1]])
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
	
func distribute_hand_cards(player_id:int) -> Dictionary:
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
		players[player_id][7][0] = ([true, -1, cards[0]])
		players[player_id][7][1] = ([true, -1, cards[1]])
		players[player_id][7][2] = ([true, -1, cards[2]])
	return cards_as_dict

func distribute_missions(player_id:int) -> Dictionary:
	var mission_as_dict = {}
	if check_player_id(player_id) :
		var missions = mission._get_rand_missions()
		if missions.size() != 0 :
			mission_as_dict = {
				"message_type":"mission",
				"white_mission":missions[0], # as id of mission according global file
				"blue_mission":missions[1]
			}
		players[player_id][8].append(missions[0])
		players[player_id][8].append(missions[1])
	return mission_as_dict

### ----------------------------------------------------------------------------------------------------------------------------------------------
### ----------------------------------------------------------------------------------------------------------------------------------------------
### ----------------------------------------------------------------------------------------------------------------------------------------------
### ----------------------------------------------------------------------------------------------------------------------------------------------
## On player's actions

# checking
func check_id_player_domain(id_player_domain: int) :
	#return id_player_domain == -1
	return (id_player_domain >= 0 and id_player_domain < players.size()) and id_player_domain != current_player_id
	#when more than 1 player

# Check player id regarding a session

func check_player_id(player_id: int) -> bool:
	return player_id >= 0 and player_id < players.size()

func check_player_turn(player_id : int) -> bool:
	return current_player_id == player_id
	
func check_player_hand(_player_id: int, card_type: int, family: String) -> bool:
	var is_valid = false
	for card in players[_player_id][7] :
		is_valid = is_valid or card[0]
		if is_valid :
			if card_type == card[2][0] and card[2][1] == family and card_stack.check_card(card_type, family):
				return is_valid
	return is_valid
	
func check_player_area(_player_id: int, area: int) -> bool:
	var is_valid = true
	for card in players[_player_id][7] :
		is_valid = is_valid and ( card[1] != area )
	return is_valid
	
func place_card(_id_player: int, _area: int, _card_type: int, _family: String, _id_player_domain: int = -1) -> bool:
	
	if _area == global.PlayZoneType.FAVOR or _area == global.PlayZoneType.DISFAVOR :
		var pos = 0 if _area == global.PlayZoneType.FAVOR else 1
		if _card_type == 2 : # case is spy
			queen_table[6][pos].append([_card_type, _family])
		else :
			queen_table[global.families.find(_family)][pos].append([_card_type, _family])		
		print("SERVER : Action saved as card placed at Queen's table ", global.play_zone_type[_area])
	elif _area == global.PlayZoneType.PLAYER:
		if _card_type == 2 : # case is spy
			players[_id_player][6].append([_card_type, _family])
		else :
			players[_id_player][global.families.find(_family)].append([_card_type, _family])
		print("SERVER : Action saved as card placed in player's domain")
				
	elif _area == global.PlayZoneType.ENEMY:
		if _card_type == 2 : # case is spy
			players[_id_player_domain][6].append([_card_type, _family])
		else :
			players[_id_player_domain][global.families.find(_family)].append([_card_type, _family])
		print("SERVER : Action saved as card placed in enemy's domain ", _id_player_domain)
	else :
		printerr("SERVER - Error : wrong area name")
		return false
	
	for card in players[_id_player][7] :
		if card[0] == true and _card_type == card[2][0] and card[2][1] == _family :
			card[0] = false # has been played
			card[1] = _area
			break
	
	# remove card from original stack to avoid cheat
	card_stack._retrieve_card(_card_type, _family)
	card_stack._one_card_played()
	
	# check player turn
	var still_current = false
	for card in players[_id_player][7] :
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
	
	display_session_status()
	return true
	
	
# implementation with id card
func remove_card(_id_player: int, _target_area: int, _target_id_card: int, _assassin_family: String, _target_family: String, _id_player_domain: int = -1) -> bool:
	var card = [] # only for debbuging
	print("remove_card:")
	if _target_id_card != -1 :
		if _target_area == global.PlayZoneType.FAVOR or _target_area == global.PlayZoneType.DISFAVOR :
			var pos = 0 if _target_area == global.PlayZoneType.FAVOR else 1
			if _target_family == "Spy" : # case is spy
				##----------------------------------------------
				queen_table[6][pos].pop_at(_target_id_card)
				##----------------------------------------------
			else :
				##----------------------------------------------
				card = queen_table[global.families.find(_target_family)][pos][_target_id_card]
				if card[0] == 3: 
					return false
				queen_table[global.families.find(_target_family)][pos].pop_at(_target_id_card)
				##----------------------------------------------
			print("SERVER : One card removed from queen's table ", global.play_zone_type[_target_area])
		elif _target_area == global.PlayZoneType.PLAYER:
			if _target_family == "Spy" : # case is spy
				##----------------------------------------------
				players[_id_player][6].pop_at(_target_id_card)
				##----------------------------------------------
			else :
				##----------------------------------------------
				card = players[_id_player][global.families.find(_target_family)][_target_id_card]
				if card[0] == 3: 
					return false
				players[_id_player][global.families.find(_target_family)].pop_at(_target_id_card)
				##----------------------------------------------
				
			print("SERVER : One card removed in player's domain")
					
		elif _target_area == global.PlayZoneType.ENEMY:
			# to change 
			var id = (_id_player + 1)%players.size()
			if _target_family == "Spy" : # case is spy
				##----------------------------------------------
				players[id][6].pop_at(_target_id_card)
				##----------------------------------------------
			else :
				##----------------------------------------------
				card = players[id][global.families.find(_target_family)][_target_id_card]
				if card[0] == 3: 
					return false
				players[id][global.families.find(_target_family)].pop_at(_target_id_card)
				##----------------------------------------------
			print("SERVER : One card removed in enemy's domain ", _id_player_domain)
		else :
			print("SERVER - Error : wrong area name")
			return false
			
		print("removed : [", card[0]," ,", card[1],"]")
	
	#----------------------------------------------
	## Place assasin card in right place
	place_card(_id_player, _target_area, 1, _assassin_family, _id_player_domain)
	##----------------------------------------------

	
	return true
	


func check_next_player(player_id) -> bool :
	return current_player_id != player_id
	
	
### ----------------------------------------------------------------------------------------------------------------------------------------------
### ----------------------------------------------------------------------------------------------------------------------------------------------
### ----------------------------------------------------------------------------------------------------------------------------------------------
### ----------------------------------------------------------------------------------------------------------------------------------------------
## On end game


func get_card_points(_card_type: int, _family: String, _position: int = 1) -> int :
	var points = 0
	match _card_type:
		0 : # idle
			points = 1
		1 : # assassin
			points = 1
		2 : # spy
			points = 1
		3 : # guard
			points = 1
		4 : # noble
			points = 2
		_:
			points = 0
	points = points * _position
	return points
	
func get_collection_points(_collection: Array, _position: int = 1) -> int :
	var points = 0
	for card in _collection :
		points = points + get_card_points(card[0], card[1], _position)
	return points
	
func get_stat() -> Array :
	var stat = [
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
			col.append(get_collection_points(player[j], 1))
		stat.append(col)
	
	for i in range(global.families.size()) :
		var weight = -1 if stat[0][0][i] < abs(stat[0][1][i]) else 1
		for j in range(1, stat.size()) :
			stat[j][i] = stat[j][i] * weight

	return stat
	
#func get_score(player_id: int) -> Dictionary:
	#var stat = get_stat()
	#var data_dict = {"message_type":"player_score"}
#
	#data_dict["favor"] = stat[0][0]
	#data_dict["disfavor"] = stat[0][1]
#
	#var score = 0
	#for k in stat[player_id + 1] :
		#score = score + k
	#data_dict["collection"] = stat[player_id + 1]
	#data_dict["score"] = score
	#
	#return data_dict

func include_spies() -> void:
	for pos in range(2) :
		for card in queen_table[6][pos] :
			queen_table[global.families.find(card[1])][pos].append([card[0], card[1]])
		
	for id_player in players.size() :
		for card in players[id_player][6] :
			players[id_player][global.families.find(card[1])].append([card[0], card[1]])
	
func get_final_score() -> Dictionary:
	var stat = get_stat()
	include_spies()
	stat = get_stat()
	var data_dict = {"message_type":"final_score"}

	var scores = []
	var winner = 0 # Due to index shift, set to -1 if there is no winner.
	var _max = -99999
	var _exaequo = false # Check ex aequo
	for i in range(1, stat.size()):
		var score = 0
		for k in stat[i] :
			score = score + k
		var id_player = (i-1)%players.size()
		print("Player ",id_player, " : ",score)
		var white = mission._get_mission_points(id_player, mission.Mission_type.WHITE, players[id_player][8][0], self)
		var blue = mission._get_mission_points(id_player, mission.Mission_type.BLUE, players[id_player][8][1], self)
		print("Player ",id_player, " + missions white : ",white)
		print("Player ",id_player, " + missions blue : ",blue)
		score = score + white + blue
		scores.append(score)
		if score > _max :
			_max = score
			winner = i
			_exaequo = false
		elif score == _max :
			_exaequo = true
			winner = 0 # Due to index shift, set to -1 if there is no winner.
	data_dict["winner"] = winner-1
	data_dict["scores"] = scores
		
	return data_dict
		
func send_three_cards_to_each_player():
	for peer_id in clients_peer:
		send_three_cards_to_a_player(peer_id)
	
func send_three_cards_to_a_player(peer_id):
	var cards_as_dict = distribute_hand_cards(clients_peer.find(peer_id))
	Network.send_message_to_peer.rpc_id(peer_id,cards_as_dict)

func _send_mission_to_a_player(peer_id):
	var mission_as_dict = distribute_missions(clients_peer.find(peer_id))
	Network.send_message_to_peer.rpc_id(peer_id,mission_as_dict)
		

func check_turn(peer_id) -> void :
	if check_end_game() :
		var scores = get_final_score()
		print(scores)
		Network.send_message_to_lobby(session_id,scores)
	elif check_next_player(Network.clients[peer_id]["id_client_in_game"]) :
		send_three_cards_to_a_player(peer_id)
		var turn = {"message_type":"player_turn","id_player":current_player_id}
		print("turn :" ,turn["id_player"])
		Network.send_message_to_lobby(session_id,turn)

func check_end_game() -> bool:
	if card_stack._no_more_card_to_play() :
		print("---\nSERVER : ============ End game ============ \n---")
		status = false
		return true
	print("---\nSERVER : waiting for next action ...\n---")
	return false
