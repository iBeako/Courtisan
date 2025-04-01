extends Node

var db_peer: WebSocketPeer = WebSocketPeer.new()
var db_url: String = "ws://pdocker:12345/ws"

var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
var port: int = 10001

const MAX_CLIENT: int = 2
var number_of_client: int = 0

var return_database: String = ""
var clients = []

var tls_cert: X509Certificate
var tls_key: CryptoKey
var server_tls_options

var session = []
var number_of_session: int = 0
#load("res://Script/session.gd").new(MAX_CLIENT) # a session specific to a port
var global = preload("res://Script/global.gd").new()
var HashPassword = preload("res://Script/password.gd")






func _onready():
	tls_key = load("res://certificates/private.key")
	tls_cert = load("res://certificates/certificate.crt")
	server_tls_options = TLSOptions.server(tls_key, tls_cert)

func _ready():
	_onready()
	#peer.create_server(port, "0.0.0.0", server_tls_options) #connection to VM when connected to eduroam or osiris
	peer.create_server(port, "*", server_tls_options)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	print("Server started and listening on port %d" % port)
	connect_to_database()

func _process(_delta):
	if db_peer.get_ready_state() == WebSocketPeer.STATE_OPEN:
		db_peer.poll()
		while db_peer.get_available_packet_count() > 0:
			var packet = db_peer.get_packet()
			return_database = packet.get_string_from_utf8()

# connexion function
## between client and server
func _on_peer_disconnected(peer_id: int):
	var client_indice
	for i in range(number_of_client):
		if clients[i]["peer_id"] == peer_id:
			client_indice = i
			
	clients.remove_at(client_indice)
	number_of_client -= 1

func _on_peer_connected(peer_id: int):
	print("New client connected with id: %d" % peer_id)
	
	clients[number_of_client] = {
		"peer_id":peer_id,
		"status":"unlogged",
		"session_id":-1,
		"id_client_in_game":-1
	}
	number_of_client += 1

func createLobby(message: Dictionary,peer_id:int):
	var return_message = await addLobbyDatabase(message)
	if return_message != null and return_message.has("id_lobby"):
		session.append(load("res://Script/session.gd").new(return_message["id_lobby"],message["number_of_player"],message["name"]))
		var ind_player_in_session = session[number_of_session]._add_player(peer_id)
		var ind = find_indice_client(peer_id)
		clients[ind]["session_id"] = return_message["id_lobby"]
		clients[ind]["id_client_in_game"] = ind_player_in_session
		number_of_session += 1
	else:
		print("error, lobby not created")

# trouve tous les lobbys ouvert du jeu
func findLobby(message: Dictionary):
	if db_peer.get_ready_state() == WebSocketPeer.STATE_OPEN:
		var json_string = JSON.stringify(message)
		db_peer.send_text(json_string)
		var allLobby = await getDatabase(message)
		if allLobby != null :
			return allLobby

func addLobbyDatabase(message: Dictionary):
	if db_peer.get_ready_state() == WebSocketPeer.STATE_OPEN:
		var json_string = JSON.stringify(message)
		db_peer.send_text(json_string)
		var id_session = await getDatabase(message)
		if id_session != null :
			return id_session
		
func joinLobby(message: Dictionary,peer_id:int):
	if db_peer.get_ready_state() == WebSocketPeer.STATE_OPEN:
		var json_string = JSON.stringify(message)
		db_peer.send_text(json_string)
		var return_message = await getDatabase(message)
		if(return_message != null  and return_message.has("id_lobby")):
			var indice_tab_session = find_indice_session(return_message["id_lobby"])
			var ind_player_in_session = session[indice_tab_session]._add_player(peer_id)
			var indice_player = find_indice_client(peer_id)
			clients[indice_player]["session_id"] = return_message["id_lobby"]
			clients[indice_player]["id_client_in_game"] = ind_player_in_session
		else:
			return {"type_of_message":"error","error":"lobby_not_found"}
			
func startLobby(message:Dictionary,id_tab_lobby:int,peer_id:int):
	if session[id_tab_lobby].check_game_start(message["id_lobby"],peer_id):
		session[id_tab_lobby].load_game() # load game of the session
		_send_three_cards_to_each_player(message["id_lobby"])
		var turn = {"message_type":"player_turn","id_player":session[id_tab_lobby].current_player_id,"number_of_cards":session[id_tab_lobby].card_stack._get_card_number()}
		print("turn :" ,turn["id_player"])
		send_message_to_everyone.rpc(turn) 
				
## between server and database		
func connect_to_database():
	await get_tree().create_timer(5.0).timeout
	var err = db_peer.connect_to_url(db_url)
	var state = db_peer.get_ready_state()
	while state == WebSocketPeer.STATE_CONNECTING:
		state = db_peer.get_ready_state()
		db_peer.poll()
	if err == OK:
		if db_peer.get_ready_state() == WebSocketPeer.STATE_OPEN:
			print("Connected to python API server!")
		else: 
			print("no connection to database")
	else:
		print("Failed to connect to python API server")


