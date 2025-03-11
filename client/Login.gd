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

static func hashData(data:String):
	var hashContext = HashingContext.new()
	hashContext.start(HashingContext.HASH_SHA256)
	hashContext.update(data.to_utf8_buffer())
	var hashed = hashContext.finish()
	return hashed.hex_encode()
