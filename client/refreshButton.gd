extends Control

@onready var button = $Refresh
@onready var vbox = $ScrollContainer/VBoxContainer
@onready var menu = preload("res://Scene/menu_principal.tscn")
@onready var arrow = $TextureButton
var lobby_count = 0  # Compteur pour incrémenter les labels
var lobby_label
var creator_label
var numberofPlayer_label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().debug_collisions_hint = true  # Visualiser les zones cliquables
	button.pressed.connect(_on_refresh_pressed)
	arrow.pressed.connect(_on_texture_button_pressed)
	var message = Lobby.findLobby()
	Network.send_message_to_server.rpc_id(1,message)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func print_lobby(message:Dictionary,number_of_lobby:int):
	for i in range(number_of_lobby):
		var scene_to_instance = load("res://Scene/LigneLobby.tscn").instantiate()
		$ScrollContainer/VBoxContainer.add_child(scene_to_instance)
		lobby_label = scene_to_instance.get_node("HBoxContainer/LobbyName")
		creator_label = scene_to_instance.get_node("HBoxContainer/CreatorName")
		numberofPlayer_label = scene_to_instance.get_node("HBoxContainer/NumberofPlayerName")
		lobby_label.text = message[i]["name"]
		creator_label.text = message[i]["creator"]
		numberofPlayer_label.text = message[i]["current_players"] + "/" + message[i]["numberofPlayer"]
		
func _on_refresh_pressed():
	var message = Lobby.findLobby()
	Network.send_message_to_server.rpc_id(1,message)


func _on_texture_button_pressed() -> void:
	print("click on texture button")
	get_tree().change_scene_to_packed(menu)
