extends Node2D

enum PlayZoneType { Joueur, Ennemie, Grace, Disgrace }
@export var Play_ZoneType: PlayZoneType = PlayZoneType.Grace

# Référence au ColorRect
@onready var color_rect: ColorRect = $ColorRect

# Liste des nœuds à renommer
var nodes_to_rename = ["Papillons", "Crapauds", "Rossignols", "Lièvres", "Cerfs", "Carpes"]

# Appelé lorsque le nœud entre dans l'arbre de la scène
func _ready() -> void:
	update_color_rect()
	#rename_nodes_based_on_type()

# Fonction pour mettre à jour la couleur du ColorRect
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
		_:
			color_rect.color = Color(1, 1, 1)  # Blanc par défaut

# Fonction pour renommer les nœuds en fonction du type de zone
func rename_nodes_based_on_type() -> void:
	for node_base_name in nodes_to_rename:
		var node_to_rename = get_node_or_null(node_base_name + "_Joueur")  # Nom par défaut
		if node_to_rename:
			match Play_ZoneType:
				PlayZoneType.Grace:
					node_to_rename.name = node_base_name + "_Grace"
					print("Renamed node to: ", node_to_rename.name)  # Affiche le nouveau nom
				PlayZoneType.Disgrace:
					node_to_rename.name = node_base_name + "_Disgrace"
					print("Renamed node to: ", node_to_rename.name)  # Affiche le nouveau nom
		else:
			print("Error: Node ", node_base_name + "_Grace", " not found!")
