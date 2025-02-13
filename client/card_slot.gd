extends Node2D
var card_in_slot = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print($Area2D.collision_mask)



var cards_in_slot = []  # Liste des cartes dans le slot
const CARD_SPACING = 20  # Espacement entre les cartes

func add_card(card):
	if card in cards_in_slot:
		return  # Évite d'ajouter la même carte plusieurs fois

	cards_in_slot.append(card)
	update_card_positions()

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
