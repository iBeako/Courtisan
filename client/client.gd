extends Node

var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
var port: int = 12345
var address: String = "ws://localhost:%d" % port  # Change 'localhost' to the actual address when needed
var id: int
func _ready():
	peer.create_client(address)
	multiplayer.multiplayer_peer = peer
	print("Client connected to server at %s" % address)

func _process(_delta):
	peer.poll()
	while peer.get_available_packet_count() > 0:
		var packet = peer.get_packet().get_string_from_utf8()
		_process_packet(packet)

func send_message(message: String):
	peer.put_packet(message.to_utf8_buffer())

func _process_packet(packet: String):
	var json = JSON.new()
	var error = json.parse(packet)
	if error == OK:
		var message = json.data
		if message.has("error"):
			print("Error from server: %s" % message.error)
		else:
			print("Message from server: %s" % message)
	else:
		print("Invalid JSON received")
