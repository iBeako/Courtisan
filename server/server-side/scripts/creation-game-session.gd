extends Node2D

# to enhance with the beta version with dynamic lobby
var session_id = 12345
var session_player_max = 2

var players = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_player(player_id):
	players.append(player_id)
	GLOBALS.add_player(player_id)
	check_game_start();
	
# PRECOND : Lobby must not be empty
func remove_player(player_id):
	players.erase(player_id)
	GLOBALS.remove_player(player_id)

func check_game_start():
	if players.size() == session_player_max:
		load_game()
		
func load_game():
	# send signal / message to the engine to load data and broadcasting
	print("send signal / message to the engine to load data and broadcasting")
	pass
