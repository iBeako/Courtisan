extends Node2D

const CARD_SCENE_PATH = "res://Scene/card.tscn"

var deck_cards = ["carte","carte","carte","carte","carte","carte","carte","carte"]  # Liste des cartes dans le deck
var card_colors = ["Papillons", "Crapauds", "Rossignols", "Lièvres", "Cerfs", "Carpes"]  # Types de cartes

var Hand_Count = 3

@onready var player_hand = get_node("../PlayerHand")

func _ready() -> void:
	$Area2D.collision_layer = 1<<4
	randomize()  # Initialise la génération aléatoire



# Fonction pour tirer des cartes et leur attribuer un type aléatoire
func draw_cards():
	print("Drawing cards...")

	if not player_hand:
		print("Erreur : player_hand introuvable")
		return
	
	var card_scene = preload(CARD_SCENE_PATH)
	
	while player_hand.player_hand.size() < Hand_Count:
		var new_card = card_scene.instantiate()  # Instancier la carte



		var card_color = get_random_card_color()  # Attribuer une couleur aléatoire
		new_card.card_color = card_color  # Assigner la couleur à la carte

		new_card.apply_card_texture()  # Mettre à jour la texture immédiatement

		new_card.z_index = 5
		new_card.name = "carte_" + card_color  # Nommer la carte
		
		$"../CardManager".add_child(new_card)  # Ajouter la carte au CardManager
		
		player_hand.add_card_to_hand(new_card)  # Ajouter à la main du joueur
	$"../CardManager".start_turn()
	
# Fonction pour récupérer un type de carte aléatoire
func get_random_card_color() -> String:
	return card_colors[randi() % card_colors.size()]  # Retourne un type de carte aléatoire
