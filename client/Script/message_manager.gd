extends Node
class_name MessageManager

signal message_sent(message)

signal card_played

const CARD_SCENE_PATH = "res://Scene/card.tscn"

func send_card_played(player: int, card_type: int, family: String, area: int, id_player_domain: int = -1):
	var message = {
		"message_type": "card_played",
		"player": player,
		"card_type": card_type,
		"family": family,
		"area": area
	}

	if area == 1: # cas ou joue chez un joueur
		message["id_player_domain"] = id_player_domain
	_send_message(message)

func send_action(player: int, id_card: int, family: String, area: String, card_killed_type: String = "", card_killed_family: String = "", id_adversary: String = ""):
	# uniquement appelee lorsqu'un assassin est joue
	
	var message = {
		"message_type": "action",
		"player": player,
		"id_card": id_card, # -1 if no card to remove
		"family": family, # if a spy change into "Spy" in purpus to do not revele the family
		"area": area,
		"target_family": family
	}
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

func add_card_to_zone(card_color : String, card_type : int, area : int, id_player : int = -1) -> void:
	var card_scene = preload(CARD_SCENE_PATH)

	var new_card : Card = card_scene.instantiate()  # Instancier la carte
	new_card.card_color = card_color  # Assigner la couleur à la carte
	new_card.card_type = card_type
	new_card.z_index = 10
	$"../CardManager".add_child(new_card)  # Ajouter la carte au CardManager
	new_card.name = "carte"  # Nom de la carte
	var zone : PlayZone
	match area:
		0:
			zone = $"../PlayZone_Joueur"
		1:
			zone = get_parent().search_zone_by_id(id_player)
		2:
			zone = $"../PlayZone_Grace"
		3:
			zone = $"../PlayZone_Disgrace"
		_:
			return
	zone.add_card(new_card)
	card_played.emit() #for labels update


func _send_message(message: Dictionary):
	Network.send_message_to_server.rpc_id(1, message)
	# Ici, vous pouvez ajouter la logique pour envoyer le message via le réseau
