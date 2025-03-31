extends Node
class_name Account

static func createAccount(login:String,email:String,password:String,):
	var strip_edges_password = password.strip_edges(true, true)
	var message = {
		"message_type":"createAccount",
		
		"login": login.strip_edges(true,true),
		"email": email.strip_edges(true,true),
		"password" : strip_edges_password,
		"is_active": 0,
		"total_games_played" : 0
	}
	return message	
	
static func loginAccount(email:String,password:String) :
	var strip_edges_password = password.strip_edges(true, true)
	var message = {
		"message_type":"connexion",
		"email": email.strip_edges(true,true),
		"password" : strip_edges_password
	}
	return message
