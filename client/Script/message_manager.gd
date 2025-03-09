extends Node
class_name MessageManager

signal message_sent(message)

signal card_played()

func send_card_played(player: int, card_type: String, family: String, area: String, position: int = 0, id_player_domain: String = ""):
	var message = {
		"message_type": "card_played",
		"player": player,
		"card_type": card_type,
		"family": family,
		"area": area
	}
	
	if area == "queen_table": # cas ou c'est joue au milieu
		message["position"] = position
	elif area == "domain": # cas ou joue chez un joueur
		message["id_player_domain"] = id_player_domain
	
	_send_message(message)

func send_action(player: int, card_type: String, family: String, area: String, card_killed_type: String = "", card_killed_family: String = "", id_adversary: String = ""):
	# uniquement appelee lorsqu'un assassin est joue
	
	var message = {
		"message_type": "action",
		"player": player,
		"card_type": card_type,
		"family": family,
		"area": area
	}
	
	
	message["card_killed_type"] = card_killed_type
	message["card_killed_family"] = card_killed_family

	_send_message(message)

#func send_table_update(area: String, card_type: String, family: String, position: int = 0, player: int = 0):
	#var message = {
		#"message_type": "table",
		#"area": area,
		#"card_type": card_type,
		#"family": family
	#}
	#
	#if area == "queen_table":
		#message["position"] = position
	#elif area == "domain":
		#message["player"] = player
	#
	#_send_message(message)

func send_player_message(player: int, message_id: int):
	var message = {
		"message_type": "message",
		"player": player,
		"message": message_id
	}
	_send_message(message)

func send_error(error_type: String):
	var message = {
		"message_type": "error",
		"error_type": error_type
	}
	_send_message(message)

func _send_message(message: Dictionary):
	var json_message = JSON.stringify(message)
	#print(json_message)  # Pour le débogage
	emit_signal("message_sent", json_message)
	# Ici, vous pouvez ajouter la logique pour envoyer le message via le réseau
