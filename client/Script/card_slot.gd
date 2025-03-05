extends Node2D

var cards_in_slot: Array = []
const CARD_SPACING: int = 10

@onready var main_node: Node2D = get_node("/root/Main")
@onready var count_label: Label = $CountLabel

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

	var zone_type: String = determine_zone_type()
	var card_slot = find_card_slot(card.card_type, zone_type)
	
	if card_slot:
		card_slot.cards_in_slot.append(card)
		card.z_index = 5
		var target_position: Vector2 = calculate_card_position_based_on_type(card.card_type, zone_type)
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(card, "position", target_position, 0.2)

		if card.has_node("Area2D/CollisionShape2D"):
			card.get_node("Area2D/CollisionShape2D").disabled = true

		card_slot.update_count_label()
		print("Card added to ", card_slot.name, ". Total cards: ", card_slot.cards_in_slot.size())
	else:
		print("Failed to add card: CardSlot not found")

func determine_zone_type() -> String:
	var parent_name: String = get_parent().name
	print("Parent name: ", parent_name)

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
		return "Joueur"

func find_card_slot(card_type: String, zone_type: String) -> Node2D:
	var node_name: String = card_type.capitalize() + "_" + zone_type
	var target_zone: Node = get_target_zone(zone_type)
	
	if not target_zone:
		print("Error: Target zone not found for type: ", zone_type)
		return null
	
	var slot_node: Node2D = target_zone.get_node_or_null(node_name)
	if slot_node:
		print("CardSlot found: ", slot_node.name)
		return slot_node
	else:
		print("CardSlot not found: ", node_name)
		return null

func calculate_card_position_based_on_type(card_type: String, zone_type: String) -> Vector2:
	print("Calculating position for card type: ", card_type, " in zone: ", zone_type)
	var node_name: String = card_type.capitalize() + "_" + zone_type
	var target_zone: Node = get_target_zone(zone_type)

	if not target_zone:
		print("Error: Target zone not found for type: ", zone_type)
		return Vector2.ZERO

	var slot_node: Node2D = target_zone.get_node_or_null(node_name)
	if slot_node:
		print("Node found: ", slot_node.name, " at global position ", slot_node.global_position)
		var local_pos = main_node.to_local(slot_node.global_position)
		print("Node local position in Main: ", local_pos)
		return local_pos
	else:
		print("Node not found: ", node_name)
		return Vector2.ZERO

func get_target_zone(zone_type: String) -> Node:
	print("Getting target zone for type: ", zone_type)
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

func remove_card(card: Node2D) -> void:
	if card in cards_in_slot:
		cards_in_slot.erase(card)
		update_card_positions()
		update_count_label()
		print("Card removed from ", self.name, ". Remaining cards: ", cards_in_slot.size())

func update_card_positions() -> void:
	for i in range(cards_in_slot.size()):
		var card: Node2D = cards_in_slot[i]
		card.position = position + Vector2(i * CARD_SPACING, 0)
		if card.has_node("Area2D/CollisionShape2D"):
			card.get_node("Area2D/CollisionShape2D").disabled = true

func update_count_label() -> void:
	print("Updating label for ", self.name)
	if count_label:
		var new_text = str(cards_in_slot.size())
		count_label.text = new_text
		count_label.add_theme_color_override("font_color", Color(1, 0, 0))  # Rouge
		print("Label updated to: ", new_text)
	else:
		print("CountLabel not found in CardSlot: ", self.name)

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
