extends Node


var server: Node
var clients: Array

func _ready():
	print_tree()# Initialize server
	server = load("res://network.gd").new()
	add_child(server)
	print("Test start")	

	
