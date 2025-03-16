extends Node


var server: Node

func _ready():
	print_tree()# Initialize server
	server = load("res://Script/network.gd").new()
	add_child(server)
	print("Test start")	

	
