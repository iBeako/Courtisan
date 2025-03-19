extends Node


var server: Node

func _ready():
	print_tree()# Initialize server
	var test = get_node("/root/Main/network")
	server = load("res://Script/network.gd").new()
	add_child(server)
	print("Test start")	
