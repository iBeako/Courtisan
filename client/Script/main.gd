extends Node2D

# Player identifier
var player_id : int = 1

# Dictionary to store the number of cards in each slot
var slot_card_counts: Dictionary = {}

func _ready() -> void:
	# Connect signals for each play zone
	print_tree()
	var client = load("res://Script/network.gd").new()
	add_child(client)
	await get_tree().create_timer(3.0).timeout
	var login = {"message_type":"connexion","login":"login","password":"password"}
	client.send_message_to_server.rpc_id(1,login)
	await get_tree().create_timer(2.0).timeout
	for zone_name in ["PlayZone_Joueur", "PlayZone_Grace", "PlayZone_Disgrace", "PlayZone_Ennemie"]:
		if has_node(zone_name):
			var zone = get_node(zone_name)
			# Assuming each zone has 6 slots
			for i in range(1, 7):
				var slot_name = "CardSlot" + str(i)  # Ensure slots are correctly named
				if zone.has_node(slot_name):
					var slot = zone.get_node(slot_name)
					# Initialize the card count for this slot
					slot_card_counts[zone_name + "/" + slot_name] = 0 

					# Connect the signal when a card is added to the slot
					slot.card_added.connect(func(card): 
						slot_card_counts[zone_name + "/" + slot_name] += 1
						update_ui()
					)

	# Update the UI initially
	update_ui()

# Function to update the UI with the number of cards in each slot
func update_ui() -> void:
	for key in slot_card_counts.keys():
		print("Slot: ", key, " - Card Count: ", slot_card_counts[key])
	# Here, update UI elements (e.g., labels) with the card counts.
	# Use `get_node()` to access these elements and modify their text.
