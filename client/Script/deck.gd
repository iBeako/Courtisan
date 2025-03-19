extends Node2D

const CARD_SCENE_PATH = "res://Scene/card.tscn"

# List of cards in the deck
var deck_cards = ["carte","carte","carte","carte","carte","carte","carte","carte"]  

# Card color types
var card_colors = ["Papillons", "Crapauds", "Rossignols", "Lièvres", "Cerfs", "Carpes"]  

# Enum for different card types
enum TYPES {
	Normal,
	Assassin,
	Espion,
	Garde,
	Noble
}

var Hand_Count = 3  # Number of cards a player can hold

@onready var player_hand = get_node("../PlayerHand")  # Reference to the player's hand node

func _ready() -> void:
	$Area2D.collision_layer = 1<<4  # Set the collision layer for Area2D
	randomize()  # Initialize random number generation

# Function to draw cards and assign them a random type
func draw_cards(message):
	print("Drawing cards...")

	if not player_hand:
		print("Error: player_hand not found")
		return
	
	var card_scene = preload(CARD_SCENE_PATH)  # Load the card scene
	var i = 0
	# Continue drawing until the player’s hand has the required number of cards
	while player_hand.player_hand.size() < Hand_Count:
		var new_card = card_scene.instantiate()  # Instantiate a new card

		new_card.card_color = message[i][1]  # Set the card’s color
		new_card.card_type = message[i][0]   # Assign a default type
		
		# new_card.apply_card_texture()  # Update the texture immediately (commented out)

		new_card.z_index = 5  # Set the rendering order
		new_card.name = "carte_" + card_colors[message[i][0]]  # Give the card a unique name
		i+= 1
		$"../CardManager".add_child(new_card)  # Add the card to the CardManager
		
		player_hand.add_card_to_hand(new_card)  # Add the card to the player's hand
	
	$"../CardManager".start_turn()  # Start the turn after drawing cards

# Function to get a random card color
func get_random_card_color() -> String:
	return card_colors[randi() % card_colors.size()]  # Return a random card color
