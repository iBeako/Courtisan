extends Control



var play_zone_type: Global.PlayZoneType  # Stocke le type reçu
var paused : bool = false
var AssassinMenue : bool = false

# Fonction exécutée au démarrage de la scène
func _ready() -> void:
	resume()  # Appel à resume() dès le départ pour préparer le menu

# Fonction pour relancer le menu (resume)
func resume() -> void:
	# Supprime toutes les cartes dans le GridContainer
	for card in $Panel/MarginContainer2/ScrollContainer/GridContainer.get_children():
		card.queue_free()  # Supprime proprement chaque carte
	AssassinMenue = false
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
#func _on_button_pressed() -> void:
	#var random_type = randi() % TYPES.size()  # Choix aléatoire parmi les types
	#var random_color = CARD_COLORS[randi() % CARD_COLORS.size()]  # Choix aléatoire parmi les couleurs
	#instantiate_card(random_type, random_color)  # Instancie la carte avec les paramètres choisis
	#instantiate_all_cards(play_zone_type)

# Fonction pour instancier une carte et l'ajouter au GridContainer
func instantiate_card(card_type: Global.CardType, card_color: String, parent_slot: CardSlot) -> void:
	# Précharge la scène de la carte
	var card_scene = preload("res://Scene/card.tscn")
	
	# Crée une instance de la carte
	var card_instance = card_scene.instantiate()
	card_instance.custom_minimum_size = Vector2(164, 300)  # Définit la taille minimale de la carte
	card_instance.card_color = card_color  # Assigne la couleur de la carte
	card_instance.card_type = card_type  # Assigne le type de la carte
	card_instance.parent_slot = parent_slot
	
	
	# Ajoute la carte au GridContainer dans le menu
	$Panel/MarginContainer2/ScrollContainer/GridContainer.add_child(card_instance)

# Fonction pour instancier toutes les cartes dans le GridContainer
# Fonction pour instancier toutes les cartes dans le GridContainer
func instantiate_all_cards(play_zone: PlayZone) -> void:
	# Récupère les PlayZones (ajuste les chemins si nécessaire)
	if AssassinMenue == true:
		print("Il s'agit de l'assassin Menu")
	
	# Vérifie que la PlayZone est bien définie
	if play_zone == null:
		print("❌ Erreur : PlayZone invalide ! Impossible d'instancier les cartes.")
		return

	# Parcourt chaque couleur dans la liste des couleurs possibles
	#for color in Global.Family:
		#var card_slot = play_zone.get_node_or_null(color)  # Trouve le CardSlot par couleur
		#
		#if card_slot == null:
			#print("⚠ CardSlot non trouvé pour la couleur :", color)
			#continue  # Passe à la prochaine couleur
#
		#if card_slot.cards_in_slot.is_empty():
			#print("ℹ Aucun carte dans le slot :", color)
			#continue  # Passe au prochain slot

	# Instancie toutes les cartes présentes dans le slot
	play_zone.cards_in_zone.sort_custom(
		func(a : Card, b : Card)-> bool: return a.card_color<b.card_color
	)
	for card in play_zone.cards_in_zone:
		if card == null:
			print("⚠ Erreur : Une carte est NULL, vérifie ton code !")
			continue

		instantiate_card(card.card_type, card.card_color,card.parent_slot)
			

	print("✅ Toutes les cartes ont été instanciées.")

	
