extends Node

var db_peer: WebSocketPeer = WebSocketPeer.new()
var db_url: String = "ws://pdocker:12345/ws"

var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
var port: int = 10001
var addr: String = "0.0.0.0" #connection to VM when connected to eduroam or osiris
#var addr: String = "*" #for localhost

var number_of_client: int = 0
var clients = {}

var tls_cert: X509Certificate
var tls_key: CryptoKey
var server_tls_options

var session = {}
var number_of_session: int = 0
#load("res://Script/session.gd").new(MAX_CLIENT) # a session specific to a port

var AI_class = load("res://Script/AI.gd")
var AIs = []

func _onready():
	tls_key = load("res://certificates/private.key")
	tls_cert = load("res://certificates/certificate.crt")
	server_tls_options = TLSOptions.server(tls_key, tls_cert)

func _ready():
	_onready()
	 
	peer.create_server(port, addr, server_tls_options)
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
			Database.return_database = packet.get_string_from_utf8()

func _exit_tree():
	pass

# connexion function
## between client and server
func _on_peer_disconnected(peer_id: int):
	var _id = clients[peer_id]
	print("Player ", _id, " has disconnected")
	if clients["peer_id"]["status"] == "in_game":
		clients["peer_id"]["status"] = "replaced_by_ai"
		#ai not work for now
		#var ai = AI_class.new()
		#ai.id_player = _id
		#ai.id_AI = AIs.size()
		#add_child(ai)
		#AIs.append(ai)
	else:
		clients.erase(peer_id)
		number_of_client -= 1
	var message_to_database = {
		"message_type" = "change_status",
		"username" = clients[peer_id]["username"],
		"is_active" = 0
	}
	Database.sendDatabase(message_to_database)
	var return_message = await Database.getDatabase()
	print(return_message)

func _on_peer_connected(peer_id: int):
	print("New client connected with id: %d" % peer_id)
	
	clients[peer_id] = {
		"peer_id":peer_id,
		"status":"unlogged",
		"session_id":-1,
		"id_client_in_game":-1,
		"pic_profile":-1,
		"pseudo":"not_connected",
		"username":"not_connected"
	}
	print(clients[peer_id])
	number_of_client += 1

func createLobby(message: Dictionary,peer_id:int):
	var return_message = await addLobbyDatabase(message)
	print(return_message)
	if return_message != null and return_message.has("game_id"):
		var new_session = load("res://Script/session.gd").new()
		new_session.init(return_message["game_id"], message["number_of_player"], message["name"], clients[peer_id]["pseudo"])
		session[return_message["game_id"]] = new_session
		var ind_player_in_session = session[return_message["game_id"]]._add_player(peer_id)
		clients[peer_id]["session_id"] = return_message["game_id"]
		clients[peer_id]["id_client_in_game"] = ind_player_in_session
		number_of_session += 1
		var forclient = {
			"message_type":"join_lobby",
			"id_lobby":return_message["game_id"],
			"id_player":ind_player_in_session
		}
		return forclient
		
	else:
		print("error, lobby not created error database")

# trouve tous les lobbys ouvert du jeu
func findLobby(message):
	if db_peer.get_ready_state() == WebSocketPeer.STATE_OPEN:
		Database.sendDatabase(message)
		var allLobby = await Database.getDatabase()
		if allLobby != null :
			for i in range (allLobby["lobbies"].size()):
				allLobby["lobbies"][i]["creator"] = session[allLobby["lobbies"][i]["game_id"]]["creator"]
			return allLobby["lobbies"]
		else:
			print("no lobby found")
	else:
		print("no connection to database")

func addLobbyDatabase(message: Dictionary):
	if db_peer.get_ready_state() == WebSocketPeer.STATE_OPEN:
		Database.sendDatabase(message)
		var return_message = await Database.getDatabase()
		if return_message != null and return_message.has("id_lobby"):
			return return_message["id_lobby"]
		
func joinLobby(message: Dictionary,peer_id:int):
	if db_peer.get_ready_state() == WebSocketPeer.STATE_OPEN:
		Database.sendDatabase(message)
		var return_message = await Database.getDatabase()
		if(return_message != null  and return_message.has("id_lobby")):
			var ind_player_in_session = session[return_message["id_lobby"]]._add_player(peer_id)
			clients[peer_id]["session_id"] = return_message["id_lobby"]
			clients[peer_id]["id_client_in_game"] = ind_player_in_session
			# creer un message à renvoyer
		else:
			return {"type_of_message":"error","error":"lobby_not_found"}
			
