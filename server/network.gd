extends Node

var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
var db_peer: WebSocketPeer = WebSocketPeer.new()
var db_url: String = "ws://localhost:10000/socket.io/?EIO=4&transport=websocket"
var port: int = 8080
const MAX_CLIENT: int = 2
var number_of_client: int = 0
var clients_peer = [] # table of all clients_peer

var return_database: String = ""
var clients = {}
var tls_cert: X509Certificate
var tls_key: CryptoKey
var server_tls_options
var session = load("res://processing/session.gd").new(MAX_CLIENT) # a session specific to a port
var global = preload("res://processing/global.gd")

func _onready():
	tls_key = load("res://certificates/private.key")
	tls_cert = load("res://certificates/certificate.crt")
	server_tls_options = TLSOptions.server(tls_key, tls_cert)

func _ready():
	_onready()
	peer.create_server(port, "127.0.0.1", server_tls_options)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	print("Server started and listening on port %d" % port)
	add_child(session) # Creation of new game session
	connect_to_database()

func _process(_delta):
	if db_peer.get_ready_state() == WebSocketPeer.STATE_OPEN:
		db_peer.poll()
		while db_peer.get_available_packet_count() > 0:
			var packet = db_peer.get_packet()
			return_database = packet.get_string_from_utf8()


func _on_peer_disconnected(peer_id: int):
	clients.erase(peer_id)
	number_of_client -= 1

func _on_peer_connected(peer_id: int):

	print("New client connected with id: %d" % peer_id)
	if number_of_client >= MAX_CLIENT:
		print("Cannot connect more people in the room")
	else:
		clients[number_of_client] = {
			"id": number_of_client,
			"peer_id":peer_id,
			"status":"unlogged"
		}
		
		
		clients_peer.append(peer_id)
		var data_id = {
			"message_type"="id",
			"your_id"= session._add_player(peer_id)
		}
		send_message_to_peer.rpc_id(peer_id,data_id)
		if session.check_game_start():
			session.load_game() # load game of the session
			_send_three_cards_to_each_player()
		number_of_client += 1
		
		
		
		
	
@rpc("any_peer")
func send_message_to_server(data: Dictionary):
	if data != null and data.has("message_type"):
		var sender_id = multiplayer.get_remote_sender_id()
		var i = find_lobby_number_client(sender_id)
		if i != -1 and clients[i]["status"] == "connected":
			print("Client %d sent a %s", [data["player"], data["message_type"]])
			print(" ", data)
			process_message(data,sender_id)
		elif data["message_type"] == "connexion":
			login(data,i)
		elif data["message_type"] == "createAccount":
			
			insertDatabase(data)
		else:
			var error_login = {
			"message_type" = "error",
			"error_type" = "unconnected",
		}
			send_message_to_peer.rpc_id(sender_id,error_login)
			
	else:
		print("error send_message_to_server")

func find_lobby_number_client(id:int) ->int:
	for i in range(number_of_client):
		if clients[i]["peer_id"] == id:
			return i
	return -1


@rpc("authority")
func send_message_to_peer(data: Dictionary):
	if data != null and data.has("message_type"):	
		var sender_id = multiplayer.get_remote_sender_id()
		print("server send a ", data["message_type"])
		print(" ", data)
		process_message(data,sender_id)
	else:
		print("error send_message_to_peer")

@rpc("authority")
func send_message_to_everyone(data : Dictionary):
	if data != null and data.has("message_type"):
		var sender_id = multiplayer.get_remote_sender_id()
		print("Broadcasting ", data["message_type"])
		print(" ", data)
		process_message(data,sender_id)
	else:
		print("error send_message_to_peer")
		
func process_message(data : Dictionary,sender_id:int):
	if data["message_type"] == "error":
		print("Error from client: ", data["error_type"])
		_process_error(data)
	#action message
	elif data["message_type"] == "card_played":
		if _validate_card_played(sender_id,data):
			send_message_to_everyone.rpc(data)
		else:
			var error_card_played = {
				"message_type" = "error",
				"error_type" = "card_played"
			}
			send_message_to_peer.rpc_id(sender_id,error_card_played)
	elif data["message_type"] == "message":
		if _validate_message(data):
			send_message_to_everyone.rpc(data)
		else:
			var error_message = {
				"message_type" = "error",
				"error_type" = "card_played"
			}
			send_message_to_peer.rpc_id(sender_id,error_message)	
	else:
		print("invalid message")
		
	if session.check_end_game() :
		session.display_session_status()
		var stat = session.get_stat()
		send_message_to_everyone.rpc(stat)

	elif session.check_next_player(sender_id) :
		_send_three_cards_to_a_player(sender_id)
		session.display_session_status()

