extends Node


var server: Node

func _ready():
	# Initialize server
	server = load("res://Script/network.gd").new()
	server.name = "network"
	add_child(server)
	print_tree()
	print("Test start")	
