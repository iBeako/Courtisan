extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# Give a dictionary version of a JSON file
func JSON_into_dictionary(text: String):
	var json = JSON.new()
	var parsed_data = json.parse(text)
	
	if parsed_data.error != OK:
		print("Error convertion text into JSON")
	else :
		return parsed_data.result
