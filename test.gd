extends Node

const CLIENT_COUNT = 2
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
		
		
	# test radom values
	var _card_types = ["normal", "noble", "guard"]
	var _families = ["butterfly", "frog", "bird", "bunny", "deer", "fish"]
	var _positions = [1, -1]

	var adv = 0
	for j in range(10) : 
		for i in range(CLIENT_COUNT):
			if i == 0 :
				adv = 1
			else :
				adv = 0
			clients[i].test_play_card(0, "queen_table", _positions[randi() % _positions.size()] )
			await get_tree().create_timer(0.5).timeout
			clients[i].test_play_card(1, "our_domain")
			await get_tree().create_timer(0.5).timeout
			clients[i].test_play_card(2, "domain", 0, adv ) # third argument is only for position at queen's table (0 as default)
			await get_tree().create_timer(0.5).timeout
		#await get_tree().create_timer(0.5).timeout
	
	# Print responses (handled in client.gd)
	print("Test interaction completed")
