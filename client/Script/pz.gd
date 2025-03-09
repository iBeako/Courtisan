extends Node
class_name PlayZone

enum PlayZoneType { Joueur, Ennemie, Grace, Disgrace }
@export var Play_ZoneType: PlayZoneType = PlayZoneType.Joueur

@onready var color_rect: ColorRect = $ColorRect

var family_names = ["Papillons", "Crapauds", "Rossignols", "Lièvres", "Cerfs", "Carpes"]

var cards_in_zone : Array = []

func _ready() -> void:
	update_color_rect()
	$Area2D.collision_layer=1<<2



func update_color_rect() -> void:
	if not color_rect:
		print("Error: ColorRect not found!")
		return

	# Définir la couleur en fonction du type de zone
	match Play_ZoneType:
		PlayZoneType.Grace:
			color_rect.color = Color(0, 1, 0)  # Vert pour Grace
		PlayZoneType.Disgrace:
			color_rect.color = Color(1, 0, 0)  # Rouge pour Disgrace
		PlayZoneType.Joueur:
			color_rect.color = Color(0, 0, 1)
		PlayZoneType.Ennemie:
			color_rect.color = Color(1, 1, 0)
		_:
			color_rect.color = Color(1, 1, 1)  # Blanc par défaut

func add_card(card: Node2D) -> void:
	print("Adding card to slot: ", self.name)
	if card in cards_in_zone:
		return
	
	cards_in_zone.append(card)
	var card_slot : CardSlot = find_card_slot(card.card_type)
	
	if card_slot:
		card_slot.cards_in_slot.append(card)
		card.z_index = 5
		var target_position: Vector2 = card_slot.global_position
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(card, "position", target_position, 0.2)

		if card.has_node("Area2D/CollisionShape2D"):
			card.get_node("Area2D/CollisionShape2D").disabled = true
		
		update_labels()
		#card_slot.update_count_label()
		print("Card added to ", card_slot.name, ". Total cards: ", card_slot.cards_in_slot.size())
	else:
		print("Failed to add card: CardSlot not found")

func update_labels(emit_signal : bool = true, values : Dictionary = {}) -> Dictionary:
	push_error("Classe update labels non implémentée")
	return {}

func find_card_slot(card_type: String) -> Node2D:
	return get_node_or_null(card_type)








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
