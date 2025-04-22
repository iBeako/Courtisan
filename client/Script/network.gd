extends Node
signal error_card_played(message)

@onready var game = preload("res://Scene/main.tscn")
@onready var menu_principal = preload("res://Scene/menu_principal.tscn")
@onready var signin_page = preload("res://Scene/login.tscn")
@onready var waiting = preload("res://Scene/Waiting.tscn")
@onready var join = preload("res://Scene/Join_game.tscn")
enum family {
	butterfly = 0,
	frog = 1,
	bird = 2,
	bunny = 3,
	deer = 4,
	fish = 5
}
var hand = []
var card_types = ["normal", "noble", "espion", "garde", "assassin"]
var families = ["butterfly", "frog", "bird", "bunny", "deer", "fish"]
enum PlayZoneType {PLAYER, ENEMY, FAVOR, DISFAVOR}
var zone = ["Joueur","Ennemie","Faveur","Disgrâce"]

#connexion:
#{"message_type:"connexion","login":"login","password":"password"}
#create_account:
#{"message_type":"create_account","username":"username","email":"email",password":"password","is_active": 0,	"total_games_played" : 0"pic_profile":0}
#id:
#{"message_type":"id","your_id":}
#change_profile
#{"message_type:"change_profile","username":"username","pic_profile":1}

#find_lobby:
#{"message_type:"find_lobby"}
#create_lobby:
#{"message_type:"create_lobby","id_player":id,"name":"name","number_of_player":number_of_player,"have_password":1}
#{"message_type:"create_lobby","id_player":id,"name":"name","number_of_player":number_of_player,"have_password":0,"password":"password"}
#join_lobby:
#{"message_type:"join_lobby","id_lobby":id_lobby}
#{"message_type:"join_lobby","id_lobby":id_lobby,"password":"password"}
#start_lobby:
#{"message_type:"start_lobby","id_lobby":id_lobby}
#quit_lobby:
#{"message_type:"quit_lobby","id_lobby":id_lobby,id_player":id}

const white_missions = [
	"Vous devez posseder au moins 2 assassins",
	"Vous devez posseder au moins 3 nobles",
	"Vous devez posseder au moins 3 espions",
	"Vous devez posseder au moins 4 gardes",
	
	"Vous devez posseder moins de carpes que votre voision de gauche",
	"Vous devez posseder moins de crapauds que votre voision de gauche",
	"Vous devez posseder moins de cerfs que votre voision de gauche",
	"Vous devez posseder moins de rossignols que votre voision de gauche",
	"Vous devez posseder moins de papillons que votre voision de gauche",
	"Vous devez posseder moins de lièvres que votre voision de gauche",
]

const blue_missions = [
	"Les lièvres doivent être en disgrâce à la cours",
	"Les crapauds doivent être en disgrâce à la cours",
	"Les cerfs doivent être en disgrâce à la cours",
	"Les carpes doivent être en disgrâce à la cours",
	"Les papillons doivent être en disgrâce à la cours",
	"Les rossignols doivent être en disgrâce à la cours",

	"3 familles, au maximum, doivent être dans la lumière à la cours",
	"Une famille doit avoir au moins 5 cartes au-dessous du tapis de jeu",
	"Au moins 2 familles, doivent être en disgrace à la cours",
	"Au moins 1 cartes de chaque famille doit être au-dessous du tapis de jeu",
]

#card_played:
#{"message_type":"card_played","player":1,"card_type":"normal","family":"deer","area":"queen_table","position":1} card in the light
#{"message_type":"card_played","player":1,"card_type":"normal","family":"deer","area":"queen_table","position":-1} card out of favor
#{"message_type":"card_played","player":1,"card_type":"normal","family":"deer","area":"our_domain"}
#{"message_type":"card_played","player":1,"card_type":"normal","family":"deer","area":"domain","id_player_domain":"2"}
#action:
#{"message_type":"action","player":1,"card_type":"assassin","family":"deer",area":"queen_table","card_killed_type":"normal","card_killed_family":"deer"}
#message:
#{"message_type":"message","player":1,"message":1}
#error:
#{"message_type":"error","error_type":"action"} -> unknown action : ask to redo action
#{"message_type":"error","error_type":"message"} ->  unknown message: do nothing
#{"message_type":"error","error_type":"connection"} -> connection not down: no connection
#{"message_type":"error","error_type":"command"} -> unknown command : do nothing
#connexion:
#{"message_type:"connexion","login":"login","password":"password"}
#player_turn:
#{"message_type:"player_turn","id_player":id}

