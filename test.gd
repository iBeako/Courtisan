extends Node

const CLIENT_COUNT = 10
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
	
	# Wait a moment for connections to establish
	await get_tree().create_timer(1.0).timeout
	
	# Send test messages from clients
	var j = 0
	for i in range(CLIENT_COUNT):
		var message = {"message_type":"action","player":i,"card":j,"area":"queen_table","position":1}
		j += 1
		var message_converted_in_json = JSON.stringify(message)
		clients[i].send_message(message_converted_in_json)
	
	# Wait a moment to process messages
	await get_tree().create_timer(1.0).timeout
	
	# Print responses (handled in client.gd)
	print("Test interaction completed")
