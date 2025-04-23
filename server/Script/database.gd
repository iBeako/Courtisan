extends Node

var return_database: String = ""

func sendDatabase(data: Dictionary):
	if Network.db_peer.get_ready_state() == WebSocketPeer.STATE_OPEN:
		var json_string = JSON.stringify(data)
		Network.db_peer.send_text(json_string)

func getDatabase():
	if Network.db_peer.get_ready_state() == WebSocketPeer.STATE_OPEN:
		var timeout = 5.0
		var elapsed = 0.0
		while elapsed < timeout:
			Network.db_peer.poll()
			if return_database != "":
				break
			await get_tree().create_timer(0.1).timeout
			elapsed += 0.1
		if return_database != "":
			var response = JSON.parse_string(return_database)
			return_database = ""
			print(response)
			if response != null:
				return response
			else:
				return {"message_type":"error","error_type":"JSON_parse"}
		return {"message_type":"error","error_type":"database_connexion"}
