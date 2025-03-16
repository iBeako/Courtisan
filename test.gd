extends Node

func _ready():
	#await _smok_test()
	#await get_tree().create_timer(1.0).timeout
	#await _unit_test()
	#await get_tree().create_timer(1.0).timeout
	await _integrity_test()

func _smok_test():
	print("=========================================================================")
	print("=== SMOK TEST ===")
	var server = load("res://server/server.gd").new()
	add_child(server)
	var client_1 = load("res://client/client.gd").new()
	add_child(client_1)
	var client_2 = load("res://client/client.gd").new()
	add_child(client_2)
	
	
	await get_tree().create_timer(0.5).timeout
	server.queue_free()
	client_1.queue_free()
	client_2.queue_free()
	
	print('=== SMOK TEST COMPLETED ===\n')
	
func _unit_test():
	print("=========================================================================")
	print("=== UNIT TEST ===")
	var server = load("res://server/server.gd").new()
	add_child(server)
	var client_1 = load("res://client/client.gd").new()
	add_child(client_1)
	await get_tree().create_timer(0.5).timeout
	var client_2 = load("res://client/client.gd").new()
	add_child(client_2)
	await get_tree().create_timer(0.5).timeout
	
	
	# should return error
	client_1._play_card(-1,  0)
	print("TEST : should be an error")
	client_1._play_card(0,  -1)
	print("TEST : should be an error")
	## should pass
	client_1._play_card(0,  2)
	await get_tree().create_timer(0.5).timeout
	print("TEST : should pass")
	
	# should return error
	client_1._play_card(0, 2)
	await get_tree().create_timer(0.5).timeout
	print("TEST : should be an error")
	# should pass
	client_1._play_card(1,  0)
	await get_tree().create_timer(0.5).timeout
	print("TEST : should pass")
	
	# should return error
	client_1._play_card(2, 1, -1)
	await get_tree().create_timer(0.5).timeout
	print("TEST : should be an error")
	client_1._play_card(2, 1, 0)
	await get_tree().create_timer(0.5).timeout
	print("TEST : should be an error")
	## should pass
	client_1._play_card(2, 1, 1)
	await get_tree().create_timer(0.5).timeout
	print("TEST : should pass")
	
	client_1._play_card(0, 2)
	print("TEST : should be an error")
	await get_tree().create_timer(0.5).timeout
	
	server.queue_free()
	client_1.queue_free()
	client_2.queue_free()
	
	print('=== UNIT TEST COMPLETED ===\n')
	
func _integrity_test():
	print("=========================================================================")
	print("=== INTEGRITY TEST COMPLETED ===")
	var server = load("res://server/server.gd").new()
	add_child(server)
	
	var clients = []
	for i in range(global.MAX_CLIENT):
		var client = load("res://client/client.gd").new()
		add_child(client)
		clients.append(client)
		await get_tree().create_timer(0.5).timeout
		
	for j in range(global.LOOP_COUNT) : 
		for i in range(global.MAX_CLIENT):
			var pos = 2 if i%2 == 0 else 3
			clients[i]._play_card(0, pos)
			await get_tree().create_timer(0.5).timeout
			clients[i]._play_card(1, 0)
			await get_tree().create_timer(0.5).timeout
			clients[i]._play_card(2, 1, ((i+1)%global.MAX_CLIENT))
			await get_tree().create_timer(0.5).timeout
	
	print("=== INTEGRITY TEST COMPLETED ===\n")
