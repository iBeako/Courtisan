extends Node2D

# Variables for screen size and collision masks
var screen_size
const COLLISION_MASK_CARD = 1 << 0
const COLLISION_MASK_CARD_SLOT = 1 << 1
const COLLISION_MASK_ZONE = 1 << 2

# Variables for card dragging and interactions
var card_is_dragged : Card
var is_hovered : bool
var player_hand_reference
var message_manager_reference : MessageManager

# Array to track where the player can play cards (player zone, enemy zone, middle zone)
var can_play = [1, 1, 1] 

# Enum for different play zones
enum PlayZoneType { Joueur, Ennemie, Grace, Disgrace }

func _ready() -> void:
	screen_size = get_viewport_rect().size  # Get screen size
	player_hand_reference = $"../PlayerHand"  # Reference to the player's hand
	message_manager_reference = $"../MessageManager"  # Reference to the message manager
	
	# Connect the input manager's signal for left mouse button release
	$"../inputManager".connect("left_mouse_button_released", on_left_mouse_button_released)
	
# Update function called every frame
func _process(delta: float) -> void:
	if card_is_dragged:
		# Get the mouse position and clamp it within screen bounds
		var mouse_pos = get_global_mouse_position()
		card_is_dragged.global_position = Vector2(clamp(mouse_pos.x, 0, screen_size.x), clamp(mouse_pos.y, 0, screen_size.y))
		card_is_dragged.global_position = mouse_pos  # Move the dragged card to the mouse position

# Function to start dragging a card
func start_drag(card):
	card_is_dragged = card
	card.z_index = 10  # Bring the card to the front layer

# Function to reset player's turn (allow playing in all zones again)
func start_turn():
	can_play = [1, 1, 1]

# Function to handle when a card is released
func end_drag():
	card_is_dragged.z_index = 1  # Reset card layering

	# Check which play zone the card is dropped in
	var card_zone_found : PlayZone = check_zone()
	
	if card_zone_found and not card_is_dragged in card_zone_found.cards_in_zone:
		player_hand_reference.remove_card_from_hand(card_is_dragged)  # Remove the card from the player's hand
		
		# Determine the play area and position
		var area = card_zone_found.Play_ZoneType
		print("Zone type: " + str(area))
		var player_id = get_parent().player_id
		
		# Determine which play zone the card was placed in
		var id_can_play : int
		match area:
			0: # Card played in the player's zone
				id_can_play = 0
			1: # Card played in the enemy's zone
				id_can_play = 1
			_: # Card played in the middle
				id_can_play = 2
		
		# Check if the player can still play in this zone
		if can_play[id_can_play] == 1:
			# Send a message to the server about the played card
			message_manager_reference.send_card_played(player_id, card_is_dragged.card_color, card_is_dragged.card_color, area)
			
			# Add the card to the play zone
			card_zone_found.add_card(card_is_dragged)
			if card_is_dragged.card_type:
				card_is_dragged.hide_card()
			can_play[id_can_play] = 0  # Mark the zone as played
		else:
			# If the player can't play in this zone, return the card to their hand
			player_hand_reference.add_card_to_hand(card_is_dragged)
	else:
		# If no valid zone is found, return the card to the player's hand
		player_hand_reference.add_card_to_hand(card_is_dragged)

	card_is_dragged = null  # Clear the dragged card variable

# Function to connect signals for card hover detection
func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)

# Function triggered when a card is hovered over
func on_hovered_over_card(card):
	if not is_hovered:
		is_hovered = true
		highlight_card(card, true)

# Function triggered when the mouse stops hovering over a card
func on_hovered_off_card(card):
	if not card_is_dragged:
		highlight_card(card, false)
		var new_card_hover = check_card()
		if new_card_hover:
			highlight_card(new_card_hover, true)
		else:
			is_hovered = false
	
# Function to visually highlight a card when hovered
func highlight_card(card, hovered):
	var tween = card.create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	print("Hovered: " + str(hovered))
	if hovered:
		tween.tween_property(card, "scale", Vector2(1.05, 1.05), 0.2)
		await tween.finished
		card.z_index = 2  # Bring the card forward when hovered
	else:
		tween.tween_property(card, "scale", Vector2(1.0, 1.0), 0.2)
		await tween.finished
		card.z_index = 1  # Reset the layering after animation

# Function to check if the mouse is over a card slot
func check_card_slot() -> Node2D:
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null

# Function to check if the mouse is over a play zone
func check_zone() -> PlayZone:
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_ZONE
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null
	
# Function to check if the mouse is over a card
func check_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return get_card_with_highest_index(result)
	return null
	
# Function to find the card with the highest z-index (the topmost card)
func get_card_with_highest_index(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_index = current_card.z_index
			highest_z_card = current_card
	return highest_z_card

# Function triggered when the left mouse button is released
func on_left_mouse_button_released():
	if card_is_dragged:
		end_drag()
