extends Node2D

var PORT = 8080
var peer = WebSocketMultiplayerPeer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print("Attached to ", get_path())
	var err = peer.create_server(PORT)
	if err != OK :
		print("Er: something gose wrong with connexion to the port ", PORT)
	else :
		print("OK : currently listening from port ", PORT)
	
	multiplayer.multiplayer_peer = peer
	print("OK : Multiplayer Peer connection is set on ", PORT)
	
	multiplayer.peer_connected.connect(_on_client_connected)
	multiplayer.peer_disconnected.connect(_on_client_disconnected)

func _on_client_connected(client_id):
	print("Client connected with ID ", client_id)
	%game_session.add_player(client_id)
	print_client_connectes()
	
func _on_client_disconnected(client_id):
	print("Client disconnected with ID ", client_id)
	%game_session.remove_player(client_id)
	print_client_connectes()
	
func print_client_connectes():
	var clients = multiplayer.get_peers()
	print("{ connected clients :", clients, " }")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	multiplayer.poll()



@rpc("any_peer", "reliable")
func receive_message(message):
	var client_id = multiplayer.get_remote_sender_id()
	print("Received : ", message)
	print("From : ", client_id)
	send_message.rpc_id(client_id, "ACK")

@rpc("reliable")
func send_message(message):
	print("Send :", message)


func test_action():
	# id 0 if on queen's table
	var json_string = '''
		{
			"player": {
				"id": 1234,
				"family": "cerf",
				"spec": "noble"
			},
			"on": {
				"id": 4321,
				"family": "carpe",
				"spec": "noble"
			}
		}'''
	%player_action.check_card_placement(json_string)
	
