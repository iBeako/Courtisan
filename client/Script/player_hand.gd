extends Node2D

signal hand_emptied  # Signal émis lorsque la main est vide

const CARD_SCENE_PATH = "res://Scene/card.tscn"
var player_hand = []
var center_screen_x
var CARD_WIDTH = 95
var HAND_Y_POSITION =940

func add_card_to_hand(card):
	if card not in player_hand:
		player_hand.insert(0, card)
		update_hand_position()
	else:
		animate_card_position(card, card.starting_position)

func is_hand_empty():
	return len(player_hand) == 0

func update_hand_position():
	for i in range(player_hand.size()):
		var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		var card = player_hand[i]
		card.starting_position = new_position
		animate_card_position(card, new_position)

func calculate_card_position(index):
	var total_width = (player_hand.size() - 1) * CARD_WIDTH
	center_screen_x = get_viewport().size.x / 4 + 100
	var x_offset = center_screen_x + index * CARD_WIDTH - total_width / 2
	return x_offset

func animate_card_position(card, new_position):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, 0.1)

func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		update_hand_position()
		if player_hand.is_empty():
			emit_signal("hand_emptied")  # Émettre le signal si la main est vide
