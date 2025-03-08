extends Node

# client receive only the action done during a turn and in the beginning 
# of every new turn send all the table

var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
var port: int = 12345  # Change this for an internet address in the future
const MAX_CLIENT:int = 2
var number_of_client :int = 0
var clients_peer = [] # table of all clients_peer

var session = load("res://server/processing/session.gd").new(MAX_CLIENT) # a session specific to a port

func _ready():
	peer.create_server(port)  # Listening on specified port
	peer.connect("peer_connected", Callable(self, "_on_peer_connected"))
	multiplayer.multiplayer_peer = peer
	print("Server started and listening on port %d" % port)
	
	add_child(session) # Creation of new game session

func _on_peer_connected(peer_id:int) -> void:
	number_of_client += 1
	print("New client connected with id: %d" % peer_id)
	
	if number_of_client > MAX_CLIENT:
		peer.refuse_new_connections = true
		print("cannot connect more people in the room")
	else :
		clients_peer.append(peer_id)
		var id = session._add_player(peer_id)
		var welcome = {"message_type":"id","your_id":id}
		var json = JSON.stringify(welcome)
		peer.set_target_peer(peer_id)
		peer.put_packet(json.to_utf8_buffer())
		
		if session.check_game_start():
			session.load_game() # load game of the session
			_send_three_cards_to_each_player()
			
	
func _process(_delta):
	peer.poll()
	while peer.get_available_packet_count() > 0:
		var sender_id = peer.get_packet_peer()
		var packet = peer.get_packet().get_string_from_utf8()
		_process_packet(sender_id, packet)

func _process_packet(sender_id: int, packet: String):
	var json = JSON.new()
	var parse_result = json.parse(packet)
	if parse_result == OK :
		var data_dict = json.data
		if data_dict.has("message_type") and data_dict["message_type"] == "message":
			if _validate_message(packet):
				_broadcast_message(packet)
			else:
				peer.set_target_peer(sender_id)
				var error_message = {"message_type":"error","error_type":"message"}
				packet = JSON.stringify(error_message)
				peer.put_packet(packet.to_utf8_buffer())
		elif data_dict.has("message_type") and data_dict["message_type"] == "card_played":
			if _validate_card_played(sender_id, packet):
				_broadcast_card_played(packet)
			else:
				peer.set_target_peer(sender_id)
				var error_message = {"message_type":"error","error_type":"action"}
				packet = JSON.stringify(error_message)
				peer.put_packet(packet.to_utf8_buffer())
		else:
			print("problem")
		
	if session.check_end_game() :
		session.display_session_status()
		var stat = session.get_stat()
		packet = JSON.stringify(stat)
		_broadcast_message(packet)
		peer.close()
	elif session.check_next_player(clients_peer.find(sender_id)) :
		_send_three_cards_to_a_player(sender_id)
		session.display_session_status()

func _validate_message(_message: String) -> bool:
	# the game has not yet begun
	# massage has the good format
	# message number exist (for nom between 1 and 5)
	return true
	
func _validate_card_played(_sender_id :int,_message: String) -> bool:
	
	# The game has not yet begun
	if session.check_status() == false :
		print("SERVER - Error : The game has not yet begun")
		return false
	
	# message has the good format
	var json = JSON.new()
	var parse_result = json.parse(_message)
	
	if parse_result == OK :
		var data_dict = json.data
		
		var is_valid_action = true
		
		# message has the good format
		is_valid_action = is_valid_action and ( data_dict.has("area") and data_dict.has("card_type") and data_dict.has("family") and data_dict.has("player") )
		if  !is_valid_action :
			print("SERVER - Error : message has not right format")
			return false
			
		if  data_dict.has("id_player_domain") and !session.check_id_player_domain(data_dict["id_player_domain"]):
			print("SERVER - Error : adversary id is the player or does not exist")
			return false
			
		# validate action if it is the good player that have played the card (same client id and same id)
		is_valid_action = is_valid_action and session.check_player_turn(clients_peer.find(_sender_id), data_dict["player"])
		if !is_valid_action :
			print("SERVER - Error : Wrong player who is currently playing")
			return false
		
		# player has a card in hand and it is the right card
		is_valid_action = is_valid_action and session.check_player_hand(data_dict["player"], data_dict["card_type"], data_dict["family"])
		if !is_valid_action :
			print("SERVER - Error : Player has no card or wrong one")
			return false
		
		# he did not put a card in the same area in the turn
		is_valid_action = is_valid_action and session.check_player_area(data_dict["player"], data_dict["area"])
		if !is_valid_action :
			print("SERVER - Error : Player can play this card in this area again")
			return false
		
		if is_valid_action :
			if data_dict["area"] == "queen_table":
				session.place_card(data_dict["player"], data_dict["area"], data_dict["card_type"], data_dict["family"], data_dict["position"])
			elif data_dict["area"] == "our_domain":
				session.place_card(data_dict["player"], data_dict["area"], data_dict["card_type"], data_dict["family"])
			elif data_dict["area"] == "domain":
				session.place_card(data_dict["player"], data_dict["area"], data_dict["card_type"], data_dict["family"], 0, data_dict["id_player_domain"])
		
	return true

func _broadcast_message(message: String):
	peer.set_target_peer(MultiplayerPeer.TARGET_PEER_BROADCAST)
	peer.put_packet(message.to_utf8_buffer())
	
func _broadcast_card_played(message: String):
	# will change with spy
	peer.set_target_peer(MultiplayerPeer.TARGET_PEER_BROADCAST)
	peer.put_packet(message.to_utf8_buffer())

func _send_error(peer_id: int, error_message: String):
	var error_packet = {"error": error_message}
	var packet = JSON.stringify(error_packet)
	peer.set_target_peer(peer_id)
	peer.put_packet(packet.to_utf8_buffer())

#-------------------------------------------------
## At game start, distribute cads to players

func _send_three_cards_to_each_player():
	for peer_id in clients_peer:
		_send_three_cards_to_a_player(peer_id)
	
func _send_three_cards_to_a_player(peer_id):
	var cards_as_dict = session.distribute_three_cards(clients_peer.find(peer_id))
	var packet = JSON.stringify(cards_as_dict)
	peer.set_target_peer(peer_id)
	peer.put_packet(packet.to_utf8_buffer())
