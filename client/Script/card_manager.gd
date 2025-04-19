extends Node2D



const CARD_SCENE_PATH = "res://Scene/card.tscn"

# Variables for screen size and collision masks
const COLLISION_MASK_CARD = 1 << 0
const COLLISION_MASK_CARD_SLOT = 1 << 1
const COLLISION_MASK_ZONE = 1 << 2

# Variables for card dragging and interactions
var card_is_dragged : Card
var is_hovered: bool = false
var card_hovered: Card

# Définition des couleurs des cartes
var card_colors: Array[String] = ["Papillons", "Crapauds", "Rossignols", "Lièvres", "Cerfs", "Carpes"]

# Définition des zones où le joueur peut jouer
var can_play: Array[int] = [1, 1, 1] 


@onready var affichage_slot_card = get_node("/root/Main/slotMenuCanvas/SlotMenu")


# Références aux autres nodes avec typage
@onready var input_manager_reference: Node = $"../inputManager"
@onready var player_hand_reference: PlayerHand = $"../PlayerHand"
@onready var message_manager_reference: MessageManager = $"../MessageManager"
@onready var change_theme_reference: OptionButton = $"../CanvasLayer/PauseMenu/Panel/MarginContainer/VBoxContainer/Sound/HBoxContainer/OptionButton"


func _ready() -> void:
	input_manager_reference.connect("left_mouse_button_released", end_drag)
	change_theme_reference.connect("item_selected",update_cards_texture)


func update_cards_texture(item) -> void:
	print("changement")
	for card : Card in get_children():
		card.apply_card_texture()

	
# Update function called every frame
func _process(delta: float) -> void:
	if card_is_dragged:
		# Get the mouse position and clamp it within screen bounds
		var mouse_pos = get_global_mouse_position()
		card_is_dragged.global_position = mouse_pos-card_is_dragged.size/2  # Move the dragged card to the mouse position

# Function to start dragging a card
func start_drag(card : Card):
	if not get_parent().client.id == get_parent().client.turn_player:
		print("It's not your turn, you cannot drag a card.")
		return
	card_is_dragged = card
	card.dragging(true)
	card.z_index = 10  # Bring the card to the front layer

# Function to reset player's turn (allow playing in all zones again)
func start_turn():
	can_play = [1, 1, 1]

# Function to handle when a card is released
func end_drag():
	if not card_is_dragged: return
	
	card_is_dragged.dragging(false)
	card_is_dragged._on_mouse_exited()
	card_is_dragged.z_index = 1  # Reset card layering

	# Check which play zone the card is dropped in
	var card_zone_found : PlayZone = check_zone()
	
	if card_zone_found and not card_is_dragged in card_zone_found.cards_in_zone:

		
		player_hand_reference.remove_card_from_hand(card_is_dragged)  # Remove the card from the player's hand
		
		# Determine the play area and position
		var area = card_zone_found.Play_ZoneType
		#print("Zone type: " + str(area))
		var player_id = get_parent().client.turn_player
		
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
			message_manager_reference.send_card_played(player_id, card_is_dragged.card_type, card_is_dragged.card_color, area, card_zone_found.id_player if area == 1 else -1)
			
			# Add the card to the play zone
			if card_is_dragged.card_type == Global.CardType.ASSASSIN:
				#print("Assassin")
				affichage_slot_card.AssassinMenue = true
				affichage_slot_card.pause(card_zone_found)  # Affiche le menu
				affichage_slot_card.instantiate_all_cards()  # Charge les cartes
				
			#card_zone_found.add_card(card_is_dragged)
			remove_child(card_is_dragged)
			
			if card_is_dragged.card_type == Global.CardType.SPY:
				card_is_dragged.hide_card()
			can_play[id_can_play] = 0  # Mark the zone as played
				
		else:
			# If the player can't play in this zone, return the card to their hand
			player_hand_reference.add_card_to_hand(card_is_dragged)
	else:
		# If no valid zone is found, return the card to the player's hand
		player_hand_reference.add_card_to_hand(card_is_dragged)
	
	card_is_dragged = null  # Clear the dragged card variable
	





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
	


func _on_child_entered_tree(node: Card) -> void:
	node.card_pressed.connect(start_drag)

	
	
