extends PlayZone

signal updated_score_board

# Appelé lorsque le nœud entre dans l'arbre de la scène
func _ready() -> void:
	super._ready()
	$Area2D.collision_layer=1<<2


func update_labels(emit_signal : bool = true, values : Dictionary = { #fonction qui mettra à jour les labels de la zone
	"Papillons" : 1, 
	"Crapauds" : 1, 
	"Rossignols" : 1, 
	"Lièvres" : 1, 
	"Cerfs" : 1, 
	"Carpes" : 1
}) -> Dictionary:
	if emit_signal : updated_score_board.emit()
	for node_name : String in family_names: # parcourir les nodes
		var nd : CardSlot = get_node_or_null(node_name)
		if not nd: break
		values[node_name]=nd.update_count_label(values[node_name])
	return values
	


	
