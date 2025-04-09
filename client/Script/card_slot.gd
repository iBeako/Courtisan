extends Node2D
class_name CardSlot
var card_type: Global.CardType
# Array to store cards currently in the slot
var cards_in_slot: Array = []

# Spacing between cards in the slot
const CARD_SPACING: int = 10

# References to important nodes
@onready var main_node: Node2D = get_node("/root/Main")  # Reference to the main node
@onready var count_label: Label = $PanelContainer/CountLabel  # Reference to the label displaying card count



func _ready() -> void:
	#print("CardSlot ready: ", self.name)  # Debug message when the slot is ready
	$PanelContainer.hide()

# Function to determine the type of play zone
func determine_zone_type() -> Global.PlayZoneType:
	return get_parent().Play_ZoneType  # Get the play zone type from the parent node

func remove_card(card: Card) -> void:
	# Afficher la carte à supprimer
	print("=== Tentative de suppression ===")
	
	# Variable pour vérifier si la carte a été trouvée
	var found = false
	
	# Parcourt les cartes dans le slot pour trouver celle à supprimer
	for c in cards_in_slot:
		print("Carte actuelle : ", c.name)
		print("Carte cible : ", card.name)
		
		# Vérifie si les propriétés correspondent (TYPES et card_colors)
		if (c.card_type == card.card_type and c.card_color == card.card_color):
			found = true  # La carte a été trouvée
			
			# Affiche l'état avant suppression
			print("Avant suppression : ", cards_in_slot)
			
			# Supprime la carte de la liste
			cards_in_slot.erase(c)
			
			# Affiche l'état après suppression
			print("Après suppression : ", cards_in_slot)
			print("Carte supprimée de ", self.name, ". Restantes : ", cards_in_slot.size())
			
			# Supprime visuellement la carte
			c.queue_free()
			
			# Met à jour le label après suppression
			update_count_label(1)  # Passez 1 si vous voulez recalculer normalement
			
			break  # Arrête la boucle une fois la carte trouvée et supprimée
	
	# Si aucune carte correspondante n'a été trouvée
	if not found:
		print("Échec : aucune carte correspondante trouvée dans le slot (ID cible : ", card.get_instance_id(), ")")



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
		#count_label.add_theme_color_override("font_color", Color(1, 0, 0))  # Set text color to red
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
