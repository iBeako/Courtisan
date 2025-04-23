extends Control

@onready var button = $Refresh
@onready var vbox = $ScrollContainer/VBoxContainer
@onready var menu = preload("res://Scene/menu_principal.tscn")
@onready var line_lobby_scene = preload("res://Scene/LigneLobby.tscn")
@onready var arrow = $TextureButton
var lobby_count = 0  # Compteur pour incrémenter les labels
var lobby_label
var creator_label
var numberofPlayer_label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().debug_collisions_hint = true  # Visualiser les zones cliquables
	if not button.pressed.is_connected(_on_refresh_pressed):
		button.pressed.connect(_on_refresh_pressed)
	if not arrow.pressed.is_connected(_on_texture_button_pressed):
		arrow.pressed.connect(_on_texture_button_pressed)
	var message = Lobby.findLobby()
	Network.send_message_to_server.rpc_id(1,message)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func clear_lobby_list():
	for child in vbox.get_children():
		child.queue_free()

func print_lobby(lobby_data:Array):
	clear_lobby_list()
	print("test: ")
	for data in lobby_data:
		print(data)
		if data.has("creator"):
			var line = line_lobby_scene.instantiate()
			var lobby_name : String = data.get("name", "Unnamed")
			var creator_name : String = str(data.get("game_id", "???"))  # You can replace with real creator if added later
			var player_count : String = str(data.get("current_players", 0)) + " / " + str(data.get("num_players", 0))
			var game_id : int = data.get("game_id", -1)
			line.set_lobby_data(lobby_name, creator_name, player_count,game_id)
			vbox.add_child(line)
		
func _on_refresh_pressed():
	var message = Lobby.findLobby()
	Network.send_message_to_server.rpc_id(1,message)


func _on_texture_button_pressed() -> void:
	print("click on texture button")
	get_tree().change_scene_to_file("res://Scene/menu_principal.tscn")
