extends Node2D
class_name CardSlot

# Array to store cards currently in the slot
var cards_in_slot: Array = []

# Spacing between cards in the slot
const CARD_SPACING: int = 10

# References to important nodes
@onready var main_node: Node2D = get_node("/root/Main")  # Reference to the main node
@onready var count_label: Label = $PanelContainer/CountLabel  # Reference to the label displaying card count

# Enumeration defining different play zone types
enum PlayZoneType { Joueur, Ennemie, Grace, Disgrace }

func _ready() -> void:
	#print("CardSlot ready: ", self.name)  # Debug message when the slot is ready
	$PanelContainer.hide()
	# Check if the label exists
	if count_label:
		#print("Label found for ", self.name)
		count_label.z_index = 10  # Ensure the label appears on top
	else:
		print("Label NOT found for ", self.name)

# Function to determine the type of play zone
func determine_zone_type() -> PlayZoneType:
	return get_parent().Play_ZoneType  # Get the play zone type from the parent node

# Function to remove a card from the slot
func remove_card(card: Card) -> void:
	if card in cards_in_slot:
		cards_in_slot.erase(card)  # Remove the card from the list
		update_card_positions()  # Update the positions of remaining cards
		#print("Card count updated")  # Uncomment if needed
		print("Card removed from ", self.name, ". Remaining cards: ", cards_in_slot.size())

# Function to reposition cards after one is removed
func update_card_positions() -> void:
	for i in range(cards_in_slot.size()):
		var card: Card = cards_in_slot[i]
		card.position = position + Vector2(i * CARD_SPACING, 0)  # Adjust card position

		# Disable the collision shape if it exists
		if card.has_node("Area2D/CollisionShape2D"):
			card.get_node("Area2D/CollisionShape2D").disabled = true

# Function to update the count label based on the number of cards
func update_count_label(value : int) -> int:  # 'value' is used to adjust the count based on special card effects
	if count_label:
		var cpt: int = 0

		# Loop through all cards and apply any special count logic
		for c : Card in cards_in_slot:
			cpt += value * c.get_value()

		# Update the label text, hide it if count is zero
		count_label.text = str(cpt) if cpt != 0 else ""
		count_label.add_theme_color_override("font_color", Color(1, 0, 0))  # Set text color to red
		if cpt != 0:
			$PanelContainer.show()
		else:
			$PanelContainer.hide()
			
		
		return cpt
	else:
		print("CountLabel not found in CardSlot: ", self.name)
		return 0

# Function to get all cards in the slot
func get_all_cards() -> Array:
	return cards_in_slot

# Function to get the number of cards in the slot
func get_card_count() -> int:
	return cards_in_slot.size()

# Function to get a specific card by index
func get_card_at_index(index: int) -> Node2D:
	if index >= 0 and index < cards_in_slot.size():
		return cards_in_slot[index]
	return null  # Return null if the index is out of range

# Function to get the first card in the slot
func get_first_card() -> Node2D:
	return cards_in_slot[0] if not cards_in_slot.is_empty() else null

# Function to get the last card in the slot
func get_last_card() -> Node2D:
	return cards_in_slot[-1] if not cards_in_slot.is_empty() else null

# Function to find a card by its name
func find_card_by_name(card_name: String) -> Node2D:
	for card in cards_in_slot:
		if card.name == card_name:
			return card
	return null  # Return null if no card with the given name is found

# Function to get all cards of a specific type
func get_cards_by_type(card_type: String) -> Array:
	return cards_in_slot.filter(func(card): return card.card_type == card_type)
