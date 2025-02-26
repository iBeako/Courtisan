extends Node

var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
var port: int = 12345  # Change this for an internet address in the future
const MAX_CLIENT:int = 5
var number_of_client :int = 0

func _ready():
	peer.create_server(port)  # Listening on specified port
	peer.connect("peer_connected", Callable(self, "_on_peer_connected"))
	multiplayer.multiplayer_peer = peer
	print("Server started and listening on port %d" % port)

func _on_peer_connected(peer_id:int) -> void:
	number_of_client += 1
	print("New client connected with id: %d" % peer_id)
	var welcome = {"message_type":"id","your_id":peer_id}
	var json = JSON.stringify(welcome)
	peer.set_target_peer(peer_id)
	peer.put_packet(json.to_utf8_buffer())
	if number_of_client >= MAX_CLIENT:
		peer.refuse_new_connections = true
		print("cannot connect more people in the room")
		
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
		elif data_dict.has("message_type") and data_dict["message_type"] == "action":
			if _validate_action(packet):
				_broadcast_action(packet)
			else:
				peer.set_target_peer(sender_id)
				var error_message = {"message_type":"error","error_type":"action"}
				packet = JSON.stringify(error_message)
				peer.put_packet(packet.to_utf8_buffer())

func _validate_message(_message: String) -> bool:
	# Always return true for this example
	return true
	
func _validate_action(_message: String) -> bool:
	# Always return true for this example
	return true

func _broadcast_message(message: String):
	peer.set_target_peer(MultiplayerPeer.TARGET_PEER_BROADCAST)
	peer.put_packet(message.to_utf8_buffer())
	
func _broadcast_action(message: String):
	# will change with spy
	peer.set_target_peer(MultiplayerPeer.TARGET_PEER_BROADCAST)
	peer.put_packet(message.to_utf8_buffer())

func _send_error(peer_id: int, error_message: String):
	var error_packet = {"error": error_message}
	var packet = JSON.stringify(error_packet)
	peer.set_target_peer(peer_id)
	peer.put_packet(packet.to_utf8_buffer())