func startLobby(message:Dictionary,peer_id:int):
	var id_lobby = message["id_lobby"]
	if session[id_lobby].check_game_start():
		var start_lobby_message_database = {
			"type_of_message":"start_game",
			"id_lobby":id_lobby
		}
		Database.sendDatabase(start_lobby_message_database)
		var return_message = await Database.getDatabase()
		session[id_lobby].load_game()
		 # load game of the session
		for client in clients:
			if client["id_lobby"] == id_lobby:
				client["status"] = "in_game"
		var turn = {"message_type":"player_turn","id_player":session[id_lobby].current_player_id,"number_of_cards":session[id_lobby].card_stack._get_card_number()}
		print("turn :" ,turn["id_player"])
		send_message_to_lobby(id_lobby,turn) 
				
## between server and database		
func connect_to_database():
	await get_tree().create_timer(2.0).timeout
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
	print(data)
	if data != null and data.has("message_type"):
		var sender_id = multiplayer.get_remote_sender_id()
		if  clients[sender_id] != null and clients[sender_id]["status"] == "connected":
			print("Client %d sent a %s", [data["username"], data["message_type"]])
			print(" ", data)
			if clients[sender_id]["session_id"] == -1:
				ProcessMessage.process_message_not_ingame(data,sender_id)
			else:
				ProcessMessage.process_message_ingame(data,sender_id)
		elif data["message_type"] == "connexion":
			login(data,sender_id)
		elif data["message_type"] == "createAccount":
			insert_Account(data,sender_id)
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

func send_message_to_lobby(id_lobby:int,data:Dictionary):
	for peer_id in session[id_lobby].client_peer:
		send_message_to_peer.rpc_id(peer_id,id_lobby,data)

func login(data: Dictionary,peer_id:int):
	var log = await validate_login(data)
	if (log.has("status") and log["status"] == "success"):
		var login_success_data = {
			"message_type" = "connexion",
			"username" = log["username"],
			"pseudo" = log["pseudo"],
			"pic_profile" = log["pic_profile"]
		}
		var last_peer_id = search_peer_id_by_username(log["username"])
		if last_peer_id == -1 or clients[last_peer_id]["status"] != "replaced_by_ai":
			clients[peer_id]["status"] = "connected"
			clients[peer_id]["pic_profile"] = log["pic_profile"]
			clients[peer_id]["username"] = log["username"]
			clients[peer_id]["pseudo"] = log["pseudo"]
		else:
			clients[peer_id] = clients[last_peer_id]
			clients[peer_id]["peer_id"]= peer_id
		#session[clients[peer_id]["id_lobby"]].client.replace
			
			clients.erase(last_peer_id)
			
		var message_to_database = {
			"message_type" = "change_status",
			"username" = clients[peer_id]["username"],
			"is_active" = 1
		}
		await get_tree().create_timer(2.0).timeout
		Database.sendDatabase(message_to_database)
		var return_message = await Database.getDatabase()
		print(return_message)
		send_message_to_peer.rpc_id(peer_id,login_success_data)
	else:
		send_message_to_peer.rpc_id(peer_id,log)

func search_peer_id_by_username(username:String):
	for client in clients.values():
		if client["username"] == username:
			return client["peer_id"]
	return -1

func insert_Account(data:Dictionary,peer_id:int):
	var salt = Login.GenerateSalt()
	data["salt"] = salt
	data["password"] = Login.HashPassword(data["password"],salt)
	print(data)
	Database.sendDatabase(data)
	var return_data = await Database.getDatabase()
	if return_data.has("status") :
		if return_data["status"] == "success":
			return_data["message_type"] = "account_created"
			send_message_to_peer.rpc_id(peer_id,return_data)
		else:
			var message = {
				"type_of_message":"error",
				"type_of_error":"account not created"
			}
			send_message_to_peer.rpc_id(peer_id,message)
	else:
		var message = {
			"type_of_message":"error",
			"type_of_error":"error in message received"
		}
		print(message)
	
func validate_login(data: Dictionary) -> Dictionary:
	var client_data
	if addr == "*" :
		var salt = Login.GenerateSalt()
		client_data = {
			"salt" = salt,
			"password" =  Login.HashPassword(data["password"],salt),
			"pic_profile" = 0
		}
	else:
		Database.sendDatabase(data)
		client_data = await Database.getDatabase()
	if client_data.has("password") and client_data.has("salt"):
		var data_hashed = Login.HashPassword(data["password"],client_data["salt"])
		if data_hashed == client_data["password"]:
			return client_data
		else:
			var mes_error = {
				"message_type":"error",
				"error_type":"not the good password"
			}
			return mes_error
	else:
		var mes_error = {
			"message_type":"error",
			"error_type":"account not found"
		}
		return mes_error

	
