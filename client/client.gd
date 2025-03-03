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
#connection:
#{"message_type":"connection","login":,"password":""}


var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
var port: int = 443 
var address: String = "wss://localhost:%d" % port  # Change 'localhost' to the future address when needed
var id: int
var tls_options

func _ready():
	#var tls_cert: X509Certificate = load("res://certificates/certificate.crt")
	var client_trusted_cas = load("res://certificates/certificate.crt")
	var client_tls_options = TLSOptions.client(client_trusted_cas,"Courtisans")
	#tls_options = TLSOptions.client_unsafe()
	peer.create_client(address, client_tls_options)
	#peer.create_client(address)
	multiplayer.multiplayer_peer = peer
	print("Client connected to server at %s" % address)

func _process(_delta):
	peer.poll()
	while peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		print("Raw packet received: ", packet)
		var packet_string = packet.get_string_from_utf8()
		if not packet.is_valid_utf8():
			print("Invalid UTF-8 data received")
		print("Decoded string: ", packet_string)
		_process_packet(packet_string)

func send_message(message: String):
	peer.put_packet(message.to_utf8_buffer())

func _process_packet(packet: String):
	var json = JSON.new()
	var error_json = json.parse(packet)
	var message = json.data
	if error_json == OK:
		
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
		print(json.get_error_line())
		print(json.get_error_message())
		print("Invalid JSON received")
		
func _process_error(message: Dictionary):
	if message["error_type"] == "card_played":
		print("redo an action")
	
