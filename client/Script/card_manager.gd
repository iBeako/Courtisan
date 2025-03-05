extends Node2D
var screen_size
const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SLOT = 2
var card_is_dragged
var is_hovered : bool
var player_hand_reference
var message_manager_reference : MessageManager

var can_play = [1, 1, 1] #zone joueur, zone milieu, zone ennemie

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	player_hand_reference = $"../PlayerHand"
	message_manager_reference = $"../MessageManager"
	$"../inputManager".connect("left_mouse_button_released",on_left_mouse_button_released)
	
func _process(delta: float) -> void:
	if card_is_dragged:
		var mouse_pos = get_global_mouse_position()
		card_is_dragged.position = Vector2(clamp(mouse_pos.x,0,screen_size.x),clamp(mouse_pos.y,0,screen_size.y))
		card_is_dragged.position = mouse_pos


func start_drag(card):
	card_is_dragged = card
	card.scale = Vector2(1.0,1.0)
	
	
func start_turn():
	can_play = [1, 1, 1]
	
func end_drag():
	card_is_dragged.scale = Vector2(1.05, 1.05)
	var card_slot_found = check_card_slot()

	if card_slot_found and not card_is_dragged in card_slot_found.cards_in_slot:
		card_slot_found.add_card(card_is_dragged)
		player_hand_reference.remove_card_from_hand(card_is_dragged)  # Retire la carte de la main
		
		# Déterminer l'aire et la position (exemple : queen_table avec position spécifique)
		var area = card_slot_found.name
		var position = -1  # Exemple : -1 pour disgrâce
		var player_id = get_parent().player_id
		message_manager_reference.send_card_played(player_id, card_is_dragged.card_type, card_is_dragged.card_color, "our_domain")
		# Envoyer le message
		play_card(1, card_is_dragged, area, position)  # Exemple : joueur 1
	else:
		player_hand_reference.add_card_to_hand(card_is_dragged)  # Sinon, remet la carte en main

	card_is_dragged = null


	
func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)

func on_hovered_over_card(card):
	if(!is_hovered):
		is_hovered=true
		highlight_card(card,true)
	
func on_hovered_off_card(card):
	if(!card_is_dragged):
		highlight_card(card,false)
		var new_card_hover = check_card()
		if new_card_hover:
			highlight_card(new_card_hover,true)
		else:
			is_hovered=false
	
func highlight_card(card,hovered):
	if (hovered):
		card.scale = Vector2(1.05,1.05)
		card.z_index=2
	else:
		card.scale = Vector2(1.0,1.0)
		card.z_index=1
		
func check_card_slot() -> Node2D:
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask=COLLISION_MASK_CARD_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size()>0:
		return result[0].collider.get_parent()
	return null
	
func check_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask=COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size()>0:
		return get_card_with_highest_index(result)
	return null
	
func get_card_with_highest_index(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_index = current_card.z_index
			highest_z_card = current_card
	return highest_z_card

func on_left_mouse_button_released():
	if card_is_dragged:
		end_drag()
		
func play_card(player_id: int, card, area: String, position: int = 0):
	# Construire le message
	var message = {
		"message_type": "card_played",
		"player": player_id,
		"card_type": card.card_type,
		"family": card.card_color,
		"area": area
	}
	
	# Ajouter des informations spécifiques si nécessaire
	if area == "queen_table":
		message["position"] = position
	
	# Convertir en JSON et afficher dans la console
	var json_message = JSON.stringify(message)
	print("#card_played:\n" + json_message)
