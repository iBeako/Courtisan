extends Node

const CLIENT_COUNT = 5
var clients: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize clients
	print_tree()

	var client = load("res://network.gd").new()
	add_child(client)

	await get_tree().create_timer(1.0).timeout
	
	# Send test messages from clients
	var message = {"message_type":"card_played","player":0,"card_type":"normal","family":"deer","area":"queen_table","position":1}
	var message_converted_in_json = JSON.stringify(message)
	client.send_message(message_converted_in_json)
	client.send_message(message_converted_in_json)

	await get_tree().create_timer(1.0).timeout
	# Wait a moment to process messages
	await get_tree().create_timer(1.0).timeout
	print("Test interaction completed")	
