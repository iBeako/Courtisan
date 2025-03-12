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
#connexion:
#{"message_type:"connexion","login":"login","password":"password"}

var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
#var port: int = 19001 #connection to VM when connected to eduroam or osiris
var port: int = 10001
#var address: String = "wss://185.155.93.105:%d" % port #connection to VM when connected to eduroam or osiris
var address: String = "wss://localhost:%d" % port
var id: int
var username
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

@rpc("any_peer")
func send_message_to_server(data: Dictionary):
	print("error cannot receive this type of message only server can")
	print(" ", data)
	#var sender_id = multiplayer.get_remote_sender_id()
	#print("Client %d sent a %s" % [data.player, data.message_type])
	#print(" ", data)
	#process_message(data)
	
@rpc("authority")
func send_message_to_peer(data: Dictionary):
	if data != null and data.has("message_type"):
		var sender_id = multiplayer.get_remote_sender_id()
		if sender_id == 1:
			print("server send a ", data["message_type"])
			print(" ", data)
			process_message(data)
		else:
			print("error send_message_to_peer")

@rpc("authority")
func send_message_to_everyone(data : Dictionary):
	if data != null and data.has("message_type"):
		var sender_id = multiplayer.get_remote_sender_id()
		if sender_id == 1:
			print("Broadcasting ", data["message_type"])
			print(" ", data)
			process_message(data)
		else:
			print("error send_message_to_peer")
			
			
func process_message(data:Dictionary):
	if data["message_type"] == "id":
		id = data.your_id
	elif data["message_type"] == "card_played":
		process_card_played(data)
	elif data["message_type"] == "message":
		put_message_in_chat(data)	
	elif  data["message_type"] == "table":
		process_table(data)
	elif data["message_type"] == "error":
		process_error(data)
	elif data["message_type"] == "connexion":
		process_connexion(data)
	else:
		print("invalid message")
		
func on_create_Account(login:String,email:String,password:String):
	var account = Account.createAccount(login,email,password)
	send_message_to_server.rpc_id(1,account)
	
func on_login_Account(email:String,password:String):
	var account = Account.loginAccount(email,password)
	send_message_to_server.rpc_id(1,account)

		
func put_message_in_chat(_data:Dictionary):
	pass
	
func process_card_played(_data:Dictionary):
	pass
	
func process_table(_data:Dictionary):
	pass

func process_connexion(data:Dictionary):
	username = data["login"]
	id = data["id"]
	print("has been logged")

func process_error(data:Dictionary):
	if data["error_type"] == "unconnected":
		print("error on password or loggin, retry")
