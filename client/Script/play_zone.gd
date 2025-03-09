extends PlayZone



func _ready() -> void:
	super._ready()
	get_parent().get_node("PlayZone_Grace").connect("updated_score_board",update_labels)
	get_parent().get_node("PlayZone_Disgrace").connect("updated_score_board",update_labels)

	adjust_labels()




func adjust_labels() -> void:
	if Play_ZoneType == PlayZoneType.Joueur:
		for node_base_name in family_names:  # Exemple : joueur 1
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

func update_labels(emit_signal : bool = false, values : Dictionary = {}) -> Dictionary: 
	"""
	Met a jour les labels de score pour chaque slot
	/!/ emit_signal ne sert a rien ici mais doit etre present pour match avec la signature de la fonction de la classe parent
	"""
	
	var node_grace : Node2D = get_parent().get_node("PlayZone_Grace")
	var node_disgrace : Node2D = get_parent().get_node("PlayZone_Disgrace")
	
	var dict_grace : Dictionary = node_grace.update_labels(false)
	var dict_disgrace : Dictionary = node_disgrace.update_labels(false)
	
	
	for node_name : String in family_names: # parcourir les nodes
		var nd : CardSlot = get_node_or_null(node_name)
		if not nd: break
		var score_famille : int = dict_grace[node_name]-dict_disgrace[node_name]
		values[node_name]=nd.update_count_label(score_famille)
	return values
	
