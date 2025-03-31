extends Control

const TYPES = preload("res://Script/card.gd").TYPES
const CARD_COLORS = ["Papillons", "Crapauds", "Rossignols", "Lièvres", "Cerfs", "Carpes"]
enum PlayZoneType { Joueur, Ennemie, Grace, Disgrace }
var play_zone_type: PlayZoneType  # Stocke le type reçu
var paused : bool = false
var menu_scene : PackedScene = load("res://Scene/menu_principal.tscn")
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
func instantiate_all_cards(zone_type: PlayZoneType) -> void:
	# Récupère les PlayZones (ajuste les chemins si nécessaire)
	if(AssassinMenue==true):
		print("Il s'agit de l'assassin Menu")
	var play_zone_joueur = get_node_or_null("/root/Main/PlayZone_Joueur")
	var play_zone_ennemie = get_node_or_null("/root/Main/PlayZone_Ennemie")
	var play_zone_grace = get_node_or_null("/root/Main/PlayZone_Grace")
	var play_zone_disgrace = get_node_or_null("/root/Main/PlayZone_Disgrace")

	# Vérifie si toutes les PlayZones existent
	if play_zone_joueur == null or play_zone_ennemie == null or play_zone_grace == null or play_zone_disgrace == null:
		print("Erreur : Une ou plusieurs PlayZones sont introuvables!")
		return  

	# Sélectionne la bonne PlayZone en fonction du type
	var play_zone = null
	match zone_type:
		PlayZoneType.Joueur:
			play_zone = play_zone_joueur
		PlayZoneType.Ennemie:
			play_zone = play_zone_ennemie
		PlayZoneType.Grace:
			play_zone = play_zone_grace
		PlayZoneType.Disgrace:
			play_zone = play_zone_disgrace
		_:
			print("Erreur : Type de PlayZone invalide!")
			return

	# Parcourt chaque couleur dans la liste des couleurs possibles
	for color in CARD_COLORS:
		var card_slot = play_zone.get_node_or_null(color)  # Trouve le CardSlot par couleur
		
		if card_slot:  # Si le CardSlot existe
			for card in card_slot.cards_in_slot:
				instantiate_card(card.card_type, card.card_color)
		else:
			print("CardSlot ", color, " non trouvé.")
	


func set_play_zone_type(zone_type: PlayZoneType):
	play_zone_type = zone_type
