extends Node2D

var player_id : int = 1

# Dictionnaire pour stocker le nombre de cartes dans chaque slot
var slot_card_counts: Dictionary = {}

func _ready() -> void:
	# Connecter les signaux de chaque slot
	for zone_name in ["PlayZone_Joueur", "PlayZone_Grace", "PlayZone_Disgrace", "PlayZone_Ennemie"]:
		if has_node(zone_name):
			var zone = get_node(zone_name)
			for i in range(1, 7): # Supposons 6 slots par zone
				var slot_name = "CardSlot" + str(i) # Assurez-vous que les slots sont nommés correctement
				if zone.has_node(slot_name):
					var slot = zone.get_node(slot_name)
					slot_card_counts[zone_name + "/" + slot_name] = 0 # Initialiser le compteur

					slot.card_added.connect(func(card): 
						slot_card_counts[zone_name + "/" + slot_name] += 1
						update_ui()
					)

	update_ui()  # Mettre à jour l'interface utilisateur initiale

func update_ui() -> void:
	# Mettre à jour l'interface utilisateur avec les informations sur le nombre de cartes dans chaque slot
	for key in slot_card_counts.keys():
		print("Slot: ", key, " - Card Count: ", slot_card_counts[key])
	# Ici, vous mettrez à jour vos éléments d'interface utilisateur (par exemple, des labels) avec les nombres de cartes.
	# Vous pouvez utiliser des fonctions `get_node()` pour accéder à ces éléments et modifier leur texte.
