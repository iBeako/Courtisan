extends Node

var hand = []

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
			print("CLIENT - Error from server : %s" % message["error_type"])
			_process_error(message)
		#id message
		elif message.has("message_type")  and message["message_type"] == "id":
			id = message.your_id
			print("CLIENT : I have been saved as player ", id)
		#distribut hand
		elif message.has("message_type")  and message["message_type"] == "hand":
			hand.clear()
			
			var cards = [
				["first_card_family", "first_card_type"],
				["second_card_family", "second_card_type"],
				["third_card_family", "third_card_type"]
			]
			for card in cards:
				var new_card = [message[card[0]], message[card[1]]]
				hand.append(new_card)
			
			print("CLIENT : As player ",id,", I recieved hand : ", hand)
		#action message
		elif message.has("message_type")  and message["message_type"] == "card_played":
			var writting_message = "CLIENT - Player %d" % id + " : player %d "  % message["player"] + " has put %s" % message["card_type"] + " %s" % message["family"]+ " in %s" % message["area"]
			if message.has("position"):
				if message["position"] > 0:
					writting_message = writting_message + " in the light"
				else:
					writting_message = writting_message + " out of favor"
			if message.has("id_adversary"):
					writting_message = writting_message + message["id_adversary"]
			print(writting_message)
		elif message.has("message_type") and message["message_type"] == "message":
			print("PLAYER ",id," : Player %s "  % message["player"] + " has said message %d" % message["message"] )
		else:
			print("invalid message")	
	else:
		print("Invalid JSON received")

func _process_error(message: Dictionary):
	if message["error_type"] == "card_played":
		print("redo an action")
	
func _play_card(id_hand_card, area, id_domain: int = -1):
	print("\nCLIENT - NEW ACTION ------------------------------------------------------")
	if id_hand_card < 3 and id_hand_card >= 0 :
		if area >= 0 and area < global.play_zone_type.size() :
			var typ = hand[id_hand_card][0]
			var fam = hand[id_hand_card][1]
			var message = {}
			if area == global.PlayZoneType.PLAYER :
				print("CLIENT : Player ", id," want to play ", hand[id_hand_card], " in ", global.play_zone_type[area])
				message = {
					"message_type": "card_played",
					"player": id,
					"family": fam,
					"card_type": typ,
					"area":area,
				}
			elif area == global.PlayZoneType.FAVOR or area == global.PlayZoneType.DISFAVOR :
				print("CLIENT : player ", id," want to play ", hand[id_hand_card], " in ", global.play_zone_type[area])
				message = {
					"message_type": "card_played",
					"player": id,
					"family": fam,
					"card_type": typ,
					"area":area
				}
			elif area == global.PlayZoneType.ENEMY :
				print("CLIENT : player ", id," want to play ", hand[id_hand_card], " in domain player ", id_domain)
				message = {
					"message_type": "card_played",
					"player": id,
					"family": fam,
					"card_type": typ,
					"area":area,
					"id_player_domain":id_domain,
				}
			else :
				print("CLIENT Error : Action unknown")
			var message_converted_in_json = JSON.stringify(message)
			send_message(message_converted_in_json)
		else :
			print("CLIENT - Error : Play zone not valid")
	else :
		print("CLIENT - Error : Card identifier not valid")
