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
	check_turn()
	
func check_turn() :
	if session.check_player_turn(id_player) :
		play()
	else :
		print("AI wait turn")
		
func play() :
	var zones = [0,1,2,3]
	for card in session.players[id_player][7] :
		if card[0] == true :
			var zone = zones.pop_front()
			var id_enemy = -1
			if zone == 1 :
				id_enemy = (id_player+1)%session.players.size()
			if session.place_card(id_player, zone, card[2][0], card[2][1], id_enemy) and session.check_player_turn(id_player):
				broadcast(card[2][0], card[2][1], zone, id_enemy)
				await get_tree().create_timer(3.0).timeout
		else :
			zones.erase(card[1])
	check_end()
	await get_tree().create_timer(3.0).timeout

func broadcast(card_type: int, family: String, area: int, id_enemy: int):
	var message = {
		"message_type": "card_played",
		"player": id_player,
		"card_type": card_type,
		"family": family,
		"area": area
	}
	if area == 1: # cas ou joue chez un joueur
		message["id_player_domain"] = id_enemy
	network.send_message_to_everyone.rpc(message)

func check_end():
	if session.check_end_game() :
		var scores = session.get_final_score()
		print(scores)
		network.send_message_to_everyone.rpc(scores)
		status = false

	elif session.check_next_player(id_player) :
		_get_hand_cards_for_AI()
		var turn = {"message_type":"player_turn","id_player":session.current_player_id}
		print("turn :" ,turn["id_player"])
		network.send_message_to_everyone.rpc(turn)
		

func _get_hand_cards_for_AI() :
	if !session.card_stack._no_more_card_in_stack():
		var cards = session.card_stack._retrieve_three_cards()
		session.players[id_player][7][0] = ([true, -1, cards[0]])
		session.players[id_player][7][1] = ([true, -1, cards[1]])
		session.players[id_player][7][2] = ([true, -1, cards[2]])

func _process(_delta):
	if session.check_player_turn(id_player) and status == true:
		play()
