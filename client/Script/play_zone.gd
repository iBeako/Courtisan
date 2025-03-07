extends Node2D

enum PlayZoneType { Joueur, Ennemie, Grace, Disgrace }
@export var Play_ZoneType: PlayZoneType = PlayZoneType.Joueur

@onready var color_rect: ColorRect = $ColorRect

var nodes_to_rename = ["Papillons", "Crapauds", "Rossignols", "Lièvres", "Cerfs", "Carpes"]

func _ready() -> void:
	get_parent().get_node("PlayZone_Grace").connect("updated_score_board",update_labels)
	get_parent().get_node("PlayZone_Disgrace").connect("updated_score_board",update_labels)	
	update_color_rect()
	#rename_nodes_based_on_type()
	adjust_labels()

func update_color_rect() -> void:
	if not color_rect:
		print("Error: ColorRect not found!")
		return

	match Play_ZoneType:
		PlayZoneType.Joueur:
			color_rect.color = Color(0, 0, 1)
		PlayZoneType.Ennemie:
			color_rect.color = Color(1, 1, 0)
		_:
			color_rect.color = Color(1, 1, 1)

func rename_nodes_based_on_type() -> void:
	for node_base_name in nodes_to_rename:
		var node_to_rename = get_node_or_null(node_base_name + "_Joueur")
		if node_to_rename:
			match Play_ZoneType:
				PlayZoneType.Joueur:
					node_to_rename.name = node_base_name + "_Joueur"
				PlayZoneType.Ennemie:
					node_to_rename.name = node_base_name + "_Ennemie"
			print("Renamed node to: ", node_to_rename.name)
		else:
			print("Error: Node ", node_base_name + "_Joueur", " not found!")

func adjust_labels() -> void:
	if Play_ZoneType == PlayZoneType.Joueur:
		for node_base_name in nodes_to_rename:  # Exemple : joueur 1
			var slot = get_node_or_null(node_base_name)
			if slot:
				var label = slot.get_node_or_null("CountLabel")
				if label:
					label.rotation_degrees = 180
					label.scale = Vector2(1, -1)
					print("Adjusted label for: ", slot.name)
				else:
					print("Error: CountLabel not found in ", slot.name)
			else:
				print("Error: Slot ", node_base_name, " not found! (labels)")

func update_labels() -> Dictionary:
	var values : Dictionary = {}
	
	var node_grace : Node2D = get_parent().get_node("PlayZone_Grace")
	var node_disgrace : Node2D = get_parent().get_node("PlayZone_Disgrace")
	
	var dict_grace : Dictionary = node_grace.update_labels(false)
	var dict_disgrace : Dictionary = node_disgrace.update_labels(false)
	
	
	for node_name : String in nodes_to_rename: # parcourir les nodes
		var nd : CardSlot = get_node_or_null(node_name)
		if not nd: break
		var score_famille : int = dict_grace[node_name]-dict_disgrace[node_name]
		values[node_name]=nd.update_count_label(score_famille)
	return values
