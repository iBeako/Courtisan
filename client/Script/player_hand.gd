extends Node2D

# Signal emitted when the player's hand is empty
signal hand_emptied  

# Path to the card scene resource
const CARD_SCENE_PATH = "res://Scene/card.tscn"

# List to store the cards in the player's hand
var player_hand = []

# Variables for card positioning
var center_screen_x
var CARD_WIDTH = 95
var HAND_Y_POSITION = 940

# Function to add a card to the player's hand
func add_card_to_hand(card):
	if card not in player_hand:
		# Insert the card at the beginning of the hand
		player_hand.insert(0, card)
		update_hand_position()
	else:
		# Animate card back to its starting position if it's already in hand
		animate_card_position(card, card.starting_position)

# Function to check if the player's hand is empty
func is_hand_empty():
	return len(player_hand) == 0

# Function to update the position of cards in the hand
func update_hand_position():
	for i in range(player_hand.size()):
		var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		var card = player_hand[i]
		card.starting_position = new_position
		animate_card_position(card, new_position)

# Function to calculate the X position of a card in the hand
func calculate_card_position(index):
	var total_width = (player_hand.size() - 1) * CARD_WIDTH
	center_screen_x = get_viewport().size.x / 4 + 100
	var x_offset = center_screen_x + index * CARD_WIDTH - total_width / 2
	return x_offset

# Function to animate a card's movement to a new position
func animate_card_position(card, new_position):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, 0.1)

# Function to remove a card from the player's hand
func remove_card_from_hand(card):
	if card in player_hand:
		# Remove the card from the hand
		player_hand.erase(card)
		update_hand_position()
		# Emit signal if the hand is now empty
		if player_hand.is_empty():
			emit_signal("hand_emptied")
