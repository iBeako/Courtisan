extends Node2D
class_name CardSlot

var cards_in_slot: Array = []
const CARD_SPACING: int = 10

@onready var main_node: Node2D = get_node("/root/Main")
@onready var count_label: Label = $CountLabel

enum PlayZoneType { Joueur, Ennemie, Grace, Disgrace }


func _ready() -> void:
	print("CardSlot ready: ", self.name)
	if count_label:
		print("Label found for ", self.name)
		count_label.z_index = 10
	else:
		print("Label NOT found for ", self.name)

func add_card(card: Node2D) -> void:
	print("Adding card to slot: ", self.name)
	if card in cards_in_slot:
		return

	var card_slot = find_card_slot(card.card_type)
	
	if card_slot:
		card_slot.cards_in_slot.append(card)
		card.z_index = 5
		var target_position: Vector2 = card_slot.global_position
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(card, "position", target_position, 0.2)

		if card.has_node("Area2D/CollisionShape2D"):
			card.get_node("Area2D/CollisionShape2D").disabled = true

		#card_slot.update_count_label()
		get_parent().update_labels()
		print("Card added to ", card_slot.name, ". Total cards: ", card_slot.cards_in_slot.size())
	else:
		print("Failed to add card: CardSlot not found")

func find_card_slot(card_type: String) -> Node2D:
	return get_node_or_null("../"+card_type)

func determine_zone_type() -> PlayZoneType:
	return get_parent().Play_ZoneType


	




func remove_card(card: Node2D) -> void:
	if card in cards_in_slot:
		cards_in_slot.erase(card)
		update_card_positions()
		#update_count_label()
		print("Card removed from ", self.name, ". Remaining cards: ", cards_in_slot.size())

func update_card_positions() -> void:
	for i in range(cards_in_slot.size()):
		var card: Node2D = cards_in_slot[i]
		card.position = position + Vector2(i * CARD_SPACING, 0)
		if card.has_node("Area2D/CollisionShape2D"):
			card.get_node("Area2D/CollisionShape2D").disabled = true

func update_count_label(value : int) -> int: # value sert à pondérer les cartes dans les domaines des joueurs
	#print("Updating label for ", self.name)
	if count_label:
		var cpt:int = 0
		for c in cards_in_slot: #permettra de rajouter la logique avec les cartes compte double
			cpt+=value
			
		count_label.text = str(cpt) if cpt!=0 else ""
		count_label.add_theme_color_override("font_color", Color(1, 0, 0))  # Rouge
		#print("Label updated to: ", new_text)
		return cpt
	else:
		print("CountLabel not found in CardSlot: ", self.name)
		return 0

func get_all_cards() -> Array:
	return cards_in_slot

func get_card_count() -> int:
	return cards_in_slot.size()

func get_card_at_index(index: int) -> Node2D:
	if index >= 0 and index < cards_in_slot.size():
		return cards_in_slot[index]
	return null

func get_first_card() -> Node2D:
	return cards_in_slot[0] if not cards_in_slot.is_empty() else null

func get_last_card() -> Node2D:
	return cards_in_slot[-1] if not cards_in_slot.is_empty() else null

func find_card_by_name(card_name: String) -> Node2D:
	for card in cards_in_slot:
		if card.name == card_name:
			return card
	return null

func get_cards_by_type(card_type: String) -> Array:
	return cards_in_slot.filter(func(card): return card.card_type == card_type)
