extends Node2D

const Hand_Count = 3
const CARD_SCENE_PATH = "res://Scene/card.tscn"
var player_hand = []
var center_screen_x
var CARD_WIDTH = 200
var HAND_Y_POSITION = 890

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	center_screen_x = get_viewport().size.x / 2
	var card_scene = preload(CARD_SCENE_PATH)  # Préchargez la scène de la carte

	for i in range(Hand_Count):
		var new_card = card_scene.instantiate()  # Créez une instance de la scène
		$"../CardManager".add_child(new_card)  # Ajoutez la carte au gestionnaire de cartes
		new_card.name = "Card"  # Donnez un nom à la carte
		add_card_to_hand(new_card)  # Ajoutez la carte à la main du joueur
	pass

func add_card_to_hand(card):
	if(card not in player_hand):
		player_hand.insert(0, card)
		update_hand_position()
	else:
		animate_card_position(card,card.starting_position )
	
func update_hand_position():
	for i in range(player_hand.size()):
		var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		var card = player_hand[i]
		card.starting_position = new_position
		animate_card_position(card, new_position)
		

func calculate_card_position(index):
	var total_width = (player_hand.size() - 1) * CARD_WIDTH
	var x_offset = center_screen_x + index * CARD_WIDTH - total_width / 2
	return x_offset

func animate_card_position(card, new_position):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, 0.1)

func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		update_hand_position()

	
