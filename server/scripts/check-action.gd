extends Node2D

var original_move
var dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# Send back an error to the client who perform the action with its own adresse
func send_back_error(adress: String):
	pass
	
# Send the same request as the player who perform the action to the whole game session
func broadcasting():
	# ask game_server to broadcast original message which is valided move
	# if last card of the player then specific action
	# if last player before end game then call end_game()
	pass

# ARGS : Player ID, a card (family, ability), section of desk (queen's table, opponent's, player's)
# Compare to the data in temporary file
func check_card_placement(json_string):
	dictionary = %json_processing.JSON_into_dictionary(json_string)
	# implementation
	pass
	
# send all usefull statistic
func end_game():
	pass
