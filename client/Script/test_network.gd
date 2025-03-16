extends Node

const CLIENT_COUNT = 5
var clients: Array

enum PlayZoneType {PLAYER, ENEMY, FAVOR, DISFAVOR}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize clients
	print_tree()

	var client = load("res://Script/network.gd").new()
	add_child(client)
	
	await get_tree().create_timer(3.0).timeout
	
	# Send test messages from clients
	var _card_types = ["normal", "noble", "guard"]
	var _families = ["butterfly", "frog", "bird", "bunny", "deer", "fish"]
	var _positions = [1, -1]
	var message = {
			"message_type": "card_played",
			"player": 1,
			"card_type": _card_types[randi() % _card_types.size()],
			"family": _families[randi() % _families.size()],
			"area": PlayZoneType.PLAYER,
		}
	client.send_message_to_server.rpc_id(1,message)
	client.send_message_to_server.rpc_id(1,message)
	var login = {"message_type":"connexion","login":"login","password":"password"}
	client.send_message_to_server.rpc_id(1,login)
	client.send_message_to_server.rpc_id(1,message)
	
	client._play_card(_card_types[randi() % _card_types.size()],  _families[randi() % _families.size()], 0)
	client._play_card(_card_types[randi() % _card_types.size()],  _families[randi() % _families.size()], 3)
	
	
	await get_tree().create_timer(1.0).timeout
	# Wait a moment to process messages
	await get_tree().create_timer(1.0).timeout
	print("Test interaction completed")	
