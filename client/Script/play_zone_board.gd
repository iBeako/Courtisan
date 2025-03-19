extends PlayZone

# Signal emitted when the scoreboard is updated
signal updated_score_board

# Called when the node enters the scene tree
func _ready() -> void:
	super._ready()  # Call the parent class's _ready() function
	# Set the collision layer for the Area2D (shifting 1 to the left by 2 places)
	$Area2D.collision_layer = 1 << 2

# Function to update the labels of the zone
func update_labels(emit_signal : bool = true, values : Dictionary = {
	"Papillons" : 1, 
	"Crapauds" : 1, 
	"Rossignols" : 1, 
	"Lièvres" : 1, 
	"Cerfs" : 1, 
	"Carpes" : 1
}) -> Dictionary:
	# Emit the updated_score_board signal if enabled
	if emit_signal:
		updated_score_board.emit()
	
	# Iterate through family names to update their respective labels
	for node_name : String in family_names:
		var nd : CardSlot = get_node_or_null(node_name)  # Retrieve the node if it exists
		if not nd:
			break  # Stop iteration if node is not found
		values[node_name] = nd.update_count_label(values[node_name])  # Update label count
	
	return values
	