#message between server and client
@rpc("any_peer")
func send_message_to_server(data: Dictionary):
	if data != null and data.has("message_type"):
		var sender_id = multiplayer.get_remote_sender_id()
		var i = find_indice_client(sender_id)
		if i != -1 and clients[i]["status"] == "connected":
			print("Client %d sent a %s", [data["player"], data["message_type"]])
			print(" ", data)
			if clients[i]["session_id"] != -1:
				process_message(data,sender_id,i)
			else:
				process_message_lobby(data,sender_id)
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

@rpc("authority")
func send_message_to_peer(data: Dictionary):
	print("error cannot receive this type of message only client can")
	print(" ", data)

@rpc("authority")
func send_message_to_everyone(data : Dictionary):
	print("error cannot receive this type of message only client can")
	print(" ", data)




func send_message_to_all_lobby(id_lobby:int,data:Dictionary):
	for 

#process message
func process_message(data : Dictionary,sender_id:int,client_indice:int):
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

	elif session.check_next_player(find_indice_client(sender_id)) :
		_send_three_cards_to_a_player(sender_id)
		session.display_session_status()
		var turn = {"message_type":"player_turn","id_player":session.current_player_id,"number_of_cards":session.card_stack._get_card_number()}
		print("turn :" ,turn["id_player"])
		send_message_to_everyone.rpc(turn)

func find_indice_client(id:int) ->int:
	for i in range(number_of_client):
		if clients[i]["peer_id"] == id:
			return i
	return -1

func find_indice_session(id_session:int)->int:
	for i in range(number_of_session):
		if session[i].session_id == id_session:
			return i
	return -1

func find_id_player_in_game(ind_tab_session,peer_id):
	for ind in session[ind_tab_session].player:
		if ind["peer_id"] == peer_id :
			return ind["id"]

func _send_three_cards_to_each_player(session):
	var ind_tab_session = find_indice_session(session)
	for peer_id in session[ind_tab_session].clients_peer:
		_send_three_cards_to_a_player(peer_id)
	
func _send_three_cards_to_a_player(peer_id,ind_tab_session):
	var cards_as_dict = session[ind_tab_session].distribute_three_cards(clients_peer.find(peer_id))
	send_message_to_peer.rpc_id(peer_id,cards_as_dict)

func _validate_message(message: Dictionary) -> bool:
	if message["message"] > 0 and message["message"] <6:
	# message number exist (for nom between 1 and 5)
		return true
	return false

func _validate_card_played(ind_tab_session:int,sender_id :int,message: Dictionary) -> bool:
	# The game has not yet begun
	if session[ind_tab_session].check_status() == false :
		print("SERVER - Error : The game has not yet begun")
		return false
		
	else :
		var is_valid_action = true
		
		# message has the good format
		is_valid_action = is_valid_action and ( message.has("area") and message.has("card_type") and message.has("family") and message.has("player") )
		if  !is_valid_action :
			print("SERVER - Error : message has not right format")
			return false
			
		if  message.has("id_player_domain") and !session[ind_tab_session].check_id_player_domain(message["id_player_domain"]):
			print("SERVER - Error : adversary id is the player or does not exist")
			return false
			
		# validate action if it is the good player that have played the card (same client id and same game id)
		is_valid_action = is_valid_action and session[ind_tab_session].check_player_turn(clients.find(sender_id), message["player"])
		if !is_valid_action :
			print("SERVER - Error : Wrong player who is currently playing")
			return false
		
		# player has a card in hand and it is the right card
		is_valid_action = is_valid_action and session[ind_tab_session].check_player_hand(message["player"], message["card_type"], message["family"])
		if !is_valid_action :
			print("SERVER - Error : Player has no card or wrong one")
			return false
		
		# he did not put a card in the same area in the turn
		is_valid_action = is_valid_action and session[ind_tab_session].check_player_area(message["player"], message["area"])
		if !is_valid_action :
			print("SERVER - Error : Player can play this card in this area again")
			return false
		
		if is_valid_action :
			if message["area"] == 2 or  message["area"] == 3:
				session[ind_tab_session].place_card(message["player"], message["area"], message["card_type"], message["family"])
			elif message["area"] == 0:
				session[ind_tab_session].place_card(message["player"], message["area"], message["card_type"], message["family"])
			elif message["area"] == 1:
				session[ind_tab_session].place_card(message["player"], message["area"], message["card_type"], message["family"])#, 0, message["id_player_domain"])
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
		var json_string = JSON.stringify(data)
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
	var client_data = await getDatabase(data)
	if client_data.has("password") and client_data.has("salt"):
		var data_hashed = HashPassword.HashPassword(data["password"],client_data["salt"])
		if data_hashed == client_data["password"]:
			return true
	#if  data["password"] == "password":
		#return true
	return false

func receive_all_lobby():
	pass
	
func test_if_is_empty():
	pass
