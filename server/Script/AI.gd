extends Node
class_name AI

var status = true
var id_AI = -1
var id_player = -1
var network: Node
var session: Node
var global = preload("res://Script/global.gd").new()


func _ready() -> void:
	print("AI takes turn as player ",id_player)
	network = get_parent()
	session = network.session
	check_move()
	
func check_move() :
	if session.check_status() :
		if check_turn() :
			print("<<<<<<<<<<<<<<<<<<")
			play()
			print(">>>>>>>>>>>>>>>>>>")
	
func check_turn() :
	if session.check_player_turn(id_player) :
		return true
	else :
		return false
	
func play() :
	var zones = [0,1,2,3]
	zones.shuffle()
	for card in session.players[id_player][7] :
		if card[0] == true :
			var zone = zones.pop_front()
			if  (zone == 2 and zones.find(3) == -1) or (zone == 3 and zones.find(2) == -1) : 
				break
			var id_enemy = -1
			if zone == 1 :
				id_enemy = (id_player+1)%session.players.size()
			send_action_to_server(id_player, zone, card[2][0], card[2][1], id_enemy)
		zones.erase(card[1])
	
func send_action_to_server(id_player, area, card_type, card_family, id_player_domain) :
	var message = {
		"message_type": "card_played",
		"player": id_player,
		"card_type": card_type,
		"family": card_family,
		"area": area
	}
	if area == 1: # case in player's domain
		message["id_player_domain"] = id_player_domain
	if card_type == 1 : # card is assassin
		message["message_type"] = "action"
		var card = get_card_to_remove(id_player, area, id_player_domain)
		print(card)
		if card != [] and card != null:
			message["target_family"] = card[1]
			message["id_card"] = 0
	print(message)
	network.process_message(message, 1)

func get_card_to_remove(id_player, area, id_player_domain):
	if area == global.PlayZoneType.FAVOR :
		for i in range(7) :
			if !session.queen_table[i][0].is_empty() :
				return session.queen_table[i][0][0]
	elif area == global.PlayZoneType.DISFAVOR :
		for i in range(7) :
			if !session.queen_table[i][1].is_empty() :
				return session.queen_table[i][1][0]
	elif area == global.PlayZoneType.PLAYER :
		for i in range(7) :
			if !session.players[id_player][i].is_empty() :
				return session.players[id_player][i][0]
	elif area == global.PlayZoneType.ENEMY :
		for i in range(7) :
			if !session.players[id_player_domain][i].is_empty() :
				return session.players[id_player_domain][i][0]
	else :
		printerr("get_card_to_remove : No area selected")

func _process(_delta):
	check_move()
