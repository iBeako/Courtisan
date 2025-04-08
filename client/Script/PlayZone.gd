extends Node
class_name PlayZone


# Exported variable to set the type of play zone (default is 'Joueur')
@export var Play_ZoneType: Global.PlayZoneType = Global.PlayZoneType.PLAYER

# Reference to the ColorRect node in the scene
@onready var color_rect: ColorRect = $ColorRect

var param_button : Button
@onready var slotMenu : Control = get_node("/root/Main/slotMenuCanvas/SlotMenu")  # Chemin absolu vers SlotMenu

# List of family names used in the game
var family_names = ["Papillons", "Crapauds", "Rossignols", "Lièvres", "Cerfs", "Carpes"]

# Array to store cards currently in this play zone
var cards_in_zone : Array = []



# Called when the node is added to the scene
func _ready() -> void:
	update_color_rect()
	# Sets the collision layer for the area (shifting 1 to the left by 2 places)
	$Area2D.collision_layer = 1 << 2
	
	# Récupérer les nœuds nécessaires dans la scène

	param_button = $Button  # Accède au bouton ParamButton
	
	# Connecter le signal 'pressed' du bouton Param
	param_button.pressed.connect(self._on_param_button_pressed)

# Function to update the color of the ColorRect based on the play zone type
func update_color_rect() -> void:
	if not color_rect:
		print("Error: ColorRect not found!")
		return

	# Assign colors based on the type of play zone
	match Play_ZoneType:
		Global.PlayZoneType.FAVOR:
			color_rect.color = Color(0, 1, 0)  # Green for Grace
		Global.PlayZoneType.DISFAVOR:
			color_rect.color = Color(1, 0, 0)  # Red for Disgrace
		Global.PlayZoneType.PLAYER:
			color_rect.color = Color(0, 0, 1)  # Blue for Player
		Global.PlayZoneType.ENEMY:
			color_rect.color = Color(1, 1, 0)  # Yellow for Enemy
		_:
			color_rect.color = Color(1, 1, 1)  # Default to White

# Function to add a card to the play zone
func add_card(card: Card) -> void:
	print("Adding card to slot: ", self.name)
	card.card_placed()
	
	# Prevent duplicate cards in the zone
	if card in cards_in_zone:
		return
	
	# Add card to the zone
	cards_in_zone.append(card)

	var card_slot : CardSlot = find_card_slot(card.card_color, card.card_type)
	
	if card_slot:
		# Add the card to the corresponding slot
		card_slot.cards_in_slot.append(card)
		card.z_index = 5  # Ensure the card is drawn above other elements
		
		# Move the card to the slot position with a tween animation
		var center_offset = card.size / 2
		var target_position = card_slot.to_global(Vector2.ZERO) - card_slot.get_global_transform().basis_xform(center_offset)
		
		

		var tween_rotate: Tween = get_tree().create_tween().set_ease(Tween.EASE_IN)
		tween_rotate.tween_property(card, "rotation", self.rotation, 0.15)
		
		var tween_pos: Tween = get_tree().create_tween().set_ease(Tween.EASE_IN)
		tween_pos.tween_property(card, "global_position", target_position, 0.2)
		
		card.base_scale = self.scale
		card.scale = self.scale
		
		# Disable card's collision shape to prevent unwanted interactions
		if card.has_node("Area2D/CollisionShape2D"):
			card.get_node("Area2D/CollisionShape2D").disabled = true
		
		if card_slot.name == "Espions":
			card.hide_card()
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# Update the UI labels
		update_labels()
		print("Card added to ", card_slot.name, ". Total cards: ", card_slot.cards_in_slot.size())
		print("Card slot :",card_slot)
		card.parent_slot = card_slot
		print("✅ parent_slot assigné :", card.parent_slot)
	else:
		print("Failed to add card: CardSlot not found",card.card_color, card.card_type)

# Function to update labels (not implemented yet)
func update_labels(emit_signal : bool = true, values : Dictionary = {}) -> Dictionary:
	push_error("Class update_labels not implemented")
	return {}

# Function to find the appropriate card slot based on the card's color and type
func find_card_slot(card_color: String, card_type : int) -> Node2D:
	# If the card is an 'Espion', assign it to the 'Espions' slot
	if card_type == Global.CardType.SPY:
		return get_node_or_null("Espions")
	# Otherwise, find a slot matching the card color
	return get_node_or_null(card_color)





# Fonction appelée lorsque le bouton Param est pressé
func _on_param_button_pressed() -> void:
	# Inverse la visibilité du menu de pause

	slotMenu.pause()
	slotMenu.instantiate_all_cards(self)



# Fonction pour renommer les nœuds en fonction du type de zone
#func rename_nodes_based_on_type() -> void:
	#for node_base_name in nodes_to_rename:
		#var node_to_rename = get_node_or_null(node_base_name + "_Joueur")  # Nom par défaut
		#if node_to_rename:
			#match Play_ZoneType:
				#PlayZoneType.Grace:
					#node_to_rename.name = node_base_name + "_Grace"
					#print("Renamed node to: ", node_to_rename.name)  # Affiche le nouveau nom
				#PlayZoneType.Disgrace:
					#node_to_rename.name = node_base_name + "_Disgrace"
					#print("Renamed node to: ", node_to_rename.name)  # Affiche le nouveau nom
		#else:
			#print("Error: Node ", node_base_name + "_Grace", " not found!")
