extends Node

const CLIENT_COUNT = 5
var clients: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize clients
	clients = []
	for i in range(CLIENT_COUNT):
		var client = load("res://client.gd").new()
		add_child(client)
		clients.append(client)
		await get_tree().create_timer(1.0).timeout
	
	# Send test messages from clients
	for i in range(CLIENT_COUNT):
		var message = {"message_type":"card_played","player":i,"card_type":"normal","family":"deer","area":"queen_table","position":1}
		var message_converted_in_json = JSON.stringify(message)
		clients[i].send_message(message_converted_in_json)
		
	# Wait a moment to process messages
	await get_tree().create_timer(1.0).timeout
	print("Test interaction completed")	
