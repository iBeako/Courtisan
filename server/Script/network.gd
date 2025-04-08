extends Node

var db_peer: WebSocketPeer = WebSocketPeer.new()
var db_url: String = "ws://pdocker:12345/ws"

var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
var port: int = 10001

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
			Database.return_database = packet.get_string_from_utf8()

# connexion function
## between client and server
func _on_peer_disconnected(peer_id: int):
	var _id = clients[peer_id]
	print("Player ", _id, " has disconnected")
	var ai = AI_class.new()
	ai.id_player = _id
	ai.id_AI = AIs.size()
	add_child(ai)
	AIs.append(ai)
	clients.erase(peer_id)
	number_of_client -= 1

func _on_peer_connected(peer_id: int):
	print("New client connected with id: %d" % peer_id)
	
	clients[peer_id] = {
		"peer_id":peer_id,
		"status":"unlogged",
		"session_id":-1,
		"id_client_in_game":-1,
		"image_profil":-1
	}
	number_of_client += 1

func createLobby(message: Dictionary,peer_id:int):
	var return_message = await addLobbyDatabase(message)
	if return_message != null and return_message.has("id_lobby"):
		var new_session = load("res://Script/session.gd").new()
		new_session.init(return_message["id_lobby"], message["number_of_player"], message["name"])
		session[return_message["id_lobby"]] = new_session
		var ind_player_in_session = session[return_message["id_lobby"]]._add_player(peer_id)
		clients[peer_id]["session_id"] = return_message["id_lobby"]
		clients[peer_id]["id_client_in_game"] = ind_player_in_session
		number_of_session += 1
	else:
		print("error, lobby not created")

# trouve tous les lobbys ouvert du jeu
func findLobby():
	if db_peer.get_ready_state() == WebSocketPeer.STATE_OPEN:
		var message = {
			"action" = "getAllLobby"
		}
		var json_string = JSON.stringify(message)
		db_peer.send_text(json_string)
		var allLobby = await Database.getDatabase(message)
		if allLobby != null :
			return allLobby

func addLobbyDatabase(message: Dictionary):
	if db_peer.get_ready_state() == WebSocketPeer.STATE_OPEN:
		var json_string = JSON.stringify(message)
		db_peer.send_text(json_string)
		var return_message = await Database.getDatabase(message)
		if return_message != null and return_message.has("id_lobby"):
			return return_message["id_lobby"]
		
func joinLobby(message: Dictionary,peer_id:int):
	if db_peer.get_ready_state() == WebSocketPeer.STATE_OPEN:
		var json_string = JSON.stringify(message)
		db_peer.send_text(json_string)
		var return_message = await Database.getDatabase(message)
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
		session[id_lobby].load_game() # load game of the session
		var turn = {"message_type":"player_turn","id_player":session[id_lobby].current_player_id,"number_of_cards":session[id_lobby].card_stack._get_card_number()}
		print("turn :" ,turn["id_player"])
		send_message_to_lobby(id_lobby,turn) 
				
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
		if  clients[sender_id] != null and clients[sender_id]["status"] == "connected":
			print("Client %d sent a %s", [data["player"], data["message_type"]])
			print(" ", data)
			if clients[sender_id]["session_id"] != -1:
				ProcessMessage.process_message_not_ingame(data,sender_id)
			else:
				ProcessMessage.process_message_ingame(data,sender_id)
		elif data["message_type"] == "connexion":
			login(data,sender_id)
		elif data["message_type"] == "createAccount":
			Database.insertDatabase(data)
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

func _process_error(_data: Dictionary):
	pass

func login(data: Dictionary,peer_id:int):
	if await validate_login(data):
		var login_success_data = {
			"message_type" = "connexion",
			"login" = data["login"],
		}
		clients[peer_id]["status"] = "connected"
		send_message_to_peer.rpc_id(peer_id,login_success_data)
	else:
		var error_login = {
			"message_type" = "error",
			"error_type" = "login",
		}
		send_message_to_peer.rpc_id(peer_id,error_login)

func validate_login(data: Dictionary) -> bool:
	var client_data = await Database.getDatabase(data)
	if client_data.has("password") and client_data.has("salt"):
		var data_hashed = Login.HashPassword(data["password"],client_data["salt"])
		if data_hashed == client_data["password"]:
			return true
	#if  data["password"] == "password":
		#return true
	return false

	
