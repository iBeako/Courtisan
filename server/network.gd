extends Node

var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
var port: int = 443
const MAX_CLIENT: int = 5
var number_of_client: int = 0
var tls_cert: X509Certificate = X509Certificate.new()
var tls_key: CryptoKey = CryptoKey.new()
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
	print("Server started and listening on port %d" % port)

func _on_peer_connected(peer_id: int):
	number_of_client += 1
	print("New client connected with id: %d" % peer_id)
	if number_of_client > MAX_CLIENT:
		print("Cannot connect more people in the room")

@rpc("any_peer")
func client_send_card_played(data: Dictionary):
	if _validate_card_played(data):
		broadcast_card_played.rpc(data)
	else:
		send_error.rpc_id(multiplayer.get_remote_sender_id(), {"message_type": "error", "error_type": "action"})

@rpc("any_peer")
func server_receive_message(message: String):
	print("Server received message: %s" % message)
	broadcast_message.rpc(message)

@rpc("any_peer")
func broadcast_message(message: String):
	print("Broadcasting message: %s" % message)

@rpc("any_peer")
func broadcast_card_played(data: Dictionary):
	print("Broadcasting card played: ", data)

@rpc("authority")
func send_error(peer_id: int, error_message: Dictionary):
	print("Sending error to peer %d: %s" % [peer_id, error_message])

func _validate_card_played(_data: Dictionary) -> bool:
	return true
