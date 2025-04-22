extends Node

func process_message_not_ingame(data: Dictionary,sender_id:int):
	if data.has("message_type"):
		if data["message_type"] == "create_lobby":
			var message = await Network.createLobby(data,sender_id)
			Network.send_message_to_peer.rpc_id(sender_id,message)
		elif data["message_type"] == "find_lobby":
			var lobbies = await Network.findLobby(data)
			var message = {
				"message_type": "find_lobby",
				"lobbies": lobbies
			}
			Network.send_message_to_peer.rpc_id(sender_id,message)
		elif data["message_type"] == "join_lobby":
			var message = await Network.joinLobby(data,sender_id)
			Network.send_message_to_lobby(data["id_lobby"],message)
		
		elif data["message_type"] == "quit_lobby":
			print(data["id_lobby"])
			print(Network.session[data["id_lobby"]].creator)
			print(data["username"])
			if Network.session[data["id_lobby"]].creator == data["username"]:
				var message = await Network.destroyLobby(data,sender_id)
				Network.send_message_to_lobby(data["id_lobby"],message)
				Network.session.erase(data["id_lobby"])
			else:
				var message = await Network.quitLobby(data,sender_id)
				Network.send_message_to_lobby(data["id_lobby"],message)
				
		elif data["message_type"] == "start_lobby":
			if Network.session[data["id_lobby"]].creator == data["username"]:
				var message = await Network.startLobby(data,sender_id)
				if message.has("status") and message["status"] == "success":
					var message_before_starting = {
						"message_type": "before_start",
						"clients": Network.session[data["id_lobby"]].clients_peer
					}
				else:
					var message_before_starting = {
						"message_type": "error",
						"error": "game not started"
					}
				Network.send_message_to_lobby(data["id_lobby"],message)
		elif data["message_type"] == "change_profil":
			Database.sendDatabase(data)
			var message = await Database.getDatabase()
			Network.send_message_to_peer.rpc_id(sender_id,message)
	else:
		var error_message = {
				"message_type" = "error",
				"error_type" = "message_format"
			}
		Network.send_message_to_peer.rpc_id(sender_id,error_message)	

#process message
func process_message_ingame(data : Dictionary,sender_id:int):
	
	if data["message_type"] == "error":
		print("Error from client: ", data["error_type"])
		process_error(data)
	#action message
	elif data["message_type"] == "card_played":
		if validate_card_played(data["id_lobby"],sender_id,data):
			Network.send_message_to_lobby(data["id_lobby"],data)
		else:
			var error_card_played = {
				"message_type" = "error",
				"error_type" = "card_played"
			}
			Network.send_message_to_peer.rpc_id(sender_id,error_card_played)
	elif data["message_type"] == "message":
		if validate_message(data):
			Network.send_message_to_lobby(data["id_lobby"],data)
		else:
			var error_message = {
				"message_type" = "error",
				"error_type" = "card_played"
			}
			Network.send_message_to_peer.rpc_id(sender_id,error_message)	
	elif data["message_type"] == "action":
		if validate_action(data):
			Network.send_message_to_lobby(data["id_lobby"],data)
		else:
			var error_message = {
				"message_type" = "error",
				"error_type" = "action"
			}
			Network.send_message_to_peer.rpc_id(sender_id,error_message)
	else:
		print("invalid message")
		
	if sender_id == 1 : # if AI sent message
		Network.session[data["id_lobby"]].check_turn(data["player"])
	else :
		Network.session[data["id_lobby"]].check_turn(sender_id)
		
	

func process_error(_data: Dictionary):
	pass	

func validate_message(message: Dictionary) -> bool:
	if message["message"] > 0 and message["message"] <6:
	# message number exist (for nom between 1 and 5)
		return true
	return false

func validate_card_played(id_lobby:int,sender_id :int,message: Dictionary) -> bool:
	# The game has not yet begun
	if Network.session[id_lobby].check_status() == false :
		print("SERVER - Error : The game has not yet begun")
		return false
		
	else :
		var is_valid_action = true
		
		# message has the good format
		is_valid_action = is_valid_action and ( message.has("area") and message.has("card_type") and message.has("family") and message.has("player") )
		if  !is_valid_action :
			print("SERVER - Error : message has not right format")
			return false
			
		if  message.has("id_player_domain") and !Network.session[id_lobby].check_id_player_domain(message["id_player_domain"]):
			print("SERVER - Error : adversary id is the player or does not exist")
			return false
			
		# validate action if it is the good player that have played the card (same client id and same game id)
		is_valid_action = is_valid_action and Network.session[id_lobby].check_player_turn(Network.clients[sender_id]["id_client_in_game"], message["player"])
		if !is_valid_action :
			print("SERVER - Error : Wrong player who is currently playing")
			return false
		
		# player has a card in hand and it is the right card
		is_valid_action = is_valid_action and Network.session[id_lobby].check_player_hand(message["player"], message["card_type"], message["family"])
		if !is_valid_action :
			print("SERVER - Error : Player has no card or wrong one")
			return false
		
		# he did not put a card in the same area in the turn
		is_valid_action = is_valid_action and Network.session[id_lobby].check_player_area(message["player"], message["area"])
		if !is_valid_action :
			print("SERVER - Error : Player can play this card in this area again")
			return false
		
		if is_valid_action :
			if message["area"] == 2 or  message["area"] == 3:
				Network.session[id_lobby].place_card(message["player"], message["area"], message["card_type"], message["family"])
			elif message["area"] == 0:
				Network.session[id_lobby].place_card(message["player"], message["area"], message["card_type"], message["family"])
			elif message["area"] == 1:
				Network.session[id_lobby].place_card(message["player"], message["area"], message["card_type"], message["family"])#, 0, message["id_player_domain"])
	return true	

func validate_action(message: Dictionary) -> bool:
	var is_valid = true
	
	if message["area"] == 1:
		print("_validate_action: area == 1")
		is_valid = is_valid and Network.session[message["id_lobby"]].remove_card(message["player"], message["area"], message["id_card"], message["family"], message["target_family"], message["id_player_domain"])
	else :
		print("_validate_action: area != 1")
		is_valid = is_valid and Network.session[message["id_lobby"]].remove_card(message["player"], message["area"], message["id_card"], message["family"], message["target_family"])
	
	if is_valid :
		return true
	return false
