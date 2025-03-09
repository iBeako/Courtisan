extends Node2D

const CARD_SCENE_PATH = "res://Scene/card.tscn"
const COLLISION_MASK_DECK = 4
const Hand_Count = 3

var card_types = ["Papillons", "Crapauds", "Rossignols", "Lièvres", "Cerfs", "Carpes"]  # Types de cartes

@onready var player_hand = get_node("../PlayerHand")  # Assurez-vous que le chemin est correct

func _ready() -> void:
	randomize()  # Initialise la génération aléatoire
	print($Area2D.collision_mask)

# Fonction pour tirer des cartes et leur attribuer un type aléatoire
func draw_cards():
	print("Drawing cards...")

	if not player_hand:
		print("Erreur : player_hand introuvable")
		return
	
	var card_scene = preload(CARD_SCENE_PATH)
	
	while player_hand.player_hand.size() < Hand_Count:
		var new_card = card_scene.instantiate()  # Instancier la carte
		var card_type = get_random_card_type()  # Sélectionner un type aléatoire
		
		new_card.card_type = card_type  # Assigner le type de carte
		new_card.apply_card_texture()  # Mettre à jour la texture immédiatement
		new_card.z_index = 10
		
		$"../CardManager".add_child(new_card)  # Ajouter la carte au CardManager
		new_card.name = "carte_" + card_type  # Nommer la carte
		
		player_hand.add_card_to_hand(new_card)  # Ajouter à la main du joueur
# Fonction pour récupérer un type de carte aléatoire
func get_random_card_type() -> String:
	return card_types[randi() % card_types.size()]  # Retourne un type de carte aléatoire
