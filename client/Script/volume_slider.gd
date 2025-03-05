extends HSlider

@export 
var bus_name: String

@export
var sound: AudioStream

@onready var audio_player = $AudioStreamPlayer

var bus_index: int

var initialized : bool = false

func _ready() -> void:
	bus_index=AudioServer.get_bus_index(bus_name)
	value_changed.connect(_on_value_changed)
	
	
	
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	initialized = true
	
	
	
func _on_value_changed(value: float)-> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	if sound and initialized:
		audio_player.stream = sound
		audio_player.play()
	
