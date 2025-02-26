extends Node2D

# Variables
var card_in_slot = false
var cards_in_slot: Array = []  # Liste des cartes dans le slot
const CARD_SPACING: int = 10  # Espacement entre les cartes

# Référence à la scène principale (à définir dans l'éditeur ou via un script)
@onready var main_node: Node2D = get_node("/root/Main")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print($Area2D.collision_mask)  # Affiche le masque de collision

# Ajouter une carte au slot
func add_card(card: Node2D) -> void:
	if card in cards_in_slot:
		return  # Évite d'ajouter la même carte plusieurs fois

	# Déterminer dynamiquement le type de zone en fonction du parent
	var zone_type: String = determine_zone_type()
	print("Zone type determined: ", zone_type)  # Affiche le type de zone déterminé

	# Déterminer la position en fonction du type de carte et du type de zone
	var target_position: Vector2 = calculate_card_position_based_on_type(card.card_type, zone_type)

	# Animation pour un placement fluide
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(card, "position", target_position, 0.2)

	# Désactiver la collision pour éviter les conflits
	card.get_node("Area2D/CollisionShape2D").disabled = true

	# Ajouter la carte à la liste des cartes dans le slot
	cards_in_slot.append(card)

# Déterminer le type de zone en fonction du parent
func determine_zone_type() -> String:
	var parent_name: String = get_parent().name  # Récupère le nom du nœud parent
	print("Parent name: ", parent_name)  # Affiche le nom du parent

	# Extraire le type de zone du nom du parent
	if "Joueur" in parent_name:
		return "Joueur"
	elif "Grace" in parent_name:
		return "Grace"
	elif "Disgrace" in parent_name:
		return "Disgrace"
	elif "Ennemie" in parent_name:
		return "Ennemie"
	else:
		print("Unknown zone type for parent: ", parent_name)
		return "Joueur"  # Valeur par défaut

# Calculer la position de la carte en fonction du type de carte et du type de zone
func calculate_card_position_based_on_type(card_type: String, zone_type: String) -> Vector2:
	print("Calculating position for card type: ", card_type, " in zone: ", zone_type)

	# Construire le nom du nœud en fonction de la couleur de la carte et du type de zone
	var node_name: String = card_type.capitalize() + "_" + zone_type
	print("Node name to find: ", node_name)  # Affiche le nom du nœud recherché

	# Récupérer la zone correspondante
	var target_zone: Node = get_target_zone(zone_type)

	# Vérifier si la zone existe
	if not target_zone:
		print("Error: Target zone not found for type: ", zone_type)
		return Vector2(0, 0)

	# Trouver le nœud dans la zone
	var slot_node: Node2D = target_zone.get_node_or_null(node_name)

	# Si le nœud est trouvé, retourner sa position globale
	if slot_node:
		print("Node found: ", slot_node.name, " at global position ", slot_node.global_position)
		var local_pos = main_node.to_local(slot_node.global_position)  # Convertit en coordonnées locales par rapport à la scène principale
		print("Node local position in Main: ", local_pos)
		return local_pos
	else:
		print("Node not found: ", node_name)
		return Vector2(0, 0)

# Récupérer la zone cible en fonction du type de zone
func get_target_zone(zone_type: String) -> Node:
	print("Getting target zone for type: ", zone_type)  # Affiche le type de zone recherché
	match zone_type:
		"Joueur":
			return get_node_or_null("/root/Main/PlayZone_Joueur")
		"Grace":
			return get_node_or_null("/root/Main/PlayZone_Grace")
		"Disgrace":
			return get_node_or_null("/root/Main/PlayZone_Disgrace")
		"Ennemie":
			return get_node_or_null("/root/Main/PlayZone_Ennemie")
		_:
			print("Unknown zone type: ", zone_type)
			return null

# Mettre à jour les positions des cartes
func update_card_positions() -> void:
	for i: int in range(cards_in_slot.size()):
		var card: Node2D = cards_in_slot[i]
		card.position = position + Vector2(i * CARD_SPACING, 0)  # Décalage horizontal
		card.get_node("Area2D/CollisionShape2D").disabled = true  # Désactiver la collision

# Retirer une carte du slot
func remove_card(card: Node2D) -> void:
	if card in cards_in_slot:
		cards_in_slot.erase(card)
		update_card_positions()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