## At game start, distribute cads to players

func _send_three_cards_to_each_player():
	for peer_id in clients_peer:
		_send_three_cards_to_a_player(peer_id)
	
func _send_three_cards_to_a_player(peer_id):
	var cards_as_dict = session.distribute_three_cards(clients_peer.find(peer_id))
	send_message_to_peer.rpc_id(peer_id,cards_as_dict)



func _validate_message(message: Dictionary) -> bool:
	if message["message"] > 0 and message["message"] <6:
	# message number exist (for nom between 1 and 5)
		return true
	return false

func _validate_card_played(_sender_id :int,message: Dictionary) -> bool:
	
	# The game has not yet begun
	if session.check_status() == false :
		print("SERVER - Error : The game has not yet begun")
		return false
		
	else :
		var is_valid_action = true

		# message has the good format
		is_valid_action = is_valid_action and ( message.has("area") and message.has("card_type") and message.has("family") and message.has("player") )
		if  !is_valid_action :
			print("SERVER - Error : message has not right format")
			return false
			
		if  message.has("id_player_domain") and !session.check_id_player_domain(message["id_player_domain"]):
		if  message.has("id_player_domain") and !session.check_id_player_domain(message["id_player_domain"]):
			print("SERVER - Error : adversary id is the player or does not exist")
			return false
			
		# validate action if it is the good player that have played the card (same client id and same game id)
		is_valid_action = is_valid_action and session.check_player_turn(clients_peer.find(_sender_id), message["player"])
		is_valid_action = is_valid_action and session.check_player_turn(clients_peer.find(_sender_id), message["player"])
		if !is_valid_action :
			print("SERVER - Error : Wrong player who is currently playing")
			return false
		
		# player has a card in hand and it is the right card
		is_valid_action = is_valid_action and session.check_player_hand(message["player"], message["card_type"], message["family"])
		if !is_valid_action :
			print("SERVER - Error : Player has no card or wrong one")
			return false
		
		# he did not put a card in the same area in the turn
		is_valid_action = is_valid_action and session.check_player_area(message["player"], message["area"])
		if !is_valid_action :
			print("SERVER - Error : Player can play this card in this area again")
			return false
		
		if is_valid_action :
			if message["area"] == "queen_table":
				session.place_card(message["player"], message["area"], message["card_type"], message["family"], message["position"])
			elif message["area"] == "our_domain":
				session.place_card(message["player"], message["area"], message["card_type"], message["family"])
			elif message["area"] == "domain":
				session.place_card(message["player"], message["area"], message["card_type"], message["family"], 0, message["id_player_domain"])

		
	return true	

func _process_error(_data: Dictionary):
	pass

func login(data: Dictionary,client_number:int):
	if await validate_login(data):
		var login_success_data = {
			"message_type" = "connexion",
			"login" = data["login"],
			"id" = client_number
		}
		clients[client_number]["status"] = "connected"
		send_message_to_peer.rpc_id(multiplayer.get_remote_sender_id(),login_success_data)
	else:
		var error_login = {
			"message_type" = "error",
			"error_type" = "login",
		}
		send_message_to_peer.rpc_id(multiplayer.get_remote_sender_id(),error_login)

func insertDatabase(data: Dictionary):
	if db_peer.get_ready_state() == WebSocketPeer.STATE_OPEN:
		var json_string = JSON.stringify(data)
		db_peer.send_text(json_string)

func getDatabase(data: Dictionary):
	if db_peer.get_ready_state() == WebSocketPeer.STATE_OPEN:
		var search = {
			"email" = data["email"]
		}
		var json_string = JSON.stringify(search)
		db_peer.send_text(json_string)
		var timeout = 5.0
		var elapsed = 0.0
		while elapsed < timeout:
			db_peer.poll()
			if return_database != "":
				break
			await get_tree().create_timer(0.1).timeout
			elapsed += 0.1

		if return_database != "":
			var response = JSON.parse_string(return_database)
			return_database = ""
			if response != null:
				return response
			else:
				return {"message_type":"error","error_type":"JSON_parse"}
		return {"message_type":"error","error_type":"database_connexion"}
		

func validate_login(data: Dictionary) -> bool:
	
	#var client_data = await getDatabase(data)
	#if client_data.has("password") and data["password"] == client_data["password"]:
	if  data["password"] == "password":
		return true
	return false

func connect_to_database():
	var err = db_peer.connect_to_url(db_url)
	if err == OK:
		print("Connected to Flask-SocketIO server!")
	else:
		print("Failed to connect to Flask-SocketIO server")