var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()

var port: int = 19001 #connection to VM when connected to eduroam or osiris
#var port: int = 10001
var address: String = "wss://185.155.93.105:%d" % port #connection to VM when connected to eduroam or osiris
#var address: String = "wss://localhost:%d" % port
var tls_options

var turn_player: int
var id_lobby: int = -1
var in_game = false

var deck_reference
var message_manager
var taskbar_reference 

var peer_id: int
var pseudo: String
var id: int
var username: String
var my_profil_pic: int
var clients = []

func _ready():
	var client_trusted_cas = load("res://certificates/certificate.crt")
	var client_tls_options = TLSOptions.client(client_trusted_cas, "Courtisans")
	peer.create_client(address, client_tls_options)
	multiplayer.multiplayer_peer = peer
	print("Client connected to server at %s" % address)

func close_connection():
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		peer.close()
		pseudo = ""
		username = ""
		id = 0
		my_profil_pic = 0
		in_game = false
		id_lobby = -1
		turn_player = 0
		get_tree().change_scene_to_packed(signin_page)
		print("Client connection closed")

func _on_message_sent(message: Dictionary) -> void:
	send_message_to_server.rpc_id(1, message)


@rpc("any_peer")
func send_message_to_server(data: Dictionary):
	print("error cannot receive this type of message only server can")
	print(" ", data)
	
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
	if data["message_type"] == "error":
			process_error(data)
	elif data["message_type"] == "connexion":
		username = data["username"]
		pseudo = data["pseudo"]
		my_profil_pic = data["pic_profile"]
		peer_id = data["peer_id"]
		print("has been logged")
		get_tree().change_scene_to_packed(menu_principal)
		
	elif data["message_type"] == "account_created":
		print("account created")
		get_tree().change_scene_to_packed(signin_page)
		while get_tree().current_scene == null:
			await get_tree().process_frame
		var root = get_tree().current_scene
		var popup_scene = load("res://Scene/popup_msg.tscn")
		var popup_instance = popup_scene.instantiate()
		root.add_child(popup_instance)
		popup_instance.show_msg("account created")
		
	if in_game == false:
		if data["message_type"] == "find_lobby":
			var current_scene = get_tree().current_scene
			if current_scene == null or current_scene.scene_file_path != join.resource_path:
				get_tree().change_scene_to_packed(join)
				while get_tree().current_scene == null:
					await get_tree().process_frame
			#var join_scene = get_tree().current_scene
			if current_scene.has_method("print_lobby") and data.has("lobbies"):
				current_scene.print_lobby(data["lobbies"])
			
		elif data["message_type"] == "join_lobby":
			id_lobby = data["id_lobby"]
			clients = data["clients"]
			get_tree().change_scene_to_packed(waiting)
			while get_tree().current_scene == null:
				await get_tree().process_frame
			var current_scene = get_tree().current_scene	
			if current_scene.has_method("instantiate_waiting_scene"):
				for i in clients.size():
					current_scene.instantiate_waiting_scene(clients[i][1])
				
		elif data["message_type"] == "start_game":
			in_game = true
			get_tree().change_scene_to_packed(game)
			if_start_game()
			
		elif data["message_type"]  == "change_profil":
			my_profil_pic = data["pic_profile"]	
			pseudo = data["pseudo"]	
			
		elif data["message_type"] == "before_start":
			clients = data["clients"]
			for i in clients.size():
				if clients[i][0] == peer_id:
					id = i
				
		elif data["message_type"] == "quit_lobby":
			clients = data["clients"]
			get_tree().change_scene_to_packed(waiting)
			while get_tree().current_scene == null:
				await get_tree().process_frame
			var current_scene = get_tree().current_scene	
			if current_scene.has_method("instantiate_waiting_scene"):
				for i in clients.size():
					current_scene.instantiate_waiting_scene(clients[i][1])
			########if_end_game()
			
	elif in_game == true and id_lobby > 0:
		if data["message_type"] == "card_played":
			process_card_played(data)
			
		elif data["message_type"] == "message":
			put_message_in_chat(data)	
			
		elif data["message_type"] == "player_turn":
			print("player turn : ", data)
			deck_reference.number_of_cards = data["number_of_cards"]
			turn_player = data["id_player"]
			
		elif data["message_type"] == "hand":
			hand.clear()
			var cards = [
				["first_card_family", "first_card_type"],
				["second_card_family", "second_card_type"],
				["third_card_family", "third_card_type"]
			]
			for card in cards:
				var new_card = [data[card[0]], data[card[1]]]
				hand.append(new_card)
				
			print("CLIENT : As player ",id,", I received hand : ", hand)
			deck_reference.draw_cards(hand)
			
		elif data["message_type"] == "mission":
			print("white mission : ", white_missions[data["white_mission"]])
			print("blue mission : ", blue_missions[data["blue_mission"]])
			
		elif data["message_type"] == "final_score":
			print("Final scores : ", data)
			get_tree().change_scene_to_file("res://Scene/fin_partie.tscn")
			#get_tree().change_scene_to_packed(menu_principal)
		else:
			print("invalid message")
		
	
