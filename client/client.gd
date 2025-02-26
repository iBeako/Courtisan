extends Node

enum family {
	butterfly = 0,
	frog = 1,
	bird = 2,
	bunny = 3,
	deer = 4,
	fish = 5
}

#card_played:
#{"message_type":"card_played","player":1,"card_type":"normal","family":"deer","area":"queen_table","position":1} card in the light
#{"message_type":"card_played","player":1,"card_type":"normal","family":"deer","area":"queen_table","position":-1} card out of favor
#{"message_type":"card_played","player":1,"card_type":"normal","family":"deer","area":"our_domain"}
#{"message_type":"card_played","player":1,"card_type":"normal","family":"deer","area":"domain","id_player_domain":"2"}
#action:
#{"message_type":"action","player":1,"card_type":"assassin","family":"deer",area":"queen_table","card_killed_type":"normal","card_killed_family":"deer"}
#{"message_type":"action","player":1,"card_type":"spy","family":"deer",area":"our_domain"}
#{"message_type":"action","player":1,"card":78,"card_type":"spy","family":"deer","area":"adversary_domain","id_adversary":"2""}
#table:
#{"message_type":"table","area":"queen_table","position":1,"card_type":"normal","family":"deer"}
#{"message_type":"table","area":"domain","player":1,"card_type":"normal","family":"deer"}
#message:
#{"message_type":"message","player":1,"message":1}
#id:
#{"message_type":"id","your_id":}
#error:
#{"message_type":"error","error_type":"action"} -> unknown action : ask to redo action
#{"message_type":"error","error_type":"message"} ->  unknown message: do nothing
#{"message_type":"error","error_type":"connection"} -> connection not down: no connection
#{"message_type":"error","error_type":"command"} -> unknown command : do nothing

var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
var port: int = 12345
var address: String = "ws://localhost:%d" % port  # Change 'localhost' to the future address when needed
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
	var error_json = json.parse(packet)
	if error_json == OK:
		var message = json.data
		#error message
		if message.has("message_type") and message["message_type"] == "error":
			print("Error from server: %s" % message["error_type"])
			_process_error(message)
		#id message
		elif message.has("message_type")  and message["message_type"] == "id":
			id = message.your_id
		#action message
		elif message.has("message_type")  and message["message_type"] == "card_played":
			var writting_message = "player %d "  % message["player"] + " has put %s" % message["card_type"] + " family %s" % message["family"]+ " in %s" % message["area"]
			if message.has("position"):
				if message["position"] > 0:
					writting_message = writting_message + " in the light"
				else:
					writting_message = writting_message + " out of favor"
			if message.has("id_adversary"):
					writting_message = writting_message + message["id_adversary"]
			print(writting_message)
		elif message.has("message_type") and message["message_type"] == "message":
			print("player %s "  % message["player"] + " has said message %d" % message["message"] )
		else:
			print("invalid message")	
	else:
		print("Invalid JSON received")

func _process_error(message: Dictionary):
	if message["error_type"] == "card_played":
		print("redo an action")
	
