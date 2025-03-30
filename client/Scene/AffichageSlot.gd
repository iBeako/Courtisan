extends Control

const TYPES = preload("res://Script/card.gd").TYPES
const CARD_COLORS = ["Papillons", "Crapauds", "Rossignols", "Lièvres", "Cerfs", "Carpes"]

var paused : bool = false
var menu_scene : PackedScene = load("res://Scene/menu_principal.tscn")

# Fonction exécutée au démarrage de la scène
func _ready() -> void:
	resume()  # Appel à resume() dès le départ pour préparer le menu

# Fonction pour relancer le menu (resume)
func resume() -> void:
	# Supprime toutes les cartes dans le GridContainer
	for card in $Panel/MarginContainer2/ScrollContainer/GridContainer.get_children():
		card.queue_free()  # Supprime proprement chaque carte
	
	# Lance l'animation "blur" à l'envers
	$AnimationPlayer.play_backwards("blur")
	paused = false
	# Attend que l'animation soit terminée avant de masquer le menu
	await $AnimationPlayer.animation_finished
	self.visible = false  # Cache le menu

# Fonction pour mettre en pause le menu (pause)
func pause() -> void:
	self.visible = true  # Affiche le menu
	$AnimationPlayer.play("blur")  # Joue l'animation "blur" pour un effet de flou
	paused = true

# Fonction exécutée lorsque le bouton "resume" est pressé
func _on_resume_pressed() -> void:
	resume()  # Relance le menu et supprime les cartes

# Fonction exécutée lorsque le bouton est pressé pour générer une carte
func _on_button_pressed() -> void:
	#var random_type = randi() % TYPES.size()  # Choix aléatoire parmi les types
	#var random_color = CARD_COLORS[randi() % CARD_COLORS.size()]  # Choix aléatoire parmi les couleurs
	#instantiate_card(random_type, random_color)  # Instancie la carte avec les paramètres choisis
	instantiate_all_cards()

# Fonction pour instancier une carte et l'ajouter au GridContainer
func instantiate_card(card_type: TYPES, card_color: String) -> void:
	# Précharge la scène de la carte
	var card_scene = preload("res://Scene/card.tscn")
	
	# Crée une instance de la carte
	var card_instance = card_scene.instantiate()
	card_instance.custom_minimum_size = Vector2(164, 300)  # Définit la taille minimale de la carte
	card_instance.card_color = card_color  # Assigne la couleur de la carte
	card_instance.card_type = card_type  # Assigne le type de la carte
	
	# Ajoute la carte au GridContainer dans le menu
	$Panel/MarginContainer2/ScrollContainer/GridContainer.add_child(card_instance)

# Fonction pour instancier toutes les cartes dans le GridContainer
func instantiate_all_cards() -> void:
	# Récupère la PlayZone (ajuste le chemin si nécessaire)
	var play_zone = get_node_or_null("/root/Main/PlayZone_Joueur")  # Remplace le chemin si nécessaire
	var play_zone2 = get_node_or_null("/root/Main/PlayZone_Ennemie")
	if play_zone == null:
		print("Erreur : PlayZone_Joueur non trouvée!")
		return  # Si PlayZone_Joueur n'est pas trouvée, on arrête la fonction
	
	# On parcourt chaque couleur dans la liste des couleurs possibles
	for color in CARD_COLORS:
		# Récupère le CardSlot par le nom de la couleur (par exemple, "Papillons", "Crapauds", etc.)
		var card_slot = play_zone.get_node(color)  # Trouve le CardSlot par couleur
		
		if card_slot:  # Si le CardSlot existe
			# Parcours toutes les cartes dans le CardSlot
			for card in card_slot.cards_in_slot:
				# Instancie la carte et l'ajoute au GridContainer
				instantiate_card(card.card_type, card.card_color)
		else:
			print("CardSlot ", color, " non trouvé.")
