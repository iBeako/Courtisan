extends Node2D

# Variables
var card_in_slot = false
var cards_in_slot: Array = []  # Liste des cartes dans le slot
const CARD_SPACING: int = 10  # Espacement entre les cartes

# Énumération pour les types de slot
enum SlotType { Haut, Bas }

# Propriété exportée pour identifier le type de slot
@export var slot_type: SlotType = SlotType.Haut

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print($Area2D.collision_mask)  # Affiche le masque de collision

# Ajouter une carte au slot
func add_card(card: Node2D) -> void:
	if card in cards_in_slot:
		return  # Évite d'ajouter la même carte plusieurs fois

	# Déterminer la position en fonction du type de carte
	var target_position: Vector2 = calculate_card_position_based_on_type(card.card_type)

	# Animation pour un placement fluide
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(card, "position", target_position, 0.2)

	# Désactiver la collision pour éviter les conflits
	card.get_node("Area2D/CollisionShape2D").disabled = true

	# Ajouter la carte à la liste des cartes dans le slot
	cards_in_slot.append(card)

# Calculer la position de la carte en fonction de son type
func calculate_card_position_based_on_type(card_type: String) -> Vector2:
	print("Calculating position for card type: ", card_type)

	var node_name: String = ""

	# Associer chaque type de carte à son slot haut ou bas
	match card_type:
		"blanc":
			node_name = "Blanc_" + SlotType.keys()[slot_type]
		"vert":
			node_name = "Vert_" + SlotType.keys()[slot_type]
		"rouge":
			node_name = "Rouge_" + SlotType.keys()[slot_type]
		"jaune":
			node_name = "Jaune_" + SlotType.keys()[slot_type]
		"marron":
			node_name = "Marron_" + SlotType.keys()[slot_type]
		"bleu":
			node_name = "Bleu_" + SlotType.keys()[slot_type]
		_:
			print("Unknown card type: ", card_type)
			return Vector2(0, 0)

	# Trouver le slot dans NeutralZone
	var neutral_zone: Node = get_node("/root/Main/NeutralZone")
	if not neutral_zone:
		print("Error: NeutralZone not found!")
		return Vector2(0, 0)

	var slot_node: Node2D = neutral_zone.get_node(node_name)
	if slot_node:
		print("Node found: ", slot_node.name, " at position ", slot_node.position)
		return slot_node.position
	else:
		print("Node not found: ", node_name)
		return Vector2(0, 0)

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
