extends Node

var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
var port: int = 12345
const MAX_CLIENT: int = 5
var number_of_client: int = 0
var clients = {}
var tls_cert: X509Certificate
var tls_key: CryptoKey
var server_tls_options

func _onready():
	tls_key = load("res://certificates/private.key")
	tls_cert = load("res://certificates/certificate.crt")
	server_tls_options = TLSOptions.server(tls_key, tls_cert)

func _ready():
	_onready()
	peer.create_server(port, "*", server_tls_options)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	print("Server started and listening on port %d" % port)

func _on_peer_disconnected(peer_id: int):
	clients.erase(peer_id)

func _on_peer_connected(peer_id: int):
	print("New client connected with id: %d" % peer_id)
	if number_of_client >= MAX_CLIENT:
		print("Cannot connect more people in the room")
	else:
		clients[number_of_client] = {
			"id": number_of_client,
			"peer_id":peer_id
		}
		var data_id = {
			"message_type"="id",
			"your_id"=number_of_client
		}
		number_of_client += 1
		send_message_to_peer.rpc_id(peer_id,data_id)

func send_login(data: Dictionary):
	if validate_login(data):
		var login_success_data = {
			"message_type" = "connexion",
			"username" = data.login,
			"id" = data.id
		}
		send_message_to_peer.rpc_id(multiplayer.get_remote_sender_id(),login_success_data)
	else:
		var error_login = {
			"message_type" = "error",
			"error_type" = "login",
		}
		send_message_to_peer.rpc_id(multiplayer.get_remote_sender_id(),error_login)

@rpc("any_peer")
func send_message_to_server(data: Dictionary):
	if data != null and data.has("message_type"):
		var sender_id = multiplayer.get_remote_sender_id()
		print("Client %d sent a %s", [data["player"], data["message_type"]])
		print(" ", data)
		process_message(data,sender_id)
	else:
		print("error send_message_to_server")
	
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
		if _validate_card_played(data):
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
	elif data["message_type"] == "login":
		if validate_login(data):
			send_login(data)
		
	else:
		print("invalid message")	

func _validate_message(_message: Dictionary) -> bool:
	# massage has the good format
	# message number exist (for nom between 1 and 5)
	return true


func _validate_card_played(_message: Dictionary) -> bool:
	# message has the good format
	# validate action if it is the good player that have played the card (same client id and same id)
	# the player has the card is the hand
	# he did not put a card in the same area in the turn
	# he had a card in hand
	return true

func _process_error(_data: Dictionary):
	pass

func validate_login(_data: Dictionary) -> bool:
	return true
