extends Node2D

const CARD_SCENE_PATH = "res://Scene/card.tscn"
var deck_cards = ["carte","carte","carte","carte","carte","carte","carte","carte"]  # Liste des cartes dans le deck
var card_types = ["blanc", "vert", "rouge", "jaune", "marron", "bleu"]  # Types de cartes
var player_hand  # Référence à PlayerHand
var Hand_Count = 3
const COLLISION_MASK_DECK = 4

func _ready() -> void:
	print($Area2D.collision_mask)
	player_hand = get_node("../PlayerHand")  # Assurez-vous que le chemin est correct

# Fonction pour tirer des cartes et leur attribuer une couleur
func draw_cards():
	print("Drawing cards...")
	var card_scene = preload(CARD_SCENE_PATH)
	
	# Tirer des cartes jusqu'à ce que la main soit pleine
	while player_hand.is_hand_empty() or player_hand.player_hand.size() < Hand_Count:
		var new_card = card_scene.instantiate()  # Instancier la carte
		var card_color = get_random_card_color()  # Attribuer une couleur aléatoire
		new_card.card_type = card_color  # Assigner la couleur à la carte
		$"../CardManager".add_child(new_card)  # Ajouter la carte au CardManager
		new_card.name = "carte"  # Nom de la carte
		player_hand.add_card_to_hand(new_card)  # Ajouter la carte à la main du joueur
# Fonction pour récupérer une couleur aléatoire parmi les types de cartes
func get_random_card_color() -> String:
	return card_types[randi() % card_types.size()]  # Retourne une couleur aléatoire de la liste
