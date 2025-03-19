extends Node2D

# Collision mask constants
const COLLISION_MASK_CARD = 1<<3
const COLLISION_MASK_DECK = 1<<4

# Signals for mouse interactions
signal left_mouse_button_clicked
signal left_mouse_button_released

# References to other game objects
var card_manager_reference
var deck_reference

# Load the main menu scene
var menu_scene : PackedScene = load("res://Scene/menu_principal.tscn")

func _ready() -> void:
	# Initialize references to CardManager and Deck
	card_manager_reference = $"../CardManager"
	deck_reference = $"../Deck"
func _input(event):
	# Handle left mouse button events
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			emit_signal("left_mouse_button_clicked")
			raycast_at_cursor()
		else:
			emit_signal("left_mouse_button_released")
	
	# Handle Escape key press to return to the main menu
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().change_scene_to_packed(menu_scene)

# Function to perform a raycast at the cursor position
func raycast_at_cursor():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	var result = space_state.intersect_point(parameters)
	
	# Check if the raycast hit something
	if result.size() > 0:
		var result_collision_layer = result[0].collider.collision_layer
		
		# If a card is detected, start dragging it
		if (result_collision_layer & COLLISION_MASK_CARD) != 0:
			var card_found = result[0].collider.get_parent()
			if card_found:
				card_manager_reference.start_drag(card_found)
		
		# If a deck is detected, draw a card
		#elif (result_collision_layer & COLLISION_MASK_DECK) != 0:
		#	deck_reference.draw_cards()
		#probably add a message to ask new cards