func on_create_Account(login:String,email:String,password:String):
	var message = Account.createAccount(login,email,password)
	send_message_to_server.rpc_id(1,message)
	
func on_login_Account(email:String,password:String):
	var message = Account.loginAccount(email,password)
	send_message_to_server.rpc_id(1,message)

func change_profile_picture(login:String,picture_id:int):
	var message = Account.changePic(login,picture_id)
	send_message_to_server.rpc_id(1,message)
	
func if_start_game():
	message_manager = $"/root/Main/MessageManager"
	deck_reference = $"/root/Main/Deck"
	taskbar_reference = $"/root/Main/Taskbar"

func if_end_game():
	message_manager.clear()
	deck_reference.clear()
		
func put_message_in_chat(_data:Dictionary):
	pass
	
func process_card_played(data:Dictionary):
	
	if data["player"] != id:
		if data["area"] == 0:
			data["area"] = 1
		elif data["area"] == 1:
			data["area"] = 0
	var writting_message = "CLIENT - Player %d" % id + " : player %d "  % data["player"] + " has put %s" % data["card_type"] + " %s" % data["family"]+ " in %s" % data["area"]
	taskbar_reference.print_action("Le joueur %d a placé un %s %s dans %s" % [data["player"] + 1, card_types[data["card_type"]], data["family"] if data["card_type"] != Global.CardType.SPY else "", zone[data["area"]]])
	
	if data.has("position"):
		if data["position"] > 0:
			writting_message = writting_message + " in the light"
			writting_message = writting_message + data["id_adversary"]
	print(writting_message)
	message_manager.add_card_to_zone(data["family"],data["card_type"],data["area"])
	
	if data["player"] != id:
		#message_manager.add_card_to_zone(data["family"],data["card_type"],data["area"])
		
		print("----",data)
		
func get_hand() -> Array:
	return hand

func _play_card( type_card, family, area, id_domain: int = -1):
	var message = {}
	if area == PlayZoneType.PLAYER :
		message = {
			"message_type": "card_played",
			"id_lobby":id_lobby,
			"player": id,
			"family": family,
			"card_type": type_card,
			"area":area,
		}
	elif area == PlayZoneType.FAVOR or area == PlayZoneType.DISFAVOR :
		message = {
			"message_type": "card_played",
			"id_lobby":id_lobby,
			"player": id,
			"family": family,
			"card_type": type_card,
			"area":area
		}
	elif area == PlayZoneType.ENEMY :
		message = {
			"message_type": "card_played",
			"id_lobby":id_lobby,
			"player": id,
			"family": family,
			"card_type": type_card,
			"area":area,
			"id_player_domain":id_domain,
		}
	else :
		print("CLIENT Error : Action unknown")
	send_message_to_server(message)

func process_error(data:Dictionary):
	var popup_scene = load("res://Scene/popup_msg.tscn")
	var popup_instance = popup_scene.instantiate()
	
	var root = get_tree().current_scene
	root.add_child(popup_instance)
	
	var msg = data.get("error_type", "An unknown error occurred.")
	popup_instance.show_msg(msg)
