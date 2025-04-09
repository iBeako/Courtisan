extends Node
class_name Account

static func createAccount(login:String,email:String,password:String,):
	var strip_edges_password = password.strip_edges(true, true)
	var message = {
		"message_type":"createAccount",
		"username": login.strip_edges(true,true),
		"email": email.strip_edges(true,true),
		"pseudo":"name",
		"password" : strip_edges_password,
		"is_active": 0,
		"total_games_played" : 0,
		"pic_profile": 0
	}
	return message	
	
static func loginAccount(login:String,password:String) :
	var strip_edges_password = password.strip_edges(true, true)
	var message = {
		"message_type":"connexion",
		"password" : strip_edges_password
	}
	if '@' in login:
		message["email"] = login.strip_edges(true,true)
	else:
		message["username"] = login.strip_edges(true,true)
	return message

static func hashData(data:String):
	var hashContext = HashingContext.new()
	hashContext.start(HashingContext.HASH_SHA256)
	hashContext.update(data.to_utf8_buffer())
	var hashed = hashContext.finish()
	return hashed.hex_encode()

static func changePic(email:String,pic_id:int) :
	var message = {
		"message_type":"change_profile",
		"email": email.strip_edges(true,true),
		"pic_profile" : pic_id
	}
	return message
