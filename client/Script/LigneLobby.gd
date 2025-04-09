extends Control

@onready var lobby_label = get_node("HBoxContainer/MarginContainer/LobbyName")
@onready var creator_label = get_node("HBoxContainer/MarginContainer2/CreatorName")

func set_lobby_data(index: int):
	if lobby_label and creator_label:  # Vérifie que les labels existent
		lobby_label.text = "Lobby " + str(index)
		creator_label.text = "Creator " + str(index)
	else:
		print("Labels not found!")
