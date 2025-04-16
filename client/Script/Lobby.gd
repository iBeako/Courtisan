extends Node
class_name Lobby
#{"message_type:"create_lobby","id_player":id,"name":"name","number_of_player":number_of_player,"have_password":1}
static func createPublicLobby(id_player:int,name:String,number_of_player:int):
	var message = {
		"message_type":"create_lobby",
		
		"id_player": id_player,
		"name": name.strip_edges(true,true),
		"number_of_player" : number_of_player,
		"have_password": 0
	}
	return message		

static func createPrivateLobby(id_player:int,name:String,number_of_player:int,password:String):
	var message = {
		"message_type":"create_lobby",
		
		"id_player": id_player,
		"name": name.strip_edges(true,true),
		"number_of_player" : number_of_player,
		"have_password": 1,
		"password":password.strip_edges(true,true)
	}
	return message	

static func findLobby():
	var message = {
		"message_type":"find_lobby",
		"username":Network.username
	}
	return message	
	
static func joinPublicLobby(id_lobby:int):
	var message = {
		"message_type":"join_lobby",
		"id_lobby":id_lobby
	}
	return message
	
static func joinPrivateLobby(id_lobby:int,password:String):
	var message = {
		"message_type":"join_lobby",
		"id_lobby":id_lobby,
		"password":password
	}
	return message	

static func startLobby():
	var message = {
		"message_type":"start_lobby"
	}
	return message	
	
static func quitLobby():
	var message = {
		"message_type":"quit_lobby"
	}
	return message	
