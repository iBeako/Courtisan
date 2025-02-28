extends Node

const CLIENT_COUNT = 5
var server: Node
var clients: Array

func _ready():
	# Initialize server
	server = load("res://server/server.gd").new()
	add_child(server)
	
	# Initialize clients
	clients = []
	for i in range(CLIENT_COUNT):
		var client = load("res://client/client.gd").new()
		add_child(client)
		clients.append(client)
		await get_tree().create_timer(0.5).timeout
	
	# Wait a moment for connections to establish
	#await get_tree().create_timer(1.0).timeout
	
	# Send test messages from clients
	for i in range(CLIENT_COUNT):
		var message = {"message_type":"card_played","player":i,"card_type":"normal","family":"deer","area":"queen_table","position":1}
		var message_converted_in_json = JSON.stringify(message)
		clients[i].send_message(message_converted_in_json)
		
	# test radom values
	var card_types = ["normal", "noble", "guard"]
	var families = ["butterfly", "frog", "bird", "bunny", "deer", "fish"]
	var positions = [1, -1]

	for i in range(CLIENT_COUNT):
		var message = {
			"message_type": "card_played",
			"player": i,
			"card_type": card_types[randi() % card_types.size()],
			"family": families[randi() % families.size()],
			"area": "queen_table",
			"position": positions[randi() % positions.size()],
		}
		var message_converted_in_json = JSON.stringify(message)
		clients[i].send_message(message_converted_in_json)
		
		# Wait a moment to process messages
		await get_tree().create_timer(1.0).timeout
	
	# Wait a moment to process messages
	await get_tree().create_timer(1.0).timeout
	
	# Print responses (handled in client.gd)
	print("Test interaction completed")
