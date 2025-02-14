extends Node2D
var screen_size
const COLLISION_MASK_CARD = 1	
const COLLISION_MASK_CARD_SLOT = 2
var card_is_dragged
var is_hovered
var player_hand_reference
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	player_hand_reference = $"../PlayerHand"
func _process(delta: float) -> void:
	if card_is_dragged:
		var mouse_pos = get_global_mouse_position()
		card_is_dragged.position = Vector2(clamp(mouse_pos.x,0,screen_size.x),clamp(mouse_pos.y,0,screen_size.y))
		card_is_dragged.position = mouse_pos

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card = check_card()
			if card :
				start_drag(card)
		else:
			if card_is_dragged:
				end_drag()
			
func start_drag(card):
	card_is_dragged = card
	card.scale = Vector2(1.0,1.0)
	
func end_drag():
	card_is_dragged.scale = Vector2(1.05, 1.05)
	var card_slot_found = check_card_slot()

	if card_slot_found and not card_is_dragged in card_slot_found.cards_in_slot:
		card_slot_found.add_card(card_is_dragged)
		player_hand_reference.remove_card_from_hand(card_is_dragged)  # Retire la carte de la main
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
		
func check_card_slot():
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
