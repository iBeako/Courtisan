extends HSlider

# Exported variable for specifying the audio bus name
@export 
var bus_name: String

# Exported variable for the sound effect to play when the slider value changes
@export
var sound: AudioStream

# Reference to the AudioStreamPlayer node
@onready var audio_player = $AudioStreamPlayer

# Stores the index of the audio bus
var bus_index: int

# Flag to ensure the script is fully initialized before playing sound
var initialized : bool = false

# Called when the node is added to the scene
func _ready() -> void:
	# Retrieve the index of the specified audio bus
	bus_index = AudioServer.get_bus_index(bus_name)
	
	# Connect the slider's value_changed signal to the custom handler function
	value_changed.connect(_on_value_changed)
	
	# Initialize the slider value based on the current bus volume
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	
	# Mark initialization as complete
	initialized = true

# Function called when the slider value is changed
func _on_value_changed(value: float) -> void:
	# Update the volume of the specified audio bus
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	
	# Play the assigned sound effect when the slider is adjusted
	if sound and initialized:
		audio_player.stream = sound
		audio_player.play()
