extends MarginContainer

@onready var lobby_label = $HBoxContainer/LobbyName
@onready var creator_label = $HBoxContainer/CreatorName
@onready var nb_of_player_label = $HBoxContainer/NumberofPlayer
@onready var join_button = $HBoxContainer/Button
var game_id: int = -1

func set_lobby_data(lobby_name: String,creator_name:String,number_of_player:String,id_lobby:int):
	game_id = id_lobby
	if lobby_label and creator_label and number_of_player:  # Vérifie que les labels existent
		lobby_label.text = lobby_name
		creator_label.text = creator_name
		nb_of_player_label.text = number_of_player
	else:
		print("Labels not found!", lobby_label, creator_label, number_of_player)

func _on_join_pressed():
	var message := {
		"message_type": "join_lobby",
		"id_lobby": game_id,
		"username": Network.username
	}
	Network.send_message_to_server.rpc_id(1, message)
