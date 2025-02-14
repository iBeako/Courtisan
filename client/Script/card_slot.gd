extends Node2D
var card_in_slot = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print($Area2D.collision_mask)



var cards_in_slot = []  # Liste des cartes dans le slot
const CARD_SPACING = 10  # Espacement entre les cartes

func add_card(card):
	if card in cards_in_slot:
		return  # Évite d'ajouter la même carte plusieurs fois

	# Récupérer la largeur de l'écran
	var screen_width = get_viewport_rect().size.x

	# Déterminer la position en fonction du type de carte
	var target_x_position = calculate_card_position_based_on_type(card.card_type)
	var target_position = Vector2(target_x_position, self.position.y)

	# Animation pour un placement fluide
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", target_position, 0.2)

	# Désactiver la collision pour éviter les conflits
	card.get_node("Area2D/CollisionShape2D").disabled = true

	# Ajouter la carte à la liste des cartes dans le slot
	cards_in_slot.append(card)

func calculate_card_position_based_on_type(card_type):
	match card_type:
		"blanc":
			return 344  # Position en pixels
		"vert":
			return 550  # Position en pixels
		"rouge":
			return 760  # Position en pixels
		"jaune":
			return 1160  # Position en pixels
		"marron":
			return 1340  # Position en pixels
		"bleu":
			return 1550  # Position en pixels
		_:
			return 324  # Par défaut, positionner à 324 px

func update_card_positions():
	for i in range(cards_in_slot.size()):
		var card = cards_in_slot[i]
		card.position = position + Vector2(i * CARD_SPACING, 0)  # Décalage horizontal
		card.get_node("Area2D/CollisionShape2D").disabled = true  # Désactiver la collision

func remove_card(card):
	if card in cards_in_slot:
		cards_in_slot.erase(card)
		update_card_positions()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
