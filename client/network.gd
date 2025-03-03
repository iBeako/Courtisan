extends Node

enum family {
	butterfly = 0,
	frog = 1,
	bird = 2,
	bunny = 3,
	deer = 4,
	fish = 5
}

var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
var port: int = 443
var address: String = "wss://localhost:%d" % port
var id: int
var tls_options

func _ready():
	var client_trusted_cas = load("res://certificates/certificate.crt")
	var client_tls_options = TLSOptions.client(client_trusted_cas, "Courtisans")
	peer.create_client(address, client_tls_options)
	multiplayer.multiplayer_peer = peer
	print("Client connected to server at %s" % address)

func close_connection():
	if peer.get_ready_state() == WebSocketPeer.STATE_OPEN:
		peer.close()
		print("Client connection closed")

func send_message(message: String):
	if multiplayer.is_server():
		broadcast_message.rpc(message)
	else:
		server_receive_message.rpc_id(1, message)

@rpc("any_peer")
func server_receive_message(message: String):
	print("Server received message: %s" % message)
	broadcast_message.rpc(message)

@rpc("any_peer")
func broadcast_message(message: String):
	print("Broadcasting message: %s" % message)

@rpc("any_peer")
func client_send_card_played(data: Dictionary):
	print("Client sent card played: ", data)

@rpc("any_peer")
func broadcast_card_played(data: Dictionary):
	print("Broadcasting card played: ", data)

@rpc("authority")
func send_error(peer_id: int, error_message: Dictionary):
	print("Sending error to peer %d: %s" % [peer_id, error_message])

func _validate_card_played(_data: Dictionary) -> bool:
	return true
