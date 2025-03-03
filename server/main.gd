extends Node


var server: Node
var clients: Array

func _ready():
	# Initialize server
	server = load("res://server.gd").new()
	add_child(server)
	print("Test start")	

	
