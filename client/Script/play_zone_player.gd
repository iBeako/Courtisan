extends PlayZone

var id_player : int = -1
var name_player : String = ""
var id_image : int = 0

@onready var card_manager_reference = get_node("../CardManager")


# Called when the node enters the scene tree
func _ready() -> void:
	super._ready()
	card_manager_reference.card_played.connect(self.update_labels)
	$VBoxContainer.rotation = -self.rotation


func update_player(id_p : int, name_p : String, id_img : int):
	id_player = id_p
	name_player = name_p
	id_img = id_image
	
	$VBoxContainer/Label.text=name_player
	var img = load(Global.profile_pictures[id_img])

# Function to adjust labels' orientation for the player zone
func adjust_labels() -> void:
	if Play_ZoneType == Global.PlayZoneType.PLAYER:
		for node_base_name in family_names:  # Example: player 1
			var slot = get_node_or_null(node_base_name)
			if slot:
				var label = slot.get_node_or_null("CountLabel")
				if label:
					# Rotate and flip the label for better visibility
					label.rotation_degrees = 180
					label.scale = Vector2(1, -1)
					print("Adjusted label for: ", slot.name)
				else:
					print("Error: CountLabel not found in ", slot.name)
			else:
				print("Error: Slot ", node_base_name, " not found! (labels)")

# Function to update score labels for each slot
func update_labels(values : Dictionary = {}) -> Dictionary: 
	"""
	Updates the score labels for each slot.
	"""
	print("--------------------received---------------------",self)
	# Retrieve references to the Grace and Disgrace play zones
	var node_grace : Node2D = get_parent().get_node("PlayZone_Grace")
	var node_disgrace : Node2D = get_parent().get_node("PlayZone_Disgrace")
	
	# Get the score values from Grace and Disgrace zones
	var dict_grace : Dictionary = node_grace.update_labels()
	var dict_disgrace : Dictionary = node_disgrace.update_labels()
	
	# Iterate through family names and update their scores
	for node_name : String in family_names:
		var nd : CardSlot = get_node_or_null(node_name)
		if not nd:
			break
		# Calculate the final score based on Grace and Disgrace values
		var score_famille : int = dict_grace[node_name] - dict_disgrace[node_name]
		values[node_name] = nd.update_count_label(score_famille)
	
	return values
